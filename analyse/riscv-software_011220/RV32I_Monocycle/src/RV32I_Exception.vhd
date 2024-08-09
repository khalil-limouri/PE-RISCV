-------------------------------------------------------------------------------
-- Title      : RV32I_Exception
-- Project    : 
-------------------------------------------------------------------------------
-- File       : RV32I_Exception.vhd
-- Author     : Olivier Potin
-- Company    : 
-- Created    : 2020-04-06
-- Last update: 
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: RISCV Exception management
-------------------------------------------------------------------------------
-- Copyright (c) 2020 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2020-04-06  1.0      Olivier Potin   Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library rtl_core;
use rtl_core.RV32I_constants.all;

entity RV32I_Exception is
    port (
        resetb_i : in std_logic;
        clock_i : in std_logic;
        iaddress_i : in std_logic_vector(31 downto 0);
        unknown_instr_i : in std_logic;
        exception_cause_o : out std_logic_vector(MCAUSE_WIDTH_P-1 downto 0);    -- also known as mcause register
        exception_address_o : out std_logic_vector(IADDRESS_WIDTH_P-1 downto 0);    -- also known as mtval register
        exception_o : out std_logic);
end entity RV32I_Exception;

architecture RV32I_Exception_arch of RV32I_Exception is
signal exception_s : std_logic;
begin
    exception_o <= exception_s;
    exception_s <= unknown_instr_i ; -- can be another source (hardware error, misalgn...)

    P0 : process(resetb_i, clock_i, exception_s, unknown_instr_i)
    begin
        if (resetb_i = '0') then
            exception_cause_o <= (others => '0');
            exception_address_o <= (others => '0');
        elsif (clock_i'event and clock_i = '1') then
            if (exception_s = '1') then
                exception_address_o <= iaddress_i;
                if (unknown_instr_i = '1') then
                    exception_cause_o <= std_logic_vector(to_unsigned(UNKNOWN_INSTR_EXCEPTION, MCAUSE_WIDTH_P)); -- 2
                end if;
                exception_cause_o(MCAUSE_WIDTH_P-1) <= '0'; -- exception cause / '1' in case of interrupt, not supported
            end if;
        end if;
    end process P0;

end architecture RV32I_Exception_arch;

