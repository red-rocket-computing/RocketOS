#include <linux/device.h>
#include <linux/fs.h>
#include <linux/poll.h>
#include <linux/miscdevice.h>
#include <linux/module.h>
#include <linux/types.h>
#include <linux/kfifo.h>
#include <linux/slab.h>

#include "dummy.h"

#define DUMMY_BUFFER_SIZE 1024

struct msws_state {
	u64 x;
	u64 w;
	u64 s;
};

struct dummy_file {
	struct msws_state msws_state;
	wait_queue_head_t readable;
	wait_queue_head_t writeable;
	struct mutex lock;
	DECLARE_KFIFO(buffer, u32, DUMMY_BUFFER_SIZE);
	struct miscdevice *misc_dev;
};

static int dummy_open(struct inode *inode, struct file *file);
static int dummy_release(struct inode *inode, struct file *file);
static ssize_t dummy_read(struct file *file, char __user *buf, size_t count, loff_t *ppos);
static ssize_t dummy_write(struct file *file, const char __user *buf, size_t count, loff_t *ppos);
static unsigned int dummy_poll(struct file *file, poll_table *pt);
static long dummy_ioctl(struct file *file, unsigned int cmd, unsigned long arg);

static const struct file_operations dummy_fops = {
	.owner	= THIS_MODULE,
	.open	= dummy_open,
	.release = dummy_release,
	.read	= dummy_read,
	.write	= dummy_write,
	.poll = dummy_poll,
	.unlocked_ioctl	= dummy_ioctl,
};

static struct miscdevice dummy_dev = {
	.minor = MISC_DYNAMIC_MINOR,
	.name = KBUILD_MODNAME,
	.fops = &dummy_fops,
};

static inline u32 msws(struct msws_state *state) 
{
	/* Middle Square Weyl Sequence RNG */
	state->x *= state->x; 
	state->w += state->s;
	state->x += state->w;
	state->x = (state->x >> 32) | (state->x << 32);

	return state->x;
}

static void msws_init(struct msws_state *state, u64 key)
{
	state->x = 0;
	state->w = 0;
	state->s = key;
}

static int dummy_open(struct inode *inode, struct file *file)
{
	struct dummy_file *dummy_file;

	dev_dbg(dummy_dev.this_device, "%s - from %s\n", __func__, current->comm);

	/* Allocate the file data */
	dummy_file = kmalloc(sizeof(struct dummy_file), GFP_KERNEL);
	if (!dummy_file)
		return -ENOMEM;

	/* Initialize the file data */
	msws_init(&dummy_file->msws_state, 0x3e079251c73bef2d);
	init_waitqueue_head(&dummy_file->readable);
	init_waitqueue_head(&dummy_file->writeable);
	INIT_KFIFO(dummy_file->buffer);
	mutex_init(&dummy_file->lock);

	/* Stash it in the file struct */
	file->private_data = dummy_file;

	/* All good */
	return 0;
}

static int dummy_release(struct inode *inode, struct file *file)
{
	dev_dbg(dummy_dev.this_device, "%s - from %s\n", __func__, current->comm);

	/* Release the file data */
	kfree(file->private_data);

	/* Should not be any errors */
	return 0;
}

static ssize_t dummy_read(struct file *file, char __user *buf, size_t count, loff_t *ppos)
{
	ssize_t copied;
	ssize_t ret = 0;
	struct dummy_file *dummy_file = file->private_data;

	dev_dbg(dummy_dev.this_device, "%s - %s %p %u\n", __func__, current->comm, buf, count);

	/* Check the size to ensure it is a multiple of 4 */
	if ((count & 0x3U) != 0)
		return -EINVAL;

	/* Wait for data if buffer is empty */
	if (kfifo_is_empty(&dummy_file->buffer)) {
		if ((file->f_flags & O_NONBLOCK) == 0) {
			ret = wait_event_interruptible(dummy_file->readable, !kfifo_is_empty(&dummy_file->buffer));
			if (ret == -ERESTARTSYS)
				return -EINTR;
		} else
			return -EAGAIN;
	}

	/* Protect the buffer and read the request data */
	if (mutex_lock_interruptible(&dummy_file->lock))
		return -EINTR;
	ret = kfifo_to_user(&dummy_file->buffer, buf, count, &copied);
	mutex_unlock(&dummy_file->lock);

	/* Return either the error code or the amount off data copied */
	return ret ? ret : copied;
}

