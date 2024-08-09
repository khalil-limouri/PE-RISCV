-------------------------------------------------------------------------------
-- Title      : RV32I components
-- Project    : 
-------------------------------------------------------------------------------
-- File       : RV32I_comps.vhd
-- Author     :   <michel agoyan@ROU13572>
-- Company    : 
-- Created    : 2015-11-25
-- Last update: 2015-12-04
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: VHDL package containing RV32I components
-------------------------------------------------------------------------------
-- Copyright (c) 2015 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2015-11-25  1.0      michel agoyan   Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library std;
use std.textio.all;

library rtl_core;
use rtl_core.RV32I_constants.all;


package RV32I_components is

  component RV32I_Monocycle_top is
  generic (
    rom_init_filename: string:="rom.hex";
    ram_init_filename: string:="";
    TLEN : POSITIVE);

  port (
    clk_i        : in std_logic;
    resetn_i     : in std_logic;
    enable_tracer_i : in std_logic;
    trace_o		 : out std_logic_vector((TLEN*8)-1 downto 0);
    trace_length_o : out NATURAL range 0 to (TLEN-1);
    trace_emitted_o : out std_logic;
    PeriphAddr_o : out std_logic_vector(31 downto 0); -- Periph address
    PeriphData_o : out std_logic_vector(31 downto 0); -- Periph word
    PeriphWe_o   : out std_logic); -- set when Periph word is valid

  end component RV32I_Monocycle_top;

  component RV32I_Monocycle_datapath is
  generic (
    rom_init_filename: string:="rom.hex";
    ram_init_filename: string:="");

  port (
	clk_i		: in  std_logic;
	resetn_i	: in  std_logic;
	Instruction_o	: out std_logic_vector(31 downto 0);
	IAddress_o	: out std_logic_vector(31 downto 0);
	ALU_zero_o	: out std_logic;			-- ALU "zero" signal flag (ALU result operation = 0x0)
	ALU_lt_o	: out std_logic;			-- ALU "less than" signal flag
	ALU_ltu_o	: out std_logic;			-- ALU "less than" signal flag in case of unsigned comparison
	PC_select_i	: in std_logic_vector(1 downto 0);	-- select next PC
	ALUSrc1_i	: in std_logic_vector(1 downto 0);	-- select ALU operand 1
	ALUSrc2_i	: in std_logic_vector(0 downto 0);	-- select ALU operand 2
	ALUControl_i	: in std_logic_vector(3 downto 0);	-- select ALU operation
	MemWrite_i	: in std_logic;				-- RAM write enable
	MemRead_i	: in std_logic;				-- RAM read enable
	MemSelectData_i	: in std_logic_vector(2 downto 0);	-- RAM data granularity selection (byte, half word or word)
	WB_select_i	: in std_logic_vector(1 downto 0);	-- select data to write back to register
	RegWrite_i	: in std_logic;				-- Register write enable
	unknown_instr_i : in std_logic;	-- exception from the control path for unknown instruction decode
	exception_o : out std_logic;
	tval_o : out std_logic_vector(IADDRESS_WIDTH_P-1 downto 0);
	mcause_o : out std_logic_vector(MCAUSE_WIDTH_P-1 downto 0);
	PeriphAddr_o	: out std_logic_vector(31 downto 0);	-- Periph address
	PeriphData_o	: out std_logic_vector(31 downto 0);	-- Periph word
	PeriphWe_o	: out std_logic);			-- set when Periph word is valid
  end component RV32I_Monocycle_datapath;

  component RV32I_Monocycle_controlpath is
  port (
	Instruction_i	: in std_logic_vector(31 downto 0);
	ALU_zero_i	: in std_logic;				-- ALU "zero" signal flag (ALU result operation = 0x0)
	ALU_lt_i	: in std_logic;				-- ALU "less than" signal flag
	ALU_ltu_i	: in std_logic;				-- ALU "less than" signal flag in case of unsigned comparison
	exception_i : in std_logic;			-- exception is detected...
	unknown_instr_o : out std_logic;	-- exception from the control path for unknown instruction decode
	PC_select_o	: out std_logic_vector(1 downto 0);	-- select next PC
	ALUSrc1_o	: out std_logic_vector(1 downto 0);	-- select ALU operand 1
	ALUSrc2_o	: out std_logic_vector(0 downto 0);	-- select ALU operand 2
	ALUControl_o	: out std_logic_vector(3 downto 0);	-- select ALU operation
	MemWrite_o	: out std_logic;			-- RAM write enable
	MemRead_o	: out std_logic;			-- RAM read enable
	MemSelectData_o	: out std_logic_vector(2 downto 0);	-- select data from memory according to load instruction (byte, half word or word)
	WB_select_o	: out std_logic_vector(1 downto 0);	-- select data to write back to register
	RegWrite_o	: out std_logic);			-- Register write enable
  end component RV32I_Monocycle_controlpath;
  
  component RV32I_Exception is
    port (
        resetb_i : in std_logic;
        clock_i : in std_logic;
        iaddress_i : in std_logic_vector(31 downto 0);
        unknown_instr_i : in std_logic;
        exception_cause_o : out std_logic_vector(MCAUSE_WIDTH_P-1 downto 0);    -- also known as mcause register
        exception_address_o : out std_logic_vector(IADDRESS_WIDTH_P-1 downto 0);    -- also known as mtval register
        exception_o : out std_logic);
