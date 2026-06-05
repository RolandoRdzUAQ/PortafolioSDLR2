library ieee;
use ieee.std_logic_1164.all;
entity AsyncronousReceiver is 
    generic(busWidth: integer :=8);
port(
    CLK : in std_logic;
    RST : in std_logic;
    RXD : in std_logic;
    DOUT : out std_logic_vector (busWidth+1 downto 0);
    RDY : out std_logic
    );	 
end AsyncronousReceiver;	

architecture Structural of AsyncronousReceiver is
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
	for all: CountDown use entity work.CountDown(Behavioral);
	component FallingEd
	port(
		CLk : in STD_LOGIC;
		RST : in STD_LOGIC;
		XIN : in STD_LOGIC;
		XRE : out STD_LOGIC
	);
	end component;
	for all: FallingEd use entity work.FallingEd(Behavioral);
	component LatchSR
	port(
		CLk : in STD_LOGIC;
		RST : in STD_LOGIC;
		CLR : in STD_LOGIC;
		SET : in STD_LOGIC;
		SOUT : out STD_LOGIC
	);
	end component;
	for all: LatchSR use entity work.LatchSR(Behavioral);
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
	for all: Deserializer use entity work.Deserializer(Behavioral);

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
	for all: Timer use entity work.Timer(Behavioral);
	component Toggle
	port(
		CLk : in STD_LOGIC;
		RST : in STD_LOGIC;
		TOG : in STD_LOGIC;
		TGS : out STD_LOGIC
	);
	end component;
	for all: Toggle use entity work.Toggle(Behavioral); 
    signal XRE, TGS, EOC, ENA, SHF, SYN : std_logic;
	 Signal DOUT_8 : std_logic_vector(busWidth-1 downto 0);
begin
	Label1 : FallingEd
	port map(
		CLk => CLk,
		RST => RST,
		XIN => RXD,
		XRE => XRE
	); 
	Label2 : LatchSR
	port map(
		CLk => CLk,
		RST => RST,
		CLR => EOC,
		SET => XRE,
		SOUT => ENA
	);
	Label3 : Timer
	generic map(
		Ticks => 217
	)
	port map(
		CLK => CLK,
		RST => ENA,
		EOT => SYN
	); 
	Label4 : Toggle
	port map(
		CLk => CLk,
		RST => ENA,
		TOG => SYN,
		TGS => TGS
	);	
	Label5 : Deserializer
	generic map(
		busWidth => busWidth
	)
	port map(
		CLK => CLK,
		RST => RST,
		BIN => RXD,
		SHF => SHF,
		DOUT => DOUT_8
	);	 
DOUT<="00"&DOUT_8;	
	Label6 : CountDown
	generic map(
		N => busWidth+1
	)
	port map(
		CLK => CLK,
		RST => ENA,
		DEC => SHF,
		RDY => EOC
	);
    SHF <= SYN AND NOT TGS;
end Structural;