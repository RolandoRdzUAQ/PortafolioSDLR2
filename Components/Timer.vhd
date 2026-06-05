library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Timer is
    generic( N : INTEGER := 10 );
    port(
        CLK : IN STD_LOGIC;
        RST : IN STD_LOGIC;
        EOT : OUT STD_LOGIC
    );
end Timer;

architecture Behavioral of Timer is
    signal Qp, Qn : INTEGER;
begin   
    Combinational : process (Qp)
    begin
        if Qp = (N - 1) then
            EOT <= '1'; 
            Qn <= 0;
        else
            Qn <= Qp + 1;   
            EOT <= '0';
        end if;
    end process Combinational;
    
    Sequential : process (RST, CLK)
    begin
        if RST = '0' then
            Qp <= 0;
        elsif rising_edge(CLK) then
            Qp <= Qn;
        end if;
    end process Sequential;
end Behavioral;