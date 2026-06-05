library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity CounterM10 is
    Port(
        CLK : in STD_LOGIC;
        RST : in STD_LOGIC;
        ENI : in STD_LOGIC;
        CNT : out std_ulogic_vector(3 downto 0);
        EN0 : out STD_LOGIC
    );
end CounterM10;

Architecture Behavioral of CounterM10 is
    signal Cp, Cn : std_logic_vector(3 downto 0);
    signal Eq9 : STD_LOGIC;
begin

    eq9 <= '1' when Cp = "1001" else '0';
    EN0 <= ENI and eq9;

    combinational : process(Cp, ENI)
    begin 
        if ENI = '1' then
            if Cp = "1001" then
                Cn <= (others => '0');
                EN0 <= '1';
            else
                Cn <= std_logic_vector(unsigned(Cp) + 1);
                EN0 <= '0';
            end if;
        else
            Cn <= Cp;
        end if;
        CNT <= std_ulogic_vector(Cp);
    end process;

    sequential : process(RST, CLK)
    begin
        if RST = '0' then 
            Cp <= (others => '0');
        elsif CLK'event and CLK = '1' then
            Cp <= Cn;
        end if;
    end process;
end Behavioral;