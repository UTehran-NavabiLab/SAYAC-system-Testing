--******************************************************************************
--	Filename:		VirtualTester_Scan_MBIST.vhd
--	Project:		SAYAC Testing
--  Version:		0.90
--	History:
--	Date:			26 July 2022
--	Last Author: 	DELARAM & NOOSHIN
--  Copyright (C) 2022 University of Teheran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--
--******************************************************************************
--	File content description:
--	Test programs for Scan, RAM MBIST, TRF MBIST and ROM MBIST                               
--******************************************************************************
LIBRARY IEEE;     
USE IEEE.STD_LOGIC_1164.ALL;
USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE ieee.NUMERIC_STD.ALL;
USE IEEE.MATH_REAL.ALL; 

ENTITY VirtualTester IS
END ENTITY VirtualTester;

ARCHITECTURE test OF VirtualTester IS

	CONSTANT numDFF      : INTEGER := 90;
	CONSTANT sizePI      : INTEGER := 49;
	CONSTANT sizePO      : INTEGER := 64;
	CONSTANT chainLength : INTEGER := 25;
	CONSTANT clkPeriod   : time    := 10 Ns;
	CONSTANT romSeg		 : INTEGER := 6;

	SIGNAL clk : STD_LOGIC := '0';
	SIGNAL rst : STD_LOGIC := '0';
	SIGNAL NbarT, PbarS : STD_LOGIC := '0';
	SIGNAL Si_1, Si_2, Si_3, Si_4, Si_5, Si_6 : STD_LOGIC;
	SIGNAL So_1, So_2, So_3, So_4, So_5, So_6, So_7 : STD_LOGIC;
	
	SIGNAL faultInjection : STD_LOGIC := '0';
	SIGNAL dumpDataMemory : STD_LOGIC := '0';
	SIGNAL stopSimulation : BOOLEAN := false;

	--MBIST SIGNALS:
	SIGNAL EOF_ROM_TEST, EOF_TRF_TEST, EOF_RAM_TEST : STD_LOGIC;
	SIGNAL faultInjection_TRF , faultInjection_RAM : STD_LOGIC;
	TYPE SIGNATURE_ARRAY IS ARRAY (0 TO romSeg-1) OF STD_LOGIC_VECTOR (15 DOWNTO 0);

	FUNCTION create_faulty_val (RWDATA : STD_LOGIC_VECTOR (15 DOWNTO 0);
					BIT_POS_TBF_S: STD_LOGIC_VECTOR (3 DOWNTO 0);
					Fault_Type_TBF_S: STD_LOGIC_VECTOR (1 DOWNTO 0)) RETURN STD_LOGIC IS
		VARIABLE faulty_bit, to_be_inverted: STD_LOGIC;
		VARIABLE faultied: STD_LOGIC_VECTOR (15 DOWNTO 0);
		BEGIN
		faultied := RWDATA;
		to_be_inverted := RWDATA(TO_INTEGER(UNSIGNED(BIT_POS_TBF_S)));
		CASE (Fault_Type_TBF_S) IS
			WHEN "00" =>
			--stuck at zero
				faulty_bit := '0';
			WHEN "01" =>
			--inversion
				faulty_bit := NOT to_be_inverted;
			WHEN "11" | "10" =>
			--stuck at one
				faulty_bit := '1';
			WHEN  OTHERS =>
		END CASE;
		RETURN faulty_bit;
	END FUNCTION create_faulty_val;

	--READ GOLDEN SIGNATURE FILE FUNCTION
	IMPURE FUNCTION READ_GOLDEN_SIGNATURE RETURN SIGNATURE_ARRAY is
		FILE SIGNATURE_FILE : TEXT OPEN READ_MODE IS "GOLDEN_SIGNATURE.txt";
		VARIABLE SIGNFileLine : LINE;
		VARIABLE GOOD : BOOLEAN;
		VARIABLE fstatus: FILE_OPEN_STATUS;
		VARIABLE SIGNATURE : SIGNATURE_ARRAY;
		BEGIN
			FOR I IN 0 TO romSeg-1 LOOP
				IF NOT ENDFILE(SIGNATURE_FILE) THEN
					READLINE(SIGNATURE_FILE, SIGNFileLine);
					READ(SIGNFileLine, SIGNATURE(I), GOOD);
		--			REPORT "Status from FILE: '" & BOOLEAN'IMAGE(GOOD) & "'";
				END IF;
			END LOOP;
			FILE_close(SIGNATURE_FILE);
			RETURN SIGNATURE;
	END FUNCTION READ_GOLDEN_SIGNATURE;

