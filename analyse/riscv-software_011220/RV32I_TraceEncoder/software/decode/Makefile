
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
PRGM := te_decoder

# sources list
SRC := $(shell find $(SRCDIR) -type f -name *.cpp)
OBJ := $(patsubst $(SRCDIR)/%,$(OBJDIR)/%,$(SRC:.cpp=.o))
# add riscv software utilities
OBJ += $(OBJDIR)/decoder-algorithm-public.o ../common/build/riscv-disas.o ../common/build/te-codec-utilities.o

# Folder Lists
# Note: Intentionally excludes the root of the include folder so the lists are clean
INCDIRS := $(shell find include/* -name '*.h' -exec dirname {} \; | sort | uniq)
INCLIST := $(patsubst include/%,-I include/%,$(INCDIRS))
BUILDLIST := $(patsubst include/%,$(BUILDDIR)/%,$(INCDIRS))

# Shared Compiler Flags
CFLAGS := -g -O0 -Wall -std=c++11
INC := -I $(INCLIST) -I /usr/local/include -I ../common/include
LIB := -L /usr/local/lib

all:$(TARGETDIR)/$(PRGM)

$(TARGETDIR)/$(PRGM): $(OBJ) 
	@mkdir -p $(TARGETDIR)
	$(GCC) $(OBJ) -o $@ $(LIB)

$(OBJDIR)/decoder-algorithm-public.o: $(SRCDIR)/decoder-algorithm-public.c 
	@mkdir -p $(OBJDIR)
	$(GCC) $(CFLAG) $(INC) -c $< -o $@

../common/build/riscv-disas.o: ../common/src/riscv-disas.c 
	@mkdir -p ../common/build
	$(GCC) $(CFLAG) $(INC) -c $< -o $@

../common/build/te-codec-utilities.o : ../common/src/te-codec-utilities.c
	@mkdir -p ../common/build
	$(GCC) $(CFLAG) $(INC) -c $< -o $@

$(OBJDIR)/%.o: $(SRCDIR)/%.cpp
	@mkdir -p $(OBJDIR)
	$(GCC) $(CFLAG) $(INC) -c $< -o $@

.PHONY: clean

clean:
	rm -f $(OBJDIR)/*.o $(TARGETDIR)/$(PRGM)
