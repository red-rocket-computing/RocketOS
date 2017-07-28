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
# dummy.mk
# Created on: 18/05/17
# Author: Stephen Street
#
ifeq ($(findstring ${BUILD_ROOT},${CURDIR}),)
include ${PROJECT_ROOT}/tools/makefiles/target.mk
else

include ${PROJECT_ROOT}/tools/makefiles/quiet.mk

KDIR ?= ${CURDIR}/../../linux

all:
	@echo "BUILDING dummy"
	$(Q) install -C -m 644 ${SOURCE_DIR}/Kbuild ${CURDIR}/Kbuild
	$(Q) $(MAKE) -C ${KDIR} src=${SOURCE_DIR} M=${CURDIR} ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}
	$(Q) $(MAKE) -C ${KDIR} src=${SOURCE_DIR} M=${CURDIR} ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} INSTALL_MOD_PATH=${CROSS_ROOT} modules_install
	$(Q) install -C -D -m 644 ${SOURCE_DIR}/dummy.h ${CROSS_ROOT}/usr/include/linux/dummy.h
	
clean:
	@echo "CLEANING dummy"
	$(Q) $(MAKE) -C ${KDIR} src=${SOURCE_DIR} M=${CURDIR} ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} INSTALL_MOD_PATH=${CROSS_ROOT} clean
	$(Q) $(RM) ${CROSS_ROOT}/usr/include/linux/dummy.h
	$(Q) -rmdir -p --ignore-fail-on-non-empty ${CROSS_ROOT}/usr/include/linux

endif