end component RV32I_Exception;

component sync_mem is
  generic (
    data_size		: positive := 8;             	-- data size which set the data width of the sync_mem data bus as data_size * data_granularity (ex: 32 bit wide = 8 bits * 4 byte)
    data_granularity	: positive := 4;		-- memory granularity 
    n			: positive := 12;		-- sync_mem size
    filename 		: string := "ram.hex");         -- memory content is set by reading file
  port(
    clk_i    : in std_logic;
    resetn_i : in std_logic;
    we_i     : in  std_logic_vector(data_granularity-1 downto 0);		-- one we for each data field 
    re_i     : in  std_logic;							-- read all width bits
    d_i      : in  std_logic_vector((data_size*data_granularity)-1 downto 0);
    add_i    : in  std_logic_vector(n-1 downto 0);
    d_o      : out std_logic_vector((data_size*data_granularity)-1 downto 0));
  end component sync_mem;


  component alu is
    generic (
      width : positive);
    port (
      func_i : in  std_logic_vector(3 downto 0);
      op1_i  : in  std_logic_vector(width -1 downto 0);
      op2_i  : in  std_logic_vector(width -1 downto 0);
      d_o    : out std_logic_vector(width -1 downto 0);
      zero_o : out std_logic;
      lt_o   : out std_logic;
      ltu_o  : out std_logic);
  end component alu;

  component register_file is
    generic (
      width : positive;
      n     : positive);
    port (
      clk_i      : in  std_logic;
      resetn_i   : in  std_logic;
      rs1_add_i  : in  std_logic_vector(n-1 downto 0);
      rs2_add_i  : in  std_logic_vector(n-1 downto 0);
      rd_add_i   : in  std_logic_vector(n-1 downto 0);
      rd_data_i  : in  std_logic_vector(width-1 downto 0);
      we_i       : in  std_logic;
      rs1_data_o : out std_logic_vector(width-1 downto 0);
      rs2_data_o : out std_logic_vector(width-1 downto 0));
  end component register_file;


  component mux_comp is
    generic (
      width : positive;
      n     : positive);
    port (
      data_i : in  std_logic_vector(width*(2**n)-1 downto 0);
      sel_i  : in  std_logic_vector(n-1 downto 0);
      data_o : out std_logic_vector(width-1 downto 0));
  end component mux_comp;

  component demux_comp is
    generic (
      width : positive;
      n     : positive);
    port (
      data_i : in  std_logic_vector(width-1 downto 0);
      sel_i  : in  std_logic_vector(n-1 downto 0);
      data_o : out std_logic_vector(width*(2**n)-1 downto 0));
  end component demux_comp;

end package RV32I_components;
