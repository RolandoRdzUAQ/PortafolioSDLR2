library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ManejoDisplaysGenerico is
    Generic (
        N_DISPLAYS    : integer := 4;      
        TICKS_REFRESH : integer := 50000   
    );
    Port ( 
        CLK    : in  STD_LOGIC;                      
        RST    : in  STD_LOGIC;                      
        DIGITS : in  STD_LOGIC_VECTOR((N_DISPLAYS * 4) - 1 downto 0); 
        SEG    : out STD_LOGIC_VECTOR(6 downto 0); 
        CAT    : out STD_LOGIC_VECTOR(N_DISPLAYS - 1 downto 0)  
    );
end ManejoDisplaysGenerico;

architecture Structural of ManejoDisplaysGenerico is

    component Timer is
        generic( Ticks : INTEGER := 10 );
        port( CLK, RST : in STD_LOGIC; EOT : out STD_LOGIC );
    end component;

    component CounterModN is
        generic ( N : integer := 4 );
        port ( CLK, RST, SYN : in STD_LOGIC; SEL : out integer range 0 to N-1 );
    end component;

    component GenericMultiplexer is
        generic ( N : integer := 4 );
        port( DIGITS : in STD_LOGIC_VECTOR((N*4)-1 downto 0); SEL : in integer range 0 to N-1; NIB : out STD_LOGIC_VECTOR(3 downto 0) );
    end component;

    component GenericCatodoDecoder is
        generic ( N : integer := 4 );
        port( SEL : in integer range 0 to N-1; CAT : out STD_LOGIC_VECTOR(N-1 downto 0) );
    end component;

    component BcdDecoder is
        port( NIB : in STD_LOGIC_VECTOR(3 downto 0); SEG : out STD_LOGIC_VECTOR(6 downto 0) );
    end component;

    signal syn_refresh : STD_LOGIC;
    signal sel_wire    : integer range 0 to N_DISPLAYS - 1;
    signal nib_wire    : STD_LOGIC_VECTOR(3 downto 0);

begin

    Display_TimerRefresh: Timer
    generic map ( Ticks => TICKS_REFRESH )
    port map ( CLK => CLK, RST => RST, EOT => syn_refresh );

    Display_SelCounter: CounterModN
    generic map ( N => N_DISPLAYS )
    port map ( CLK => CLK, RST => RST, SYN => syn_refresh, SEL => sel_wire );

    Display_Mux: GenericMultiplexer
    generic map ( N => N_DISPLAYS )
    port map ( DIGITS => DIGITS, SEL => sel_wire, NIB => nib_wire );

    Display_CatDec: GenericCatodoDecoder
    generic map ( N => N_DISPLAYS )
    port map ( SEL => sel_wire, CAT => CAT );

    Display_7SegDec: BcdDecoder
    port map ( NIB => nib_wire, SEG => SEG );

end Structural;