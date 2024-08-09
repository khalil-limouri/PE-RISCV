-------------------------------------------------------------------------------
-- Title      : mux_comp
-- Project    :
-------------------------------------------------------------------------------
-- File       : mux_comp.vhd
-- Author     : michel agoyan  <michel.agoyan@st.com>
-- Company    :
-- Created    : 2015-11-15
-- Last update: 2015-11-25
-- Platform   :
-- Standard   : VHDL'2008
-------------------------------------------------------------------------------
-- Description:  mux  with parametrable width
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

entity mux_comp is
  generic (
    width : positive := 32;             -- width of one of the nb ports
    n     : positive := 5);             -- nb of input ports = 2^n

  port (
    data_i : in  std_logic_vector(width*(2**n)-1 downto 0);
    sel_i  : in  std_logic_vector(n-1 downto 0);
    data_o : out std_logic_vector(width-1 downto 0));

end entity mux_comp;

architecture mux_comp_arch of mux_comp is
begin  -- architecture mux_comp_arch
  data_o <= data_i(width*To_integer(unsigned(sel_i)+1) - 1 downto width*(To_integer(unsigned(sel_i)+1)-1));
end architecture mux_comp_arch;
