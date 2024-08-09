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
-- 2019-08-21  1.1      Olivier potin   Modified to implement RISCV Monocycle
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library rtl_core;
use rtl_core.RV32I_components.all;
use rtl_core.RV32I_constants.all;

entity RV32I_Monocycle_datapath is
  
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



end entity RV32I_Monocycle_datapath;

architecture RV32I_Monocycle_datapath_architecture of RV32I_Monocycle_datapath is

  signal pc_next_s    : std_logic_vector(31 downto 0);  -- next value of the program counter
  signal pc_plus4_s   : std_logic_vector(31 downto 0);  -- next instruction without jump (i.e. PC+4)
  signal pc_imm_s     : std_logic_vector(31 downto 0);  -- next instruction with jump (i.e. PC+Immediate value)
  signal pc_counter_s : std_logic_vector(31 downto 0);  -- output of the program counter

  signal instruction_s	: std_logic_vector(31 downto 0);  -- instruction bus 
  signal wb_data_s	: std_logic_vector(31 downto 0);  -- write back data bus
  signal rs1_data_s	: std_logic_vector(31 downto 0);  -- register source 1 data bus
  signal rs2_data_s	: std_logic_vector(31 downto 0);  -- register source 2 data bus
  signal rs1_add_s	: std_logic_vector(4 downto 0);  -- register source 1 index
  signal rs2_add_s	: std_logic_vector(4 downto 0);  -- register source 2 index 
  signal rd_add_s	: std_logic_vector(4 downto 0);  -- register destination index
  signal imm_s		: std_logic_vector(31 downto 0); -- sign extended data
  signal MemReadData_s	: std_logic_vector(31 downto 0); -- Data read from memory
  signal MemWriteData_s	: std_logic_vector(31 downto 0); -- Data to write in memory
  signal MemData_s	: std_logic_vector(31 downto 0); -- data memory output to write back according to load option (byte, half-word or word)
  signal MemWrite_s	: std_logic_vector(3 downto 0);  -- Data memory write enable
  constant MemAddrUp	: std_logic_vector(31 downto 22):=(others=>'0'); -- Data memory addr upside
  signal ALU_s		: std_logic_vector(31 downto 0); -- ALU output
  signal ALU_op1_data_s	: std_logic_vector(31 downto 0);  -- ALU operand 1
  signal ALU_op2_data_s	: std_logic_vector(31 downto 0);  -- ALU operand 2

