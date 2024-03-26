--******************************************************************************
--	Filename:		TAPController.vhd
--	Project:		JTAG BC_1 Testing 
--  Version:		2.0
--	History:
--	Date:			27 Nov 2022
--	Last Author: 	Shahab Karbasian
--  Copyright (C) 2022 University of Tehran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--
--******************************************************************************
--	File content description:
--	IEEE Std 1149.1 TAP Controller                              
--******************************************************************************

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
use ieee.std_logic_1164.STD_LOGIC;
USE IEEE.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

ENTITY TAPController IS
	PORT(
		TMS : 	 IN STD_LOGIC;
		TCLK :   IN STD_LOGIC;
		RstBar : OUT STD_LOGIC;
		sel : 	 OUT STD_LOGIC;
		Enable : OUT STD_LOGIC;
		ShiftIR, UpdateIR, ClockIR : OUT STD_LOGIC;
		ShiftDR, UpdateDR, ClockDR : OUT STD_LOGIC);
END TAPController;

ARCHITECTURE str OF TAPController IS
	TYPE state IS (Test_logic_reset, run_test_idle, select_DR_scan, capture_DR, 
				   shift_DR, exit1_DR, pause_DR, exit2_DR, update_DR, select_IR_scan, 
				   capture_IR, shift_IR, exit1_IR, pause_IR, exit2_IR, update_IR);
	SIGNAL TAP_STATE : state;
	
BEGIN
	PROCESS (TCLK) BEGIN 
		IF (TCLK = '1' and TCLK'EVENT) THEN           
			CASE TAP_STATE IS  
			WHEN Test_logic_reset =>
				IF (TMS = '1') THEN TAP_STATE <= Test_logic_reset;
				ELSE TAP_STATE <= run_test_idle; END IF; 					   
			WHEN run_test_idle =>
				IF (TMS = '1') THEN TAP_STATE <= select_DR_scan;
				ELSE TAP_STATE <= run_test_idle; END IF; 					  
			WHEN select_DR_scan =>
				IF (TMS = '1') THEN TAP_STATE <= select_IR_scan;
				ELSE TAP_STATE <= capture_DR; END IF; 						
			WHEN capture_DR =>
				IF (TMS = '1') THEN TAP_STATE <= exit1_DR;
				ELSE TAP_STATE <= shift_DR; END IF; 						 
			WHEN shift_DR =>
				IF (TMS = '1') THEN TAP_STATE <= exit1_DR;
				ELSE TAP_STATE <= shift_DR; END IF; 						 
			WHEN exit1_DR =>
				IF (TMS = '1') THEN TAP_STATE <= update_DR;
				ELSE TAP_STATE <= pause_DR; END IF; 	
			WHEN pause_DR =>
				IF (TMS = '1') THEN TAP_STATE <= exit2_DR;
				ELSE TAP_STATE <= pause_DR; END IF; 					   
			WHEN exit2_DR =>
				IF (TMS = '1') THEN TAP_STATE <= update_DR;
				ELSE TAP_STATE <= shift_DR; END IF; 					
			WHEN update_DR =>
				IF (TMS = '1') THEN TAP_STATE <= select_DR_scan;
				ELSE TAP_STATE <= run_test_idle; END IF; 					   
			WHEN select_IR_scan =>
				IF (TMS = '1') THEN TAP_STATE <= Test_logic_reset;
				ELSE TAP_STATE <= capture_IR; END IF; 
			WHEN capture_IR =>
				IF (TMS = '1') THEN TAP_STATE <= exit1_IR;
				ELSE TAP_STATE <= shift_IR; END IF; 
			WHEN shift_IR =>
				IF (TMS = '1') THEN TAP_STATE <= exit1_IR;
				ELSE TAP_STATE <= shift_IR; END IF; 
			WHEN exit1_IR =>
				IF (TMS = '1') THEN TAP_STATE <= update_IR;
				ELSE TAP_STATE <= pause_IR; END IF; 
			WHEN pause_IR =>
				IF (TMS = '1') THEN TAP_STATE <= exit2_IR;
				ELSE TAP_STATE <= pause_IR; END IF; 					       					   
			WHEN exit2_IR =>
				IF (TMS = '1') THEN TAP_STATE <= update_IR;
				ELSE TAP_STATE <= shift_IR; END IF; 
			WHEN update_IR =>
				IF (TMS = '1') THEN TAP_STATE <= select_DR_scan;
				ELSE TAP_STATE <= run_test_idle; END IF;   
			END CASE ;
		END IF;
	END PROCESS;
	PROCESS (TCLK) BEGIN 
		IF (TCLK = '0' and TCLK'event) THEN              
			RstBar <= '0'; 	  
			Enable <= '0';     
			ShiftIR <= '0';  ShiftDR <= '0';  
			UpdateIR <= '0'; UpdateDR <= '0'; 
			ClockIR <= '0';  ClockDR <= '0';   		
			CASE TAP_STATE IS  
			WHEN Test_logic_reset  =>
				RstBar <= '1';  
			WHEN capture_DR =>
				ClockDR <= '1'; 						 
			WHEN shift_DR =>
				Enable <= '1';            
				ShiftDR <= '1';  
				ClockDR <= '1'; 	
			WHEN update_DR =>
				UpdateDR <= '1'; 
			WHEN capture_IR  =>
				ClockIR <= '1';      
			WHEN shift_IR =>
				Enable <= '1';     
				ShiftIR <= '1';   
				ClockIR <= '1';  
			WHEN update_IR =>
				UpdateIR <= '1';   	   	   
			WHEN OTHERS =>
				RstBar <= '0'; 	  
				Enable <= '0';     
				ShiftIR <= '0';  ShiftDR <= '0';  
				UpdateIR <= '0'; UpdateDR <= '0'; 
				ClockIR <= '0';  ClockDR <= '0';   		
			END CASE ;
		END IF;
	END PROCESS;
	PROCESS (TAP_STATE) BEGIN 
		sel <= '0';				
		CASE TAP_STATE IS  
		WHEN Test_logic_reset =>
			sel <= '1';
		WHEN capture_IR =>  
			sel <=  '1';
		WHEN shift_IR => 
			sel <=  '1';
		WHEN update_IR =>   
			sel <=  '1';			
		WHEN exit1_IR =>
			sel <=  '1';					 
		WHEN pause_IR =>
			sel <=  '1';			   
		WHEN exit2_IR =>
			sel <=  '1';
		WHEN run_test_idle =>
			sel <=  '1';	   	   
		WHEN OTHERS =>
			sel <= '0';	 	
		END CASE ;
	END PROCESS;          
END str;

