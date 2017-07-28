# RocketOS

## Overview

This repository builds a lightweight bootable Linux OS using the busybox. The image is targeted at the vexpress ARM A9/A15 QEMU emulation enviroment and has the following features:

* v4.11 Linux Kernel
* v1.26 Busybox
* Simple gnumake based build system supporting both both external git projects and local applications
* Single file image with embedded initramfs root fileysystem suitable for tftp booting
* Device Tree vexpress-v2p-ca9 built into the image, no external bootloader required
* Sample out-of-kernel/out-of-tree "Middle Square Weyl Sequence" stream cipher loadable module
* /dev managed by devtmpfs providing simplified device management

## License

[Mozilla Public License, V2.0.](http://mozilla.org/MPL/2.0) and [GNU General Public License, version 2](https://www.gnu.org/licenses/gpl-2.0.html).

## Dependencies

RocketOS requires the following host tools:

* Ubuntu 16.04
* Git
* GCC ARM Linux toolchain
* GNU Make
* QEMU with Full System Emulator for ARM

To install the required tools on Ubuntu 16.04:

`sudo apt install build-essential git qemu-system-arm gcc-arm-linux-gnueabi`

## Building

To clone and build RocketOS from github

```
git clone https://github.com/sgstreet/RocketOS.git /path/to/repo
cd /path/to/repo
make
```

## Running under QEMU

To run:

```
cd /path/to/repo
qemu-system-arm -M vexpress-a9 -m 512M -kernel images/linux-vexpress-v2p-ca9.img -append “console=ttyAMA0” -serial stdio
```

The root passwd is `rocketos`

## Middle Square Weyl Sequence (MSWS) Stream Cipher Loadable Module

To test the "Middle Square Weyl Sequence" stream cipher loadable module, login as root and:

```
modprobe dummy
echo -n "0123" | ./dummy-example | ./dummy-example
```

## Known Issues

Just about everything. But a short, incomplete summary:

* Build system does extra work building the kernel on rebuilds.
* MSWS module poll and ioctl system calls have not been tested.
* Missing, limited and wrong documentation
* No sysroot available in image.
* Busybox and sample application are statically linked, see above.
* Missing/mismatched license files












