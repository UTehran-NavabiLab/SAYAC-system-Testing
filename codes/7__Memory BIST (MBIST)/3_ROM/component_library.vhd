--******************************************************************************
--	Filename:		component_library.vhd
--	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
--  Version:		0.990
--	History:
--	Date:			26 July 2022
--	Last Author: 	HANIEH
--  Copyright (C) 2022 University of Teheran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--

--******************************************************************************
--	File content description:
--	necessary components for implementation.                            
--******************************************************************************
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
	
ENTITY nor_n IS
	PORT (
		in1  : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		out1 : OUT STD_LOGIC);
END ENTITY nor_n;

ARCHITECTURE behaviour OF nor_n IS
BEGIN
	out1 <= in1(0) NOR in1(1);
END ARCHITECTURE behaviour;
------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY nand_n IS
	PORT (
		in1  : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		out1 : OUT STD_LOGIC);
END ENTITY nand_n;

ARCHITECTURE behaviour OF nand_n IS
BEGIN
	out1 <= in1(0) NAND in1(1);
END ARCHITECTURE behaviour;
------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY notg IS
	PORT (
		in1  : IN STD_LOGIC;
		out1 : OUT STD_LOGIC);
END ENTITY notg;

ARCHITECTURE behaviour OF notg IS
BEGIN
	out1 <= NOT in1;
END ARCHITECTURE behaviour;
------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY bufg IS
	PORT (
		in1  : IN STD_LOGIC;
		out1 : OUT STD_LOGIC);
END ENTITY bufg;

ARCHITECTURE behaviour OF bufg IS
BEGIN
	out1 <= in1;
END ARCHITECTURE behaviour;
------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY pin IS
	PORT (
		in1  : IN STD_LOGIC;
		out1 : OUT STD_LOGIC);
END ENTITY pin;

ARCHITECTURE behaviour OF pin IS
BEGIN
	out1 <= in1;
END ARCHITECTURE behaviour;
------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY pout IS
	PORT (
		in1  : IN STD_LOGIC;
		out1 : OUT STD_LOGIC);
END ENTITY pout;

ARCHITECTURE behaviour OF pout IS
BEGIN
	out1 <= in1;
END ARCHITECTURE behaviour;
------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY dff IS
	PORT (
		D, C, CLR, PRE, CE, NbarT, Si, global_reset : IN STD_LOGIC;
		Q : OUT STD_LOGIC);
END ENTITY dff;

ARCHITECTURE behaviour OF dff IS
	SIGNAL tmp : STD_LOGIC;
