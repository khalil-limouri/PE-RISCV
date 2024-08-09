-------------------------------------------------------------------------------
-- Title      : RV32I_TraceEncoder
-- Project    : RISCV EC_SAS
-------------------------------------------------------------------------------
-- File       : RV32I_TraceEncoder.vhd
-- Author     : <olivier.potin@emse.fr>
-- Company    : Mines Saint-Etienne
-- Created    : 2020-03-26
-- Last update: 
-- Platform   : 
-- Standard   : VHDL'2008
-------------------------------------------------------------------------------
-- Description:  Trace encoder for the 32bit RISCV developped in EC-SAS department
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

library rtl_core;
use rtl_core.RV32I_constants.all;

library rtl_tracer;
use rtl_tracer.RV32I_TraceEncoder_constants.all;

entity RV32I_TraceEncoder is
    generic (TLEN : POSITIVE);
--                CONTEXT_WIDTH_P : POSITIVE;         -- optional 
--                CTYPE_WIDTH_P : POSITIVE := 1;
--                IRETIRE_WIDTH_P : POSITIVE := 2;    -- The number of half-word instructions that are being retired
--                ILASTSIZE_WIDTH_P : POSITIVE);      -- optional
                   
    port (  clock_i : in std_logic;
            resetb_i : in std_logic;
            enable_i : in std_logic;
            exception_i : in std_logic; -- an exception occurs
-- not supported            interrupt_i : in std_logic; -- an interruption occurs
            iaddr_i : in std_logic_vector(IADDRESS_WIDTH_P-1 downto 0);   -- next instruction address
            instr_i : in std_logic_vector(INSTR_WIDTH_P-1 downto 0);        -- current instruction
            ecause_i : in std_logic_vector(MCAUSE_WIDTH_P-1 downto 0);
            tval_i : in std_logic_vector(IADDRESS_WIDTH_P-1 downto 0);
            priv_i : in std_logic_vector(PRIVILEGE_WIDTH_P-1 downto 0);   -- fixed as user privilege for us
--            context_i : in std_logic_vector(CONTEXT_WIDTH_P-1 downto 0);
--            ctype_i : in std_logic_vector(CTYPE_WIDTH_P-1 downto 0);
--            iretire_i : in std_logic_vector(IRETIRE_WIDTH_P-1 downto 0);
--            ilastsize_i : in std_logic_vector(ILASTSIZE_WIDTH_P-1 downto 0);
            trace_o : out std_logic_vector((TLEN*8)-1 downto 0);
            trace_length_o : out NATURAL range 0 to (TLEN-1);
	        trace_emitted_o : out std_logic);
end entity;

architecture RV32I_TraceEncoder_architecture of RV32I_TraceEncoder is
-- TBD
-- constant MAX_RESYNC : POSITIVE := 10000;
type state is ( init, treated );
signal present_state_s : state;
signal future_state_s : state;
signal first_qualified_treated_s : std_logic;
-- component declaration
component RV32I_BranchMap is
    port (  resetb_i : in std_logic;
            clock_i : in std_logic;
            branch_taken_i : in std_logic;
            update_map_i : in std_logic;
            flush_map_i : in std_logic;
            map_o : out std_logic_vector(31 downto 0);
            map_count_o : out NATURAL range 0 to 31;
            map_empty_o : out std_logic;
            map_full_o : out std_logic);
