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
--	TOP level logic (LGC) of the SAYAC core                                 
--******************************************************************************

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY LGC IS
	PORT (
		clk, rst : IN STD_LOGIC;
		readyMEM : IN STD_LOGIC;
		dataBusIn : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		p1TRF, p2TRF : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		readMM, writeMM : OUT STD_LOGIC;
		dataBusOut, addrBus : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		outMuxrs1, outMuxrs2, outMuxrd : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		inDataTRF : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		writeTRF : OUT STD_LOGIC;
		readInst : OUT STD_LOGIC
	);
END ENTITY LGC;

ARCHITECTURE behaviour OF LGC IS
	SIGNAL opcode : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL seldataBus_TRF, selPC1_TRF, selLLU_TRF, selSHU_TRF, 
		   selASU_TRF, selMDU1_TRF, selMDU2_TRF, selIMM_TRF : STD_LOGIC;
    SIGNAL selrs1_TRF, selrd_1_TRF, selrs2_TRF, selrd_2_TRF : STD_LOGIC;
	SIGNAL selrd0_TRF, selrd1_TRF : STD_LOGIC;
	SIGNAL selp1_PCP, selimm_PCP : STD_LOGIC;
    SIGNAL selPC_MEM, selp1_PC, selPCadd_PC, selPC1_PC : STD_LOGIC;
    SIGNAL selADR_MEM, driveDataBus : STD_LOGIC;
    SIGNAL SE5bits, SE6bits, USE8bits, SE8bits, p1lowbits : STD_LOGIC;
    SIGNAL selp2_ASU, selimm_ASU, arithADD, arithSUB : STD_LOGIC;
    SIGNAL logicAND, onesComp, twosComp : STD_LOGIC;
    SIGNAL selp2_SHU, selshim_SHU, logicSH, arithSH : STD_LOGIC;
    SIGNAL ldMDU1, ldMDU2, arithMUL, arithDIV, startMDU : STD_LOGIC;
    SIGNAL ldIR, ldADR, ldPC : STD_LOGIC;
	SIGNAL readyMDU : STD_LOGIC;
	SIGNAL FIB     : STD_LOGIC_VECTOR(4 DOWNTO 0);  --FLags Intrepretation Bits
	SIGNAL setFlags, enFlag : STD_LOGIC;
	SIGNAL outFlag : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL selFlag : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL readMEM, writeMEM, readIO, writeIO : STD_LOGIC;
BEGIN
	DataPath : ENTITY WORK.DPU PORT MAP 
					(clk => clk, rst => rst,
					seldataBus_TRF => seldataBus_TRF, selPC1_TRF => selPC1_TRF,  
					selLLU_TRF => selLLU_TRF, selSHU_TRF => selSHU_TRF, 
					selASU_TRF => selASU_TRF, selMDU1_TRF => selMDU1_TRF,  
					selMDU2_TRF => selMDU2_TRF, selIMM_TRF => selIMM_TRF, 
					selrs1_TRF => selrs1_TRF, selrd_1_TRF => selrd_1_TRF,  
					selrs2_TRF => selrs2_TRF, selrd_2_TRF => selrd_2_TRF, 
					selrd0_TRF => selrd0_TRF, selrd1_TRF => selrd1_TRF, 
					selp1_PCP => selp1_PCP, selimm_PCP => selimm_PCP, selp1_PC => selp1_PC, 
					selPCadd_PC => selPCadd_PC, selPC1_PC => selPC1_PC,  
					selPC_MEM => selPC_MEM, selADR_MEM => selADR_MEM,  
					driveDataBus => driveDataBus, SE5bits => SE5bits, SE6bits => SE6bits, 
					USE8bits => USE8bits, SE8bits => SE8bits, p1lowbits => p1lowbits,  
					selp2_ASU => selp2_ASU, selimm_ASU => selimm_ASU, arithADD => arithADD, 
					arithSUB => arithSUB, logicAND => logicAND, onesComp => onesComp,  
					twosComp => twosComp, selp2_SHU => selp2_SHU, selshim_SHU => selshim_SHU,  
					logicSH => logicSH, arithSH => arithSH, ldMDU1 => ldMDU1, ldMDU2 => ldMDU2, 
					arithMUL => arithMUL, arithDIV => arithDIV, startMDU => startMDU,  
					ldIR => ldIR, ldADR => ldADR, ldPC => ldPC, 
					readyMDU => readyMDU, opcode => opcode, FIB => FIB, setFlags => setFlags, 
					enFlag => enFlag, selFlag => selFlag, outFlag => outFlag, 
					dataBusIn => dataBusIn, addrBus => addrBus, dataBusOut => dataBusOut,
					outMuxrs1 => outMuxrs1, outMuxrs2 => outMuxrs2, outMuxrd => outMuxrd, 
					inDataTRF => inDataTRF,
					p1TRF => p1TRF, p2TRF => p2TRF);
	
	Controller : ENTITY WORK.CCU PORT MAP 
					(clk => clk, rst => rst, readyMEM => readyMEM, readyMDU => readyMDU, 
					opcode => opcode, FIB => FIB, seldataBus_TRF => seldataBus_TRF,  
					selPC1_TRF => selPC1_TRF, selLLU_TRF => selLLU_TRF,  
					selSHU_TRF => selSHU_TRF, selASU_TRF => selASU_TRF,  
					selMDU1_TRF => selMDU1_TRF, selMDU2_TRF => selMDU2_TRF,  
					selIMM_TRF => selIMM_TRF, selrs1_TRF => selrs1_TRF,  
					selrd_1_TRF => selrd_1_TRF, selrs2_TRF => selrs2_TRF,  
					selrd_2_TRF => selrd_2_TRF, selrd0_TRF => selrd0_TRF,  
					selrd1_TRF => selrd1_TRF, writeTRF => writeTRF, selp1_PCP => selp1_PCP, 
					selimm_PCP => selimm_PCP, selp1_PC => selp1_PC,  
					selPCadd_PC => selPCadd_PC, selPC1_PC => selPC1_PC,  
					selPC_MEM => selPC_MEM, selADR_MEM => selADR_MEM,  
					driveDataBus => driveDataBus, SE5bits => SE5bits, SE6bits => SE6bits, 
					USE8bits => USE8bits, SE8bits => SE8bits, p1lowbits => p1lowbits, 
					selp2_ASU => selp2_ASU, selimm_ASU => selimm_ASU, arithADD => arithADD, 
					arithSUB => arithSUB, logicAND => logicAND, onesComp => onesComp,  
					twosComp => twosComp, selp2_SHU => selp2_SHU, selshim_SHU => selshim_SHU,  
					logicSH => logicSH, arithSH => arithSH, ldMDU1 => ldMDU1, ldMDU2 => ldMDU2,  
					arithMUL => arithMUL, arithDIV => arithDIV, startMDU => startMDU, 
					ldIR => ldIR, ldADR => ldADR, ldPC => ldPC, readMEM => readMEM,  
					writeMEM => writeMEM, readIO => readIO, writeIO => writeIO, 
					setFlags => setFlags, enFlag => enFlag, 
					outFlag => outFlag, selFlag => selFlag);
	
	readInst <= selPC_MEM;
	
	-- Address Decoder
	readMM  <= readMEM OR readIO;
	writeMM <= writeMEM OR writeIO;
	
END ARCHITECTURE behaviour;
