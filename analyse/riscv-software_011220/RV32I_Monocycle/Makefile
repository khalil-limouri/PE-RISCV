#The root path of the RV32I  project
ifndef RV32I
RV32I = .
endif

#PATH to the VHDL compiler and options used
VCOM=vcom
VLIB=vlib
VDEL=vdel
VMAP=vmap
VFLAGS=-93
VLFLAGS=+acc=rnbptscmgla
VSIM=vsim
VLOG=vlog


ifeq ($(COVER),yes)
VFLAGS:=$(VFLAGS) -cover bcsxf
VSIM_FLAGS:=$(VSIM_FLAGS) -coverage -coverExcludeDefault
endif

###########################################################################
# user defined function to retrieve the source files list 
# SRC_FILES_LIST=$(call src_list,$(SRC_PATH))
define src_list
 $(wildcard $1/*.vhd)
endef

# user defined function to build a tag list from a source list
# TAG_LIST=$(call src_list,$(SRC_FILES_LIST))
define tag_list
 $(patsubst %.vhd,%.tag,$1)
endef
############################################################################

############################################################################
# Source vhdl path
# Use the user defined fct scr_list to parse a directory
# manage the file list order using alphabetic order
# you can prefix the file names with number
# or give an explicit list of files
############################################################################
#RV32I_SRC = $(call src_list,$(RV32I)/src)

RV32I_CONST_SRC=$(RV32I)/src/RV32I_constants.vhd
RV32I_COMPS_SRC=$(RV32I)/src/RV32I_components.vhd
RV32I_SRC=$(RV32I)/src/mux_comp.vhd \
	$(RV32I)/src/demux_comp.vhd \
	$(RV32I)/src/sync_mem.vhd \
	$(RV32I)/src/alu.vhd \
	$(RV32I)/src/register_file.vhd \
	$(RV32I)/src/RV32I_Monocycle_datapath.vhd \
	$(RV32I)/src/RV32I_Monocycle_controlpath.vhd \
	$(RV32I)/src/RV32I_Exception.vhd \
	$(RV32I)/src/RV32I_Monocycle_top.vhd

RV32I_TB_SRC=$(RV32I)/test/RV32I_tb.vhd

###########################################################################

###########################################################################
# The correspoding tag files
# We use tag files
###########################################################################
RV32I_CONST_TAG=$(call tag_list,$(RV32I_CONST_SRC))
RV32I_COMPS_TAG=$(call tag_list,$(RV32I_COMPS_SRC))
RV32I_TAG = $(call tag_list,$(RV32I_SRC))
RV32I_TB_TAG=$(call tag_list,$(RV32I_TB_SRC))

###########################################################################
#LIBS_DIR =$(RV32I)/libs/work
###########################################################################
# target specific variables for VFLAGS and LIBS

src/sync_mem.tag:VFLAGS=-2008
src/alu.tag:VFLAGS=-2008
src/RV32I_Monocycle_datapath.tag:VFLAGS=-2008
test/RV32I_tb.tag:VFLAGS=-2008

# everything in one lib
LIB_NAME = rtl_core
LIB_PATH = rtl

###########################################################################

###########################################################################
# rules
###########################################################################

all : $(RV32I_TB_TAG)

$(LIB_NAME).tag:
	test ! -d $(LIB_PATH) || $(VDEL) -lib $(LIB_PATH) -all
	$(VLIB) $(LIB_PATH) && $(VMAP) $(LIB_NAME) $(LIB_PATH) && touch $@
	$(VMAP) rtl_tracer ../RV32I_TraceEncoder/rtl

%tag : %vhd $(LIB_NAME).tag
	$(VCOM)  -work $(LIB_NAME) $(VFLAGS)  $<  && touch $@


###########################################################################
# Targets and dependencies
###########################################################################


$(RV32I_TAG) : $(RV32I_CONST_TAG) $(RV32I_COMPS_TAG)
$(RV32I_TB_TAG) : $(RV32I_TAG)


clean :
	find . -name *.tag -exec rm {} \;
	test ! -d $(LIB_PATH) || $(VDEL) -lib $(LIB_PATH) -all

run : $(RV32I_TB_TAG)
	$(VSIM) -novopt -msgmode both -gui RV32I_tb
	
#	$(VSIM) -novopt -msgmode both -gui RV32I_tb -do wave.do

test:
	@echo $(RV32I_COMPS_TAG)