static ssize_t dummy_write(struct file *file, const char __user *buf, size_t count, loff_t *ppos)
{
	ssize_t ret = 0;
	ssize_t copied = 0;
	struct dummy_file *dummy_file = file->private_data;
	const char *cur = buf;
	u32 value;

	dev_dbg(dummy_dev.this_device, "%s - from %s\n", __func__, current->comm);

	/* Check the size to ensure it is a multiple of 4 */
	if ((count & 0x3U) != 0)
		return -EINVAL;

	/* Wait for room is the buffer is full */
	if (kfifo_is_full(&dummy_file->buffer)) {
		if ((file->f_flags & O_NONBLOCK) == 0) {
			ret = wait_event_interruptible(dummy_file->writeable, !kfifo_is_full(&dummy_file->buffer));
			if (ret == -ERESTARTSYS)
				return -EINTR;
		} else
			return -EAGAIN;
	}

	/* Protect while writing data to the buffer */
	if (mutex_lock_interruptible(&dummy_file->lock))
		return -EINTR;

	/* Encrypt the buffer and store in the kfifo */
	while (cur < buf + count && !kfifo_is_full(&dummy_file->buffer)) {

		/* Try extract a 32 bit quanity from the buffer */
		if (copy_from_user(&value, cur, sizeof(u32)) != 0) {
			ret = -EINVAL;
			break;
		}

		/* XOR the value with the RNG and push into the fifo */
		copied += kfifo_put(&dummy_file->buffer, value ^ msws(&dummy_file->msws_state));

		/* Update the buffer position */
		cur += sizeof(u32);
	}

	mutex_unlock(&dummy_file->lock);

	/* Return either an error or the amount of data written */
	return ret ? ret : copied << 2;
}

static unsigned int dummy_poll(struct file *file, poll_table *pt)
{
	unsigned int mask = 0;
	struct dummy_file *dummy_file = file->private_data;

	dev_dbg(dummy_dev.this_device, "%s - from %s\n", __func__, current->comm);

	/* Get ready for potential waiting */
	poll_wait(file, &dummy_file->readable, pt);
	poll_wait(file, &dummy_file->writeable, pt);

	/* Build state mask */
	if (!kfifo_is_empty(&dummy_file->buffer))
		mask |= POLLIN | POLLRDNORM;
	mask |= POLLOUT | POLLWRNORM;

	/* Lets go */
	return mask;
}


static long dummy_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
{
	int ret = 0;
	struct dummy_file *dummy_file = file->private_data;

	dev_dbg(dummy_dev.this_device, "%s - cmd=0x%X arg=0x%lX\n", __func__, cmd, arg);

	/* Check type */
	if (_IOC_TYPE(cmd) != DUMMY_IOCTL_TYPE)
		return -EINVAL;

	/* We need to protect the seed while changing it */
	if (mutex_lock_interruptible(&dummy_file->lock))
		return -EINTR;

	/* Handle the command */
	if (_IOC_NR(cmd) == DUMMY_IOCTL_SET_KEY && access_ok(VERIFY_READ, (u64 *)arg, sizeof(u64 *)))
		msws_init(&dummy_file->msws_state, *(u64 *)arg);
	else
		ret = -EINVAL;

	mutex_unlock(&dummy_file->lock);

	return ret;
}

static void dummy_exit(void)
{
	printk(KERN_INFO "exiting %s\n", KBUILD_MODNAME);

	/* Unregister the dummy device */
	misc_deregister(&dummy_dev);
}

static __init int dummy_init(void)
{
	int ret;

	printk(KERN_INFO "initializing %s\n", KBUILD_MODNAME);

	/* Register the dummy device */
	ret = misc_register(&dummy_dev);
	if (ret < 0) {
		printk(KERN_ERR "misc_register failed");
		goto error_exit;
	}

	return 0;

error_exit:
	dummy_exit();
	return ret;
}

module_init(dummy_init);
module_exit(dummy_exit);

MODULE_DESCRIPTION("Middle Square Weyl Sequence Stream Cipher");
MODULE_AUTHOR("Stephen Street <stephen@redrocketcomputing.com>");
MODULE_LICENSE("GPL");
