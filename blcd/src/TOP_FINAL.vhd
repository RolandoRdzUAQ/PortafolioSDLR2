library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity BLDC_Top is
    generic(
        FCLK_HZ  : integer := 50_000_000; -- Reloj FPGA (50 MHz)
        PWM_BITS : integer := 8           -- Resolucion del PWM (0 a 255)
    );
    port(
        CLK   : in std_logic;
        RST   : in std_logic;
        
        -- Entradas de los comparadores LM311
        HA    : in std_logic; 
        HB    : in std_logic; 
        HC    : in std_logic; 
        DUTY  : in std_logic_vector(PWM_BITS-1 downto 0);
        
        -- Indicadores LED
        Led   : out std_logic_vector(2 downto 0);
		  change : out std_logic;

        -- Salidas hacia los drivers IR2110
        HIN_A : out std_logic;
        LIN_A : out std_logic;
        HIN_B : out std_logic;
        LIN_B : out std_logic;
        HIN_C : out std_logic;
        LIN_C : out std_logic
    );
end BLDC_Top;

architecture Structural of BLDC_Top is

    
    constant TMR_8_3MS_CYCLES : integer := (FCLK_HZ / 10000) * 25; 
    constant TMR_1S_CYCLES    : integer := FCLK_HZ;                
    constant DT_3US_CYCLES    : integer := (FCLK_HZ * 1) / 1000000;
    constant BLANK_2MS_CYCLES : integer := 50000;--(FCLK_HZ * 1) / 1000; 

    
    component Timer is
        generic( N : INTEGER := 10 );
        port( CLK : in STD_LOGIC; RST : in STD_LOGIC; EOT : out STD_LOGIC );
    end component;

    component LatchSR is
        port( RST : in STD_LOGIC; CLK : in STD_LOGIC; SET : in STD_LOGIC; CLEAR : in STD_LOGIC; SOUT : out STD_LOGIC );
    end component;

    component HallZeroCross is       
        port( RST : in std_logic; CLK : in std_logic; PHA : in std_logic; PHB : in std_logic; PHC : in std_logic; ZCR : out std_logic );
    end component;

    component HallFSM is
        port( RST : in std_logic; CLK : in std_logic; ENI : in std_logic; ENA : out std_logic; ENB : out std_logic; ENC : out std_logic; SDA : out std_logic; SDB : out std_logic; SDC : out std_logic );
    end component;

    component FreeRunCounter is
        generic ( N : integer := 4 );
        port ( INC : in STD_LOGIC; CLK : in STD_LOGIC; RST : in STD_LOGIC; COUNT : out STD_LOGIC_VECTOR(N-1 downto 0) );
    end component;

    component DeadTimeGen is
        generic( DTCycles : integer := 10 );
        port( CLK  : in std_logic; RST  : in std_logic; XIN  : in std_logic; XOUT : out std_logic );
    end component;

    component debounce IS
        GENERIC( CYCLES : INTEGER := 5000 );
        PORT( clk : IN STD_LOGIC; reset_n : IN STD_LOGIC; button : IN STD_LOGIC; result : OUT STD_LOGIC );
    end component;

    
    signal tck_8_3ms : std_logic;
    signal eoc_1s    : std_logic;
    signal init_sig  : std_logic;
    signal zcr_sig   : std_logic;
    signal syn_sig   : std_logic;

    
    signal blank_cnt    : integer range 0 to BLANK_2MS_CYCLES := 0;
    signal zcr_filtered : std_logic;

    
    signal cnt_pwm   : std_logic_vector(PWM_BITS-1 downto 0);
    signal pwm_sig   : std_logic;

    
    signal ena, enb, enc : std_logic;
    signal sda, sdb, sdc : std_logic;
    signal ina, inb, inc : std_logic;

    
    signal ha_clean, hb_clean, hc_clean : std_logic;
	 
	 
    signal prs_cnt   : integer range 0 to 7 := 0;
    signal pwm_tick  : std_logic;
	 
	 signal test_toggle : std_logic := '0';

