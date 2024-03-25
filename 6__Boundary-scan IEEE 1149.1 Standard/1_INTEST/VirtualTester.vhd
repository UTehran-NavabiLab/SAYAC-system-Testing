--******************************************************************************
--	Filename:		VirtualTester.vhd
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
--	Testbench as a virtual tester for JTAG testing                              
--******************************************************************************

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;

ENTITY VirtualTester IS
END VirtualTester;

ARCHITECTURE test OF VirtualTester IS 
    CONSTANT instructionWidth : INTEGER := 3;
	CONSTANT numDFF    : INTEGER := 90;
	CONSTANT sizePI    : INTEGER := 49;
	CONSTANT sizePO    : INTEGER := 64;
	CONSTANT clkPeriod : time    := 10 ns;

	CONSTANT bypass_instruction : STD_LOGIC_VECTOR (2 DOWNTO 0) := "111";
    CONSTANT intest_instruction : STD_LOGIC_VECTOR (2 DOWNTO 0) := "011";
    CONSTANT sample_instruction : STD_LOGIC_VECTOR (2 DOWNTO 0) := "010";
    CONSTANT preload_instruction: STD_LOGIC_VECTOR (2 DOWNTO 0) := "001";
    CONSTANT extest_instruction : STD_LOGIC_VECTOR (2 DOWNTO 0) := "000";

    SIGNAL TCLK : STD_LOGIC := '1';
    SIGNAL TMS, TDI : STD_LOGIC;
	SIGNAL ClkCUT : STD_LOGIC := '1';
	SIGNAL RstCUT : STD_LOGIC := '0';
    SIGNAL In_Pin : STD_LOGIC_VECTOR (sizePI-1 DOWNTO 0);
    SIGNAL Out_Pin: STD_LOGIC_VECTOR (sizePO-1 DOWNTO 0);
    SIGNAL TDO : STD_LOGIC;

	SIGNAL faultInjection : STD_LOGIC := '0';
	SIGNAL dumpDataMemory : STD_LOGIC := '0';
	SIGNAL stopSimulation : BOOLEAN := false;
