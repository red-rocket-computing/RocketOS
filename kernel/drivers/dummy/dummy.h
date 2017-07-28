#ifndef DUMMY_H
#define DUMMY_H

#include <linux/ioctl.h>
#include <linux/types.h>

#define DUMMY_IOCTL_TYPE 0xfc
#define DUMMY_IOCTL_SET_KEY 0

#define DUMMY_SET_KEY _IOW(DUMMY_IOCTL_TYPE, DUMMY_IOCTL_SET_KEY, u64*)
 
#endif