BEGIN
	PROCESS (C, PRE, CLR, global_reset)
	BEGIN
		IF (CLR = '1' OR global_reset = '1') THEN
			tmp <= '0';
		ELSIF (PRE = '1' AND PRE'EVENT) THEN
			tmp <= '1';
		ELSIF (C = '1' AND C'EVENT) THEN
			IF NbarT = '1' THEN
				tmp <= Si;
			ELSIF CE = '1' THEN
				tmp <= D;
			END IF;
		END IF;
	END PROCESS;
	
	PROCESS (tmp)
	BEGIN
		IF (tmp = '1' AND tmp'EVENT) THEN
			Q <= tmp;
		ELSIF (tmp = '0' AND tmp'EVENT) THEN
			Q <= tmp;
		END IF;
	END PROCESS;
	
END ARCHITECTURE behaviour;
------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY dffBlock IS 
    GENERIC (Length : INTEGER := 20); 
    PORT(
	    D : IN STD_LOGIC_VECTOR (Length-1 DOWNTO 0); 
		C, CLR, PRE, CE, NbarT, Si, global_reset : IN STD_LOGIC;
		Q : OUT STD_LOGIC_VECTOR (Length-1 DOWNTO 0));
END dffBlock;
 
ARCHITECTURE str OF dffBlock IS      
    SIGNAL temp : STD_LOGIC_VECTOR (Length-1 DOWNTO 0);
    COMPONENT dff IS
        PORT(     
	        D, C, CLR, PRE, CE, NbarT, Si, global_reset : IN STD_LOGIC;
	        Q : OUT STD_LOGIC);
    END COMPONENT;
BEGIN
    for_gen : FOR i IN 0 TO Length-1 GENERATE 
		if_gen0 : IF (i = Length-1) GENERATE 
			Cel_0 : dff PORT MAP (D(i), C, CLR, PRE, CE, NbarT, Si, global_reset, temp(i));
	    END GENERATE if_gen0; 	    									   
        if_genN : IF ((i < Length-1) AND (i >= 0)) GENERATE  
            Cel_N : dff PORT MAP (D(i), C, CLR, PRE, CE, NbarT, temp(i+1), global_reset, temp(i));
        END GENERATE if_genN;									  		  
	END GENERATE for_gen;
	Q <= temp;
END str;
------------------------------------------
LIBRARY ieee;     
use IEEE.std_logic_1164.all;
USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;
use ieee.numeric_std.all;
	
ENTITY counter IS
    GENERIC ( N : INTEGER := 4);
	PORT (
		clk, rst, ld, u_d, cen : IN STD_LOGIC;
		d_in : IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
		q    : OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0);
		cout : OUT STD_LOGIC
	);
END ENTITY counter;

ARCHITECTURE behaviour OF counter IS
SIGNAL temp : STD_LOGIC_VECTOR (N DOWNTO 0) := (OTHERS=>'0');
BEGIN
	PROCESS (clk, rst) BEGIN
	    IF ( clk='1' AND clk'EVENT) THEN
            IF ( rst ='1') THEN 
                temp <= (OTHERS => '0');
            ELSIF cen = '1' THEN
                IF ld = '1' THEN 
                    temp <= '0' & d_in;
                ELSIF u_d = '1' THEN
                    temp <= temp + '1';
                ELSE 
                    temp <= temp - '1';
                END IF;
            END IF;
        END IF;
	END PROCESS;
    q <= temp (N-1 DOWNTO 0);
    cout <= temp(N);
END ARCHITECTURE behaviour;
------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------


LIBRARY ieee;     
use IEEE.std_logic_1164.all;
USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;
use ieee.numeric_std.all;
	
ENTITY decoder IS
	PORT (
		in_dec    : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		out_dec : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END ENTITY decoder;

ARCHITECTURE behaviour OF decoder IS
BEGIN
	PROCESS (in_dec)
	BEGIN
    CASE in_dec IS
        WHEN "0000" =>
        	out_dec <= "0000000000000001";
        WHEN "0001" =>
        	out_dec <= "0000000000000010";
        WHEN "0010" =>
        	out_dec <= "0000000000000100";
        WHEN "0011" =>
        	out_dec <= "0000000000001000";
        WHEN "0100" =>
        	out_dec <= "0000000000010000";
        WHEN "0101" =>
        	out_dec <= "0000000000100000";
        WHEN "0110" =>
        	out_dec <= "0000000001000000";
        WHEN "0111" =>
        	out_dec <= "0000000010000000";
        WHEN "1000" =>
        	out_dec <= "0000000100000000";
        WHEN "1001" =>
        	out_dec <= "0000001000000000";
        WHEN "1010" =>
        	out_dec <= "0000010000000000";
        WHEN "1011" =>
        	out_dec <= "0000100000000000";
        WHEN "1100" =>
    		out_dec <= "0001000000000000";
        WHEN "1101" =>
        	out_dec <= "0010000000000000";
        WHEN "1110" =>
        	out_dec <= "0100000000000000";
        WHEN "1111" =>
        	out_dec <= "1000000000000000";
        WHEN OTHERS =>
        	out_dec <= "0000000000000000";
        END CASE;
	END PROCESS;
END ARCHITECTURE behaviour;
------------------------------------------
--MISR
LIBRARY ieee;     
use IEEE.std_logic_1164.all;

ENTITY MISR IS
    GENERIC (n : INTEGER := 16);
	PORT (
		clk, rst, en : IN STD_LOGIC;
		poly, seed, d_in  : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		d_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END ENTITY MISR;

ARCHITECTURE behaviour OF MISR IS
SIGNAL data : STD_LOGIC_VECTOR (15 DOWNTO 0);
BEGIN
	PROCESS (clk, rst) BEGIN
        IF ( rst ='1') THEN 
            data <= seed;
        ELSIF ( clk='1' AND clk'EVENT) THEN
            IF en = '1' THEN
                data(15) <= ( data(0) AND poly(15) ) XOR d_in(15);
            FOR i IN 0 TO 14 LOOP
                data(i) <= ( data(0) and poly(i) ) XOR d_in(i) XOR data(i + 1);
            END LOOP;
            END IF;
        END IF;
	END PROCESS;
    d_out <= data ;--WHEN D_IN/="ZZZZZZZZZZZZZZZZ" ELSE (OTHERS=>'Z');
END ARCHITECTURE behaviour;
------------------------------------------------------------------------------------------------