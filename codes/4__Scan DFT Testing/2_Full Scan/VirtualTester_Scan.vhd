--******************************************************************************
--	Filename:		VirtualTester_Scan.vhd
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
--	Testbench as a virtual tester for full scan testing                                 
--******************************************************************************

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.math_real.ALL; 

ENTITY VirtualTester IS
END ENTITY VirtualTester;

ARCHITECTURE test OF VirtualTester IS

	CONSTANT numDFF    : INTEGER := 90;
	CONSTANT sizePI    : INTEGER := 49;
	CONSTANT sizePO    : INTEGER := 64;
	CONSTANT clkPeriod : time    := 10 ns;
	
	SIGNAL clk : STD_LOGIC := '0';
	SIGNAL rst : STD_LOGIC := '0';
	SIGNAL NbarT, PbarS, Si, So : STD_LOGIC;
	
	SIGNAL faultInjection : STD_LOGIC := '0';
	SIGNAL dumpDataMemory : STD_LOGIC := '0';
	SIGNAL stopSimulation : BOOLEAN := false;
BEGIN
	
	FUT: ENTITY WORK.testableSAYAC 
			GENERIC MAP (sizePI, sizePO)
			PORT MAP (
				clk   => clk, 
				rst   => rst, 
				NbarT => NbarT,
				PbarS => PbarS,
				Si	  => Si,
				So 	  => So
			);
	
	clk <= NOT clk AFTER clkPeriod/2;
	
	FI:PROCESS 
		VARIABLE detected : STD_LOGIC := '0';
		VARIABLE numOfDetecteds : INTEGER := 0;
		VARIABLE numOfFaults : INTEGER := 0;
		VARIABLE testNum : INTEGER := 0;
		VARIABLE load_PI : STD_LOGIC_VECTOR (1 TO sizePI);
		VARIABLE load_PI_Rever : STD_LOGIC_VECTOR (1 TO sizePI);
		VARIABLE saved_PO : STD_LOGIC_VECTOR (1 TO sizePO);
		VARIABLE saved_PO_Rever : STD_LOGIC_VECTOR (1 TO sizePO);
		VARIABLE saved_PPO, load_PPI : STD_LOGIC_VECTOR (1 TO numDFF);
		VARIABLE load_In : STD_LOGIC_VECTOR (1 TO numDFF+sizePI);
		VARIABLE saved_Out : STD_LOGIC_VECTOR (1 TO numDFF+sizePO);
		VARIABLE pre_expected_st, cur_expected_st : STD_LOGIC_VECTOR (1 TO numDFF+sizePO);
		VARIABLE index : INTEGER;
	    FILE faultFile, testFile, reportFile, debugFile : TEXT; 
        VARIABLE fstatusR, fstatusW : FILE_OPEN_STATUS;
	    VARIABLE lbufR, lbufW, lbufD : LINE;
	    VARIABLE testLine : STD_LOGIC_VECTOR (1 TO sizePO + sizePI + (2 * numDFF));
		variable str : string(1 to 100);
		variable strSize : INTEGER;
		VARIABLE wireName : STRING(1 TO 100);
		VARIABLE stuckAtVal : STD_LOGIC;
		VARIABLE coverage : REAL;
	BEGIN
