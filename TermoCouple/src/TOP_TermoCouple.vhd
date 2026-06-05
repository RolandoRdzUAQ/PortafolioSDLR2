library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TOP_Thermocouple is
    port(
        CLK  : in  STD_LOGIC;  -- Reloj de 50 MHz de la DE10-Lite
        RST  : in  STD_LOGIC;  -- Botón de reset (Activo en bajo)
        MISO : in  STD_LOGIC;  -- Señal de datos del MAX6675
        CSE  : out STD_LOGIC;  -- Chip Select al MAX6675
        SCK  : out STD_LOGIC;  -- Reloj SPI al MAX6675
        SEG  : out STD_LOGIC_VECTOR(6 downto 0);            -- A los segmentos del display
        CAT  : out STD_LOGIC_VECTOR(3 downto 0)             -- A los 4 cátodos del display
        -- Nota: Si usas los 6 displays de la tarjeta, ajusta CAT a 5 downto 0
    );
end TOP_Thermocouple;

architecture Structural of TOP_Thermocouple is

    -- 1. Disparador de lecturas (4 Hz)
    component Timer is
        generic( Ticks : integer := 100);
        port(
            CLK : in  std_logic;
            RST : in  std_logic;
            EOT : out std_logic
        );
    end component;

    -- 2. El Maestro SPI (Configurado a 16 bits)
    component SPIMaster is
        generic(
            cFreq : integer := 1000000;
            nBits : integer := 16  -- ¡Importante! 16 bits para el MAX6675
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
    end component;

    -- 3. Registro de carga
    component LoadRegister is
        generic ( nBits : integer := 10 );
        port(
            CLK  : in STD_LOGIC;
            RST  : in STD_LOGIC;
            LDR  : in STD_LOGIC;
            DIN  : in STD_LOGIC_VECTOR(nBits-1 downto 0);	  
            DOUT : out STD_LOGIC_VECTOR(nBits-1 downto 0)	  
        );
    end component;

    -- 4. Convertidor Binario a BCD (Basado en tu diagrama)
    component BinaryToDecimal is
        port(
            DATA : in  STD_LOGIC_VECTOR(9 downto 0);
            ONE  : out STD_LOGIC_VECTOR(3 downto 0);
            TEN  : out STD_LOGIC_VECTOR(3 downto 0);
            HUN  : out STD_LOGIC_VECTOR(3 downto 0);
            THO  : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    -- 5. Tu Módulo de Displays Genérico
    component ManejoDisplaysGenerico is
        Generic (
            N_DISPLAYS    : integer := 4;      
            TICKS_REFRESH : integer := 50000   
        );
        Port ( 
            CLK    : in  STD_LOGIC;                      
            RST    : in  STD_LOGIC;                      
            DIGITS : in  STD_LOGIC_VECTOR((N_DISPLAYS * 4) - 1 downto 0); 
            SEG    : out STD_LOGIC_VECTOR(6 downto 0); 
            CAT    : out STD_LOGIC_VECTOR(N_DISPLAYS - 1 downto 0)  
        );
    end component;

    -- ==========================================
    -- SEÑALES INTERNAS (Los cables de tu diagrama)
    -- ==========================================
    signal syn_wire     : STD_LOGIC;
    signal rdy_wire     : STD_LOGIC;
    signal spi_data_out : STD_LOGIC_VECTOR(15 downto 0);
    
    signal temp_int     : STD_LOGIC_VECTOR(9 downto 0); -- Temperatura en entero
    signal reg_data_out : STD_LOGIC_VECTOR(9 downto 0);
    
    signal bcd_one      : STD_LOGIC_VECTOR(3 downto 0);
    signal bcd_ten      : STD_LOGIC_VECTOR(3 downto 0);
    signal bcd_hun      : STD_LOGIC_VECTOR(3 downto 0);
    signal bcd_tho      : STD_LOGIC_VECTOR(3 downto 0);
    
    signal display_bus  : STD_LOGIC_VECTOR(15 downto 0);

begin

    -- Genera un pulso cada 250ms (50MHz / 4 = 12,500,000)
    U_Trigger: Timer 
        generic map ( Ticks => 12500000 ) 
        port map (
            CLK => CLK,
            RST => RST,
            EOT => syn_wire
        );

    -- Instancia del Maestro SPI
    U_SPI: SPIMaster
        generic map ( cFreq => 1000000, nBits => 16 )
        port map (
            CLK  => CLK,
            RST  => RST,
            STR  => syn_wire,
            MISO => MISO,
            CSE  => CSE,
            SCK  => SCK,
            DOUT => spi_data_out,
            RDY  => rdy_wire
        );

    -- EXTRACCIÓN DE LA TEMPERATURA: 
    -- Tomamos del bit 14 al 5 para tener los grados enteros.
    temp_int <= spi_data_out(14 downto 5);

    -- Registro que guarda el valor cuando el SPI termina (RDY = 1)
    U_Reg: LoadRegister
        generic map ( nBits => 10 )
        port map (
            CLK  => CLK,
            RST  => RST,
            LDR  => rdy_wire,   -- En tu diagrama se llama DREC
            DIN  => temp_int,
            DOUT => reg_data_out
        );

    -- Convertidor de Binario (10 bits) a 4 dígitos BCD
    U_B2D: BinaryToDecimal
        port map (
            DATA => reg_data_out,
            ONE  => bcd_one,
            TEN  => bcd_ten,
            HUN  => bcd_hun,
            THO  => bcd_tho
        );

    -- Empaquetamos los 4 dígitos BCD en el bus de 16 bits que pide tu display
    -- El orden es: Miles & Centenas & Decenas & Unidades
    display_bus <= bcd_tho & bcd_hun & bcd_ten & bcd_one;

    -- Tu módulo genérico de displays
    U_Display: ManejoDisplaysGenerico
        generic map (
            N_DISPLAYS => 4,
            TICKS_REFRESH => 50000
        )
        port map (
            CLK    => CLK,
            RST    => RST,
            DIGITS => display_bus,
            SEG    => SEG,
            CAT    => CAT
        );

end Structural;