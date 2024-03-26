--******************************************************************************
--	Filename:		Lock_Register.vhd
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
--	Lock_Register                           
--******************************************************************************

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
--USE IEEE.std_logic_arith.ALL;
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

