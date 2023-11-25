----------------------------------------------------------------------------------
----------------------------------------------------------------------------
-- Author:  Albert Fazakas adapted from Sam Bobrowicz and Mihaita Nagy
--          Copyright 2014 Digilent, Inc.
----------------------------------------------------------------------------

-- Design Name:    Nexys4 DDR User Demo
-- Module Name:    Nexys4DdrUserDemo - Behavioral 
-- Project Name: 
-- Target Devices: Nexys4 DDR Development Board, containing a XC7a100t-1 csg324 device
-- Tool versions: 
-- Description: 
-- This module represents the top - level design of the Nexys4 DDR User Demo.
-- The project connects to the VGA display in a 1280*1024 resolution and displays various
-- items on the screen:
--    - a Digilent / Analog Devices logo
--
--    - a mouse cursor, if an Usb mouse is connected to the board when the project is started
--
--    - the audio signal from the onboard ADMP421 Omnidirectional Microphone

--    - a small square representing the X and Y acceleration data from the ADXL362 onboard Accelerometer.
--      The square moves according the Nexys4 board position. Note that the X and Y axes 
--      on the board are exchanged due to the accelerometer layout on the Nexys4 board.
--      The accelerometer display also displays the acceleration magnitude, calculated as
--      SQRT( X^2 + Y^2 +Z^2), where X, Y and Z represent the acceleration value on the respective axes
--
--    - The FPGA temperature, the onboard ADT7420 temperature sensor temperature value and the accelerometer
--      temperature value
--
--    - The value of the R, G and B components sent to the RGB Leds LD16 and LD17
--
-- Other features:
--    - The 16 Switches (SW0..SW15) are connected to LD0..LD15 except when audio recording is done
--
--    - Pressing BTNL, BTNC and BTNR will toggle between Red, Green and Blue colors on LD16 and LD17
--      Color sweeping returns when BTND is pressed. BTND also togles between LD16, LD17, none or both
--
--    - Pressing BTNU will start audio recording for about 5S, then the audio data will be played back
--      on the Audio output. While recording, LD15..LD0 will show a progressbar moving to left, while
--      playing back, LD15..LD0 will show a progressbar moving to right
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Nexys4DdrUserDemo is
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
      -- RGB leds
      rgb1_red_o     : out std_logic;
      rgb1_green_o   : out std_logic;
      rgb1_blue_o    : out std_logic;
      rgb2_red_o     : out std_logic;
      rgb2_green_o   : out std_logic;
      rgb2_blue_o    : out std_logic;
      -- VGA display
      vga_hs_o       : out std_logic;
      vga_vs_o       : out std_logic;
      vga_red_o      : out std_logic_vector(3 downto 0);
      vga_blue_o     : out std_logic_vector(3 downto 0);
      vga_green_o    : out std_logic_vector(3 downto 0);
      -- PDM microphone
      pdm_clk_o      : out std_logic;
      pdm_data_i     : in  std_logic;
      pdm_lrsel_o    : out std_logic;
      -- PWM audio
      pwm_audio_o    : inout std_logic;
      pwm_sdaudio_o  : out std_logic;
		-- Temperature sensor
		tmp_scl        : inout std_logic;
		tmp_sda        : inout std_logic;
--		tmp_int        : in std_logic; -- Not used in this project
--		tmp_ct         : in std_logic; -- Not used in this project
      -- SPI Interface signals for the ADXL362 accelerometer
      sclk           : out STD_LOGIC;
      mosi           : out STD_LOGIC;
      miso           : in STD_LOGIC;
      ss             : out STD_LOGIC;
      -- PS2 interface signals
      ps2_clk        : inout std_logic;
      ps2_data       : inout std_logic;
      
      -- Debug output signals
--      SCLK_DBG       : out STD_LOGIC;
--      MOSI_DBG       : out STD_LOGIC;
--      MISO_DBG       : out STD_LOGIC;
--      SS_DBG         : out STD_LOGIC;
      
