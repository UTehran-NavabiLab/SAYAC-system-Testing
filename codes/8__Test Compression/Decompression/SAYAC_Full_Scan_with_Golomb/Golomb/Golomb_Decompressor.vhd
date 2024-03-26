--******************************************************************************
--	Filename:		Golomb_Decompressor.vhd
--	Project:		SAYAC Testing 
--  Version:		0.90
--	History:
--	Date:			11 November 2023
--	Last Author: 	Delaram
--  Copyright (C) 2023 University of Tehran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--
--******************************************************************************
--	File content description:
--  Integration of "Golomb_Decoder", "Synch1", and "Synch2" 
--******************************************************************************

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;

ENTITY Golomb_Decompressor IS
    GENERIC (
        TV_Length    : INTEGER := 293;
        TS_Length    : INTEGER := 398;
        CMPTS_Length : INTEGER := 163610
        );
    PORT(
        clk:IN STD_LOGIC;
        rst:IN STD_LOGIC;
        tester_clk:IN STD_LOGIC;
        start : IN STD_LOGIC;
        valid : OUT STD_LOGIC;
        data_out : OUT STD_LOGIC_VECTOR (TV_Length-1 DOWNTO 0);
        Do : OUT STD_LOGIC
    );
END ENTITY Golomb_Decompressor;

ARCHITECTURE ARCH OF Golomb_Decompressor IS
	SIGNAL d_in       : STD_LOGIC := '0';
    SIGNAL ready      : STD_LOGIC := '0';
    SIGNAL diff_out   : STD_LOGIC := '0';
    SIGNAL load       : STD_LOGIC := '0';
    SIGNAL shift      : STD_LOGIC := '0';
    SIGNAL valid_wire : STD_LOGIC := '0';
    SIGNAL m_input    : STD_LOGIC_VECTOR (2 DOWNTO 0) := "100"; -- m is 4
BEGIN	
    Synch_1_INST : ENTITY WORK.Synch1(DP_ARC) 
        GENERIC MAP (CMPTS_Length)    
        PORT MAP (
            clk   => clk, 
            rst   => rst, 
            d_in  => d_in, 
            ready => ready
            );

    Golomb_Decoder_INST : ENTITY WORK.Golomb_Decoder_TOP(TOP_ARC) 
        GENERIC MAP (TV_Length, TS_Length)
        PORT MAP (
            clk            => clk,
            rst            => rst, 
            d_in           => d_in, 
            start          => start,
            m_input        => m_input, 
            valid          => valid_wire,
            ready          => ready, 
            difference_out => diff_out
            );

    Synch_2_INST : ENTITY WORK.Synch2(ARC) 
        GENERIC MAP (TV_Length)    
        PORT MAP (
            tester_clk => tester_clk, 
            rst        => rst,
            valid      => valid_wire,
            diff_in    => diff_out,
            shift      => shift,
            data_out   => data_out,
            Do         => Do
            );

    load <= '0';
    shift <= '1' WHEN valid_wire = '1' ELSE '0';
    valid <= valid_wire;
END ARCHITECTURE ARCH;