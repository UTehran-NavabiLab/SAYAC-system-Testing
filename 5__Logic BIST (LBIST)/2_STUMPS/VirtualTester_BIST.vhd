--******************************************************************************
--	Filename:		VirtualTester_BIST.vhd
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
--	Testbench as a virtual tester for STUMPS LBIST testing                                 
--******************************************************************************

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL; 
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.MATH_REAL.ALL;

ENTITY VirtualTester IS
END ENTITY VirtualTester;

ARCHITECTURE test OF VirtualTester IS
	CONSTANT sizePI      : INTEGER := 49; 
	CONSTANT sizePO      : INTEGER := 64;
	CONSTANT PRPG1_Size  : INTEGER := 60;		 	 -- using 49   
	CONSTANT MISR1_Size  : INTEGER := 80;		     -- using 64
	CONSTANT PRPG2_Size  : INTEGER := 10;
	CONSTANT MISR2_Size  : INTEGER := 10;
	CONSTANT ShiftSize   : INTEGER := 25;
	CONSTANT numOfCycles : INTEGER := 100;
	CONSTANT numOfRounds : INTEGER := 5;			-- Number of deterministic test patterns genetrated by Atalanta is 398
	CONSTANT numOfConfig : INTEGER := 1;
	CONSTANT clkPeriod   : time    := 10 ns;
	
	PROCEDURE random (VARIABLE seed1, seed2 : INOUT INTEGER; 
		SIGNAL target : INOUT std_logic_vector) 
	IS 
		VARIABLE ti : INTEGER; 
		VARIABLE size : INTEGER := target'LENGTH; 
		VARIABLE tmp : std_logic_vector (size-1 DOWNTO 0);
		VARIABLE rand, within : REAL; 
	BEGIN
		UNIFORM (seed1, seed2, rand); 
		within := 2.0**size; 
		ti := INTEGER (rand * within); 
		target <= conv_std_logic_vector (ti, size); 
	END PROCEDURE random; 
	
	SIGNAL clk   : STD_LOGIC := '0';
	SIGNAL rst   : STD_LOGIC := '0';
	SIGNAL NbarT : STD_LOGIC := '0';
	SIGNAL fail  : STD_LOGIC := '0';
	
	TYPE arrayTypeMISR IS ARRAY (1 TO numOfRounds) OF STD_LOGIC_VECTOR(MISR1_Size-1 DOWNTO 0);
	SIGNAL Golden_MISR_Out : arrayTypeMISR;
	TYPE arrayTypeSISA IS ARRAY (1 TO numOfRounds) OF STD_LOGIC_VECTOR(MISR2_Size-1 DOWNTO 0);
	SIGNAL Golden_SISA_Out : arrayTypeSISA;

	SIGNAL faultInjection : STD_LOGIC := '0';
	SIGNAL dumpDataMemory : STD_LOGIC := '0';
	SIGNAL stopSimulation : BOOLEAN := false;

