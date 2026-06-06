library IEEE;
use ieee.std_logic_1164.all;
use ieee.NUMERIC_STD_UNSIGNED.all;
use ieee.NUMERIC_STD.all;


entity FilterMultiplexor is
    port (
      RST : in STD_LOGIC;
      CLK : in STD_LOGIC;
      SYN : in STD_LOGIC;
      XIN : in STD_LOGIC_VECTOR(15 downto 0);
      SEL : in STD_LOGIC_VECTOR(4 downto 0);
      XOUT : out STD_LOGIC_VECTOR(15 downto 0)
    );
end entity FilterMultiplexor;


architecture Structural of FilterMultiplexor is
  type ArrayData is array (0 to 31) of std_logic_vector(15 downto 0);
  signal Samples : ArrayData;
begin
  Reg0: entity work.LoadRegister
  generic map(
      nBits => 16
  )
  port map(
    CLK => CLK,
    RST => RST,
    LDR => SYN,
    DIN => XIN,
    DOUT => Samples(0)
  );
  
  GEN_REG : for i in 1 to 31 generate
  REGX: entity work.LoadRegister
  generic map(
      nBits => 16
  )
  port map(
    CLK => CLK,
    RST => RST,
    LDR => SYN,
    DIN => Samples(i - 1),
    DOUT => Samples(i)
  );
end generate GEN_REG;

  XOUT <= Samples(to_integer(unsigned(SEL)));

end architecture Structural;
