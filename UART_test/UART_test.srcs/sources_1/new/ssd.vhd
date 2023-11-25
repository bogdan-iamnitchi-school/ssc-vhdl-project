----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/01/2020 01:11:50 PM
-- Design Name: 
-- Module Name: displ7seg - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ssd is
      Port ( Clk  : in  STD_LOGIC;
          Rst  : in  STD_LOGIC;
          Data : in  STD_LOGIC_VECTOR (31 downto 0); 
                 -- date de afisat (cifra 1 din stanga: biti 31..28)
          An   : out STD_LOGIC_VECTOR (7 downto 0); 
                 -- semnale pentru anozi (active in 0 logic)
          Seg  : out STD_LOGIC_VECTOR (7 downto 0)); 
                 -- semnale pentru segmentele (catozii) cifrei active
end ssd;

architecture Behavioral of ssd is

constant CLK_RATE  : INTEGER := 100_000_000;  -- frecventa semnalului Clk
constant CNT_100HZ : INTEGER := 2**20;        -- divizor pentru rata de
                                              -- reimprospatare de ~100 Hz
signal Count       : INTEGER range 0 to CNT_100HZ - 1 := 0;
signal CountVect   : STD_LOGIC_VECTOR (19 downto 0) := (others => '0');
signal LedSel      : STD_LOGIC_VECTOR (2 downto 0) := (others => '0');
signal tmp         : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');
signal Digit1      : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');
signal Digit2      : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');
signal Digit3      : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');
signal Digit4      : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');
signal Digit5      : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');
signal Digit6      : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');
signal Digit7      : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');
signal Digit8      : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');

begin
   -- Proces pentru divizarea frecventei ceasului
   div_clk: process (Clk)
   begin
      if RISING_EDGE (Clk) then
         if (Rst = '1') then
            Count <= 0;
         elsif (Count = CNT_100HZ - 1) then
            Count <= 0;
         else
            Count <= Count + 1;
         end if;
      end if;
   end process div_clk;

   CountVect <= CONV_STD_LOGIC_VECTOR (Count, 20);
   LedSel <= CountVect (19 downto 17);
   
    -- Date pentru segmentele fiecarei cifre
   Digit8 <= Data (3 downto 0);
   Digit7 <= Data (7 downto 4);
   Digit6 <= Data (11 downto 8);
   Digit5 <= Data (15 downto 12);
   Digit4 <= Data (19 downto 16);
   Digit3 <= Data (23 downto 20);
   Digit2 <= Data (27 downto 24);
   Digit1 <= Data (31 downto 28);
   
   sel_cifra:process(LedSel,Data,tmp)
   begin
        case LedSel is
            when "000"=>tmp<=Digit8;
            when "001"=>tmp<=Digit7;
            when "010"=>tmp<=Digit6;
            when "011"=>tmp<=Digit5;
            when "100"=>tmp<=Digit4;
            when "101"=>tmp<=Digit3;
            when "110"=>tmp<=Digit2;
            when others=>tmp<=Digit1;
        end case;
   end process;



   -- Semnal pentru selectarea cifrei active (anozi)
   An <= "11111110" when LedSel = "000" else
         "11111101" when LedSel = "001" else
         "11111011" when LedSel = "010" else
         "11110111" when LedSel = "011" else
         "11101111" when LedSel = "100" else
         "11011111" when LedSel = "101" else
         "10111111" when LedSel = "110" else
         "01111111" when LedSel = "111" else
         "11111111";

   -- Semnal pentru segmentele cifrei active (catozi)
   process(tmp)
   begin
        case tmp is
          when "0000" => Seg <= "11000000";  -- 0
          when "0001" => Seg <= "11111001";  -- 1
          when "0010" => Seg <= "10100100";  -- 2
          when "0011" => Seg <= "10110000";  -- 3
          when "0100" => Seg <= "10011001";  -- 4
          when "0101" => Seg <= "10010010";  -- 5
          when "0110" => Seg <= "10000010";  -- 6
          when "0111" => Seg <= "11111000";  -- 7
          when "1000" => Seg <= "10000000";  -- 8
          when "1001" => Seg <= "10010000";  -- 9
          when "1010" => Seg <= "10001000";  -- A
          when "1011" => Seg <= "10000011";  -- b
          when "1100" => Seg <= "11000110";  -- C
          when "1101" => Seg <= "10100001";  -- d
          when "1110" => Seg <= "10000110";  -- E
          when "1111" => Seg <= "10001110";  -- F
          when others => Seg <= "11111111";
         end case;
     end process;

end architecture;