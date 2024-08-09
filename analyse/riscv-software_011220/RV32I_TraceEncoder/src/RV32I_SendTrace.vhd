-------------------------------------------------------------------------------
-- Title      : RV32I_SendTrace
-- Project    : RISCV EC_SAS
-------------------------------------------------------------------------------
-- File       : RV32I_SendTrace.vhd
-- Author     : <olivier.potin@emse.fr>
-- Company    : Mines Saint-Etienne
-- Created    : 2020-03-26
-- Last update: 
-- Platform   : 
-- Standard   : VHDL'2008
-------------------------------------------------------------------------------
-- Description:  Send trace to a file
-------------------------------------------------------------------------------
-- Copyright (c) 2020
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2020-03-30  1.0      Olivier Potin   Created
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library rtl_core;
use rtl_core.RV32I_constants.all;

library rtl_tracer;
use rtl_tracer.RV32I_TraceEncoder_constants.all;

entity RV32I_SendTrace is
    generic (   PACKET_SIZE_MAX : POSITIVE;
		full_address : boolean := false);
    port (      resetb_i : in std_logic;
		enable_i : in std_logic;
                clock_i : in std_logic;
                valid_i : in std_logic;
                format_i : in format_e;
                subformat_i : in subformat_e;
                branch_was_taken_i : in std_logic;
                branch_map_count_i : in NATURAL range 0 to 31;
                branch_map_full_i : in std_logic;
                branch_map_i : in std_logic_vector(31 downto 0);
                privilege_level_i : in std_logic_vector(PRIVILEGE_WIDTH_P-1 downto 0);
                iaddr_i : in std_logic_vector(IADDRESS_WIDTH_P-1 downto 0);
                ecause_i : in std_logic_vector(MCAUSE_WIDTH_P-1 downto 0);
                tval_i : in std_logic_vector(IADDRESS_WIDTH_P-1 downto 0);
                interrupt_i : in std_logic;
                packet_o : out std_logic_vector(PACKET_SIZE_MAX-1 downto 0);
                packet_len_o : out NATURAL range 0 to PACKET_SIZE_MAX;
                packet_valid_o : out std_logic);
end entity RV32I_SendTrace;

