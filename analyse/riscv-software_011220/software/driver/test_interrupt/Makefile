# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Generate a baremetal application

# Name of the program $(PROGRAM).c will be added as a source file
Directory= .
PROGRAM = $(Directory)/interrupt
PROGRAM_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
# Any extra source files to include in the build. Use the upper case .S
# extension for assembly files
CPPFLAGS = -I$(CURDIR)/include
CPPFLAGS = -I$(CURDIR)/bench
#EXTRA_SRCS :=  $(Directory)/../../../pulpissimo_v130121/pulp-runtime/include/pulp.h
include ${PROGRAM_DIR}/../common/common.mk

