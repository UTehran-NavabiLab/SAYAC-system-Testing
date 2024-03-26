--******************************************************************************
--	Filename:		BS_SAYAC_CPU.vhd
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
--	SAYAC compliant with IEEE Std 1149.1                         
--******************************************************************************

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;
 
ENTITY BS_SAYAC_CPU IS 
    PORT(
	    TCLK, TMS, TDI : IN STD_LOGIC;
		ClkCUT, RstCUT : IN STD_LOGIC; 
	    In_Pin  : IN  STD_LOGIC_VECTOR (48 DOWNTO 0);
	    Out_Pin : OUT STD_LOGIC_VECTOR (63 DOWNTO 0);
	    TDO : OUT STD_LOGIC);
END BS_SAYAC_CPU;

ARCHITECTURE str OF BS_SAYAC_CPU IS 
	SIGNAL  ShiftIR, UpdateIR, ClockIR : STD_LOGIC;
    SIGNAL  ShiftDR, UpdateDR, ClockDR : STD_LOGIC;
    SIGNAL  ShiftBR, UpdateBR, ClockBR : STD_LOGIC;
    SIGNAL  ShiftBY, ClockBY : STD_LOGIC;
    SIGNAL  RstBar, ModeControl : STD_LOGIC;
    SIGNAL  Sout_IR, Sout_BS, Sout_BY : STD_LOGIC;
    SIGNAL  Sel_Mux2, TriEn, Out_Mux4, Out_Mux2, Out_SynchFF, NTCLK : STD_LOGIC;
	SIGNAL  Si_SAYAC_Logic, So_SAYAC_Logic : STD_LOGIC;	
    SIGNAL  In_CPU : STD_LOGIC_VECTOR (48 DOWNTO 0);
    SIGNAL  Out_CPU : STD_LOGIC_VECTOR (63 DOWNTO 0);
    SIGNAL  Dout_IR : STD_LOGIC_VECTOR (2 DOWNTO 0);
    SIGNAL  Sel_Mux4 : STD_LOGIC_VECTOR (1 DOWNTO 0);
    
	COMPONENT BSRegister_Block IS
	    GENERIC (Length : INTEGER := 20);
        PORT(
	        Sin, TCLK, ShiftBR, UpdateBR : IN STD_LOGIC;
	        Din : IN STD_LOGIC_VECTOR (Length-1 DOWNTO 0);
	        ClockBR, RstBar, ModeControl : IN STD_LOGIC;
	        Sout : OUT STD_LOGIC;
	        Dout : OUT STD_LOGIC_VECTOR (Length-1 DOWNTO 0));
    END COMPONENT;
	COMPONENT InstructionRegister_Block IS
	    GENERIC (Length : INTEGER := 3);
	    PORT(
	        Sin, TCLK, ShiftIR, UpdateIR : IN STD_LOGIC;
	        Din : IN STD_LOGIC_VECTOR (Length-1 DOWNTO 0);
	        ClockIR, RstBar : IN STD_LOGIC;
	        Sout : OUT STD_LOGIC;
	        Dout : OUT STD_LOGIC_VECTOR (Length-1 DOWNTO 0));
    END COMPONENT;
	COMPONENT ByPassRegister_Cell IS
        PORT(
	        Din, Sin, TCLK, ShiftBY : IN STD_LOGIC;
	        ClockBY, RstBar : IN STD_LOGIC;
	        TDO : OUT STD_LOGIC);
    END COMPONENT;
	COMPONENT Decoder IS
        PORT(
	        Instruction : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
	        ShiftDR, ClockDR, UpdateDR : IN STD_LOGIC;
	        ShiftBY, ClockBY : OUT STD_LOGIC;
	        ShiftBR, ClockBR, UpdateBR, ModeControl : OUT STD_LOGIC;
	        Select_DR : OUT STD_LOGIC_VECTOR (1 DOWNTO 0));
    END COMPONENT;
	COMPONENT TAPController IS
        PORT(
            TMS : IN STD_LOGIC;
	        TCLK : IN STD_LOGIC;
	        RstBar : OUT STD_LOGIC;
	        sel : OUT STD_LOGIC;
	        Enable : OUT STD_LOGIC;
	        ShiftIR, UpdateIR, ClockIR : OUT STD_LOGIC;
	        ShiftDR, UpdateDR, ClockDR : OUT STD_LOGIC);
    END COMPONENT;
	COMPONENT MUX4_1 IS
        PORT(
            in1, in2, in3, in4 : IN STD_LOGIC;
	        sel : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
	        output : OUT STD_LOGIC);
    END COMPONENT;
	COMPONENT MUX2_1 IS
        PORT(
	        in1, in2, sel : IN STD_LOGIC;
  	        output : OUT STD_LOGIC);
    END COMPONENT;
	COMPONENT D_FF IS
        PORT(
	        D, CLK, RstBar : IN STD_LOGIC;
	        Q : OUT STD_LOGIC);
    END COMPONENT;
	COMPONENT tristate IS
        PORT(
            input : IN STD_LOGIC;	
            enable : IN STD_LOGIC;	
            output : OUT STD_LOGIC);
    END COMPONENT;
	