architecture RV32I_SendTrace_arch of RV32I_SendTrace is
signal branch_map_s : NATURAL range 0 to 31;
signal previous_iaddr_s : std_logic_vector(IADDRESS_WIDTH_P-1 downto 0);
begin
    --  compute the number of valid branches
    PBranches : process(branch_map_full_i, branch_map_count_i)
    begin
        if (branch_map_full_i = '1') then
            branch_map_s <= 0;
        else
            if (branch_map_count_i < 2) then
                branch_map_s <= 1;
            elsif (branch_map_count_i < 4) then
                branch_map_s <= 3;
            elsif (branch_map_count_i < 8) then
                branch_map_s <= 7;
            elsif (branch_map_count_i < 16) then
                branch_map_s <= 15;
            else
                branch_map_s <= 31;
            end if;
        end if;            
    end process PBranches;

    PTraceEncode : process(clock_i, enable_i, valid_i, format_i, subformat_i, iaddr_i, privilege_level_i, branch_was_taken_i, tval_i, interrupt_i, ecause_i, branch_map_i, branch_map_s, previous_iaddr_s)
    variable valid_v : std_logic;
    variable len_v : NATURAL range 0 to PACKET_SIZE_MAX;
    variable message_v : std_logic_vector(PACKET_SIZE_MAX-1 downto 0);
    begin
        if (clock_i'event and clock_i = '1') then
            valid_v := '0';
            if (enable_i = '1') then
                if (valid_i = '1') then
                    message_v := (others => '0');
                    case format_i is
                        when F_3 =>
                        -- Synchronisation (Format3, Subformat0)
                        -- Exception (Format3, SubFormat1)
                            case subformat_i is
                                when SF_0 =>
                                    -- table 5.1 of specification (page 27)
                                    -- 1100 & is branch ? & privilege level && instruction address 
                                    len_v := IADDRESS_WIDTH_P + PRIVILEGE_WIDTH_P + 1 + 2 + 2;
                                    message_v(len_v-1 downto 0) := iaddr_i & privilege_level_i & (not branch_was_taken_i) & "00" & "11" ;
                                    valid_v := '1';
                                when SF_1 =>
                                    -- table 5.2 of specification (page 28)
                                    -- 1101 & is branch ? & privilege level & exception cause & interrupt & iaddr & tvalepc
                                    len_v := IADDRESS_WIDTH_P + IADDRESS_WIDTH_P + 1 + MCAUSE_WIDTH_P + PRIVILEGE_WIDTH_P + 1 + 2 + 2;
                                    message_v(len_v-1 downto 0) := tval_i & iaddr_i & interrupt_i & ecause_i & privilege_level_i & (not branch_was_taken_i) & "01" & "11" ;
                                    valid_v := '1';
                                when SF_2 =>
                                    -- TODO : context changes and can be reported imprecisely (not supported)
                                when SF_3 => 
                                    -- TODO : support for decoder or encoder error status (not supported) 
                                when others =>
                            end case;
                        when F_2 =>
                            -- Address report (Format2)
                            -- table 5.5 of the specification (page 31)
                            -- considered as full address mode by default
                            -- not supported:
                                -- notify = normally MSB(iaddr_i) if there is no trigger (see table 5.5)
                                -- updiscon = notify (except for ...)
                                -- irreport = updiscon 
    --  NOTE CFI : irreport differs from updiscon when an instruction that is following a return because its address differs from the predicted return address at the top of the implicit_return return address stack)
                            len_v := IADDRESS_WIDTH_P + 2;
                            if (not full_address) then
				message_v(len_v-1 downto 0) := std_logic_vector(unsigned(iaddr_i) - unsigned(previous_iaddr_s)) & "10" ;
			    else
				message_v(len_v-1 downto 0) := iaddr_i & "10";
			    end if;
                            valid_v := '1';
                        when F_1 =>
                            -- Branch report (Format1)
                            -- see table 5.6 of the specification (page 35)
                            -- 01 & branches & branch_map & differential address & notify & updiscon & irreport & irdepth
                            if (branch_map_s = 0) then
                                len_v := 31 + 5 + 2;
                                message_v(len_v-1 downto 0) := branch_map_i & std_logic_vector(to_unsigned(branch_map_s, 5)) & "01" ;
                            else
                                len_v := IADDRESS_WIDTH_P + branch_map_s + 5 + 2;
                                if (not full_address) then
					message_v(len_v-1 downto 0) := std_logic_vector(unsigned(iaddr_i) - unsigned(previous_iaddr_s)) 
							& branch_map_i(branch_map_s-1 downto 0) & std_logic_vector(to_unsigned(branch_map_s, 5)) & "01";
				else
					message_v(len_v-1 downto 0) := iaddr_i & branch_map_i(branch_map_s-1 downto 0) & std_logic_vector(to_unsigned(branch_map_s, 5)) & "01";
				end if;
                            end if;
                            valid_v := '1';
                        when others =>
                        -- not supported : Optional efficiency -> Branch prediction report, cache... (Format0)
                    end case;
                end if;
            end if;
        end if;
	packet_valid_o <= valid_v;
	packet_len_o <= len_v;
	packet_o <= message_v;
    end process PTraceEncode;

    PPreviousiaddr : process(resetb_i, enable_i, clock_i, valid_i, iaddr_i, previous_iaddr_s)
    begin
        if (resetb_i = '0') then
            previous_iaddr_s <= (others => '0');
        elsif (clock_i'event and clock_i = '1') then
            if (enable_i = '1') then
                if (valid_i = '1') then
                    previous_iaddr_s <= iaddr_i;
                else
                    previous_iaddr_s <= previous_iaddr_s;
                end if;
            end if;
        end if;
    end process PPreviousiaddr; 
end architecture RV32I_SendTrace_arch;
