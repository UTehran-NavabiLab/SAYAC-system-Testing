--******************************************************************************
--	Filename:		Memory.vhd
--	Project:		SAYAC Testing 
--  Version:		0.1
--	History:
--	Date:			Feb 2023
--	Last Author: 	Helia Hosseini
--  Copyright (C) 2023 University of Tehran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--
--******************************************************************************
--	File content description:
--	Memory for saving data                                 
--******************************************************************************
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY Generic_MEM IS
	GENERIC (
		SizeOfData   : INTEGER := 16;
		SizeOfMem   : INTEGER := 100);
	PORT (
		clk, readMEM, writeMEM : IN STD_LOGIC;
		addr : IN STD_LOGIC_VECTOR(SizeOfData-1 DOWNTO 0);
		writeData : IN STD_LOGIC_VECTOR(SizeOfData-1 DOWNTO 0);
		readData        : OUT STD_LOGIC_VECTOR(SizeOfData-1 DOWNTO 0);
		readyMEM        : OUT STD_LOGIC
	);
END ENTITY Generic_MEM;

ARCHITECTURE behaviour OF Generic_MEM IS
	TYPE data_mem IS ARRAY (0 TO SizeOfMem-1) OF STD_LOGIC_VECTOR(SizeOfData-1 DOWNTO 0);
	SIGNAL memory : data_mem;
BEGIN
	PROCESS (clk)
	BEGIN
	readyMEM <= '0';
		--IF rst = '1' THEN
			--FOR I IN 0 TO SizeOfMem-1 LOOP
				--memory(I) <= STD_LOGIC_VECTOR(TO_UNSIGNED(I, SizeOfData));
			--END LOOP;
		IF clk = '1' AND clk'EVENT THEN
			IF writeMem = '1' THEN
				memory(TO_INTEGER(UNSIGNED(addr))) <= writeData;
				readyMEM <= '1';
			END IF;
			
			IF readMEM = '1' THEN
				readyMEM <= '1';
			END IF;
		END IF;
	END PROCESS;

    readData <= memory(TO_INTEGER(UNSIGNED(addr))) WHEN readMEM = '1';
    
END ARCHITECTURE behaviour;














