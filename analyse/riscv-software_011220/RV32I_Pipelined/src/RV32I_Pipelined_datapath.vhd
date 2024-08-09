-------------------------------------------------------------------------------
-- Title      : RV32I_datapath
-- Project    : 
-------------------------------------------------------------------------------
-- File       : RV32I_datapath.vhd
-- Author     :   <michel agoyan@ROU13572>
-- Company    : 
-- Created    : 2015-11-25
-- Last update: 2019-08-23
-- Platform   : 
-- Standard   : VHDL'2008
-------------------------------------------------------------------------------
-- Description:  RV32I datapath , also included instruction memory
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
use work.RV32I_components.all;
use work.RV32I_constants.all;

entity RV32I_Pipelined_datapath is
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

end entity RV32I_Pipelined_datapath;

architecture RV32I_Pipelined_datapath_architecture of RV32I_Pipelined_datapath is
  -- signals used at IF/ID stage
  signal pc_next_s	: std_logic_vector(31 downto 0);  -- next value of the program counter
  signal pc_plus4_s	: std_logic_vector(31 downto 0);  -- next instruction without jump (i.e. PC+4)
  signal pc_counter_s	: std_logic_vector(31 downto 0);  -- output of the program counter
  signal instruction_s	: std_logic_vector(31 downto 0);  -- instruction bus 
  signal IFID_Stage_s	: std_logic_vector(95 downto 0);  
	-- pc_plus4_s & pc_counter_s & instruction_s;
	-- [95|64]	[63|32]		[31|0]
  alias IFID_pc_plus4 : std_logic_vector(31 downto 0) is IFID_stage_s(95 downto 64);
  alias IFID_pc_counter : std_logic_vector(31 downto 0) is IFID_stage_s(63 downto 32);
  alias IFID_instruction : std_logic_vector(31 downto 0) is IFID_stage_s(31 downto 0);

  -- signals used at ID/EXE stage
  signal rs1_data_s	: std_logic_vector(31 downto 0); -- register source 1 data bus
  signal rs2_data_s	: std_logic_vector(31 downto 0); -- register source 2 data bus
  signal rs1_add_s	: std_logic_vector(4 downto 0);  -- register source 1 index
  signal rs2_add_s	: std_logic_vector(4 downto 0);  -- register source 2 index 
  signal rd_add_s	: std_logic_vector(4 downto 0);  -- register destination index
  signal imm_s		: std_logic_vector(31 downto 0); -- sign extended data
  -- TODO -> Question ? : send all instruction bits
  signal IDEXE_Stage_s	: std_logic_vector(185 downto 0); 
	-- pc_plus4_s & pc_counter_s & rs1_data_s & rs2_data_s & imm_s & IFID_instruction[30|24:20|19:15|14:12|11:7|6:0] (i.e. bit 30 | rs2 | rs1 | func3 | rd address | opcode) 
	-- [185|154]	[153|122]      [121|90]     [89|58]	 [57|26] [25:0]
  alias IDEXE_pc_plus4 : std_logic_vector(31 downto 0) is IDEXE_Stage_s(185 downto 154);
  alias IDEXE_pc_counter : std_logic_vector(31 downto 0) is IDEXE_Stage_s(153 downto 122);
  alias IDEXE_rs1_data : std_logic_vector(31 downto 0) is IDEXE_Stage_s(121 downto 90);
  alias IDEXE_rs2_data : std_logic_vector(31 downto 0) is IDEXE_Stage_s(89 downto 58);
  alias IDEXE_imm : std_logic_vector(31 downto 0) is IDEXE_Stage_s(57 downto 26);
  alias IDEXE_instruction : std_logic_vector(25 downto 0) is IDEXE_Stage_s(25 downto 0);
  
  -- signals used at EXE/MEM stage
  signal ALU_s		: std_logic_vector(31 downto 0);  -- ALU output
  signal ALU_op1_data_s	: std_logic_vector(31 downto 0);  -- ALU operand 1
  signal ALU_op2_data_s	: std_logic_vector(31 downto 0);  -- ALU operand 2
  signal ALU_zero_s	: std_logic;
  signal ALU_lt_s	: std_logic;
  signal pc_imm_s	: std_logic_vector(31 downto 0);  -- next instruction with jump (i.e. PC+Immediate value)
  Signal RS1_EXMEM_data_s	: std_logic_vector(31 downto 0);
  Signal RS2_EXMEM_data_s	: std_logic_vector(31 downto 0);
  signal EXMEM_Stage_s	: std_logic_vector(144 downto 0);  
	-- pc_plus4_s & pc_imm_s & ALU_zero_s & ALU_lt_s & ALU_s & IDEXE_Stage_s[79:48] (i.e. rs2_data) & IDEXE_Stage_s[14:0] (i.e. ID_instruction [func3 | rd address | opcode])
	-- [144|113]    [112|81]   [80]		[79]	   [78|47] [46|15]				  [14|0]
  alias EXMEM_pc_plus4 : std_logic_vector(31 downto 0) is EXMEM_Stage_s(144 downto 113);
  alias EXMEM_imm : std_logic_vector(31 downto 0) is EXMEM_Stage_s(112 downto 81);
  alias EXMEM_alu_zero : std_logic is EXMEM_Stage_s(80);
  alias EXMEM_alu_lt : std_logic is EXMEM_Stage_s(79);
  alias EXMEM_alu : std_logic_vector(31 downto 0) is EXMEM_Stage_s(78 downto 47);
  alias EXMEM_rs2_data : std_logic_vector(31 downto 0) is EXMEM_Stage_s(46 downto 15);
  alias EXMEM_instruction : std_logic_vector(14 downto 0) is EXMEM_Stage_s(14 downto 0);

  -- signals used at MEM/WB stage
  signal MemData_s	: std_logic_vector(31 downto 0); -- Data memory
  signal MEMWB_Stage_s	: std_logic_vector(100 downto 0); 
	-- pc_plus4_s & MemData_s & EXMEM[78|47] (ALU result) & EXMEM_Stage_s[11:7] (i.e. EXE_instruction [rd address]) 
	-- [100|69]	[68|37]	    [36|5]			[4|0]
  alias MEMWB_pc_plus4 : std_logic_vector(31 downto 0) is MEMWB_Stage_s(100 downto 69);
  alias MEMWB_mem_data : std_logic_vector(31 downto 0) is MEMWB_Stage_s(68 downto 37);
  alias MEMWB_alu : std_logic_vector(31 downto 0) is MEMWB_Stage_s(36 downto 5);
  alias MEMWB_rd : std_logic_vector(4 downto 0) is MEMWB_Stage_s(4 downto 0);

  -- signals used at WB stage
  signal wb_data_s	: std_logic_vector(31 downto 0);  -- write back data bus

