--******************************************************************************
--	Filename:		fulladder.vhd
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
--	Gate level fulladder                                  
--******************************************************************************

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY fulladder_RTL IS
    PORT (i0, i1 : IN STD_LOGIC; ci : IN STD_LOGIC; s : OUT STD_LOGIC; co : OUT STD_LOGIC);
END fulladder_RTL;
  
ARCHITECTURE rtl OF fulladder_RTL IS
BEGIN
	s <= i0 XOR i1 XOR ci;
	co <= (i0 AND i1) OR (i0 AND ci) OR (i1 AND ci);
END rtl;
