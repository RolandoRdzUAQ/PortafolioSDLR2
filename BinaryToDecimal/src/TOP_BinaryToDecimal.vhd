library IEEE;
use IEEE.STD_LOGIC_1164.ALL;		  
use IEEE.NUMERIC_STD.ALL;

Entity BinaryToDecimal is
	Generic(
		N_DISPLAYS : integer := 4	
	);
	Port(
		STR	: in STD_LOGIC;
		RST	: in STD_LOGIC;	   
		CLK : in STD_LOGIC;
		DIN : in STD_LOGIC_VECTOR(8 downto 0);	 
		BTN : in STD_LOGIC;
		SEG  : out STD_LOGIC_VECTOR(6 downto 0); 
	    CAT  : out STD_LOGIC_VECTOR(N_DISPLAYS - 1 downto 0)  
	);
end BinaryToDecimal;


architecture Structural of BinaryToDecimal is

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
	
	component GenericDecimalCounter is
	    Generic ( 
			N : integer := 4 
		); 
	    Port (
	        CLK     : in  STD_LOGIC;
	        RST     : in  STD_LOGIC;
	        ENA     : in  STD_LOGIC; 
	        DEC_OUT : out STD_LOGIC_VECTOR((N*4)-1 downto 0) 
	    );
	end component;	
	
	component RisingEdge is
    port(
        RST : in STD_LOGIC;
        CLK : in STD_LOGIC;
        XIN : in STD_LOGIC;
        RED : out STD_LOGIC
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
	
	component FreeRunCounter is
    generic (
        N : integer := 4
    );
    port (
        INC : in STD_LOGIC;
        CLK : in STD_LOGIC;
        RST : in STD_LOGIC;
        COUNT : out STD_LOGIC_VECTOR(N-1 downto 0)
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
	
	signal syn_ena : STD_LOGIC := '0';	
	signal syn_gte : STD_LOGIC;	 
	signal syn_clr_n : STD_LOGIC;	 
	signal syn_count : STD_LOGIC_VECTOR(14 downto 0);	  
	signal syn_inc : STD_LOGIC;	  
	signal syn_dec_out : STD_LOGIC_VECTOR((N_DISPLAYS*4)-1 downto 0); 
	signal syn_ena_n : STD_LOGIC;
	signal syn_str_n : STD_LOGIC;
	signal syn_rss : STD_LOGIC;		   
	signal syn_str_n_re : STD_LOGIC;
	signal tick_100ms : STD_LOGIC;
	
	begin
		
	syn_gte <= '1' when unsigned("000000" & DIN) > unsigned(syn_count) else '0';
	--syn_gte <= '1' when unsigned("111111" & DIN) > unsigned(syn_count) else '0';
	--syn_gte <= '0' when 50000000 > unsigned(syn_count) else '1';
	syn_clr_n <= not (syn_gte);
	syn_inc <= syn_gte and syn_ena;			
	syn_ena_n <= not syn_ena;
	syn_str_n <= not STR;
	syn_rss <= RST and (not tick_100ms);-- and STR;

	U00_AutoStart : Timer
   generic map(
       N => 5000000 -- 100 milisegundos a 50 MHz
   )
   port map(
       CLK => CLK,
       RST => RST,
       EOT => tick_100ms
   );
	
	U00 : RisingEdge
    port map(
        RST => RST,
        CLK => CLK,
        XIN => syn_str_n,
        RED => syn_str_n_re
    );
	
	U01 : LatchSR
	port map(
        RST   => RST,
        CLK   => CLK,
        SET   => tick_100ms,--syn_str_n_re,
        CLEAR => syn_clr_n,
        SOUT  => syn_ena
    );			
	
	U02 : FreeRunCounter
	generic map(
        N => 15
    )
    port map(
        INC => '1',
        CLK => CLK,
        RST => syn_ena,
        COUNT => syn_count
    );					   
	
	U03 : GenericDecimalCounter
    Generic map( 
		N => N_DISPLAYS
	) 
    Port map(
        CLK     => CLK,
        RST     => syn_rss,
        ENA     => syn_inc,
        DEC_OUT => syn_dec_out
    );					  
	
	U04 : ManejoDisplaysGenerico
    Generic map(
        N_DISPLAYS    => N_DISPLAYS,     
        TICKS_REFRESH => 50000   
    )
    Port map( 
        CLK    => CLK,                    
        RST    => RST,                  
        DIGITS => syn_dec_out, 
        SEG    => SEG, 
        CAT    => CAT
    );
	
end Structural;