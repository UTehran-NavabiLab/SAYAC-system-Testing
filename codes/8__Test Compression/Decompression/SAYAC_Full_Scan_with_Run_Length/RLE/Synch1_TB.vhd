--******************************************************************************
--	Filename:		Synch1_TB.vhd
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
--	A simple test bench for "Synch1" module                             
--******************************************************************************


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.MATH_REAL.ALL; 

ENTITY Synch1_TB IS
END ENTITY Synch1_TB;

ARCHITECTURE test OF Synch1_TB IS
    CONSTANT CMPTS_Length : INTEGER := 162687;

	SIGNAL clk   : STD_LOGIC := '0';
    SIGNAL rst   : STD_LOGIC := '0';
    SIGNAL d_in  : STD_LOGIC := '0';
    SIGNAL start : STD_LOGIC := '0';
    SIGNAL ready : STD_LOGIC := '0';

BEGIN	

    Synch_1_INST : ENTITY WORK.Synch1(DP_ARC)
        GENERIC MAP (CMPTS_Length) 
        PORT MAP (
            clk   => clk, 
            rst   => rst, 
            d_in  => d_in, 
            ready => ready
            );

    clk <= NOT clk AFTER 1 NS;

    PROCESS    BEGIN
        rst <= '1';
        WAIT FOR 3 NS;
        rst <= '0';
        WAIT UNTIL clk = '1';
        WAIT UNTIL clk = '1';
        ready <='1';
        WAIT UNTIL clk = '1';
        WAIT UNTIL clk = '1';
        WAIT UNTIL clk = '1';
        WAIT UNTIL clk = '1';
        ready <= '0';
        WAIT;  
    END PROCESS;
END ARCHITECTURE test;