begin

    -- 1. FILTROS ANTI-REBOTES 
    Inst_Debounce_A: debounce generic map(CYCLES => 5)
        port map(clk => CLK, reset_n => RST, button => HA, result => ha_clean);

    Inst_Debounce_B: debounce generic map(CYCLES => 5)
        port map(clk => CLK, reset_n => RST, button => HB, result => hb_clean);

    Inst_Debounce_C: debounce generic map(CYCLES => 5)
        port map(clk => CLK, reset_n => RST, button => HC, result => hc_clean);

    -- 2. TIMERS Y LATCH (Arranque de 1s)
    Inst_Timer_8_3ms: Timer generic map (N => TMR_8_3MS_CYCLES)
        port map(CLK => CLK, RST => RST, EOT => tck_8_3ms);

    Inst_Timer_1s: Timer generic map (N => TMR_1S_CYCLES)
        port map(CLK => CLK, RST => RST, EOT => eoc_1s);

    Inst_Latch: LatchSR port map(
        RST => RST, CLK => CLK, SET => eoc_1s, CLEAR => '0', SOUT => init_sig
    );
    
    
    Led(0) <= HA;
    Led(1) <= HB;
    Led(2) <= HC;
    
    
    Inst_ZCR: HallZeroCross port map(
        RST => RST, CLK => CLK, 
        PHA => HA, PHB => HB, PHC => HC, 
        ZCR => zcr_sig
    );
  
    -- syn_sig <= zcr_sig when init_sig = '1' else tck_8_3ms;
	 syn_sig <= zcr_sig when init_sig = '1' else tck_8_3ms;
	 

	 process(CLK)
    begin
        if rising_edge(CLK) then
            if syn_sig = '1' then
                test_toggle <= not test_toggle; 
            end if;
        end if;
    end process;
    
    change <= test_toggle; 
	 
    Inst_FSM: HallFSM port map(
        RST => RST, CLK => CLK, ENI => syn_sig,
        ENA => ena, ENB => enb, ENC => enc,
        SDA => sda, SDB => sdb, SDC => sdc
    );

    process(CLK)
    begin
        if rising_edge(CLK) then
            if prs_cnt = 7 then
                prs_cnt <= 0;
                pwm_tick <= '1';
            else
                prs_cnt <= prs_cnt + 1;
                pwm_tick <= '0';
            end if;
        end if;
    end process;

    Inst_PWM_Cnt: FreeRunCounter generic map(N => PWM_BITS)
        port map(INC => pwm_tick, CLK => CLK, RST => RST, COUNT => cnt_pwm);

    pwm_sig <= '1' when unsigned(cnt_pwm) < unsigned(DUTY) else '0';

    ina <= ena and pwm_sig;
    inb <= enb and pwm_sig;
    inc <= enc and pwm_sig;

    DT_HA: DeadTimeGen generic map(DTCycles => DT_3US_CYCLES) port map(CLK=>CLK, RST=>RST, XIN=>ina, XOUT=>HIN_A);
    DT_LA: DeadTimeGen generic map(DTCycles => DT_3US_CYCLES) port map(CLK=>CLK, RST=>RST, XIN=>sda, XOUT=>LIN_A);
    DT_HB: DeadTimeGen generic map(DTCycles => DT_3US_CYCLES) port map(CLK=>CLK, RST=>RST, XIN=>inb, XOUT=>HIN_B);
    DT_LB: DeadTimeGen generic map(DTCycles => DT_3US_CYCLES) port map(CLK=>CLK, RST=>RST, XIN=>sdb, XOUT=>LIN_B);
    DT_HC: DeadTimeGen generic map(DTCycles => DT_3US_CYCLES) port map(CLK=>CLK, RST=>RST, XIN=>inc, XOUT=>HIN_C);
    DT_LC: DeadTimeGen generic map(DTCycles => DT_3US_CYCLES) port map(CLK=>CLK, RST=>RST, XIN=>sdc, XOUT=>LIN_C);

end Structural;