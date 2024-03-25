--******************************************************************************
--	Filename:		Bypass_Register.vhd
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
--	IEEE Std 1149.1 Bypass Registers                              
--******************************************************************************

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_arith.ALL;
USE IEEE.STD_LOGIC_unsigned.ALL;

ENTITY ByPassRegister_Cell IS
    PORT(
	    Din,Sin,Clk,ClockDR,ShiftDR : IN STD_LOGIC;
	    RstBar : IN STD_LOGIC;
	    TDO : OUT STD_LOGIC);
END ByPassRegister_Cell;

ARCHITECTURE str OF ByPassRegister_Cell IS 
    SIGNAL D_Df : STD_LOGIC;
BEGIN
	PROCESS (Clk, RstBar) BEGIN 
	    IF (RstBar = '1' and RstBar'EVENT) THEN             
		    TDO <= '0';
	    ELSIF (Clk = '1' and Clk'EVENT) THEN
			IF (ClockDR= '1') THEN
		    TDO <= D_Df;	
			END IF;
	    END IF;  
    END PROCESS;
	
    D_Df <= Sin WHEN (ShiftDR = '1') ELSE Din;
END str;	     

