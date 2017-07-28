#
# Copyright (C) 2012 Red Rocket Computing
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
# kernel.mk
# Created on: 18/05/17
# Author: Stephen Street
#
ifeq ($(findstring ${BUILD_ROOT},${CURDIR}),)
include ${PROJECT_ROOT}/tools/makefiles/target.mk
else

include ${PROJECT_ROOT}/tools/makefiles/quiet.mk

KSRC_DIR := ${EXT_ROOT}/linux
INSTALL_MOD_PATH := ${CROSS_ROOT}
KERNEL_BASE := ${CURDIR}/vmlinux
KERNEL_VERSION := $(make -s -C ${KSRC_DIR} kernelversion)

all: ${EXT_ROOT}/linux/README ${KERNEL_BASE}

clean:
	@echo "CLEANING kernel"
	$(Q) -$(MAKE) -C ${CURDIR} O=${CURDIR} ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} clean
	$(Q) -rm -rf ${INSTALL_TARGET} ${INSTALL_MOD_PATH}/lib/modules

${EXT_ROOT}/linux/README:
	@echo "FETCHING linux"
	$(Q) git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git ${EXT_ROOT}/linux
	$(Q) git -C ${EXT_ROOT}/linux checkout v4.11

.config: ${SOURCE_DIR}/linux.config
	@echo "CONFIGURING $@"
	$(Q) install -D $< $@
	$(Q) $(MAKE) -C ${KSRC_DIR} O=${CURDIR} ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} oldconfig

${CURDIR}/vmlinux: .config
	@echo "BUILDING $@"
	$(Q) $(MAKE) ${BUILD_THREADS} -C ${CURDIR} O=${CURDIR} ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} vmlinux modules
	$(Q) $(MAKE) ${BUILD_THREADS} -C ${CURDIR} O=${CURDIR} ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} INSTALL_MOD_PATH=${CROSS_ROOT} modules_install

endif



