--******************************************************************************
--	Filename:		Decoder.vhd
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
--	IEEE Std 1149.1 Decoder                              
--******************************************************************************

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_arith.ALL;
USE IEEE.STD_LOGIC_unsigned.ALL;

ENTITY Decoder IS
    PORT(
	    Instruction : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
	    ShiftDR, ClockDR, UpdateDR,Locked : IN STD_LOGIC;
	    ShiftBY, ClockBY : OUT STD_LOGIC;
	    ShiftBR, ClockBR, UpdateBR, ModeControl,En_KLSR,En_KR,En_LR,ShiftKL,UpdateKL : OUT STD_LOGIC; 
	    Select_DR : OUT STD_LOGIC_VECTOR (1 DOWNTO 0));
END Decoder;

ARCHITECTURE str OF Decoder IS 
    CONSTANT bypass_instruction : STD_LOGIC_VECTOR (2 DOWNTO 0)  := "111";
    CONSTANT intest_instruction : STD_LOGIC_VECTOR (2 DOWNTO 0)  := "011";
    CONSTANT sample_instruction : STD_LOGIC_VECTOR (2 DOWNTO 0)  := "010";
    CONSTANT preload_instruction: STD_LOGIC_VECTOR (2 DOWNTO 0)  := "001";
    CONSTANT extest_instruction : STD_LOGIC_VECTOR (2 DOWNTO 0)  := "000";
	CONSTANT lOCK_instruction 	: STD_LOGIC_VECTOR (2 DOWNTO 0)  := "100";
	CONSTANT unlock_instruction : STD_LOGIC_VECTOR (2 DOWNTO 0)  := "101";
	
    CONSTANT sel_BS : STD_LOGIC_VECTOR (1 DOWNTO 0)   := "11";
    CONSTANT sel_BY : STD_LOGIC_VECTOR (1 DOWNTO 0)   := "10";
    CONSTANT sel_KL : STD_LOGIC_VECTOR (1 DOWNTO 0)   := "01";
    CONSTANT sel_NONE : STD_LOGIC_VECTOR (1 DOWNTO 0) := "00";
	
BEGIN
    PROCESS (Instruction, ShiftDR, ClockDR, UpdateDR) BEGIN 
		ShiftBY 	<= '0';
		ClockBY 	<= '0';
        ShiftBR 	<= '0';
		ClockBR 	<= '0';
		UpdateBR 	<= '0';
		ModeControl <= '0';	
		En_KLSR     <= '0';
		En_KR       <= '0';
		En_LR       <= '0';
		Select_DR <= sel_NONE; 
		IF (Instruction = bypass_instruction) THEN               
		    ShiftBY <= ShiftDR;
		    ClockBY <= ClockDR;
		    Select_DR <= sel_BY; 
		ELSIF (Instruction = lOCK_instruction) 	 THEN 
			En_LR    <= '1';
			En_KLSR  <= '1';
			ShiftKL  <= ShiftDR;
			UpdateKL <= UpdateDR;
			Select_DR <=sel_KL;			
		ELSIF (Instruction = unlock_instruction) THEN 
			En_KR    <= '1';
			En_KLSR  <= '1';
			ShiftKL  <= ShiftDR;
			UpdateKL <= UpdateDR;
			Select_DR <=sel_KL;
	    ELSIF  (Locked='0') THEN
		    ShiftBR <= ShiftDR;
		    UpdateBR <= UpdateDR;
		    ClockBR <= ClockDR;
		    ModeControl <= '1';	
		    Select_DR <= sel_BS; 
		ELSIF  (Locked='1') THEN	
			ShiftBY <= ShiftDR;
		    ClockBY <= ClockDR;
		    Select_DR <= sel_BY;
		
		END IF;	
    END PROCESS;
END str; 


