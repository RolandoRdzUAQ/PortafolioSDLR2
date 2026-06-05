library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ReactionTimeGame is
    Generic (
        N_DISPLAYS : integer := 4
    );
    Port ( 
        CLK  : in  STD_LOGIC;                      
        RST  : in  STD_LOGIC;                      
        BTN  : in  STD_LOGIC;                      
        ALRM : out STD_LOGIC;                      
        SEG  : out STD_LOGIC_VECTOR(6 downto 0); 
        CAT  : out STD_LOGIC_VECTOR(N_DISPLAYS - 1 downto 0)  
    );
end ReactionTimeGame;

architecture Structural of ReactionTimeGame is

    constant TICKS_ESPERA  : integer := 500000000; 
    constant TICKS_MS      : integer := 50000;

    component Timer is
        generic( N : INTEGER := 10 );
        port( CLK, RST : in STD_LOGIC; EOT : out STD_LOGIC );
    end component;

    component LatchSR is
        port( RST, CLK, SET, CLEAR : in STD_LOGIC; SOUT : out STD_LOGIC );
    end component;

    component GenericDecimalCounter is
        generic ( N : integer := 4 );
        port ( CLK, RST, ENA : in STD_LOGIC; DEC_OUT : out STD_LOGIC_VECTOR((N*4)-1 downto 0) );
    end component;

    component ManejoDisplaysGenerico is
        Generic ( N_DISPLAYS : integer := 4; TICKS_REFRESH : integer := 50000 );
        Port (
            CLK, RST : in STD_LOGIC;
            DIGITS   : in STD_LOGIC_VECTOR((N_DISPLAYS * 4) - 1 downto 0);
            SEG      : out STD_LOGIC_VECTOR(6 downto 0);
            CAT      : out STD_LOGIC_VECTOR(N_DISPLAYS - 1 downto 0)
        );
    end component;

    signal syn_start_pulse : STD_LOGIC;
    signal syn_active      : STD_LOGIC; 
    signal syn_tick_1ms    : STD_LOGIC;   
    signal BTN_n           : STD_LOGIC;
    signal rst_timer_ms    : STD_LOGIC; 
    signal all_digits      : STD_LOGIC_VECTOR((N_DISPLAYS * 4) - 1 downto 0);
	signal syn_start_pulse_n   : STD_LOGIC;
begin

    BTN_n <= not BTN;
    ALRM <= syn_active;           
    rst_timer_ms <= syn_active;
	syn_start_pulse_n <= not syn_start_pulse;

    Game_DelayTimer: Timer
    generic map ( N => TICKS_ESPERA )
    port map ( CLK => CLK, RST => RST, EOT => syn_start_pulse );

    Game_Latch: LatchSR
    port map ( CLK => CLK, RST => RST, SET => syn_start_pulse, CLEAR => BTN_n, SOUT => syn_active );

    Game_MsTimer: Timer
    generic map ( N => TICKS_MS )
    port map ( CLK => CLK, RST => rst_timer_ms, EOT => syn_tick_1ms );

    Game_DecCounter: GenericDecimalCounter
    generic map ( N => N_DISPLAYS )
    port map ( CLK => CLK, RST => syn_start_pulse_n, ENA => syn_tick_1ms, DEC_OUT => all_digits );

    Control_Displays: ManejoDisplaysGenerico
    generic map ( 
        N_DISPLAYS => N_DISPLAYS,
        TICKS_REFRESH => 50000
    )
    port map (
        CLK    => CLK,
        RST    => RST,
        DIGITS => all_digits,
        SEG    => SEG,
        CAT    => CAT
    );

end Structural;