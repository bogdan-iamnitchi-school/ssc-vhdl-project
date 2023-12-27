
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

----------------------------------------------------------------------------------
-- Entity
----------------------------------------------------------------------------------  
entity sSegCtrl is
   port(
      clk_i : in std_logic;
      rstn_i : in std_logic;
      msg : in std_logic_vector(1 downto 0);
      seg_o : out std_logic_vector(7 downto 0);
      an_o  : out std_logic_vector(7 downto 0)
   );
end sSegCtrl;



architecture Behavioral of sSegCtrl is

----------------------------------------------------------------------------------
-- Components
----------------------------------------------------------------------------------  
component sSegDisplay is
    port(
        ck       : in  std_logic;                     -- 100Mhz system clock
        number   : in  std_logic_vector(63 downto 0); -- eght digit hex data to be displayed, active-low
        seg      : out std_logic_vector(7 downto 0);  -- display cathodes
        an       : out std_logic_vector(7 downto 0)   -- display anodes active-low
    ); 
end component;


----------------------------------------------------------------------------------
-- Signals
---------------------------------------------------------------------------------- 
-- dispVal represents the pattern to be displayed
signal dispVal : std_logic_vector(63 downto 0);


----------------------------------------------------------------------------------
-- Begin
---------------------------------------------------------------------------------- 
begin

   ----------------------------------------------------------------------------------
   -- Seven-Segment display multiplexer
   ----------------------------------------------------------------------------------
   Disp: sSegDisplay
   port map(
      ck       => clk_i,
      number   => dispVal, -- 64-bit
      seg      => seg_o,
      an       => an_o
   );
   
   with msg select
      dispVal <=  x"88" & x"86" & x"C6" & x"BF" & x"BF" & x"C0" & x"AB" & x"FF" when "01", -- Rec On
                  x"8C" & x"C7" & x"88" & x"99" & x"83" & x"88" & x"C6" & x"89" when "10", -- playback
                  x"8C" & x"88" & x"86" & x"92" & x"FF" & x"83" & x"C1" & x"FF" when others; -- Pres BU

end Behavioral;

