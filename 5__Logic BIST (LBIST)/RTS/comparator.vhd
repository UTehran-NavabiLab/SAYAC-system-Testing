--******************************************************************************
--	Filename:		comparator.vhd
--	Project:		SAYAC Testing 
--  Version:		0.1
--	History:
--	Date:			22 Nov 2022
--	Last Author: 	Helia Hosseini
--  Copyright (C) 2022 University of Tehran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--
--******************************************************************************
--	File content description:
--	comparator used in b+virtual tester
--******************************************************************************

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
	
ENTITY Comparator IS
	GENERIC (
		n   : INTEGER := 80;
		m   : INTEGER := 90);
	PORT (
		in1, in2  : IN STD_LOGIC_VECTOR (n+m-1 DOWNTO 0);
		e : OUT STD_LOGIC);
END ENTITY comparator;

ARCHITECTURE behaviour OF comparator IS
BEGIN
	PROCESS(in1, in2)
	BEGIN
	  e <= '0';
		IF (in1 = in2) THEN
			e <= '1';
		END IF;
	END PROCESS;
END ARCHITECTURE behaviour;
------------------------------------------