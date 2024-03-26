--******************************************************************************
--	Filename:		RL_Decoder_TB.vhd
--	Project:		SAYAC Testing 
--  Version:		0.90
--	History:
--	Date:			18 November 2023
--	Last Author: 	Delaram
--  Copyright (C) 2023 University of Tehran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--
--******************************************************************************
--	File content description:
--	Test bench for integration of "RL_Decoder", "Synch1", and "Synch2"
--  Note that in order to use the modeules for different compressed test sets,
--  "TV_Length", "TS_Length", "CMPTS_Length", and "lcw" must be set.                              
--******************************************************************************

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.MATH_REAL.ALL; 

ENTITY RL_Decoder_TB IS
END ENTITY RL_Decoder_TB;

ARCHITECTURE test OF RL_Decoder_TB IS
    CONSTANT TV_Length    : INTEGER := 293;
    CONSTANT TS_Length    : INTEGER := 398;
    CONSTANT CMPTS_Length : INTEGER := 162687;
    CONSTANT lcw          : INTEGER := 3;
    
	SIGNAL clk      : STD_LOGIC := '0';
    SIGNAL rst      : STD_LOGIC := '0';
    SIGNAL d_in     : STD_LOGIC := '0';
    SIGNAL start    : STD_LOGIC := '0';
    SIGNAL ready    : STD_LOGIC := '0';
    SIGNAL valid    : STD_LOGIC := '0';
    SIGNAL diff_out : STD_LOGIC := '0';
    SIGNAL load     : STD_LOGIC := '0';
    SIGNAL shift    : STD_LOGIC := '0';
    SIGNAL Do       : STD_LOGIC := '0';
    
    -- SIGNAL lcw      : STD_LOGIC_VECTOR (2 DOWNTO 0) := "011";
    SIGNAL data_out : STD_LOGIC_VECTOR (TV_Length-1 DOWNTO 0);

    ALIAS END_OF_TV : STD_LOGIC IS << SIGNAL .RL_Decoder_TB.RL_Decoder_INST.DataPath.end_of_TV:STD_LOGIC>>;

BEGIN	

    RL_Decoder_INST : ENTITY WORK.RL_Decoder_TOP(TOP_ARC) 
        GENERIC MAP (TV_Length, TS_Length, lcw)
        PORT MAP (
            clk      => clk, 
            rst      => rst, 
            d_in     => d_in, 
            start    => start,
            valid    => valid,
            ready    => ready, 
            diff_out => diff_out
            );

    Synch_1_INST : ENTITY WORK.Synch1(DP_ARC)
        GENERIC MAP (CMPTS_Length) 
        PORT MAP (
            clk   => clk, 
            rst   => rst, 
            d_in  => d_in, 
            ready => ready
            );

    CSC_INST : ENTITY WORK.CSR(ARCH) 
        GENERIC MAP (TV_Length)
        PORT MAP (
            clk           => clk, 
            rst           => rst, 
            diff_in       => diff_out, 
            load          => load, 
            shift         => shift, 
            initial_value => (OTHERS => '0'), 
            data_out      => data_out, 
            So            => Do
            );

    shift <= '1' WHEN valid = '1' ELSE '0';
  
    clk <= NOT clk AFTER 1 NS;

    PROCESS BEGIN
        rst <= '1';
        WAIT FOR 3 NS;
        rst <= '0';
        WAIT FOR 3 NS;
        start <= '1';
        WAIT FOR 4 NS;
        start <= '0';
        WAIT;
    END PROCESS;
         
    -- writing the decompressed test vctors into a text file
    PROCESS (rst, END_OF_TV) 
        FILE TV_FILE : text OPEN WRITE_MODE IS "Decompressed_TVs.txt";
        VARIABLE R_LINE : LINE;
        VARIABLE str : string(1 TO TV_Length);
    BEGIN
        IF (rst'EVENT) THEN
        ELSIF(END_OF_TV='0' AND END_OF_TV'EVENT) THEN
            str :=  (OTHERS => ' ');
            str(1 TO TV_Length) := to_string(data_out);
            WRITE(R_LINE, str);
            writeline(TV_FILE, R_LINE);
        END IF;
    END PROCESS;

END ARCHITECTURE test;