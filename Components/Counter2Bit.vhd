library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Counter2Bit is
    port(
        CLK : in STD_LOGIC;
        RST : in STD_LOGIC;
        SYN : in STD_LOGIC;
        SEL : out STD_LOGIC_VECTOR(1 downto 0)
    );
end Counter2Bit;

architecture Behavioral of Counter2Bit is
    signal count : unsigned(1 downto 0);
begin
    process(CLK, RST)
    begin
        if RST = '0' then
            count <= "00";
        elsif rising_edge(CLK) then
            if SYN = '1' then
                count <= count + 1;
            end if;
        end if;
    end process;
    SEL <= std_logic_vector(count);
end Behavioral;