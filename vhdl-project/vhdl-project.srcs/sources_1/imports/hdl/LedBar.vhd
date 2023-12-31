
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

----------------------------------------------------------------------------------
-- Entity
---------------------------------------------------------------------------------- 
entity LedBar is
   generic(
      C_SYS_CLK_FREQ_MHZ  : integer := 100; -- system clock frequency in MHz
      C_SECONDS_TO_RECORD : integer := 5 -- number of seconds to record
   );
   port(
      clk_i  : in  std_logic; -- system clock
      en_i   : in  std_logic; -- enable
      rnl_i  : in  std_logic; -- shift Right/Left
      leds_o : out std_logic_vector(15 downto 0) -- output LEDs
   );
end LedBar;

----------------------------------------------------------------------------------
-- Architecture
---------------------------------------------------------------------------------- 
architecture Behavioral of LedBar is

------------------------------------------------------------------------
-- Constants
------------------------------------------------------------------------
constant CLK_DIV_RATIO : integer := (((C_SECONDS_TO_RECORD * C_SYS_CLK_FREQ_MHZ * 1000000)/16) - 1);

------------------------------------------------------------------------
-- Signals
------------------------------------------------------------------------
-- Clock divider counter
signal cnt_clk : integer := 0;
signal clk_div : std_logic;
--Shift register to hold the Led data
signal tmp_sig : std_logic_vector(15 downto 0) := (others => '0');

------------------------------------------------------------------------
-- Begin
------------------------------------------------------------------------
begin

   -- shift register
   SHFT: process(clk_i)
   begin
      if rising_edge(clk_i) then
         if en_i = '1' then
            if clk_div = '1' then
            
               -- shift left
               if rnl_i = '0' then
                  tmp_sig <= tmp_sig(14 downto 0) & '1';
                  
               -- shift right
               else 
                  tmp_sig <= '1' & tmp_sig(15 downto 1);
               end if;
            end if;
         else
            tmp_sig <= (others => '0');
         end if;
      end if;
   end process SHFT;
   
   leds_o <= tmp_sig;

   -- Generate shift clock
   CLK_CNT: process(clk_i)
   begin
      if rising_edge(clk_i) then
         if en_i = '0' or cnt_clk = CLK_DIV_RATIO then
            cnt_clk <= 0;
            clk_div <= '1';
         else
            cnt_clk <= cnt_clk + 1;
            clk_div <= '0';
         end if;
      end if;
   end process CLK_CNT;

end Behavioral;

