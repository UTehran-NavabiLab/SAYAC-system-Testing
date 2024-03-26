--******************************************************************************
--	Filename:		SAYAC_TOP_TB.vhd
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
--	Testbench for verifying the SAYAC core without memories                               
--******************************************************************************

-- Application: for 5 times (A*B => 128*5 = 640) 
-- memory => mem[37] = 128(A), mem[45] = 640(result)
-- Reg File:
-- 		R1 = 37(Address of A)
-- 		R2 = 45(Address of result)
-- 		R5 = 128(A)
-- 		R6 = 5(B)
-- 		R7 = 640(result)	
--      R3 = 0 (numOfTimes) 
--      R4 = -9 (Jump Address)
-------------------------------------------------------------------------
-- R1: Address of A   		MSI: R1 = SE(37):			0101_00100101_0001	
-- R5: Load A				LDR: R5 = MEM(R1):			00100000_0001_0101	 
-- R6: Put B				MSI: R6 = SE(05):			0101_00000101_0110
-- R7: Mult A by B			MUL: R7 = R5 * R6:			1101_0101_0110_0111
-- R2: Address of result	MSI: R2 = SE(45):			0101_00101101_0010	
-- mem[45]: Store A*B		STR: MEM(R2) = R7:			00100100_0111_0010
-- Add 1 to numOfTimes		ADI: R3 = R3 + SE(01):		1011_00000001_0011			
-- Check (numOfTimes<5)		CMR: R3, R6:				1111_00_00_0011_0110
-- R4: Jump Address 		MSI: R4 = SE(F8):			0101_11110111_0100			R4 = -9	= F7	
-- IF(numOfTimes<5)jump to newMul  BRR: 00010, R4:		1111_01_1_00010_0100	Jump End_ACol (-40+31=-9=F7)

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY test_SAYAC_Ver IS
END ENTITY test_SAYAC_Ver;

ARCHITECTURE test OF test_SAYAC_Ver IS
	SIGNAL clk : STD_LOGIC := '0';
	SIGNAL rst, readyMEM : STD_LOGIC;
	SIGNAL dataBusIn : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL p1TRF, p2TRF : STD_LOGIC_VECTOR(15 DOWNTO 0);
	
	SIGNAL readMM_RTL, writeMM_RTL : STD_LOGIC;
	SIGNAL dataBusOut_RTL, addrBus_RTL : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL outMuxrs1_RTL, outMuxrs2_RTL, outMuxrd_RTL : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL inDataTRF_RTL : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL writeTRF_RTL : STD_LOGIC;
	SIGNAL readInst_RTL : STD_LOGIC;
	--------------------------------------------------------------------
	SIGNAL readMM_NET, writeMM_NET : STD_LOGIC;
	SIGNAL dataBusOut_NET, addrBus_NET : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL outMuxrs1_NET, outMuxrs2_NET, outMuxrd_NET : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL inDataTRF_NET : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL writeTRF_NET : STD_LOGIC;
	SIGNAL readInst_NET : STD_LOGIC;
BEGIN	
	clk <= NOT clk AFTER 5 NS WHEN NOW <= 250 NS ELSE '0';
	rst <= '1', '0' AFTER 7 NS;
	
	readyMEM <= '0', '1' AFTER 10 NS;
	
	dataBusIn <= X"0000", "0101001001010001" AFTER 10 NS,  --Ins 1: Address of A
						  "0010000000010101" AFTER 30 NS,  --Ins 2: Load A
						  "0000000010000000" AFTER 40 NS,  --A: 1000_0000
						  "0101000001010110" AFTER 60 NS,  --Ins 3: Put B
						  "1101010101100111" AFTER 80 NS,  --Ins 4: A*B
						  "0101001011010010" AFTER 100 NS, --Ins 5: Address of result
						  "0010010001110010" AFTER 120 NS, --Ins 6: Store of result
						  "1011000000010011" AFTER 140 NS, --Ins 7: Add 1 to numOfTimes
						  "1111000000110110" AFTER 160 NS, --Ins 8: Check condition
						  "0101111101110100" AFTER 180 NS, --Ins 9: Determine Jump Address
						  "1111011000100100" AFTER 200 NS, --Ins 10: If (cond is satisfied) Jump
						  "0000000000000000" AFTER 220 NS; 
						  
	p1TRF <= "0000000000000000", "0000000000100101" AFTER 35 NS,
							    "0000000000000000" AFTER 45 NS,
							    "0000000000000101" AFTER 85 NS,
							    "0000000000000000" AFTER 95 NS,
							    "0000000000000010" AFTER 125 NS,
							    "0000001010000000" AFTER 135 NS,
							    "0000000000000000" AFTER 145 NS,
								"0000000000000011" AFTER 155 NS,
								"0000000000000100" AFTER 160 NS,
								"0000000000000000" AFTER 165 NS,
								"0000000000000100" AFTER 175 NS,
								"0000000000000000" AFTER 185 NS,
								"1111111111110111" AFTER 215 NS,
								"0000000000000000" AFTER 225 NS;
							  
	p2TRF <= "0000000000000000", "0000000010000000" AFTER 85 NS,
							    "0000000000000000" AFTER 95 NS,
								"0000000000000101" AFTER 175 NS,
								"0000000000000000" AFTER 185 NS;
								
	SAYAC_RTL : ENTITY WORK.LGC PORT MAP 
					(clk, rst, readyMEM, dataBusIn, p1TRF, p2TRF,  
					readMM_RTL, writeMM_RTL, 
					dataBusOut_RTL, addrBus_RTL,
					outMuxrs1_RTL, outMuxrs2_RTL, outMuxrd_RTL,
					inDataTRF_RTL, writeTRF_RTL, readInst_RTL);

	SAYAC_Netlist : ENTITY WORK.LGC_Netlist_Ver PORT MAP 
					(clk, rst, readyMEM, dataBusIn, p1TRF, p2TRF, 
					readMM_NET, writeMM_NET, dataBusOut_NET, addrBus_NET, 
					outMuxrs1_NET, outMuxrs2_NET, outMuxrd_NET, 
					inDataTRF_NET, writeTRF_NET, readInst_NET);

END ARCHITECTURE test;