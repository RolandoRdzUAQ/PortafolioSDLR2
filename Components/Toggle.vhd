library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity Toggle is
    port(
        RST : in STD_LOGIC;
        CLK : in STD_LOGIC;
        TOG : in STD_LOGIC;
        TGS : out STD_LOGIC
    );
end Toggle;

architecture Behavioral of Toggle is
signal Qp, Qn : STD_LOGIC;
begin 
    Combinational : process(TOG)
    begin
        if Qp = TOG then
            Qn <= '0';
        else
            Qn <= '1';
        end if;
        TGS <= Qp;
    end process Combinational;
    Sequential : process(RST, CLK)
    begin 
        if RST = '0' then
            Qp <= '0';
        elsif CLK'event and CLK = '1' then
            Qp <= Qn;
        end if;
    end process;
end Behavioral;