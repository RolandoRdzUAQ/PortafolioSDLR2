library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity CountDown is
    generic(
        M : INTEGER := 15
    );
    port(
        CLK : IN STD_LOGIC;
        RST : IN STD_LOGIC;
        DEC : IN STD_LOGIC;
        RDY : OUT STD_LOGIC
    );
end CountDown;

architecture Behavioral of CountDown is 
    signal Qp, Qn : INTEGER;
begin								
	
    Combinational : process (DEC, Qp)
    begin
        if Qp = 0 then
            RDY <= '1';
            Qn <= Qp;
        elsif DEC = '1' AND Qp /= 0 then
            Qn <= Qp - 1;
            RDY <= '0';
        else
            Qn <= Qp;
            RDY <= '0';		  
		end if;
    end process Combinational;

    Sequential : process (CLK, RST)
    begin
        if RST = '0' then
            Qp <= M;
        elsif CLK'event AND CLK = '1' then
            Qp <= Qn;		  
		end if;
    end process Sequential;
end Behavioral; 
