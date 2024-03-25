--******************************************************************************
--	Filename:		SAYAC_MEM.vhd
--	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
--  Version:		0.900
--	History:
--	Date:			20 April 2021
--	Last Author: 	HANIEH
--  Copyright (C) 2021 University of Teheran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--

--******************************************************************************
--	File content description:
--	Memory (MEM) of the SAYAC core                                 
--******************************************************************************

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY MEM IS
	PORT (
		clk, rst, readMEM, writeMEM : IN STD_LOGIC;
		addr : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		writeData : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		readData        : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
--		rwData          : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		readyMEM        : OUT STD_LOGIC
	);
END ENTITY MEM;

ARCHITECTURE behaviour OF MEM IS
	TYPE data_mem IS ARRAY (0 TO 65535) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL memory : data_mem;
BEGIN
	PROCESS (clk, rst)
	BEGIN
		IF rst = '1' THEN
			FOR I IN 0 TO 65535 LOOP
				memory(I) <= STD_LOGIC_VECTOR(TO_UNSIGNED(0, 16));
			END LOOP;
		ELSIF clk = '1' AND clk'EVENT THEN
			IF writeMem = '1' THEN
				memory(TO_INTEGER(UNSIGNED(addr))) <= writeData;
--				memory(TO_INTEGER(UNSIGNED(addr))) <= rwData;
				readyMEM <= '1';
			END IF;
			
			IF readMEM = '1' THEN
				readyMEM <= '1';
			END IF;
		END IF;
	END PROCESS;

    readData <= memory(TO_INTEGER(UNSIGNED(addr))) WHEN readMEM = '1' ELSE
--    rwData <= memory(TO_INTEGER(UNSIGNED(addr))) WHEN readMEM = '1' ELSE
			    (OTHERS => 'Z'); 
END ARCHITECTURE behaviour;

