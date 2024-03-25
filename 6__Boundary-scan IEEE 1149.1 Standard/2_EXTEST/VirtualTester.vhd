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
USE IEEE.STD_LOGIC_unsigned.ALL;
USE IEEE.STD_LOGIC_arith.ALL;

ENTITY VirtualTester IS
END VirtualTester;

ARCHITECTURE str OF VirtualTester IS 
    CONSTANT instructionWidth : INTEGER := 3;
    CONSTANT inwidth_SAYAC : INTEGER := 17;
    CONSTANT outWidth_AccBUS : INTEGER := 17;
    CONSTANT interconnectWidth : INTEGER := 36;
	CONSTANT inwidth_AccBUS: INTEGER := 36;
    CONSTANT outWidth_SAYAC : INTEGER := 36;
	
	CONSTANT bypass_instruction : STD_LOGIC_VECTOR (2 DOWNTO 0) := "111";
    CONSTANT intest_instruction : STD_LOGIC_VECTOR (2 DOWNTO 0) := "011";
    CONSTANT sample_instruction : STD_LOGIC_VECTOR (2 DOWNTO 0) := "010";
    CONSTANT preload_instruction : STD_LOGIC_VECTOR (2 DOWNTO 0):= "001";
    CONSTANT extest_instruction : STD_LOGIC_VECTOR (2 DOWNTO 0) := "000";

    SIGNAL TCLK : STD_LOGIC := '1';
    SIGNAL TMS, TDI : STD_LOGIC;
    SIGNAL TDO : STD_LOGIC;
	SIGNAL sel_test : STD_LOGIC;
    SIGNAL Instruction : STD_LOGIC_VECTOR (2*instructionWidth-1 DOWNTO 0);
    COMPONENT BS_BoardLevel IS
        PORT(
	        TCLK, TMS, TDI : IN STD_LOGIC;
	        sel_test : IN STD_LOGIC;
	        TDO : OUT STD_LOGIC);
    END COMPONENT;