BEGIN
    FUT : ENTITY WORK.BS_SAYAC_CPU PORT MAP (TCLK, TMS, TDI, ClkCUT, RstCUT, In_Pin, Out_Pin, TDO); 
	
	TCLK <= NOT TCLK AFTER clkPeriod/2; 
	ClkCUT <= TCLK;
	
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
		VARIABLE Instruction : STD_LOGIC_VECTOR (instructionWidth-1 DOWNTO 0);
	BEGIN
		FILE_OPEN (fstatusW, debugFile, "debugFile.txt", write_mode);
	    FILE_OPEN (fstatusW, reportFile, "reportFile.txt", write_mode);
		WRITE (lbufW, string'("===================================> @ "));
		WRITE (lbufW, NOW);
		WRITE (lbufW, string'("   JTAG MODE is starting ... "));
		WRITELINE (reportFile, lbufW);

	    FOR i IN 1 TO 5 LOOP                         -- 5 consecutive clocks for resetting
		    TMS <= '1';
		    WAIT UNTIL TCLK = '0'; 	     
        END LOOP;
		
		TMS <= '0'; WAIT UNTIL TCLK = '0';           -- run_test_idle
		TMS <= '1'; WAIT UNTIL TCLK = '0';           -- select_DR
		TMS <= '1'; WAIT UNTIL TCLK = '0';           -- select_IR
		TMS <= '0'; WAIT UNTIL TCLK = '0';           -- capture_IR
		TMS <= '0'; WAIT UNTIL TCLK = '0';           -- shift_IR
		
		Instruction := intest_instruction;
		
		FOR i IN 0 TO instructionWidth-2 LOOP         
		    TDI	<= Instruction (i); 
		    TMS	<= '0';	WAIT UNTIL TCLK = '0';       -- shift_IR     
        END LOOP;
		TDI	<= Instruction (instructionWidth-1);
		
		TMS	<= '1';	WAIT UNTIL TCLK = '0';  		 -- exit_IR
		TMS <= '1';	WAIT UNTIL TCLK = '0';   		 -- update_IR
		TMS <= '1';	WAIT UNTIL TCLK = '0';  		 -- select_DR
		TMS <= '0'; WAIT UNTIL TCLK = '0';		     -- capture_DR
		
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

			READLINE (testFile, lbufR);
			READ (lbufR, testLine);
			load_PPI := testLine(1 TO numDFF);
			load_PI := testLine(numDFF+1 TO numDFF+sizePI);
			FOR i IN 1 TO sizePI LOOP
				load_PI_Rever(sizePI+1-i) := load_PI(i);
			END LOOP; 
			load_In := (load_PI_Rever & load_PPI);
			cur_expected_st := testLine(numDFF+sizePI+1 TO 2*numDFF+sizePI+sizePO);                             
		
--			TMS <= '1';	WAIT UNTIL TCLK = '0';  		 -- select_DR
--			TMS <= '0'; WAIT UNTIL TCLK = '0';		     -- capture_DR
			RstCUT <= '0'; 
			TMS <= '0'; WAIT UNTIL TCLK = '0'; 		     -- shift_DR
			RstCUT <= '1';

			index := numDFF+sizePI;
			FOR i IN 0 TO numDFF+sizePI-2 LOOP         
			    TDI	<=  load_In (index);
			    TMS	<= '0';	WAIT UNTIL TCLK = '0';       -- shift_DR
			    index := index - 1;       
        	END LOOP;
			TDI	<= load_In (1);
			TMS	<= '1';	WAIT UNTIL TCLK = '0';		     -- exit_DR

			testNum := 0;
			WHILE (NOT ENDFILE (testFile) AND detected = '0') LOOP
				TMS <= '1';	WAIT UNTIL TCLK = '0';		     -- update_DR

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

			    TMS <= '1';	WAIT UNTIL TCLK = '0';	     -- select_DR
				TMS <= '0';	WAIT UNTIL TCLK = '0';	     -- capture_DR
			    TMS <= '0'; WAIT UNTIL TCLK = '0';	     -- shift_DR

			    index := sizePO;	
        	    FOR i IN 0 TO sizePO-sizePI-1 LOOP                 
			        TMS <= '0'; WAIT UNTIL TCLK = '0';   -- shift_DR
			        saved_PO(index) := TDO;
			        index := index - 1;     
        	    END LOOP;

				index := sizePI;
				FOR i IN 0 TO sizePI-1 LOOP   
					TDI	<=  load_In (index+numDFF);
					TMS <= '0'; WAIT UNTIL TCLK = '0';   -- shift_DR
					saved_PO(index) := TDO;
					index := index - 1;
				END LOOP;

				index := numDFF;
				FOR i IN 0 TO numDFF-2 LOOP   
					TDI	<=  load_In (index);
					TMS <= '0'; WAIT UNTIL TCLK = '0';   -- shift_DR
					saved_PPO(index) := TDO;
					index := index - 1;
				END LOOP;
				TDI	<= load_In (1);
				TMS	<= '1';	WAIT UNTIL TCLK = '0';		 -- exit_DR
				saved_PPO(1) := TDO;

				FOR i IN 1 TO sizePO LOOP
					saved_PO_Rever(sizePO+1-i) := saved_PO(i);
				END LOOP; 
				saved_Out := (saved_PO_Rever & saved_PPO);

				IF (pre_expected_st /= saved_Out) THEN
					detected := '1';
				END IF;

				WRITE (lbufD, string'("I am in the test loop @ "));
				WRITE (lbufD, NOW);
				WRITE (lbufD, string'(" --- detected is "));
				WRITE (lbufD, detected);
				WRITE (lbufD, string'(" *** pre_expected_st = "));
				WRITE (lbufD, pre_expected_st);
				WRITE (lbufD, string'(" *** saved_Out = "));
				WRITE (lbufD, saved_Out);
				WRITELINE (debugFile, lbufD);
			END LOOP; 	

			IF (detected /= '1') THEN
				TMS <= '1';	WAIT UNTIL TCLK = '0';		 -- update_DR

				TMS <= '1';	WAIT UNTIL TCLK = '0';	     -- select_DR
				TMS <= '0';	WAIT UNTIL TCLK = '0';	     -- capture_DR
			    TMS <= '0'; WAIT UNTIL TCLK = '0';	     -- shift_DR

				index := sizePO;
				FOR i IN 0 TO sizePO-1 LOOP         
					TMS <= '0'; WAIT UNTIL TCLK = '0';   -- shift_DR
					saved_PO(index) := TDO;
					index := index - 1;
				END LOOP; 

				index := numDFF;
				FOR i IN 0 TO numDFF-2 LOOP         
					TMS <= '0'; WAIT UNTIL TCLK = '0';   -- shift_DR
					saved_PPO(index) := TDO;
					index := index - 1;
				END LOOP;
				TMS	<= '1';	WAIT UNTIL TCLK = '0';		 -- exit_DR
				saved_PPO(1) := TDO;

				FOR i IN 1 TO sizePO LOOP
					saved_PO_Rever(sizePO+1-i) := saved_PO(i);
				END LOOP;
				saved_Out := (saved_PO_Rever & saved_PPO);

				IF (cur_expected_st /= saved_Out) THEN
					detected := '1';
				END IF;
				WRITE (lbufD, string'("I am in the part for the last test pattern @ "));
				WRITE (lbufD, NOW);
				WRITE (lbufD, string'(" --- detected is "));
				WRITE (lbufD, detected);
				WRITE (lbufD, string'(" *** cur_expected_st = "));
				WRITE (lbufD, cur_expected_st);
				WRITE (lbufD, string'(" *** saved_Out = "));
				WRITE (lbufD, saved_Out);
				WRITELINE (debugFile, lbufD);
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

			TMS <= '1';	WAIT UNTIL TCLK = '0'; 	     -- update_DR
			TMS <= '1';	WAIT UNTIL TCLK = '0';  	 -- select_DR
			TMS <= '0'; WAIT UNTIL TCLK = '0';		 -- capture_DR
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
		
		TMS <= '1';	WAIT UNTIL TCLK = '0'; 	  	     -- select_DR
	    TMS <= '1';	WAIT UNTIL TCLK = '0'; 		     -- select_IR
		TMS <= '1';	WAIT UNTIL TCLK = '0'; 		     -- test_logic_reset
		stopSimulation <= true;
		WAIT;

	END PROCESS;	 

END ARCHITECTURE test;

  