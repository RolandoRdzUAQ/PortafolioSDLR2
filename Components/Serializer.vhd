library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Serializer is
    generic (
        nBits : integer := 8
    );
    port(
        CLK : in STD_LOGIC;
        RST : in STD_LOGIC;
        LDR : in STD_LOGIC;
        SHF : in STD_LOGIC;
        DIN : in STD_LOGIC_VECTOR(nBits-1 downto 0);
        DOUT : out STD_LOGIC
    );
end Serializer;

architecture Behavioral of Serializer is
   signal Qp, Qn : STD_LOGIC_VECTOR(nBits-1 downto 0); 
begin
    Combinational : process(LDR, Qp, SHF, DIN)
    begin
        if LDR = '1' then
            Qn <= DIN;
        elsif SHF = '1' then
            Qn <= '1' & Qp(nBits - 1 downto 1);
        else
            Qn <= Qp;
        end if;
        DOUT <= Qp(0);
    end process Combinational;
    Sequential : process(RST, CLK)
    begin
        if RST = '0' then
            Qp <= (others => '0');
        elsif CLK'event and CLK = '1' then
            Qp <= Qn;
        end if;
    end process Sequential;
end architecture Behavioral;