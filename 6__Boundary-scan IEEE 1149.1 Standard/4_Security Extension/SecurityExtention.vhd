--******************************************************************************
--	Filename:		SecurityExtension.vhd
--	Project:		Security extension for IEEE Std 1149.1 
--  Version:		0.10
--	History:
--	Date:			17 Nov 2022
--	Last Author: 	Shahab Karbasian
--  Copyright (C) 2022 University of Tehran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--
--******************************************************************************
--	File content description:
--	SecurityExtension                               
--******************************************************************************

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
ENTITY SecurityExtension IS 
    GENERIC (Length : INTEGER := 20); 
    PORT(
	    TDI,UpdateDR,shiftDR,CaptureDR,ClockDR,En_KLSR,En_KR,En_LR : IN STD_LOGIC;
		TDO, Locked :out STD_LOGIC);	 
END SecurityExtension;
 
ARCHITECTURE str OF SecurityExtension IS
signal KLSR_out:STD_LOGIC_VECTOR(Length-1 DOWNTO 0);
signal KeyCode:STD_LOGIC_VECTOR	(Length-1 DOWNTO 0):=(others=>'0');
signal LockCode:STD_LOGIC_VECTOR(Length-1 DOWNTO 0):=(others=>'0');

	COMPONENT LockRegister_Block IS
		GENERIC (Length : INTEGER := 20); 
        PORT(Update, Write_Enable  : IN STD_LOGIC;
	    Din : IN STD_LOGIC_VECTOR (Length-1 DOWNTO 0);	       
	    Dout : OUT STD_LOGIC_VECTOR (Length-1 DOWNTO 0));
    END COMPONENT;
	
	COMPONENT KeyRegister_Block IS
		GENERIC (Length : INTEGER := 20); 
        PORT(Update, Write_Enable,Clear_Key  : IN STD_LOGIC;
	    Din : IN STD_LOGIC_VECTOR (Length-1 DOWNTO 0);	       
	    Dout : OUT STD_LOGIC_VECTOR (Length-1 DOWNTO 0));
    END COMPONENT;
	
	COMPONENT KLSRegister_Block IS
		GENERIC (Length : INTEGER := 20); 
        PORT(TDI, CLK, Capture, Enable,shift : IN STD_LOGIC;	    	    
	    TDO : OUT STD_LOGIC;
	    Dout : OUT STD_LOGIC_VECTOR (Length-1 DOWNTO 0));
    END COMPONENT;
	
	COMPONENT Comprator IS
		GENERIC (Length : INTEGER := 20); 
        PORT(Din1 : IN STD_LOGIC_VECTOR (Length-1 DOWNTO 0);	  
		Din2 : IN STD_LOGIC_VECTOR (Length-1 DOWNTO 0);			
	    Locked : OUT STD_LOGIC);
    END COMPONENT;
	
BEGIN
LockRegister: LockRegister_Block
 GENERIC MAP(Length => Length) 
 PORT MAP(
	Update 		=> UpdateDR,
	Write_Enable=> En_LR,
	Din			=> KLSR_out,
	Dout		=> LockCode);
	
KeyRegister:  KeyRegister_Block
 GENERIC MAP(Length => Length) 
 PORT MAP(
	Update		=> UpdateDR,
	Write_Enable=> En_KR,
	Clear_Key	=> En_LR,
	Din			=> KLSR_out,
	Dout		=> KeyCode);
	
KLSRegister:  KLSRegister_Block
  GENERIC MAP(Length => Length)
  PORT MAP(
	TDI		=> TDI,
	CLK		=> ClockDR,
	Capture	=> CaptureDR,
	Enable	=> En_KLSR,
	shift	=> shiftDR,
	TDO		=> TDO,
	Dout	=> KLSR_out);
	
Comprator1 :   Comprator
  GENERIC MAP(Length => Length)
  PORT MAP(
	Din1	=> LockCode,
	Din2	=> KeyCode,
	Locked	=> Locked);

END str;











--******************************************************************************
--	File content description:
--	Lock_Register                           
--******************************************************************************

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY LockRegister_cell is
    PORT(	    
		Update,Write_Enable,Din  : IN STD_LOGIC;	    
	    Dout : OUT STD_LOGIC);
