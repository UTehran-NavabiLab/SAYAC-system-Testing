--******************************************************************************
--	Filename:		BS_SAYAC_CPU.vhd
--	Project:		SAYAC Testing 
--  Version:		0.1
--	History:
--	Date:			11 Nov 2022
--	Last Author: 	Shahab Karbasian
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
	    In_Pin : IN STD_LOGIC_VECTOR (16 DOWNTO 0);
	    DataBus : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		Out_Pin : OUT STD_LOGIC_VECTOR (19 DOWNTO 0);		
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
	SIGNAL  In_BS_reg, Out_BS_reg : STD_LOGIC_VECTOR (52 DOWNTO 0);	
    SIGNAL  In_CPU : STD_LOGIC_VECTOR (16 DOWNTO 0);
    SIGNAL  Out_CPU : STD_LOGIC_VECTOR (35 DOWNTO 0);
    SIGNAL  Dout_IR : STD_LOGIC_VECTOR (2 DOWNTO 0);
    SIGNAL  Sel_Mux4 : STD_LOGIC_VECTOR (1 DOWNTO 0);
	SIGNAL  Data : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL  DataTri : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL  WriteMem: STD_LOGIC;
	
    
	COMPONENT SAYAC_CPU IS
        PORT(
	        Input : IN STD_LOGIC_VECTOR (16 DOWNTO 0);	
            Output : OUT STD_LOGIC_VECTOR (35 DOWNTO 0));
    END COMPONENT;
	COMPONENT BSRegister_Block IS
	    GENERIC (Length : INTEGER := 53);
        PORT(
	        Sin,Clk,ClockDR,UpdateDR,ShiftDR : IN STD_LOGIC;
			Din : IN STD_LOGIC_VECTOR (Length-1 DOWNTO 0);
			RstBar, ModeControl : IN STD_LOGIC;
			Sout : OUT STD_LOGIC;
			Dout : OUT STD_LOGIC_VECTOR (Length-1 DOWNTO 0));
    END COMPONENT;
	COMPONENT InstructionRegister_Block IS
	    GENERIC (Length : INTEGER := 3);
	    PORT(
	        Sin, ShiftIR, UpdateIR : IN STD_LOGIC ;
			Din : IN STD_LOGIC_VECTOR (Length-1 DOWNTO 0) ;
			Clk,ClockIR, RstBar : IN STD_LOGIC ;
			Sout : OUT STD_LOGIC;
			Dout : OUT STD_LOGIC_VECTOR (Length-1 DOWNTO 0));
    END COMPONENT;
	COMPONENT ByPassRegister_Cell IS
        PORT(
	        Din,Sin,Clk,ClockDR,ShiftDR : IN STD_LOGIC;
			RstBar : IN STD_LOGIC;
			TDO : OUT STD_LOGIC);
    END COMPONENT;
	COMPONENT Decoder IS
        PORT(
	        Instruction : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
			ModeControl: OUT STD_LOGIC;		
			Select_DR  : OUT STD_LOGIC_VECTOR (1 DOWNTO 0));
    END COMPONENT;
	COMPONENT TAPController IS
        PORT(
            TMS : 	 IN STD_LOGIC;
			TCLK :   IN STD_LOGIC;
			RstBar : OUT STD_LOGIC;
			sel : 	 OUT STD_LOGIC;
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
	COMPONENT tristate_16 IS
        PORT(
            input : IN STD_LOGIC_VECTOR (15 DOWNTO 0);	
            enable : IN STD_LOGIC;	
            output : OUT STD_LOGIC_VECTOR (15 DOWNTO 0));
    END COMPONENT;	
	
		
	
BEGIN
    BS_SAYAC_Chip : SAYAC_CPU PORT MAP (In_CPU, Out_CPU); 
    BS_Reg_SAYAC : BSRegister_Block PORT MAP (TDI, TCLK, ClockDR, UpdateDR,ShiftDR, In_BS_reg,RstBar, ModeControl, Sout_BS, Out_BS_reg);
    IR_Reg : InstructionRegister_Block PORT MAP (TDI,ShiftIR, UpdateIR, "001",TCLK ,ClockIR, RstBar, Sout_IR, Dout_IR);  
    BY_Reg : ByPassRegister_Cell PORT MAP ('0', TDI, TCLK, ClockDR,ShiftDR,RstBar, Sout_BY);
    DCD : Decoder PORT MAP (Dout_IR,ModeControl, Sel_Mux4);
    TAP : TAPController PORT MAP (TMS, TCLK, RstBar, Sel_Mux2, TriEn, ShiftIR, UpdateIR, ClockIR, ShiftDR, UpdateDR, ClockDR);
	Mux4 : MUX4_1 PORT MAP ('X', 'X', Sout_BY, Sout_BS, Sel_Mux4, Out_Mux4);
	Mux2 : MUX2_1 PORT MAP (Out_Mux4, Sout_IR, Sel_Mux2, Out_Mux2);
	SynchFF : D_FF PORT MAP (Out_Mux2, NTCLK, RstBar, Out_SynchFF);
    Tri1 : tristate PORT MAP (Out_SynchFF, TriEn, TDO);
	Tri2 : tristate_16 PORT MAP (Data,WriteMem ,DataBus ); --Data in Memory bus is bidirectional
	
	NTCLK <= NOT TCLK;
    In_BS_reg <= In_Pin & Out_CPU;
	In_CPU <= Out_BS_reg (52 DOWNTO 36); 
    Out_Pin(19 DOWNTO 0) <= Out_BS_reg (35 DOWNTO 16); 
	Data <= Out_BS_reg (15 DOWNTO 0); 
	WriteMem <= Out_BS_reg (33);
END str;
  