--******************************************************************************
--	Filename:		SAYAC_register_file.vhd
--	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
--  Version:		0.990
--	History:
--	Date:			27 April 2021
--	Last Author: 	HANIEH
--  Copyright (C) 2021 University of Tehran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--

--******************************************************************************
--	File content description:
--	Testbench (TB) of the SAYAC core                                 
--******************************************************************************

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY TB IS
END ENTITY TB;

ARCHITECTURE test OF TB IS
	SIGNAL clk : STD_LOGIC := '0';
	SIGNAL rst : STD_LOGIC;
BEGIN	
	clk <= NOT clk AFTER 5 NS WHEN NOW <= 1000000 NS ELSE '0';
	rst <= '1', '0' AFTER 2 NS;

	TOP_Circuit : ENTITY WORK.TOP PORT MAP 
					(clk, rst);
END ARCHITECTURE test;