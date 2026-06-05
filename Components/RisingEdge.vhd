library IEEE;
use IEEE.std_logic_1164.all;

entity RisingEdge is
    port(
        RST : in STD_LOGIC;
        CLK : in STD_LOGIC;
        XIN : in STD_LOGIC;
        RED : out STD_LOGIC
    );
end RisingEdge;

architecture Behavioral of RisingEdge is
signal Qp, Qn : std_logic_vector(2 downto 0);
begin 
    Combinational : process(XIN, Qp)
    begin
        Qn <= Qp(1) & Qp(0) & XIN;
        RED <= (not Qp(2)) and Qp(1) and Qp(0);
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