BEGIN
	FUT : ENTITY WORK.testableSAYAC 
			GENERIC MAP (sizePI, sizePO, PRPG1_Size, MISR1_Size, PRPG2_Size, MISR2_Size, ShiftSize, numOfCycles, numOfRounds)
			PORT MAP (clk, rst, NbarT); --fail

	clk <= NOT clk AFTER clkPeriod/2;
	
	FI:PROCESS 
		ALIAS PRPG1_Poly_Sig : STD_LOGIC_VECTOR (PRPG1_Size-1 DOWNTO 0) IS << SIGNAL .VirtualTester.FUT.PRPG1_Poly : STD_LOGIC_VECTOR (PRPG1_Size-1 DOWNTO 0)>>;
		ALIAS PRPG1_Seed_Sig : STD_LOGIC_VECTOR (PRPG1_Size-1 DOWNTO 0) IS << SIGNAL .VirtualTester.FUT.PRPG1_Seed : STD_LOGIC_VECTOR (PRPG1_Size-1 DOWNTO 0)>>;
		ALIAS MISR1_Poly_Sig : STD_LOGIC_VECTOR (MISR1_Size-1 DOWNTO 0) IS << SIGNAL .VirtualTester.FUT.MISR1_Poly : STD_LOGIC_VECTOR (MISR1_Size-1 DOWNTO 0)>>;
		ALIAS MISR1_Seed_Sig : STD_LOGIC_VECTOR (MISR1_Size-1 DOWNTO 0) IS << SIGNAL .VirtualTester.FUT.MISR1_Seed : STD_LOGIC_VECTOR (MISR1_Size-1 DOWNTO 0)>>;
		ALIAS PRPG2_Poly_Sig : STD_LOGIC_VECTOR (PRPG2_Size-1 DOWNTO 0) IS << SIGNAL .VirtualTester.FUT.PRPG2_Poly : STD_LOGIC_VECTOR (PRPG2_Size-1 DOWNTO 0)>>;
		ALIAS PRPG2_Seed_Sig : STD_LOGIC_VECTOR (PRPG2_Size-1 DOWNTO 0) IS << SIGNAL .VirtualTester.FUT.PRPG2_Seed : STD_LOGIC_VECTOR (PRPG2_Size-1 DOWNTO 0)>>;
		ALIAS MISR2_Poly_Sig : STD_LOGIC_VECTOR (MISR2_Size-1 DOWNTO 0) IS << SIGNAL .VirtualTester.FUT.MISR2_Poly : STD_LOGIC_VECTOR (MISR2_Size-1 DOWNTO 0)>>;
		ALIAS MISR2_Seed_Sig : STD_LOGIC_VECTOR (MISR2_Size-1 DOWNTO 0) IS << SIGNAL .VirtualTester.FUT.MISR2_Seed : STD_LOGIC_VECTOR (MISR2_Size-1 DOWNTO 0)>>;
		ALIAS done_Sig : STD_LOGIC IS << SIGNAL .VirtualTester.FUT.done : STD_LOGIC>>;
		ALIAS MISR1_Out_Sig : STD_LOGIC_VECTOR (MISR1_Size-1 DOWNTO 0) IS << SIGNAL .VirtualTester.FUT.MISR1_Out : STD_LOGIC_VECTOR (MISR1_Size-1 DOWNTO 0)>>;
		ALIAS MISR2_Out_Sig : STD_LOGIC_VECTOR (MISR2_Size-1 DOWNTO 0) IS << SIGNAL .VirtualTester.FUT.MISR2_Out : STD_LOGIC_VECTOR (MISR2_Size-1 DOWNTO 0)>>;

		VARIABLE detected : STD_LOGIC := '0';
		VARIABLE numOfDetecteds : INTEGER := 0;
		VARIABLE numOfFaults : INTEGER := 0;
	    FILE sigFile, cfgFile, faultFile, reportFile : TEXT; 
        VARIABLE fstatusR, fstatusW : FILE_OPEN_STATUS;
	    VARIABLE lbufR, lbufW : LINE;
		VARIABLE i : INTEGER;
		variable str : string(1 to 100);
		variable strSize : INTEGER;
		VARIABLE wireName : STRING(1 TO 100);
		VARIABLE stuckAtVal : STD_LOGIC;
		VARIABLE coverage : REAL;

		VARIABLE seed1 : POSITIVE := 14;
		VARIABLE seed2 : POSITIVE := 37;
		VARIABLE strLine : STRING(1 TO 42); 
		VARIABLE cfgLine : STD_LOGIC_VECTOR (PRPG1_Size+MISR1_Size+PRPG2_Size+MISR2_Size-1 DOWNTO 0);
		VARIABLE sigLine : STD_LOGIC_VECTOR (MISR1_Size+MISR2_Size-1 DOWNTO 0);
		VARIABLE tempGolden_Out : STD_LOGIC_VECTOR(MISR1_Size+MISR2_Size-1 DOWNTO 0);
	BEGIN
	FILE_OPEN (fstatusW, reportFile, "reportFile.txt", write_mode);
