library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity AsynchronousTransmitter is
    port(
        CLK : in STD_LOGIC;
        RST : in STD_LOGIC;
        DIN : in STD_LOGIC_VECTOR(7 downto 0);
        STR : in STD_LOGIC;
        RDY : out STD_LOGIC;
        TXD : out STD_LOGIC
    );
end AsynchronousTransmitter;


architecture Structural of AsynchronousTransmitter is
    component Serializer is
    generic (
        nBits : integer := 8
    );
    port(
        CLK : in STD_LOGIC;
        RST : in STD_LOGIC;
        LDR : in STD_LOGIC;
        SHF : in STD_LOGIC;
        DIN : in STD_LOGIC_VECTOR(nBits-1 downto 0);
        DOUT : out STD_LOGIC
    );
    end component;
    component LatchSR is
        port(
            RST   : in STD_LOGIC;
            CLK   : in STD_LOGIC;
            SET   : in STD_LOGIC;
            CLEAR : in STD_LOGIC;
            SOUT  : out STD_LOGIC
        );
    end component;
    component Timer is
        generic( N : INTEGER := 10 );
        port(
            CLK : IN STD_LOGIC;
            RST : IN STD_LOGIC;
            EOT : OUT STD_LOGIC
        );
    end component;
    component CountDown is
        generic(
            M : INTEGER := 15
        );
        port(
            CLK : IN STD_LOGIC;
            RST : IN STD_LOGIC;
            DEC : IN STD_LOGIC;
            RDY : OUT STD_LOGIC
        );
    end component;

    signal EOC, ENA, SHF : STD_LOGIC;
    signal AUX : std_logic_vector(8 downto 0);
begin
   AUX <= DIN & '0';
   RDY <= NOT(ENA);
   U01 : LatchSR port map(RST => RST, CLK => CLK, SET => STR, CLEAR => EOC, SOUT => ENA);
   U02 : Timer generic map(N => 434) port map(CLK => CLK, RST => ENA, EOT => SHF);
   U03 : Serializer generic map(nBits => 9) port map(CLK => CLK, RST => RST, LDR => STR, SHF => SHF, DIN => AUX, DOUT => TXD); 
   U04 : CountDown generic map(M => 10) port map(CLK => CLK, RST => ENA, DEC => SHF, RDY => EOC);
    
    
end architecture Structural;