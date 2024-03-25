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
--	Testbench of the fulladder circuit for the Dynamic method                                  
--******************************************************************************

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.math_real.ALL; 

ENTITY fulladder_TB IS
END ENTITY fulladder_TB;

ARCHITECTURE test OF fulladder_TB IS
	CONSTANT faultsNum : INTEGER := 24;
	CONSTANT inputWidth : INTEGER := 3;
	CONSTANT outputWidth : INTEGER := 2;
	
	SIGNAL i0 : STD_LOGIC;
	SIGNAL i1 : STD_LOGIC;
	SIGNAL ci : STD_LOGIC;
	SIGNAL s_RTL  : STD_LOGIC;
	SIGNAL co_RTL : STD_LOGIC;
	SIGNAL s_NET  : STD_LOGIC;
	SIGNAL co_NET : STD_LOGIC;
	
	SIGNAL inputs : STD_LOGIC_VECTOR (inputWidth-1 DOWNTO 0);
	SIGNAL outputs_FUT : STD_LOGIC_VECTOR (outputWidth-1 DOWNTO 0);
	SIGNAL outputs_GUT : STD_LOGIC_VECTOR (outputWidth-1 DOWNTO 0);
	SIGNAL stopSim : STD_LOGIC := '0';

BEGIN	
	FA_RTL : ENTITY WORK.fulladder 
			 PORT MAP (i0, i1, ci, s_RTL, co_RTL);
	FA_NET : ENTITY WORK.fulladder 
			 PORT MAP (i0, i1, ci, s_NET, co_NET);

	(i0, i1, ci) <= inputs;
	outputs_GUT <= (s_RTL & co_RTL);
	outputs_FUT <= (s_NET & co_NET);
	
	PROCESS 
		VARIABLE detected : STD_LOGIC := '0';
		VARIABLE numOfDetecteds : INTEGER := 0;
		VARIABLE numOfFaults : INTEGER := 0;
	
	    FILE testFile, reportFile : TEXT; 
        VARIABLE fstatusR, fstatusW : FILE_OPEN_STATUS;
	    VARIABLE lbufR, lbufW : LINE;
	    VARIABLE TestData : STD_LOGIC_VECTOR (inputWidth-1 DOWNTO 0);
		VARIABLE firstTime : STD_LOGIC := '1';
		VARIABLE coverage : REAL;
	BEGIN
		IF (firstTime = '1') THEN
			FILE_OPEN (fstatusW, reportFile, "reportFile.txt", write_mode);
			firstTime := '0';
		END IF;
--	    FOR i IN 1 TO faultNum LOOP  -- Fault loop
		IF (stopSim = '1') THEN
			numOfFaults := numOfFaults + 1;
			
			WRITE (lbufW, string'("faultNum = "));
			WRITE (lbufW, numOfFaults);
			WRITE (lbufW, string'(" is injected @ "));
			WRITE (lbufW, NOW);
			
			FILE_OPEN (fstatusR, testFile, "test_list.txt", read_mode);
		    detected := '0';
			WHILE (NOT ENDFILE (testFile) AND detected = '0') LOOP
				READLINE (testFile, lbufR);
				READ (lbufR, TestData);
				inputs <= TestData;
				WAIT FOR 2 ns;
				IF (outputs_GUT /= outputs_FUT) THEN
					detected := '1';
					
					WRITE (lbufW, string'(", detected by testVector = "));
					WRITE (lbufW, TestData);
					WRITE (lbufW, string'(" @ "));
					WRITE (lbufW, NOW);
					WRITELINE (reportFile, lbufW);
--					REPORT "The injected fault is detected at "  & TIME'IMAGE(NOW);
				--	stopSim <= '0';
				END IF;
			END LOOP; 
			FILE_CLOSE (testFile);
			IF (detected = '1') THEN
				numOfDetecteds := numOfDetecteds + 1;
			END IF;
			stopSim <= '0';
        END IF;
		
		IF (numOfFaults = faultsNum)THEN
			FILE_CLOSE (reportFile);
			coverage := REAL(numOfDetecteds / faultsNum);
			REPORT "numOfDetecteds: " &INTEGER'IMAGE(numOfDetecteds); 
			REPORT "faultsNum: " &INTEGER'IMAGE(faultsNum); 
			REPORT "coverage: " &REAL'IMAGE(coverage);
		END IF;
		
		WAIT ON stopSim;
	END PROCESS;
	
END ARCHITECTURE test;