#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <stdint.h>
#include <stdbool.h>
#include <unistd.h>
#include <linux/dummy.h>


int main(int argc, char **argv)
{
	/* Open the dummy driver */
	int fd = open("/dev/dummy", O_RDWR | O_SYNC);
	if (fd < 0) {
		fprintf(stderr, "problem opening /dev/dummy: (%d) %s\n", errno, strerror(errno));
		return 1;
	}

	/* While not eof on stdin, read 4 byte quanities */
	uint32_t value;
	int n;
	while ((n = read(STDIN_FILENO, &value, sizeof(value))) == sizeof(value)) {

		if (write(fd, &value, sizeof(value)) != sizeof(value)) {
			fprintf(stderr, "problem writing /dev/dummy: (%d) %s\n", errno, strerror(errno));
			return 1;
		}

		if ((n = read(fd, &value, sizeof(value))) != sizeof(value)) {
			fprintf(stderr, "problem reading /dev/dummy: %d (%d) %s\n", n, errno, strerror(errno));
			return 1;
		}

		if (write(STDOUT_FILENO, &value, sizeof(value)) != sizeof(value)) {
			fprintf(stderr, "problem write stdout: (%d) %s\n", errno, strerror(errno));
			return 1;
		}
	}

	if (n < 0) {
		fprintf(stderr, "problem reading stdin: (%d) %s\n", errno, strerror(errno));
		return 1;
	}

	if (n > 0 && n < sizeof(value)) {
		fprintf(stderr, "truncated, stdin did not have multi of 4 byte data\n");
		return 1;
	}

	if (close(fd) < 0) {
		fprintf(stderr, "problem closing /dev/dummy: (%d) %s\n", errno, strerror(errno));
		return 1;
	}

	return 0;
}
