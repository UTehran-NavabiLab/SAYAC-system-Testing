--******************************************************************************
--	Filename:		VirtualTester.vhd
--	Project:		Memory of SAYAC Testing through 1149.1 standard
--  Version:		0.10
--	History:
--	Date:			11 Nov 2022
--	Last Author: 	Shahab Karbasian
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
USE IEEE.STD_LOGIC_unsigned.ALL;
USE IEEE.STD_LOGIC_arith.ALL;
USE IEEE.numeric_std.ALL;

ENTITY VirtualTester IS
END VirtualTester;

ARCHITECTURE str OF VirtualTester IS 
	CONSTANT MaxRow : INTEGER := 5; -- Set MaxRow=65536 for test total memory
	CONSTANT Data1: STD_LOGIC_VECTOR (15 DOWNTO 0) := x"0000"; --Set first Data to write/read to/from memory.
	CONSTANT Data2: STD_LOGIC_VECTOR (15 DOWNTO 0) := x"FFFF"; --Set second Data to write/read to/from memory.	
    CONSTANT instructionWidth : INTEGER := 3;
    CONSTANT inwidth_SAYAC : INTEGER := 17;
    CONSTANT interconnectWidth : INTEGER := 36;
	CONSTANT clkPeriod : time    := 10 ns;
	
	CONSTANT bypass_instruction : STD_LOGIC_VECTOR (2 DOWNTO 0) := "111";
    CONSTANT intest_instruction : STD_LOGIC_VECTOR (2 DOWNTO 0) := "011";
    CONSTANT sample_instruction : STD_LOGIC_VECTOR (2 DOWNTO 0) := "010";
    CONSTANT preload_instruction: STD_LOGIC_VECTOR (2 DOWNTO 0) := "001";
    CONSTANT extest_instruction : STD_LOGIC_VECTOR (2 DOWNTO 0) := "000";
	SIGNAL   ClkCUT : STD_LOGIC := '1';
	SIGNAL   RstCUT : STD_LOGIC := '0';
    SIGNAL   TCLK 	: STD_LOGIC := '1';
    SIGNAL   TMS 	: STD_LOGIC;
	SIGNAL   TDI 	: STD_LOGIC:= '0';
    SIGNAL   TDO 	: STD_LOGIC;	
    SIGNAL   Instruction : STD_LOGIC_VECTOR (instructionWidth-1 DOWNTO 0);
    COMPONENT BS_BoardLevel IS
        PORT(
	        ClkCUT, RstCUT,TCLK, TMS, TDI : IN STD_LOGIC;	        
	        TDO : OUT STD_LOGIC);
    END COMPONENT;
BEGIN
    CUT : BS_BoardLevel PORT MAP (ClkCUT, RstCUT, TCLK, TMS, TDI, TDO);
	TCLK <= NOT TCLK AFTER clkPeriod;
	ClkCUT <= TCLK;
	RstCUT <= '0','1' after 5 ns,'0' after 10 ns;
		
    PROCESS
	    VARIABLE index : INTEGER;
	    FILE reportFile : TEXT; 
        VARIABLE fstatusW : FILE_OPEN_STATUS;
	    VARIABLE lbufW : LINE;
	    VARIABLE TestData: STD_LOGIC_VECTOR (interconnectWidth-1 DOWNTO 0);
	    VARIABLE Output: STD_LOGIC_VECTOR (interconnectWidth+inwidth_SAYAC-1 DOWNTO 0);
		VARIABLE readyMem : STD_LOGIC;
		
	BEGIN
	    FILE_OPEN (fstatusW, reportFile, "reportFile.txt", write_mode);
--------------------
--Resetting 
		FOR i IN 1 TO 5 LOOP                         -- 5 consecutive clocks for resetting
		    TMS <= '1';			
		    WAIT UNTIL TCLK = '0'; 	     
        END LOOP;			
