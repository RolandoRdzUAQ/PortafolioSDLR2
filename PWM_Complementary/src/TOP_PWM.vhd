library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity PWM is
    generic(
        Frequency : INTEGER := 25000;
        nBits : INTEGER := 8
    );
    port(
        CLK : IN STD_LOGIC;
        RST : IN STD_LOGIC;
        DUTY : in STD_LOGIC_VECTOR(nBits-1 downto 0);
        PWM : OUT STD_LOGIC
    );
end PWM;


architecture Structural of PWM is 
    
    component Timer is
    generic( N : INTEGER := 10 );
    port(
        CLK : IN STD_LOGIC;
        RST : IN STD_LOGIC;
        EOT : OUT STD_LOGIC
    );
    end component;

    component FreeRunCounter is
    generic (
        N : integer := 4
    );
    port (
        INC : in STD_LOGIC;
        CLK : in STD_LOGIC;
        RST : in STD_LOGIC;
        COUNT : out STD_LOGIC_VECTOR(N-1 downto 0)
    );
    end component;					
	
	signal SYN : STD_LOGIC;			  
	signal syn_COUNT : STD_LOGIC_VECTOR(nBits-1 downto 0);

begin 

    U01 : Timer 
    generic map ( N => 5e7/(Frequency*2**nBits))
    port map ( CLK => CLK, RST => RST, EOT => SYN );

    U02 : FreeRunCounter
    generic map ( N => nBits )
    port map ( INC => SYN, CLK => CLK, RST => RST, COUNT => syn_Count );   
	
	PWM <= '1' when unsigned(DUTY) > unsigned(syn_COUNT) else '0';

end Structural;