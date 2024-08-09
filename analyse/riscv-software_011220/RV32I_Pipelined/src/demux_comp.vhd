-------------------------------------------------------------------------------
-- Title      : demux_comp
-- Project    :
-------------------------------------------------------------------------------
-- File       : demux_comp.vhd
-- Author     : michel agoyan  <michel.agoyan@st.com>
-- Company    :
-- Created    : 2015-11-15
-- Last update: 2015-11-25
-- Platform   :
-- Standard   : VHDL'2008
-------------------------------------------------------------------------------
-- Description: demux with parametrable width
-------------------------------------------------------------------------------
-- Copyright (c) 2015
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2015-11-15  1.0      magoyan Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity demux_comp is

  generic (
    width : positive := 1;              -- width of the input port
    n     : positive := 5);             -- nb of output ports = 2

  port (
    data_i : in  std_logic_vector(width-1 downto 0);
    sel_i  : in  std_logic_vector(n-1 downto 0);
    data_o : out std_logic_vector(width*(2**n)-1 downto 0));
end entity demux_comp;

architecture demux_comp_arch of demux_comp is

begin  -- architecture demux_comp_arch


  demux_comb_proc : process (sel_i, data_i)
  begin
    data_o                                                                                         <= (others => '0');
    data_o(width*To_integer(unsigned(sel_i)+1) - 1 downto width*(To_integer(unsigned(sel_i)+1)-1)) <= data_i;
  end process;

end architecture demux_comp_arch;
