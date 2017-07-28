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
# filesystem.mk
# Created on: 18/05/17
# Author: Stephen Street (stephen@redrocketcomputing.com)
#

include ${PROJECT_ROOT}/tools/makefiles/quiet.mk

override MAKEFLAGS=L

SOURCE_PATH := ${CURDIR}/userspace
INSTALL_DIRS := $(subst ${SOURCE_PATH},${CROSS_ROOT},$(shell find ${SOURCE_PATH} -depth -mindepth 1 -type d -printf "%p "))
INSTALL_FILES := $(subst ${SOURCE_PATH},${CROSS_ROOT},$(shell find ${SOURCE_PATH} -mindepth 1 -type f -not -name ".gitignore" -printf "%p "))
INSTALL_LINKS := $(subst ${SOURCE_PATH},${CROSS_ROOT},$(shell find ${SOURCE_PATH} -mindepth 1 -type l -printf "%p "))

all: ${INSTALL_FILES} ${INSTALL_DIRS} ${INSTALL_LINKS}

clean:
	@echo "CLEANING filesystem"
	$(Q) -rm -f ${INSTALL_FILES}
	$(Q) -rm -f ${INSTALL_LINKS}
	$(Q) -rmdir --ignore-fail-on-non-empty ${INSTALL_DIRS} 2> /dev/null

${INSTALL_FILES}: ${CROSS_ROOT}/%: ${SOURCE_PATH}/%
	@echo "INSTALLING FILE $<"
	$(Q) install -D -m $$(stat --printf="%a" $<) $< $@

${INSTALL_DIRS}: ${CROSS_ROOT}/%: ${SOURCE_PATH}/%
	@echo "INSTALLING DIR $<"
	$(Q) install -d -m $$(stat --printf="%a" $<) $@
	$(Q) @touch $@

${INSTALL_LINKS}: ${CROSS_ROOT}/%: ${SOURCE_PATH}/%
	@echo "INSTALLING LINK $<"
	$(Q) ln -sf $$(readlink -n $<) $@