--		FILE_OPEN (fstatusW, debugFile, "debugFile.txt", write_mode);
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
		WRITE (lbufW, string'("   SCAN TEST MODE is starting ... "));
		WRITELINE (reportFile, lbufW);
		NbarT <= '1';

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
			
			WRITE (lbufW, string'("faultNum "));
			WRITE (lbufW, numOfFaults);
			WRITE (lbufW, string'(" = SA@"));
			WRITE (lbufW, stuckAtVal); 
			WRITE (lbufW, string'(" on "));
			WRITE (lbufW, wireName(1 TO 50));
			WRITE (lbufW, string'(", injected @ "));
			WRITE (lbufW, NOW);
			
			FILE_OPEN (fstatusR, testFile, "SAYAC.pat", read_mode);
		    detected := '0';
			rst <= '1'; 
			WAIT UNTIL clk = '1';
			rst <= '0';
			
			READLINE (testFile, lbufR);
			READ (lbufR, testLine);
			load_PPI := testLine(1 TO numDFF);
			load_PI := testLine(numDFF+1 TO numDFF+sizePI);
			FOR i IN 1 TO sizePI LOOP
				load_PI_Rever(sizePI+1-i) := load_PI(i);
			END LOOP; 
			load_In := (load_PI_Rever & load_PPI);
			cur_expected_st := testLine(numDFF+sizePI+1 TO 2*numDFF+sizePI+sizePO);
			
			PbarS <= '1';
			index := numDFF+sizePI;
			FOR i IN 0 TO numDFF+sizePI-1 LOOP   
				Si	<=  load_In (index);
				WAIT UNTIL clk = '1';
				index := index - 1;
			END LOOP;	
			
			testNum := 0;
			WHILE (NOT ENDFILE (testFile) AND detected = '0') LOOP
				PbarS <= '0';
				WAIT UNTIL clk = '1';

				pre_expected_st := cur_expected_st;
				READLINE (testFile, lbufR);
				READ (lbufR, testLine);
				load_PPI := testLine(1 TO numDFF);
				load_PI := testLine(numDFF+1 TO numDFF+sizePI);
				FOR i IN 1 TO sizePI LOOP
					load_PI_Rever(sizePI+1-i) := load_PI(i);
				END LOOP; 
				load_In := (load_PI_Rever & load_PPI);
				cur_expected_st := testLine(numDFF+sizePI+1 TO 2*numDFF+sizePI+sizePO);
				testNum := testNum + 1;
				
				PbarS <= '1';
				index := sizePO;
				FOR i IN 0 TO sizePO-sizePI-1 LOOP   
					WAIT UNTIL clk = '1';
					saved_PO(index) := So;
					index := index - 1;
				END LOOP; 
				
				index := sizePI;
				FOR i IN 0 TO sizePI-1 LOOP   
					Si	<=  load_In (index+numDFF);
					WAIT UNTIL clk = '1';
					saved_PO(index) := So;
					index := index - 1;
				END LOOP;
				
				index := numDFF;
				FOR i IN 0 TO numDFF-1 LOOP   
					Si	<=  load_In (index);
					WAIT UNTIL clk = '1';
					saved_PPO(index) := So;
					index := index - 1;
				END LOOP;
				
				FOR i IN 1 TO sizePO LOOP
					saved_PO_Rever(sizePO+1-i) := saved_PO(i);
				END LOOP; 
				saved_Out := (saved_PO_Rever & saved_PPO);
				
				IF (pre_expected_st /= saved_Out) THEN
					detected := '1';
				END IF;
--				WRITE (lbufD, string'("I am in the test loop @ "));
--				WRITE (lbufD, NOW);
--				WRITE (lbufD, string'(" --- detected is "));
--				WRITE (lbufD, detected);
--				WRITE (lbufD, string'(" *** pre_expected_st = "));
--				WRITE (lbufD, pre_expected_st);
--				WRITE (lbufD, string'(" *** saved_Out = "));
--				WRITE (lbufD, saved_Out);
--				WRITELINE (debugFile, lbufD);
			END LOOP; 	
			
			IF (detected /= '1') THEN
				PbarS <= '0';
				WAIT UNTIL clk = '1';
				
				PbarS <= '1';
				index := sizePO;
				FOR i IN 0 TO sizePO-1 LOOP         
					WAIT UNTIL clk = '1';  
					saved_PO(index) := So;
					index := index - 1;
				END LOOP; 
				
				index := numDFF;
				FOR i IN 0 TO numDFF-1 LOOP         
					WAIT UNTIL clk = '1';  
					saved_PPO(index) := So;
					index := index - 1;
				END LOOP;
				
				FOR i IN 1 TO sizePO LOOP
					saved_PO_Rever(sizePO+1-i) := saved_PO(i);
				END LOOP;
				saved_Out := (saved_PO_Rever & saved_PPO);
				
				IF (cur_expected_st /= saved_Out) THEN
					detected := '1';
				END IF;
--				WRITE (lbufD, string'("I am in the part for the last test pattern @ "));
--				WRITE (lbufD, NOW);
--				WRITE (lbufD, string'(" --- detected is "));
--				WRITE (lbufD, detected);
--				WRITE (lbufD, string'(" *** cur_expected_st = "));
--				WRITE (lbufD, cur_expected_st);
--				WRITE (lbufD, string'(" *** saved_Out = "));
--				WRITE (lbufD, saved_Out);
--				WRITELINE (debugFile, lbufD);
			END IF;
			FILE_CLOSE (testFile);

			IF (detected = '1') THEN
				numOfDetecteds := numOfDetecteds + 1;
				WRITE (lbufW, string'(", detected by testVector "));
				WRITE (lbufW, testNum);
				WRITE (lbufW, string'(" = "));
				WRITE (lbufW, testLine);
				WRITE (lbufW, string'(" @ "));
				WRITE (lbufW, NOW);
				WRITELINE (reportFile, lbufW);
			ELSE 
				WRITE (lbufW, string'(", not detected "));
				WRITE (lbufW, string'(" @ "));
				WRITE (lbufW, NOW);
				WRITELINE (reportFile, lbufW);
			END IF;
			
			faultInjection <= '0';
			WAIT FOR 0 ns;
		END LOOP;
		FILE_CLOSE (faultFile);
		
		coverage := REAL(numOfDetecteds / numOfFaults);
		WRITE (lbufW, string'("*******************************************************************"));
		WRITELINE (reportFile, lbufW);
		WRITE (lbufW, string'("*******************************************************************"));
		WRITELINE (reportFile, lbufW);
		WRITE (lbufW, string'("*******************************************************************"));
		WRITELINE (reportFile, lbufW);
		WRITE (lbufW, string'("numOfDetecteds: "));
		WRITE (lbufW, numOfDetecteds);
		WRITELINE (reportFile, lbufW);
		WRITE (lbufW, string'("numOfFaults: "));
		WRITE (lbufW, numOfFaults);
		WRITELINE (reportFile, lbufW);
		WRITE (lbufW, string'("coverage: "));
		WRITE (lbufW, coverage);
		WRITELINE (reportFile, lbufW);
		FILE_CLOSE (reportFile);
--		FILE_CLOSE (debugFile);

		stopSimulation <= true;
		WAIT;
		
	END PROCESS;

END ARCHITECTURE test;