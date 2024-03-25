--******************************************************************************
--	Filename:		VirtualTester_ROM_MBIST.vhd
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
--	Test program for ROM MBIST, golden signatures are generated using 
--	the signature generator module and then the test promgram initiates the MBIST                              
--******************************************************************************
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.MATH_REAL.ALL; 

ENTITY VirtualTester_ROM_MBIST IS
END ENTITY VirtualTester_ROM_MBIST;

ARCHITECTURE test OF VirtualTester_ROM_MBIST IS
	CONSTANT clkPeriod   : time    := 10 Ns;
	CONSTANT romSeg		 : INTEGER := 6;
	SIGNAL clk : STD_LOGIC := '0';
	SIGNAL rst : STD_LOGIC := '0';
	SIGNAL stopSimulation : STD_LOGIC;
	--MBIST SIGNALS:
	SIGNAL EOF_ROM_TEST : STD_LOGIC;
	SIGNAL NbarT : STD_LOGIC;
	SIGNAL ROM_MBIST_START_SIGNAL : STD_LOGIC;
	SIGNAL READINST : STD_LOGIC;
	SIGNAL ROMADDR, ROMDATA : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL SIG_GEN_START : STD_LOGIC;
	SIGNAL MISR_GD_LD : STD_LOGIC;
	SIGNAL MISR_GD_RST : STD_LOGIC;
	SIGNAL GOLDEN_OUTPUT, ROM_SIGNATURE_OUTPUT : STD_LOGIC_VECTOR(15 DOWNTO 0);

	TYPE SIGNATURE_ARRAY IS ARRAY (0 TO romSeg-1) OF STD_LOGIC_VECTOR (15 DOWNTO 0);

	--READ GOLDEN SIGNATURE FILE FUNCTION
	IMPURE FUNCTION READ_GOLDEN_SIGNATURE RETURN SIGNATURE_ARRAY is
		FILE SIGNATURE_FILE : TEXT OPEN read_mode IS "GOLDEN_SIGNATURE.txt";
		VARIABLE SIGNFileLine : LINE;
		VARIABLE GOOD : BOOLEAN;
		VARIABLE fstatus: FILE_OPEN_STATUS;
		VARIABLE SIGNATURE : SIGNATURE_ARRAY;
		BEGIN
			FOR I IN 0 TO romSeg - 1 LOOP
				IF NOT ENDFILE(SIGNATURE_FILE) THEN
					READLINE(SIGNATURE_FILE, SIGNFileLine);
					READ(SIGNFileLine, SIGNATURE(I), GOOD);
					--REPORT "Status from FILE: '" & BOOLEAN'IMAGE(GOOD) & "'";
				END IF;
			END LOOP;
			FILE_close(SIGNATURE_FILE);
			RETURN SIGNATURE;
	END FUNCTION READ_GOLDEN_SIGNATURE;
