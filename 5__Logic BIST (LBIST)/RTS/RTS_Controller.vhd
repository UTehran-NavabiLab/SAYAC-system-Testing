--******************************************************************************
--	Filename:		RTS_Controller.vhd
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
--	LBIST Controller                               
--******************************************************************************

--///////////////////////////////// Counter /////////////////////////////////
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY BIST_Counter IS
	GENERIC (counterSize : INTEGER := 8);
	PORT (clk, rst, En : IN STD_LOGIC; 
	counterOut : OUT STD_LOGIC_VECTOR(counterSize-1 DOWNTO 0)); 
END ENTITY ; 
--
ARCHITECTURE procedural OF BIST_Counter IS 
	SIGNAL temp : STD_LOGIC_VECTOR(counterSize-1 DOWNTO 0);
BEGIN
	PROCESS (clk)
	BEGIN
		IF clk = '1' AND clk'EVENT THEN
			IF rst = '1' THEN
				temp <= (OTHERS => '0');
			ELSIF (En = '1') THEN 
				temp <= temp + 1; 
			END IF;
		END IF;
	END PROCESS;

	counterOut <= temp;

END ARCHITECTURE;

--///////////////////////////////// Controller /////////////////////////////////
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY RTS_Controller IS
	GENERIC (shiftSize : INTEGER := 90; numOfCycles : INTEGER := 100; numOfRounds : INTEGER := 5);
	PORT (clk, rst, runLBIST : IN STD_LOGIC; 
	PbarS, rstOut, PRPG_En, SRSG_En, SISA_En, MISR_En, done : OUT STD_LOGIC); 
END ENTITY ; 
--
ARCHITECTURE procedural OF RTS_Controller IS 
	TYPE state IS (Reset, firstPI, firstPPI, normalMode, shiftMode, lastPO, lastPPO); 
	SIGNAL present_state, next_state : state; 
	SIGNAL SC : STD_LOGIC_VECTOR (6 DOWNTO 0);  -- Pay attension. vector size should be log2 of shiftSize
	SIGNAL SC_Rst, SC_En : STD_LOGIC;
	SIGNAL TC : STD_LOGIC_VECTOR (6 DOWNTO 0);  -- Pay attension. vector size should be log2 of numOfCycles
	SIGNAL TC_Rst, TC_En : STD_LOGIC;
	SIGNAL RC : STD_LOGIC_VECTOR (2 DOWNTO 0);  -- Pay attension. vector size should be log2 of numOfRounds
	SIGNAL RC_Rst, RC_En : STD_LOGIC;

BEGIN
	PROCESS (clk, rst)
	BEGIN
		IF rst = '1' THEN
			present_state <= Reset;
		ELSIF clk = '1' AND clk'EVENT THEN
			present_state <= next_state;
		END IF;
	END PROCESS;
	
	PROCESS (present_state, runLBIST, SC, TC, RC) 
	BEGIN
		PbarS <= '0';	rstOut <= '0'; 
		PRPG_En <= '0'; SRSG_En <= '0'; 
		SISA_En <= '0'; MISR_En <= '0';
		SC_Rst <= '0';  SC_En <= '0';
		TC_Rst <= '0';  TC_En <= '0';
		RC_Rst <= '0';  RC_En <= '0';				
		done <= '0'; next_state <= Reset;
	CASE present_state IS 
		WHEN Reset =>
			IF runLBIST = '0' THEN next_state <= Reset;
			ELSE next_state <= firstPI; END IF; 	
			rstOut <= '1';
		WHEN firstPI =>
			next_state <= firstPPI;
			PRPG_En <= '1';
			SC_Rst  <= '1';
			TC_Rst  <= '1';
			RC_Rst  <= '1';				
		WHEN firstPPI =>
			IF SC < shiftSize - 1 THEN next_state <= firstPPI;
			ELSE next_state <= normalMode; END IF; 
			SC_En   <= '1';
			SRSG_En <= '1';
			PbarS   <= '1';
		WHEN normalMode =>
			next_state <= shiftMode;
			MISR_En <= '1';
			TC_En   <= '1';
			SC_Rst  <= '1';
			PRPG_En <= '1';
			PbarS   <= '0';
		WHEN shiftMode =>
			IF SC < shiftSize - 1 THEN next_state <= shiftMode;
			ELSIF TC < numOfCycles THEN next_state <= normalMode;
			ELSIF RC < numOfRounds - 1 THEN next_state <= normalMode; done <= '1'; TC_Rst <= '1'; RC_En <= '1';
			ELSE next_state <= lastPO; END IF; 
			SISA_En <= '1';
			SRSG_En <= '1';
			SC_En   <= '1';
			PbarS   <= '1';
		WHEN lastPO =>
			next_state <= lastPPO;
			MISR_En <= '1';
			SC_Rst  <= '1';
			PbarS   <= '0';	
		WHEN lastPPO =>
			IF SC < shiftSize - 1 THEN next_state <= lastPPO;
			ELSIF (SC = shiftSize - 1) THEN next_state <= Reset; done <= '1'; END IF; 
--			IF SC < shiftSize - 1 THEN next_state <= lastPPO;
--			ELSE next_state <= Reset; done <= '1'; RC_En <= '1'; END IF;    ---- resulting in a delta pulse(Mahboobeh :) )
				SISA_En <= '1';
				SC_En   <= '1';
				PbarS   <= '1';	
		WHEN OTHERS => next_state <= Reset; 
	END CASE; 
	END PROCESS; 
	
	Shift_Counter : ENTITY WORK.BIST_Counter GENERIC MAP (SC'LENGTH) 
			PORT MAP (clk, SC_Rst, SC_En, SC);
	testCycle_Counter : ENTITY WORK.BIST_Counter GENERIC MAP (TC'LENGTH) 
			PORT MAP (clk, TC_Rst, TC_En, TC);
	testRound_Counter : ENTITY WORK.BIST_Counter GENERIC MAP (RC'LENGTH) 
			PORT MAP (clk, RC_Rst, RC_En, RC);
	
END ARCHITECTURE;