END LockRegister_cell;
ARCHITECTURE str OF LockRegister_cell IS     	
BEGIN 
    PROCESS (Update, Write_Enable) BEGIN 
	    IF (Update = '1' AND Update'EVENT) THEN               
		    IF (Write_Enable = '1') THEN
		        Dout <= Din;
		    END IF;
        END IF;	
    END PROCESS;    
END str;

----------------------------------------------------
--     LockRegister_Block
----------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY LockRegister_Block IS 
    GENERIC (Length : INTEGER := 20); 
    PORT(
	    Update, Write_Enable  : IN STD_LOGIC;
	    Din : IN STD_LOGIC_VECTOR (Length-1 DOWNTO 0);	       
	    Dout : OUT STD_LOGIC_VECTOR (Length-1 DOWNTO 0));	 
END LockRegister_Block;
 
ARCHITECTURE str OF LockRegister_Block IS   	
    COMPONENT LockRegister_cell IS
        PORT(     
	        Update,Write_Enable,Din : IN STD_LOGIC;	    
			Dout : OUT STD_LOGIC);
    END COMPONENT;
	
BEGIN
    for_gen : FOR i IN 0 TO Length-1 GENERATE 
            Cel_N : LockRegister_cell PORT MAP (Update,Write_Enable,Din(i),Dout(i));
			END GENERATE for_gen;	
END str;





--******************************************************************************
--	File content description:
--	IEEE Std 1149.1 Boundary Scan Key_Register                              
--******************************************************************************

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY KeyRegister_cell is
    PORT(	    
		Update,Write_Enable,Clear_Key,Din : IN STD_LOGIC;	    
	    Dout : OUT STD_LOGIC);
END KeyRegister_cell;
ARCHITECTURE str OF KeyRegister_cell IS     	
BEGIN 
    PROCESS (Update, Write_Enable,Clear_Key) BEGIN 
		IF (Clear_Key= '1' AND Clear_Key'EVENT) THEN
		Dout <= '0';
	    ELSIF (Update = '1' AND Update'EVENT) THEN 			
		    IF (Write_Enable = '1') THEN
		        Dout <= Din;
		    END IF;
        END IF;	
    END PROCESS;    
END str;

----------------------------------------------------
--     KeyRegister_Block
----------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY KeyRegister_Block IS 
    GENERIC (Length : INTEGER := 20); 
    PORT(
	    Update, Write_Enable,Clear_Key  : IN STD_LOGIC;
	    Din : IN STD_LOGIC_VECTOR (Length-1 DOWNTO 0);	       
	    Dout : OUT STD_LOGIC_VECTOR (Length-1 DOWNTO 0));	 
END KeyRegister_Block;
 
ARCHITECTURE str OF KeyRegister_Block IS   	
    COMPONENT KeyRegister_cell IS
        PORT(     
	        Update,Write_Enable,Clear_Key,Din : IN STD_LOGIC;	    
			Dout : OUT STD_LOGIC);
    END COMPONENT;
	
BEGIN
    for_gen : FOR i IN 0 TO Length-1 GENERATE 
            Cel_N : KeyRegister_cell PORT MAP (Update,Write_Enable,Clear_Key,Din(i),Dout(i));
			END GENERATE for_gen;	
END str;







--******************************************************************************
--	File content description:
--	Key/Lock shift Register                               
--******************************************************************************
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY KLSRegister_Cell is
    PORT(
	    Sin, CLK,Capture,Enable,shift  : IN STD_LOGIC;	    
	    Dout : OUT STD_LOGIC);
END KLSRegister_Cell;

ARCHITECTURE str OF KLSRegister_Cell IS 
  	
BEGIN 
    PROCESS (CLK, Capture) BEGIN 
        IF (Capture = '0' AND Capture'EVENT) THEN                        
		    Dout <= '0';
	    ELSIF (CLK = '1' AND CLK'EVENT) THEN               
	        IF (shift = '1' AND Enable= '1' ) THEN
		        Dout <= Sin;
            END IF;
        END IF;	
    END PROCESS;     
END str;

----------------------------------------------------
--     KLSRegister_Block
----------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY KLSRegister_Block IS 
    GENERIC (Length : INTEGER := 20); 
    PORT(
	    TDI, CLK, Capture, Enable,shift : IN STD_LOGIC;	    	    
	    TDO : OUT STD_LOGIC;
	    Dout : OUT STD_LOGIC_VECTOR (Length-1 DOWNTO 0));	 
END KLSRegister_Block;
 
ARCHITECTURE str OF KLSRegister_Block IS      
    SIGNAL temp : STD_LOGIC_VECTOR (Length-1 DOWNTO 0);
    COMPONENT KLSRegister_Cell IS
        PORT(     
	        Sin, CLK,Capture,Enable,shift  : IN STD_LOGIC;	    
			Dout : OUT STD_LOGIC);
    END COMPONENT;
BEGIN
    for_gen : FOR i IN 0 TO Length-1 GENERATE 
	    if_gen1 : IF (i = Length-1) GENERATE
            Cel_N : KLSRegister_Cell PORT MAP (TDI,CLK,Capture,Enable,shift,temp(i));
	    END GENERATE if_gen1;									   
        if_gen2 : IF ((i < Length-1) AND (i > 0)) GENERATE  
            Cel_2ToN : KLSRegister_Cell PORT MAP (temp(i+1),CLK,Capture,Enable,shift,temp(i));
        END GENERATE if_gen2;									  		  
		if_gen3 : IF (i = 0) GENERATE 
			Cel_1 : KLSRegister_Cell PORT MAP (temp(i+1),CLK,Capture,Enable,shift,temp(0));
	    END GENERATE if_gen3; 
	END GENERATE for_gen;
	Dout  <= temp;
	TDO <= temp(0);
END str;

--******************************************************************************
--	File content description:
--  Comprator                              
--******************************************************************************


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY Comprator IS 
    GENERIC (Length : INTEGER := 20); 
    PORT(
	    Din1 : IN STD_LOGIC_VECTOR (Length-1 DOWNTO 0);	  
		Din2 : IN STD_LOGIC_VECTOR (Length-1 DOWNTO 0);			
	    Locked : OUT STD_LOGIC);	 
		
END Comprator;
 
ARCHITECTURE str OF Comprator IS 
BEGIN
    PROCESS (Din1,Din2) BEGIN
	IF (Din1 =Din2) THEN
	Locked <= '0';
	ELSE Locked <= '1';		
	END IF;	
	END PROCESS;	
END str;



