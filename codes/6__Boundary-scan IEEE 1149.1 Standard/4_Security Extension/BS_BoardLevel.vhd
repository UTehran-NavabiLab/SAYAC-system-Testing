--******************************************************************************
--	Filename:		BS_BoardLevel.vhd
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
--	Top level board                        
--******************************************************************************

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_arith.ALL;
USE IEEE.STD_LOGIC_unsigned.ALL;
 
ENTITY BS_BoardLevel IS 
    PORT(
	    TCLK, TMS, TDI : IN STD_LOGIC;
	    TDO : OUT STD_LOGIC);
END BS_BoardLevel;

ARCHITECTURE str OF BS_BoardLevel IS    
    SIGNAL  In_Pin : STD_LOGIC_VECTOR (35 DOWNTO 0);
	SIGNAL  Out_Pin : STD_LOGIC_VECTOR (16 DOWNTO 0);
    
	COMPONENT BS_Accelerator_BUS IS
        PORT(
            TCLK, TMS, TDI : IN STD_LOGIC ;
	        In_Pin : IN STD_LOGIC_VECTOR (35 DOWNTO 0);
	        Out_Pin : OUT STD_LOGIC_VECTOR (16 DOWNTO 0);
	        TDO : OUT STD_LOGIC);
    END COMPONENT;
	
	
BEGIN
    
    Chip1 : BS_Accelerator_BUS PORT MAP (TCLK, TMS, TDI, In_Pin, Out_Pin, TDO);
	
END str; 
  