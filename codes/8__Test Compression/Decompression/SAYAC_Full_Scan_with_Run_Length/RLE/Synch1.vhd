--******************************************************************************
--	Filename:		Synch1.vhd
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
--	First Synchronizer for RL Decompression                              
--******************************************************************************

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;

ENTITY Synch1 IS
    GENERIC (CMPTS_Length : INTEGER := 162687);
    PORT(
        clk   : IN STD_LOGIC;
        rst   : IN STD_LOGIC;
        ready : IN STD_LOGIC;
        d_in  : OUT STD_LOGIC
    );
   END ENTITY Synch1;
   
ARCHITECTURE DP_ARC OF Synch1 IS
BEGIN
    PROCESS (clk, rst, ready)
        FILE file_pointer : TEXT;
        VARIABLE line_content : STD_LOGIC_VECTOR(CMPTS_Length-1 DOWNTO 0);
        VARIABLE internal : STD_LOGIC_VECTOR(CMPTS_Length-1 DOWNTO 0);
        VARIABLE line_num : LINE; 
        BEGIN
            IF (clk='1' AND clk'EVENT) THEN
                IF (rst = '1') THEN
                    FILE_OPEN(file_pointer,"CompressedTV.txt",READ_MODE);
                    READLINE(file_pointer, line_num); 
                    READ(line_num, line_content);
                    internal := line_content;
                    FILE_CLOSE(file_pointer);
                END IF;
                IF (ready = '1') THEN
                internal := '0' & line_content(CMPTS_Length-1 DOWNTO 1); --shift right
                line_content := internal;
                END IF;
                d_in <= line_content(0);
            END IF;
        END PROCESS;
END ARCHITECTURE DP_ARC;
