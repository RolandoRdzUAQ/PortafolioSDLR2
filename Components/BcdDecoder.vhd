library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity BcdDecoder is
    port(
        NIB : in STD_LOGIC_VECTOR(3 downto 0);
        SEG : out STD_LOGIC_VECTOR(6 downto 0)
    );
end BcdDecoder;

architecture Behavioral of BcdDecoder is
begin
    -- Decodificador BCD a 7 Segmentos (Cátodo Común)
    -- Si recibe algo mayor a 9, simplemente apaga todos los segmentos.
    with NIB select
        SEG <= "0111111" when "0000", -- 0
               "0000110" when "0001", -- 1
               "1011011" when "0010", -- 2
               "1001111" when "0011", -- 3
               "1100110" when "0100", -- 4
               "1101101" when "0101", -- 5
               "1111101" when "0110", -- 6
               "0000111" when "0111", -- 7
               "1111111" when "1000", -- 8
               "1101111" when "1001", -- 9
               "0000000" when others; -- Apagado de seguridad
end Behavioral;