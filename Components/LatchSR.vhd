library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity LatchSR is
    port(
        RST   : in STD_LOGIC;
        CLK   : in STD_LOGIC;
        SET   : in STD_LOGIC;
        CLEAR : in STD_LOGIC;
        SOUT  : out STD_LOGIC
    );
end LatchSR;

architecture Behavioral of LatchSR is
    signal Qp, Qn : STD_LOGIC;
begin 
    Combinational : process(SET, CLEAR, Qp)
    begin
        if SET = '1' then
            Qn <= '1';
        elsif CLEAR = '1' then
            Qn <= '0';
        else
            Qn <= Qp;
        end if;
        SOUT <= Qp;
    end process Combinational;

    Sequential : process(RST, CLK)
    begin 
        if RST = '0' then
            Qp <= '0';
        elsif rising_edge(CLK) then
            Qp <= Qn;
        end if;
    end process;
end Behavioral;