--******************************************************************************
--	Filename:		testableSAYAC.vhd
--	Project:		SAYAC Testing 
--  Version:		1.0
--	History:
--	Date:			20 June 2022
--	Last Author: 	Helia
--  Copyright (C) 2022 University of Tehran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--
--******************************************************************************
--	File content description:
--	Top level of testable SAYAC-MEM system for STUMPS LBIST testing                               
--******************************************************************************

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.MATH_REAL.ALL;

ENTITY testableSAYAC IS
	GENERIC (
		sizePI      : INTEGER := 49; 
		sizePO      : INTEGER := 64;
		PRPG1_Size  : INTEGER := 60;
		MISR1_Size  : INTEGER := 80;
		PRPG2_Size  : INTEGER := 10;
		MISR2_Size  : INTEGER := 10;
		ShiftSize   : INTEGER := 25;
		numOfCycles : INTEGER := 100;
		numOfRounds : INTEGER := 5
	);
	PORT (
		clk   : IN STD_LOGIC;
		rst   : IN STD_LOGIC;
		ROM_rst : IN STD_LOGIC;
		NbarT : IN STD_LOGIC;
		equal : OUT STD_LOGIC
--		fail  : OUT STD_LOGIC
	);
END ENTITY testableSAYAC;

ARCHITECTURE arch OF testableSAYAC IS

	SIGNAL In_SAYAC  : STD_LOGIC_VECTOR (sizePI-1 DOWNTO 0);
	SIGNAL OUT_MEM   : STD_LOGIC_VECTOR (sizePI-1 DOWNTO 0);
	SIGNAL Out_MTEST : STD_LOGIC_VECTOR (sizePI-1 DOWNTO 0);
	
	SIGNAL Si1_SAYAC_Logic, Si2_SAYAC_Logic : STD_LOGIC;
	SIGNAL Si3_SAYAC_Logic, Si4_SAYAC_Logic : STD_LOGIC;
	SIGNAL So1_SAYAC_Logic, So2_SAYAC_Logic : STD_LOGIC;
	SIGNAL So3_SAYAC_Logic, So4_SAYAC_Logic : STD_LOGIC;
	
	SIGNAL Out_SAYAC  : STD_LOGIC_VECTOR (sizePO-1 DOWNTO 0); 
	SIGNAL In_MEM     : STD_LOGIC_VECTOR (sizePO-1 DOWNTO 0);  
	SIGNAL In_MTEST   : STD_LOGIC_VECTOR (sizePO-1 DOWNTO 0); 

	SIGNAL PbarS, PbarS_CNTRL: STD_LOGIC;
	SIGNAL done : STD_LOGIC;
	SIGNAL internalRst : STD_LOGIC;
	SIGNAL PRPG1_En, MISR1_En, PRPG2_En, MISR2_En : STD_LOGIC;
	SIGNAL PRPG1_Poly, PRPG1_Seed : STD_LOGIC_VECTOR (PRPG1_Size-1 DOWNTO 0);
	SIGNAL MISR1_Poly, MISR1_Seed : STD_LOGIC_VECTOR (MISR1_Size-1 DOWNTO 0);
	SIGNAL PRPG2_Poly, PRPG2_Seed : STD_LOGIC_VECTOR (PRPG2_Size-1 DOWNTO 0);
	SIGNAL MISR2_Poly, MISR2_Seed : STD_LOGIC_VECTOR (MISR2_Size-1 DOWNTO 0);
	SIGNAL PRPG1_Out : STD_LOGIC_VECTOR (PRPG1_Size-1 DOWNTO 0);
	SIGNAL PRPG2_Out : STD_LOGIC_VECTOR (PRPG2_Size-1 DOWNTO 0);
	SIGNAL MISR1_In  : STD_LOGIC_VECTOR (MISR1_Size-1 DOWNTO 0);
	SIGNAL MISR2_In  : STD_LOGIC_VECTOR (MISR2_Size-1 DOWNTO 0);
	SIGNAL MISR1_Out : STD_LOGIC_VECTOR (MISR1_Size-1 DOWNTO 0);
	SIGNAL MISR2_Out : STD_LOGIC_VECTOR (MISR2_Size-1 DOWNTO 0);
	SIGNAL tempGolden_Out : STD_LOGIC_VECTOR (MISR1_Size+MISR2_Size-1 DOWNTO 0);
	SIGNAL temp_Out : STD_LOGIC_VECTOR (MISR1_Size+MISR2_Size-1 DOWNTO 0);
	
	SIGNAL read_Sig, read_Cfg: STD_LOGIC;
	SIGNAL addr_Sig, data_Sig: STD_LOGIC_VECTOR (MISR1_Size+MISR2_Size-1 DOWNTO 0);
	SIGNAL addr_Cfg, data_Cfg: STD_LOGIC_VECTOR (PRPG1_Size+MISR1_Size+PRPG2_Size+MISR2_Size-1 DOWNTO 0);

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
				Si_3		=> Si1_SAYAC_Logic,
				Si_4		=> Si2_SAYAC_Logic,
				Si_5		=> Si3_SAYAC_Logic,
				Si_6		=> Si4_SAYAC_Logic,
				So_1		=> So1_SAYAC_Logic,
				So_2		=> So2_SAYAC_Logic,
				So_3		=> So3_SAYAC_Logic,
				So_4		=> So4_SAYAC_Logic,
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
	
	PRPG_1 : ENTITY WORK.LFSR GENERIC MAP (PRPG1_Size) 
			PORT MAP (clk, internalRst, PRPG1_En, PRPG1_Poly, PRPG1_Seed, PRPG1_Out);
	MISR_1 : ENTITY WORK.MISR GENERIC MAP (MISR1_Size) 
			PORT MAP (clk, internalRst, MISR1_En, MISR1_Poly, MISR1_Seed, MISR1_In, MISR1_Out);
	PRPG_2 : ENTITY WORK.LFSR GENERIC MAP (PRPG2_Size) 
			PORT MAP (clk, internalRst, PRPG2_En, PRPG2_Poly, PRPG2_Seed, PRPG2_Out);
	MISR_2 : ENTITY WORK.MISR GENERIC MAP (MISR2_Size) 
			PORT MAP (clk, internalRst, MISR2_En, MISR2_Poly, MISR2_Seed, MISR2_In, MISR2_Out);
	CNTRL : ENTITY WORK.STUMPS_Controller GENERIC MAP (ShiftSize, numOfCycles, numOfRounds) 
			PORT MAP (clk, rst, NbarT, PbarS_CNTRL, internalRst, PRPG1_En, PRPG2_En, MISR2_En, MISR1_En, done);
									
	In_SAYAC <= PRPG1_Out(sizePI-1 DOWNTO 0) WHEN NbarT = '1' ELSE Out_MEM;
	In_MEM   <= In_MTEST WHEN NbarT = '1' ELSE Out_SAYAC;
	
	Si4_SAYAC_Logic <= PRPG2_Out(9);
	Si3_SAYAC_Logic <= PRPG2_Out(5);
	Si2_SAYAC_Logic <= PRPG2_Out(3);
	Si1_SAYAC_Logic <= PRPG2_Out(0);
	MISR1_In <= ("0000000000000000" & Out_SAYAC);
	MISR2_In <= (So4_SAYAC_Logic & "000" & So3_SAYAC_Logic & '0' & So2_SAYAC_Logic & "00" & So1_SAYAC_Logic);
	PbarS    <= PbarS_CNTRL WHEN NbarT = '1' ELSE '0';
	
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
	COMP : ENTITY WORK.comparator GENERIC MAP (MISR1_Size, MISR2_Size)
			PORT MAP (temp_Out, tempGolden_Out, equal);
			
	Good_Responses_Rom : ENTITY WORK.inst_ROM_Signature GENERIC MAP ((MISR1_Size+MISR2_Size), 100)
			PORT MAP (clk, ROM_rst, read_Sig, addr_Sig, data_Sig);
			
	Config_Rom : ENTITY WORK.inst_ROM_Config GENERIC MAP ((PRPG1_Size+MISR1_Size+PRPG2_Size+MISR2_Size), 100)
			PORT MAP (clk, ROM_rst, read_Cfg, addr_Cfg, data_Cfg);
END ARCHITECTURE arch;