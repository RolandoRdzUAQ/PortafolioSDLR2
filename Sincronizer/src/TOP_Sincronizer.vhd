Library IEEE;
use IEEE.std_logic_1164.all;

entity TOP_Sincronizer is
    generic(
        ticks : integer := 5
    )
    port (
        RST : in STD_LOGIC;
        CLK : in STD_LOGIC;
        XIN : in STD_LOGIC;
        COUT : in STD_LOGIC;
    );
end entity TOP_Sincronizer;


architecture Behavioral of TOP_Sincronizer is
    signal Xp, Xn : STD_LOGIC_VECTOR(ticks-1 downto 0);
    signal Xr : STD_LOGIC_VECTOR(ticks-2 downto 0);

begin
    combinational : process(Xp, XIN)
        begin
            Xn <= XIN & Xp(ticks-2 downto 1);
            Xr(0) <= Xp(0) and Xp(1);
            for i in 1 to ticks-2 loop
                Xr(i) <= Xr(i - 1) and Xp(i + 1);
            end loop;
                XOUT <= Xr(ticks-2);
        end process combinational;
        
    sequential : process(CLK, RST)
        begin
            if RST = '0' then
                Xp <= (others => '0');
            elsif CLK'event and CLK = '1' then
                Xp <= Xn;
            end if;
        end process Sequential;
    
    
    
end architecture Behavioral;