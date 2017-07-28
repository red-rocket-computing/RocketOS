#
# Copyright (C) 2017 Red Rocket Computing, LLC
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# commom.mk
#
# Created on: Mar 16, 2017
#     Author: Stephen Street (stephen@redrocketcomputing.com)
#

CC := ${CROSS_COMPILE}gcc
CXX := ${CROSS_COMPILE}g++
LD := ${CROSS_COMPILE}gcc
AR := ${CROSS_COMPILE}ar
AS := ${CROSS_COMPILE}as
OBJCOPY := ${CROSS_COMPILE}objcopy
OBJDUMP := ${CROSS_COMPILE}objdump
SIZE := ${CROSS_COMPILE}size
NM := ${CROSS_COMPILE}nm

CROSS_FLAGS := -mthumb
CPPFLAGS :=
ARFLAGS := cr
ASFLAGS := ${CROSS_FLAGS} 
CFLAGS := ${CROSS_FLAGS} -fno-omit-frame-pointer -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections -Wall -Winline -Wunused -Wuninitialized -Wmissing-declarations -std=gnu11
CXXFLAGS := ${CROSS_FLAGS} -fno-omit-frame-pointer -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections -Wall -Wunused -Wuninitializedl -Wmissing-declarations -std=gnu++11 -mpoke-function-name -funwind-tables
LDFLAGS := ${CROSS_FLAGS} -Xlinker --gc-sections -Wl,--cref -Wl,-Map,"$(basename ${TARGET}).map" 
LDLIBS :=
LOADLIBES := 