begin  -- architecture RV32I_Monocycle_datatpath_architecture
  Instruction_o <= instruction_s;
  IAddress_o <= pc_counter_s;
  -- decode partially the instruction to retrieve the register indexes
  rs1_add_s <= instruction_s(19 downto 15);
  rs2_add_s <= instruction_s(24 downto 20);
  rd_add_s  <= instruction_s(11 downto 7);

  -- multiplexors on intern signals
  pc_next_s <= pc_plus4_s when PC_select_i = SEL_PC_PLUS_4 else 
		pc_imm_s when PC_select_i = SEL_PC_IMM else
		alu_s and not 32x"1" when PC_select_i = SEL_PC_JALR else	-- see note on JALR instruction page 154, Patterson & Waterman, The RISCV Reader
		32x"1C09000" when PC_select_i = SEL_PC_EXCEPTION else
		(others => 'U');

  ALU_op1_data_s <= rs1_data_s when ALUSrc1_i = SEL_OP1_RS1 else 
		imm_s when ALUSrc1_i = SEL_OP1_IMM else 
		pc_counter_s when ALUSrc1_i = SEL_OP1_PC else
		(others => 'X') when ALUSrc1_i = SEL_OP1_X else
		(others => 'U');

  ALU_op2_data_s <= rs2_data_s when ALUSrc2_i = SEL_OP2_RS2 else 
		imm_s when ALUSrc2_i = SEL_OP2_IMM else 
		(others => 'U');

  wb_data_s <= ALU_s when WB_select_i = SEL_ALU_TO_REG else
		MemData_s when WB_select_i = SEL_MEM_TO_REG else
		pc_plus4_s when WB_select_i = SEL_PC_PLUS4_TO_REG else
		(others => 'U');
             
  -- purpose: immediate extension of data in instruction according to ISA
  -- type   : combinational
  -- inputs : instruction_s
  -- outputs: imm_s
  ImmGen : process(instruction_s)
  variable opcode_v : std_logic_vector(6 downto 0);
  begin
	opcode_v := instruction_s(6 downto 0);
	case opcode_v is
	when RV32I_U_INSTR_LUI => 
		imm_s <= instruction_s(31 downto 12) & "000000000000";
	when RV32I_U_INSTR_AUIPC => 
		imm_s <= instruction_s(31 downto 12) & "000000000000";
	when RV32I_S_INSTR => 
		imm_s <= std_logic_vector(resize(signed(instruction_s(31 downto 25) & instruction_s(11 downto 7)),32));
	when RV32I_I_INSTR_JALR => 
		imm_s <= std_logic_vector(resize(signed(instruction_s(31 downto 20)),32));
	when RV32I_I_INSTR_LOAD => 
		imm_s <= std_logic_vector(resize(signed(instruction_s(31 downto 20)),32));
	when RV32I_I_INSTR_OPER =>
		imm_s <= std_logic_vector(resize(signed(instruction_s(31 downto 20)),32));
	when RV32I_B_INSTR => 
		imm_s <= std_logic_vector(resize(signed(instruction_s(31) & instruction_s(7) & instruction_s(30 downto 25) & instruction_s(11 downto 8) & '0'),32));
	when RV32I_J_INSTR => 
		imm_s <= std_logic_vector(resize(signed(instruction_s(31) & instruction_s(19 downto 12) & instruction_s(20) & instruction_s(30 downto 21) & '0'),32));
	when others =>
		imm_s <= (others => 'U'); 
	end case;	
  end process ImmGen;

  -- purpose: program counter
  -- type   : sequential
  -- inputs : clk_i, resetn_i
  -- outputs: pc_counter_s
  pc : process (clk_i, resetn_i) is
  begin  
    if resetn_i = '0' then                  -- asynchronous reset (active low)
      pc_counter_s <= (others => '0');	    -- NB : normally PC starts from 0x00010000 (see Patterson & Waterman page 40) !
    elsif clk_i'event and clk_i = '1' then  -- rising clock edge
      pc_counter_s <= pc_next_s;
    end if;
  end process pc;

  -- purpose: program counter incrementer
  -- type   : combinational
  -- inputs : pc_counter_s
  -- outputs: pc_plus4_s 
  pc_incr : process (pc_counter_s) is
  begin  
    pc_plus4_s <= std_logic_vector(unsigned(pc_counter_s)+4);
  end process pc_incr;

  -- purpose: compute immediate value of next pc
  -- type   : behavioral
  -- inputs : pc_counter_s, imm_s
  -- outputs: pc_imm_s
  pc_imm : process(pc_counter_s, imm_s)
  begin
	pc_imm_s <= std_logic_vector(unsigned(pc_counter_s) + unsigned(imm_s)); -- imm_s is considered as generated correctly by ImmGen with sign extended
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
      zero_o => ALU_zero_o,
      lt_o   => ALU_lt_o,
      ltu_o  => ALU_ltu_o);

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

  -- NB : use only ROM of ?Ko (i.e. 2^16 32-bit words) 
  instruction_mem : sync_mem
    generic map (
	data_size => 32,
	data_granularity => 1,
	n => 16,
	filename => rom_init_filename)
    port map (
      clk_i    => clk_i,
      resetn_i => resetn_i,
      we_i     => "0",
      re_i     => '1',
      d_i      => (others => '0'),
      add_i    => pc_counter_s(17 downto 2),
      d_o      => instruction_s);

  -- purpose: select data fields according to LOAD/STORE instruction
  -- type   : behavioral
  -- inputs : MemSelectData_i, MemReadData_s, ALU_s
  -- outputs: MemData_s
  LoadDataSelect : process(MemSelectData_i, MemReadData_s, ALU_s)
  begin
	case MemSelectData_i is
		when RV32I_FUNCT3_LS_BYTE =>
			case ALU_s(1 downto 0) is
			when "00" => 
				MemData_s(31 downto 8) <= (others => MemReadData_s(7));
				MemData_s(7 downto 0) <= MemReadData_s(7 downto 0);
			when "01" => 
				MemData_s(31 downto 8) <= (others => MemReadData_s(15));
				MemData_s(7 downto 0) <= MemReadData_s(15 downto 8);
			when "10" => 
				MemData_s(31 downto 8) <= (others => MemReadData_s(23));
				MemData_s(7 downto 0) <= MemReadData_s(23 downto 16);
			when "11" => 
				MemData_s(31 downto 8) <= (others => MemReadData_s(31));
				MemData_s(7 downto 0) <= MemReadData_s(31 downto 24);
			when others => 
				assert false report "loading address is not defined properly. Get lowest byte by default" severity warning;
				MemData_s(31 downto 8) <= (others => MemReadData_s(7));	-- NB: Default is to keep the lowest byte 
				MemData_s(7 downto 0) <= MemReadData_s(7 downto 0);
			end case;
		when RV32I_FUNCT3_LS_HALFWORD =>
			if (ALU_s(1) = '1') then -- NB: we considered the memory aligned on 32 bits so the half word can only be the lowest part or the highest part of the word
				MemData_s(31 downto 16) <= (others => MemReadData_s(31));
				MemData_s(15 downto 0) <= MemReadData_s(31 downto 16);
			else 
				MemData_s(31 downto 16) <= (others => MemReadData_s(15));	-- NB: Default is to keep the lowest half word 
				MemData_s(15 downto 0) <= MemReadData_s(15 downto 0);
			end if;
		when RV32I_FUNCT3_LS_WORD => 
			MemData_s <= MemReadData_s;
	 	when RV32I_FUNCT3_LBU =>
			case ALU_s(1 downto 0) is
			when "00" => 
				MemData_s(31 downto 8) <= (others => '0');
				MemData_s(7 downto 0) <= MemReadData_s(7 downto 0);
			when "01" => 
				MemData_s(31 downto 8) <= (others => '0');
				MemData_s(7 downto 0) <= MemReadData_s(15 downto 8);
			when "10" => 
				MemData_s(31 downto 8) <= (others => '0');
				MemData_s(7 downto 0) <= MemReadData_s(23 downto 16);
			when "11" => 
				MemData_s(31 downto 8) <= (others => '0');
				MemData_s(7 downto 0) <= MemReadData_s(31 downto 24);
			when others => 
				assert false report "loading address is not defined properly. Get lowest byte by default" severity warning;
				MemData_s(31 downto 8) <= (others => '0');	-- NB: Default is to keep the lowest byte 
				MemData_s(7 downto 0) <= MemReadData_s(7 downto 0);
			end case;
	  	when RV32I_FUNCT3_LHU =>
			if (ALU_s(1) = '1') then -- NB: we considered the memory aligned on 32 bits so the half word can only be the lowest part or the highest part of the word
				MemData_s(31 downto 16) <= (others => '0');
				MemData_s(15 downto 0) <= MemReadData_s(31 downto 16);
			else 
				MemData_s(31 downto 16) <= (others => '0');	-- NB: Default is to keep the lowest half word 
				MemData_s(15 downto 0) <= MemReadData_s(15 downto 0);
			end if;
		when others =>
			MemData_s <= MemReadData_s;
	end case;
  end process;

  -- purpose: select data fields according to LOAD/STORE instruction /  MemWrite is disable when writting in peripheral address page (i.e > 0x003FFFFFF, see constant : MemAddrUp)
  -- type   : behavioral
  -- inputs : MemSelectData_i, rs2_data_s, MemWrite_i, ALU_s
  -- outputs: MemWriteData_s, MemWrite_s
  WriteDataSelect : process(MemSelectData_i, rs2_data_s, MemWrite_i, ALU_s)
  begin
	if (ALU_s(31 downto 22) = MemAddrUp) then
		case MemSelectData_i is
			when RV32I_FUNCT3_LS_BYTE =>
				case ALU_s(1 downto 0) is
				when "00" => 
					MemWriteData_s(31 downto 8) <= (others => 'X');
					MemWriteData_s(7 downto 0) <= rs2_data_s(7 downto 0);
					MemWrite_s(0) <= MemWrite_i;
					MemWrite_s(3 downto 1) <= (others => WE_0);
				when "01" => 
					MemWriteData_s(31 downto 16) <= (others => 'X');
					MemWriteData_s(15 downto 8) <= rs2_data_s(7 downto 0);
					MemWriteData_s(7 downto 0) <= (others => 'X');
					MemWrite_s(0) <= WE_0;
					MemWrite_s(1) <= MemWrite_i;
					MemWrite_s(3 downto 2) <= (others => WE_0);
				when "10" => 
					MemWriteData_s(31 downto 24) <= (others => 'X');
					MemWriteData_s(23 downto 16) <= rs2_data_s(7 downto 0);
					MemWriteData_s(15 downto 0) <= (others => 'X');
					MemWrite_s(1 downto 0) <= (others => WE_0);
					MemWrite_s(2) <= MemWrite_i;
					MemWrite_s(3) <= WE_0;
				when "11" => 
					MemWriteData_s(31 downto 24) <= rs2_data_s(7 downto 0);
					MemWriteData_s(23 downto 0) <= (others => 'X');
					MemWrite_s(2 downto 0) <= (others => WE_0);
					MemWrite_s(3) <= MemWrite_i;
				when others => 
					assert false report "Store address is not defined properly. Write on the lowest byte by default" severity warning;
					MemWriteData_s(31 downto 8) <= (others => 'X');		-- NB: Default is to write the RS2 lowest byte at the lowest address 
					MemWriteData_s(7 downto 0) <= rs2_data_s(7 downto 0);
					MemWrite_s(0) <= MemWrite_i;
					MemWrite_s(3 downto 1) <= (others => WE_0);
				end case;
			when RV32I_FUNCT3_LS_HALFWORD =>
				if (ALU_s(1) = '1') then -- NB: we considered the memory aligned on 32 bits so the half word can only be written on the lowest part or the highest part of the word
					MemWriteData_s(31 downto 16) <= rs2_data_s(15 downto 0);
					MemWriteData_s(15 downto 0) <= (others => 'X');
					MemWrite_s(1 downto 0) <= (others => WE_0);
					MemWrite_s(3 downto 2) <= (others => MemWrite_i);
				else 
					MemWriteData_s(31 downto 16) <= (others => 'X');	-- NB: Default is to keep the lowest half word 
					MemWriteData_s(15 downto 0) <= rs2_data_s(15 downto 0);
					MemWrite_s(1 downto 0) <= (others => MemWrite_i);
					MemWrite_s(3 downto 2) <= (others => WE_0);
				end if;
			when RV32I_FUNCT3_LS_WORD => 
				MemWriteData_s <= rs2_data_s;
				MemWrite_s <= (others => MemWrite_i);
			when others =>
				MemWriteData_s <= rs2_data_s;
				MemWrite_s <= (others => MemWrite_i);
		end case;
	else
		MemWrite_s <= (others => WE_0);
		MemWriteData_s <= rs2_data_s;
	end if;
  end process;

  -- NB : use only RAM of ?Ko (i.e. 2^20 32-bit words) 
  data_mem : sync_mem
    generic map (
	data_size => 8,
	data_granularity => 4,
	n => 20,
	filename => ram_init_filename)
    port map (
      clk_i    => clk_i,
      resetn_i => resetn_i,
      we_i     => MemWrite_s,
      re_i     => MemRead_i,
      d_i      => MemWriteData_s,
      add_i    => ALU_s(21 downto 2),
      d_o      => MemReadData_s);

  UExceptionManagement : RV32I_Exception
  port map(
			resetb_i => resetn_i,
			clock_i => clk_i,
			iaddress_i => pc_counter_s,
			unknown_instr_i => unknown_instr_i,
			exception_cause_o => mcause_o,
			exception_address_o => tval_o,
			exception_o => exception_o);

  -- NB : Periph Write
  PeriphAddr_o<=ALU_s;
  PeriphData_o<=rs2_data_s;
  PeriphWe_o<=MemWrite_i when not(ALU_s(31 downto 22)=MemAddrUp) else '0';

end architecture RV32I_Monocycle_datapath_architecture;
