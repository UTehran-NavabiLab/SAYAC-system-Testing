--******************************************************************************
--	Filename:		SAYAC_CPU.vhd
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
--	SAYAC with concatenated inputs & outputs                             
--******************************************************************************

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY SAYAC_CPU IS
    PORT(
	    Input : IN STD_LOGIC_VECTOR (16 DOWNTO 0);
	    Output : OUT STD_LOGIC_VECTOR (35 DOWNTO 0));
END SAYAC_CPU;

ARCHITECTURE str OF SAYAC_CPU IS
    SIGNAL readyMEM   :  STD_LOGIC;
	SIGNAL clk   	  :  STD_LOGIC;
	SIGNAL rst        :  STD_LOGIC;
    SIGNAL dataBusIn  :  STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL readMEM    :  STD_LOGIC;
	SIGNAL writeMEM   :  STD_LOGIC;
	SIGNAL readIO     :  STD_LOGIC;
	SIGNAL writeIO    :  STD_LOGIC;
	SIGNAL dataBusOut :  STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL addrBus    :  STD_LOGIC_VECTOR(15 DOWNTO 0);
BEGIN 
   SAYAC : ENTITY WORK.SAYAC_TOP PORT MAP 
					(clk => clk, rst => rst,  readyMEM => readyMEM,
					dataBusIn => dataBusIn,	readMEM => readMEM,
					writeMEM => writeMEM, readIO => readIO,
					writeIO => writeIO, dataBusOut => dataBusOut,	
					addrBus => addrBus
					);
	readyMEM  <= Input(16);
    dataBusIn <= Input (15 DOWNTO 0); 
	Output (15 DOWNTO 0)  <= dataBusOut;
	Output (31 DOWNTO 16) <= addrBus;
	Output (32)  <= readMEM;
	Output (33)  <= writeMEM;
	Output (34)  <= readIO;
	Output (35)  <= writeIO;
END str; 