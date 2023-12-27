
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

----------------------------------------------------------------------------------
-- Entity
----------------------------------------------------------------------------------  
entity Main is
   port(
      clk_i          : in  std_logic;
      rstn_i         : in  std_logic;
      -- push-buttons
      btnl_i         : in  std_logic;
      btnc_i         : in  std_logic;
      btnr_i         : in  std_logic;
      btnd_i         : in  std_logic;
      btnu_i         : in  std_logic;
      -- switches
      sw_i           : in  std_logic_vector(15 downto 0);
      -- 7-segment display
      disp_seg_o     : out std_logic_vector(7 downto 0);
      disp_an_o      : out std_logic_vector(7 downto 0);
      -- leds
      led_o          : out std_logic_vector(15 downto 0);
      -- PDM microphone
      pdm_clk_o      : out std_logic;
      pdm_data_i     : in  std_logic;
      pdm_lrsel_o    : out std_logic;
      -- PWM audio
      pwm_audio_o    : inout std_logic;
      pwm_sdaudio_o  : out std_logic;
      
      -- DDR2 interface signals
      ddr2_addr      : out   std_logic_vector(12 downto 0);
      ddr2_ba        : out   std_logic_vector(2 downto 0);
      ddr2_ras_n     : out   std_logic;
      ddr2_cas_n     : out   std_logic;
      ddr2_we_n      : out   std_logic;
      ddr2_ck_p      : out   std_logic_vector(0 downto 0);
      ddr2_ck_n      : out   std_logic_vector(0 downto 0);
      ddr2_cke       : out   std_logic_vector(0 downto 0);
      ddr2_cs_n      : out   std_logic_vector(0 downto 0);
      ddr2_dm        : out   std_logic_vector(1 downto 0);
      ddr2_odt       : out   std_logic_vector(0 downto 0);
      ddr2_dq        : inout std_logic_vector(15 downto 0);
      ddr2_dqs_p     : inout std_logic_vector(1 downto 0);
      ddr2_dqs_n     : inout std_logic_vector(1 downto 0);
      
      -- TX_Bluetooth
      tx_pmodbt : out std_logic

   );
end Main;


----------------------------------------------------------------------------------
-- Architecture
----------------------------------------------------------------------------------  
architecture Behavioral of Main is

----------------------------------------------------------------------------------
-- Components
----------------------------------------------------------------------------------  
-- 200 MHz Clock Generator
component ClkGen
port (
    -- Clock in ports
    clk_100MHz_i           : in     std_logic;
    -- Clock out ports
    clk_100MHz_o          : out    std_logic;
    clk_200MHz_o          : out    std_logic;
    -- Status and control signals
    reset_i             : in     std_logic;
    locked_o            : out    std_logic
 );
end component;

component AudioCtrl is
   port (
      -- Common
      clk_i                : in    std_logic;
      clk_200_i            : in    std_logic;
      rst_i                : in    std_logic;

      -- Buttons    
      btn_u                : in    std_logic;
      btn_d                : in    std_logic;
      btn_c                : in    std_logic;
      
      -- Leds
      leds_o               : out   std_logic_vector(15 downto 0);
      
      -- 7-segment display
      disp_seg_o     : out std_logic_vector(7 downto 0);
      disp_an_o      : out std_logic_vector(7 downto 0);
      
      -- Microphone PDM signals
      pdm_m_clk_o    : out   std_logic; -- Output M_CLK signal to the microphone
      pdm_m_data_i   : in    std_logic; -- Input PDM data from the microphone
      pdm_lrsel_o    : out   std_logic; -- Set to '0' -> data is read on the positive edge
      
      -- Audio output signals
      pwm_audio_o    : inout   std_logic; -- Output Audio data to the onboard lowpass filters
      pwm_sdaudio_o  : out   std_logic; -- Output Audio enable

      -- DDR2 interface
      ddr2_addr            : out   std_logic_vector(12 downto 0);
      ddr2_ba              : out   std_logic_vector(2 downto 0);
      ddr2_ras_n           : out   std_logic;
      ddr2_cas_n           : out   std_logic;
      ddr2_we_n            : out   std_logic;
      ddr2_ck_p            : out   std_logic_vector(0 downto 0);
      ddr2_ck_n            : out   std_logic_vector(0 downto 0);
      ddr2_cke             : out   std_logic_vector(0 downto 0);
      ddr2_cs_n            : out   std_logic_vector(0 downto 0);
      ddr2_dm              : out   std_logic_vector(1 downto 0);
      ddr2_odt             : out   std_logic_vector(0 downto 0);
      ddr2_dq              : inout std_logic_vector(15 downto 0);
      ddr2_dqs_p           : inout std_logic_vector(1 downto 0);
      ddr2_dqs_n           : inout std_logic_vector(1 downto 0);
      
      -- TX_Bluetooth
      tx_pmodbt : out std_logic

);
end component;

