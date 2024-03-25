--******************************************************************************
--	Filename:		SAYAC_TOP_TB.vhd
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
--	Testbench for verifying the SAYAC core with memories                               
--******************************************************************************

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY NetlistVerification_TB IS
END ENTITY NetlistVerification_TB;

ARCHITECTURE test OF NetlistVerification_TB IS
	SIGNAL clk : STD_LOGIC := '0';
	SIGNAL rst : STD_LOGIC;
BEGIN	
	clk <= NOT clk AFTER 5 NS WHEN NOW <= 1000000 NS ELSE '0';
	rst <= '1', '0' AFTER 2 NS;

	TOP_Circuit : ENTITY WORK.TOP PORT MAP 
					(clk, rst);
END ARCHITECTURE test;