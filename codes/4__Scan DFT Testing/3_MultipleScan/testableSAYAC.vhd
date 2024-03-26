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
--	Top level of testable SAYAC-MEM system for multiple scan testing                               
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
		sizePI      : INTEGER := 49; 
		sizePO      : INTEGER := 64;
		chainLength : INTEGER := 25
	);
	PORT (
		clk   : IN STD_LOGIC;
		rst   : IN STD_LOGIC;
		NbarT : IN STD_LOGIC;
		PbarS : IN STD_LOGIC;
		Si_1  : IN STD_LOGIC;  
		Si_2  : IN STD_LOGIC;  
		Si_3  : IN STD_LOGIC;  
		Si_4  : IN STD_LOGIC;  
		Si_5  : IN STD_LOGIC;   
		Si_6  : IN STD_LOGIC;   
		So_1  : OUT STD_LOGIC; 
		So_2  : OUT STD_LOGIC; 
		So_3  : OUT STD_LOGIC; 
		So_4  : OUT STD_LOGIC; 
		So_5  : OUT STD_LOGIC; 
		So_6  : OUT STD_LOGIC; 
		So_7  : OUT STD_LOGIC);
END ENTITY testableSAYAC;

ARCHITECTURE arch OF testableSAYAC IS

	SIGNAL In_SAYAC  : STD_LOGIC_VECTOR (sizePI-1 DOWNTO 0);
	SIGNAL OUT_MEM   : STD_LOGIC_VECTOR (sizePI-1 DOWNTO 0);
	SIGNAL In_LTEST  : STD_LOGIC_VECTOR (sizePI-1 DOWNTO 0);
	SIGNAL Out_MTEST : STD_LOGIC_VECTOR (sizePI-1 DOWNTO 0);
	
	SIGNAL Out_SAYAC  : STD_LOGIC_VECTOR (sizePO-1 DOWNTO 0); 
	SIGNAL In_MEM     : STD_LOGIC_VECTOR (sizePO-1 DOWNTO 0); 
	SIGNAL In_MTEST   : STD_LOGIC_VECTOR (sizePO-1 DOWNTO 0); 
	SIGNAL OutScanReg : STD_LOGIC_VECTOR (sizePO-1 DOWNTO 0);

	SIGNAL fakeDFF_sigIn  : STD_LOGIC_VECTOR (0 DOWNTO 0);
	SIGNAL fakeDFF_sigOut : STD_LOGIC_VECTOR (10 DOWNTO 0); 

BEGIN	
	SAYAC_Logic : ENTITY WORK.LGC_Netlist 
			PORT MAP (
				clk 		   => clk, 								
				rst 		   => rst, 
				dataBusIn 	   => In_SAYAC(15 DOWNTO 0 ),
				p1TRF 		   => In_SAYAC(31 DOWNTO 16),
				p2TRF 		   => In_SAYAC(47 DOWNTO 32),
				readyMEM 	   => In_SAYAC(48),
				PbarS 		   => PbarS,
				Si_3           => Si_3,
				Si_4           => Si_4,
				Si_5           => Si_5,
				Si_6           => Si_6,
				So_1           => So_1,
				So_2           => So_2,
				So_3           => So_3,
				So_4           => So_4,
				addrBus 	   => Out_SAYAC(15 DOWNTO 0 ),
				dataBusOut 	   => Out_SAYAC(31 DOWNTO 16),
				inDataTRF 	   => Out_SAYAC(47 DOWNTO 32),
				outMuxrd  	   => Out_SAYAC(51 DOWNTO 48),
				outMuxrs1 	   => Out_SAYAC(55 DOWNTO 52),
				outMuxrs2 	   => Out_SAYAC(59 DOWNTO 56),
				readInst 	   => Out_SAYAC(60),
				readMM		   => Out_SAYAC(61),
				writeMM 	   => Out_SAYAC(62),
				writeTRF 	   => Out_SAYAC(63)			
			);
	
	scanReg_In_1to25: ENTITY WORK.dffBlock GENERIC MAP (chainLength) 
				PORT MAP ((OTHERS=>'0'), clk, rst, '0', '0', PbarS, Si_1, '0', In_LTEST(48 DOWNTO 24));
	scanReg_In_26to49: ENTITY WORK.dffBlock GENERIC MAP (chainLength-1) 
				PORT MAP ((OTHERS=>'0'), clk, rst, '0', '0', PbarS, Si_2, '0', In_LTEST(23 DOWNTO 0));
	fakeDFF_50: ENTITY WORK.dffBlock GENERIC MAP (1) 
				PORT MAP ((OTHERS=>'0'), clk, rst, '0', '0', PbarS, In_LTEST(0), '0', fakeDFF_sigIn);

	
	scanReg_Out_1to25: ENTITY WORK.dffBlock GENERIC MAP (chainLength) 
				 PORT MAP (Out_SAYAC(63 DOWNTO 39), clk, rst, '0', '1', PbarS, '0', '0', OutScanReg(63 DOWNTO 39));	
	So_5 <= OutScanReg(39);
	scanReg_Out_26to50: ENTITY WORK.dffBlock GENERIC MAP (chainLength) 
				 PORT MAP (Out_SAYAC(38 DOWNTO 14), clk, rst, '0', '1', PbarS, '0', '0', OutScanReg(38 DOWNTO 14));	
	So_6 <= OutScanReg(14);
	scanReg_Out_51to64: ENTITY WORK.dffBlock GENERIC MAP (sizePO-sizePI-1) 
				 PORT MAP (Out_SAYAC(13 DOWNTO 0), clk, rst, '0', '1', PbarS, '0', '0', OutScanReg(13 DOWNTO 0));	
	fakeDFF_65to75: ENTITY WORK.dffBlock GENERIC MAP (chainLength-(sizePO-sizePI-1)) 
				 PORT MAP ((OTHERS=>'0'), clk, rst, '0', '1', PbarS, OutScanReg(0), '0', fakeDFF_sigOut(10 DOWNTO 0));
	So_7 <= fakeDFF_sigOut(0);
		
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