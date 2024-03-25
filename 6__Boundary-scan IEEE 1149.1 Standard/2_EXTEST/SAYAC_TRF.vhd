--******************************************************************************
--	Filename:		SAYAC_TRF.vhd
--	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
--  Version:		0.990
--	History:
--	Date:			28 May 2021
--	Last Author: 	HANIEH
--  Copyright (C) 2021 University of Tehran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--

--******************************************************************************
--	File content description:
--	The Register File (TRF) of the SAYAC core                                 
--******************************************************************************
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY IFF IS
	PORT (
		clk, rst, enFlag, setFlags : IN STD_LOGIC;
		selFlag  : IN STD_LOGIC;
		inFlag   : IN STD_LOGIC;
		outFlag  : OUT STD_LOGIC
	);
END ENTITY IFF;

ARCHITECTURE behaviour OF IFF IS
	SIGNAL outFlag_FF, inFlag_FF : STD_LOGIC;
BEGIN
	inFlag_FF <= outFlag_FF WHEN (selFlag OR setFlags) = '0' ELSE inFlag;
	
	PROCESS (clk, rst)
	BEGIN
		IF rst = '1' THEN
			outFlag_FF <= '0';
		ELSIF clk = '1' AND clk'EVENT THEN
			IF enFlag = '1' THEN
				outFlag_FF <= inFlag_FF;
			END IF;
		END IF;
	END PROCESS;
	
	outFlag <= outFlag_FF;
END ARCHITECTURE behaviour;
------------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY TRF IS
	PORT (
		clk, rst, writeTRF : IN STD_LOGIC;
		setFlags, enFlag   : IN STD_LOGIC;
		rs1, rs2, rd       : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		selFlag, inFlag    : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		outFlag            : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		write_data         : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		p1, p2             : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END ENTITY TRF;

ARCHITECTURE behaviour OF TRF IS
	TYPE reg_file_mem IS ARRAY (0 TO 15) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL memTRF 	   : reg_file_mem;
	SIGNAL outFlag_reg : STD_LOGIC_VECTOR(7 DOWNTO 0);
BEGIN
	PROCESS (clk, rst)
	BEGIN
		IF rst = '1' THEN
			FOR I IN 0 TO 15 LOOP
				memTRF(I) <= STD_LOGIC_VECTOR(TO_UNSIGNED(I, 16));
			END LOOP;
		ELSIF clk = '0' AND clk'EVENT  THEN
			IF writeTRF = '1' AND rd /= "0000" THEN
				memTRF(TO_INTEGER(UNSIGNED(rd))) <= write_data;
			END IF;
		END IF;
	END PROCESS;
	
	p1 <= memTRF(TO_INTEGER(UNSIGNED(rs1))) WHEN rs1 /= "1111" ELSE
		((15 DOWNTO 8 => '0') & outFlag_reg);
	p2 <= memTRF(TO_INTEGER(UNSIGNED(rs2))) WHEN rs2 /= "1111" ELSE 
		((15 DOWNTO 8 => '0') & outFlag_reg);
	
	-- Flags = R15(7 DOWNTO 0)
	FlagsFF : FOR I IN 0 TO 7 GENERATE
				FF_bitI : ENTITY WORK.IFF
					PORT MAP (clk, rst, enFlag, setFlags, 
							 selFlag(I), inFlag(I), outFlag_reg(I));
	END GENERATE;
	
	outFlag <= outFlag_reg;
END ARCHITECTURE behaviour;