begin  -- architecture RV32I_Pipelined_datatpath_architecture

  -- IF/ID Stage processes
  -- ____________________________________________________________________________________________
  -- purpose: program counter incrementer
  -- type   : combinational
  -- inputs : pc_counter_s
  -- outputs: 
  pc_incr : process (pc_counter_s) is
  begin  
    pc_plus4_s <= std_logic_vector(unsigned(pc_counter_s)+4);
  end process pc_incr;

  -- purpose: program counter
  -- type   : sequential
  -- inputs : clk_i, resetn_i
  -- outputs: 
  pc : process (clk_i, resetn_i, pc_next_s, PCWrite_i, pc_counter_s) is
  begin  
    if resetn_i = '0' then                  	-- asynchronous reset (active low)
      pc_counter_s <= (others => '0');	    	-- NB : normally PC starts from 0x00010000 (see Patterson & Waterman page 40) !
    elsif clk_i'event and clk_i = '1' then  	-- rising clock edge
      	if (PCWrite_i = WE_1) then		-- manage stall (see Patternson & Hennessy page 306)
		pc_counter_s <= pc_next_s;
	else
		pc_counter_s <= pc_counter_s;
	end if;
    end if;
  end process pc;

  -- purpose: IF/ID stage register
  -- type   : sequential
  -- inputs : clk_i, resetn_i, instruction_s, pc_counter_s, pc_plus4_s
  -- outputs: IFID_Stage_s
  IFID_Stage : process (clk_i, resetn_i, instruction_s, pc_counter_s, pc_plus4_s, IFIDWrite_i, IFID_Stage_s) 
  begin  
    if resetn_i = '0' then                  -- asynchronous reset (active low)
      IFID_Stage_s <= (others => '0');	    
    elsif clk_i'event and clk_i = '1' then  -- rising clock edge
	if (IFIDWrite_i = WE_1) then
      		IFID_Stage_s <= pc_plus4_s & pc_counter_s & instruction_s;
	else
		IFID_Stage_s <= IFID_Stage_s;
	end if;
    end if;
  end process IFID_Stage;

  -- NB : use only ROM of 8Ko (i.e. 2^12 32-bit words) 
  instruction_mem : sync_mem
    generic map (
      width    => 32,
      n        => 12,
      filename => "rom_Stall&Forward.hex")
    port map (
      clk_i    => clk_i,
      resetn_i => resetn_i,
      we_i     => '0',
      re_i     => '1',
      d_i      => (others => '0'),
      add_i    => pc_counter_s(13 downto 2),
      d_o      => instruction_s);

  pc_next_s <= pc_plus4_s when PC_select_i = SEL_PC_PLUS_4 else 
		EXMEM_imm  when PC_select_i = SEL_PC_IMM else			-- pc_imm_s
		EXMEM_alu and not 32x"1" when PC_select_i = SEL_PC_JALR else	-- alu_s (see note on JALR instruction page 154, Patterson & Waterman, The RISCV Reader)
		32x"1C09000" when PC_select_i = SEL_PC_EXCEPTION else 
		(others => 'U');

  Instruction_IFID_o <= IFID_Stage_s(31 downto 0);

  -- end of IF/ID Stage processes
  -- ____________________________________________________________________________________________

  -- ID/EXE Stage processes
  -- ____________________________________________________________________________________________
  -- purpose: immediate extension of data in instruction according to ISA
  -- type   : combinational
  -- inputs : instruction_s
  -- outputs: imm_s
  ImmGen : process(IFID_instruction)
  variable opcode_v : std_logic_vector(6 downto 0);
  begin
	opcode_v := IFID_instruction(6 downto 0);
	case opcode_v is
	when RV32I_U_INSTR_LUI => 
		imm_s <= IFID_instruction(31 downto 12) & "000000000000";
	when RV32I_U_INSTR_AUIPC => 
		imm_s <= IFID_instruction(31 downto 12) & "000000000000";
	when RV32I_S_INSTR => 
		imm_s <= std_logic_vector(resize(signed(IFID_instruction(31 downto 25) & IFID_instruction(11 downto 7)),32));
	when RV32I_I_INSTR_JALR => 
		imm_s <= std_logic_vector(resize(signed(IFID_instruction(31 downto 20)),32));
	when RV32I_I_INSTR_LOAD => 
		imm_s <= std_logic_vector(resize(signed(IFID_instruction(31 downto 20)),32));
	when RV32I_I_INSTR_OPER =>
		imm_s <= std_logic_vector(resize(signed(IFID_instruction(31 downto 20)),32));
	when RV32I_B_INSTR => 
		imm_s <= std_logic_vector(resize(signed(IFID_instruction(31) & IFID_instruction(7) & IFID_instruction(30 downto 25) & IFID_instruction(11 downto 8) & '0'),32));
	when RV32I_J_INSTR => 
		imm_s <= std_logic_vector(resize(signed(IFID_instruction(31) & IFID_instruction(19 downto 12) & IFID_instruction(20) & IFID_instruction(30 downto 21) & '0'),32));
	when others =>
		imm_s <= (others => 'U'); 
	end case;	
  end process ImmGen;

  -- purpose: ID/EXE stage register
  -- type   : sequential
  -- inputs : clk_i, resetn_i, IFID_Stage_s, rs1_data_s, rs2_data_s, imm_s 
  -- outputs: IDEXE_Stage_s
  IDEXE_Stage : process (clk_i, resetn_i, IFID_Stage_s, rs1_data_s, rs2_data_s, imm_s) 
  begin  
    if resetn_i = '0' then                  -- asynchronous reset (active low)
      IDEXE_Stage_s <= (others => '0');	    
    elsif clk_i'event and clk_i = '1' then  -- rising clock edge
      IDEXE_Stage_s <= IFID_pc_plus4 & 
			IFID_pc_counter & 
			rs1_data_s & 
			rs2_data_s & 
			imm_s & 
			IFID_instruction(30) & IFID_instruction(24 downto 20) & IFID_instruction(19 downto 15) & IFID_instruction(14 downto 12) & IFID_instruction(11 downto 7) & IFID_instruction(6 downto 0);
			 	-- pc_plus4_s & pc_counter_s & rs1_data_s & rs2_data_s & imm_s & IF_instruction[30|24:20|19:15|14:12|11:7|6:0] (i.e. bit 30 | rs2 | rs1 | func3 | rd address | opcode) 
    end if;
  end process IDEXE_Stage;

  -- decode partially the instruction to retrieve the register indexes
  rs1_add_s <= IFID_instruction(19 downto 15);
  rs2_add_s <= IFID_instruction(24 downto 20);
  rd_add_s  <= MEMWB_rd;

  register_file_1 : register_file
    generic map (
      width => 32,
      n     => 5)
    port map (
      clk_i      => clk_i,
      resetn_i   => resetn_i,
      rs1_add_i  => rs1_add_s,
      rs2_add_i  => rs2_add_s,
      rd_add_i   => rd_add_s,
      rd_data_i  => wb_data_s,
      we_i       => RegWrite_i,
      rs1_data_o => rs1_data_s,
      rs2_data_o => rs2_data_s);

  Instruction_IDEX_o <= IDEXE_instruction; 
	 -- instruction's bit 30, rs2, rs1, func3, Rd and opcode for ALU control, stall and forwarding processes in control path

  -- end of ID/EXE Stage processes
  -- ____________________________________________________________________________________________

  -- EXE/MEM Stage processes
  -- ____________________________________________________________________________________________
  -- purpose: EXE/MEM stage register
  -- type   : sequential
  -- inputs : clk_i, resetn_i, IDEXE_Stage_s, pc_imm_s, ALU_zero_s, ALU_lt_s, ALU_s 
  -- outputs: EXMEM_Stage_s
  EXMEM_Stage : process (clk_i, resetn_i, IDEXE_Stage_s, pc_imm_s, ALU_zero_s, ALU_lt_s, ALU_s) 
  begin  
    if resetn_i = '0' then                  -- asynchronous reset (active low)
      EXMEM_Stage_s <= (others => '0');	    
    elsif clk_i'event and clk_i = '1' then  -- rising clock edge
      EXMEM_Stage_s <= IDEXE_pc_plus4 & 
			pc_imm_s & 
			ALU_zero_s & 
			ALU_lt_s & 
			ALU_s &
			IDEXE_rs2_data &
			IDEXE_instruction(14 downto 0); 	
		-- pc_plus4_s & pc_imm_s & ALU_zero_s & ALU_lt_s & ALU_s & IDEXE_Stage_s[89:58] (i.e. rs2_data) & IDEXE_Stage_s[14:0] (i.e. ID_instruction [func3 | rd address | opcode]) 
    end if;
  end process EXMEM_Stage;

  -- purpose: compute immediate value of next pc
  -- type   : behavioral
  -- inputs : IDEXE_Stage_s(153 downto 122), IDEXE_Stage_s(57 downto 26) as pc_counter_s and imm_s
  -- outputs: pc_imm_s
  pc_imm : process(IDEXE_pc_counter, IDEXE_imm)
  begin
	pc_imm_s <= std_logic_vector(unsigned(IDEXE_pc_counter) + unsigned(IDEXE_imm(30 downto 0) & '0')); 
		-- pc_counter + imm_s // imm_s is considered as generated correctly by ImmGen with sign extended
  end process pc_imm;

  -- components instanciation
  alu_1 : alu
    generic map (
      width => 32)
    port map (
      func_i => ALUControl_i,
      op1_i  => ALU_op1_data_s,
      op2_i  => ALU_op2_data_s,
      d_o    => ALU_s,
      zero_o => ALU_zero_s,
      lt_o   => ALU_lt_s);

	ForwardingMux_rs1: process(ForwardA_i, IDEXE_rs1_data, EXMEM_alu, wb_data_s)
	begin
		case ForwardA_i is
		when "00" =>
			RS1_EXMEM_data_s <= IDEXE_rs1_data;
		when "01" => 
			RS1_EXMEM_data_s <= wb_data_s;
		when "10" => 
			RS1_EXMEM_data_s <= EXMEM_alu;
		when others => 
			RS1_EXMEM_data_s <= (others => 'X');
		end case;
	end process;
	
	ForwardingMux_rs2: process(ForwardB_i, IDEXE_rs2_data, EXMEM_alu, wb_data_s)
	begin
		case ForwardB_i is
		when "00" =>
			RS2_EXMEM_data_s <= IDEXE_rs2_data;
		when "01" => 
			RS2_EXMEM_data_s <= wb_data_s;
		when "10" => 
			RS2_EXMEM_data_s <= EXMEM_alu;
		when others => 
			RS2_EXMEM_data_s <= (others => 'X');
		end case;
	end process;
  
  -- multiplexors on intern signals
  ALU_op1_data_s <= RS1_EXMEM_data_s when ALUSrc1_i = SEL_OP1_RS1 else  -- rs1_data or forwarding data
		IDEXE_imm when ALUSrc1_i = SEL_OP1_IMM else		-- imm_s
		IDEXE_pc_counter when ALUSrc1_i = SEL_OP1_PC else	-- pc_counter
		(others => 'X') when ALUSrc1_i = SEL_OP1_X else
		(others => 'U');

  ALU_op2_data_s <= RS2_EXMEM_data_s when ALUSrc2_i = SEL_OP2_RS2 else 	-- rs2_data or forwarding data
		IDEXE_imm when ALUSrc2_i = SEL_OP2_IMM else		-- imm_s
		(others => 'U');

  Instruction_EXMEM_o <= EXMEM_instruction;	-- func3, rd and opcode
  ALU_zero_o <= EXMEM_alu_zero;
  ALU_lt_o <= EXMEM_alu_lt;

  -- end of EXE/MEM Stage processes
  -- ____________________________________________________________________________________________

  -- MEM/WB Stage processes
  -- ____________________________________________________________________________________________
  -- purpose: MEM/WB stage register
  -- type   : sequential
  -- inputs : clk_i, resetn_i, MemData_s, EXMEM_Stage_s  
  -- outputs: MEMWB_Stage_s
  MEMWB_Stage : process (clk_i, resetn_i, MemData_s, EXMEM_Stage_s)
  begin  
    if resetn_i = '0' then                  -- asynchronous reset (active low)
      MEMWB_Stage_s <= (others => '0');	    
    elsif clk_i'event and clk_i = '1' then  -- rising clock edge
      MEMWB_Stage_s <= EXMEM_pc_plus4 & 		-- pc_plus4
			MemData_s & 
			EXMEM_alu &  			-- ALU_s
			EXMEM_instruction(11 downto 7); -- Rd address	
		-- pc_plus4_s & MemData_s & EXMEM[78|47] (ALU result) & EXMEM_Stage_s[11:7] (i.e. EXE_instruction [rd address]) 
    end if;
  end process MEMWB_Stage;

  -- NB : use only RAM of 256Ko (i.e. 2^16 32-bit words) 
  data_mem : sync_mem
    generic map (
      width    => 32,
      n        => 16,
      filename => "ram.hex")
    port map (
      clk_i    => clk_i,
      resetn_i => resetn_i,
      we_i     => MemWrite_i,
      re_i     => MemRead_i,
      d_i      => EXMEM_rs2_data, -- rs2
      add_i    => EXMEM_alu(17 downto 2), -- ALU (17 downto 2)
      d_o      => MemData_s);

  Instruction_MEMWB_o <= MEMWB_rd;	-- rd address


  -- end of MEM/WB Stage processes
  -- ____________________________________________________________________________________________

  -- WB Stage processes
  -- ____________________________________________________________________________________________

  wb_data_s <= MEMWB_alu when WB_select_i = SEL_ALU_TO_REG else			-- ALU result
		MEMWB_mem_data when WB_select_i = SEL_MEM_TO_REG else		-- Mem data
		MEMWB_pc_plus4 when WB_select_i = SEL_PC_PLUS4_TO_REG else	-- pc + 4
		(others => 'U');
             
end architecture RV32I_Pipelined_datapath_architecture;
