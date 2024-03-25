--******************************************************************************
--	Filename:		BS_Register.vhd
--	Project:		JTAG BC_1 Testing 
--  Version:		2.0
--	History:
--	Date:			27 Nov 2022
--	Last Author: 	Shahab Karbasian
--  Copyright (C) 2022 University of Tehran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--
--******************************************************************************
--	File content description:
--	IEEE Std 1149.1 Boundary Scan (BS) Registers                              
--******************************************************************************

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY BSRegister_Cell is
    PORT(
	    Din,Sin,Clk,ClockDR,UpdateDR,ShiftDR  : IN STD_LOGIC;
	    RstBar, ModeControl : IN STD_LOGIC;
	    Sout : OUT STD_LOGIC;
	    Dout : OUT STD_LOGIC);
END BSRegister_Cell;

ARCHITECTURE str OF BSRegister_Cell IS 
    SIGNAL D_Df1 :STD_LOGIC;
    SIGNAL Q_Df1 :STD_LOGIC;
    SIGNAL Q_Df2 :STD_LOGIC;	
BEGIN 
    PROCESS (Clk, RstBar) BEGIN 
        IF (RstBar = '1' AND RstBar'EVENT) THEN                        
		    Q_Df1 <= '0';
	    ELSIF (Clk = '1' AND Clk'EVENT) THEN
			if(ClockDR = '1') then 
	        Q_Df1 <= D_Df1;
			END IF;            
        END IF;	
    END PROCESS;
	PROCESS (UpdateDR, RstBar) BEGIN 
	    IF (RstBar = '1' AND RstBar'EVENT) THEN                          
		    Q_Df2 <= '0';
	    ELSIF (UpdateDR = '1' AND UpdateDR'EVENT) THEN               
		   Q_Df2 <= Q_Df1;		    
        END IF;	
    END PROCESS;
	
    D_Df1 <= Sin   WHEN (ShiftDR = '1')     ELSE Din;
    Dout  <= Q_Df2 WHEN (ModeControl = '1') ELSE Din;   
    Sout  <= Q_Df1; 
END str;

----------------------------------------------------
--     BSRegister_Block
----------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY BSRegister_Block IS 
    GENERIC (Length : INTEGER := 20); 
    PORT(
	    Sin,Clk,ClockDR,UpdateDR,ShiftDR : IN STD_LOGIC;
	    Din : IN STD_LOGIC_VECTOR (Length-1 DOWNTO 0);
	    RstBar, ModeControl : IN STD_LOGIC;
	    Sout : OUT STD_LOGIC;
	    Dout : OUT STD_LOGIC_VECTOR (Length-1 DOWNTO 0));	 
END BSRegister_Block;
 
ARCHITECTURE str OF BSRegister_Block IS      
    SIGNAL temp : STD_LOGIC_VECTOR (Length-1 DOWNTO 0);
    COMPONENT BSRegister_Cell IS
        PORT(     
	        Din, Sin,Clk, ClockDR,UpdateDR,ShiftDR  : IN STD_LOGIC;
			RstBar, ModeControl : IN STD_LOGIC;
			Sout : OUT STD_LOGIC;
			Dout : OUT STD_LOGIC);
    END COMPONENT;
BEGIN
    for_gen : FOR i IN 0 TO Length-1 GENERATE 
	    if_gen1 : IF (i = Length-1) GENERATE
            Cel_N : BSRegister_Cell PORT MAP (Din(i),Sin,Clk,ClockDR,UpdateDR,ShiftDR,RstBar,ModeControl,temp(i),Dout(i));
	    END GENERATE if_gen1;									   
        if_gen2 : IF ((i < Length-1) AND (i > 0)) GENERATE  
            Cel_2ToN : BSRegister_Cell PORT MAP (Din(i),temp(i+1),Clk,ClockDR,UpdateDR,ShiftDR,RstBar,ModeControl,temp(i),Dout(i));
        END GENERATE if_gen2;									  		  
		if_gen3 : IF (i = 0) GENERATE 
			Cel_1 : BSRegister_Cell PORT MAP (Din(i),temp(i+1),Clk,ClockDR,UpdateDR,ShiftDR,RstBar,ModeControl,Sout,Dout(i));
	    END GENERATE if_gen3; 
	END GENERATE for_gen;
END str;

