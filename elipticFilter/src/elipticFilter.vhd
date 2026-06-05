Library IEEE;
Use IEEE.Std_logic_1164.all;
Use IEEE.Numeric_Std.all;

Entity elipticFilter is
	PORT(
		RST : in Std_logic;
		CLK : in Std_Logic;
		STR : in Std_Logic;
		XIN : in Std_Logic_Vector(63 downto 0);
		YOUT : out Std_Logic_Vector(63 downto 0)
	);
End Entity elipticFilter;   

Architecture Structural of elipticFilter is  
Component LatchSR is
	PORT(
	RST : in Std_Logic;
	CLK	: in Std_Logic;
	SET : in Std_Logic;
	CLR : in Std_Logic;
	SOUT : out Std_Logic
	);
End Component LatchSR;

Component CountDown is
	GENERIC(
	
		  Num : integer := 10
	);
	PORT(
		RST : in Std_Logic;
		CLK : in Std_Logic;
		DEC : in Std_Logic;
		RDY : out Std_Logic
	);
End Component CountDown;

Component FreeRunCounter is 
	GENERIC(
		nBits : integer := 8
	);
	PORT(
	RST : in Std_Logic;
	CLK : in Std_Logic;
	INC : in Std_Logic;
	CNT : out Std_Logic_Vector(nBits-1 Downto 0)
	);
End Component FreeRunCounter;

Component FreeCounter is
	generic (
		busWidth : integer := 8
		);	
	port (			 
	RST : in std_logic;
	CLK: in std_logic;
	ENA : in std_logic;
	CNT : out std_logic_vector(busWidth - 1 downto 0)
		);
end Component FreeCounter;

Component LoadRegister is
	GENERIC(
		BusWidth : Integer := 7	
	);
	PORT(
	RST : in Std_Logic;
	CLK : in Std_Logic;
	LDR : in Std_Logic;
	DIN : in Std_Logic_Vector(BusWidth - 1 downto 0);
	DOUT : out Std_Logic_Vector(BusWidth - 1 downto 0)
	);											
End Component LoadRegister;	

Component Coefficients_B is
	PORT(
	SEL : in Std_logic_vector(3 downto 0);
	QOUT: out Std_logic_vector(63 downto 0)
	
	);
End Component Coefficients_B;

Component Coefficients_A is
	PORT(
	SEL : in Std_logic_vector(3 downto 0);
	QOUT: out Std_logic_vector(63 downto 0)
	
	);
End Component Coefficients_A;
Signal EOC : Std_logic := '0';
Signal ENA : Std_logic := '0'; 
Signal SEL, SEL_AUX: Std_Logic_vector(3 downto 0):= (Others => '0'); 

Signal XK0, XK1, XK2, XK3 : Std_Logic_Vector(63 downto 0) := (Others => '0'); 
Signal XK4, XK5, XK6, XK7, XK8: Std_Logic_Vector(63 downto 0) := (Others => '0');
Signal XK9, XK10, XK11, XK12: Std_Logic_Vector(63 downto 0) := (Others => '0');	 

Signal YK1, YK2, YK3, YK4 : Std_Logic_Vector(63 downto 0) := (Others => '0'); 
Signal YK5, YK6, YK7, YK8: Std_Logic_Vector(63 downto 0) := (Others => '0');
Signal YK9, YK10, YK11, YK12,YK13: Std_Logic_Vector(63 downto 0) := (Others => '0');

Signal XMUX : Std_Logic_Vector(63 downto 0) := (Others => '0');	
Signal BMUX : Std_Logic_Vector(63 downto 0) := (Others => '0');	
Signal AMUX : Std_Logic_Vector(63 downto 0) := (Others => '0');	
Signal YMUX : Std_Logic_Vector(63 downto 0) := (Others => '0');	  
Signal YAUX : Std_Logic_Vector(127 downto 0) := (Others => '0');
Signal XXX : Std_logic_vector(31 downto 0) := (Others => '0');
Signal MULTB : Std_Logic_Vector(127 downto 0):= (Others =>'0'); 
Signal MULTA : Std_Logic_Vector(127 downto 0):= (Others =>'0');
Signal RSUM : Std_Logic_Vector(127 downto 0) := (Others =>'0');
Signal ACCU : Std_Logic_Vector(127 downto 0) := (Others => '0');