BEGIN
	
	FUT: ENTITY WORK.testableSAYAC 
			GENERIC MAP (sizePI, sizePO, chainLength)
			PORT MAP (
				clk   => clk, 
				rst   => rst, 
				NbarT => NbarT,
				PbarS => PbarS,
				Si_1  => Si_1,
				Si_2  => Si_2,
				Si_3  => Si_3,
				Si_4  => Si_4,
				Si_5  => Si_5,
				Si_6  => Si_6,
				So_1  => So_1,
				So_2  => So_2,
				So_3  => So_3,
				So_4  => So_4,
				So_5  => So_5,
				So_6  => So_6,
				So_7  => So_7
				);
	
	clk <= NOT clk AFTER clkPeriod/2;
	
	STRAT_MEMORY_TEST : PROCESS
	FILE TRF_REPORT_FILE : text OPEN write_mode IS "Report_TRF.txt";
		FILE ROM_REPORT_FILE : text OPEN write_mode IS "Report_ROM.txt";
		FILE RAM_REPORT_FILE : text OPEN write_mode IS "Report_RAM.txt";
		FILE reportFile : TEXT; 
		VARIABLE R_LINE : LINE;
		VARIABLE str : string(1 TO 120);
		VARIABLE strSize : natural;
		VARIABLE fstatusW : FILE_OPEN_STATUS;
	    VARIABLE lbufR, lbufW, lbufD : LINE;
		ALIAS TRF_START_SIGNAL : STD_LOGIC IS << SIGNAL .VirtualTester.FUT.TRF_START:STD_LOGIC>>;
		ALIAS ROM_MBIST_START_SIGNAL : STD_LOGIC IS << SIGNAL .VirtualTester.FUT.ROM_MBIST_START:STD_LOGIC>>;
		ALIAS RAM_START_SIGNAL : STD_LOGIC IS << SIGNAL .VirtualTester.FUT.RAM_START:STD_LOGIC>>;



	BEGIN
		FILE_OPEN (fstatusW, reportFile, "Report_SCAN.txt", write_mode);	

		WRITE (lbufW, string'("===================================> @ "));
		WRITE (lbufW, NOW);
		WRITE (lbufW, string'("   NORMAL MODE is starting ... "));
		WRITELINE (reportFile, lbufW);

		NbarT <= '0'; 
		WAIT FOR 6000 ns;
		dumpDataMemory <= '1';
		WAIT FOR 10 ns;
		dumpDataMemory <= '0';
		WAIT FOR 0 NS;

		NbarT <= '1';
		TRF_START_SIGNAL <= '1';
		strSize := to_string(NOW, ms)'length;
		str := (OTHERS => ' ');
		str(1 TO 72 + strSize) := "===================================> @ "&to_string(NOW , ms)&"  TRF MBIST MODE is starting ... ";
		WRITE(R_LINE, str);
		writeline(TRF_REPORT_FILE, R_LINE);
		WAIT UNTIL EOF_TRF_TEST = '1';
		TRF_START_SIGNAL <= '0';
		WAIT FOR 0 NS;

		ROM_MBIST_START_SIGNAL <= '1';
		strSize := to_string(NOW, Ns)'length;
		str := (OTHERS => ' ');
		str(1 TO 73 + strSize) := "===================================> @ "&to_string(NOW , Ns)&"   ROM MBIST MODE is starting ... ";
		WRITE(R_LINE, str);
		writeline(ROM_REPORT_FILE, R_LINE);
		WAIT UNTIL EOF_ROM_TEST = '1';
		ROM_MBIST_START_SIGNAL <= '0';
		WAIT FOR 0 NS;

		RAM_START_SIGNAL <= '1';
		strSize := to_string(NOW, ms)'length;
		str := (OTHERS => ' ');
		str(1 TO 69 + strSize) := "===================================> @ "&to_string(NOW , ms)&"   MBIST MODE is starting ... ";
		WRITE(R_LINE, str);
		writeline(RAM_REPORT_FILE, R_LINE);
		WAIT UNTIL EOF_RAM_TEST = '1';
		RAM_START_SIGNAL <= '0';
		WAIT FOR 0 NS;
	END PROCESS;


	FI:PROCESS 
		VARIABLE detected : STD_LOGIC := '0';
		VARIABLE numOfDetecteds : INTEGER := 0;
		VARIABLE numOfFaults : INTEGER := 0;
		VARIABLE testNum : INTEGER := 0;
		VARIABLE load_PI : STD_LOGIC_VECTOR (1 TO sizePI);
		VARIABLE load_PI_Rever : STD_LOGIC_VECTOR (1 TO sizePI);
		VARIABLE saved_PO : STD_LOGIC_VECTOR (1 TO sizePO+11);				-- (+11) for fake DFFs	
		VARIABLE saved_PO_Rever : STD_LOGIC_VECTOR (1 TO sizePO);
		VARIABLE saved_PPO : STD_LOGIC_VECTOR (1 TO numDFF+10);				-- (+10) for fake DFFs
		VARIABLE load_PPI : STD_LOGIC_VECTOR (1 TO numDFF);
		VARIABLE load_In : STD_LOGIC_VECTOR (1 TO numDFF+sizePI+11);		-- (+11) for fake DFFs
		VARIABLE saved_Out : STD_LOGIC_VECTOR (1 TO numDFF+sizePO);
		VARIABLE pre_expected_st, cur_expected_st : STD_LOGIC_VECTOR (1 TO numDFF+sizePO);
		VARIABLE index : INTEGER;
	    FILE faultFile, testFile, reportFile, debugFile : TEXT; 
        VARIABLE fstatusR, fstatusW : FILE_OPEN_STATUS;
	    VARIABLE lbufR, lbufW, lbufD : LINE;
	    VARIABLE testLine : STD_LOGIC_VECTOR (1 TO sizePO + sizePI + (2 * numDFF));
		VARIABLE str : string(1 to 100);
		VARIABLE strSize : INTEGER;
		VARIABLE wireName : STRING(1 TO 100);
		VARIABLE stuckAtVal : STD_LOGIC;
		VARIABLE coverage : REAL;

		ALIAS TRF_RST_SIGNAL : STD_LOGIC IS << SIGNAL .VirtualTester.FUT.TRF_RST:STD_LOGIC>>;
		ALIAS ROM_RST_SIGNAL : STD_LOGIC IS << SIGNAL .VirtualTester.FUT.ROM_RST:STD_LOGIC>>;
		ALIAS RAM_RST_SIGNAL : STD_LOGIC IS << SIGNAL .VirtualTester.FUT.RAM_RST:STD_LOGIC>>;
	BEGIN
		FILE_OPEN (fstatusW, reportFile, "Report_SCAN.txt", write_mode);	

		WHILE (NBART = '1') LOOP END LOOP;
		rst <= '1';
		TRF_RST_SIGNAL <= '1';
		RAM_RST_SIGNAL <= '1';
		ROM_RST_SIGNAL <= '1';
		WAIT UNTIL clk = '1';
		rst <= '0'; 
		TRF_RST_SIGNAL <= '0';
		RAM_RST_SIGNAL <= '0';
		ROM_RST_SIGNAL <= '0';

		WAIT UNTIL NbarT = '1';
		WRITE (lbufW, string'("===================================> @ "));
		WRITE (lbufW, NOW);
		WRITE (lbufW, string'("   SCAN TEST MODE is starting ... "));
		WRITELINE (reportFile, lbufW);
		

		FILE_OPEN (fstatusR, faultFile, "SAYAC.flt", read_mode);
		numOfFaults := 0;
		numOfDetecteds := 0;
		WHILE (NOT ENDFILE (faultFile)) LOOP
			READLINE (faultFile, lbufR);
			assert lbufR'length < str'length;  
			str := (OTHERS => ' '); 
			strSize := lbufR'length;
			read(lbufR, str(1 to strSize));
			wireName := (OTHERS => ' ');
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
			load_In := (load_PI_Rever & '0' & load_PPI & "0000000000");
			cur_expected_st := testLine(numDFF+sizePI+1 TO 2*numDFF+sizePI+sizePO);
			
			PbarS <= '1';

			index := chainLength;
			FOR i IN 0 TO chainLength-1 LOOP   
				Si_1	<=  load_In (index);
				Si_2	<=  load_In (1*chainLength+index);
				Si_3	<=  load_In (2*chainLength+index);
				Si_4	<=  load_In (3*chainLength+index);
				Si_5	<=  load_In (4*chainLength+index);
				Si_6	<=  load_In (5*chainLength+index);
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
				load_In := (load_PI_Rever & '0' & load_PPI & "0000000000");
				cur_expected_st := testLine(numDFF+sizePI+1 TO 2*numDFF+sizePI+sizePO);
				testNum := testNum + 1;
				
				PbarS <= '1';
				
				index := chainLength;
				FOR i IN 0 TO chainLength-1 LOOP   
					Si_1	<=  load_In (index);
					Si_2	<=  load_In (1*chainLength+index);
					Si_3	<=  load_In (2*chainLength+index);
					Si_4	<=  load_In (3*chainLength+index);
					Si_5	<=  load_In (4*chainLength+index);
					Si_6	<=  load_In (5*chainLength+index);
					WAIT UNTIL clk = '1';
					saved_PO(2*chainLength+index) := So_7;
					saved_PO(1*chainLength+index) := So_6;
					saved_PO(index) := So_5;
					saved_PPO(3*chainLength+index) := So_4;
					saved_PPO(2*chainLength+index) := So_3;
					saved_PPO(1*chainLength+index) := So_2;
					saved_PPO(index) := So_1;
					index := index - 1;
				END LOOP;
				
				FOR i IN 1 TO sizePO LOOP
					saved_PO_Rever(sizePO+1-i) := saved_PO(i);
				END LOOP; 
				saved_Out := (saved_PO_Rever & saved_PPO(1 TO numDFF));
				
				IF (pre_expected_st /= saved_Out) THEN
					detected := '1';
				END IF;
			END LOOP; 	
			
			IF (detected /= '1') THEN
				PbarS <= '0';
				WAIT UNTIL clk = '1';
				
				PbarS <= '1';

				index := chainLength;
				FOR i IN 0 TO chainLength-1 LOOP   
					WAIT UNTIL clk = '1';
					saved_PO(2*chainLength+index) := So_7;
					saved_PO(1*chainLength+index) := So_6;
					saved_PO(index) := So_5;
					saved_PPO(3*chainLength+index) := So_4;
					saved_PPO(2*chainLength+index) := So_3;
					saved_PPO(1*chainLength+index) := So_2;
					saved_PPO(index) := So_1;
					index := index - 1;
				END LOOP;
				
				FOR i IN 1 TO sizePO LOOP
					saved_PO_Rever(sizePO+1-i) := saved_PO(i);
				END LOOP;
				saved_Out := (saved_PO_Rever & saved_PPO(1 TO numDFF));
				
				IF (cur_expected_st /= saved_Out) THEN
					detected := '1';
				END IF;
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

		stopSimulation <= true;
		WAIT;	
 	END PROCESS;

	--RAM TEST PROGRAM : 
	TP_RAM : PROCESS
		VARIABLE ADDRESS_TBF :  STD_LOGIC_VECTOR(15 DOWNTO 0);
		VARIABLE BIT_POS_TBF :  STD_LOGIC_VECTOR(3 DOWNTO 0) ;
		VARIABLE Fault_Type_TBF :  STD_LOGIC_VECTOR(1 DOWNTO 0);
		FILE F_FILE : text IS IN "RAM_FAULT_LIST.txt";
		VARIABLE F_LINE : LINE;
		FILE REPORT_FILE : text OPEN WRITE_MODE IS "Report_RAM.txt";
		VARIABLE R_LINE : LINE;
		VARIABLE str : string(1 TO 150);
		VARIABLE strSize : INTEGER;
		VARIABLE wireName : STRING(1 TO 100);
		VARIABLE stuckAtVal : STD_LOGIC;
		VARIABLE faulty_BIT : STD_LOGIC;
		VARIABLE RAM_injected : STD_LOGIC;
		VARIABLE FAULT : STD_LOGIC_VECTOR(21 DOWNTO 0);
		VARIABLE match : BOOLEAN;
		VARIABLE num_of_detected :INTEGER := 0;
		VARIABLE numfault :  INTEGER := 0;
		VARIABLE COV : REAL := 0.0;
		VARIABLE RAM_NEOF_SIGNAL : STD_LOGIC;
		--SIGNAL ALIASING FOR HIERARCHICAL ACCESS :
		ALIAS RAM_START_SIGNAL : STD_LOGIC IS << SIGNAL .VirtualTester.FUT.RAM_START:STD_LOGIC>>;
		ALIAS RAM_FAIL_SIGNAL : STD_LOGIC IS << SIGNAL .VirtualTester.FUT.RAM_MBIST.DATAPATH.FAIL:STD_LOGIC>>;
		ALIAS RAM_end_of_TV_test_SIGNAL : STD_LOGIC IS << SIGNAL .VirtualTester.FUT.RAM_MBIST.CONTROLLER.end_of_TV_test:STD_LOGIC>>;
		ALIAS RAM_DETECTED_SIGNAL : STD_LOGIC IS << SIGNAL .VirtualTester.FUT.RAM_DETECTED:STD_LOGIC>>;
		ALIAS RAM_WM_SIGNAL : STD_LOGIC IS << SIGNAL .VirtualTester.FUT.RAM_MBIST.write_to_Mem:STD_LOGIC>>;
		ALIAS RAM_TEST_DATA : STD_LOGIC_VECTOR(15 DOWNTO 0) IS << SIGNAL .VirtualTester.FUT.RAM_MBIST.DATAPATH.test_data:STD_LOGIC_VECTOR(15 DOWNTO 0)>>; 	

		BEGIN
		WAIT UNTIL RAM_START_SIGNAL = '1';
		WHILE (TRUE) LOOP
			IF (RAM_START_SIGNAL = '1') THEN
					EOF_RAM_TEST <= '0';
					WAIT FOR 0 NS;
			END IF;

			IF (NOT ENDFILE (F_FILE)) THEN
				RAM_NEOF_SIGNAL := '1';
			ELSE
				RAM_NEOF_SIGNAL := '0';
			END IF;
			WAIT FOR 0 NS;

			IF (RAM_end_of_TV_test_SIGNAL = '1' AND RAM_NEOF_SIGNAL = '1') THEN			
				READLINE(F_FILE, F_LINE);
				READ (F_LINE, FAULT);
				ADDRESS_TBF := FAULT(21 DOWNTO 6);
				BIT_POS_TBF := FAULT(5 DOWNTO 2);
				Fault_Type_TBF := FAULT(1 DOWNTO 0);
				RAM_injected := '1';
			ELSE 
				RAM_injected := '0';
			END IF;

			IF RAM_WM_SIGNAL = '1' THEN
				IF (ADDRESS_TBF = << SIGNAL .VirtualTester.FUT.RAM_MBIST.memAddr:STD_LOGIC_VECTOR (15 DOWNTO 0) >>) then match := true; else match := false; end if;
				IF (match) THEN
				-- INJECT FAULT
					faulty_BIT := create_faulty_val(RAM_TEST_DATA, BIT_POS_TBF, Fault_Type_TBF);
					IF (TO_INTEGER(UNSIGNED(BIT_POS_TBF)) > 9) THEN strSize := 44; ELSE strSize := 43; END IF;
					wireName := (OTHERS => ' ');
					wireName(1 TO strSize) := "VirtualTester/FUT/RAM_MBIST/memDataWrite("&TO_STRING(TO_INTEGER(UNSIGNED(BIT_POS_TBF)))&")";
					stuckAtVal := faulty_BIT;
					faultInjection_RAM <= '1';
					WAIT FOR 0 NS;
				ELSE
				--MEMORY LOCATION IS INTACT
					faulty_BIT := create_faulty_val(RAM_TEST_DATA, BIT_POS_TBF,Fault_Type_TBF);
					IF (TO_INTEGER(UNSIGNED(BIT_POS_TBF)) > 9) THEN strSize := 44; ELSE strSize := 43; END IF;
					wireName := (OTHERS => ' ');
					wireName(1 TO strSize) := "VirtualTester/FUT/RAM_MBIST/memDataWrite("&TO_STRING(TO_INTEGER(UNSIGNED(BIT_POS_TBF)))&")";
					stuckAtVal := faulty_BIT;
					faultInjection_RAM <= '0';
					WAIT FOR 0 NS;
				END IF;
			END IF;

			IF (clk = '1') THEN
				IF(RAM_FAIL_SIGNAL = '1' AND RAM_DETECTED_SIGNAL = '0') THEN
					--DETECTED FAULT REPORT:
					strSize := to_string(RAM_TEST_DATA)'LENGTH
								+to_string(NOW, ms)'LENGTH;
					str :=  (OTHERS => ' ');
					str(1 to strSize+28 ) :="Detected by TestVector = "
								&to_string(RAM_TEST_DATA)
								&" @ "&to_string(NOW, ms);
					WRITE(R_LINE, str);
					writeline(REPORT_FILE, R_LINE);
					RAM_DETECTED_SIGNAL <= '1';
					WAIT FOR 0 NS;
					numfault := numfault+1;
					num_of_detected := num_of_detected + 1;
				END IF;
				IF (RAM_injected = '1') THEN
					RAM_DETECTED_SIGNAL <= '0';
					WAIT FOR 0 NS;
				END IF; 
			END IF;

			IF (RAM_injected = '1') THEN
				faulty_BIT := create_faulty_val(RAM_TEST_DATA, BIT_POS_TBF, Fault_Type_TBF);
				strSize := to_string(NOW, ms)'LENGTH + INTEGER'IMAGE(numfault)'LENGTH 
							+to_string(Address_TBF)'LENGTH 
							+ to_string(faulty_BIT)'LENGTH 
							+ INTEGER'IMAGE(to_integer(unsigned(BIT_POS_TBF)))'LENGTH ;
				str := (OTHERS => ' ');
				str(1 to strSize+58) :="faultNum "&INTEGER'IMAGE(numfault)
							&" = SA@"&to_string(faulty_BIT)
							&" on Address = "&to_string(Address_TBF)
							&", Bit Position = "&INTEGER'IMAGE(to_integer(unsigned(BIT_POS_TBF)))
							&" injected @ "&to_string(NOW, ms);
				WRITE(R_LINE, str);
				writeline(REPORT_FILE, R_LINE);
			END IF;

			IF (RAM_NEOF_SIGNAL = '0' AND RAM_DETECTED_SIGNAL = '1' AND RAM_START_SIGNAL = '1') THEN
				---COVERAGE REPORT:
				strSize := INTEGER'IMAGE(num_of_detected)'LENGTH
							+INTEGER'IMAGE(numfault)'LENGTH
							+REAL'IMAGE(COV)'LENGTH;
				COV := (REAL(num_of_detected) / REAL(numfault)) * REAL(100);

				FOR I IN 0 TO 2 LOOP
					str := (OTHERS => ' ');
					str(1 to 67) :=  "*******************************************************************";
					WRITE(R_LINE, str);
					writeline(REPORT_FILE, R_LINE);
				END LOOP;

				str := (OTHERS => ' ');
				strSize := INTEGER'IMAGE(num_of_detected)'LENGTH;
				str(1 to strSize+15) := "numOfDetected: "&INTEGER'IMAGE(num_of_detected);
				WRITE(R_LINE, str);
				writeline(REPORT_FILE, R_LINE);

				str := (OTHERS => ' ');
				strSize := INTEGER'IMAGE(numfault)'LENGTH;
				str(1 to strSize+13) := "numOfFaults: "&INTEGER'IMAGE(numfault);
				WRITE(R_LINE, str);
				writeline(REPORT_FILE, R_LINE);

				str := (OTHERS => ' ');
				strSize := REAL'IMAGE(COV)'LENGTH;
				str(1 to strSize+13) := "Coverage = "&REAL'IMAGE(COV)&" %";
				WRITE(R_LINE, str);
				writeline(REPORT_FILE, R_LINE);

				EOF_RAM_TEST <= '1';
				WAIT UNTIL CLK = '1';
				END IF;
			WAIT UNTIL CLK = '1';
		END LOOP;
		WAIT;
	END PROCESS;


 
	--TRF TEST PROGRAM :
	TP_TRF : PROCESS
		VARIABLE ADDRESS_TBF :  STD_LOGIC_VECTOR(3 DOWNTO 0);
		VARIABLE BIT_POS_TBF :  STD_LOGIC_VECTOR(3 DOWNTO 0) ;
		VARIABLE Fault_Type_TBF :  STD_LOGIC_VECTOR(1 DOWNTO 0);
		FILE F_FILE : text IS IN "TRF_FAULT_LIST.txt";
		VARIABLE F_LINE : LINE;
		FILE REPORT_FILE : text OPEN WRITE_MODE IS "Report_TRF.txt";
		VARIABLE R_LINE : LINE;
		VARIABLE str : string(1 to 100);
		VARIABLE strSize : INTEGER;
		VARIABLE wireName : STRING(1 TO 100);
		VARIABLE stuckAtVal : STD_LOGIC;
		VARIABLE faulty_BIT : STD_LOGIC;
		VARIABLE TRF_injected : STD_LOGIC;
		VARIABLE FAULT : STD_LOGIC_VECTOR(9 DOWNTO 0);
		VARIABLE match : BOOLEAN;
		VARIABLE num_of_detected : INTEGER := 0;
		VARIABLE numfault : INTEGER := 0;
		VARIABLE COV : REAL:=0.0;
		VARIABLE TRF_NEOF_SIGNAL : STD_LOGIC;
		--SIGNAL ALIASING FOR HIERARCHICAL ACCESS :
		ALIAS TRF_START_SIGNAL : STD_LOGIC IS << SIGNAL .VirtualTester.FUT.TRF_START:STD_LOGIC>>;
		ALIAS TRF_FAIL_SIGNAL : STD_LOGIC IS << SIGNAL .VirtualTester.FUT.TRF_MBIST.DATAPATH.FAIL:STD_LOGIC>>;
		ALIAS TRF_end_of_TV_SIGNAL : STD_LOGIC IS << SIGNAL .VirtualTester.FUT.TRF_MBIST.CONTROLLER.end_of_TV_test:STD_LOGIC>>;
		ALIAS TRF_DETECTED_SIGNAL : STD_LOGIC IS << SIGNAL .VirtualTester.FUT.TRF_DETECTED:STD_LOGIC>>;
		ALIAS TRF_WRITE_TO_SIGNAL : STD_LOGIC IS << SIGNAL .VirtualTester.FUT.TRF_MBIST.write_to_TRF:STD_LOGIC>>;
		ALIAS TRF_TEST_DATA : STD_LOGIC_VECTOR(15 DOWNTO 0) IS << SIGNAL .VirtualTester.FUT.TRF_MBIST.DATAPATH.test_data:STD_LOGIC_VECTOR(15 DOWNTO 0)>>; 	

	 BEGIN
	 	WAIT UNTIL TRF_START_SIGNAL = '1';
		WHILE (TRUE) LOOP
			IF (TRF_START_SIGNAL = '1') THEN
					EOF_TRF_TEST <= '0';
					WAIT FOR 0 NS;
			END IF;

			IF (NOT ENDFILE (F_FILE)) THEN
				TRF_NEOF_SIGNAL := '1';
			ELSE
				TRF_NEOF_SIGNAL := '0';
			END IF;

			IF (TRF_end_of_TV_SIGNAL = '1' AND TRF_NEOF_SIGNAL = '1') THEN			
				READLINE(F_FILE, F_LINE);
				READ (F_LINE, FAULT);
				ADDRESS_TBF := FAULT(9 DOWNTO 6);
				BIT_POS_TBF := FAULT(5 DOWNTO 2);
				Fault_Type_TBF := FAULT(1 DOWNTO 0);
				TRF_injected := '1';
			ELSE 
				TRF_injected := '0';
			END IF;

			IF TRF_WRITE_TO_SIGNAL = '1' THEN
				IF (ADDRESS_TBF = << SIGNAL .VirtualTester.FUT.TRF_MBIST.TRFAddr:STD_LOGIC_VECTOR (3 DOWNTO 0) >>) then match := true; else match := false; end if;
				IF (match) THEN
				-- INJECT FAULT
					faulty_BIT := create_faulty_val(TRF_TEST_DATA, BIT_POS_TBF, Fault_Type_TBF);
					IF (TO_INTEGER(UNSIGNED(BIT_POS_TBF)) > 9) THEN strSize := 42; ELSE strSize := 41; END IF;
					wireName := (OTHERS => ' ');
					wireName(1 TO strSize) := "VirtualTester/FUT/TRF_MBIST/TRFData_IN("&TO_STRING(TO_INTEGER(UNSIGNED(BIT_POS_TBF)))&")";
					stuckAtVal := faulty_BIT;
					faultInjection_TRF <= '1';
					WAIT FOR 0 NS;
				ELSE
				--MEMORY LOCATION IS INTACT
					faulty_BIT := create_faulty_val(TRF_TEST_DATA, BIT_POS_TBF,Fault_Type_TBF);
					IF (TO_INTEGER(UNSIGNED(BIT_POS_TBF)) > 9) THEN strSize := 42; ELSE strSize := 41; END IF;
					wireName := (OTHERS => ' ');
					wireName(1 TO strSize) := "VirtualTester/FUT/TRF_MBIST/TRFData_IN("&TO_STRING(TO_INTEGER(UNSIGNED(BIT_POS_TBF)))&")";
					stuckAtVal := faulty_BIT;
					faultInjection_TRF <= '0';
					WAIT FOR 0 NS;
				END IF;
			END IF;

			IF (clk = '1') THEN
				IF(TRF_FAIL_SIGNAL = '1' and TRF_DETECTED_SIGNAL = '0') THEN
					--DETECTED FAULT REPORT:
					strSize := to_string(TRF_TEST_DATA)'LENGTH--delayed
								+to_string(NOW, ms)'LENGTH;
					str := (OTHERS => ' ');
					str(1 to strSize+28 ) :="Detected by TestVector = "
								&to_string(TRF_TEST_DATA)--delayed
								&" @ "&to_string(NOW, ms);
					WRITE(R_LINE, str);
					writeline(REPORT_FILE, R_LINE);
					TRF_DETECTED_SIGNAL <= '1';
					WAIT FOR 0 NS;
					numfault := numfault + 1;
					num_of_detected := num_of_detected + 1;
				END IF;
				IF (TRF_injected = '1') THEN
					TRF_DETECTED_SIGNAL <= '0';
					WAIT FOR 0 NS;
				END IF; 
			END IF;

			IF (TRF_injected = '1') THEN
				faulty_BIT := create_faulty_val(TRF_TEST_DATA, BIT_POS_TBF, Fault_Type_TBF);
				strSize := to_string(NOW, ms)'LENGTH + INTEGER'IMAGE(numfault)'LENGTH 
							+to_string(Address_TBF)'LENGTH 
							+ to_string(faulty_BIT)'LENGTH 
							+ INTEGER'IMAGE(to_integer(unsigned(BIT_POS_TBF)))'LENGTH ;
				str := (OTHERS => ' ');
				str(1 to strSize+58) :="faultNum "&INTEGER'IMAGE(numfault)
							&" = SA@"&to_string(faulty_BIT)
							&" on Address = "&to_string(Address_TBF)
							&", Bit Position = "&INTEGER'IMAGE(to_integer(unsigned(BIT_POS_TBF)))
							&" injected @ "&to_string(NOW, ms);
				WRITE(R_LINE, str);
				writeline(REPORT_FILE, R_LINE);
			END IF;

			IF (TRF_NEOF_SIGNAL = '0'  AND TRF_DETECTED_SIGNAL = '1' AND TRF_START_SIGNAL = '1') THEN
				---COVERAGE REPORT:
				strSize := INTEGER'IMAGE(num_of_detected)'LENGTH
							+INTEGER'IMAGE(numfault)'LENGTH
							+REAL'IMAGE(COV)'LENGTH;
				COV := (REAL(num_of_detected) / REAL(numfault)) * REAL(100);

				FOR I IN 0 TO 2 LOOP
					str := (OTHERS => ' ');
					str(1 to 67) :=  "*******************************************************************";
					WRITE(R_LINE, str);
					writeline(REPORT_FILE, R_LINE);
				END LOOP;

				str := (OTHERS => ' ');
				strSize := INTEGER'IMAGE(num_of_detected)'LENGTH;
				str(1 to strSize+15) := "numOfDetected: "&INTEGER'IMAGE(num_of_detected);
				WRITE(R_LINE, str);
				writeline(REPORT_FILE, R_LINE);

				str := (OTHERS => ' ');
				strSize := INTEGER'IMAGE(numfault)'LENGTH;
				str(1 to strSize+13) := "numOfFaults: "&INTEGER'IMAGE(numfault);
				WRITE(R_LINE , str);
				writeline(REPORT_FILE, R_LINE);

				str := (OTHERS => ' ');
				strSize := REAL'IMAGE(COV)'LENGTH;
				str(1 to strSize+13) := "Coverage = "&REAL'IMAGE(COV)&" %";
				WRITE(R_LINE, str);
				writeline(REPORT_FILE, R_LINE);

				EOF_TRF_TEST <= '1';
				WAIT UNTIL CLK='1';
				END IF;
			WAIT UNTIL CLK='1';
		END LOOP;
		WAIT;
	END PROCESS;
	
	--ROM TEST PROGRAM :
	TP_ROM : PROCESS
		FILE REPORT_FILE : text OPEN WRITE_MODE IS "Report_ROM.txt";
		VARIABLE R_LINE : LINE;
		VARIABLE str : string(1 TO 120);
		VARIABLE strSize : natural;
		VARIABLE I, N : INTEGER := 0;
		VARIABLE ROM_GOLDEN_SIGN_ARRAY : SIGNATURE_ARRAY;	
		VARIABLE ROM_SIGNATURE_OUTPUT_VAR : STD_LOGIC_VECTOR(15 DOWNTO 0);
		ALIAS ROM_MBIST_START_SIGNAL : STD_LOGIC IS << SIGNAL .VirtualTester.FUT.ROM_MBIST_START:STD_LOGIC>>;
		ALIAS ROM_EOP_OUT_SIGNAL : STD_LOGIC IS << SIGNAL .VirtualTester.FUT.ROM_MBIST.EOP:STD_LOGIC>>;
		ALIAS ROM_EOF_OUT_SIGNAL : STD_LOGIC IS << SIGNAL .VirtualTester.FUT.ROM_MBIST.EOF:STD_LOGIC>>;
		ALIAS ROM_MISR_RST : STD_LOGIC IS << SIGNAL .VirtualTester.FUT.ROM_MBIST.MISR_RST:STD_LOGIC>>;
	 BEGIN
		WAIT UNTIL ROM_MBIST_START_SIGNAL = '1';
		ROM_GOLDEN_SIGN_ARRAY := READ_GOLDEN_SIGNATURE;
		WHILE (TRUE) LOOP
			ROM_SIGNATURE_OUTPUT_VAR := << SIGNAL .VirtualTester.FUT.ROM_SIGNATURE_OUTPUT: STD_LOGIC_VECTOR(15 DOWNTO 0)>>;
			IF (ROM_EOP_OUT_SIGNAL = '1') THEN
				IF(ROM_GOLDEN_SIGN_ARRAY(I) /= ROM_SIGNATURE_OUTPUT_VAR AND ROM_MISR_RST /='1')  AND (I < romSeg-1) THEN
					N := N + 1;
					strSize := to_string(NOW, Ns)'LENGTH
								+ to_string(ROM_GOLDEN_SIGN_ARRAY(I))'LENGTH 
								+ to_string(ROM_SIGNATURE_OUTPUT_VAR)'LENGTH
								+ INTEGER'IMAGE(I)'LENGTH;
					str := (OTHERS => ' ');
					str(1 to strSize+73) :="ROM FAULT DETECTED IN SECTION "&INTEGER'IMAGE(I)
								&", GOLDEN SIGNATURE ="&to_string(ROM_GOLDEN_SIGN_ARRAY(I))
								&", FAULTY SIGNATURE ="&to_string(ROM_SIGNATURE_OUTPUT_VAR)
								&" @ "&to_string(NOW, Ns);
					WRITE(R_LINE, str);
					writeline(REPORT_FILE, R_LINE);
				END IF;
				IF (I < romSeg-1) THEN
					I := I+1;
				END IF;
				WAIT UNTIL CLK = '1';
			END IF;

			IF (ROM_EOF_OUT_SIGNAL = '1') THEN
				FOR I IN 0 TO 2 LOOP
					str := (OTHERS => ' ');
					str(1 to 67) := "*******************************************************************";
					WRITE(R_LINE, str);
					writeline(REPORT_FILE, R_LINE);
				END LOOP;

				strSize := INTEGER'IMAGE(N)'LENGTH;
				str := (OTHERS => ' ');
				str(1 to strSize+26) := INTEGER'IMAGE(N)&" FAULTY SEGMENTS DETECTED.";
				WRITE(R_LINE, str);
				writeline(REPORT_FILE, R_LINE);

				strSize := to_string(NOW, Ns)'length;
				str := (OTHERS => ' ');
				str(1 to strSize+20) :="ROM TEST FINISHED @ "&to_string(NOW, Ns);
				WRITE(R_LINE, str);
				writeline(REPORT_FILE, R_LINE);
				EOF_ROM_TEST <= '1';
				WAIT UNTIL CLK = '1';
			END IF;
			WAIT UNTIL CLK = '1';
		END LOOP;
		WAIT;
	END PROCESS;
END ARCHITECTURE test;