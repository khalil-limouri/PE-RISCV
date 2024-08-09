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
-- 2019-08-21  1.1      Olivier potin   Modified to implement RISCV Pipelined
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.RV32I_constants.all;

entity RV32I_Pipelined_controlpath is

  port (
	clk_i			: in std_logic;
	resetn_i		: in std_logic;
	Instruction_IFID_i	: in std_logic_vector(31 downto 0);	-- all instruction bits in ID stage
	Instruction_IDEX_i	: in std_logic_vector(25 downto 0);	-- bit30 & Rs2 & Rs1 & Func3 & Rd & Opcode concatenation in EXE stage
	Instruction_EXMEM_i	: in std_logic_vector(14 downto 0);	-- Func3 & Rd & Opcode concatenation in MEM stage
	Instruction_MEMWB_i	: in std_logic_vector(4 downto 0);	-- Rd in WB stage
	ALU_zero_i		: in std_logic;				-- ALU "zero" signal flag (ALU result operation = 0x0) used during EXE/MEM stage
	ALU_lt_i		: in std_logic;				-- ALU "less than" signal flag used during EXE/MEM stage
	PC_select_o		: out std_logic_vector(1 downto 0);	-- select next PC
	ALUSrc1_o		: out std_logic_vector(1 downto 0);	-- select ALU operand 1
	ALUSrc2_o		: out std_logic_vector(0 downto 0);	-- select ALU operand 2
	ALUControl_o		: out std_logic_vector(3 downto 0);	-- select ALU operation
	ForwardA_o		: out std_logic_vector(1 downto 0);	-- forward previous results to ALU op1
	ForwardB_o		: out std_logic_vector(1 downto 0);	-- forward previous results to ALU op2
	MemWrite_o		: out std_logic;			-- RAM write enable
	MemRead_o		: out std_logic;			-- RAM read enable
	WB_select_o		: out std_logic_vector(1 downto 0);	-- select data to write back to register
	RegWrite_o		: out std_logic;			-- Register write enable
	PCWrite_o		: out std_logic;			-- enable PC update
	IFIDWrite_o		: out std_logic);			-- enable IFID pipeline register


end entity RV32I_Pipelined_controlpath;

architecture RV32I_Pipelined_controlpath_architecture of RV32I_Pipelined_controlpath is
-- constants declaration
constant X0 : std_logic_vector(4 downto 0) := "00000";		-- X0 register hardwired to 0
constant NOP: std_logic_vector(10 downto 0) := "00000000000";	-- No operation on controlpath due to insertion of stall
-- signals declaration
signal PipelinedControl_s: std_logic_vector(10 downto 0);
signal IDEXE_ControlEXE_s : std_logic_vector(4 downto 0);	-- ALUOp_s(1 downto 0) & ALUSrc1_s(1 downto 0) & ALUSrc2_s(0 downto 0)
signal IDEXE_ControlMEM_s : std_logic_vector(2 downto 0); 	-- Branch_s & MemRead_s & MemWrite_s
signal IDEXE_ControlWB_s : std_logic_vector(2 downto 0);  	-- RegWrite_s & WB_select_s(1 downto 0)
signal EXMEM_ControlMEM_s : std_logic_vector(2 downto 0);
signal EXMEM_ControlWB_s : std_logic_vector(2 downto 0);
signal MEMWB_ControlWB_s : std_logic_vector(2 downto 0);

-- signals used during ID/EXE stage
signal ALUSrc1_s : std_logic_vector(1 downto 0);
signal ALUSrc2_s : std_logic_vector(0 downto 0);
signal ALUOp_s  : std_logic_vector(1 downto 0);

-- signals used during EXE/MEM stage
signal Branch_s : std_logic;
signal MemRead_s : std_logic;
signal MemWrite_s : std_logic;

-- signals used during MEM/WB stage
signal WB_select_s : std_logic_vector(1 downto 0);
signal RegWrite_s : std_logic;

-- signal used in forwarding process
signal EXMEM_RegWrite_s : std_logic;
signal EXMEM_Rd_s  : std_logic_vector(4 downto 0); 
signal MEMWB_RegWrite_s : std_logic;
signal MEMWB_Rd_s  : std_logic_vector(4 downto 0); 
signal IDEXE_Rs1_s : std_logic_vector(4 downto 0); 
signal IDEXE_Rs2_s : std_logic_vector(4 downto 0); 

