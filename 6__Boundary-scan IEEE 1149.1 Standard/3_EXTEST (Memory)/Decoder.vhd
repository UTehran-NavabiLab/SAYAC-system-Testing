--******************************************************************************
--	Filename:		Decoder.vhd
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
--	IEEE Std 1149.1 Decoder                              
--******************************************************************************

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_arith.ALL;
USE IEEE.STD_LOGIC_unsigned.ALL;

ENTITY Decoder IS
    PORT(
	    Instruction : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		ModeControl: OUT STD_LOGIC;		
	    Select_DR  : OUT STD_LOGIC_VECTOR (1 DOWNTO 0));
END Decoder;

ARCHITECTURE str OF Decoder IS 
    CONSTANT bypass_instruction : STD_LOGIC_VECTOR (2 DOWNTO 0)  := "111";
    CONSTANT intest_instruction : STD_LOGIC_VECTOR (2 DOWNTO 0)  := "011";
    CONSTANT sample_instruction : STD_LOGIC_VECTOR (2 DOWNTO 0)  := "010";
    CONSTANT preload_instruction : STD_LOGIC_VECTOR(2 DOWNTO 0)  := "001";
    CONSTANT extest_instruction : STD_LOGIC_VECTOR (2 DOWNTO 0)  := "000";
	
    CONSTANT sel_BS : STD_LOGIC_VECTOR (1 DOWNTO 0)   := "11";
    CONSTANT sel_BY : STD_LOGIC_VECTOR (1 DOWNTO 0)   := "10";
    CONSTANT sel_UD : STD_LOGIC_VECTOR (1 DOWNTO 0)   := "01";
    CONSTANT sel_NONE : STD_LOGIC_VECTOR (1 DOWNTO 0) := "00";
	
BEGIN
    PROCESS (Instruction ) BEGIN 
		ModeControl <= '0';	
		Select_DR <= sel_NONE; 
		IF (Instruction = bypass_instruction) THEN               
		    Select_DR <= sel_BY; 
			ModeControl <= '0';
		ELSIF (Instruction = intest_instruction) THEN	
			Select_DR <= sel_BS; 
			ModeControl <= '1';
		ELSIF (Instruction = sample_instruction) THEN	
			Select_DR <= sel_BS; 
			ModeControl <= '0';
		ELSIF (Instruction = preload_instruction) THEN	
			Select_DR <= sel_BS; 
			ModeControl <= '0';
		ELSIF (Instruction = extest_instruction) THEN	
			Select_DR <= sel_BS; 
			ModeControl <= '1';
	    ELSE  		    
		    Select_DR <= sel_BS; 
			ModeControl <= '1';
		END IF;	
    END PROCESS;
END str; 