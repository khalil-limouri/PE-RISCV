
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
PRGM := te_encoder

# sources list
SRC := $(shell find $(SRCDIR) -type f -name *.cpp)
OBJ := $(patsubst $(SRCDIR)/%,$(OBJDIR)/%,$(SRC:.cpp=.o))
# add riscv software utilities
OBJ += $(OBJDIR)/encoder-algorithm-public.o $(OBJDIR)/riscv-disas.o $(OBJDIR)/te-codec-utilities.o

# Folder Lists
# Note: Intentionally excludes the root of the include folder so the lists are clean
INCDIRS := $(shell find include/* -name '*.h' -exec dirname {} \; | sort | uniq)
INCLIST := $(patsubst include/%,-I include/%,$(INCDIRS))
BUILDLIST := $(patsubst include/%,$(BUILDDIR)/%,$(INCDIRS))

# Shared Compiler Flags
CFLAGS := -g -O0 -Wall
INC := -I $(INCLIST) -I /usr/local/include
LIB := -L /usr/local/lib

all:$(TARGETDIR)/$(PRGM)

$(TARGETDIR)/$(PRGM): $(OBJ) 
	@mkdir -p $(TARGETDIR)
	$(GCC) $(OBJ) -o $@ $(LIB)

$(OBJDIR)/encoder-algorithm-public.o: $(SRCDIR)/encoder-algorithm-public.c 
	@mkdir -p $(OBJDIR)
	$(GCC) $(CFLAGS) $(INC) -c $< -o $@

 $(OBJDIR)/riscv-disas.o: $(SRCDIR)/riscv-disas.c 
	@mkdir -p ../common/build
	$(GCC) $(CFLAGS) $(INC) -c $< -o $@

$(OBJDIR)/te-codec-utilities.o : $(SRCDIR)/te-codec-utilities.c
	@mkdir -p ../common/build
	$(GCC) $(CFLAGS) $(INC) -c $< -o $@

$(OBJDIR)/%.o: $(SRCDIR)/%.cpp
	@mkdir -p $(OBJDIR)
	$(GCC) $(CFLAGS) $(INC) -c $< -o $@

.PHONY: clean

clean:
	rm -f $(OBJDIR)/*.o $(TARGETDIR)/$(PRGM)
