-------------------------------------------------------------------------------
-- Title      : RV32I_BranchMap
-- Project    : RISCV EC_SAS
-------------------------------------------------------------------------------
-- File       : RV32I_BranchMap.vhd
-- Author     : <olivier.potin@emse.fr>
-- Company    : Mines Saint-Etienne
-- Created    : 2020-03-26
-- Last update: 
-- Platform   : 
-- Standard   : VHDL'2008
-------------------------------------------------------------------------------
-- Description:  Branch mapping management
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

entity RV32I_BranchMap is
    port (  resetb_i : in std_logic;
            clock_i : in std_logic;
            branch_taken_i : in std_logic;
            update_map_i : in std_logic;
            flush_map_i : in std_logic;
            map_o : out std_logic_vector(31 downto 0);
            map_count_o : out NATURAL range 0 to 31;
            map_empty_o : out std_logic;
            map_full_o : out std_logic);
end entity;

architecture RV32I_BranchMap_arch of RV32I_BranchMap is
signal map_count_s : NATURAL range 0 to 31;
signal map_s : std_logic_vector(31 downto 0);
signal next_map_count_s : NATURAL range 0 to 31;
signal next_map_s : std_logic_vector(31 downto 0);
begin

    PCount : process(update_map_i, map_s, map_count_s, branch_taken_i)
    begin
	if (update_map_i = '1') then
		next_map_s(map_count_s) <= not branch_taken_i;
		next_map_count_s <= map_count_s + 1;
	else
		next_map_s <= map_s;
		next_map_count_s <= map_count_s;
	end if;
    end process PCount;

    map_count_o <= next_map_count_s;
    map_empty_o <= '1' when map_count_s = 0 else '0';
    map_full_o <= '1' when map_count_s = 31 else '0';
    map_o <= next_map_s;

    PUpdateMap : process(resetb_i, clock_i, flush_map_i, next_map_count_s, next_map_s)
    begin
        if ((resetb_i = '0') or (flush_map_i = '1')) then
            map_s <= (others => '0');
	    map_count_s <= 0;
        elsif (clock_i'event and clock_i = '1') then
		map_count_s <= next_map_count_s;
		map_s <= next_map_s;
        end if;
    end process PUpdateMap;

end RV32I_BranchMap_arch;
