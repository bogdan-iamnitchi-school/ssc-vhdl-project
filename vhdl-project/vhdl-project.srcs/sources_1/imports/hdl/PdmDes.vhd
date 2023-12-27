
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

----------------------------------------------------------------------------------
-- Entity
---------------------------------------------------------------------------------- 
entity PdmDes is
   generic(
      C_NR_OF_BITS : integer := 16;
      C_SYS_CLK_FREQ_MHZ : integer := 100;
      C_PDM_FREQ_HZ : integer := 2000000
   );
   port(
      clk_i : in std_logic;
      en_i : in std_logic; -- Enable deserializing (during record)
      
      done_o : out std_logic; -- Signaling that 16 bits are deserialized
      data_o : out std_logic_vector(C_NR_OF_BITS - 1 downto 0); -- output deserialized data
      
      -- PDM
      pdm_m_clk_o : out std_logic; -- Output M_CLK signal to the microphone
      pdm_m_data_i : in std_logic; -- Input PDM data from the microphone
      pdm_lrsel_o : out std_logic -- Set to '0' -> data is read on the positive edge
   );
end PdmDes;



architecture Behavioral of PdmDes is

------------------------------------------------------------------------
-- Signals
------------------------------------------------------------------------
-- Divider to create pdm_m_clk_0
signal cnt_clk : integer range 0 to 127 := 0;
-- Internal pdm_m_clk_o signal
signal clk_int : std_logic := '0';

-- Piped clk_int signal to create pdm_clk_rising
signal pdm_clk_rising : std_logic;

-- Shift register to deserialize incoming microphone data
signal pdm_tmp : std_logic_vector((C_NR_OF_BITS - 1) downto 0);
-- Count the number of bits
signal cnt_bits : integer range 0 to 31 := 0;

signal en_int : std_logic;
signal done_int : std_logic;

------------------------------------------------------------------------
-- Begin
------------------------------------------------------------------------
begin

   -- with L/R Sel tied to GND => output = DATA1 (rising edge)
   pdm_lrsel_o <= '0';
   
   -- Synchronize the enable input
   SYNC: process(clk_i)
   begin
      if rising_edge(clk_i) then
         en_int <= en_i;
      end if;
   end process SYNC;

   ------------------------------------------------------------------------
   -- Deserializer
   ------------------------------------------------------------------------
   -- Sample input serial data process
   SHFT_IN: process(clk_i) 
   begin 
      if rising_edge(clk_i) then
         if pdm_clk_rising = '1' then 
            pdm_tmp <= pdm_tmp(C_NR_OF_BITS-2 downto 0) & pdm_m_data_i;
         end if; 
      end if;
   end process SHFT_IN;
   
   -- Count the number of sampled bits
   CNT: process(clk_i) begin
      if rising_edge(clk_i) then
         if en_int = '0' then
            cnt_bits <= 0;
         else
            if pdm_clk_rising = '1' then
               if cnt_bits = (C_NR_OF_BITS-1) then
                  cnt_bits <= 0;
               else
                  cnt_bits <= cnt_bits + 1;
               end if;
            end if;
         end if;
      end if;
   end process CNT;

   -- Generate the done signal
   process(clk_i) 
   begin
      if rising_edge(clk_i) then
         if pdm_clk_rising = '1' then
            if cnt_bits = 0 then
               if en_int = '1' then
                  done_int <= '1';
                  data_o <= pdm_tmp;
               end if;
            end if;
         else
            done_int <= '0';
         end if;
      end if;
   end process;
   
   done_o <= done_int;

   -- Generate PDM Clock
   CLK_CNT: process(clk_i)
   begin
      if rising_edge(clk_i) then
            if cnt_clk = (((C_SYS_CLK_FREQ_MHZ*1000000)/(C_PDM_FREQ_HZ*2))-1) then
               cnt_clk <= 0;
               clk_int <= not clk_int;
               if clk_int = '0' then
                  pdm_clk_rising <= '1';
               end if;
            else
               cnt_clk <= cnt_clk + 1;
               pdm_clk_rising <= '0';
            end if;
      end if;
   end process CLK_CNT;
   
   pdm_m_clk_o <= clk_int;

end Behavioral;
