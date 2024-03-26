--******************************************************************************
--	Filename:		VirtualTester.vhd
--	Project:		Security extension for IEEE Std 1149.1  
--  Version:		0.90
--	History:
--	Date:			17 Nov 2022
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

ENTITY VirtualTester IS
END VirtualTester;

ARCHITECTURE str OF VirtualTester IS 

    CONSTANT KLSWidth : INTEGER := 8; -- "Key/lock shift" Register Width
	CONSTANT LockCode : STD_LOGIC_VECTOR (KLSWidth-1 DOWNTO 0):= "10101011";
	CONSTANT KeyCode  : STD_LOGIC_VECTOR (KLSWidth-1 DOWNTO 0):= "10101011";	
    CONSTANT instructionWidth : INTEGER := 3;
    CONSTANT inwidth_SAYAC : INTEGER := 17;
    CONSTANT outWidth_AccBUS : INTEGER := 17;
    CONSTANT interconnectWidth : INTEGER := 36;
	CONSTANT inwidth_AccBUS: INTEGER := 36;
    CONSTANT outWidth_SAYAC : INTEGER := 36;
	
	CONSTANT bypass_instruction : STD_LOGIC_VECTOR (2 DOWNTO 0) := "111";
    CONSTANT intest_instruction : STD_LOGIC_VECTOR (2 DOWNTO 0) := "011";
    CONSTANT sample_instruction : STD_LOGIC_VECTOR (2 DOWNTO 0) := "010";
    CONSTANT preload_instruction : STD_LOGIC_VECTOR(2 DOWNTO 0) := "001";
    CONSTANT extest_instruction : STD_LOGIC_VECTOR (2 DOWNTO 0) := "000";
	CONSTANT lOCK_instruction 	: STD_LOGIC_VECTOR (2 DOWNTO 0) := "100";
	CONSTANT unlock_instruction : STD_LOGIC_VECTOR (2 DOWNTO 0) := "101";
	
	
	

    SIGNAL TCLK : STD_LOGIC := '1';
    SIGNAL TMS, TDI : STD_LOGIC;
    SIGNAL TDO : STD_LOGIC;
	--SIGNAL  : STD_LOGIC;
    SIGNAL Instruction : STD_LOGIC_VECTOR (instructionWidth-1 DOWNTO 0);
    COMPONENT BS_BoardLevel IS
        PORT(
	        TCLK, TMS, TDI : IN STD_LOGIC;
	        TDO : OUT STD_LOGIC);
    END COMPONENT;
BEGIN
    CUT : BS_BoardLevel PORT MAP (TCLK, TMS, TDI, TDO);
    PROCESS  BEGIN
        WAIT FOR 15 ns; TCLK <= '0';
        WAIT FOR 15 ns; TCLK <= '1';
    END PROCESS;
    PROCESS
	    VARIABLE index : INTEGER;
	    FILE testFile, reportFile : TEXT; 
        VARIABLE fstatusR, fstatusW : FILE_OPEN_STATUS;
        VARIABLE spase : CHARACTER;
	    VARIABLE lbufR, lbufW : LINE;
	    VARIABLE TestData, Output: STD_LOGIC_VECTOR (interconnectWidth-1 DOWNTO 0);
	BEGIN
        --FILE_OPEN (fstatusR, testFile, "testFile.txt", read_mode);
	    FILE_OPEN (fstatusW, reportFile, "reportFile.txt", write_mode);
		
--------------------
--Resetting 
		FOR i IN 1 TO 5 LOOP                         -- 5 consecutive clocks for resetting
		    TMS <= '1';			
		    WAIT UNTIL TCLK = '0'; 	     
        END LOOP;			
---------------------------------------------------------------------
--Set Instruction: lOCK_instruction
		Instruction <= lOCK_instruction;		
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
		WRITE (lbufW, string'("Instruction was set on lOCK_instruction."));
		WRITELINE (reportFile, lbufW);
--------------------------------------------------------------------------------
		-- Shifting Serial in/out to "Key/lock shift" Register		
		TMS <= '1'; WAIT UNTIL TCLK = '0';		     -- select_DR
		TMS <= '0'; WAIT UNTIL TCLK = '0';		     -- capture_DR
		TMS <= '0'; WAIT UNTIL TCLK = '0'; 		     -- shift_DR
		index := 0;			
		FOR i IN 1 TO KLSWidth LOOP 		    			
		    TMS	<= '0';	WAIT UNTIL TCLK = '0';       -- shift_DR
			TDI	<=  LockCode (index);			
			Output (index) := TDO;
		    index := index + 1;       
        END LOOP;
		-----------------------
		TDI	<= '0';
		
		TMS	<= '1';	WAIT UNTIL TCLK = '0';		     -- exit_DR
		TMS <= '1';	WAIT UNTIL TCLK = '0';		     -- update_DR
		TMS <= '0';	WAIT UNTIL TCLK = '0';		     -- run_test_idle
		---------------------------------------------------------
		WRITE (lbufW, Output);         --just for testing the code
		WRITE (lbufW, string'(","));   --just for testing the code
		WRITELINE (reportFile, lbufW); --just for testing the code		
		
		
		WRITE (lbufW, string'("Shifting Serial in/out to Key/lock shift Register is done."));
		WRITELINE (reportFile, lbufW);
		
		
---------------------------------------------------------------------
--Set Instruction: unlock_instruction
		Instruction <= unlock_instruction;		
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
		WRITE (lbufW, string'("Instruction was set on unlock_instruction."));
		WRITELINE (reportFile, lbufW);
--------------------------------------------------------------------------------		
		-- Shifting Serial in/out to "Key/lock shift" Register		
		TMS <= '1'; WAIT UNTIL TCLK = '0';		     -- select_DR
		TMS <= '0'; WAIT UNTIL TCLK = '0';		     -- capture_DR
		TMS <= '0'; WAIT UNTIL TCLK = '0'; 		     -- shift_DR
		index := 0;			
		FOR i IN 1 TO KLSWidth LOOP 		    			
		    TMS	<= '0';	WAIT UNTIL TCLK = '0';       -- shift_DR
			TDI	<=  KeyCode (index);			
			Output (index) := TDO;
		    index := index + 1;       
        END LOOP;
		-----------------------
		TDI	<= '0';
		
		TMS	<= '1';	WAIT UNTIL TCLK = '0';		     -- exit_DR
		TMS <= '1';	WAIT UNTIL TCLK = '0';		     -- update_DR
		TMS <= '0';	WAIT UNTIL TCLK = '0';		     -- run_test_idle
		---------------------------------------------------------
		WRITE (lbufW, Output);         --just for testing the code
		WRITE (lbufW, string'(","));   --just for testing the code
		WRITELINE (reportFile, lbufW); --just for testing the code		
		
		
		WRITE (lbufW, string'("Shifting Serial in/out to Key/lock shift Register is done."));
		WRITELINE (reportFile, lbufW);
		
		
---------------------------------------------------------------------		
		
		
		
		
		WAIT;
	END PROCESS;	 
END str; 
  