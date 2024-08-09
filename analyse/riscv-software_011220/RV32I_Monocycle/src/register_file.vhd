-------------------------------------------------------------------------------
-- Title      : register file
-- Project    :
-------------------------------------------------------------------------------
-- File       : file_register.vhd
-- Author     : michel agoyan  <michel.agoyan@st.com>
-- Company    :
-- Created    : 2015-11-15
-- Last update: 2015-11-26
-- Platform   :
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
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

entity register_file is

  generic (
    width : positive := 32;             --  width of the registers
    n     : positive := 5);             -- number of registers=2^n

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

end entity register_file;




architecture register_file_arch of register_file is

  type regs_file_t is array (0 to (2**n)-1) of std_logic_vector(width-1 downto 0 );
  signal regs_file_s : regs_file_t;

  signal rd_add_nox:  std_logic_vector(n-1 downto 0);
  signal rs1_add_nox: std_logic_vector(n-1 downto 0):=(others=>'0');
  signal rs2_add_nox: std_logic_vector(n-1 downto 0):=(others=>'0');

begin  -- architecture register_file_arch

  rd_add_nox<=(others=>'0') when is_X(rd_add_i) else
              rd_add_i;
  rs1_add_nox<=(others=>'0') when is_X(rs1_add_i) else
               rs1_add_i;
  rs2_add_nox<=(others=>'0') when is_X(rs2_add_i) else
               rs2_add_i;

  -- purpose: behavior description of a reg file
  -- type   : sequential
  -- inputs : clk_i, resetn_i
  -- outputs: 
  regs_file_proc : process (clk_i, resetn_i) is
  begin  -- process regs_file_proc
    if resetn_i = '0' then                  -- asynchronous reset (active low)
     regs_file_s <= (others => (others => '0'));
    elsif clk_i'event and clk_i = '1' then  -- rising clock edge
      if we_i = '1' then
        regs_file_s(To_integer(unsigned(rd_add_nox))) <= rd_data_i;
      end if;
    end if;
  end process regs_file_proc;


  rs1_data_o <=   (others => '0') when rs1_add_nox = (rs1_add_nox'range => '0')  else
                  regs_file_s(to_integer(unsigned(rs1_add_nox)));

  rs2_data_o <=   (others => '0') when rs2_add_nox = (rs2_add_nox'range => '0')  else
                  regs_file_s(to_integer(unsigned(rs2_add_nox)));
 

end architecture register_file_arch;
