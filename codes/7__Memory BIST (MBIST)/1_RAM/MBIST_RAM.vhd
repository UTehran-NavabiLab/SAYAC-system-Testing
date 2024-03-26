--******************************************************************************
--	Filename:		MBIST_RAM.vhd
--	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
--  Version:		0.990
--	History:
--	Date:			28 July 2022
--	Last Author: 	DELARAM
--  Copyright (C) 2022 University of Teheran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--

--******************************************************************************
--	File content description:
--	memory BIST module for SAYAC RAM testing (Controller, Datapath, Top)                               
--******************************************************************************
--------------------------------------------------------------------------------
-- RAM MBIST CONTROLLER
--------------------------------------------------------------------------------
LIBRARY IEEE;     
USE IEEE.STD_LOGIC_1164.all;
USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;
	
ENTITY RAM_MBIST_Controller IS
	PORT (
		clk, rst, start, cout, writeMemT, readMemT, detected : IN STD_LOGIC;
		ld, cen, rst_cnt : OUT STD_LOGIC);
END ENTITY RAM_MBIST_Controller;

ARCHITECTURE RAM_MBIST_Controller_Arc OF RAM_MBIST_Controller IS
    TYPE STATE IS (WFS, init, testR1, testW1, inter);
    SIGNAL PSTATE, NSTATE : STATE;
    SIGNAL end_of_TV_test : STD_LOGIC;
BEGIN
    PROCESS (clk, rst)
    BEGIN
        IF rst = '1' THEN
            PSTATE<= WFS;
        ELSIF clk = '1' AND clk'EVENT THEN 
            PSTATE <= NSTATE;
        END IF;
    END PROCESS;

    PROCESS (PSTATE, start, cout, writeMemT, readMemT, detected) 
    BEGIN
        NSTATE <= WFS; 
        CASE PSTATE IS
            WHEN WFS =>
                IF (start = '1') THEN 
                    NSTATE <= init;
                ELSE
                    NSTATE <= WFS;
                END IF ;

            WHEN init =>
                IF (start = '1') THEN
                    NSTATE <= testW1;
                ELSE
                    NSTATE <= WFS;
                END IF;

            WHEN testW1 =>
                IF (writeMemT = '1') THEN
                    NSTATE <= testW1;
                ELSIF (readMemT = '1' AND cout = '0') THEN
                    NSTATE <= testR1;
                END IF;

            WHEN testR1 =>
                IF (detected = '1' OR cout = '1') THEN
                    NSTATE <= init;
                ELSIF (readMemT = '1') THEN 
                    NSTATE <= testR1;
                ELSIF (writeMemT = '1') THEN 
                    NSTATE <= inter;
                    --NSTATE <= testW1;
                END IF ;

            WHEN INTER => 
               NSTATE <= testW1;
        END CASE;
    END PROCESS;

    PROCESS (PSTATE)
    BEGIN
        ld <= '0'; cen <= '0'; end_of_TV_test <= '0'; rst_cnt <= '0';
        CASE PSTATE IS
            WHEN WFS =>
                ld <= '1';
            WHEN init =>
                end_of_TV_test <= '1';
                rst_cnt <= '1';
                
            WHEN testW1 =>
                cen <= '1';
               
            WHEN testR1 =>
                cen <= '1';
                end_of_TV_test <= '0';
            
            WHEN INTER =>
        END CASE;
    END PROCESS;
END ARCHITECTURE RAM_MBIST_Controller_Arc;
--------------------------------------------------------------------------------
-- RAM MBIST DATAPATH
--------------------------------------------------------------------------------
LIBRARY IEEE;     
USE IEEE.STD_LOGIC_1164.all;
USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;
    
