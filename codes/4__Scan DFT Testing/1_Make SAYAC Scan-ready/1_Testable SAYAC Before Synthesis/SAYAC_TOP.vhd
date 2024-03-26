--******************************************************************************
--	Filename:		SAYAC_register_file.vhd
--	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
--  Version:		0.990
--	History:
--	Date:			27 April 2021
--	Last Author: 	HANIEH
--  Copyright (C) 2021 University of Teheran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--

--******************************************************************************
--	File content description:
--	TOP level circuit (TOP) of the SAYAC core                                 
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
	SIGNAL dataBusIn : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL readMM, writeMM : STD_LOGIC;
	SIGNAL dataBusOut, addrBus : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL outMuxrs1, outMuxrs2, outMuxrd : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL inDataTRF : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL p1TRF, p2TRF : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL writeTRF : STD_LOGIC;
	SIGNAL readInst : STD_LOGIC;
BEGIN
	SAYAC_Logic : ENTITY WORK.LGC PORT MAP 
					(clk => clk, rst => rst,
					readyMEM => readyMEM, dataBusIn => dataBusIn, 
					readMM => readMM, writeMM => writeMM,  
					dataBusOut => dataBusOut, addrBus => addrBus, 
					outMuxrs1 => outMuxrs1, outMuxrs2 => outMuxrs2,  
					outMuxrd => outMuxrd, inDataTRF => inDataTRF, 
					p1TRF => p1TRF, p2TRF => p2TRF,  
					writeTRF => writeTRF, readInst => readInst);

	Register_File : ENTITY WORK.TRF PORT MAP 
					(clk => clk, rst => rst, writeTRF => writeTRF, 
					rs1 => outMuxrs1, rs2 => outMuxrs2, rd => outMuxrd,  
					write_data => inDataTRF, 
					p1 => p1TRF, p2 => p2TRF);
					
	Data_MEMORY : ENTITY WORK.MEM PORT MAP 
				(clk => clk, rst => rst, readMEM => readMM, writeMEM => writeMM,  
				addr => addrBus, writeData => dataBusOut, readData => dataBusIn, readyMEM => readyMEM);
				
	InstructionROM : ENTITY WORK.inst_ROM GENERIC MAP (	3857 )
						PORT MAP (clk => clk, rst => rst, readInst => readInst,  
							addrInst => addrBus, Inst => dataBusIn);
END ARCHITECTURE behaviour;

