// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module Nexys4DdrUserDemo(clk_i, rstn_i, btnl_i, btnc_i, btnr_i, btnd_i, 
  btnu_i, sw_i, disp_seg_o, disp_an_o, led_o, rgb1_red_o, rgb1_green_o, rgb1_blue_o, rgb2_red_o, 
  rgb2_green_o, rgb2_blue_o, vga_hs_o, vga_vs_o, vga_red_o, vga_blue_o, vga_green_o, pdm_clk_o, 
  pdm_data_i, pdm_lrsel_o, pwm_audio_o, pwm_sdaudio_o, tmp_scl, tmp_sda, sclk, mosi, miso, ss, ps2_clk, 
  ps2_data, ddr2_addr, ddr2_ba, ddr2_ras_n, ddr2_cas_n, ddr2_we_n, ddr2_ck_p, ddr2_ck_n, ddr2_cke, 
  ddr2_cs_n, ddr2_dm, ddr2_odt, ddr2_dq, ddr2_dqs_p, ddr2_dqs_n);
  input clk_i;
  input rstn_i;
  input btnl_i;
  input btnc_i;
  input btnr_i;
  input btnd_i;
  input btnu_i;
  input [15:0]sw_i;
  output [7:0]disp_seg_o;
  output [7:0]disp_an_o;
  output [15:0]led_o;
  output rgb1_red_o;
  output rgb1_green_o;
  output rgb1_blue_o;
  output rgb2_red_o;
  output rgb2_green_o;
  output rgb2_blue_o;
  output vga_hs_o;
  output vga_vs_o;
  output [3:0]vga_red_o;
  output [3:0]vga_blue_o;
  output [3:0]vga_green_o;
  output pdm_clk_o;
  input pdm_data_i;
  output pdm_lrsel_o;
  inout pwm_audio_o;
  output pwm_sdaudio_o;
  inout tmp_scl;
  inout tmp_sda;
  output sclk;
  output mosi;
  input miso;
  output ss;
  inout ps2_clk;
  inout ps2_data;
  output [12:0]ddr2_addr;
  output [2:0]ddr2_ba;
  output ddr2_ras_n;
  output ddr2_cas_n;
  output ddr2_we_n;
  output [0:0]ddr2_ck_p;
  output [0:0]ddr2_ck_n;
  output [0:0]ddr2_cke;
  output [0:0]ddr2_cs_n;
  output [1:0]ddr2_dm;
  output [0:0]ddr2_odt;
  inout [15:0]ddr2_dq;
  inout [1:0]ddr2_dqs_p;
  inout [1:0]ddr2_dqs_n;
endmodule
