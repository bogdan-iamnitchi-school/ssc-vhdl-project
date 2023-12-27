
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

----------------------------------------------------------------------------------
-- Entity
----------------------------------------------------------------------------------  
entity PdmSer is
   generic(
      C_NR_OF_BITS : integer := 16;
      C_SYS_CLK_FREQ_MHZ : integer := 100;
      C_PDM_FREQ_HZ : integer := 2000000
   );
   port(
      clk_i : in std_logic;
      en_i : in std_logic; -- Enable serializing (during playback)
      btn_d : in    std_logic;
      btn_c : in    std_logic;
      
      done_o : out std_logic; -- Signaling that data_i is sent
      data_i : in std_logic_vector(C_NR_OF_BITS - 1 downto 0); -- input data
      
      -- PWM
      pwm_audio_o : inout std_logic; -- Output audio data
      
      -- TX_Bluetooth
      tx_pmodbt : out std_logic
   );
end PdmSer;


----------------------------------------------------------------------------------
-- Architecture
----------------------------------------------------------------------------------  
architecture Behavioral of PdmSer is

----------------------------------------------------------------------------------
-- UART_TX_CTRL control signals
----------------------------------------------------------------------------------  
type UART_STATE_TYPE is (RST_REG, IDLE, LD_FIRST, SEND_CHAR, RDY_LOW, WAIT_RDY, LD_SECOND, LD_NEWLINE);
--Current uart state signal
signal uartState : UART_STATE_TYPE := RST_REG;

signal btnd_debounced : std_logic;
signal btnc_debounced : std_logic;

signal uartRdy : std_logic;
signal uartSend : std_logic := '0';
signal uartData : std_logic_vector (7 downto 0):= "00000000";
signal uartTX : std_logic;

signal begin_send : std_logic;
signal done_send_async : std_logic;
signal data_to_send : std_logic_vector(15 downto 0);

constant RESET_CNTR_MAX : std_logic_vector(17 downto 0) := "110000110101000000";-- 100,000,000 * 0.002 = 200,000 = clk cycles per 2 ms
signal reset_cntr : std_logic_vector (17 downto 0) := (others=>'0');

signal data_send : std_logic_vector (15 downto 0) := x"6162";
signal byte_data : std_logic_vector (7 downto 0);

--Contains the length of the current string being sent over uart.
signal BYTE_COUNT : natural := 3;
signal byte_index : natural := 0;
signal newline : std_logic_vector (7 downto 0) := x"0A";

------------------------------------------------------------------------
-- Serializer signals
------------------------------------------------------------------------
-- divider to create clk_int
signal cnt_clk : integer range 0 to 255 := 0;
-- internal pdm_clk signal
signal clk_int : std_logic := '0';

-- Piped clk_int signal to create pdm_clk_rising
signal pdm_clk_rising : std_logic;

-- Shift register used to temporary store then serialize data
signal pdm_s_tmp : std_logic_vector((C_NR_OF_BITS-1) downto 0);
-- Count the number of bits
signal cnt_bits : integer range 0 to 31 := 0;

signal en_int, done_int : std_logic;


constant HALF_NR_BITS: integer := (C_NR_OF_BITS / integer(2));
signal tx_send: std_logic;
signal tx_send_temp: std_logic := '0';
signal tx_ready: std_logic :='0';
signal tx_data: std_logic_vector (7 downto 0) := x"61";

