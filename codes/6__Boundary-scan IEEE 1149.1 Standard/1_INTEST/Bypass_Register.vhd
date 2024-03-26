--******************************************************************************
--	Filename:		Bypass_Register.vhd
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
--	IEEE Std 1149.1 Bypass Registers                              
--******************************************************************************

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_arith.ALL;
USE IEEE.STD_LOGIC_unsigned.ALL;

ENTITY ByPassRegister_Cell IS
    PORT(
	    Din, Sin, TCLK, ShiftBY : IN STD_LOGIC;
	    ClockBY, RstBar : IN STD_LOGIC;
	    TDO : OUT STD_LOGIC);
END ByPassRegister_Cell;

ARCHITECTURE str OF ByPassRegister_Cell IS 
    SIGNAL D_Df : STD_LOGIC;
BEGIN
	PROCESS (TCLK, RstBar) BEGIN 
	    IF (RstBar = '0' and RstBar'EVENT) THEN             
		    TDO <= '0';
	    ELSIF (TCLK = '1' and TCLK'EVENT) THEN           
		    IF (ClockBY = '0') THEN
		        TDO <= D_Df;
		    END IF;
	    END IF;  
    END PROCESS;
	
    D_Df <= Sin WHEN (ShiftBY = '1') ELSE Din;
END str;	     

