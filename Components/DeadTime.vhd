library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity DeathTimeGen is
	generic(
		DTCycles : integer := 10
	);
	port(
		CLK : in std_logic;
		RST : in std_logic;
		XIN : in std_logic;
		XOUT : out std_logic
	);
end DeathTimeGen;
architecture Behavioral of DeathTimeGen is
	SIGNAL Cn, Cp : std_logic_vector(DTCycles-1 downto 0);
begin
	combinational : process(XIN, Cp)
	begin
		Cn <= Cp(DTCycles-2 downto 0) & XIN;
		if Cp = (DTCycles-1 downto 0 => '1') then
			XOUT <= '1';
		else
			XOUT <= '0';
		end if;
	end process combinational;

	Sequencial : process(CLK, RST)
	begin
	if RST = '0' then
		Cp <= (DTCycles-1 downto 0 => '0');
	elsif CLK'event and CLK = '1' then
		Cp <= Cn;
	end if;
	end process Sequencial;
	
end Behavioral;