ENTITY RAM_MBIST_DP IS
	PORT (
        clk, rst, ld, cen, rst_cnt : IN STD_LOGIC;
        cout : OUT STD_LOGIC;
        write_to_Mem, Read_to_Mem : OUT STD_LOGIC;
        memAddr : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
        memDataWrite : OUT STD_LOGIC_VECTOR (15 DOWNTO 0); 
        memDataRead : IN STD_LOGIC_VECTOR (15 DOWNTO 0));
END ENTITY RAM_MBIST_DP;

ARCHITECTURE RAM_MBIST_DP_Arc OF RAM_MBIST_DP IS
    SIGNAL q_wire : STD_LOGIC_VECTOR (20 DOWNTO 0); 
    SIGNAL ramout, data_t, test_data : STD_LOGIC_VECTOR (15 DOWNTO 0);
    SIGNAL eq, writeMem_wire, readMem_wire, fail : STD_LOGIC;
BEGIN
    counter: ENTITY WORK.counter GENERIC MAP (21) PORT MAP(clk => clk, rst => rst_cnt, ld => ld, d_in => "000000000000000000000", q => q_wire, u_d => '1', cen => cen, cout => cout);
    decoder: ENTITY WORK.decoder PORT MAP (in_dec => q_wire (20 DOWNTO 17), out_dec => data_t);
    memDatawrite <= data_t WHEN writeMem_wire = '1' ELSE (OTHERS => 'Z');
    memAddr <= q_wire(15 DOWNTO 0);
    readMem_wire <= q_wire(16);
    writeMem_wire <= NOT(q_wire(16));
    write_to_Mem <= writeMem_wire;
    Read_to_Mem <= readMem_wire;
    ramout <= memDataRead WHEN readMem_wire = '1' ELSE (OTHERS => '0');
    eq <= '1' WHEN (data_t = ramout AND readMem_wire = '1') ELSE '0';
    fail <= '1' WHEN (eq = '0'AND readMem_wire = '1') ELSE '0';
    test_data <= data_t ;
END ARCHITECTURE RAM_MBIST_DP_Arc;
--------------------------------------------------------------------------------
-- RAM MBIST TOP
--------------------------------------------------------------------------------
LIBRARY IEEE;     
USE IEEE.STD_LOGIC_1164.all;
USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;
	
ENTITY RAM_MBIST_TOP IS
	PORT (
        clk, rst, start: IN STD_LOGIC;
        write_to_Mem, read_to_Mem : OUT STD_LOGIC;
        memAddr : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
        memDataWrite : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
        memDataRead : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
        DETECTED : IN STD_LOGIC
	);
END ENTITY RAM_MBIST_TOP;

ARCHITECTURE RAM_MBIST_TOP_Arc OF RAM_MBIST_TOP IS
    SIGNAL ld, cout, cen, rst_cnt, writeMem_wire, readMem_wire : STD_LOGIC;
    SIGNAL memAddr_WIRE :  STD_LOGIC_VECTOR (15 DOWNTO 0);
BEGIN

    CONTROLLER: ENTITY WORK.RAM_MBIST_Controller(RAM_MBIST_Controller_Arc) PORT MAP (clk => clk, rst => rst, start => start,
                    cout => cout, ld => ld, cen => cen, writeMemT => writeMem_wire, readMemT => readMem_wire,
                    rst_cnt => rst_cnt, detected => detected);

    DATAPATH: ENTITY WORK.RAM_MBIST_DP(RAM_MBIST_DP_ARC) PORT MAP (clk => clk, rst => rst,
                    write_to_Mem => writeMem_wire, read_to_Mem => readMem_wire, memAddr => memAddr_WIRE, memDataWrite => memDataWrite,
                    memDataRead => memDataRead, ld => ld, cen => cen, cout => cout, rst_cnt => rst_cnt);

    write_to_Mem <= writeMem_wire;
    read_to_Mem <= READMem_wire;
    memAddr <= memAddr_WIRE WHEN start = '1' ELSE (OTHERS => 'Z');
END ARCHITECTURE RAM_MBIST_TOP_Arc;