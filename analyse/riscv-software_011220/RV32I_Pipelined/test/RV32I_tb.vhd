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

entity RV32I_tb is
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
    
begin  -- architecture RV32I_tb_arch

  RV32I_top_1: entity work.RV32I_Pipelined_top
    port map (
      clk_i    => clk_s,
      resetn_i => resetn_s);
  
  -- clock generation
  clk_s <= not clk_s after HALF_PERIOD;

 
 tb : process
  begin

    -- reset the design
    resetn_s <= '0';
    wait_negedge(3, clk_s);
    resetn_s <= '1';
    wait_negedge(12,clk_s);
    --end of the tb
    assert false report "end of simulation" severity error;
  end process tb;
    
end architecture RV32I_tb_arch;
