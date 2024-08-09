-------------------------------------------------------------------------------
-- Title      : RV32I testbench
-- Project    : 
-------------------------------------------------------------------------------
-- File       : RV32I_tb.vhd
-- Author     :   <michel agoyan@ROU13572>
-- Company    : 
-- Created    : 2015-11-25
-- Last update: 2015-11-26
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-- 
-------------------------------------------------------------------------------
-- Copyright (c) 2015 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2015-11-25  1.0      michel agoyan	Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.RV32I_components.all;
library std;
use std.textio.all;

-- for spy_controlflow
library modelsim_lib;
use modelsim_lib.util.all;


entity RV32I_tb is

  generic (
    rom_init_filename: string:="rom.hex";
    ram_init_filename: string:="";
    stdout_filename:   string:="";    -- @0xFFFF0000
    signature_filename:   string:=""; -- @0xFFFF0004
    trace_encoder_filename: string:="";
    max_cycles: integer:=0;
    trace_filename: string:="";
    verbose: integer:=2 -- 0 -> reported notes: none
                        -- 1 -> reported notes: stdout
                        -- 2 -> reported notes: stdout + signature
                        -- 3 -> reported notes: stdout + signature + trace
  );

end entity RV32I_tb;

architecture RV32I_tb_arch of RV32I_tb is
  constant PERIOD : time := 20 ns;
  constant HALF_PERIOD : time := 10 ns;
  
  procedure wait_negedge (
    constant nb  : in positive;         -- number of negative clk edge
    signal clk_i : in std_logic) is
  begin
    for i in 1 to nb loop
      wait until clk_i'event and clk_i = '0';
    end loop;  -- i
  end procedure wait_negedge;
  
  signal clk_s    : std_logic := '0';
  signal resetn_s : std_logic := '0';

  signal cycle: integer;

  signal PeriphAddr_s : std_logic_vector(31 downto 0); -- Periph address
  signal PeriphData_s : std_logic_vector(31 downto 0); -- Periph word
  signal PeriphWe_s   : std_logic; -- set when Periph word is valid

  type regs_file_t is array (0 to 31) of std_logic_vector(31 downto 0 );
  
  -- alias regs_file_a is << signal RV32I_tb.RV32I_top_1.RV32I_datapath_1.register_file_1.regs_file_s  : regs_file_t >> ;
  
  signal ir: std_logic_vector(32-1 downto 0);
  signal pc: std_logic_vector(32-1 downto 0);

  -- trace encoder signals
  constant TLEN : POSITIVE := 13;
  signal enable_tracer_s : std_logic := '0';
  signal trace_s : std_logic_vector((TLEN*8)-1 downto 0);
  signal trace_length_s : NATURAL range 0 to (TLEN-1);
  signal trace_emitted_s : std_logic;
  
