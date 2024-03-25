--******************************************************************************
--	Filename:		Golomb_Decompressor_TB.vhd
--	Project:		SAYAC Testing
--  Version:		0.990
--	History:
--	Date:			11 November 2023
--	Last Author: 	Delaram
--  Copyright (C) 2023 University of Teheran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--

--******************************************************************************
--	File content description:
--	Test bench for "Golomb_Decompressor" module 
--  Note that the constants "TV_Length", "TS_Length", and "CMPTS_Length" 
--  must be set appropriately.  
--******************************************************************************

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;

ENTITY Golomb_Decompressor_TB IS
END ENTITY Golomb_Decompressor_TB;

ARCHITECTURE test OF Golomb_Decompressor_TB IS
    CONSTANT TV_Length    : INTEGER := 293;
    CONSTANT TS_Length    : INTEGER := 398;
    CONSTANT CMPTS_Length : INTEGER := 163610;

    SIGNAL clk      : STD_LOGIC := '0';
    SIGNAL rst      : STD_LOGIC := '0';
    SIGNAL start    : STD_LOGIC := '0';
    SIGNAL valid    : STD_LOGIC := '0';
    SIGNAL Do       : STD_LOGIC := '0';
    SIGNAL data_out : STD_LOGIC_VECTOR (TV_Length-1 DOWNTO 0);

    ALIAS END_OF_TV : STD_LOGIC IS << SIGNAL .Golomb_Decompressor_TB.Golomb_Decompressor_INST.Golomb_Decoder_INST.DataPath.end_of_TV:STD_LOGIC>>;
    ALIAS END_OF_TS : STD_LOGIC IS << SIGNAL .Golomb_Decompressor_TB.Golomb_Decompressor_INST.Golomb_Decoder_INST.DataPath.end_of_TS:STD_LOGIC>>;

BEGIN	

    Golomb_Decompressor_INST : ENTITY WORK.Golomb_Decompressor(ARCH) 
        GENERIC MAP (TV_Length, TS_Length, CMPTS_Length) 
        PORT MAP (
            clk        => clk,
            tester_clk => clk, 
            rst        => rst, 
            start      => start,
            valid      => valid,
            data_out   => data_out, 
            Do         => Do
            );
    
    clk <= NOT clk AFTER 1 NS;

    PROCESS BEGIN
        rst <= '1';
        WAIT FOR 3 NS;
        rst <= '0';
        WAIT FOR 3 NS;
        WAIT FOR 30 NS;
        start <= '1';
        WAIT FOR 10 NS;
        start <= '0';
        wait;
    END PROCESS;

    -- write the decompressed TVs into a tet file
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