BEGIN
	
	SIGNATURE_GENERATOR : ENTITY WORK.SIGNATURE_TOP(SIGNATURE_TOP_Arc) PORT MAP
			(CLK => CLK, RST => RST, START => SIG_GEN_START, MISR_GD_LD => MISR_GD_LD,
			MISR_GD_RST => MISR_GD_RST, SIGNATURE => GOLDEN_OUTPUT);

	ROM_MBIST : ENTITY WORK.ROM_MBIST_TOP(ROM_MBIST_TOP_Arc) GENERIC MAP (300) PORT MAP 
			(clk => CLK, rst => RST , start => ROM_MBIST_START_SIGNAL,
			READINST => READINST, ROMAddr => ROMADDR, ROMDATA => ROMDATA, SIGNATURE => ROM_SIGNATURE_OUTPUT);

	InstructionROM : ENTITY WORK.inst_ROM GENERIC MAP (300)
			PORT MAP (clk, rst, READINST, ROMADDR, ROMDATA ,NbarT);

	clk <= NOT clk AFTER clkPeriod/2;
	RST <= '1','0'AFTER  clkPeriod;
	STRAT_MEMORY_TEST : PROCESS
		FILE ROM_REPORT_FILE : text OPEN WRITE_MODE IS "Report_ROM.txt";
		VARIABLE R_LINE : LINE;
		VARIABLE str : string(1 TO 120);
		VARIABLE strSize : natural;
		ALIAS SIG_GEN_IS_DONE : STD_LOGIC IS << SIGNAL .VirtualTester_ROM_MBIST.SIGNATURE_GENERATOR.EOF:STD_LOGIC>>;
	BEGIN
		WRITE (R_LINE, string'("===================================> @ "));
		WRITE (R_LINE, NOW);
		WRITE (R_LINE, string'("   NORMAL MODE is starting ... "));
		WRITELINE (ROM_REPORT_FILE, R_LINE);

		NbarT <= '0'; 
		rst <= '1', '0' AFTER 2 NS;
		SIG_GEN_START<='1';
		WAIT FOR 0 NS;
		WAIT UNTIL SIG_GEN_IS_DONE = '1';
		SIG_GEN_START<='0';
		WAIT FOR 0 NS;
		WAIT FOR 5000 ns;
		NbarT <= '1';
		WAIT UNTIL clk = '1';
		ROM_MBIST_START_SIGNAL <= '1';
		WAIT FOR 0 NS;
		strSize := to_string(NOW , Ns)'length;
		str :=  (OTHERS => ' ');
		str(1 TO 73 + strSize) := "===================================> @ "&to_string(NOW, Ns)&"   ROM MBIST MODE is starting ... ";
		WRITE(R_LINE, str);
		writeline(ROM_REPORT_FILE, R_LINE);
		WAIT UNTIL EOF_ROM_TEST = '1';
		ROM_MBIST_START_SIGNAL <= '0';
		NbarT <= '0';
		WAIT FOR 0 NS;
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
		VARIABLE ROM_SIGNATURE_OUTPUT_VAR : STD_LOGIC_VECTOR( 15 DOWNTO 0);
		ALIAS ROM_EOP_OUT_SIGNAL : STD_LOGIC IS << SIGNAL .VirtualTester_ROM_MBIST.ROM_MBIST.EOP:STD_LOGIC>>;
		ALIAS ROM_EOF_OUT_SIGNAL : STD_LOGIC IS << SIGNAL .VirtualTester_ROM_MBIST.ROM_MBIST.EOF:STD_LOGIC>>;
		ALIAS ROM_MISR_RST : STD_LOGIC IS << SIGNAL .VirtualTester_ROM_MBIST.ROM_MBIST.MISR_RST:STD_LOGIC>>;
		ALIAS SIG_GEN_IS_DONE : STD_LOGIC IS << SIGNAL .VirtualTester_ROM_MBIST.SIGNATURE_GENERATOR.EOF:STD_LOGIC>>;
	BEGIN		
	 	WAIT UNTIL SIG_GEN_IS_DONE = '1';
		ROM_GOLDEN_SIGN_ARRAY := READ_GOLDEN_SIGNATURE;
		WAIT UNTIL ROM_MBIST_START_SIGNAL = '1';
		WHILE (TRUE) LOOP
			ROM_GOLDEN_SIGN_ARRAY := READ_GOLDEN_SIGNATURE;
			ROM_SIGNATURE_OUTPUT_VAR := ROM_SIGNATURE_OUTPUT;
			IF ( ROM_EOP_OUT_SIGNAL = '1') THEN
				IF(ROM_GOLDEN_SIGN_ARRAY(I) /= ROM_SIGNATURE_OUTPUT_VAR AND ROM_MISR_RST /= '1')  AND (I < romSeg) THEN
					N := N + 1;
					strSize := to_string(NOW, Ns)'length
								+ to_string(ROM_GOLDEN_SIGN_ARRAY(I))'LENGTH 
								+ to_string(ROM_SIGNATURE_OUTPUT_VAR)'LENGTH
								+ INTEGER'IMAGE(I)'LENGTH;
					str := (OTHERS=>' ');
					str(1 to strSize + 73) :="ROM FAULT DETECTED IN SECTION "&INTEGER'IMAGE(I)
								&", GOLDEN SIGNATURE ="&to_string(ROM_GOLDEN_SIGN_ARRAY(I))
								&", FAULTY SIGNATURE ="&to_string(ROM_SIGNATURE_OUTPUT_VAR)
								&" @ "&to_string(NOW, Ns);
					WRITE(R_LINE, str);
					writeline(REPORT_FILE, R_LINE);
				END IF;
				IF (I < romSeg-1) THEN
					I := I + 1;
				END IF;
				WAIT UNTIL CLK = '1';
			END IF;

			IF (ROM_EOF_OUT_SIGNAL = '1') THEN
				FOR I IN 0 TO 2 LOOP
					str := (OTHERS => ' ');
					str(1 to 67) :=  "*******************************************************************";
					WRITE(R_LINE, str);
					writeline(REPORT_FILE, R_LINE);
				END LOOP;

				strSize := INTEGER'IMAGE(N)'LENGTH;
				str := (OTHERS => ' ');
				str(1 to strSize + 26) := INTEGER'IMAGE(N)&" FAULTY SEGMENTS DETECTED.";
				WRITE(R_LINE, str);
				writeline(REPORT_FILE, R_LINE);

				strSize := to_string(NOW, Ns)'length;
				str := (OTHERS => ' ');
				str(1 to strSize + 20) :="ROM TEST FINISHED @ "&to_string(NOW, Ns);
				WRITE(R_LINE, str);
				writeline(REPORT_FILE, R_LINE);
				EOF_ROM_TEST <= '1';
				stopSimulation <= '1';
				WAIT UNTIL CLK = '1';
			END IF;
			WAIT UNTIL CLK = '1';
		END LOOP;
		WAIT;
	END PROCESS;
END ARCHITECTURE test;