# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Generate a baremetal application

# Name of the program $(PROGRAM).c will be added as a source file
Directory= ./C_files
PROGRAM = $(Directory)/aes
PROGRAM_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
# Any extra source files to include in the build. Use the upper case .S
# extension for assembly files
ifeq ($(CPP), OpenSSLAES)
EXTRA_SRCS :=  $(Directory)/aes_ssl.c $(Directory)/aes_ecb_ssl.c
CPPFLAGS += -DOpenSSLAES
else ifeq ($(CPP), TinyAES)
EXTRA_SRCS := $(Directory)/aes_stm_tiny.c
CPPFLAGS += -DTinyAES
else
CPPFLAGS += -DAESIBEX
endif

include ${PROGRAM_DIR}/../common/common.mk
