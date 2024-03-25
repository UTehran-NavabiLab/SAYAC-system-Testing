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
	SIGNAL PbarS, Si, So : STD_LOGIC;
	SIGNAL In_SAYAC  : STD_LOGIC_VECTOR (sizePI-1 DOWNTO 0);
	SIGNAL Out_SAYAC : STD_LOGIC_VECTOR (sizePO-1 DOWNTO 0); 
	
	SIGNAL faultInjection : STD_LOGIC := '0';
	SIGNAL stopSimulation : BOOLEAN := false;
BEGIN
	
	FUT : ENTITY WORK.LGC_Netlist 
			PORT MAP (
				clk 		=> clk, 								
				rst 		=> rst, 
				dataBusIn 	=> In_SAYAC(15 DOWNTO 0 ),
				p1TRF 		=> In_SAYAC(31 DOWNTO 16),
				p2TRF 		=> In_SAYAC(47 DOWNTO 32),
				readyMEM 	=> In_SAYAC(48),
				PbarS 		=> PbarS,
				Si			=> Si,
				So 			=> So,
				addrBus 	=> Out_SAYAC(15 DOWNTO 0 ),
				dataBusOut 	=> Out_SAYAC(31 DOWNTO 16),
				inDataTRF 	=> Out_SAYAC(47 DOWNTO 32),
				outMuxrd  	=> Out_SAYAC(51 DOWNTO 48),
				outMuxrs1 	=> Out_SAYAC(55 DOWNTO 52),
				outMuxrs2 	=> Out_SAYAC(59 DOWNTO 56),
				readInst 	=> Out_SAYAC(60),
				readMM		=> Out_SAYAC(61),
				writeMM 	=> Out_SAYAC(62),
				writeTRF 	=> Out_SAYAC(63)			
			);

	clk <= NOT clk AFTER clkPeriod/2;
	
	FI:PROCESS 
		VARIABLE detected : STD_LOGIC := '0';
		VARIABLE flag : STD_LOGIC := '0';
		VARIABLE numOfDetecteds : INTEGER := 0;
		VARIABLE numOfFaults : INTEGER := 0;
		VARIABLE testNum : INTEGER := 0;
		VARIABLE load_PI : STD_LOGIC_VECTOR (1 TO sizePI);
		VARIABLE load_PI_Rever : STD_LOGIC_VECTOR (sizePI-1 DOWNTO 0);
		VARIABLE expected_PO : STD_LOGIC_VECTOR (1 TO sizePO);
		VARIABLE expected_PO_Rever, saved_PO : STD_LOGIC_VECTOR (sizePO-1 DOWNTO 0);
		VARIABLE saved_PPO, load_PPI : STD_LOGIC_VECTOR (1 TO numDFF);
		VARIABLE pre_expected_PPO, cur_expected_PPO : STD_LOGIC_VECTOR (1 TO numDFF);
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

		WRITE (lbufW, string'("===================================> @ "));
		WRITE (lbufW, NOW);
		WRITE (lbufW, string'("   SCAN TEST MODE is starting ... "));
		WRITELINE (reportFile, lbufW);

		FILE_OPEN (fstatusR, faultFile, "SAYAC_Ver.flt", read_mode);
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
			flag := '0';
			rst <= '1'; 
			WAIT UNTIL clk = '1';
			rst <= '0';
			
			testNum := 0;
			WHILE (NOT ENDFILE (testFile) AND detected = '0') LOOP

				pre_expected_PPO := cur_expected_PPO;

				READLINE (testFile, lbufR);
				READ (lbufR, testLine);
				load_PPI := testLine(1 TO numDFF);
				load_PI := testLine(numDFF+1 TO numDFF+sizePI);
				FOR i IN 1 TO sizePI LOOP
					load_PI_Rever(i-1) := load_PI(i);
				END LOOP; 
				In_SAYAC <= load_PI_Rever;
				expected_PO := testLine(numDFF+sizePI+1 TO numDFF+sizePI+sizePO);
				FOR i IN 1 TO sizePO LOOP
					expected_PO_Rever(i-1) := expected_PO(i);
				END LOOP;
				cur_expected_PPO := testLine(numDFF+sizePI+sizePO+1 TO 2*numDFF+sizePI+sizePO);
				testNum := testNum + 1;
				
				PbarS <= '1';
				index := numDFF;
				FOR i IN 0 TO numDFF-1 LOOP   
					Si	<=  load_PPI (index);
					WAIT UNTIL clk = '1';
					saved_PPO(index) := So;
					index := index - 1;
				END LOOP;
				
				PbarS <= '0';
				WAIT UNTIL clk = '1';
				saved_PO := Out_SAYAC;

				IF (flag = '0') THEN
					flag := '1';
					IF (expected_PO_Rever /= saved_PO) THEN
						detected := '1';
					END IF;
--					WRITE (lbufD, string'("I am in the flag part @ "));
--					WRITE (lbufD, NOW);
--					WRITE (lbufD, string'(" --- detected is "));
--					WRITE (lbufD, detected);
--					WRITE (lbufD, string'(" *** expected_PO = "));
--					WRITE (lbufD, expected_PO);
--					WRITE (lbufD, string'(" *** saved_PO = "));
--					WRITE (lbufD, saved_PO);
--					WRITELINE (debugFile, lbufD);
				ELSE
					IF ((pre_expected_PPO & expected_PO_Rever) /= (saved_PPO & saved_PO)) THEN
						detected := '1';
					END IF;
--					WRITE (lbufD, string'("I am in the flag part @ "));
--					WRITE (lbufD, NOW);
--					WRITE (lbufD, string'(" --- detected is "));
--					WRITE (lbufD, detected);
--					WRITE (lbufD, string'(" *** expected_PO = "));
--					WRITE (lbufD, expected_PO);
--					WRITE (lbufD, string'(" *** saved_PO = "));
--					WRITE (lbufD, saved_PO);
--					WRITE (lbufD, string'(" *** pre_expected_PPO = "));
--					WRITE (lbufD, pre_expected_PPO);
--					WRITE (lbufD, string'(" *** saved_st = "));
--					WRITE (lbufD, saved_st);
--					WRITELINE (debugFile, lbufD);
				END IF;
			END LOOP; 	
			
			IF (detected /= '1') THEN			
				PbarS <= '1';
				index := numDFF;
				FOR i IN 0 TO numDFF-1 LOOP         
					WAIT UNTIL clk = '1';  
					saved_PPO(index) := So;
					index := index - 1;
				END LOOP;
				
				IF (cur_expected_PPO /= saved_PPO) THEN
					detected := '1';
				END IF;
--				WRITE (lbufD, string'("I am in the part for the last test pattern @ "));
--				WRITE (lbufD, NOW);
--				WRITE (lbufD, string'(" --- detected is "));
--				WRITE (lbufD, detected);
--				WRITE (lbufD, string'(" *** cur_expected_PPO = "));
--				WRITE (lbufD, cur_expected_PPO);
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