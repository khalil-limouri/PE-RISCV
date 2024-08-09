library IEEE;
use IEEE.std_logic_1164.all;

package RV32I_TraceEncoder_constants is
    -- used register address
    constant X0: std_logic_vector(4 downto 0) := (others => '0');
    constant X1: std_logic_vector(4 downto 0) := "00001";
    constant X5: std_logic_vector(4 downto 0) := "00101";

    -- itype definitions
    constant NO_TYPE: std_logic_vector(3 downto 0) := (others => '0');
    constant EXCEPTION_TYPE: std_logic_vector(3 downto 0) := "0001";
    constant INTERRUPT_TYPE: std_logic_vector(3 downto 0) := "0010";
    constant RETURN_EXINT : std_logic_vector(3 downto 0) := "0011";
    constant NOTTAKEN_TYPE: std_logic_vector(3 downto 0) := "0100";
    constant TAKEN_TYPE: std_logic_vector(3 downto 0) := "0101";
    constant UNINFERABLE_CALL: std_logic_vector(3 downto 0) := "1000";
    constant INFERABLE_CALL: std_logic_vector(3 downto 0) := "1001";
    constant UNINFERABLE_TAILCALL: std_logic_vector(3 downto 0) := "1010";
    constant INFERABLE_TAILCALL: std_logic_vector(3 downto 0) := "1011";
    constant UNINFERABLE_SWAP: std_logic_vector(3 downto 0) := "1100";
    constant UNINFERABLE_RETURNS: std_logic_vector(3 downto 0) := "1101";
    constant UNINFERABLE_OTHERJUMP: std_logic_vector(3 downto 0) := "1110";
    constant INFERABLE_OTHERJUMP: std_logic_vector(3 downto 0) := "1111";

    -- FORMAT definition
    type Format_e is (F_0, F_1, F_2, F_3, F_X);
    type Subformat_e is (SF_0, SF_1, SF_2, SF_3, SF_X);
    
    -- 
    constant UNDEFINED_INSTRUCTION: std_logic_vector(31 downto 0) := (others => 'U');

end package;
