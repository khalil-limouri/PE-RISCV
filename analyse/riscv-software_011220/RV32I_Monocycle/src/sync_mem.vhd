-------------------------------------------------------------------------------
-- Title      : Synchronous memory
-- Project    :
-------------------------------------------------------------------------------
-- File       : DLX_sync_mem.vhd
-- Author     : michel agoyan  <michel.agoyan@st.com>
-- Company    :
-- Created    : 2015-11-15
-- Last update: 2015-11-25
-- Platform   :
-- Standard   : VHDL'2008
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
library std;
use std.textio.all;


entity sync_mem is

  generic (
    data_size		: positive := 8;             	-- data size which set the data width of the sync_mem data bus as data_size * data_granularity (ex: 32 bit wide = 8 bits * 4 byte)
    data_granularity	: positive := 4;		-- memory granularity 
    n			: positive := 12;		-- sync_mem size, memory size is "(2^n)*data_granularity*data_size" bits
    filename 		: string := "ram.hex");         -- memory content is set by reading file
  port(
    clk_i    : in std_logic;
    resetn_i : in std_logic;

    we_i   : in  std_logic_vector(data_granularity-1 downto 0);		-- one we for each data field
    re_i   : in  std_logic;						-- read all width bits
    d_i    : in  std_logic_vector((data_size*data_granularity)-1 downto 0);
    add_i  : in  std_logic_vector(n-1 downto 0);
    d_o    : out std_logic_vector((data_size*data_granularity)-1 downto 0));

end entity sync_mem;




architecture sync_mem_arch of sync_mem is

  type mem_t is array (0 to (2**n)-1) of std_logic_vector((data_size*data_granularity)-1 downto 0);



 -- function is declared as impure to support  file reference
 impure function mem_init(filename : string) return mem_t is
    variable mem_v : mem_t;      
    variable lin_v :line;  
    variable data_v : std_logic_vector((data_size*data_granularity)-1 downto 0);
    variable i_v : integer := 0;
    
    file fin:text;
 begin
   i_v :=0;       

   while (i_v < 2**n  ) loop
     mem_v(i_v) := (others => '0');
     i_v :=i_v+1;
   end loop;

   if filename'Length>0 then
     file_open(fin,filename,READ_MODE);
     report "reading the init file " & filename  ;

     i_v := 0;
     
      while(not endfile(fin) and i_v < 2**n) loop
       readline(fin,lin_v);
       hread(lin_v,data_v);
       --report "@" & integer'image(i_v) & " = " & integer'image(to_integer(unsigned(data_v))) ;
      
       mem_v(i_v) := data_v;
       i_v := i_v+1;
     end loop;
   end if;

   return mem_v;
   
  end function;

  signal mem_s : mem_t:= mem_init(filename);
  signal add_nox_s  : std_logic_vector(n-1 downto 0);
  
begin  -- architecture sync_mem_arch

  add_nox_s<=(others=>'0') when is_X(add_i) else
             add_i;

  -- purpose: behavior description of sync_mem
  -- type   : sequential
  -- inputs : clk_i, resetn_i
  -- outputs: 
  mem_proc : process (clk_i, resetn_i) is
  variable high_idx_v : natural;
  variable low_idx_v  : natural;
  begin  -- process regs_file_proc
    if resetn_i = '0' then                  	-- asynchronous reset (active low)
    -- regs_file_s <= (others => '0');
    elsif clk_i'event and clk_i = '1' then  	-- rising clock edge
	for i in 0 to data_granularity-1 loop	-- NB: little indian style
		high_idx_v := ((i+1)*data_size)-1;
		low_idx_v := i*data_size;
		if (we_i(i) = '1') then
			mem_s(To_integer(unsigned(add_nox_s)))(high_idx_v downto low_idx_v) <= d_i(high_idx_v downto low_idx_v);
			assert not(is_X(add_i)) report "write at unknown address" severity error;
		end if; 
	end loop;
      
--	if we_i = '1' then
--        mem_s(To_integer(unsigned(add_nox_s))) <= d_i;
--        assert not(is_X(add_i)) report "write at unknown address" severity error;
--      end if;
    end if;
  end process mem_proc;

  d_o <= (others => '0') when re_i = '0' else
         (others => 'X') when is_X(add_i) else
         mem_s(to_integer(unsigned(add_nox_s)));

end architecture sync_mem_arch;
