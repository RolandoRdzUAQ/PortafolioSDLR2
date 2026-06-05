library ieee;
use ieee.std_logic_1164.all;

Entity SPIMaster is
    generic(
    cFreq : integer := 1000000;
    nBits : integer := 8
    );
    port(
    RST  : in std_logic;
    CLK  : in std_logic;
    STR  : in std_logic;
    MISO : in std_logic;
    CSE  : out std_logic;
    SCK  : out std_logic;
    DOUT : out std_logic_vector(nBits - 1 downto 0);
    RDY  : out std_logic
    );
end SPIMaster;

architecture Structural of SPIMaster is
	component CountDown
	generic(
		N : INTEGER := 10
	);
	port(
		CLK : in STD_LOGIC;
		RST : in STD_LOGIC;
		DEC : in STD_LOGIC;
		RDY : out STD_LOGIC
	);
	end component;
	component FallingEd
	port(
		CLk : in STD_LOGIC;
		RST : in STD_LOGIC;
		XIN : in STD_LOGIC;
		XRE : out STD_LOGIC
	);
	end component;
	component LatchSR
	port(
		CLk : in STD_LOGIC;
		RST : in STD_LOGIC;
		CLR : in STD_LOGIC;
		SET : in STD_LOGIC;
		SOUT : out STD_LOGIC
	);
	end component;
	component Deserializer
	generic(
		busWidth : INTEGER := 8
	);
	port(
		CLK : in STD_LOGIC;
		RST : in STD_LOGIC;
		BIN : in STD_LOGIC;
		SHF : in STD_LOGIC;
		DOUT : out STD_LOGIC_VECTOR(busWidth-1 downto 0)
	);
	end component;

	component Timer
	generic(
		Ticks : INTEGER := 100
	);
	port(
		CLK : in STD_LOGIC;
		RST : in STD_LOGIC;
		EOT : out STD_LOGIC
	);
	end component;
	component Toggle
	port(
		CLk : in STD_LOGIC;
		RST : in STD_LOGIC;
		TOG : in STD_LOGIC;
		TGS : out STD_LOGIC
	);
	end component;

		
	signal ENA, SYN, TOG, EOC, SHF : STD_logic;
begin
    -- U01: LatchSR (Tu componente usa SOUT, CLR y SET)
    U01 : LatchSR port map(
        CLk  => CLK,
        RST  => RST,
        CLR  => EOC,  -- EOC apaga el Latch
        SET  => STR,  -- STR enciende el Latch
        SOUT => ENA   -- Tu salida se llama SOUT
    );

    -- U02: Timer (Tu componente usa el genérico Ticks y salida EOT)
    U02 : Timer generic map(
        Ticks => 1e8/(2*cFreq)
    ) port map(
        CLK => CLK,
        RST => ENA,   -- El amigo usa ENA como Reset
        EOT => SYN    -- Tu salida se llama EOT
    );

    -- U03: Toggle (Tu componente usa TGS)
    U03 : Toggle port map(
        CLk => CLK,
        RST => ENA,
        TOG => SYN,
        TGS => TOG    -- Tu salida se llama TGS
    );

    SHF <= SYN AND NOT(TOG);

    -- U04: Deserializer (Tu componente usa el genérico busWidth y entrada BIN)
    U04 : Deserializer generic map(
        busWidth => nBits
    ) port map(
        CLK  => CLK,
        RST  => RST,
        BIN  => MISO, -- Tu entrada de datos se llama BIN
        SHF  => SHF,
        DOUT => DOUT
    );

    -- U05: CountDown (Tu componente usa el genérico N)
    U05 : CountDown generic map(
        N => nBits * 2
    ) port map(
        CLK => CLK,
        RST => ENA,
        DEC => SYN,
        RDY => EOC
    );

    CSE <= NOT(ENA);
    RDY <= NOT(ENA);
    SCK <= TOG;
end Structural;