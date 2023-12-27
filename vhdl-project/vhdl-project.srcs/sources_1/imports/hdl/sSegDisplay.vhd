
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

----------------------------------------------------------------------------------
-- Entity
----------------------------------------------------------------------------------  
entity sSegDisplay is
    port(
        ck : in  std_logic;                          -- 100MHz system clock
        number : in  std_logic_vector (63 downto 0); -- eight digit number to be displayed
        seg : out  std_logic_vector (7 downto 0);    -- display cathodes
        an : out  std_logic_vector (7 downto 0)      -- display anodes (active-low, due to transistor complementing)
    );    
end sSegDisplay;

----------------------------------------------------------------------------------
-- Architecture                                                                       
----------------------------------------------------------------------------------
architecture Behavioral of sSegDisplay is

--signals
signal cnt: std_logic_vector(19 downto 0); -- divider counter
signal hex: std_logic_vector(7 downto 0);  -- hexadecimal digit
signal intAn: std_logic_vector(7 downto 0); -- internal signal representing anode data

begin

   -- Assign outputs
   an <= intAn;
   seg <= hex;

   clockDivider: process(ck)
   begin
      if ck'event and ck = '1' then
         cnt <= cnt + '1';
      end if;
   end process clockDivider;

   -- Anode Select
   with cnt(19 downto 17) select -- 100MHz/2^20 = 95.3Hz
      intAn <=    
         "11111110" when "000",
         "11111101" when "001",
         "11111011" when "010",
         "11110111" when "011",
         "11101111" when "100",
         "11011111" when "101",
         "10111111" when "110",
         "01111111" when others;

   -- Digit Select
   with cnt(19 downto 17) select -- 100MHz/2^20 = 95.3Hz
      hex <=      
         number(7 downto 0)   when "000",
         number(15 downto 8)  when "001",
         number(23 downto 16) when "010",
         number(31 downto 24) when "011",
         number(39 downto 32) when "100",
         number(47 downto 40) when "101",
         number(55 downto 48) when "110",
         number(63 downto 56) when others;

end Behavioral;