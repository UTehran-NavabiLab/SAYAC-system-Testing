--******************************************************************************
--	Filename:		testableSAYAC.vhd
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
--	Top level of testable SAYAC-MEM system for full scan testing                               
--******************************************************************************

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.math_real.ALL; 

ENTITY testableSAYAC IS
	GENERIC (
		sizePI : INTEGER := 49; 
		sizePO : INTEGER := 64
	);
	PORT (
		clk   : IN STD_LOGIC;
		rst   : IN STD_LOGIC;
		NbarT : IN STD_LOGIC;
		PbarS : IN STD_LOGIC;
		Si    : IN STD_LOGIC;
		So    : OUT STD_LOGIC);
END ENTITY testableSAYAC;

ARCHITECTURE arch OF testableSAYAC IS

	SIGNAL In_SAYAC  : STD_LOGIC_VECTOR (sizePI-1 DOWNTO 0);
	SIGNAL OUT_MEM   : STD_LOGIC_VECTOR (sizePI-1 DOWNTO 0);
	SIGNAL In_LTEST  : STD_LOGIC_VECTOR (sizePI-1 DOWNTO 0);
	SIGNAL Out_MTEST : STD_LOGIC_VECTOR (sizePI-1 DOWNTO 0);
	
	SIGNAL Si_SAYAC_Logic : STD_LOGIC;
	SIGNAL So_SAYAC_Logic : STD_LOGIC;
	
	SIGNAL Out_SAYAC  : STD_LOGIC_VECTOR (sizePO-1 DOWNTO 0); 
	SIGNAL In_MEM     : STD_LOGIC_VECTOR (sizePO-1 DOWNTO 0);  
	SIGNAL In_MTEST   : STD_LOGIC_VECTOR (sizePO-1 DOWNTO 0); 
	SIGNAL OutScanReg : STD_LOGIC_VECTOR (sizePO-1 DOWNTO 0);

BEGIN	
	SAYAC_Logic : ENTITY WORK.LGC_Netlist 
			PORT MAP (
				clk 		=> clk, 								
				rst 		=> rst, 
				dataBusIn 	=> In_SAYAC(15 DOWNTO 0 ),
				p1TRF 		=> In_SAYAC(31 DOWNTO 16),
				p2TRF 		=> In_SAYAC(47 DOWNTO 32),
				readyMEM 	=> In_SAYAC(48),
				PbarS 		=> PbarS,
				Si			=> Si_SAYAC_Logic,
				So 			=> So_SAYAC_Logic,
				addrBus 	=> Out_SAYAC(15 DOWNTO 0 ),
				dataBusOut 	=> Out_SAYAC(31 DOWNTO 16),
				inDataTRF 	=> Out_SAYAC(47 DOWNTO 32),
				outMuxrd  	=> Out_SAYAC(51 DOWNTO 48),
				outMuxrs1 	=> Out_SAYAC(55 DOWNTO 52),
				outMuxrs2 	=> Out_SAYAC(59 DOWNTO 56),
				readInst 	=> Out_SAYAC(60),
				readMM		=> Out_SAYAC(61),
				writeMM 	=> Out_SAYAC(62),
				writeTRF 	=> Out_SAYAC(63)			
			);
	
	scanReg_In: ENTITY WORK.dffBlock GENERIC MAP (sizePI) 
				PORT MAP ((OTHERS=>'0'), clk, rst, '0', '0', PbarS, Si, '0', In_LTEST);
	Si_SAYAC_Logic <= In_LTEST(0);
	
	scanReg_Out: ENTITY WORK.dffBlock GENERIC MAP (sizePO) 
				 PORT MAP (Out_SAYAC, clk, rst, '0', '1', PbarS, So_SAYAC_Logic, '0', OutScanReg);	
	So <= OutScanReg(0);
		
	In_SAYAC <= In_LTEST WHEN NbarT = '1' ELSE Out_MEM;
	In_MEM   <= In_MTEST WHEN NbarT = '1' ELSE Out_SAYAC;
	
	Register_File : ENTITY WORK.TRF 
						PORT MAP (
							clk 	   => clk, 
							rst 	   => rst,
							write_data => In_MEM(47 DOWNTO 32),
							rd 		   => In_MEM(51 DOWNTO 48), 
							rs1 	   => In_MEM(55 DOWNTO 52), 
							rs2 	   => In_MEM(59 DOWNTO 56), 
							writeTRF   => In_MEM(63),
							p1 		   => Out_MEM(31 DOWNTO 16), 
							p2 		   => Out_MEM(47 DOWNTO 32)
						);
					
	Data_MEMORY : ENTITY WORK.MEM  
					PORT MAP (
						clk 	  => clk,
						rst 	  => rst,
						addr	  => In_MEM(15 DOWNTO 0),
						writeData => In_MEM(31 DOWNTO 16),
						readMEM   => In_MEM(61),
						writeMEM  => In_MEM(62), 
						readData  => Out_MEM(15 DOWNTO 0),  
						readyMEM  => Out_MEM(48)
					);
				
	InstructionROM : ENTITY WORK.inst_ROM GENERIC MAP (	3857 )
						PORT MAP (
							clk 	 => clk, 
							rst 	 => rst, 
							readInst => In_MEM(60),  
							addrInst => In_MEM(15 DOWNTO 0),
							Inst 	 => Out_MEM(15 DOWNTO 0)
						);
END ARCHITECTURE arch;