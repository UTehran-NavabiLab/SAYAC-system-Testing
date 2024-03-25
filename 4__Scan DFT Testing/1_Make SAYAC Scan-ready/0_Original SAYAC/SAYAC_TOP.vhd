--******************************************************************************
--	Filename:		SAYAC_register_file.vhd
--	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
--  Version:		0.990
--	History:
--	Date:			27 April 2021
--	Last Author: 	HANIEH
--  Copyright (C) 2021 University of Tehran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--

--******************************************************************************
--	File content description:
--	SAYAC_TOP level circuit (TOP) of the SAYAC core                                 
--******************************************************************************

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY TOP IS
	PORT (
		clk, rst : IN STD_LOGIC
	);
END ENTITY TOP;

ARCHITECTURE behaviour OF TOP IS
	SIGNAL readyMEM : STD_LOGIC;
	SIGNAL readMM, writeMM : STD_LOGIC;  
	SIGNAL addrBus : STD_LOGIC_VECTOR(15 DOWNTO 0); 
	SIGNAL dataBus : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL readInst : STD_LOGIC;
BEGIN
	SAYAC_Processor : ENTITY WORK.PRC PORT MAP 
					(clk => clk, rst => rst,
					readyMEM => readyMEM, 
					readMM => readMM, writeMM => writeMM, 
					addrBus => addrBus, dataBus => dataBus,  
					readInst => readInst);
					
	Data_MEMORY : ENTITY WORK.MEM PORT MAP 
				(clk => clk, rst => rst, readMEM => readMM, writeMEM => writeMM,  
				addr => addrBus, rwData => dataBus, readyMEM => readyMEM);
				
	InstructionROM : ENTITY WORK.inst_ROM GENERIC MAP (	3857 )
						PORT MAP (clk => clk, rst => rst, readInst => readInst,  
							addrInst => addrBus, Inst => dataBus);
END ARCHITECTURE behaviour;
