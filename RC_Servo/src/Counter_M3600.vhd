library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Counter_M3600 is
    port (
        INC   : in STD_LOGIC;
        CLK   : in STD_LOGIC;
        RST   : in STD_LOGIC;
        COUNT : out STD_LOGIC_VECTOR(11 downto 0)
    );
end Counter_M3600;

architecture Behavioral of Counter_M3600 is
    signal count_int : unsigned(11 downto 0) := (others => '0');
begin
    process(CLK, RST)
    begin
        if RST = '1' then
            count_int <= (others => '0');
        elsif rising_edge(CLK) then
            if INC = '1' then
                if count_int = 3599 then
                    count_int <= (others => '0');
                else
                    count_int <= count_int + 1;
                end if;
            end if;
        end if;
    end process;
    
    COUNT <= std_logic_vector(count_int);
end Behavioral;