Begin	   	
	
	U01 : latchSR Port Map(RST, CLK, STR, EOC, ENA);	
	U02 : FreeCounter Generic Map(4) Port Map(ENA, CLK, '1', SEL);	 
	U03 : CountDown Generic Map(13) Port Map(ENA, CLK, '1',EOC);
	
	U04 : LoadRegister Generic Map(64) Port Map(RST, CLK, STR, XIN, XK0); 
	U05 : LoadRegister Generic Map(64) Port Map(RST, CLK, STR, XK0, XK1);
	U06 : LoadRegister Generic Map(64) Port Map(RST, CLK, STR, XK1, XK2); 
	U07 : LoadRegister Generic Map(64) Port Map(RST, CLK, STR, XK2, XK3);  
	U08 : LoadRegister Generic Map(64) Port Map(RST, CLK, STR, XK3, XK4); 
	U09 : LoadRegister Generic Map(64) Port Map(RST, CLK, STR, XK4, XK5);
	U10 : LoadRegister Generic Map(64) Port Map(RST, CLK, STR, XK5, XK6); 
	U11 : LoadRegister Generic Map(64) Port Map(RST, CLK, STR, XK6, XK7); 
	U12 : LoadRegister Generic Map(64) Port Map(RST, CLK, STR, XK7, XK8); 
	U13 : LoadRegister Generic Map(64) Port Map(RST, CLK, STR, XK8, XK9);
	U14 : LoadRegister Generic Map(64) Port Map(RST, CLK, STR, XK9, XK10); 
  U15 : LoadRegister Generic Map(64) Port Map(RST, CLK, STR, XK10, XK11);  
	U16 : LoadRegister Generic Map(64) Port Map(RST, CLK, STR, XK11, XK12); 

	With SEL Select XMUX <= XK0 when "0000", XK1 when "0001", XK2 when "0010", XK3 when "0011", 
	XK4 when "0100", XK5 when "0101", XK6 when "0110", XK7 when "0111", XK8 when "1000", XK9 when "1001",
	XK10 when "1010", XK11 when "1011", XK12 when "1100", (Others => '0') when others;
	
	U17 : LoadRegister Generic Map(64) Port Map(RST, CLK, STR, YAUX(111 downto 48), YK1); 
	U18 : LoadRegister Generic Map(64) Port Map(RST, CLK, STR, YK1, YK2);
	U19 : LoadRegister Generic Map(64) Port Map(RST, CLK, STR, YK2, YK3); 
	U20 : LoadRegister Generic Map(64) Port Map(RST, CLK, STR, YK3, YK4);  
	U21 : LoadRegister Generic Map(64) Port Map(RST, CLK, STR, YK4, YK5); 
	U22 : LoadRegister Generic Map(64) Port Map(RST, CLK, STR, YK5, YK6);
	U23 : LoadRegister Generic Map(64) Port Map(RST, CLK, STR, YK6, YK7); 
	U24 : LoadRegister Generic Map(64) Port Map(RST, CLK, STR, YK7, YK8); 
	U25 : LoadRegister Generic Map(64) Port Map(RST, CLK, STR, YK8, YK9); 
	U26 : LoadRegister Generic Map(64) Port Map(RST, CLK, STR, YK9, YK10);
	U27 : LoadRegister Generic Map(64) Port Map(RST, CLK, STR, YK10, YK11); 
	U28 : LoadRegister Generic Map(64) Port Map(RST, CLK, STR, YK11, YK12);  
	U29 : LoadRegister Generic Map(64) Port Map(RST, CLK, STR, YK12, YK13); 
	
	With SEL Select YMUX <= YK1 when "0000", YK2 when "0001", YK3 when "0010", YK4 when "0011", 
	YK5 when "0100", YK6 when "0101", YK7 when "0110", YK8 when "0111", YK9 when "1000", YK10 when "1001",
	YK11 when "1010", YK12 when "1011", YK13 when "1100", (Others => '0') when others;
	
	SEL_AUX <= Std_Logic_Vector(unsigned(SEL) + 1);
	
	U30 : Coefficients_B Port Map(SEL,BMUX);
	U31 : Coefficients_A Port Map(SEL_AUX,AMUX);
	
	MULTB <= Std_Logic_Vector(signed(BMUX) * signed(XMUX));
	MULTA <= Std_Logic_Vector(signed(AMUX) * (-signed(YMUX)));
	
	RSUM <= Std_Logic_Vector(signed(MULTA) + signed(MULTB) + signed(ACCU));	 
	
	
	U32 : LoadRegister Generic Map(128) Port Map(ENA, CLK, '1', RSUM, ACCU);
	U33 : LoadRegister Generic Map(128) Port Map(RST, CLK, EOC, ACCU, YAUX);
	
	YOUT <= YAUX(111 downto 48);
	
End Architecture Structural;
