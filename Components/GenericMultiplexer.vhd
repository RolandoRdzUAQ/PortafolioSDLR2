library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity GenericMultiplexer is
    generic ( N : integer := 4 );
    port (
        DIGITS : in STD_LOGIC_VECTOR((N*4)-1 downto 0);
        SEL    : in integer range 0 to N-1;
        NIB    : out STD_LOGIC_VECTOR(3 downto 0)
    );
end GenericMultiplexer;

architecture Behavioral of GenericMultiplexer is
begin
    NIB <= DIGITS((SEL * 4) + 3 downto SEL * 4);
end Behavioral;