-- signal used in stall process
signal IDEXE_MemRead_s	: std_logic;
signal IDEXE_Rd_s	: std_logic_vector(4 downto 0); 
signal IFID_Rs1_s 	: std_logic_vector(4 downto 0); 
signal IFID_Rs2_s	: std_logic_vector(4 downto 0); 
signal Stall_select_s	: std_logic;

begin  -- architecture RV32I_Pipelined_controlpath_architecture
	-- TODO : verify signals definition
	-- assert(IDEXE_ControlEXE_s'LENGTH \= (ALUOp_s'LENGTH + ALUSrc1_s'LENGTH + ALUSrc2_s'LENGTH)) 
	--	report "Error in the definition of signal'size of signals ALUOp, ALUSrc1 and ALUSrc2 with IDEXE_ControlEXE_s" severity error;

  --_____________________________________________________________________________________________________
  -- ID processes

  -- purpose: implement LUT  to generate  signals to control the datapath
  -- type   : combinational
  -- inputs : Instruction_IFID_i
  -- outputs: Control signals stored in ID/EXE stage
  InstructionDecode_process : process (Instruction_IFID_i) is
  begin  
    case Instruction_IFID_i(6 downto 0) is
	when RV32I_R_INSTR =>
		ALUSrc2_s <= SEL_OP2_RS2;
		ALUSrc1_s <= SEL_OP1_RS1;
		WB_select_s <= SEL_ALU_TO_REG;
		RegWrite_s <= WE_1;
	  	MemRead_s <= '0';
		MemWrite_s <= WE_0;
		Branch_s <= '0'; 
		ALUOp_s <= ALU_OP_FUNCT;

	when RV32I_S_INSTR => 
		ALUSrc2_s <= SEL_OP2_IMM;
		ALUSrc1_s <= SEL_OP1_RS1;
		WB_select_s <= (others => 'X');
		RegWrite_s <= WE_0;
	  	MemRead_s <= '0';
		MemWrite_s <= WE_1;
		Branch_s <= '0'; 
		ALUOp_s <= ALU_OP_ADD;

	when RV32I_I_INSTR_LOAD => 
		ALUSrc2_s <= SEL_OP2_IMM;
		ALUSrc1_s <= SEL_OP1_RS1;
		WB_select_s <= SEL_MEM_TO_REG;
		RegWrite_s <= WE_1;
	  	MemRead_s <= '1';
		MemWrite_s <= WE_0;
		Branch_s <= '0'; 
		ALUOp_s <= ALU_OP_ADD;

	when RV32I_B_INSTR => 
		ALUSrc2_s <= SEL_OP2_RS2;
		ALUSrc1_s <= SEL_OP1_RS1;
		WB_select_s <= (others => 'X');
		RegWrite_s <= WE_0;
	  	MemRead_s <= '0';
		MemWrite_s <= WE_0;
		Branch_s <= '1'; 
		ALUOp_s <= ALU_OP_SUB;

	when RV32I_U_INSTR_LUI => 
		ALUSrc2_s <= (others => 'X');  -- don't care about ALU op2
		ALUSrc1_s <= SEL_OP1_IMM;
		WB_select_s <= SEL_MEM_TO_REG;
		RegWrite_s <= WE_1;
	  	MemRead_s <= '0';
		MemWrite_s <= WE_0;
		Branch_s <= '0'; 
		ALUOp_s <= ALU_OP_COPY;

	when RV32I_I_INSTR_OPER => 
		ALUSrc2_s <= SEL_OP2_IMM;
		ALUSrc1_s <= SEL_OP1_RS1;
		WB_select_s <= SEL_ALU_TO_REG;
		RegWrite_s <= WE_1;
	  	MemRead_s <= '0';
		MemWrite_s <= WE_0;
		Branch_s <= '0'; 
		ALUOp_s <= ALU_OP_FUNCT;

	when RV32I_J_INSTR =>
	-- JAL instruction
		ALUSrc2_s <= (others => 'X');
		ALUSrc1_s <= SEL_OP1_X;
		WB_select_s <= SEL_PC_PLUS4_TO_REG;
		RegWrite_s <= WE_1;
	  	MemRead_s <= '0';
		MemWrite_s <= WE_0;
		Branch_s <= '1'; 
		ALUOp_s <= (others => 'X');

	when RV32I_I_INSTR_JALR =>
		ALUSrc2_s <= SEL_OP2_IMM;
		ALUSrc1_s <= SEL_OP1_RS1;
		WB_select_s <= SEL_PC_PLUS4_TO_REG;
		RegWrite_s <= WE_1;
	  	MemRead_s <= '0';
		MemWrite_s <= WE_0;
		Branch_s <= '1'; 
		ALUOp_s <= ALU_OP_ADD;

	when RV32I_U_INSTR_AUIPC => 
		ALUSrc2_s <= SEL_OP2_IMM;
		ALUSrc1_s <= SEL_OP1_PC;
		WB_select_s <= SEL_ALU_TO_REG;
		RegWrite_s <= WE_1;
	  	MemRead_s <= '0';
		MemWrite_s <= WE_0;
		Branch_s <= '0'; 
		ALUOp_s <= ALU_OP_ADD;

	when RV32I_I_INSTR_FENCE => 
        	assert false report "fence instructions not supported" severity warning;
	-- TODO
		ALUSrc2_s <= (others => 'U');
		ALUSrc1_s <= (others => 'U');
		WB_select_s <= (others => 'U');
		RegWrite_s <= 'U';
	  	MemRead_s <= 'U';
		MemWrite_s <= 'U';
		Branch_s <= 'U'; 
		ALUOp_s <= (others => 'U');

	when RV32I_I_INSTR_ENVCSR => 
        	assert false report "env or csr instructions not supported" severity warning;
	-- TODO
		ALUSrc2_s <= (others => 'U');
		ALUSrc1_s <= (others => 'U');
		WB_select_s <= (others => 'U');
		RegWrite_s <= 'U';
	  	MemRead_s <= 'U';
		MemWrite_s <= 'U';
		Branch_s <= 'U'; 
		ALUOp_s <= (others => 'U');

	when others =>
        	assert false report "unknown instruction" severity warning;
		ALUSrc2_s <= (others => 'X');
		ALUSrc1_s <= (others => 'X');
		WB_select_s <= (others => 'X');
		RegWrite_s <= 'X';
	  	MemRead_s <= 'X';
		MemWrite_s <= 'X';
		Branch_s <= 'X'; 
		ALUOp_s <= (others => 'X');

    end case;
  end process InstructionDecode_process;

  -- Hazard detection process
  -- purpose: insert bubble in pipeline in case of dependency 
  -- type   : combinational
  -- inputs : IDEX_MemRead_s, IDEX_Rd_s, IFID_Rs1_s, IFID_Rs2_s
  -- outputs: Stall_Select_s

  IDEXE_MemRead_s <= IDEXE_ControlMEM_s(1);	-- MemRead control signal of IDEXE pipeline stage
  IDEXE_Rd_s <= Instruction_IDEX_i(11 downto 7);
  IFID_Rs1_s <= Instruction_IFID_i(19 downto 15);
  IFID_Rs2_s <= Instruction_IFID_i(24 downto 20); 

  HazardDetection: process(IDEXE_MemRead_s, IDEXE_Rd_s, IFID_Rs1_s, IFID_Rs2_s)
  begin
	if ((IDEXE_MemRead_s = '1') and ((IDEXE_Rd_s = IFID_Rs1_s) or (IDEXE_Rd_s = IFID_Rs2_s))) then
		Stall_select_s <= '1';	-- insert bubble
		PCWrite_o <= WE_0;
		IFIDWrite_o <= WE_0;
	else
		Stall_select_s <= '0';	-- normal operation
		PCWrite_o <= WE_1;
		IFIDWrite_o <= WE_1;
	end if;
  end process HazardDetection;

  PipelinedControl_s <= (ALUOp_s & ALUSrc1_s & ALUSrc2_s & Branch_s & MemRead_s & MemWrite_s & RegWrite_s & WB_select_s) when Stall_select_s = '0' else 
			NOP when Stall_select_s = '1' else 
			(others => 'U');
  -- End of ID processes
  --_____________________________________________________________________________________________________

  --_____________________________________________________________________________________________________
  -- IDEXE control processes
  -- purpose: save bits 
  -- type   : combinational
  -- inputs : ALUOp_s, ALUSrc1_s, ALUSrc2_s, resetn_i, clk_i
  -- outputs: IDEXE_ControlEXE_s
  IDEXEcontrol_0 : process(PipelinedControl_s, resetn_i, clk_i)
  begin
	if (resetn_i = '0') then
		IDEXE_ControlEXE_s <= (others => '0');
	elsif (clk_i'event and clk_i = '1') then
		IDEXE_ControlEXE_s <= PipelinedControl_s(10 downto 6);	-- ALUOp_s & ALUSrc1_s & ALUSrc2_s
	end if;
  end process IDEXEcontrol_0;

  -- inputs : Branch_s, MemRead_s, MemWrite_s, resetn_i, clk.
  -- outputs: IDEXE_ControlMEM_s
  IDEXEcontrol_1 : process(PipelinedControl_s, resetn_i, clk_i)
  begin
	if (resetn_i = '0') then
		IDEXE_ControlMEM_s <= (others => '0');
	elsif (clk_i'event and clk_i = '1') then
		IDEXE_ControlMEM_s <= PipelinedControl_s(5 downto 3);	-- Branch_s & MemRead_s & MemWrite_s;
	end if;
  end process IDEXEcontrol_1;

  -- inputs : RegWrite_s, WB_select_s, resetn_i, clk_i
  -- outputs: IDEXE_ControlWB_s
  IDEXEcontrol_2 : process(PipelinedControl_s, resetn_i, clk_i)
  begin
	if (resetn_i = '0') then
		IDEXE_ControlWB_s <= (others => '0');
	elsif (clk_i'event and clk_i = '1') then
		IDEXE_ControlWB_s <= PipelinedControl_s(2 downto 0);	-- RegWrite_s & WB_select_s;
	end if;
  end process IDEXEcontrol_2;

  -- ALU control process
  -- purpose: control ALU operation according to ALUOp from control process and funct3 bits of ISA
  -- type   : combinational
  -- inputs : ALUOp_s, Instruction_IDEX_i (bit30 & Func3 & Opcode)
  -- outputs: ALUControl_o
  ALUcontrol : process(IDEXE_ControlEXE_s, Instruction_IDEX_i)
  begin
	case IDEXE_ControlEXE_s(4 downto 3) is	-- according to ALUOp in EXE stage
	when ALU_OP_ADD =>
		ALUControl_o <= ALU_ADD; 
	when ALU_OP_SUB => 
		ALUControl_o <= ALU_SUB;
	when ALU_OP_FUNCT => 
		case Instruction_IDEX_i(14 downto 12) is	-- func3
		when "000" =>
			if (Instruction_IDEX_i(6 downto 0) = RV32I_R_INSTR) and (Instruction_IDEX_i(25) = '1') then
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
			if (Instruction_IDEX_i(25) = '1') then
				ALUControl_o <= ALU_SRAV;
			elsif (Instruction_IDEX_i(25) = '0') then
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
		assert false report "ALU operation is not defined" severity warning;
		ALUControl_o <= ALU_X;
	end case;
  end process ALUControl;

  ALUSrc1_o <= IDEXE_ControlEXE_s(2 downto 1);
  ALUSrc2_o <= "" & IDEXE_ControlEXE_s(0);

  -- purpose: Forwarding process in case of hazards
  -- type   : behavioral
  -- inputs : EXMEM_RegWrite_s, EXMEM_Rd_s, MEMWB_RegWrite_s, MEMWB_Rd_s, IDEXE_Rs1_s, IDEXE_Rs2_s
  -- outputs: RS1_data_s, RS2_data_s

	EXMEM_RegWrite_s <= EXMEM_ControlWB_s(2);
	EXMEM_Rd_s <= Instruction_EXMEM_i(11 downto 7);
	MEMWB_RegWrite_s <= MEMWB_ControlWB_s(2);
	MEMWB_Rd_s <= Instruction_MEMWB_i(4 downto 0);
	IDEXE_Rs1_s <= Instruction_IDEX_i(19 downto 15);
	IDEXE_Rs2_s <= Instruction_IDEX_i(24 downto 20);

	ForwardUnit: process(EXMEM_RegWrite_s, EXMEM_Rd_s, MEMWB_RegWrite_s, MEMWB_Rd_s, IDEXE_Rs1_s, IDEXE_Rs2_s)
	begin
		if ((EXMEM_RegWrite_s = WE_1) and (EXMEM_Rd_s /= X0) and (EXMEM_Rd_s = IDEXE_Rs1_s)) then	-- EX hazard
			  ForwardA_o <= "10";
		elsif ((MEMWB_RegWrite_s = WE_1) and (MEMWB_Rd_s /= X0) and not((EXMEM_RegWrite_s = WE_1) and (EXMEM_Rd_s /= X0) and (EXMEM_Rd_s = IDEXE_Rs1_s)) and (MEMWB_Rd_s = IDEXE_Rs1_s)) then	-- MEM hazard
			  ForwardA_o <= "01";
		else 		-- other cases
			  ForwardA_o <= "00";
		end if;

		if ((EXMEM_RegWrite_s = WE_1) 
			and (EXMEM_Rd_s /= X0)
			and (EXMEM_Rd_s = IDEXE_Rs2_s)) then	-- EX hazard
			  ForwardB_o <= "10";
		elsif ((MEMWB_RegWrite_s = WE_1) 
			and (MEMWB_Rd_s /= X0)
			and not((EXMEM_RegWrite_s = WE_1) and (EXMEM_Rd_s /= X0) and (EXMEM_Rd_s = IDEXE_Rs2_s)) 
			and (MEMWB_Rd_s = IDEXE_Rs2_s)) then	-- MEM hazard
			  ForwardB_o <= "01";
		else 		-- other cases 
			  ForwardB_o <= "00";
		end if;
	end process;


  -- End of EXE stage processes 
  --_____________________________________________________________________________________________________

  --_____________________________________________________________________________________________________
  -- MEM processes
  -- EXE/MEM control processes
  -- purpose: save bits 
  -- type   : combinational
  -- inputs : IDEXE_ControlMEM_s, resetn_i, clk_i
  -- outputs: EXMEM_ControlMEM_s
  EXMEMcontrol_0 : process(IDEXE_ControlMEM_s, resetn_i, clk_i)
  begin
	if (resetn_i = '0') then
		EXMEM_ControlMEM_s <= (others => '0');
	elsif (clk_i'event and clk_i = '1') then
		EXMEM_ControlMEM_s <= IDEXE_ControlMEM_s;
	end if;
  end process EXMEMcontrol_0;

  -- inputs : IDEXE_ControlWB_s, resetn_i, clk_i
  -- outputs: EXMEM_ControlWB_s
  EXMEMcontrol_1 : process(IDEXE_ControlWB_s, resetn_i, clk_i)
  begin
	if (resetn_i = '0') then
		EXMEM_ControlWB_s <= (others => '0');
	elsif (clk_i'event and clk_i = '1') then
		EXMEM_ControlWB_s <= IDEXE_ControlWB_s;
	end if;
  end process EXMEMcontrol_1;

  -- purpose: program counter selection (PC+4, branch, jump...)
  -- type   : combinational
  -- inputs : EXMEM_ControlMEM_s (i.e. Branch_s), ALU_zero_i, ALU_lt_i, Instruction_EXMEM_i
  -- outputs: PC_select_o
  pc_select:process(EXMEM_ControlMEM_s(2), ALU_zero_i, ALU_lt_i, Instruction_EXMEM_i)
  variable select_v : std_logic;
  begin
	select_v := '0';
	case Instruction_EXMEM_i(6 downto 0) is
	when RV32I_B_INSTR =>
		case Instruction_EXMEM_i(14 downto 12) is
		when "000" =>
			select_v := ALU_zero_i;		-- BEQ 
		when "001" =>
			select_v := not ALU_zero_i;	-- BNE
		when "100" =>
			select_v := ALU_lt_i;		-- BLT
		when "101" =>
			select_v := not ALU_lt_i;	-- BGE
		when "110" =>
			select_v := ALU_lt_i;		-- BLTU
		when "111" =>
			select_v := not ALU_lt_i;	-- BGEU
		when "010" =>
			select_v := 'U';			
		when "011" =>
			select_v := 'U';			
		when others =>
			select_v := 'U';			
		end case;
		if ((EXMEM_ControlMEM_s(2) and select_v) = '1') then -- according to branch_s and ALU status signals ...
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
  end process pc_select;
  MemRead_o <= EXMEM_ControlMEM_s(1);
  MemWrite_o <= EXMEM_ControlMEM_s(0);

  -- End of MEM stage processes 
  --_____________________________________________________________________________________________________

  --_____________________________________________________________________________________________________
  -- WB processes
  -- MEM/WB control processes
  -- purpose: save bits 
  -- type   : combinational
  -- inputs : EXMEM_ControlWB_s, resetn_i, clk_i
  -- outputs: MEMWB_ControlWB_s
  MEMWBcontrol_0 : process(EXMEM_ControlWB_s, resetn_i, clk_i)
  begin
	if (resetn_i = '0') then
		MEMWB_ControlWB_s <= (others => '0');
	elsif (clk_i'event and clk_i = '1') then
		MEMWB_ControlWB_s <= EXMEM_ControlWB_s;
	end if;
  end process MEMWBcontrol_0;
  RegWrite_o <= MEMWB_ControlWB_s(2);
  WB_select_o <= MEMWB_ControlWB_s(1 downto 0);

end architecture RV32I_Pipelined_controlpath_architecture;

