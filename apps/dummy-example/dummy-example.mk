#
# Copyright (C) 2017 Red Rocket Computing, LLC
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# dummy-example.mk
#
# Created on: May 21, 2017
#     Author: Stephen Street (stephen@redrocketcomputing.com)
#

ifeq ($(findstring ${BUILD_ROOT},${CURDIR}),)
include ${PROJECT_ROOT}/tools/makefiles/target.mk
else

include ${PROJECT_ROOT}/tools/makefiles/project.mk

CPPFLAGS += -I${CROSS_ROOT}/usr/include
LDFLAGS += --static

all: ${CROSS_ROOT}/root/dummy-example

clean:
	@echo "CLEANING ${CURDIR}"
	$(Q) $(RM) *.img *.elf *.map *.smap *.dis *.lst *.o

${CROSS_ROOT}/root/dummy-example: ${CURDIR}/dummy-example.elf
	@echo "INSTALLING $@"
	$(Q) install -m 755 -D $< $@

endif