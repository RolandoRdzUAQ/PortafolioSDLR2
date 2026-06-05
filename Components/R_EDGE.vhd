library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity DFF is
    port(
        RST : in STD_LOGIC;
        CLK : in STD_LOGIC;
        XOUT : out STD_LOGIC;
        XIN : in STD_LOGIC
    );
end DFF;

architecture Behavioral of DFF is
    signal Qp, Qn : STD_LOGIC;
    Combinational : process(XIN)
    begin
        if XIN = '1' then
            Qn <= '1';
        else
            Qn <= '0';
        end if;
        XOUT <= Qp;
    end Combinational;
    Sequential : process(RST, CLK)
    begin
        if RST = '0' then
            Qp <= '0';
        elsif CLK'event and CLK = '1' then
            Qp <= Qn;
        end if;
    end Sequential;
end Behavioral;

entity Rising_Edge is
    port(
        RIN : in STD_LOGIC;
        XRE : out STD_LOGIC;
        CLK : in STD_LOGIC;
        RST : in STD_LOGIC
    );
end Rising_Edge;



architecture Behavioral of Rising_Edge is
signal Out1, Out2, Out3 : STD_LOGIC;
signal Qp, Qn : STD_LOGIC;
Component DFF
    port(
        RST : in STD_LOGIC;
        CLK : in STD_LOGIC;
        XOUT : out STD_LOGIC;
        XIN : in STD_LOGIC
    );
end Component;

begin 
    U1: DFF port map (
        RST => RST,
        CLK => CLK,
        XOUT => Out1,
        XIN => RIN
    );

    U2: DFF port map (
        RST => RST,
        CLK => CLK,
        XOUT => Out2,
        XIN => Out1
    );

    U3: DFF port map (
        RST => RST,
        CLK => CLK,
        XOUT => Out3,
        XIN => Out2
    );

    XRE <= Out1 and Out2 and (not Out3);
    
end Behavioral;