begin  -- architecture RV32I_tb_arch

  RV32I_top_1: entity work.RV32I_Monocycle_top
    generic map (
      rom_init_filename => rom_init_filename,
      ram_init_filename => ram_init_filename,
      TLEN => TLEN
    ) port map (
      clk_i    => clk_s,
      resetn_i => resetn_s,
      enable_tracer_i => enable_tracer_s,
      trace_o	=> trace_s,	 
      trace_length_o => trace_length_s,
      trace_emitted_o => trace_emitted_s,
      PeriphAddr_o => PeriphAddr_s,
      PeriphData_o => PeriphData_s,
      PeriphWe_o => PeriphWe_s);
  
  -- clock generation
  clk_s <= not clk_s after HALF_PERIOD;

 reset : process
  begin
    -- reset the design
    resetn_s <= '0';
    wait_negedge(3, clk_s);
    resetn_s <= '1';
    wait; -- wait forever
  end process reset;

  cycles: process
  begin
    cycle<=0;
    while 1=1 loop
      wait on clk_s until clk_s='1' and resetn_s='1';
      if max_cycles>0 then
        if cycle>=max_cycles then
          assert false report "end of simulation: timeout (max cycles happen before main return, cycle: " & Integer'Image(cycle) & ")" severity failure;
        end if;
      end if;
      cycle<=cycle+1;
    end loop;
  end process cycles;

  main_return: process
    variable returncode_line: line;
    variable returncode_string: string(1 to 8);
  begin
    wait on clk_s until clk_s='1' and resetn_s='1' and PeriphWe_s='1' and PeriphAddr_s=x"FFFFFFF0";
    hwrite(returncode_line,PeriphData_s,right,8);
    read(returncode_line,returncode_string);
    if PeriphData_s=x"00000000" then
      assert false report "end of simulation: success (return value: 0x" & returncode_string & ", cycle: " & Integer'Image(cycle) & ")" severity failure;
    else
      assert false report "end of simulation: failure (return value: 0x" & returncode_string & ", cycle: " & Integer'Image(cycle) & ")" severity failure;
    end if;
  end process main_return;

  stdout: process
    file     stdout_fd: text;
    variable stdout_line: line;
    variable stdout_string: string(1 to 8);
  begin
    if stdout_filename'Length>0 then
      file_open(stdout_fd,stdout_filename,WRITE_MODE);
      report "open stdout file: " & stdout_filename;
    end if;

    while 1=1 loop
      wait on clk_s until clk_s='1' and resetn_s='1' and PeriphWe_s='1' and PeriphAddr_s=x"FFFF0000";
      if verbose>=1 then
        hwrite(stdout_line,PeriphData_s,right,8);
        read(stdout_line,stdout_string);
        report "stdout: " & stdout_string severity note;
      end if;
      if stdout_filename'Length>0 then
        hwrite(stdout_line,PeriphData_s,right,8);
        writeline(stdout_fd,stdout_line);
      end if;
    end loop;
  end process stdout;

  signature: process
    file     signature_fd: text;
    variable signature_line: line;
    variable signature_string: string(1 to 8);
  begin
    if signature_filename'Length>0 then
      file_open(signature_fd,signature_filename,WRITE_MODE);
      report "open signature file: " & signature_filename;
    end if;

    while 1=1 loop
      wait on clk_s until clk_s='1' and resetn_s='1' and PeriphWe_s='1' and PeriphAddr_s=x"FFFF0004";
      if verbose>=2 then
        hwrite(signature_line,PeriphData_s,right,8);
        read(signature_line,signature_string);
        report "signature: " & signature_string severity note;
      end if;
      if signature_filename'Length>0 then
        hwrite(signature_line,PeriphData_s,right,8);
        writeline(signature_fd,signature_line);
      end if;
    end loop;
  end process signature;

  spy_controlflow: process
    file     trace_fd: text;
    variable trace_line: line;
    variable trace_string: string(1 to 3+8+4+8);
    variable pc_line: line;
    variable pc_string: string(1 to 8);
    variable ir_line: line;
    variable ir_string: string(1 to 8);
  begin
    if trace_filename'Length>0 then
      file_open(trace_fd,trace_filename,WRITE_MODE);
      report "open trace file: " & trace_filename;
    end if;
    init_signal_spy("/rv32i_tb/RV32I_top_1/RV32I_Monocycle_datapath_1/pc_counter_s","pc");
    init_signal_spy("/rv32i_tb/RV32I_top_1/RV32I_Monocycle_datapath_1/instruction_s","ir");
    while 1=1 loop
      wait on clk_s until clk_s='1' and resetn_s='1';
      hwrite(pc_line,pc,right,8);
      read(pc_line,pc_string);
      hwrite(ir_line,ir,right,8);
      read(ir_line,ir_string);
      trace_string:="@0x" & pc_string & ": 0x" & ir_string;
      if verbose>=3 then
        report "instruction: " & trace_string severity note;
      end if;
      if trace_filename'Length>0 then
        write(trace_line,trace_string,right,trace_string'Length);
        writeline(trace_fd,trace_line);
      end if;
    end loop;
  end process;

  PEnabletracer : process
  begin
	if trace_encoder_filename'length>0 then
		enable_tracer_s <= '1';
	else
		enable_tracer_s <= '0';
	end if;
	-- wait end of simulation 
	wait on clk_s until clk_s='1' and resetn_s='1' and PeriphWe_s='1' and PeriphAddr_s=x"FFFFFFF0"; 
	enable_tracer_s <= '0';
	wait;
  end process;

  PFiletrace : process
  file handle : text;
  variable trace_line : line;
  begin
	if (trace_encoder_filename'length>0) then
		file_open(handle, trace_encoder_filename, WRITE_MODE);
		report "open trace instruction encoder file : " & trace_encoder_filename;
	end if;
	while 1=1 loop
		wait on clk_s until clk_s='1' and resetn_s='1';
		if (enable_tracer_s = '1') then
		    if (trace_emitted_s = '1') then
			  hwrite(trace_line, trace_s((trace_length_s*8)-1 downto 0));
			  writeline(handle, trace_line);
		    end if;
	        end if;
	end loop;
  end process;


end architecture RV32I_tb_arch;
