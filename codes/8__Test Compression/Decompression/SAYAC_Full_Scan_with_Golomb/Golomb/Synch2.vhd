--******************************************************************************
--	Filename:		Synch2.vhd
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
--	Second Synchronizer for Golomb Decompression                   
--******************************************************************************

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;

ENTITY Synch2 IS    
    GENERIC (TV_Length : INTEGER := 293);
    PORT(
        tester_clk : IN STD_LOGIC;
        rst        : IN STD_LOGIC;
        valid      : IN STD_LOGIC;
        diff_in    : IN STD_LOGIC;
        shift      : IN STD_LOGIC;
        data_out   : OUT STD_LOGIC_VECTOR (TV_Length-1 DOWNTO 0);
        Do         : OUT STD_LOGIC
   );
   END ENTITY Synch2;
   
ARCHITECTURE ARC OF Synch2 IS
    SIGNAL load : STD_LOGIC := '0';    
BEGIN 
    CSC_INSTANCE : ENTITY WORK.CSR(ARCH) 
        GENERIC MAP (TV_Length)
        PORT MAP (
            clk           => tester_clk,
            rst           => rst, 
            diff_in       => diff_in, 
            load          => load, 
            shift         => shift, 
            initial_value => (OTHERS => '0'), 
            data_out      => data_out, 
            So            => Do
        );
END ARCHITECTURE ARC;