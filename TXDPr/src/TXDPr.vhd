library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Transmitter is
    port(
        CLK : in STD_LOGIC;
        RST : in STD_LOGIC;
        DIN : in STD_LOGIC_VECTOR(7 downto 0);
        STR : in STD_LOGIC;
        RDY : out STD_LOGIC;
        TXD : out STD_LOGIC
    );
end Transmitter;

architecture Structural of Transmitter is
	component AsynchronousTransmitter is
    port(
        CLK : in STD_LOGIC;
        RST : in STD_LOGIC;
        DIN : in STD_LOGIC_VECTOR(7 downto 0);
        STR : in STD_LOGIC;
        RDY : out STD_LOGIC;
        TXD : out STD_LOGIC
    );
end component;
begin

    
end architecture Structural;