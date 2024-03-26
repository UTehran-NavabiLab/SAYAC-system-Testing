--******************************************************************************
--	Filename:		Golomb_Decoder_TB.vhd
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
--	Test bench for integration of "Golomb_Decoder", "Synch1", and "Synch2"
--  Note that in order to use the modeules for different compressed test sets,
--  "TV_Length", "TS_Length", "CMPTS_Length", and "lcw" must be set.                              
--******************************************************************************

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;

ENTITY Golomb_Decoder_TB IS
END ENTITY Golomb_Decoder_TB;

ARCHITECTURE test OF Golomb_Decoder_TB IS
    CONSTANT TV_Length    : INTEGER := 293;
    CONSTANT TS_Length    : INTEGER := 398;
    CONSTANT CMPTS_Length : INTEGER := 163610;

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
    SIGNAL m_input  : STD_LOGIC_VECTOR (2 DOWNTO 0) := "100"; -- m is 4
    SIGNAL data_out : STD_LOGIC_VECTOR (TV_Length-1 DOWNTO 0);

    ALIAS END_OF_TV : STD_LOGIC IS << SIGNAL .Golomb_Decoder_TB.Golomb_Decoder_INST.DataPath.end_of_TV:STD_LOGIC>>;
    ALIAS END_OF_TS : STD_LOGIC IS << SIGNAL .Golomb_Decoder_TB.Golomb_Decoder_INST.DataPath.end_of_TS:STD_LOGIC>>;

BEGIN	

    Synch_1_INST : ENTITY WORK.Synch1(DP_ARC) 
        GENERIC MAP (CMPTS_Length)
        PORT MAP(
            clk   => clk, 
            rst   => rst, 
            d_in  => d_in, 
            ready => ready
            );
        
    Golomb_Decoder_INST : ENTITY WORK.Golomb_Decoder_TOP(TOP_ARC) 
        GENERIC MAP (TV_Length, TS_Length)
        PORT MAP(
            clk            => clk, 
            rst            => rst, 
            d_in           => d_in, 
            start          => start,
            m_input        => m_input,
            valid          => valid,
            ready          => ready, 
            difference_out => diff_out
            );

    CSC_INST : ENTITY WORK.CSR(ARCH) 
        GENERIC MAP (TV_Length) 
        PORT MAP(
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
        load <= '0';
        WAIT FOR 3 NS;
        rst <= '0';
        WAIT FOR 3 NS;
        WAIT FOR 30 NS;
        start <= '1';
        WAIT FOR 10 NS;
        start <= '0';
        wait;
    END PROCESS;

    -- write the decompressed TVs into a text file
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