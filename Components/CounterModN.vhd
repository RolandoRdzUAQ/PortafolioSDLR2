library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CounterModN is
    generic ( N : integer := 4 );
    port (
        CLK : in STD_LOGIC;
        RST : in STD_LOGIC;
        SYN : in STD_LOGIC;
        SEL : out integer range 0 to N-1
    );
end CounterModN;

architecture Behavioral of CounterModN is
    signal count : integer range 0 to N-1 := 0;
begin
    process(CLK, RST)
    begin
        if RST = '0' then
            count <= 0;
        elsif rising_edge(CLK) then
            if SYN = '1' then
                if count = N - 1 then
                    count <= 0;
                else
                    count <= count + 1;
                end if;
            end if;
        end if;
    end process;
    SEL <= count;
end Behavioral;