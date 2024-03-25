--******************************************************************************
--	Filename:		Comprator.vhd
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
	Locked <= '1';
	ELSE Locked <= '0';		
	END IF;	
	END PROCESS;	
END str;

