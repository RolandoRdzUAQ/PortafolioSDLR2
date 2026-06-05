library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ReactionTimeGame is
    Port ( 
        CLK  : in  STD_LOGIC;                     
        RST  : in  STD_LOGIC;                     
        BTN  : in  STD_LOGIC;                     
        ALRM : out STD_LOGIC;                     
        TIME_LEDS : out STD_LOGIC_VECTOR(9 downto 0) 
    );
end ReactionTimeGame;

architecture Structural of ReactionTimeGame is

    constant TICKS_ESPERA : integer := 500000000; 
    constant TICKS_MS     : integer := 50000;

    component Timer is
        generic( N : INTEGER := 10 );
        port(
            CLK : IN STD_LOGIC;
            RST : IN STD_LOGIC;
            EOT : OUT STD_LOGIC
        );
    end component;

    component LatchSR is
        port(
            RST : in STD_LOGIC;
            CLK : in STD_LOGIC;
            SET : in STD_LOGIC;
            CLEAR : in STD_LOGIC;
            SOUT : out STD_LOGIC
        );
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

    signal syn_start_pulse : STD_LOGIC;
    signal syn_active      : STD_LOGIC;
    signal syn_tick_1ms    : STD_LOGIC;  
    signal BTN_n           : STD_LOGIC;
    signal rst_timer_ms    : STD_LOGIC; 

begin
	
    BTN_n <= not BTN;

    ALRM <= syn_active;
    rst_timer_ms <= syn_active;

    U01_DelayTimer: Timer
    generic map (
        N => TICKS_ESPERA
    )
    port map (
        CLK => CLK,
        RST => RST,
        EOT => syn_start_pulse
    );

    U02_ControlLatch: LatchSR
    port map (
        CLK   => CLK,
        RST   => RST,
        SET   => syn_start_pulse,
        CLEAR => BTN_n,
        SOUT  => syn_active
    );

    U03_MsTimer: Timer
    generic map (
        N => TICKS_MS
    )
    port map (
        CLK => CLK,
        RST => rst_timer_ms, 
        EOT => syn_tick_1ms
    );

    U04_ResultCounter: FreeRunCounter
    generic map (
        N => 10
    )
    port map (
        CLK   => CLK,
        RST   => RST,
        INC   => syn_tick_1ms,
        COUNT => TIME_LEDS
    );

end Structural;
