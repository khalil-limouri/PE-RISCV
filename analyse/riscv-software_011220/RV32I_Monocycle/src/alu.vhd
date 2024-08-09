-------------------------------------------------------------------------------
-- Title      : DLX ALU
-- Project    : 
-------------------------------------------------------------------------------
-- File       : DLX_alu.vhd
-- Author     :   <michel agoyan@ROU13572>
-- Company    : 
-- Created    : 2015-11-24
-- Last update: 2015-11-27
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
-- 2015-11-24  1.0      michel agoyan   Created
-- 2019-08-22  1.1      Olivier potin   Add SLTU to be compatible with RISCV operation
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library rtl_core;
use rtl_core.RV32I_constants.all;


entity alu is
  generic(
    width : positive := 32);
  port (
    func_i : in  std_logic_vector(3 downto 0);
    op1_i  : in  std_logic_vector(width -1 downto 0);
    op2_i  : in  std_logic_vector(width -1 downto 0);
    d_o    : out std_logic_vector(width -1 downto 0);
    zero_o : out std_logic;
    lt_o   : out std_logic;
    ltu_o  : out std_logic);

end entity alu;

architecture alu_arch of alu is
  constant x1 : std_logic_vector(width downto 0) := 33x"1";
  signal d_s : std_logic_vector(width downto 0);

begin  -- architecture alu_arch
-- purpose: alu core operations
-- type   : combinational
-- inputs : func_i,op1_i,op2_i
-- outputs: d_o,zero_o,lt_o
  alu_comb_proc : process (func_i, op1_i, op2_i) is
  begin  -- process alu_comb_proc
    case func_i is
      when ALU_ADD =>
        d_s <= std_logic_vector(resize(signed(op1_i),33) + resize(signed(op2_i),33));
      when ALU_SUB =>
        d_s <= std_logic_vector(resize(signed(op1_i),33) - resize(signed(op2_i),33));
      when ALU_AND =>
        d_s <= '0' & (op1_i and op2_i);
      when ALU_OR =>
        d_s <= '0' & (op1_i or op2_i);
      when ALU_XOR =>
        d_s <= '0' & (op1_i xor op2_i);
      when ALU_SLT =>
        if (resize(signed(op1_i),33) < resize(signed(op2_i),33)) then
          d_s <= x1;
        else
          d_s <= (others => '0');
        end if;
      when ALU_SLTU =>
        if (resize(unsigned(op1_i),33) < resize(unsigned(op2_i),33)) then
          d_s <= x1;
        else
          d_s <= (others => '0');
        end if;
      when ALU_SLLV =>
          d_s <= std_logic_vector(resize(shift_left(unsigned(op1_i), to_integer(unsigned(op2_i(4 downto 0)))),33));
      when ALU_SRAV =>
          d_s <= std_logic_vector(resize(shift_right(signed(op1_i), to_integer(unsigned(op2_i(4 downto 0)))),33));
      when ALU_SRLV =>
          d_s <= std_logic_vector(resize(shift_right(unsigned(op1_i), to_integer(unsigned(op2_i(4 downto 0)))),33));
      when ALU_COPY_RS1 =>
        d_s <= '0' & op1_i;
      when others =>
        d_s <= (others => '0');
    end case;
  end process alu_comb_proc;

-- purpose: flags zero and less_than
-- type   : combinational
-- inputs : d_s
-- outputs: zero_o,lt_o
  alu_flags_comb_proc : process (d_s) is
  begin  -- process alu_flags_comb_proc
    if is_X(d_s) then
      zero_o <= 'X';
    elsif unsigned(d_s) = 0 then
      zero_o <= '1';
    else
      zero_o <= '0';
    end if;

    if is_X(d_s) then
      lt_o <= 'X';
    elsif signed(d_s) < 0 then
      lt_o <= '1';
    else
      lt_o <= '0';
    end if;

    if (is_X(op1_i) or is_X(op2_i)) then
      ltu_o <= 'X';
    elsif unsigned(op1_i) < unsigned(op2_i) then
      ltu_o <= '1';
    else
      ltu_o <= '0';
    end if;
  end process alu_flags_comb_proc;

  d_o <= d_s(31 downto 0);

end architecture alu_arch;

