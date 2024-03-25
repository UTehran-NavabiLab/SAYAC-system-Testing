--******************************************************************************
--	Filename:		BS_BoardLevel.vhd
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
--	Top level board                        
--******************************************************************************

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_arith.ALL;
USE IEEE.STD_LOGIC_unsigned.ALL;
 
ENTITY BS_BoardLevel IS 
    PORT(
	    TCLK, TMS, TDI, sel_test: IN STD_LOGIC;
	    TDO : OUT STD_LOGIC);
END BS_BoardLevel;

ARCHITECTURE str OF BS_BoardLevel IS 
    SIGNAL  Par_Chip1To2 : STD_LOGIC_VECTOR (35 DOWNTO 0);
    SIGNAL  Par_Chip2To1 : STD_LOGIC_VECTOR (16 DOWNTO 0); 
	SIGNAL  TDI_chip1 : STD_LOGIC;
	SIGNAL  TDI_chip2 : STD_LOGIC;
    SIGNAL  TDO_chip1 : STD_LOGIC;
	SIGNAL  TDO_chip2 : STD_LOGIC;
    SIGNAL  faultyPar_Chip1To2 : STD_LOGIC_VECTOR (35 DOWNTO 0);
	SIGNAL  faultyPar_Chip2To1 : STD_LOGIC_VECTOR (16 DOWNTO 0);
    COMPONENT BS_SAYAC_CPU IS
	    PORT(
	        TCLK, TMS, TDI : IN STD_LOGIC;
	        In_Pin : IN STD_LOGIC_VECTOR (16 DOWNTO 0);
	        Out_Pin : OUT STD_LOGIC_VECTOR (35 DOWNTO 0);
	        TDO : OUT STD_LOGIC);
	END COMPONENT;
	COMPONENT BS_Accelerator_BUS IS
        PORT(
            TCLK, TMS, TDI : IN STD_LOGIC ;
	        In_Pin : IN STD_LOGIC_VECTOR (35 DOWNTO 0);
	        Out_Pin : OUT STD_LOGIC_VECTOR (16 DOWNTO 0);
	        TDO : OUT STD_LOGIC);
    END COMPONENT;
	COMPONENT MUX2_1 IS
	    PORT(
	        in1, in2, sel : IN STD_LOGIC;	
		    output : OUT STD_LOGIC);
	END COMPONENT;
	
BEGIN
    faultyPar_Chip1To2 <= Par_Chip1To2 (35 DOWNTO 1) & '1'; 
	faultyPar_Chip2To1 <= '1' & Par_Chip2To1 (15 DOWNTO 0); 
    Chip1 : BS_SAYAC_CPU PORT MAP (TCLK, TMS, TDI_chip1, faultyPar_Chip2To1, Par_Chip1To2, TDO_chip1);
    Chip2 : BS_Accelerator_BUS PORT MAP (TCLK, TMS, TDI_chip2, faultyPar_Chip1To2, Par_Chip2To1, TDO_chip2);
	Mux_chip_in  : MUX2_1 PORT MAP (TDI, TDO_chip2, sel_test, TDI_chip1);
	Mux_connect  : MUX2_1 PORT MAP (TDO_chip1, TDI, sel_test, TDI_chip2);
	Mux_chip_out : MUX2_1 PORT MAP (TDO_chip2, TDO_chip1, sel_test, TDO);
END str; 
  