---------------------------------------------------------------------
--Set Instruction: extest_instruction
		Instruction <= extest_instruction;		
		TMS <= '0'; WAIT UNTIL TCLK = '0';           -- run_test_idle
		TMS <= '1'; WAIT UNTIL TCLK = '0';           -- select_DR
		TMS <= '1'; WAIT UNTIL TCLK = '0';           -- select_IR
		TMS <= '0'; WAIT UNTIL TCLK = '0';           -- capture_IR
		TMS <= '0'; WAIT UNTIL TCLK = '0';           -- shift_IR
		
		FOR i IN 0 TO  instructionWidth - 2 LOOP         
		    TDI	<= Instruction (i); 
		    TMS	<= '0';	WAIT UNTIL TCLK = '0';       -- shift_IR     
        END LOOP;
		TDI	<= Instruction ( instructionWidth - 1);
		
		TMS	<= '1';	WAIT UNTIL TCLK = '0';  		 -- exit_IR
		TMS <= '1';	WAIT UNTIL TCLK = '0';   		 -- update_IR
		TMS <= '0';	WAIT UNTIL TCLK = '0';  		 -- run_test_idle
		--------------------------------------------------------------------------------
		WRITE (lbufW, string'("Instruction was set on extest_instruction."));
		WRITELINE (reportFile, lbufW);
--------------------------------------------------------------------------------
-- Writing Zeros to memory:
--      Assinging "Data", "Address" and "write" Signals" for writing Zeros in Memory
		FOR j IN 0 TO MaxRow  LOOP  --65536
		TestData (15 DOWNTO 0) := Data1; -- zeros 
		TestData (31 DOWNTO 16) := std_logic_vector( to_unsigned(j,16)); --Convert j to 16bit std-logic
		TestData (32) :='0' ; --ReadMem=0
		TestData (33) :='1' ; --WriteMem=1 
		TestData (35 DOWNTO 34) :="00"; --Not used in this test
		--------------------------
		--Checking "ReadyMem"
		readyMem:='0';
		while (readyMem = '0')loop
		---------------------------
		-- Shifting Serial in/out
		-- Part1
		TMS <= '1'; WAIT UNTIL TCLK = '0';		     -- select_DR
		TMS <= '0'; WAIT UNTIL TCLK = '0';		     -- capture_DR
		TMS <= '0'; WAIT UNTIL TCLK = '0'; 		     -- shift_DR
		index := 0;			
		FOR i IN 1 TO interconnectWidth LOOP 		    			
		    TMS	<= '0';	WAIT UNTIL TCLK = '0';       -- shift_DR
			TDI	<=  TestData (index);			
			Output (index) := TDO;
		    index := index + 1;       
        END LOOP;
		-----------------------
		-- Part2
		index := 0;
		FOR i IN 1 TO inwidth_SAYAC LOOP
		    TMS	<= '0';	WAIT UNTIL TCLK = '0';	     -- shift_DR
			TDI	<= '0';
			Output (index+interconnectWidth) := TDO;
		    index := index + 1;      
        END LOOP;
		TDI	<= '0';
		
		TMS	<= '1';	WAIT UNTIL TCLK = '0';		     -- exit_DR
		TMS <= '1';	WAIT UNTIL TCLK = '0';		     -- update_DR
		TMS <= '0';	WAIT UNTIL TCLK = '0';		     -- run_test_idle
		---------------------------------------------------------
		--Getting "ReadyMem"
		readyMem := Output (interconnectWidth+inwidth_SAYAC-1);
		end loop; -- End While loop
		---------------------------------------------------------		
		--WRITE (lbufW, Output);         --just for testing the code
		--WRITE (lbufW, string'(","));   --just for testing the code
		--WRITELINE (reportFile, lbufW); --just for testing the code		
        END LOOP;	--End FOR-j	
		-----------------------------------------
		WRITE (lbufW, string'("Zeros were written on memory."));
		WRITELINE (reportFile, lbufW);
		WRITE (lbufW, string'("Reading Zeros:"));
		WRITELINE (reportFile, lbufW);
--------------------------------------------------------------------------------
-- Reading Zeros from memory:		
		-- Assinging "Data", "Address" and "write" Signals for reading Zeros in Memory
		FOR j IN 0 TO 5  LOOP  --65536
		TestData (15 DOWNTO 0) := Data1; -- it will be don't care
		TestData (31 DOWNTO 16) := std_logic_vector( to_unsigned(j,16)); --Convert j to 16bit std-logic
		TestData (32) :='1' ; --ReadMem=1
		TestData (33) :='0' ; --WriteMem=0 
		TestData (35 DOWNTO 34) :="00"; --Not used in this test
		--------------------------
		--Checking "ReadyMem"
		readyMem:='0';
		while (readyMem = '0')loop
		---------------------------
		-- Shifting Serial in/out
		-- Part1
		TMS <= '1'; WAIT UNTIL TCLK = '0';		     -- select_DR
		TMS <= '0'; WAIT UNTIL TCLK = '0';		     -- capture_DR
		TMS <= '0'; WAIT UNTIL TCLK = '0'; 		     -- shift_DR
		index := 0;			
		FOR i IN 1 TO interconnectWidth LOOP 		    			
		    TMS	<= '0';	WAIT UNTIL TCLK = '0';       -- shift_DR
			TDI	<=  TestData (index);			
			Output (index) := TDO;
		    index := index + 1;       
        END LOOP;
		-----------------------
		-- Part2
		index := 0;
		FOR i IN 1 TO inwidth_SAYAC LOOP
		    TMS	<= '0';	WAIT UNTIL TCLK = '0';	     -- shift_DR
			TDI	<= '0';
			Output (index+interconnectWidth) := TDO;
		    index := index + 1;      
        END LOOP;
		TDI	<= '0';
		
		TMS	<= '1';	WAIT UNTIL TCLK = '0';		     -- exit_DR
		TMS <= '1';	WAIT UNTIL TCLK = '0';		     -- update_DR
		TMS <= '0';	WAIT UNTIL TCLK = '0';		     -- run_test_idle
		---------------------------------------------------------
		--Getting "ReadyMem"
		readyMem := Output (interconnectWidth+inwidth_SAYAC-1);
		end loop; --End while
		------------------------		
		WRITE (lbufW, Output(interconnectWidth+inwidth_SAYAC-2 downto interconnectWidth));
		WRITELINE (reportFile, lbufW);
		------------------------
		if (Output(interconnectWidth+inwidth_SAYAC-2 downto interconnectWidth) /= Data1) then
		WRITE (lbufW, string'("Fault is detected in address:  "));
		WRITE (lbufW, j );
		WRITELINE (reportFile, lbufW);		
		end if;
		---------------------------
        END LOOP;	--End FOR-j	
		-----------------------------------------------------------
		WRITE (lbufW, string'("All Zeros were read."));
		WRITELINE (reportFile, lbufW);
--------------------------------------------------------------------		
-- Writing Ones in memory:
--      Assinging "Data", "Address" and "write" Signals" for writing Ones in Memory
		FOR j IN 0 TO 5  LOOP  --65536
		TestData (15 DOWNTO 0) := Data2; --Ones
		TestData (31 DOWNTO 16) := std_logic_vector( to_unsigned(j,16)); --Convert 1 to 16bit std-logic
		TestData (32) :='0' ; --ReadMem=0
		TestData (33) :='1' ; --WriteMem=1
		TestData (35 DOWNTO 34) :="00"; --Not used in this test
		--------------------------
		--Checking "ReadyMem"
		readyMem:='0';
		while (readyMem = '0')loop
		---------------------------
		-- Shifting Serial
		-- Part1
		TMS <= '1'; WAIT UNTIL TCLK = '0';		     -- select_DR
		TMS <= '0'; WAIT UNTIL TCLK = '0';		     -- capture_DR
		TMS <= '0'; WAIT UNTIL TCLK = '0'; 		     -- shift_DR
		index := 0;			
		FOR i IN 1 TO interconnectWidth LOOP 		    			
		    TMS	<= '0';	WAIT UNTIL TCLK = '0';       -- shift_DR
			TDI	<=  TestData (index);			
			Output (index) := TDO;
		    index := index + 1;       
        END LOOP;
		-----------------------
		-- Part2
		index := 0;
		FOR i IN 1 TO inwidth_SAYAC LOOP
		    TMS	<= '0';	WAIT UNTIL TCLK = '0';	     -- shift_DR
			TDI	<= '0';
			Output (index+interconnectWidth) := TDO;
		    index := index + 1;      
        END LOOP;
		TDI	<= '0';
		
		TMS	<= '1';	WAIT UNTIL TCLK = '0';		     -- exit_DR
		TMS <= '1';	WAIT UNTIL TCLK = '0';		     -- update_DR
		TMS <= '0';	WAIT UNTIL TCLK = '0';		     -- run_test_idle
		---------------------------------------------------------
		--Getting "ReadyMem"
		readyMem := Output (interconnectWidth+inwidth_SAYAC-1);
		end loop; --for while
		----------------------------		
		--WRITE (lbufW, Output);			--just for testing the code
		--WRITELINE (reportFile, lbufW); 	--just for testing the code	
        END LOOP;	--End FOR-j			
		----------------------------------------
		WRITE (lbufW, string'("Ones were written on memory."));
		WRITELINE (reportFile, lbufW);
		WRITE (lbufW, string'("Reading Ones:"));
		WRITELINE (reportFile, lbufW);
--------------------------------------------------------------------------------
-- Reading Ones from memory:		
		-- Assinging "Data", "Address" and "write" Signals for reading Ones in Memory
		FOR j IN 0 TO 5  LOOP  --65536
		TestData (15 DOWNTO 0) := Data2; -- It will be "don't care" 
		TestData (31 DOWNTO 16) := std_logic_vector( to_unsigned(j,16)); --Convert 1 to 16bit std-logic
		TestData (32) :='1' ; --ReadMem=1
		TestData (33) :='0' ; --WriteMem=0 
		TestData (35 DOWNTO 34) :="00"; --Not used in this test
		--------------------------
		--Checking "ReadyMem"
		readyMem:='0';
		while (readyMem = '0')loop
		---------------------------
		-- Shifting Serial in/out
		-- Part1
		TMS <= '1'; WAIT UNTIL TCLK = '0';		     -- select_DR
		TMS <= '0'; WAIT UNTIL TCLK = '0';		     -- capture_DR
		TMS <= '0'; WAIT UNTIL TCLK = '0'; 		     -- shift_DR
		index := 0;			
		FOR i IN 1 TO interconnectWidth LOOP 		    			
		    TMS	<= '0';	WAIT UNTIL TCLK = '0';       -- shift_DR
			TDI	<=  TestData (index);			
			Output (index) := TDO;
		    index := index + 1;       
        END LOOP;
		-----------------------
		-- Part2
		index := 0;
		FOR i IN 1 TO inwidth_SAYAC LOOP
		    TMS	<= '0';	WAIT UNTIL TCLK = '0';	     -- shift_DR
			TDI	<= '0';
			Output (index+interconnectWidth) := TDO;
		    index := index + 1;      
        END LOOP;
		TDI	<= '0';
		
		TMS	<= '1';	WAIT UNTIL TCLK = '0';		     -- exit_DR
		TMS <= '1';	WAIT UNTIL TCLK = '0';		     -- update_DR
		TMS <= '0';	WAIT UNTIL TCLK = '0';		     -- run_test_idle
		---------------------------------------------------------
		--Getting "ReadyMem"
		readyMem := Output(interconnectWidth+inwidth_SAYAC-1);
		end loop; --End while
		----------------------		
		WRITE (lbufW, Output(interconnectWidth+inwidth_SAYAC-2 downto interconnectWidth));
		WRITELINE (reportFile, lbufW);
		------------------------
		if (Output(interconnectWidth+inwidth_SAYAC-2 downto interconnectWidth) /= Data2) then
		WRITE (lbufW, string'("Fault is detected in address:  "));
		WRITE (lbufW, j );
		WRITELINE (reportFile, lbufW);		
		end if;
		---------------------------
        END LOOP;	--End FOR-j		
		-----------------------------------------------------------	
		WRITE (lbufW, string'("All Ones were read."));
		WRITELINE (reportFile, lbufW);	
		
		WAIT;		
	END PROCESS;	 
END str; 





  