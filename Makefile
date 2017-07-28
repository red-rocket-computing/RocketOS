#
# Copyright (C) 2017 Red Rocket Computing, LLC
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Makefile
#
# Created on: Mar 16, 2017
#     Author: Stephen Street (stephen@redrocketcomputing.com)
#

export PROJECT_ROOT ?= ${CURDIR}
export TOOLS_ROOT ?= ${PROJECT_ROOT}/tools
export IMAGE_ROOT ?= ${PROJECT_ROOT}/images
export BUILD_ROOT ?= ${PROJECT_ROOT}/build
export CROSS_ROOT ?= ${PROJECT_ROOT}/rootfs
export EXT_ROOT ?= ${PROJECT_ROOT}/ext

export ARCH ?= arm
export CROSS_COMPILE ?= arm-linux-gnueabi-
export BUILD_THREADS := -j $(shell cat /proc/cpuinfo | grep processor | wc -l)

include ${PROJECT_ROOT}/tools/makefiles/tree.mk

#$(info PROJECT_ROOT=${PROJECT_ROOT})
#$(info IMAGE_ROOT=${IMAGE_ROOT})

target: sys kernel apps pkg

distclean:
	@echo "DISTCLEAN ${PROJECT_ROOT}"
	$(Q)-${RM} -r ${BUILD_ROOT} ${IMAGE_ROOT} ${CROSS_ROOT}

realclean:
	@echo "REALCLEAN ${PROJECT_ROOT}"
	$(Q)-${RM} -r ${EXT_ROOT} ${BUILD_ROOT} ${IMAGE_ROOT} ${CROSS_ROOT}