--      PS2C_DBG       : out std_logic;
--      PS2D_DBG       : out std_logic;
      
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
      ddr2_dqs_n     : inout std_logic_vector(1 downto 0)

   );
end Nexys4DdrUserDemo;

architecture Behavioral of Nexys4DdrUserDemo is

----------------------------------------------------------------------------------
-- Component Declarations
----------------------------------------------------------------------------------  

-- 200 MHz Clock Generator
component ClkGen
port
 (-- Clock in ports
  clk_100MHz_i           : in     std_logic;
  -- Clock out ports
  clk_100MHz_o          : out    std_logic;
  clk_200MHz_o          : out    std_logic;
  -- Status and control signals
  reset_i             : in     std_logic;
  locked_o            : out    std_logic
 );
end component;


component sSegDemo is
port(
   clk_i          : in std_logic;
   rstn_i         : in std_logic;
   seg_o          : out std_logic_vector(7 downto 0);
   an_o           : out std_logic_vector(7 downto 0));
end component;


component AudioDemo is
   port (
      -- Common
      clk_i                : in    std_logic;
      clk_200_i            : in    std_logic;
      rst_i                : in    std_logic;

      -- Peripherals      
      btn_u                : in    std_logic;
      leds_o               : out   std_logic_vector(15 downto 0);
      
      -- Microphone PDM signals
      pdm_m_clk_o    : out   std_logic; -- Output M_CLK signal to the microphone
      pdm_m_data_i   : in    std_logic; -- Input PDM data from the microphone
      pdm_lrsel_o    : out   std_logic; -- Set to '0', therefore data is read on the positive edge
      
      -- Audio output signals
      pwm_audio_o    : inout   std_logic; -- Output Audio data to the lowpass filters
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

      pdm_clk_rising_o : out std_logic -- Signaling the rising edge of M_CLK, used by the MicDisplay
                                       -- component in the VGA controller
);
end component;

----------------------------------------------------------------------------------
-- Signal Declarations
----------------------------------------------------------------------------------  
-- Inverted input reset signal
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

-- RGB LED signals
signal rgb_led_red: std_logic_vector (7 downto 0);
signal rgb_led_green: std_logic_vector (7 downto 0);
signal rgb_led_blue: std_logic_vector (7 downto 0);

-- ADXL362 Accelerometer data signals
signal ACCEL_X    : STD_LOGIC_VECTOR (8 downto 0);
signal ACCEL_Y    : STD_LOGIC_VECTOR (8 downto 0);
signal ACCEL_MAG  : STD_LOGIC_VECTOR (11 downto 0);
signal ACCEL_TMP  : STD_LOGIC_VECTOR (11 downto 0);

-- Mouse data signals
signal MOUSE_X_POS: std_logic_vector (11 downto 0);
signal MOUSE_Y_POS: std_logic_vector (11 downto 0);

-- ADT7420 Temperature Sensor raw Data Signal
signal tempValue : std_logic_vector(12 downto 0);
signal tempRdy, tempErr : std_logic;

-- pdm_clk and pdm_clk_rising are needed by the VGA controller
-- to display incoming microphone data
signal pdm_clk : std_logic;
signal pdm_clk_rising : std_logic;


begin
   
   -- Assign LEDs
   led_o <= sw_i when (led_audio = X"0000") else led_audio;

   -- The Reset Button on the Nexys4 board is active-low,
   -- however many components need an active-high reset
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
-- Seven-Segment Display
----------------------------------------------------------------------------------     
   Inst_SevenSeg: sSegDemo
   port map(
      clk_i          => clk_100MHz_buf,
      rstn_i         => resetn,
      seg_o          => disp_seg_o,
      an_o           => disp_an_o);


----------------------------------------------------------------------------------
-- Audio Demo
----------------------------------------------------------------------------------
   Inst_Audio: AudioDemo
   port map(
      clk_i          => clk_100MHz_buf,
      clk_200_i      => clk_200MHz_buf,
      rst_i          => reset,
      btn_u          => btnu_i,
      leds_o         => led_audio,
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
      pdm_clk_rising_o => pdm_clk_rising
   );


end Behavioral;

