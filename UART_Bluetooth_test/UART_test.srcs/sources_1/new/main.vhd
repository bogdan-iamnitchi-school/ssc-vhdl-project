----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/18/2019 11:31:25 PM
-- Design Name: 
-- Module Name: modul_principal - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity modul_principal is
    Port ( Clk : in std_logic;
    	   Rst : in std_logic;
    	   Send : in std_logic;
    	   Tx : out std_logic;
    	   Rx : in std_logic;
    	   
    	   TxReady : out std_logic;
    	   RxReady : out std_logic;
    	   
    	   An : out STD_LOGIC_VECTOR (7 downto 0);
           Seg : out STD_LOGIC_VECTOR (7 downto 0)
    	 );
end modul_principal;

architecture Behavioral of modul_principal is
signal TxData : std_logic_vector(7 downto 0) := x"61";
signal RxData : std_logic_vector(7 downto 0);
signal send_debounced : std_logic;
signal rst_debounced : std_logic;
signal Tx_aux : std_logic := '1';
signal TxReady_aux : std_logic := '0';
signal Rx_aux : std_logic := '1';
signal RxReady_aux : std_logic := '0';
signal probe_in : std_logic_vector(1 downto 0);

signal Data: STD_LOGIC_VECTOR (31 downto 0);

begin

    deb1 : entity WORK.debouncer port map (
        clk_i => Clk, 
        sig_i => Send, 
        pls_o => send_debounced
    );
    
    deb2 : entity WORK.debouncer port map (
        clk_i => Clk, 
        sig_i => Rst, 
        pls_o => rst_debounced
    );
    
    Tx_i : entity WORK.UART_TX_CTRL port map(
        Clk => Clk, 
        send => send_debounced, 
        data => TxData, 
        UART_TX => Tx, 
        READY => TxReady
    );
    
    
    Rx_i : entity WORK.UART_RX_CTRL port map(
        clk => Clk, 
        rst => rst_debounced, 
        data_stream_out => RxData, 
        data_stream_out_stb => RxReady, 
        rx => Rx
    );
    
    
    
    Data <= x"0000" & x"00" & RxData; 
    ssd_i: entity WORK.ssd port map (
        Clk => Clk, 
        Rst => Rst, 
        Data => Data,
        An => An, 
        Seg => Seg
    ); 

end Behavioral;
