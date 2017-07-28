#
# Copyright (C) 2017 Red Rocket Computing
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
# 
# pkg.mk
# Created on: 18/05/17
# Author: Stephen Street
#
ifeq ($(findstring ${BUILD_ROOT},${CURDIR}),)
include ${PROJECT_ROOT}/tools/makefiles/target.mk
else

include ${PROJECT_ROOT}/tools/makefiles/quiet.mk

KSRC_DIR := ${EXT_ROOT}/linux
KOUT_DIR := ${CURDIR}/../kernel/linux
IMAGE_NAME := linux-vexpress-v2p-ca9.img
IMAGE_TARGET := ${IMAGE_ROOT}/${IMAGE_NAME}
KERNEL_BASE := ${KOUT_DIR}/vmlinux
KERNEL_TARGET := arch/arm/boot/zImage

$(info IMAGE_ROOT=${IMAGE_ROOT})

all: ${IMAGE_TARGET}

clean:
	@echo "CLEANING image"
	$(Q) -rm  ${IMAGE_TARGET}

${KERNEL_TARGET}: ${KERNEL_BASE}
	@echo "BUILDING $@"
	$(Q) sh ${KSRC_DIR}/scripts/gen_initramfs_list.sh -d -u squash -g squash ${CROSS_ROOT} > initramfs.data
	$(Q) ${MAKE} ${BUILD_THREADS} -C ${KSRC_DIR} O=${KOUT_DIR} ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} CONFIG_INITRAMFS_SOURCE="${CURDIR}/initramfs.data" all vexpress-v2p-ca9.dtb

${IMAGE_TARGET}: ${KERNEL_TARGET}
	@echo "INSTALLING $@"
	$(Q) cat ${KOUT_DIR}/arch/arm/boot/zImage ${KOUT_DIR}/arch/arm/boot/dts/vexpress-v2p-ca9.dtb > ${IMAGE_NAME}
	$(Q) install -m 644 -D ${IMAGE_NAME} $@

endif



