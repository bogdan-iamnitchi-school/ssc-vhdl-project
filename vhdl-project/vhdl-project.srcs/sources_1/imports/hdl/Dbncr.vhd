
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

----------------------------------------------------------------------------------
-- Entity
----------------------------------------------------------------------------------  
entity Dbncr is
    Port ( 
        clk_i : in STD_LOGIC;
	    sig_i : in STD_LOGIC;
        pls_o : out STD_LOGIC
    );
end Dbncr;


----------------------------------------------------------------------------------
-- Architecture                                                                       
----------------------------------------------------------------------------------
architecture Behavioral of Dbncr is

-- signals
signal count_int: std_logic_vector(31 downto 0):=x"00000000";
signal q1: std_logic;
signal q2: std_logic;
signal q3: std_logic;

begin

    pls_o <= q2 and (not q3);

    -- count
    counter: process(clk_i)
    begin 
        if rising_edge(clk_i) then
           count_int<= count_int + 1;
        end if;
    end process counter;
    
    -- verify
    check: process(clk_i)
    begin 
        if rising_edge(clk_i) then
             if count_int(15 downto 0)="1111111111111111" then
                   q1 <= sig_i;
               end if;
        end if;
    end process check;

    -- flip flops
    move: process(clk_i)
    begin 
        if rising_edge(clk_i) then 
         q2<=q1;
         q3<=q2;
        end if;
    end process move;	   

end Behavioral;