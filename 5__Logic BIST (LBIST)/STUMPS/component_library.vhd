--******************************************************************************
--	Filename:		component_library.vhd
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
--	Gate level components                                  
--******************************************************************************

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
	
ENTITY nor_n IS
	PORT (
		in1  : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		out1 : OUT STD_LOGIC);
END ENTITY nor_n;

ARCHITECTURE behaviour OF nor_n IS
BEGIN
	out1 <= in1(0) NOR in1(1);
END ARCHITECTURE behaviour;
------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY nand_n IS
	PORT (
		in1  : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		out1 : OUT STD_LOGIC);
END ENTITY nand_n;

ARCHITECTURE behaviour OF nand_n IS
BEGIN
	out1 <= in1(0) NAND in1(1);
END ARCHITECTURE behaviour;
------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY notg IS
	PORT (
		in1  : IN STD_LOGIC;
		out1 : OUT STD_LOGIC);
END ENTITY notg;

ARCHITECTURE behaviour OF notg IS
BEGIN
	out1 <= NOT in1;
END ARCHITECTURE behaviour;
------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY bufg IS
	PORT (
		in1  : IN STD_LOGIC;
		out1 : OUT STD_LOGIC);
END ENTITY bufg;

ARCHITECTURE behaviour OF bufg IS
BEGIN
	out1 <= in1;
END ARCHITECTURE behaviour;
------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY pin IS
	PORT (
		in1  : IN STD_LOGIC;
		out1 : OUT STD_LOGIC);
END ENTITY pin;

ARCHITECTURE behaviour OF pin IS
BEGIN
	out1 <= in1;
END ARCHITECTURE behaviour;
------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY pout IS
	PORT (
		in1  : IN STD_LOGIC;
		out1 : OUT STD_LOGIC);
END ENTITY pout;

ARCHITECTURE behaviour OF pout IS
BEGIN
	out1 <= in1;
END ARCHITECTURE behaviour;
------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY dff IS
	PORT (
		D, C, CLR, PRE, CE, NbarT, Si, global_reset : IN STD_LOGIC;
		Q : OUT STD_LOGIC);
END ENTITY dff;

ARCHITECTURE behaviour OF dff IS
	SIGNAL tmp : STD_LOGIC;
BEGIN
	PROCESS (C, PRE, CLR, global_reset)
	BEGIN
		IF (CLR = '1' OR global_reset = '1') THEN
			tmp <= '0';
		ELSIF (PRE = '1' AND PRE'EVENT) THEN
			tmp <= '1';
		ELSIF (C = '1' AND C'EVENT) THEN
			IF NbarT = '1' THEN
				tmp <= Si;
			ELSIF CE = '1' THEN
				tmp <= D;
			END IF;
		END IF;
	END PROCESS;
	
	PROCESS (tmp)
	BEGIN
		IF (tmp = '1' AND tmp'EVENT) THEN
			Q <= tmp;
		ELSIF (tmp = '0' AND tmp'EVENT) THEN
			Q <= tmp;
		END IF;
	END PROCESS;
	
END ARCHITECTURE behaviour;
------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY dffBlock IS 
    GENERIC (Length : INTEGER := 20); 
    PORT(
	    D : IN STD_LOGIC_VECTOR (Length-1 DOWNTO 0); 
		C, CLR, PRE, CE, NbarT, Si, global_reset : IN STD_LOGIC;
		Q : OUT STD_LOGIC_VECTOR (Length-1 DOWNTO 0));
END dffBlock;
 
ARCHITECTURE str OF dffBlock IS      
    SIGNAL temp : STD_LOGIC_VECTOR (Length-1 DOWNTO 0);
    COMPONENT dff IS
        PORT(     
	        D, C, CLR, PRE, CE, NbarT, Si, global_reset : IN STD_LOGIC;
	        Q : OUT STD_LOGIC);
    END COMPONENT;
BEGIN
    for_gen : FOR i IN 0 TO Length-1 GENERATE 
		if_gen0 : IF (i = Length-1) GENERATE 
			Cel_0 : dff PORT MAP (D(i), C, CLR, PRE, CE, NbarT, Si, global_reset, temp(i));
	    END GENERATE if_gen0; 	    									   
        if_genN : IF ((i < Length-1) AND (i >= 0)) GENERATE  
            Cel_N : dff PORT MAP (D(i), C, CLR, PRE, CE, NbarT, temp(i+1), global_reset, temp(i));
        END GENERATE if_genN;									  		  
	END GENERATE for_gen;
	Q <= temp;
END str;

