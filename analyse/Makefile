# RISCV PATH (TODO get riscv path from env)
RISCV_PATH = riscv-software_011220

# CC
PREFIX?=
GCC := $(PREFIX)g++
AS := $(PREFIX)as
LD := $(PREFIX)ld
OBJCOPY := $(PREFIX)objcopy
OBJDUMP := $(PREFIX)objdump

# folders
SRCDIR := src
OBJDIR := build
TARGETDIR := bin

# target
PRGM := flow_analysis

# sources list
SRC := $(shell find $(SRCDIR) -type f -name *.cpp)
OBJ := $(patsubst $(SRCDIR)/%,$(OBJDIR)/%,$(SRC:.cpp=.o))
# add riscv software utilities
OBJ += $(RISCV_PATH)/RV32I_TraceEncoder/software/common/build/riscv-disas.o 

# Folder Lists
# Note: Intentionally excludes the root of the include folder so the lists are clean
INCDIRS := $(shell find include/* -name '*.h' -exec dirname {} \; | sort | uniq)
INCLIST := $(patsubst include/%,-I include/%,$(INCDIRS))
BUILDLIST := $(patsubst include/%,$(BUILDDIR)/%,$(INCDIRS))

# Shared Compiler Flags
CFLAGS := -g -O0 -Wall
INC := -I $(INCLIST) -I /usr/local/include -I $(RISCV_PATH)/RV32I_TraceEncoder/software/encode/include
LIB := -L /usr/local/lib


#$(info OBJ = $(OBJ))


all:$(TARGETDIR)/$(PRGM)

$(TARGETDIR)/$(PRGM): $(OBJ) 
	@mkdir -p $(TARGETDIR)
	$(GCC) $(OBJ) -o $@ $(LIB)

$(RISCV_PATH)/RV32I_TraceEncoder/software/common/build/riscv-disas.o: $(RISCV_PATH)/RV32I_TraceEncoder/software/encode/src/riscv-disas.c 
	@mkdir -p ../common/build
	$(GCC) $(CFLAGS) $(INC) -c $< -o $@

$(OBJDIR)/%.o: $(SRCDIR)/%.cpp
	@mkdir -p $(OBJDIR)
	$(GCC) $(CFLAGS) $(INC) -c $< -o $@


.PHONY: clean

clean:
	rm -f $(OBJDIR)/*.o $(TARGETDIR)/$(PRGM)

