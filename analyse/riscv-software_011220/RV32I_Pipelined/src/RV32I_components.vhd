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

package RV32I_components is

  component RV32I_Pipelined_top is
    port (
      clk_i    : in std_logic;
      resetn_i : in std_logic);
  end component RV32I_Pipelined_top;

  component RV32I_Pipelined_datapath is
  port (
	clk_i		: in  std_logic;
	resetn_i	: in  std_logic;
	Instruction_IFID_o	: out std_logic_vector(31 downto 0);
	Instruction_IDEX_o	: out std_logic_vector(25 downto 0);
	Instruction_EXMEM_o	: out std_logic_vector(14 downto 0);
	Instruction_MEMWB_o	: out std_logic_vector(4 downto 0);
	ALU_zero_o	: out std_logic;			-- ALU "zero" signal flag (ALU result operation = 0x0)
	ALU_lt_o	: out std_logic;			-- ALU "less than" signal flag
	PC_select_i	: in std_logic_vector(1 downto 0);	-- select next PC
	ALUSrc1_i	: in std_logic_vector(1 downto 0);	-- select ALU operand 1
	ALUSrc2_i	: in std_logic_vector(0 downto 0);	-- select ALU operand 2
	ALUControl_i	: in std_logic_vector(3 downto 0);	-- select ALU operation
	ForwardA_i	: in std_logic_vector(1 downto 0);
	ForwardB_i	: in std_logic_vector(1 downto 0);
	MemWrite_i	: in std_logic;				-- RAM write enable
	MemRead_i	: in std_logic;				-- RAM read enable
	WB_select_i	: in std_logic_vector(1 downto 0);	-- select data to write back to register
	RegWrite_i	: in std_logic;				-- Register write enable
	PCWrite_i	: in std_logic;				-- enable PC update
	IFIDWrite_i	: in std_logic);			-- enable IFID pipeline register
  end component RV32I_Pipelined_datapath;

  component RV32I_Pipelined_controlpath is
  port (
	clk_i			: in std_logic;
	resetn_i		: in std_logic;
	Instruction_IFID_i	: in std_logic_vector(31 downto 0);
	Instruction_IDEX_i	: in std_logic_vector(25 downto 0);
	Instruction_EXMEM_i	: in std_logic_vector(14 downto 0);
	Instruction_MEMWB_i	: in std_logic_vector(4 downto 0);
	ALU_zero_i		: in std_logic;				-- ALU "zero" signal flag (ALU result operation = 0x0) used during EXE/MEM stage
	ALU_lt_i		: in std_logic;				-- ALU "less than" signal flag used during EXE/MEM stage
	PC_select_o		: out std_logic_vector(1 downto 0);	-- select next PC
	ALUSrc1_o		: out std_logic_vector(1 downto 0);	-- select ALU operand 1
	ALUSrc2_o		: out std_logic_vector(0 downto 0);	-- select ALU operand 2
	ALUControl_o		: out std_logic_vector(3 downto 0);	-- select ALU operation
	ForwardA_o		: out std_logic_vector(1 downto 0);
	ForwardB_o		: out std_logic_vector(1 downto 0);
	MemWrite_o		: out std_logic;			-- RAM write enable
	MemRead_o		: out std_logic;			-- RAM read enable
	WB_select_o		: out std_logic_vector(1 downto 0);	-- select data to write back to register
	RegWrite_o		: out std_logic;			-- Register write enable
	PCWrite_o		: out std_logic;			-- enable PC update
	IFIDWrite_o		: out std_logic);			-- enable IFID pipeline register
  end component RV32I_Pipelined_controlpath;
  
  component sync_mem is
    generic (
      width    : positive;
      n        : positive;
      filename : string);
    port (
      clk_i    : in  std_logic;
      resetn_i : in  std_logic;
      we_i     : in  std_logic;
      re_i     : in  std_logic;
      d_i      : in  std_logic_vector(width-1 downto 0);
      add_i    : in  std_logic_vector(n-1 downto 0);
      d_o      : out std_logic_vector(width-1 downto 0));
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
      lt_o   : out std_logic);
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
