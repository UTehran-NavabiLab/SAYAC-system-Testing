--******************************************************************************
--	Filename:		VirtualTester_RAM_MBIST.vhd
--	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
--  Version:		0.990
--	History:
--	Date:			28 July 2022
--	Last Author: 	DELARAM
--  Copyright (C) 2022 University of Teheran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--

--******************************************************************************
--	File content description:
--	Test program for RAM MBIST                             
--******************************************************************************
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.MATH_REAL.ALL; 

ENTITY VirtualTester_RAM_MBIST IS
END ENTITY VirtualTester_RAM_MBIST;

ARCHITECTURE test OF VirtualTester_RAM_MBIST IS

	CONSTANT clkPeriod   : time    := 10 Ns;

	SIGNAL clk : STD_LOGIC := '0';
	SIGNAL rst : STD_LOGIC := '0';
	SIGNAL stopSimulation : STD_LOGIC := '0';
	SIGNAL READMEM, READYMEM : STD_LOGIC;
	--MBIST SIGNALS:
	SIGNAL EOF_RAM_TEST : STD_LOGIC;
	SIGNAL faultInjection_RAM : STD_LOGIC;
	SIGNAL RAM_START_SIGNAL : STD_LOGIC;
	SIGNAL RAM_DETECTED_SIGNAL : STD_LOGIC;
	SIGNAL RAM_WM_SIGNAL : STD_LOGIC;
	SIGNAL RAM_ADDR: STD_LOGIC_VECTOR (15 DOWNTO 0);
	SIGNAL RAM_TEST_ADDR : STD_LOGIC_VECTOR (15 DOWNTO 0);
	SIGNAL WRITEDATA : STD_LOGIC_VECTOR (15 DOWNTO 0);
	SIGNAL READDATA : STD_LOGIC_VECTOR (15 DOWNTO 0);

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
BEGIN	

	MEMORY : ENTITY WORK.MEM PORT MAP 
			 (clk, rst, READMEM, RAM_WM_SIGNAL, RAM_ADDR, 
			 writeData, readData, readyMEM);

	RAM_MBIST : ENTITY WORK.RAM_MBIST_TOP(RAM_MBIST_TOP_Arc) PORT MAP 
			 (clk=>clk, rst=>rst, start=>RAM_START_SIGNAL, 
			 write_to_Mem=>RAM_WM_SIGNAL, Read_to_Mem=>READMEM, memAddr=>RAM_ADDR,
			 memDataWrite=>writeData, memDataRead=>readData,
			 DETECTED=>RAM_DETECTED_SIGNAL);

	clk <= NOT clk AFTER clkPeriod/2;
	STRAT_MEMORY_TEST : PROCESS 
		FILE RAM_REPORT_FILE : text OPEN write_mode IS "Report_RAM.txt";
		VARIABLE R_LINE : LINE;
		VARIABLE str : string(1 TO 120);
		VARIABLE strSize : natural;
	BEGIN
		WRITE (R_LINE, string'("===================================> @ "));
		WRITE (R_LINE, NOW);
		WRITE (R_LINE, string'("   NORMAL MODE is starting ... "));
		WRITELINE (RAM_REPORT_FILE, R_LINE);
		rst <= '1', '0' AFTER 2 NS;
		WAIT FOR 6000 ns;
		RAM_START_SIGNAL <= '1';
		WAIT FOR 0 NS;
		strSize := to_string(NOW, MS)'LENGTH;
		str := (OTHERS => ' ');
		str(1 TO 72 + strSize) := "===================================> @ "&to_string(NOW , MS)&"  RAM MBIST MODE is starting ... ";
		WRITE(R_LINE, str);
		writeline(RAM_REPORT_FILE, R_LINE);
		WAIT UNTIL EOF_RAM_TEST = '1';
		RAM_START_SIGNAL <= '0';
		WAIT FOR 0 NS;
		WAIT;
	END PROCESS;

	--RAM TEST PROGRAM : 
	TP_RAM : PROCESS
		VARIABLE ADDRESS_TBF :  STD_LOGIC_VECTOR(15 DOWNTO 0);
		VARIABLE BIT_POS_TBF :  STD_LOGIC_VECTOR(3 DOWNTO 0);
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
		VARIABLE num_of_detected : INTEGER := 0;
		VARIABLE numfault : INTEGER := 0;
		VARIABLE COV : REAL:= 0.0;
		VARIABLE RAM_NEOF_SIGNAL : STD_LOGIC;
		ALIAS RAM_end_of_TV_test_SIGNAL : STD_LOGIC IS << SIGNAL .VirtualTester_RAM_MBIST.RAM_MBIST.CONTROLLER.end_of_TV_test:STD_LOGIC>>; 
		ALIAS RAM_FAIL_SIGNAL : STD_LOGIC IS << SIGNAL .VirtualTester_RAM_MBIST.RAM_MBIST.DATAPATH.FAIL:STD_LOGIC>>; 
		ALIAS RAM_TEST_DATA : STD_LOGIC_VECTOR(15 DOWNTO 0) IS << SIGNAL .VirtualTester_RAM_MBIST.RAM_MBIST.DATAPATH.test_data:STD_LOGIC_VECTOR(15 DOWNTO 0)>>; 	

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
				IF (ADDRESS_TBF = RAM_ADDR) THEN match := true; ELSE match := false; END IF;
				IF (match) THEN
				-- INJECT FAULT
					faulty_BIT := create_faulty_val(RAM_TEST_DATA, BIT_POS_TBF, Fault_Type_TBF);
					IF (TO_INTEGER(UNSIGNED(BIT_POS_TBF)) > 9) THEN strSize := 13; ELSE strSize := 12; END IF;
					wireName := (OTHERS => ' ');
					wireName(1 TO strSize) := "writeData("&TO_STRING(TO_INTEGER(UNSIGNED(BIT_POS_TBF)))&")";
					stuckAtVal := faulty_BIT;
					faultInjection_RAM <= '1';
					WAIT FOR 0 NS;
				ELSE
				--MEMORY LOCATION IS INTACT
					faulty_BIT := create_faulty_val(RAM_TEST_DATA, BIT_POS_TBF,Fault_Type_TBF);
					IF (TO_INTEGER(UNSIGNED(BIT_POS_TBF)) > 9) THEN strSize := 13; ELSE strSize := 12; END IF;
					wireName := (OTHERS => ' ');
					wireName(1 TO strSize) := "writeData("&TO_STRING(TO_INTEGER(UNSIGNED(BIT_POS_TBF)))&")";
					stuckAtVal := faulty_BIT;
					faultInjection_RAM <= '0';
					WAIT FOR 0 NS;
				END IF;
			END IF;

			IF (clk = '1') THEN
				IF(RAM_FAIL_SIGNAL = '1' AND RAM_DETECTED_SIGNAL = '0') THEN
					strSize := to_string(RAM_TEST_DATA)'LENGTH
								+to_string(NOW, ms)'LENGTH;
					str := (OTHERS => ' ');
					str(1 to strSize + 28) :="Detected by TestVector = "
								&to_string(RAM_TEST_DATA)
								&" @ "&to_string(NOW, ms);
					WRITE(R_LINE, str);
					writeline(REPORT_FILE, R_LINE);
					RAM_DETECTED_SIGNAL <= '1';
					WAIT FOR 0 NS;
					numfault := numfault + 1;
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
							+ to_string(Address_TBF)'LENGTH 
							+ to_string(faulty_BIT)'LENGTH 
							+ INTEGER'IMAGE(to_integer(unsigned(BIT_POS_TBF)))'LENGTH ;
				str := (OTHERS => ' ');
				str(1 to strSize + 58) := "faultNum "&INTEGER'IMAGE(numfault)
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
				str(1 to strSize + 15) := "numOfDetected: "&INTEGER'IMAGE(num_of_detected);
				WRITE(R_LINE, str);
				writeline(REPORT_FILE, R_LINE);

				str := (OTHERS => ' ');
				strSize := INTEGER'IMAGE(numfault)'LENGTH;
				str(1 to strSize + 13) := "numOfFaults: "&INTEGER'IMAGE(numfault);
				WRITE(R_LINE, str);
				writeline(REPORT_FILE, R_LINE);

				str := (OTHERS => ' ');
				strSize := REAL'IMAGE(COV)'LENGTH;
				str(1 to strSize + 13) := "Coverage = "&REAL'IMAGE(COV)&" %";
				WRITE(R_LINE, str);
				writeline(REPORT_FILE, R_LINE);

				EOF_RAM_TEST <= '1';
				stopSimulation <= '1';
				WAIT UNTIL clk='1';
				END IF;
			WAIT UNTIL clk='1';
		END LOOP;
		WAIT;
	END PROCESS;
END ARCHITECTURE test;