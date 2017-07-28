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
# busybox.mk
# Created on: 18/05/17
# Author: Stephen Street
#

ifeq ($(findstring ${BUILD_ROOT},${CURDIR}),)
include ${PROJECT_ROOT}/tools/makefiles/target.mk
else

include ${PROJECT_ROOT}/tools/makefiles/quiet.mk

BUILD_PATH = ${CURDIR}
INSTALL_PATH = ${CROSS_ROOT}/bin

all: ${EXT_ROOT}/busybox/README ${INSTALL_PATH}/busybox

clean:
	@echo "CLEANING busybox"
	$(Q) -${MAKE} ${BUILD_THREADS} -C ${EXT_ROOT}/busybox O=${CURDIR} ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} clean
	$(Q) -rm ${INSTALL_PATH}/busybox
	$(Q) -rmdir --ignore-fail-on-non-empty ${INSTALL_PATH}

${EXT_ROOT}/busybox/README:
	@echo "FETCHING $<"
	$(Q) git clone git://git.busybox.net/busybox ${EXT_ROOT}/busybox
	$(Q) git -C ${EXT_ROOT}/busybox checkout 1_26_2

.config: ${SOURCE_DIR}/busybox.config 
	@echo "CONFIGURING $<"
	$(Q) install -D $< $@

busybox: .config 
	@echo "BUILDING $<"
	$(Q) ${MAKE} ${BUILD_THREADS} -C ${EXT_ROOT}/busybox O=${CURDIR} ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} all

${INSTALL_PATH}/busybox: busybox
	@echo "INSTALLING $<"
	$(Q) install -C -D busybox $@

endif

