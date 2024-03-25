--******************************************************************************
--	Filename:		Accelerator_BUS.vhd
--	Project:		SAYAC Testing 
--  Version:		0.90
--	History:
--	Date:			20 June 2022
--	Last Author: 	Nooshin Nosrati
--  Copyright (C) 2022 University of Tehran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--
--******************************************************************************
--	File content description:
--	Fictitious bus accelerator                        
--******************************************************************************

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY Accelerator_BUS IS
    PORT(
	    Input : IN STD_LOGIC_VECTOR (35 DOWNTO 0);	
	    Output : OUT STD_LOGIC_VECTOR (16 DOWNTO 0));
END Accelerator_BUS;

ARCHITECTURE str OF Accelerator_BUS IS  
BEGIN
    --Fictitious_Accelerator
END str;


