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
use work.RV32I_constants.all;


entity alu is
  generic(
    width : positive := 32);
  port (
    func_i : in  std_logic_vector(3 downto 0);
    op1_i  : in  std_logic_vector(width -1 downto 0);
    op2_i  : in  std_logic_vector(width -1 downto 0);
    d_o    : out std_logic_vector(width -1 downto 0);
    zero_o : out std_logic;
    lt_o   : out std_logic);

end entity alu;

architecture alu_arch of alu is

  signal d_s : std_logic_vector(width -1 downto 0);

begin  -- architecture alu_arch
-- purpose: alu core operations
-- type   : combinational
-- inputs : func_i,op1_i,op2_i
-- outputs: d_o,zero_o,lt_o
  alu_comb_proc : process (func_i, op1_i, op2_i) is
  begin  -- process alu_comb_proc
    case func_i is
      when ALU_ADD =>
        d_s <= std_logic_vector(signed(op1_i) + signed(op2_i));
      when ALU_SUB =>
        d_s <= std_logic_vector(signed(op1_i) - signed(op2_i));
      when ALU_AND =>
        d_s <= op1_i and op2_i;
      when ALU_OR =>
        d_s <= op1_i or op2_i;
      when ALU_XOR =>
        d_s <= op1_i xor op2_i;
      when ALU_SLT =>
        if (signed(op1_i) < signed(op2_i)) then
          d_s <= X"0000_0001";
        else
          d_s <= (others => '0');
        end if;
      when ALU_SLTU =>
        if (unsigned(op1_i) < unsigned(op2_i)) then
          d_s <= X"0000_0001";
        else
          d_s <= (others => '0');
        end if;
      when ALU_SLLV =>
        d_s <= op1_i sll to_integer(unsigned(op2_i));
      when ALU_SRAV =>
        d_s <= std_logic_vector(signed(op1_i) sra to_integer(unsigned(op2_i)));
      when ALU_SRLV =>
        d_s <= op1_i srl to_integer(unsigned(op2_i));
      when ALU_COPY_RS1 =>
        d_s <= op1_i;
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
    if unsigned(d_s) = 0 then
      zero_o <= '1';
    else
      zero_o <= '0';
    end if;

    if signed(d_s) < 0 then
      lt_o <= '1';
    else
      lt_o <= '0';
    end if;
  end process alu_flags_comb_proc;

  d_o <= d_s;

end architecture alu_arch;
