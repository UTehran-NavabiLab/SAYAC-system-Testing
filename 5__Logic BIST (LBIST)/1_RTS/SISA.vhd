--******************************************************************************
--	Filename:		SISA.vhd
--	Project:		SAYAC Testing 
--  Version:		0.90
--	History:
--	Date:			20 June 2022
--	Last Author: 	Delaram Mohammadzadeh
--  Copyright (C) 2022 University of Tehran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--
--******************************************************************************
--	File content description:
--	SISA (Serial Input Signature Analyzer) ‎                               
--******************************************************************************

LIBRARY ieee;     
use IEEE.std_logic_1164.all;

ENTITY SISA IS
    GENERIC (n : INTEGER := 8);
	PORT (
		clk, rst, en : IN STD_LOGIC;
		poly, seed  : IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
		Sin : IN STD_LOGIC;
		data : OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
	);
END ENTITY SISA;

ARCHITECTURE behaviour OF SISA IS
SIGNAL data_temp : STD_LOGIC_VECTOR (n-1 DOWNTO 0);
SIGNAL test_data : STD_LOGIC_VECTOR (23 DOWNTO 0);
BEGIN
	PROCESS (clk, rst) BEGIN
        IF ( rst ='1') THEN 
            data_temp <= seed;
        ELSIF ( clk='1' AND clk'EVENT) THEN
            IF en = '1' THEN
                data_temp(n-1) <= data_temp(0) XOR Sin;
            FOR i IN 0 TO n-2 LOOP
                data_temp(i) <= ( data_temp(0) AND poly(i) ) XOR data_temp(i + 1);
            END LOOP;
            END IF;
        END IF;
	END PROCESS;

    PROCESS (clk) BEGIN
        IF ( clk='1' AND clk'EVENT) THEN
            IF ( rst ='1') THEN 
                test_data <= (OTHERS=>'0');
            END IF;
            
            IF en = '1' THEN
            FOR i IN 0 TO 22 LOOP
                test_data(i) <= test_data(i + 1);
            END LOOP;
            test_data(23) <= Sin;
            END IF;
        END IF;
	END PROCESS;

    data <= data_temp;
END ARCHITECTURE behaviour;
------------------------------------------------------------------------------------------------