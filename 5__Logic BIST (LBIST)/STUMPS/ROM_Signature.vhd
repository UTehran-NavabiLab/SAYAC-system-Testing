--******************************************************************************
--	Filename:		ROM_Signature.vhd
--  Version:		1.0
--	History:
--	Date:		    April 2023
--	Last Author: 	HELYA
--  Copyright (C) 2021 University of Teheran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--

--******************************************************************************
--	File content description:
--	instruction ROM for Signature.txt (inst_ROM_Signature)                                  
--******************************************************************************

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
	
ENTITY inst_ROM_Signature IS
	GENERIC (
		SizeOfData   : INTEGER := 16;
		numofinst : INTEGER := 36
	);
	PORT (
		clk, rst, readInst : IN STD_LOGIC;
		addrInst : IN STD_LOGIC_VECTOR(SizeOfData-1 DOWNTO 0);
		Inst     : OUT STD_LOGIC_VECTOR(SizeOfData-1 DOWNTO 0)   
	);
END ENTITY inst_ROM_Signature;

ARCHITECTURE behaviour OF inst_ROM_Signature IS
	TYPE inst_mem IS ARRAY (0 TO numofinst-1) OF STD_LOGIC_VECTOR(SizeOfData-1 DOWNTO 0);
	SIGNAL instMEM : inst_mem;
	
	IMPURE FUNCTION InitRomFromFile 
	RETURN inst_mem IS
		FILE RomFile : TEXT OPEN read_mode IS "Signature.txt";
		VARIABLE RomFileLine : LINE;
		VARIABLE GOOD : BOOLEAN;
		VARIABLE fstatus: FILE_OPEN_STATUS;
		VARIABLE ROM : inst_mem;
	BEGIN	
		REPORT "Status from FILE: '" & FILE_OPEN_STATUS'IMAGE(fstatus) & "'";
		READLINE(RomFile, RomFileLine);
		FOR I IN 0 TO numofinst-1 LOOP
			IF NOT ENDFILE(RomFile) THEN
				READLINE(RomFile, RomFileLine);
				READ(RomFileLine, ROM(I), GOOD);
				REPORT "Status from FILE: '" & BOOLEAN'IMAGE(GOOD) & "'";
			END IF;
		END LOOP;
		
		FILE_close(RomFile);
		RETURN ROM;
	END FUNCTION;
BEGIN
	PROCESS (clk, rst)
	BEGIN
		IF rst = '1' THEN
			instMEM <= InitRomFromFile;
			REPORT "Writing from Sig file has been done successfully" ;
		--	Inst <= (OTHERS => '0');
		-- ELSIF clk = '1' AND clk'EVENT THEN
			-- IF readInst = '1' THEN
				-- Inst <= instMEM(TO_INTEGER(UNSIGNED(addrInst)));
			-- ELSE
				-- Inst <= (OTHERS => 'Z');
			-- END IF;
		END IF;
	END PROCESS;
	
	Inst <= instMEM(TO_INTEGER(UNSIGNED(addrInst))) WHEN readInst = '1' ELSE
			(OTHERS => 'Z');
END ARCHITECTURE behaviour;
------------------------------------------------------------------------------------------------
