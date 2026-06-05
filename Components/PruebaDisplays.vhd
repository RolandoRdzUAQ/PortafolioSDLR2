library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PruebaDisplays is
    Port ( 
        CLK : in  STD_LOGIC;                      
        RST : in  STD_LOGIC;                      
        SW  : in  STD_LOGIC_VECTOR(9 downto 0); 
        SEG : out STD_LOGIC_VECTOR(6 downto 0); 
        CAT : out STD_LOGIC_VECTOR(3 downto 0)  
    );
end PruebaDisplays;

architecture Structural of PruebaDisplays is

    constant TICKS_REFRESH : integer := 50000; 

    component Timer is
        generic( N : INTEGER := 10 );
        port( CLK, RST : in STD_LOGIC; EOT : out STD_LOGIC );
    end component;

    component FreeRunCounter is
        generic ( N : integer := 4 );
        port (
            INC : in STD_LOGIC;
            CLK : in STD_LOGIC;
            RST : in STD_LOGIC;
            COUNT : out STD_LOGIC_VECTOR(N-1 downto 0)
        );
    end component;

    component Multiplex4To1 is
        port(
            DIG1, DIG2, DIG3, DIG4 : in STD_LOGIC_VECTOR(3 downto 0);
            SEL : in STD_LOGIC_VECTOR(1 downto 0);
            NIB : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    component Decoder74LS47 is
        port( NIB : in STD_LOGIC_VECTOR(3 downto 0); SEG : out STD_LOGIC_VECTOR(6 downto 0) );
    end component;

    component CatodoDecoder is
        port( SEL : in STD_LOGIC_VECTOR(1 downto 0); CAT : out STD_LOGIC_VECTOR(3 downto 0) );
    end component;

	 component HexDecoder is
        port( NIB : in STD_LOGIC_VECTOR(3 downto 0); SEG : out STD_LOGIC_VECTOR(6 downto 0) );
    end component;
	 
    component BinToBCD is
        port(
            BIN_IN : in  STD_LOGIC_VECTOR (15 downto 0);
            DIG_1  : out STD_LOGIC_VECTOR (3 downto 0);
            DIG_2  : out STD_LOGIC_VECTOR (3 downto 0);
            DIG_3  : out STD_LOGIC_VECTOR (3 downto 0);
            DIG_4  : out STD_LOGIC_VECTOR (3 downto 0)
        );
    end component;

    signal syn_refresh : STD_LOGIC;
    signal sel_wire    : STD_LOGIC_VECTOR(1 downto 0);
    signal nib_wire    : STD_LOGIC_VECTOR(3 downto 0);
    
    signal d1, d2, d3, d4 : STD_LOGIC_VECTOR(3 downto 0);
	 
	 signal num_completo   : STD_LOGIC_VECTOR(15 downto 0);

begin

	 num_completo <= "101001" & SW;

    Display_TimerRefresh: Timer
    generic map ( N => TICKS_REFRESH )
    port map ( CLK => CLK, RST => RST, EOT => syn_refresh );

    Display_SelCounter: FreeRunCounter
    generic map ( N => 2 )
    port map ( 
        CLK   => CLK, 
        RST   => RST, 
        INC   => syn_refresh,
        COUNT => sel_wire 
    );

    --Conversor_Binario: BinToBCD
    --port map ( BIN_IN => "000111" & SW, DIG_1 => d1, DIG_2 => d2, DIG_3 => d3, DIG_4 => d4 );
	 
	 d4 <= num_completo(15 downto 12);
    d3 <= num_completo(11 downto 8);  
    d2 <= num_completo(7 downto 4);  
    d1 <= num_completo(3 downto 0);

    Display_Mux: Multiplex4To1
    port map ( DIG1 => d1, DIG2 => d2, DIG3 => d3, DIG4 => d4, SEL => sel_wire, NIB => nib_wire );

    --Display_7SegDec: Decoder74LS47
    --port map ( NIB => nib_wire, SEG => SEG );
	 
	 Display_HexDec: HexDecoder
    port map ( NIB => nib_wire, SEG => SEG );

    Display_CatDec: CatodoDecoder
    port map ( SEL => sel_wire, CAT => CAT );

end Structural;