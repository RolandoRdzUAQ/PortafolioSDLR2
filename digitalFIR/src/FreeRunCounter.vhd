library IEEE;
use IEEE.STD_LOGIC_1164.all;	
use IEEE.NUMERIC_STD.all;

entity FreeRunCounter is
    generic (
        N : integer := 4
    );
    port (
        INC : in STD_LOGIC;
        CLK : in STD_LOGIC;
        RST : in STD_LOGIC;
        COUNT : out STD_LOGIC_VECTOR(N-1 downto 0)
    );
end FreeRunCounter;

architecture Behavioral of FreeRunCounter is
    signal Qp : STD_LOGIC_VECTOR(N-1 downto 0) := (others => '0');
    signal Qn : STD_LOGIC_VECTOR(N-1 downto 0);
begin
    Combinational : process(INC, Qp)
    begin
        if INC = '1' then
            Qn <= std_logic_vector(unsigned(Qp) + 1);
        else
            Qn <= Qp;
        end if;
        COUNT <= Qp;
    end process Combinational;
    Sequential : process(RST, CLK)
    begin
        if RST = '0' then
            Qp <= (others => '0');
        elsif CLK'event and CLK = '1' then
            Qp <= Qn;
        end if;
    end process Sequential;
end Behavioral;
