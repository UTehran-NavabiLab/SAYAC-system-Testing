--******************************************************************************
--	Filename:		OtherUnits.vhd
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
--	IEEE Std 1149.1 MUX, DFF, and Tri-State                              
--******************************************************************************

----------------------------------------------------------------------
--		Multiplexer 2 - 1
----------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY MUX2_1 IS
	PORT(
		in1, in2, sel : IN STD_LOGIC;	
		output : OUT STD_LOGIC);
END MUX2_1;

ARCHITECTURE str OF MUX2_1 IS
BEGIN
	output <= in1 WHEN (sel = '0') ELSE in2; 
END str;

----------------------------------------------------------------------
--		Multiplexer 4 - 1
----------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY MUX4_1 IS
	PORT(
		in1, in2, in3, in4 : IN STD_LOGIC;	
		sel : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		output : OUT STD_LOGIC);
END MUX4_1;

ARCHITECTURE str OF MUX4_1 IS 
BEGIN
	WITH sel SELECT
		output <= in1 WHEN "00",
				  in2 WHEN "01",
				  in3 WHEN "10",
				  in4 WHEN OTHERS ; 
END str; 

----------------------------------------------------------------------
--		D FlipFlop
----------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY D_FF IS
	PORT(
		D, CLK, RstBar : IN STD_LOGIC;
		Q : OUT STD_LOGIC);
END D_FF;

ARCHITECTURE str OF D_FF IS
BEGIN
	PROCESS (CLK, RstBar) BEGIN 
		IF (RstBar = '0' and RstBar'EVENT) THEN              
			Q <= '0';
		ELSIF (CLK = '1' and CLK'EVENT) THEN         
			Q <= D;
		END IF;
	END PROCESS;
END str;

----------------------------------------------------------------------
--		Tri-State
----------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY tristate IS
	PORT(
		input : IN STD_LOGIC;	
		enable : IN STD_LOGIC;	
		output : OUT STD_LOGIC);
END tristate;

ARCHITECTURE str OF tristate IS
BEGIN
	PROCESS (input, enable) BEGIN
		IF (enable = '1') THEN
			output <= input;
		ELSE
			output <= 'Z';
		END IF;
	END PROCESS;
END str;
