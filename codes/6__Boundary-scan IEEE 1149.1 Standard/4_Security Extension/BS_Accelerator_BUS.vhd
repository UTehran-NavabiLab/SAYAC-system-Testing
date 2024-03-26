--******************************************************************************
--	Filename:		BS_Accelerator_BUS.vhd
--	Project:		Security extension for IEEE Std 1149.1  
--  Version:		0.91
--	History:
--	Date:			17 Nov 2022
--	Last Author: 	Shahab Karbasian
--  Copyright (C) 2022 University of Tehran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--
--******************************************************************************
--	File content description:
--	Fictitious bus accelerator compliant with IEEE Std 1149.1                         
--******************************************************************************

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_arith.ALL;
USE IEEE.STD_LOGIC_unsigned.ALL;

ENTITY BS_Accelerator_BUS IS 
    PORT(
	    TCLK, TMS, TDI : IN STD_LOGIC;
	    In_Pin : IN STD_LOGIC_VECTOR (35 DOWNTO 0);
	    Out_Pin : OUT STD_LOGIC_VECTOR (16 DOWNTO 0);
	    TDO : OUT STD_LOGIC);
END BS_Accelerator_BUS;

ARCHITECTURE str OF BS_Accelerator_BUS IS 
    SIGNAL  ShiftIR, UpdateIR, ClockIR : STD_LOGIC;
    SIGNAL  ShiftDR, UpdateDR, ClockDR : STD_LOGIC;
    SIGNAL  ShiftBR, UpdateBR, ClockBR : STD_LOGIC;
    SIGNAL  ShiftBY, ClockBY : STD_LOGIC;
    SIGNAL  RstBar, ModeControl : STD_LOGIC;
	SIGNAL  En_KLSR,En_KR,En_LR,TDO_SE,UpdateKL,ShiftKL,Locked : STD_LOGIC;
    SIGNAL  Sout_IR, Sout_BS, Sout_BY : STD_LOGIC;
    SIGNAL  Sel_Mux2, TriEn, Out_Mux4, Out_Mux2, Out_SynchFF, NTCLK : STD_LOGIC;   
	SIGNAL  In_BS_reg, Out_BS_reg : STD_LOGIC_VECTOR (52 DOWNTO 0);	
    SIGNAL  In_Acc_BUS : STD_LOGIC_VECTOR (35 DOWNTO 0);
    SIGNAL  Out_Acc_BUS : STD_LOGIC_VECTOR (16 DOWNTO 0);
    SIGNAL  Dout_IR : STD_LOGIC_VECTOR (2 DOWNTO 0);
    SIGNAL  Sel_Mux4 : STD_LOGIC_VECTOR (1 DOWNTO 0);
    
    COMPONENT Accelerator_BUS IS
        PORT(
	        Input : IN STD_LOGIC_VECTOR (35 DOWNTO 0);
	        Output : OUT STD_LOGIC_VECTOR (16 DOWNTO 0));
    END COMPONENT;
	COMPONENT BSRegister_Block IS
	    GENERIC (Length : INTEGER := 53);
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
	        ShiftDR, ClockDR, UpdateDR,Locked : IN STD_LOGIC;
	        ShiftBY, ClockBY : OUT STD_LOGIC;
	        ShiftBR, ClockBR, UpdateBR, ModeControl,En_KLSR,En_KR,En_LR,ShiftKL,UpdateKL : OUT STD_LOGIC;
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
	COMPONENT MUX4_1 is
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
	COMPONENT  SecurityExtension IS 
    GENERIC (Length : INTEGER := 8); 
    PORT(
	    TDI,UpdateDR,shiftDR,CaptureDR,ClockDR,En_KLSR,En_KR,En_LR : IN STD_LOGIC;
		TDO, Locked :out STD_LOGIC);
    END COMPONENT;	
		
	
	
BEGIN
	BS_Acc_BUS_Chip : Accelerator_BUS PORT MAP (In_Acc_BUS, Out_Acc_BUS); 
	BS_Reg_Acc_BUS : BSRegister_Block PORT MAP (TDI, TCLK, ShiftBR, UpdateBR, In_BS_reg, ClockBR, RstBar, ModeControl, Sout_BS, Out_BS_reg);
	IR_Reg : InstructionRegister_Block PORT MAP (TDI, TCLK, ShiftIR, UpdateIR, "001", ClockIR, RstBar, Sout_IR, Dout_IR);
	BY_Reg : ByPassRegister_Cell PORT MAP ('0', TDI, TCLK, ShiftBY, ClockBY, RstBar, Sout_BY);
	DCD : Decoder PORT MAP (Dout_IR, ShiftDR, ClockDR, UpdateDR,Locked, ShiftBY, ClockBY, ShiftBR, ClockBR, UpdateBR, ModeControl,En_KLSR,En_KR,En_LR,ShiftKL,UpdateKL, Sel_Mux4);
	TAP : TAPController PORT MAP (TMS, TCLK, RstBar, Sel_Mux2, TriEn, ShiftIR, UpdateIR, ClockIR, ShiftDR, UpdateDR, ClockDR);  
	Mux4 : MUX4_1 PORT MAP ('X',TDO_SE, Sout_BY, Sout_BS, Sel_Mux4, Out_Mux4);
	Mux2 : MUX2_1 PORT MAP (Out_Mux4, Sout_IR, Sel_Mux2, Out_Mux2);	
	SynchFF : D_FF PORT MAP (Out_Mux2, NTCLK, RstBar, Out_SynchFF);
	Tri : tristate PORT MAP (Out_SynchFF, TriEn, TDO);
	SE  : SecurityExtension PORT MAP(TDI,UpdateKL,ShiftKL,'1',TCLK,En_KLSR,En_KR,En_LR,TDO_SE,Locked);

	NTCLK <= NOT TCLK;
	In_BS_reg <= In_Pin & Out_Acc_BUS;
	Out_BS_reg (52 DOWNTO 17) <= In_Acc_BUS;
	Out_Pin <= Out_BS_reg (16 DOWNTO 0); 
END str; 
  