end component;
component RV32I_SendTrace is
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
end component;
-- signal declaration
signal previous_iaddr_s : std_logic_vector(IADDRESS_WIDTH_P-1 downto 0); -- last instruction addess
signal trace_iaddr_s : std_logic_vector(IADDRESS_WIDTH_P-1 downto 0); -- current instruction addess
signal next_iaddr_s : std_logic_vector(IADDRESS_WIDTH_P-1 downto 0); -- next instruction addess
signal previous_instr_s : std_logic_vector(INSTR_WIDTH_P-1 downto 0);    -- last instruction
signal trace_instr_s : std_logic_vector(INSTR_WIDTH_P-1 downto 0);    -- current instruction
signal next_instr_s : std_logic_vector(INSTR_WIDTH_P-1 downto 0);    -- next instruction
signal previous_exception_s : std_logic; -- last exception
signal trace_exception_s : std_logic; -- current exception
signal next_exception_s : std_logic; -- next exception
signal previous_qualified_s : std_logic;
signal trace_qualified_s : std_logic;
signal next_qualified_s : std_logic;
signal first_qualified_s : std_logic;
signal trace_privilege_s : std_logic_vector(PRIVILEGE_WIDTH_P-1 downto 0);
signal next_privilege_s : std_logic_vector(PRIVILEGE_WIDTH_P-1 downto 0);
signal trace_exception_cause_s : std_logic_vector(MCAUSE_WIDTH_P-1 downto 0);
signal next_exception_cause_s : std_logic_vector(MCAUSE_WIDTH_P-1 downto 0);
signal trace_trap_value_s : std_logic_vector(IADDRESS_WIDTH_P-1 downto 0);
signal next_trap_value_s : std_logic_vector(IADDRESS_WIDTH_P-1 downto 0);
signal previous_discontinuity_s : std_logic;
signal trace_discontinuity_s : std_logic;
-- signal discontinuity_s : std_logic;
signal previous_itype_s : std_logic_vector(3 downto 0);  -- see table 3.1 of riscv-trace-spec.pdf
signal trace_itype_s : std_logic_vector(3 downto 0);  -- see table 3.1 of riscv-trace-spec.pdf
signal trace_sijump_s : std_logic;
signal trace_branch_s : std_logic;
signal trace_branch_taken_s : std_logic;
signal update_branch_map_s : std_logic;
signal e_ccd_s : std_logic;
signal er_ccdn_s : std_logic;
signal exc_only_s : std_logic;
-- not supported : signal ppch_br_s : std_logic;
-- signal resync_count_s : NATURAL range 0 to MAX_RESYNC;
-- signal resync_br_s : std_logic;
signal packet_enable_s : std_logic;
signal map_s : std_logic_vector(31 downto 0);
signal map_count_s : NATURAL range 0 to 31;
signal map_empty_s : std_logic;
signal map_full_s : std_logic;
signal map_flush_s : std_logic;
signal trace_format_s : Format_e;
signal trace_subformat_s : SubFormat_e;
signal trace_emitted_s : std_logic;
signal trace_length_s : NATURAL range 0 to TLEN*8;
-- architecture body declaration
begin
    U0: RV32I_BranchMap
    port map (
        resetb_i => resetb_i,
        clock_i => clock_i,
        branch_taken_i => trace_branch_taken_s,
        update_map_i => update_branch_map_s,
        flush_map_i => map_flush_s,
        map_o => map_s,
        map_count_o => map_count_s,
        map_empty_o => map_empty_s,
        map_full_o => map_full_s);
    
    U1: RV32I_SendTrace
    generic map (
        PACKET_SIZE_MAX => TLEN*8,
	full_address => true)
    port map (  
	    resetb_i => resetb_i,    
        enable_i => enable_i,
        clock_i => clock_i,
        valid_i => packet_enable_s,
        format_i => trace_format_s,
        subformat_i => trace_subformat_s,
        branch_was_taken_i => trace_branch_taken_s,
        branch_map_count_i => map_count_s,
        branch_map_full_i => map_full_s,
        branch_map_i => map_s,
        privilege_level_i => trace_privilege_s,
        iaddr_i => trace_iaddr_s,
        ecause_i => trace_exception_cause_s,
        tval_i => trace_trap_value_s,
        interrupt_i => '0', -- currently not supported
        packet_o => trace_o,
        packet_len_o => trace_length_s,
        packet_valid_o => trace_emitted_s);

    next_iaddr_s <= iaddr_i;
    next_instr_s <= instr_i;
    next_exception_s <= exception_i;
    next_privilege_s <= priv_i;
    next_exception_cause_s <= ecause_i;
    next_trap_value_s <= tval_i;

    PStore : process(resetb_i, enable_i, clock_i, next_instr_s, next_iaddr_s, next_exception_s, next_qualified_s, trace_iaddr_s, trace_instr_s, trace_exception_s, trace_qualified_s, trace_discontinuity_s, trace_itype_s, next_privilege_s, next_exception_cause_s, next_trap_value_s)
    begin
        if (resetb_i = '0') then
            previous_iaddr_s <= (others => '0');
            trace_iaddr_s <= (others => '0');
            previous_instr_s <= (others => '0');
            trace_instr_s <= (others => '0');
            previous_exception_s <= '0';
            trace_exception_s <= '0';
            previous_qualified_s <= '0';
            trace_qualified_s <= '0';
            previous_discontinuity_s <= '0';
            -- trace_discontinuity_s <= '0';
            previous_itype_s <= (others => '0');
            trace_privilege_s <= (others  => '0');
        elsif (clock_i'event and clock_i = '1') then
            if (enable_i = '1') then
                previous_iaddr_s <= trace_iaddr_s;
                trace_iaddr_s <= next_iaddr_s;
                previous_instr_s <= trace_instr_s;
                trace_instr_s <= next_instr_s;
                previous_exception_s <= trace_exception_s;
                trace_exception_s <= next_exception_s;
                previous_qualified_s <= trace_qualified_s;
                trace_qualified_s <= next_qualified_s;
                previous_discontinuity_s <= trace_discontinuity_s;
                -- trace_discontinuity_s <= discontinuity_s;
                previous_itype_s <= trace_itype_s;
                trace_privilege_s <= next_privilege_s;
                trace_exception_cause_s <= next_exception_cause_s;
                trace_trap_value_s <= next_trap_value_s;
            end if;
        end if;
    end process PStore;

    -- Is the instruction being retired ?
    PQualified: process(enable_i, next_instr_s)
    begin
        if (enable_i = '1') then
            if ((next_instr_s(6 downto 0) = RV32I_I_INSTR_SYSTEM)
              or (next_instr_s(6 downto 0) = RV32I_B_INSTR)
              or (next_instr_s(6 downto 0) = RV32I_J_INSTR)
              or (next_instr_s(6 downto 0) = RV32I_I_INSTR_JALR)) then
		        next_qualified_s <= '1';
-- ??? or (exception_i = '1')
-- not supported                or (interrupt_i  = '1') 
            else 
                next_qualified_s <= '0';
            end if;
        else
            next_qualified_s <= '0';
        end if;
    end process PQualified;

    PFirstqualified: process(resetb_i, previous_qualified_s, trace_qualified_s)
    begin
        first_qualified_s <= not previous_qualified_s and trace_qualified_s and not first_qualified_treated_s ;
    end process PFirstqualified;

    PFSM_clocked : process(resetb_i, clock_i, future_state_s)
    begin
        if (resetb_i = '0') then
            present_state_s <= init;
        elsif (clock_i'event and clock_i = '1') then
            present_state_s <= future_state_s;
        end if;
    end process PFSM_clocked;

    PFSM_comb : process(present_state_s, enable_i, first_qualified_s, e_ccd_s, packet_enable_s)
    begin
        case present_state_s is
            when init =>
                first_qualified_treated_s <= '0';
                if (enable_i = '1' and e_ccd_s = '0' and first_qualified_s = '1' and packet_enable_s = '1') then
                    future_state_s <= treated;
                else
                    future_state_s <= init;
                end if;
            when treated =>
                    first_qualified_treated_s <= '1';
                    future_state_s <= treated;
            when others =>
        end case;
    end process PFSM_comb;

    PDiscontinuity : process(trace_iaddr_s, next_iaddr_s)
    variable PCNext_v : NATURAL;
    begin
        PCNext_v := to_integer(unsigned(trace_iaddr_s)) + 4;
        if (not (PCNext_v = to_integer(unsigned(next_iaddr_s)))) then
            trace_discontinuity_s <= '1';
        else 
            trace_discontinuity_s <= '0';
        end if;
    end process PDiscontinuity;

    -- Define retired instruction type
    PType:process(trace_exception_s, trace_qualified_s, trace_instr_s, trace_discontinuity_s, previous_instr_s)
    begin
        if (trace_exception_s = '1') then
            trace_itype_s <= EXCEPTION_TYPE;
-- not supported            elsif (interrupt_i = '1') then
-- not supported                trace_itype_s <= INTERRUPT_TYPE;
        elsif (trace_qualified_s = '1') then
            -- return from exception or interrupt ?
            -- instruction uret
            -- opcode : SYSTEM, rd = X0, rs = X0 and [21:20] = "10" ?
            if ((trace_instr_s(6 downto 0) = RV32I_I_INSTR_SYSTEM) 
                and (trace_instr_s(11 downto 7) = X0) 
                and (trace_instr_s(19 downto 15) = X0) 
                and (trace_instr_s(21 downto 20) = "10")) then
                    trace_itype_s <= RETURN_EXINT;
            elsif (trace_instr_s(6 downto 0) = RV32I_B_INSTR) then
                -- taken or not taken ?
                if (trace_discontinuity_s = '0') then
                    trace_itype_s <= NOTTAKEN_TYPE;
                elsif (trace_discontinuity_s = '1') then
                    trace_itype_s <= TAKEN_TYPE;
                end if;
            elsif (trace_instr_s(6 downto 0) = RV32I_J_INSTR) then
                -- JAL X1 or JAL X5 ?
                if ((trace_instr_s(11 downto 7) = X1) 
                    or (trace_instr_s(11 downto 7) = X5)) then
                    trace_itype_s <= INFERABLE_CALL;
                -- JAL X0 ?
                elsif (trace_instr_s(11 downto 7) = X0) then
                    trace_itype_s <= INFERABLE_TAILCALL;
                -- JAL rd where rd != x1 and rd != x5 ?
                else
                    trace_itype_s <= INFERABLE_OTHERJUMP;
                end if;
            elsif (trace_instr_s(6 downto 0) = RV32I_I_INSTR_JALR) then
                -- JALR x1, rs where rs != x5 or JALR x5, rs where rs != x1 ?
                if (((trace_instr_s(11 downto 7) = X1) and (trace_instr_s(19 downto 15) /= X5)) 
                    or ((trace_instr_s(11 downto 7) = X5) and (trace_instr_s(19 downto 15) /= X1))) then
                    trace_itype_s <= UNINFERABLE_CALL;
                -- JALR x0, rs where rs != x5 and rs != x1 ?
                elsif ((trace_instr_s(11 downto 7) = X0) 
                    and (trace_instr_s(19 downto 15) /= X5) 
                    and (trace_instr_s(19 downto 15) /= X1)) then
                    trace_itype_s <= UNINFERABLE_TAILCALL;
                -- JALR rd, rs where (rs == x5 or rs == x1) and rd != x1 and rd != x5 ?
                elsif (((trace_instr_s(19 downto 15) = X1) or (trace_instr_s(19 downto 15) = X5)) 
                    and ((trace_instr_s(11 downto 7) /= X5) 
                    and (trace_instr_s(11 downto 7) /= X1))) then
                    trace_itype_s <= UNINFERABLE_RETURNS;
                -- JALR x1, x5 or JALR x5, x1 ?
                elsif (((trace_instr_s(11 downto 7) = X1) and (trace_instr_s(19 downto 15) = X5)) 
                        or ((trace_instr_s(11 downto 7) = X5) and (trace_instr_s(19 downto 15) = X1))) then
                    trace_itype_s <= UNINFERABLE_SWAP;
                -- JALR rd, rs where (rs!=x1 and rs!=x5 and rd!=x0 and rd!=x1 and rd!=x5)
                else
                    trace_itype_s <= UNINFERABLE_OTHERJUMP;
                end if;
                -- uninferable jump can become inferable if the previous instruction permits to know immediate value
                if ((previous_instr_s(6 downto 0) = RV32I_U_INSTR_AUIPC) or (previous_instr_s(6 downto 0) = RV32I_U_INSTR_LUI)) then
                    trace_sijump_s <= '1';
                else
                    trace_sijump_s <= '0';
                end if;
            else
                trace_itype_s <= NO_TYPE;
            end if;
        else 
            trace_itype_s <= NO_TYPE;
        end if;
    end process PType;

    -- Is branch ?
    PBranch: process(trace_itype_s)
    begin
        trace_branch_s <= '0'; 
        if (trace_itype_s = TAKEN_TYPE) then
            trace_branch_s <= '1';
            trace_branch_taken_s <= '1';
        else
            trace_branch_taken_s <= '0';
            if (trace_itype_s = NOTTAKEN_TYPE) then
                trace_branch_s <= '1';
            end if;
        end if;
    end process PBranch;

    Pe_ccd : process(trace_discontinuity_s, trace_exception_s, previous_exception_s)
    begin
        -- exception changes with discontinuity
        -- context change not supported
        e_ccd_s <= trace_discontinuity_s and (not previous_exception_s and trace_exception_s);
    end process Pe_ccd;


--    Presync_br: process(resync_count_s, map_empty_s)
--    begin
        -- resync count = MAX and branch map not empty
--        if ((resync_count_s = MAX_RESYNC) and (map_empty_s = '0')) then
--            resync_br_s <= '1';
--        else
--            resync_br_s <= '0';
--        end if;
--    end process Presync_br;

    Per_ccdn: process(trace_exception_s, trace_qualified_s)
    begin
        -- simultaneous exception and retirement 
        -- not supported : or context change with discontinuity or notify
        er_ccdn_s <= (trace_exception_s and trace_qualified_s) ;
    end process Per_ccdn;

    Pexc_only: process(next_exception_s, next_qualified_s)
    begin
        exc_only_s <= next_exception_s and not next_qualified_s;
    end process Pexc_only;

    -- TODO : rpt_br_s process use in case of branch prediction

    -- TODO : cci as imprecise context change 

    -- Delta trace algorithm detailed in RISCV trace specification Figure 6.1
    PAlgorithm : process(resetb_i, enable_i, trace_qualified_s, trace_branch_s, e_ccd_s, first_qualified_s, previous_itype_s, previous_discontinuity_s, map_empty_s, er_ccdn_s, exc_only_s, next_qualified_s)
    variable packettosend_v : std_logic; 
    variable updatebranch_v : std_logic;
    begin
		packettosend_v := '0';
		updatebranch_v := '0';
		if (enable_i = '1') then
		    if (trace_qualified_s = '1') then
		        if (trace_branch_s = '1') then
		            -- Update branch map
			    updatebranch_v := '1';
		        end if;
		        -- discontinuity and context or exception change ?
		        if (e_ccd_s = '1') then
		            -- Send trace with Format3 and subformat 1
		            trace_format_s <= F_3;
		            trace_subformat_s <= SF_1;
		            packettosend_v := '1';
--		            resync_count_s <= 0;
		        else
		            -- first qualified, ppch or >max_resync ?
		            -- ppch is not supported
		            if (first_qualified_s = '1') then
		                -- send trace with Format3 and subformat 0
		                trace_format_s <= F_3;
		                trace_subformat_s <= SF_0;
		                packettosend_v := '1';
--		                resync_count_s <= 0;
		            else
		                -- previous inst was updiscon ?
		                if (((previous_itype_s =  UNINFERABLE_CALL) 
		                    or (previous_itype_s = UNINFERABLE_TAILCALL) 
		                    or (previous_itype_s = UNINFERABLE_SWAP)
		                    or (previous_itype_s = UNINFERABLE_RETURNS)
		                    or (previous_itype_s = UNINFERABLE_OTHERJUMP)) and (previous_discontinuity_s = '1')) then
		                        -- send trace with Format0/1/2
		                        -- F2 : address report
		                        -- F1 : branch report
		                        if ((map_empty_s = '1') and (updatebranch_v = '0')) then
		                            trace_format_s <= F_2;
		                        else
		                            trace_format_s <= F_1;
		                        end if;
		                        trace_subformat_s <= SF_X;
		                        packettosend_v := '1';
		                else
		                    -- er_ccdn 
				    -- not supported : or resync_br ?
		                    if (er_ccdn_s = '1') then
		                        -- send trace with Format0/1/2
		                        -- F2 : address report
		                        -- F1 : branch report
		                        if ((map_empty_s = '1') and (updatebranch_v = '0')) then
		                            trace_format_s <= F_2;
		                        else
		                            trace_format_s <= F_1;
		                        end if;
		                        trace_subformat_s <= SF_X;
		                        packettosend_v := '1';
		                    else
		                        -- Next inst is exc_only or unqualified ?
		                        -- not supported : ppch_br
		                        if ((exc_only_s = '1') or (next_qualified_s = '0')) then
		                                -- send trace with Format0/1/2
		                                -- F2 : address report
		                                -- F1 : branch report
		                                if ((map_empty_s = '1') and (updatebranch_v = '0')) then
		                                    trace_format_s <= F_2;
		                                else
		                                    trace_format_s <= F_1;
		                                end if;
		                                trace_subformat_s <= SF_X;
		                                packettosend_v := '1';
		                        end if;
		                        -- TODO: following algorithm is not supported
		                        -- TODO: rpt_br ? send trace with Format0 if pbc >= 31 ou format1 if pbc < 31
		                        -- TODO: cci ? send trace with Format3 subformat 2
		                    end if;
		                end if;
		            end if;
		        end if;
		    end if;
		end if;
		packet_enable_s <= packettosend_v;
		update_branch_map_s <= updatebranch_v;
    end process PAlgorithm;

    PFlushBranchMap : process(resetb_i, clock_i, enable_i, trace_emitted_s)
    begin
        if (resetb_i = '0') then
            map_flush_s <= '0';
        elsif (clock_i'event and clock_i = '1') then
            if (enable_i = '1') then
                if (trace_emitted_s = '1') then -- and (trace_format_s = F_1)) then -- as soon as a packet was emitted and it concerns a branch report, we can flush the branch map
                    map_flush_s <= '1';
                else
                    map_flush_s <= '0';
                end if;
            else
                map_flush_s <= '0';
            end if;
        end if;
    end process;

    trace_emitted_o <= trace_emitted_s ;
    trace_length_o <= trace_length_s / 8 when trace_length_s mod 8 = 0 else trace_length_s / 8 + 1;

end architecture RV32I_TraceEncoder_architecture;