----------------------------------------------------------------------------------
-- Signals
----------------------------------------------------------------------------------  
-- Inverted reset signal
signal rst        : std_logic;
-- Reset signal conditioned by the PLL lock
signal reset      : std_logic;
signal resetn     : std_logic;
signal locked     : std_logic;

-- 100 MHz buffered clock signal
signal clk_100MHz_buf : std_logic;
-- 200 MHz buffered clock signal
signal clk_200MHz_buf : std_logic;

-- Progressbar signal when recording
signal led_audio  : std_logic_vector(15 downto 0);

-- pdm_clk and pdm_clk_rising are needed by the VGA controller
-- to display incoming microphone data
signal pdm_clk : std_logic;

----------------------------------------------------------------------------------
-- Begin
----------------------------------------------------------------------------------  
begin
   
   -- Assign LEDs
   led_o <= sw_i when (led_audio = X"0000") else led_audio;

   -- rst on nexys4 is active-low,
   -- we make an active-high reset for other use
   rst <= not rstn_i;

   -- Assign reset signals conditioned by the PLL lock
   reset <= rst or (not locked);
   -- active-low version of the reset signal
   resetn <= not reset;


   -- Assign pdm_clk output
   pdm_clk_o <= pdm_clk;


   ----------------------------------------------------------------------------------
   -- 200MHz Clock Generator
   ----------------------------------------------------------------------------------
   Inst_ClkGen: ClkGen
   port map (
      clk_100MHz_i   => clk_i,
      clk_100MHz_o   => clk_100MHz_buf,
      clk_200MHz_o   => clk_200MHz_buf,
      reset_i        => rst,
      locked_o       => locked
      );
    
   ----------------------------------------------------------------------------------
   -- Audio Demo
   ----------------------------------------------------------------------------------
   Inst_Audio: AudioCtrl
   port map(
      clk_i          => clk_100MHz_buf,
      clk_200_i      => clk_200MHz_buf,
      rst_i          => reset,
      btn_u          => btnu_i,
      btn_d          => btnd_i,
      btn_c          => btnc_i,
      leds_o         => led_audio,
      
      disp_seg_o     => disp_seg_o,
      disp_an_o      => disp_an_o,
      
      pdm_m_clk_o    => pdm_clk,
      pdm_m_data_i   => pdm_data_i,
      pdm_lrsel_o    => pdm_lrsel_o,
      pwm_audio_o    => pwm_audio_o,
      pwm_sdaudio_o  => pwm_sdaudio_o,

      -- DDR2 signals
      ddr2_dq        => ddr2_dq,
      ddr2_dqs_p     => ddr2_dqs_p,
      ddr2_dqs_n     => ddr2_dqs_n,
      ddr2_addr      => ddr2_addr,
      ddr2_ba        => ddr2_ba,
      ddr2_ras_n     => ddr2_ras_n,
      ddr2_cas_n     => ddr2_cas_n,
      ddr2_we_n      => ddr2_we_n,
      ddr2_ck_p      => ddr2_ck_p,
      ddr2_ck_n      => ddr2_ck_n,
      ddr2_cke       => ddr2_cke,
      ddr2_cs_n      => ddr2_cs_n,
      ddr2_dm        => ddr2_dm,
      ddr2_odt       => ddr2_odt,
      
      -- TX_Bluetooth
      tx_pmodbt      => tx_pmodbt
   );


end Behavioral;

