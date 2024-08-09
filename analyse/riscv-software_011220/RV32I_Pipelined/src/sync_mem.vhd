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
    width : positive := 32;             --  width of the sync_mem data bus
    n     : positive := 12;
    filename : string := "ram.hex");          --  sync_mem size
  port(
    clk_i    : in std_logic;
    resetn_i : in std_logic;

    we_i   : in  std_logic;
    re_i   : in  std_logic;
    d_i    : in  std_logic_vector(width-1 downto 0);
    add_i  : in  std_logic_vector(n-1 downto 0);
    d_o    : out std_logic_vector(width-1 downto 0));

end entity sync_mem;




architecture sync_mem_arch of sync_mem is

  type mem_t is array (0 to (2**n)-1) of std_logic_vector(width-1 downto 0);



 -- function is declared as impure to support  file reference
 impure function mem_init(filename : string) return mem_t is
    variable mem_v : mem_t;      
    variable lin_v :line;  
    variable data_v : std_logic_vector(width-1 downto 0);
    variable i_v : integer := 0;
    
    file fin:text;
 begin
   i_v :=0;       
   file_open(fin,filename,READ_MODE);

   while (i_v < 2**n  ) loop
     mem_v(i_v) := (others => '0');
     i_v :=i_v+1;
   end loop;

   report "reading the init file " & filename  ;

   i_v := 0;
   
    while(not endfile(fin) and i_v < 2**n) loop
     readline(fin,lin_v);
     hread(lin_v,data_v);
     --report "@" & integer'image(i_v) & " = " & integer'image(to_integer(unsigned(data_v))) ;
    
     mem_v(i_v) := data_v;
     i_v := i_v+1;
   end loop;   

   return mem_v;
   
  end function;

  signal mem_s : mem_t:= mem_init(filename);
  
begin  -- architecture sync_mem_arch

  -- purpose: behavior description of sync_mem
  -- type   : sequential
  -- inputs : clk_i, resetn_i
  -- outputs: 
  mem_proc : process (clk_i, resetn_i, we_i, add_i, d_i) is
  begin  -- process regs_file_proc
    if resetn_i = '0' then                  -- asynchronous reset (active low)
    -- regs_file_s <= (others => '0');
    elsif clk_i'event and clk_i = '1' then  -- rising clock edge
      if we_i = '1' then
        mem_s(To_integer(unsigned(add_i))) <= d_i;
      end if;
    end if;
  end process mem_proc;

  d_o <= (others => '0') when re_i = '0' else
         mem_s(to_integer(unsigned(add_i)));

end architecture sync_mem_arch;
