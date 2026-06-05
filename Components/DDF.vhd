library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity DFF is
    port(
        RST : in STD_LOGIC;
        CLK : in STD_LOGIC;
        XOUT : out STD_LOGIC;
        XIN : in STD_LOGIC
    );
end DFF;

architecture Behavioral of DFF is
    signal Qp, Qn : STD_LOGIC;
    Combinational : process(XIN)
    begin
        if XIN = '1' then
            Qn <= '1';
        else
            Qn <= '0';
        end if;
        XOUT <= Qp;
    end Combinational;
    Sequential : process(RST, CLK)
    begin
        if RST = '0' then
            Qp <= '0';
        elsif CLK'event and CLK = '1' then
            Qp <= Qn;
        end if;
    end Sequential;
end Behavioral;