------------------------------------------------------------------------
-- Begin
------------------------------------------------------------------------
begin

    ------------------------------------------------------------------------
    -- UART_TX
    ------------------------------------------------------------------------
    Btnd: entity WORK.Dbncr
    port map(
      clk_i          => clk_i,
      sig_i          => btn_d,
      pls_o          => btnd_debounced
    );
    
    Btnc: entity WORK.Dbncr
    port map(
      clk_i          => clk_i,
      sig_i          => btn_c,
      pls_o          => btnc_debounced
    );

    --This counter holds the UART state machine in reset for ~2 milliseconds. This
    --will complete transmission of any byte that may have been initiated
    process(clk_i)
    begin
      if (rising_edge(clk_i)) then
        if ((reset_cntr = RESET_CNTR_MAX) or (uartState /= RST_REG)) then
          reset_cntr <= (others=>'0');
        else
          reset_cntr <= reset_cntr + 1;
        end if;
      end if;
    end process;
    
    --Next Uart state logic
    next_uartState_process : process (clk_i)
    begin
        if (rising_edge(clk_i)) then
            if (btnd_debounced = '1') then
                uartState <= RST_REG;
            else	
                case uartState is 
                when RST_REG =>
                    if (reset_cntr = RESET_CNTR_MAX) then
                      uartState <= IDLE;
                    end if;
                when IDLE =>
                    if (en_int = '1') then
                      uartState <= LD_FIRST;
                    end if;
                when LD_FIRST =>
                    uartState <= SEND_CHAR;
                when SEND_CHAR =>
                    uartState <= RDY_LOW;
                when RDY_LOW =>
                    uartState <= WAIT_RDY;
                when WAIT_RDY =>
                    if (uartRdy = '1') then
                        if (byte_index = BYTE_COUNT) then
                            uartState <= IDLE;
                        elsif (byte_index = BYTE_COUNT-1) then
                            uartState <= LD_NEWLINE;
                        else
                            uartState <= LD_SECOND;
                        end if;
                    end if;
                when LD_SECOND =>
                    uartState <= SEND_CHAR;
                when LD_NEWLINE =>
                    uartState <= SEND_CHAR;
                when others =>
                    uartState <= RST_REG;
                end case;
            end if ;
        end if;
    end process;
    
    --Loads the data(7,0) / data(15,8) signals when a LD First/Second is
    --is reached.
    string_load_process : process (clk_i)
    begin
        if (rising_edge(clk_i)) then
            if (uartState = LD_FIRST) then
                byte_data <= data_i(15 downto 8);
            elsif (uartState = LD_SECOND) then
                byte_data <= data_i(7 downto 0);
            else
                byte_data <= newline;
            end if;
        end if;
    end process;
    
    --Conrols the byte_index signal so that it contains the index
    --of the next sample that needs to be sent over uart
    char_count_process : process (clk_i)
    begin
        if (rising_edge(clk_i)) then
            if (uartState = IDLE) then
                byte_index <= 0;
            elsif (uartState = SEND_CHAR) then
                byte_index <= byte_index + 1;
            end if;
        end if;
    end process;
    
    --Controls the UART_TX_CTRL signals
    char_load_process : process (clk_i)
    begin
        if (rising_edge(clk_i)) then
            if (uartState = SEND_CHAR) then
                uartSend <= '1';
                uartData <= byte_data;
            else
                uartSend <= '0';
            end if;
        end if;
    end process;
    
    --Component used to send a byte of data over a UART line.
    Inst_UART_TX_CTRL: entity WORK.UART_TX_CTRL port map(
            SEND => uartSend,
            DATA => uartData,
            CLK => clk_i,
            READY => uartRdy,
            UART_TX => uartTX 
        );
    
    -- output the data to the module
    tx_pmodbt <= uartTX;
    
------------------------------------------------------------------------
-- SERIALIZER
------------------------------------------------------------------------

   -- Register en_i
   SYNC: process(clk_i)
   begin
      if rising_edge(clk_i) then
         en_int <= en_i;
      end if;
   end process SYNC;
   
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
   
    -- Generate done_o when the number of bits are serialized
   process(clk_i)
   begin
      if rising_edge(clk_i) then
         if pdm_clk_rising = '1' then
            if cnt_bits = (C_NR_OF_BITS-1) then
               done_int <= '1';
            end if;
         else
            done_int <= '0';
         end if;
      end if;
   end process;
   
   done_o <= done_int;
   
   ------------------------------------------------------------------------
   -- Serializer
   ------------------------------------------------------------------------
   SHFT_OUT: process(clk_i)
   begin
      if rising_edge(clk_i) then
         if pdm_clk_rising = '1' then
            if cnt_bits = 0 then
               pdm_s_tmp <= data_i;
            else
               pdm_s_tmp <= pdm_s_tmp(C_NR_OF_BITS-2 downto 0) & '0';
            end if;
         end if;
      end if;
   end process SHFT_OUT;
   
   -- output the serial pdm data
   pwm_audio_o <= '0' when pdm_s_tmp(C_NR_OF_BITS-1) = '0' else 'Z';

   -- Generate the internal PDM Clock
   CLK_CNT: process(clk_i)
   begin
      if rising_edge(clk_i) then
         if en_int = '0' then
            cnt_clk <= 0;
            pdm_clk_rising <= '0';
         else
            if cnt_clk = (((C_SYS_CLK_FREQ_MHZ*1000000)/C_PDM_FREQ_HZ)-1) then
               cnt_clk <= 0;
               pdm_clk_rising <= '1';
            else
               cnt_clk <= cnt_clk + 1;
               pdm_clk_rising <= '0';
            end if;
         end if;
      end if;
   end process CLK_CNT;
   
   
end Behavioral;

