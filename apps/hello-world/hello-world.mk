#
# Copyright (C) 2017 Red Rocket Computing, LLC
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# hello-world.mk
#
# Created on: May 21, 2017
#     Author: Stephen Street (stephen@redrocketcomputing.com)
#

ifeq ($(findstring ${BUILD_ROOT},${CURDIR}),)
include ${PROJECT_ROOT}/tools/makefiles/target.mk
else

include ${PROJECT_ROOT}/tools/makefiles/project.mk

LDFLAGS += --static

all: ${CROSS_ROOT}/root/hello-world

clean:
	@echo "CLEANING ${CURDIR}"
	$(Q) $(RM) *.img *.elf *.map *.smap *.dis *.lst *.o

${CROSS_ROOT}/root/hello-world: ${CURDIR}/hello-world.elf
	@echo "INSTALLING $@"
	$(Q) install -m 755 -D $< $@
endif