--		WRITE (lbufW, string'("===================================> @ "));
--		WRITE (lbufW, NOW);
--		WRITE (lbufW, string'("   NORMAL MODE is starting ... "));
--		WRITELINE (reportFile, lbufW);
--
--		NbarT <= '0';
--		rst <= '1', '0' AFTER 2 NS;
--		WAIT FOR 6000 ns;
--		
--		dumpDataMemory <= '1';
--		WAIT FOR 10 ns;
--		dumpDataMemory <= '0';

		WRITE (lbufW, string'("===================================> @ "));
		WRITE (lbufW, NOW);
		WRITE (lbufW, string'("   RTS BIST MODE is starting ... "));
		WRITELINE (reportFile, lbufW);
		
		NbarT <= '1';

		FILE_OPEN (fstatusW, cfgFile, "Configuration.txt", write_mode);
		WRITE (lbufW, string'("PRPG1_Poly, MISR1_Poly, PRPG2_Poly, MISR2_Poly"));
		WRITELINE (cfgFile, lbufW);
		FOR i IN 1 TO numOfConfig LOOP   
			random (seed1, seed2, PRPG1_Poly_Sig(59 DOWNTO 30));
			random (seed1, seed2, PRPG1_Poly_Sig(29 DOWNTO 0));
			random (seed1, seed2, MISR1_Poly_Sig(79 DOWNTO 50));
			random (seed1, seed2, MISR1_Poly_Sig(49 DOWNTO 20));
			random (seed1, seed2, MISR1_Poly_Sig(19 DOWNTO 0));
			random (seed1, seed2, PRPG2_Poly_Sig(9 DOWNTO 0));
			random (seed1, seed2, MISR2_Poly_Sig(9 DOWNTO 0));
			WAIT FOR 0 ns;
			WRITE (lbufW, PRPG1_Poly_Sig);
			WRITE (lbufW, MISR1_Poly_Sig);
			WRITE (lbufW, PRPG2_Poly_Sig);
			WRITE (lbufW, MISR2_Poly_Sig);
			WRITELINE (cfgFile, lbufW);
		END LOOP;
		FILE_CLOSE (cfgFile);
		
		PRPG1_Seed_Sig <= STD_LOGIC_VECTOR(to_unsigned(11, PRPG1_Size));
		MISR1_Seed_Sig <= STD_LOGIC_VECTOR(to_unsigned(27, MISR1_Size));
		PRPG2_Seed_Sig <= STD_LOGIC_VECTOR(to_unsigned(8, PRPG2_Size));
		MISR2_Seed_Sig <= STD_LOGIC_VECTOR(to_unsigned(36, MISR2_Size));

		WRITE (lbufW, string'("===================================> @ "));
		WRITE (lbufW, NOW);
		WRITE (lbufW, string'("   Good response generation is starting ... "));
		WRITELINE (reportFile, lbufW);

		FILE_OPEN (fstatusR, cfgFile, "Configuration.txt", read_mode);
		FILE_OPEN (fstatusW, sigFile, "Signature.txt", write_mode);
		READLINE (cfgFile, lbufR);
		READ (lbufR, strLine);
		i := 0;
		WHILE (NOT ENDFILE (cfgFile)) LOOP
			i := i + 1;
			READLINE (cfgFile, lbufR);
			READ (lbufR, cfgLine);
			PRPG1_Poly_Sig <= cfgLine(PRPG1_Size+MISR1_Size+PRPG2_Size+MISR2_Size-1 DOWNTO MISR1_Size+PRPG2_Size+MISR2_Size);
			MISR1_Poly_Sig <= cfgLine(MISR1_Size+PRPG2_Size+MISR2_Size-1 DOWNTO PRPG2_Size+MISR2_Size);
			PRPG2_Poly_Sig <= cfgLine(PRPG2_Size+MISR2_Size-1 DOWNTO MISR2_Size);
			MISR2_Poly_Sig <= cfgLine(MISR2_Size-1 DOWNTO 0);
			
			rst <= '1'; 
			WAIT UNTIL clk = '1';
			rst <= '0';
		
			FOR i IN 1 TO numOfRounds LOOP
				WAIT UNTIL done_Sig = '0' AND done_Sig'EVENT;
				WRITE (lbufW, MISR1_Out_Sig);
				WRITE (lbufW, MISR2_Out_Sig);
				WRITELINE (sigFile, lbufW);
			END LOOP;
			REPORT "Signature for configuration " & INTEGER'IMAGE(i) & " was generated";
		END LOOP;
		FILE_CLOSE (cfgFile);
		FILE_CLOSE (sigFile);

		
		FILE_OPEN (fstatusR, cfgFile, "Configuration.txt", read_mode);
		FILE_OPEN (fstatusR, sigFile, "Signature.txt", read_mode);
		READLINE (cfgFile, lbufR);
		READ (lbufR, strLine);
		i := 0;
		WHILE (NOT ENDFILE (cfgFile)) LOOP
			i := i + 1;
			REPORT " ############### Configuration " & INTEGER'IMAGE(i) & " ###############";
			WRITE (lbufW, string'("===================================> @ "));
			WRITE (lbufW, NOW);
			WRITE (lbufW, string'("   Test process for configuration #"));
			WRITE (lbufW, i); 
			WRITE (lbufW, string'(" is starting ... "));
			WRITELINE (reportFile, lbufW);
			READLINE (cfgFile, lbufR);
			READ (lbufR, cfgLine);
			PRPG1_Poly_Sig <= cfgLine(PRPG1_Size+MISR1_Size+PRPG2_Size+MISR2_Size-1 DOWNTO MISR1_Size+PRPG2_Size+MISR2_Size);
			MISR1_Poly_Sig <= cfgLine(MISR1_Size+PRPG2_Size+MISR2_Size-1 DOWNTO PRPG2_Size+MISR2_Size);
			PRPG2_Poly_Sig <= cfgLine(PRPG2_Size+MISR2_Size-1 DOWNTO MISR2_Size);
			MISR2_Poly_Sig <= cfgLine(MISR2_Size-1 DOWNTO 0);
			
			FOR i IN 1 TO numOfRounds LOOP
				READLINE (sigFile, lbufR);
				READ (lbufR, sigLine);
				Golden_MISR_Out(i) <= sigLine(MISR1_Size+MISR2_Size-1 DOWNTO MISR2_Size);
				Golden_SISA_Out(i) <= sigLine(MISR2_Size-1 DOWNTO 0);
			END LOOP;

			FILE_OPEN (fstatusR, faultFile, "SAYAC.flt", read_mode);
			numOfFaults := 0;
			numOfDetecteds := 0;
			WHILE (NOT ENDFILE (faultFile)) LOOP
				READLINE (faultFile, lbufR);
				assert lbufR'length < str'length;  
				str := (others => ' '); 
				strSize := lbufR'length;
				read(lbufR, str(1 to strSize));
				wireName := (others => ' ');
				wireName(1 TO strSize-2) := str(1 to strSize-2);
				stuckAtVal := STD_LOGIC'value(str(strSize to strSize));
				faultInjection <= '1';
				numOfFaults := numOfFaults + 1;
				
				rst <= '1'; 
				WAIT UNTIL clk = '1';
				rst <= '0';
				fail <= '0';
				
				detected := '0';
				FOR i IN 1 TO numOfRounds LOOP
					tempGolden_Out := (Golden_MISR_Out(i) & Golden_SISA_Out(i));

					WAIT UNTIL done_Sig = '0' AND done_Sig'EVENT;

					IF ((MISR1_Out_Sig & MISR2_Out_Sig) /= tempGolden_Out) THEN
						detected := '1';
					END IF;
				END LOOP;

				IF detected = '1' THEN 
					fail <= '1';
					numOfDetecteds := numOfDetecteds + 1;
				END IF;

				faultInjection <= '0';
				WAIT FOR 0 NS;
			END LOOP;
			FILE_CLOSE(faultFile);
			
			coverage := (REAL(numOfDetecteds) / REAL(numOfFaults));
			REPORT "numOfDetecteds: " &INTEGER'IMAGE(numOfDetecteds); 
			REPORT "numOfFaults: " &INTEGER'IMAGE(numOfFaults); 
			REPORT "coverage: " &REAL'IMAGE(coverage);
			WRITE (lbufW, string'("Config "));
			WRITE (lbufW, i);
			WRITE (lbufW, string'(": Coverage = "));
			WRITE (lbufW, coverage);
			WRITE (lbufW, string'(": --- numOfDetecteds = "));
			WRITE (lbufW, numOfDetecteds);
			WRITE (lbufW, string'(", numOfFaults = "));
			WRITE (lbufW, numOfFaults);
			WRITELINE (reportFile, lbufW);
		END LOOP;
		FILE_CLOSE (cfgFile);
		FILE_CLOSE (sigFile);
		FILE_CLOSE (reportFile);

		stopSimulation <= true;
		WAIT;	

	END PROCESS;

END ARCHITECTURE test;