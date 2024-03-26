--******************************************************************************
--	Filename:		fulladder_TB.vhd
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
--	Testbench of the fulladder circuit for the All-in-TCL method                                  
--******************************************************************************

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY fulladder_TB IS
END ENTITY fulladder_TB;

ARCHITECTURE test OF fulladder_TB IS
	SIGNAL i0 : STD_LOGIC;
	SIGNAL i1 : STD_LOGIC;
	SIGNAL ci : STD_LOGIC;
	SIGNAL s_RTL  : STD_LOGIC;
	SIGNAL co_RTL : STD_LOGIC;
	SIGNAL s_NET  : STD_LOGIC;
	SIGNAL co_NET : STD_LOGIC;
	
	SIGNAL inputs : STD_LOGIC_VECTOR (2 DOWNTO 0);
	SIGNAL outputs_FUT : STD_LOGIC_VECTOR (1 DOWNTO 0);
	SIGNAL outputs_GUT : STD_LOGIC_VECTOR (1 DOWNTO 0);
BEGIN	
	FA_RTL : ENTITY WORK.fulladder_RTL 
			 PORT MAP (i0, i1, ci, s_RTL, co_RTL);
	FA_NET : ENTITY WORK.fulladder 
			 PORT MAP (i0, i1, ci, s_NET, co_NET);

	(i0, i1, ci) <= inputs;
	outputs_GUT <= (s_RTL & co_RTL);
	outputs_FUT <= (s_NET & co_NET);
	
END ARCHITECTURE test;