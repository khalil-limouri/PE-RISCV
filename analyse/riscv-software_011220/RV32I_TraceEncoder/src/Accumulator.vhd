-------------------------------------------------------------------------------
-- Title      : Accumulator
-- Project    : RISCV EC_SAS
-------------------------------------------------------------------------------
-- File       : Accumulator.vhd
-- Author     : <olivier.potin@emse.fr>
-- Company    : Mines Saint-Etienne
-- Created    : 2020-03-26
-- Last update: 
-- Platform   : 
-- Standard   : VHDL'2008
-------------------------------------------------------------------------------
-- Description:  Accumulator component
-------------------------------------------------------------------------------
-- Copyright (c) 2020
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2020-03-26  1.0      Olivier Potin   Created
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Accumulator is
    generic (WIDTH_P : POSITIVE := 5);
    port (  clock_i : in std_logic;
            resetb_i : in std_logic;
            enable_i : in std_logic;
            value_o : out std_logic_vector(WIDTH_P-1 downto 0));
end entity Accumulator;

architecture Accumulator_arch of Accumulator is
signal value_s: NATURAL range 0 to 2**WIDTH_P-1;
begin    
    P0: process(clock_i, resetb_i, enable_i)
    begin
        if (resetb_i = '0') then
            value_s <= 0;
        elsif (clock_i'event and clock_i = '1') then
            if (enable_i = '1') then
                value_s <= value_s + 1;
            else
                value_s <= value_s;
            end if;
        end if;
    end process P0;

    value_o <= std_logic_vector(to_unsigned(value_s, WIDTH_P));
end architecture Accumulator_arch;

