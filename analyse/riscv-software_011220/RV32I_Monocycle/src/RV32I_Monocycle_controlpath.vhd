-------------------------------------------------------------------------------
-- Title      : DLX_controlpath
-- Project    : 
-------------------------------------------------------------------------------
-- File       : DLX_controlpath.vhd
-- Author     :   <michel agoyan@ROU13572>
-- Company    : 
-- Created    : 2015-11-25
-- Last update: 2019-08-23
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: DLX control path
-------------------------------------------------------------------------------
-- Copyright (c) 2015 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2015-11-25  1.0      michel agoyan   Created
-- 2019-08-21  1.1      Olivier potin   Modified to implement RISCV Monocycle
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library rtl_core;
use rtl_core.RV32I_constants.all;

entity RV32I_Monocycle_controlpath is

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

end entity RV32I_Monocycle_controlpath;

architecture RV32I_Monocycle_controlpath_architecture of RV32I_Monocycle_controlpath is
signal ALUOp_s  : std_logic_vector(1 downto 0);
signal Branch_s : std_logic;
begin  -- architecture RV32I_Monocycle_controlpath_architecture
  -- ALU control process
  -- purpose: control ALU operation according to ALUOp from control process and funct3 bits of ISA
  -- type   : combinational
  -- inputs : ALUOp_s, Instruction_i
  -- outputs: ALUControl_o
  ALUcontrol : process(ALUOp_s, Instruction_i)
  variable func3_v : std_logic_vector(2 downto 0);
  begin
	func3_v := Instruction_i(14 downto 12);
	case ALUOp_s is
	when ALU_OP_ADD =>
		ALUControl_o <= ALU_ADD; 
	when ALU_OP_SUB => 
		ALUControl_o <= ALU_SUB;
	when ALU_OP_FUNCT => 
		case func3_v is
		when "000" =>
			if (Instruction_i(6 downto 0) = RV32I_R_INSTR) and (Instruction_i(30) = '1') then
				ALUControl_o <= ALU_SUB;
			else 
				ALUControl_o <= ALU_ADD;
			end if;
		when "001" =>
			ALUControl_o <= ALU_SLLV;
		when "010" => 
			ALUControl_o <= ALU_SLT;
		when "011" =>
			ALUControl_o <= ALU_SLTU;
		when "100" => 
			ALUControl_o <= ALU_XOR;
		when "101" =>
			if (Instruction_i(30) = '1') then
				ALUControl_o <= ALU_SRAV;
			elsif (Instruction_i(30) = '0') then
				ALUControl_o <= ALU_SRLV;
			else
				assert false report "instruction bit 30 for funct3 = 101 is not defined" severity warning;
				ALUControl_o <= ALU_X;
			end if;
		when "110" =>
			ALUControl_o <= ALU_OR;
		when "111" =>  			
			ALUControl_o <= ALU_AND;	
		when others =>
			assert false report "instruction-bit [14 - 12] are not well-defined" severity warning;
			ALUControl_o <= ALU_X;
		end case;
	when ALU_OP_COPY =>
		ALUControl_o <= ALU_COPY_RS1;
	when others => 
		--assert false report "ALU operation is not defined" severity warning;
		ALUControl_o <= ALU_X;
	end case;
  end process ALUControl;

  -- purpose: program counter selection (PC+4, branch, jump...)
  -- type   : combinational
  -- inputs : Branch_s, ALU_zero_i, ALU_lt_i, Instruction_i
  -- outputs: PC_select_o
  pc_select:process(Branch_s, ALU_zero_i, ALU_lt_i, Instruction_i, exception_i) -- for all branch and jump instructions, add signals add ALU_lt_i, Instruction_i in sensibility process
  variable select_v : std_logic;
  begin
	-- exception is treated first...
	if (exception_i = '1') then
		PC_select_o <= SEL_PC_EXCEPTION;
	else	
		select_v := '0';
		case Instruction_i(6 downto 0) is
		when RV32I_B_INSTR =>
			case Instruction_i(14 downto 12) is
			when "000" =>
				select_v := ALU_zero_i;		-- BEQ 
			when "001" =>
				select_v := not ALU_zero_i;	-- BNE
			when "100" =>
				select_v := ALU_lt_i;		-- BLT
			when "101" =>
				select_v := not ALU_lt_i;	-- BGE
			when "110" =>
				select_v := ALU_ltu_i;		-- BLTU 
			when "111" =>
				select_v := not ALU_ltu_i;	-- BGEU 
			when "010" =>
				select_v := 'U';			
			when "011" =>
				select_v := 'U';			
			when others =>
				select_v := 'U';			
			end case;
			if ((Branch_s and select_v) = '1') then 
				PC_select_o <= SEL_PC_IMM;
			else
				PC_select_o <= SEL_PC_PLUS_4;
			end if;
		when RV32I_J_INSTR =>
			PC_select_o <= SEL_PC_IMM;
		when RV32I_I_INSTR_JALR => 
			PC_select_o <= SEL_PC_JALR;
		when others =>
			PC_select_o <= SEL_PC_PLUS_4;
		end case;
	end if;
  end process pc_select;

  -- purpose: implement LUT  to generate  signals to control the datapath
  -- type   : combinational
  -- inputs : Instruction_i
  -- outputs: 
  -- ALUSrc2_o = 
  -- ALUSrc1_o = 
  -- WB_select_o = 
  -- RegWrite_o = 
  -- MemRead_o = 
  -- MemWrite_o = 
  -- Branch_s =  
  -- ALUOp_s = 
  controlpath_combinational_process : process (Instruction_i) is
  begin 
	unknown_instr_o <= '0'; 
	case Instruction_i(6 downto 0) is
	when RV32I_R_INSTR =>
		ALUSrc2_o <= SEL_OP2_RS2;
		ALUSrc1_o <= SEL_OP1_RS1;
		WB_select_o <= SEL_ALU_TO_REG;
		RegWrite_o <= WE_1;
	  	MemRead_o <= '0';
		MemWrite_o <= WE_0;
		MemSelectData_o <= RV32I_FUNCT3_LS_WORD;
		Branch_s <= '0'; 
		ALUOp_s <= ALU_OP_FUNCT;

	when RV32I_S_INSTR => 
		ALUSrc2_o <= SEL_OP2_IMM;
		ALUSrc1_o <= SEL_OP1_RS1;
		WB_select_o <= (others => 'X');
		RegWrite_o <= WE_0;
	  	MemRead_o <= '0';
		MemWrite_o <= WE_1;
		MemSelectData_o <= Instruction_i(14 downto 12);
		Branch_s <= '0'; 
		ALUOp_s <= ALU_OP_ADD;

	when RV32I_I_INSTR_LOAD => 
		ALUSrc2_o <= SEL_OP2_IMM;
		ALUSrc1_o <= SEL_OP1_RS1;
		WB_select_o <= SEL_MEM_TO_REG;
		RegWrite_o <= WE_1;
	  	MemRead_o <= '1';
		MemWrite_o <= WE_0;
		MemSelectData_o <= Instruction_i(14 downto 12);
		Branch_s <= '0'; 
		ALUOp_s <= ALU_OP_ADD;

	when RV32I_B_INSTR => 
		ALUSrc2_o <= SEL_OP2_RS2;
		ALUSrc1_o <= SEL_OP1_RS1;
		WB_select_o <= (others => 'X');
		RegWrite_o <= WE_0;
	  	MemRead_o <= '0';
		MemWrite_o <= WE_0;
		MemSelectData_o <= RV32I_FUNCT3_LS_WORD;
		Branch_s <= '1'; 
		ALUOp_s <= ALU_OP_SUB;

	when RV32I_U_INSTR_LUI => 
		ALUSrc2_o <= (others => 'X');  -- don't care about ALU op2
		ALUSrc1_o <= SEL_OP1_IMM;
		WB_select_o <= SEL_ALU_TO_REG;
		RegWrite_o <= WE_1;
	  	MemRead_o <= '0';
		MemWrite_o <= WE_0;
		MemSelectData_o <= RV32I_FUNCT3_LS_WORD;
		Branch_s <= '0'; 
		ALUOp_s <= ALU_OP_COPY;

	when RV32I_I_INSTR_OPER => 
		ALUSrc2_o <= SEL_OP2_IMM;
		ALUSrc1_o <= SEL_OP1_RS1;
		WB_select_o <= SEL_ALU_TO_REG;
		RegWrite_o <= WE_1;
	  	MemRead_o <= '0';
		MemWrite_o <= WE_0;
		MemSelectData_o <= RV32I_FUNCT3_LS_WORD;
		Branch_s <= '0'; 
		ALUOp_s <= ALU_OP_FUNCT;

	when RV32I_J_INSTR =>
	-- JAL instruction
		ALUSrc2_o <= (others => 'X');
		ALUSrc1_o <= SEL_OP1_X;
		WB_select_o <= SEL_PC_PLUS4_TO_REG;
		RegWrite_o <= WE_1;
	  	MemRead_o <= '0';
		MemWrite_o <= WE_0;
		MemSelectData_o <= RV32I_FUNCT3_LS_WORD;
		Branch_s <= '1'; 
		ALUOp_s <= (others => 'X');

	when RV32I_I_INSTR_JALR =>
		ALUSrc2_o <= SEL_OP2_IMM;
		ALUSrc1_o <= SEL_OP1_RS1;
		WB_select_o <= SEL_PC_PLUS4_TO_REG;
		RegWrite_o <= WE_1;
	  	MemRead_o <= '0';
		MemWrite_o <= WE_0;
		MemSelectData_o <= RV32I_FUNCT3_LS_WORD;
		Branch_s <= '1'; 
		ALUOp_s <= ALU_OP_ADD;

	when RV32I_U_INSTR_AUIPC => 
		ALUSrc2_o <= SEL_OP2_IMM;
		ALUSrc1_o <= SEL_OP1_PC;
		WB_select_o <= SEL_ALU_TO_REG;
		RegWrite_o <= WE_1;
	  	MemRead_o <= '0';
		MemWrite_o <= WE_0;
		MemSelectData_o <= RV32I_FUNCT3_LS_WORD;
		Branch_s <= '0'; 
		ALUOp_s <= ALU_OP_ADD;

	when RV32I_I_INSTR_FENCE => 
		assert false report "fence instructions not supported" severity warning;
	-- TODO
	-- considered as NOP
		ALUSrc2_o <= (others => 'U');
		ALUSrc1_o <= (others => 'U');
		WB_select_o <= (others => 'U');
		RegWrite_o <= '0';
	  	MemRead_o <= '0';
		MemWrite_o <= '0';
		MemSelectData_o <= (others => 'U');
		Branch_s <= '0'; 
		ALUOp_s <= (others => '0');

	when RV32I_I_INSTR_SYSTEM => 
		assert false report "env or csr instructions not supported" severity warning;
	-- TODO
	-- considered as NOP
		ALUSrc2_o <= (others => 'U');
		ALUSrc1_o <= (others => 'U');
		WB_select_o <= (others => 'U');
		RegWrite_o <= '0';
	  	MemRead_o <= '0';
		MemWrite_o <= '0';
		MemSelectData_o <= (others => 'U');
		Branch_s <= '0'; 
		ALUOp_s <= (others => '0');

	when others =>
		assert false report "unknown instruction" severity warning;
		ALUSrc2_o <= (others => 'X');
		ALUSrc1_o <= (others => 'X');
		WB_select_o <= (others => 'X');
		RegWrite_o <= 'X';
	  	MemRead_o <= 'X';
		MemWrite_o <= 'X';
		MemSelectData_o <= (others => 'X');
		Branch_s <= 'X'; 
		ALUOp_s <= (others => 'X');
		unknown_instr_o <= '1';
	end case;
  end process controlpath_combinational_process;
end architecture RV32I_Monocycle_controlpath_architecture;