BEGIN
    CUT : BS_BoardLevel PORT MAP (TCLK, TMS, TDI, sel_test, TDO);
    PROCESS  BEGIN
        WAIT FOR 15 ns; TCLK <= '0';
        WAIT FOR 15 ns; TCLK <= '1';
    END PROCESS;
	sel_test <= '0';
    PROCESS
	    VARIABLE index : INTEGER;
	    FILE testFile, reportFile : TEXT; 
        VARIABLE fstatusR, fstatusW : FILE_OPEN_STATUS;
        VARIABLE spase : CHARACTER;
	    VARIABLE lbufR, lbufW : LINE;
	    VARIABLE TestData, Output: STD_LOGIC_VECTOR (interconnectWidth-1 DOWNTO 0);
	BEGIN
        FILE_OPEN (fstatusR, testFile, "testFile.txt", read_mode);
	    FILE_OPEN (fstatusW, reportFile, "reportFile.txt", write_mode);
		
	    FOR i IN 1 TO 5 LOOP                         -- 5 consecutive clocks for resetting
		    TMS <= '1';
		    WAIT UNTIL TCLK = '0'; 	     
        END LOOP;
		
		TMS <= '0'; WAIT UNTIL TCLK = '0';           -- run_test_idle
		TMS <= '1'; WAIT UNTIL TCLK = '0';           -- select_DR
		TMS <= '1'; WAIT UNTIL TCLK = '0';           -- select_IR
		TMS <= '0'; WAIT UNTIL TCLK = '0';           -- capture_IR
		TMS <= '0'; WAIT UNTIL TCLK = '0';           -- shift_IR
		
		Instruction <= (preload_instruction & bypass_instruction);
		
		FOR i IN 0 TO 2 * instructionWidth - 2 LOOP         
		    TDI	<= Instruction (i); 
		    TMS	<= '0';	WAIT UNTIL TCLK = '0';       -- shift_IR     
        END LOOP;
		TDI	<= Instruction (2 * instructionWidth - 1);
		
		TMS	<= '1';	WAIT UNTIL TCLK = '0';  		 -- exit_IR
		TMS <= '1';	WAIT UNTIL TCLK = '0';   		 -- update_IR
		TMS <= '1';	WAIT UNTIL TCLK = '0';  		 -- select_DR
		
		READLINE (testFile, lbufR);
        READ (lbufR, TestData);                                
		
		TMS <= '0'; WAIT UNTIL TCLK = '0';		     -- capture_DR
		TMS <= '0'; WAIT UNTIL TCLK = '0'; 		     -- shift_DR

		index := 0;
		FOR i IN 1 TO interconnectWidth LOOP         
		    TDI	<=  TestData (index);
		    TMS	<= '0';	WAIT UNTIL TCLK = '0';       -- shift_DR
		    index := index + 1;       
        END LOOP;
		
		index := 0;
		FOR i IN 1 TO inwidth_SAYAC-1 LOOP         
		    TDI	<= '0';
		    TMS	<= '0';	WAIT UNTIL TCLK = '0';	     -- shift_DR
		    index := index + 1;      
        END LOOP;
		TDI	<= '0';
		
		TMS	<= '1';	WAIT UNTIL TCLK = '0';		     -- exit_DR
		TMS <= '1';	WAIT UNTIL TCLK = '0';		     -- update_DR
		TMS <= '1';	WAIT UNTIL TCLK = '0';		     -- select_DR
		TMS <= '1';	WAIT UNTIL TCLK = '0';		     -- select_IR  
		TMS <= '0';	WAIT UNTIL TCLK = '0';		     -- capture_IR
		TMS <= '0';	WAIT UNTIL TCLK = '0';		     -- shift_IR
		
		Instruction <= (extest_instruction & extest_instruction);   
		
		FOR i IN 0 TO  2 * instructionWidth - 2 LOOP         
		    TDI	<= Instruction (i);
		    TMS	<= '0'; WAIT UNTIL TCLK = '0';	     -- shift_IR  
        END LOOP;
		TDI	<= Instruction (2 * instructionWidth - 1);
		
        TMS	<= '1';	WAIT UNTIL TCLK = '0';		     -- exit_IR
		TMS <= '1';	WAIT UNTIL TCLK = '0'; 		     -- update_IR
		TMS <= '1';	WAIT UNTIL TCLK = '0';		     -- select_DR
		
		WHILE NOT ENDFILE (testFile) LOOP
            READLINE (testFile, lbufR);
            READ (lbufR, TestData);
			
		    TMS <= '0';	WAIT UNTIL TCLK = '0';	     -- capture_DR
		    TMS <= '0'; WAIT UNTIL TCLK = '0';	     -- shift_DR
			
		    index := 0;	
            FOR i IN 1 TO  outWidth_AccBUS LOOP         
		        TDI <= '0';
			    TMS	<= '0';	WAIT UNTIL TCLK = '0';   -- shift_DR
			    index := index + 1;    
            END LOOP;
			
			index := 0;	
            FOR i IN 1 TO  interconnectWidth LOOP         
		        TDI <=  TestData (index);
		        TMS <= '0'; WAIT UNTIL TCLK = '0';   -- shift_DR
		        Output (index) := TDO;
		        index := index + 1;     
            END LOOP;
			
		    WRITE (lbufW, Output);
		    WRITELINE (reportFile, lbufW);
			
            index := 0;	
            FOR i IN 1 TO  inwidth_SAYAC - 1 LOOP         
		        TDI <= '0';
		        TMS <= '0'; WAIT UNTIL TCLK = '0';   -- shift_DR
		        index := index + 1;   
            END LOOP;
		    TDI	<=  '0';
			
		    TMS	<= '1'; WAIT UNTIL TCLK = '0'; 	     -- exit_DR
		    TMS <= '1';	WAIT UNTIL TCLK = '0'; 	     -- update_DR
		    TMS <= '1';	WAIT UNTIL TCLK = '0'; 	     -- select_DR
	    END LOOP; 
		FILE_CLOSE (testFile);                                                                              
		FILE_CLOSE (reportFile);
		
	    TMS <= '1';	WAIT UNTIL TCLK = '0'; 		     -- select_IR
		TMS <= '1';	WAIT UNTIL TCLK = '0'; 		     -- test_logic_reset
		WAIT;
	END PROCESS;	 
END str; 
  