library IEEE;
use ieee.std_logic_1164.all;
use ieee.STD_LOGIC_SIGNED.all;
use ieee.NUMERIC_STD.all;

entity digitalFIR is
    port (
      RST : in STD_LOGIC;
      CLK : in STD_LOGIC;
      SYN : in STD_LOGIC;
      XIN : in std_logic_vector(15 downto 0);
      YOUT : out std_logic_vector(55 downto 0)
    );
end entity digitalFIR;


architecture Behavioral of digitalFIR is
  signal ENA, EOC : std_logic;
  signal SEL : std_logic_vector(4 downto 0);
  signal XOUT : std_logic_vector(15 downto 0);
  signal BOUT : std_logic_vector(31 downto 0);
  signal MULT : std_logic_vector(47 downto 0);
  signal EMUL : std_logic_vector(55 downto 0);
  signal RSUM : std_logic_vector(55 downto 0);
  signal ACCU : std_logic_vector(55 downto 0);

begin

  U01: entity work.LatchSR
   port map(
      RST => RST,
      CLK => CLK,
      SET => SYN,
      CLEAR => EOC,
      SOUT => ENA
  );
  U02: entity work.FreeRunCounter
   generic map(
      N => 5
  )
   port map(
      INC => '1',
      CLK => CLK,
      RST => ENA,
      COUNT => SEL
  );

  U03: entity work.CountDown
   generic map(
      M => 32
  )
   port map(
      CLK => CLK,
      RST => ENA,
      DEC => '1',
      RDY => EOC
  );

  U04: entity work.FilterMultiplexor
   port map(
      RST => RST,
      CLK => CLK,
      SYN => SYN,
      XIN => XIN,
      SEL => SEL,
      XOUT => XOUT
  );

  U05: entity work.CoefficientsROM
   port map(
      SEL => SEL,
      BOUT => BOUT
  );

  MULT <= std_logic_vector(signed(XOUT) * signed(BOUT));
  EMUL <= std_logic_vector(resize(signed(MULT), EMUL'length));
  RSUM <= std_logic_vector(signed(EMUL) + signed(ACCU));

 U06: entity work.LoadRegister
  generic map(
     nBits => 56
 )
  port map(
     CLK => CLK,
     RST => ENA,
     LDR => '1',
     DIN => RSUM,
     DOUT => ACCU
 );

 U07: entity work.LoadRegister
  generic map(
     nBits => 56
 )
  port map(
     CLK => CLK,
     RST => RST,
     LDR => EOC,
     DIN => ACCU,
     DOUT => YOUT
 );

end architecture Behavioral;
