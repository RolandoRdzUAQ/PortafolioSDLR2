Library IEEE;
use IEEE.std_logic_1164.all;

Entity HallFSM is
    port(
    RST : in std_logic;
    CLK : in std_logic;
    ENI : in std_logic;
    ENA : out std_logic;
    ENB : out std_logic;
    ENC : out std_logic;
    SDA : out std_logic;
    SDB : out std_logic;
    SDC : out std_logic
    );
end HallFSM;

Architecture Behavioral of HallFSM is
signal Qp, Qn : std_logic_vector(2 downto 0);
begin
    Combinational : process(Qp, ENI)
    begin
        case Qp is
            when "000" =>
                ENA <= '0';
                ENB <= '0';
                ENC <= '0';
                SDA <= '0';
                SDB <= '0';
                SDC <= '0';

                if ENI = '1' then
                    Qn <= "001";
                else
                    Qn <= Qp;
                end if;
            when "001" =>
                if ENI = '1' then
                    Qn <= "010";
                else
                    Qn <= Qp;
                end if;
            when "010" =>
                if ENI = '1' then
                    Qn <= "011";
                else
                    Qn <= Qp;
                end if;
            when "011" =>
                if ENI = '1' then
                    Qn <= "100";
                else
                    Qn <= Qp;
                end if;
            when "100" =>
                if ENI = '1' then
                    Qn <= "101";
                else
                    Qn <= Qp;
                end if;
            when others =>
                if ENI = '1' then
                    Qn <= "000";
                else
                    Qn <= Qp;
                end if;
        end case;
    end process Combinational;

    Sequential : process(RST, CLK)
    begin
        if RST = '0' then
            Qp <= (others => '0');
        elsif CLK'event and CLK = '1' then
            Qp <= Qn;
        end if;
    end process Sequential;

end Behavioral;
