--******************************************************************************
--	Filename:		BS_BoardLevel.vhd
--	Project:		SAYAC Testing 
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
--	Top level board                        
--******************************************************************************

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_arith.ALL;
USE IEEE.STD_LOGIC_unsigned.ALL;
 
ENTITY BS_BoardLevel IS 
    PORT(
	    ClkCUT, RstCUT, TCLK, TMS, TDI: IN STD_LOGIC;
	    TDO : OUT STD_LOGIC);
END BS_BoardLevel;

ARCHITECTURE str OF BS_BoardLevel IS     
	SIGNAL  Out_Pin : STD_LOGIC_VECTOR (19 DOWNTO 0);
    SIGNAL  In_Pin  : STD_LOGIC_VECTOR (16 DOWNTO 0);
	SIGNAL  readMEM : STD_LOGIC;
	SIGNAL  writeMEM: STD_LOGIC;
	SIGNAL  addr    : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL  DataBus : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL readyMEM : STD_LOGIC;
    COMPONENT BS_SAYAC_CPU IS
	    PORT(
	        TCLK, TMS, TDI : IN STD_LOGIC;
	        In_Pin : IN STD_LOGIC_VECTOR (16 DOWNTO 0);
			DataBus : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
	        Out_Pin : OUT STD_LOGIC_VECTOR (19 DOWNTO 0);
	        TDO : OUT STD_LOGIC);
	END COMPONENT;
	COMPONENT MEM IS
	PORT (
		clk, rst, readMEM, writeMEM : IN STD_LOGIC;
		addr : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		rwData          : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		readyMEM        : OUT STD_LOGIC
	);
	END COMPONENT MEM;	
	
BEGIN     
    Chip  : BS_SAYAC_CPU PORT MAP (TCLK, TMS, TDI, In_Pin,DataBus ,Out_Pin, TDO);
    MEMORY: MEM PORT MAP (ClkCUT,RstCUT,readMEM, writeMEM,addr,DataBus,readyMEM);
	readMEM   <= Out_Pin(16);
	writeMEM  <= Out_Pin(17);
	addr      <= Out_Pin(15 DOWNTO 0);
	In_Pin(16 downto 0) <=(readyMEM & DataBus);
	
END str; 
  