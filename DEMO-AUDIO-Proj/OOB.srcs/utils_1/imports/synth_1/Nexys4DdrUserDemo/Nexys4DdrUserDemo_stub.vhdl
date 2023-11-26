-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Nexys4DdrUserDemo is
  Port ( 
    clk_i : in STD_LOGIC;
    rstn_i : in STD_LOGIC;
    btnl_i : in STD_LOGIC;
    btnc_i : in STD_LOGIC;
    btnr_i : in STD_LOGIC;
    btnd_i : in STD_LOGIC;
    btnu_i : in STD_LOGIC;
    sw_i : in STD_LOGIC_VECTOR ( 15 downto 0 );
    disp_seg_o : out STD_LOGIC_VECTOR ( 7 downto 0 );
    disp_an_o : out STD_LOGIC_VECTOR ( 7 downto 0 );
    led_o : out STD_LOGIC_VECTOR ( 15 downto 0 );
    rgb1_red_o : out STD_LOGIC;
    rgb1_green_o : out STD_LOGIC;
    rgb1_blue_o : out STD_LOGIC;
    rgb2_red_o : out STD_LOGIC;
    rgb2_green_o : out STD_LOGIC;
    rgb2_blue_o : out STD_LOGIC;
    vga_hs_o : out STD_LOGIC;
    vga_vs_o : out STD_LOGIC;
    vga_red_o : out STD_LOGIC_VECTOR ( 3 downto 0 );
    vga_blue_o : out STD_LOGIC_VECTOR ( 3 downto 0 );
    vga_green_o : out STD_LOGIC_VECTOR ( 3 downto 0 );
    pdm_clk_o : out STD_LOGIC;
    pdm_data_i : in STD_LOGIC;
    pdm_lrsel_o : out STD_LOGIC;
    pwm_audio_o : inout STD_LOGIC;
    pwm_sdaudio_o : out STD_LOGIC;
    tmp_scl : inout STD_LOGIC;
    tmp_sda : inout STD_LOGIC;
    sclk : out STD_LOGIC;
    mosi : out STD_LOGIC;
    miso : in STD_LOGIC;
    ss : out STD_LOGIC;
    ps2_clk : inout STD_LOGIC;
    ps2_data : inout STD_LOGIC;
    ddr2_addr : out STD_LOGIC_VECTOR ( 12 downto 0 );
    ddr2_ba : out STD_LOGIC_VECTOR ( 2 downto 0 );
    ddr2_ras_n : out STD_LOGIC;
    ddr2_cas_n : out STD_LOGIC;
    ddr2_we_n : out STD_LOGIC;
    ddr2_ck_p : out STD_LOGIC_VECTOR ( 0 to 0 );
    ddr2_ck_n : out STD_LOGIC_VECTOR ( 0 to 0 );
    ddr2_cke : out STD_LOGIC_VECTOR ( 0 to 0 );
    ddr2_cs_n : out STD_LOGIC_VECTOR ( 0 to 0 );
    ddr2_dm : out STD_LOGIC_VECTOR ( 1 downto 0 );
    ddr2_odt : out STD_LOGIC_VECTOR ( 0 to 0 );
    ddr2_dq : inout STD_LOGIC_VECTOR ( 15 downto 0 );
    ddr2_dqs_p : inout STD_LOGIC_VECTOR ( 1 downto 0 );
    ddr2_dqs_n : inout STD_LOGIC_VECTOR ( 1 downto 0 )
  );

end Nexys4DdrUserDemo;

architecture stub of Nexys4DdrUserDemo is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
begin
end;
