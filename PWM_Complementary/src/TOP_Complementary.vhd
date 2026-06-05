library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ComplementaryPWM is
    generic(
        Frequency : INTEGER := 19800;
        nBits     : INTEGER := 8;
        DTCycles  : INTEGER := 7
    );
    port(
        CLK   : in STD_LOGIC;
        RST   : in STD_LOGIC;
        DUTY  : in STD_LOGIC_VECTOR(nBits-1 downto 0);
        PWM_H : out STD_LOGIC;
        PWM_L : out STD_LOGIC
    );
end ComplementaryPWM;

architecture Structural of ComplementaryPWM is

    component PWM is
        generic(
            Frequency : INTEGER := 25000;
            nBits : INTEGER := 8
        );
        port(
            CLK  : IN STD_LOGIC;
            RST  : IN STD_LOGIC;
            DUTY : in STD_LOGIC_VECTOR(nBits-1 downto 0);
            PWM  : OUT STD_LOGIC
        );
    end component;

    component DeathTimeGen is
        generic(
            DTCycles : integer := 10
        );
        port(
            CLK  : in std_logic;
            RST  : in std_logic;
            XIN  : in std_logic;
            XOUT : out std_logic
        );
    end component;

    signal syn_raw_pwm     : STD_LOGIC;
    signal syn_not_raw_pwm : STD_LOGIC;

begin

    U_PWM_Base : PWM
    generic map(
        Frequency => Frequency,
        nBits     => nBits
    )
    port map(
        CLK  => CLK,
        RST  => RST,
        DUTY => DUTY,
        PWM  => syn_raw_pwm
    );

    syn_not_raw_pwm <= not syn_raw_pwm;

    U_DT_High : DeathTimeGen
    generic map(
        DTCycles => DTCycles
    )
    port map(
        CLK  => CLK,
        RST  => RST,
        XIN  => syn_raw_pwm,
        XOUT => PWM_H
    );

    U_DT_Low : DeathTimeGen
    generic map(
        DTCycles => DTCycles
    )
    port map(
        CLK  => CLK,
        RST  => RST,
        XIN  => syn_not_raw_pwm,
        XOUT => PWM_L
    );

end Structural;