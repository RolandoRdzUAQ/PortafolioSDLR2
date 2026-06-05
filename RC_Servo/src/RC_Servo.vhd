library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Control_Servo_1ms_2ms is
    port(
        CLK : IN STD_LOGIC;
        RST : IN STD_LOGIC;
        DUT : IN STD_LOGIC_VECTOR(7 downto 0);
        PWM : OUT STD_LOGIC
    );
end Control_Servo_1ms_2ms;

architecture Structural of Control_Servo_1ms_2ms is 
    
    component Timer is
        generic( N : INTEGER := 10 );
        port(
            CLK : IN STD_LOGIC;
            RST : IN STD_LOGIC;
            EOT : OUT STD_LOGIC
        );
    end component;

    component Counter_M3600 is
        port (
            INC   : in STD_LOGIC;
            CLK   : in STD_LOGIC;
            RST   : in STD_LOGIC;
            COUNT : out STD_LOGIC_VECTOR(11 downto 0) 
        );
    end component;

    signal SYN        : STD_LOGIC;            
    signal CNT        : STD_LOGIC_VECTOR(11 downto 0);
    signal DUT_PADDED : unsigned(11 downto 0);
    signal SUM        : unsigned(11 downto 0);

begin 

    U01 : Timer 
    generic map ( N => 278 )
    port map ( CLK => CLK, RST => RST, EOT => SYN );

    U02 : Counter_M3600
    port map ( INC => SYN, CLK => CLK, RST => RST, COUNT => CNT );   
    
    DUT_PADDED <= unsigned("0000" & DUT);

    SUM <= DUT_PADDED + 180;

    PWM <= '1' when SUM > unsigned(CNT) else '0';

end Structural;