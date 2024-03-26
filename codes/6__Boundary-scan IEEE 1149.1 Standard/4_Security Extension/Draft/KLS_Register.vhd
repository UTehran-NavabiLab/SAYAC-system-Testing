--******************************************************************************
--	Filename:		KLS_Register.vhd
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
			Cel_1 : KLSRegister_Cell PORT MAP (temp(i+1),CLK,Capture,Enable,shift,TDO);
	    END GENERATE if_gen3; 
	END GENERATE for_gen;
	Dout  <=temp;
END str;

