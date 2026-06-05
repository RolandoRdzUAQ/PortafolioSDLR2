library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Blinky is
    Port ( 
        CLK : in STD_LOGIC;
        RST : in STD_LOGIC;
        LED : out STD_LOGIC  
    );
end Blinky;

architecture Structural of Blinky is  

	constant FREQ_DESEADA_HZ  : integer := 8;       
    constant FREQ_RELOJ_HZ    : integer := 50000000;
    
    component Timer is
        generic(
            N : INTEGER := 10 
        );
        port(
            CLK : IN STD_LOGIC;
            RST : IN STD_LOGIC;
            EOT : OUT STD_LOGIC
        );
    end component;

    component Toggle is
        port(
            RST : in STD_LOGIC;
            CLK : in STD_LOGIC;
            TOG : in STD_LOGIC;
            TGS : out STD_LOGIC
        );
    end component;
    signal SYN_wire : STD_LOGIC; 

begin
    U1_Timer: Timer
    generic map (
        N => FREQ_RELOJ_HZ / (2 * FREQ_DESEADA_HZ)
    )
    port map (
        CLK => CLK,     
        RST => RST,   
        EOT => SYN_wire 
    );

    U2_Toggle: Toggle
    port map (
        CLK => CLK,     
        RST => RST,    
        TOG => SYN_wire, 
        TGS => LED      
    );

end Structural;