BEGIN
	SAYAC_Logic : ENTITY WORK.LGC_Netlist 
	PORT MAP (
		clk 		=> ClkCUT, 								
		rst 		=> RstCUT, 
		dataBusIn 	=> In_CPU(15 DOWNTO 0 ),
		p1TRF 		=> In_CPU(31 DOWNTO 16),
		p2TRF 		=> In_CPU(47 DOWNTO 32),
		readyMEM 	=> In_CPU(48),
		ShiftBR 	=> ShiftBR,
		UpdateBR 	=> UpdateBR,
		ClockBR 	=> ClockBR,
		ModeControl => ModeControl,
		Si			=> Si_SAYAC_Logic,
		So 			=> So_SAYAC_Logic,
		addrBus 	=> Out_CPU(15 DOWNTO 0 ),
		dataBusOut 	=> Out_CPU(31 DOWNTO 16),
		inDataTRF 	=> Out_CPU(47 DOWNTO 32),
		outMuxrd  	=> Out_CPU(51 DOWNTO 48),
		outMuxrs1 	=> Out_CPU(55 DOWNTO 52),
		outMuxrs2 	=> Out_CPU(59 DOWNTO 56),
		readInst 	=> Out_CPU(60),
		readMM		=> Out_CPU(61),
		writeMM 	=> Out_CPU(62),
		writeTRF 	=> Out_CPU(63)			
	);
    BS_Reg_InSAYAC  : BSRegister_Block GENERIC MAP (49) PORT MAP (TDI, TCLK, ShiftBR, UpdateBR, In_Pin, ClockBR, RstBar, ModeControl, Si_SAYAC_Logic, In_CPU);
    BS_Reg_OutSAYAC : BSRegister_Block GENERIC MAP (64) PORT MAP (So_SAYAC_Logic, TCLK, ShiftBR, UpdateBR, Out_CPU, ClockBR, RstBar, ModeControl, Sout_BS, Out_Pin);
	IR_Reg : InstructionRegister_Block GENERIC MAP (3)  PORT MAP (TDI, TCLK, ShiftIR, UpdateIR, "001", ClockIR, RstBar, Sout_IR, Dout_IR);  
    BY_Reg : ByPassRegister_Cell PORT MAP ('0', TDI, TCLK, ShiftBY, ClockBY, RstBar, Sout_BY);
    DCD : Decoder PORT MAP (Dout_IR, ShiftDR, ClockDR, UpdateDR, ShiftBY, ClockBY, ShiftBR, ClockBR, UpdateBR, ModeControl, Sel_Mux4);
    TAP : TAPController PORT MAP (TMS, TCLK, RstBar, Sel_Mux2, TriEn, ShiftIR, UpdateIR, ClockIR, ShiftDR, UpdateDR, ClockDR);
	Mux4 : MUX4_1 PORT MAP ('X', 'X', Sout_BY, Sout_BS, Sel_Mux4, Out_Mux4);
	Mux2 : MUX2_1 PORT MAP (Out_Mux4, Sout_IR, Sel_Mux2, Out_Mux2);
	SynchFF : D_FF PORT MAP (Out_Mux2, NTCLK, RstBar, Out_SynchFF);
    Tri : tristate PORT MAP (Out_SynchFF, TriEn, TDO);

	NTCLK <= NOT TCLK;
 
END str;
  