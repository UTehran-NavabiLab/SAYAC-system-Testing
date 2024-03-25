--******************************************************************************
--	Filename:		Instruction_Register.vhd
--	Project:		SAYAC Testing 
--  Version:		0.90
--	History:
--	Date:			20 June 2022
--	Last Author: 	Nooshin Nosrati
--  Copyright (C) 2022 University of Tehran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--
--******************************************************************************
--	File content description:
--	IEEE Std 1149.1 Instruction Registers                              
--******************************************************************************

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_arith.ALL;
USE IEEE.STD_LOGIC_unsigned.ALL;

ENTITY InstructionRegister_Cell IS
    PORT(
	    Din, Sin, TCLK, ShiftIR, UpdateIR : IN STD_LOGIC;
	    ClockIR, RstBar : IN STD_LOGIC;
	    Sout : OUT STD_LOGIC;
	    Dout : OUT STD_LOGIC);
END InstructionRegister_Cell;

ARCHITECTURE str OF InstructionRegister_Cell IS 
    SIGNAL D_Df1 : STD_LOGIC;
    SIGNAL Q_Df1 : STD_LOGIC;	
BEGIN     
    PROCESS (TCLK, RstBar) BEGIN  
        IF (RstBar = '0' and RstBar'EVENT) THEN            
		    Q_Df1 <= '0';
	    ELSIF (TCLK ='1' and TCLK'EVENT) THEN             
		    IF (ClockIR = '0') THEN
		        Q_Df1 <= D_Df1;
		    END IF;
		END IF;	
    END PROCESS;
    PROCESS (TCLK, RstBar) BEGIN 
		IF (RstBar = '0' and RstBar'EVENT) THEN                            
		    Dout <= '0';
		ELSIF (TCLK = '0' and TCLK'EVENT) THEN              
		    IF (UpdateIR = '1') THEN
		        Dout <= Q_Df1;
		    END IF;
		END IF;	
    END PROCESS;
	
    D_Df1 <= Sin WHEN (ShiftIR = '1') ELSE Din;
    Sout <= Q_Df1; 
END str;

----------------------------------------------------
--     BSRegister_Block
----------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_arith.ALL;
USE IEEE.STD_LOGIC_unsigned.ALL;

ENTITY InstructionRegister_Block IS 
	GENERIC (Length : INTEGER := 3);
    PORT(
	    Sin, TCLK, ShiftIR, UpdateIR : IN STD_LOGIC ;
	    Din : IN STD_LOGIC_VECTOR (Length-1 DOWNTO 0) ;
	    ClockIR, RstBar : IN STD_LOGIC ;
	    Sout : OUT STD_LOGIC;
	    Dout : OUT STD_LOGIC_VECTOR (Length-1 DOWNTO 0));	 
END InstructionRegister_Block;

ARCHITECTURE str OF InstructionRegister_Block IS
    SIGNAL temp : STD_LOGIC_VECTOR (Length-1 DOWNTO 0);
    COMPONENT InstructionRegister_Cell IS
        PORT(     
	        Din, Sin, TCLK, ShiftIR, UpdateIR : IN STD_LOGIC;
	        ClockIR, RstBar : IN STD_LOGIC;
	        Sout : OUT STD_LOGIC;
	        Dout : OUT STD_LOGIC);
    END COMPONENT;	
	
BEGIN
	for_gen : FOR i IN 0 TO Length-1 GENERATE 
		if_gen1 : IF (i = Length-1) GENERATE
			Cel_N : InstructionRegister_Cell PORT MAP (Din(i),Sin,TCLK,ShiftIR,UpdateIR,ClockIR,RstBar,temp(i),Dout(i));
		END GENERATE if_gen1;
		if_gen2 : IF ((i < Length-1) AND (i > 0)) GENERATE 
			Cel_2ToN : InstructionRegister_Cell PORT MAP (Din(i),temp(i+1),TCLK,ShiftIR,UpdateIR,ClockIR,RstBar,temp(i),Dout(i));
		END GENERATE if_gen2;
		if_gen3 : IF (i = 0) GENERATE 
			Cel_1 : InstructionRegister_Cell PORT MAP (Din(i),temp(i+1),TCLK,ShiftIR,UpdateIR,ClockIR,RstBar,Sout,Dout(i));
		END GENERATE if_gen3; 	
	END GENERATE for_gen;
END str;

