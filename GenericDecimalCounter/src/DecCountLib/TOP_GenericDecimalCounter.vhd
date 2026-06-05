library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity GenericDecimalCounter is
    Generic ( N : integer := 4 ); 
    Port (
        CLK     : in  STD_LOGIC;
        RST     : in  STD_LOGIC;
        ENA     : in  STD_LOGIC; 
        DEC_OUT : out STD_LOGIC_VECTOR((N*4)-1 downto 0) 
    );
end GenericDecimalCounter;

architecture Structural of GenericDecimalCounter is
    component CounterM10 is
        Port( CLK, RST, ENI : in STD_LOGIC; CNT : out STD_LOGIC_VECTOR(3 downto 0); EN0 : out STD_LOGIC );
    end component;
    
    signal carry : STD_LOGIC_VECTOR(N downto 0);
begin
    carry(0) <= ENA;

    gen_counters: for i in 0 to N-1 generate
        U_Digit: CounterM10
        port map (
            CLK => CLK,
            RST => RST,
            ENI => carry(i),
            CNT => DEC_OUT((i*4)+3 downto i*4), 
            EN0 => carry(i+1)
        );
    end generate gen_counters;
end Structural;