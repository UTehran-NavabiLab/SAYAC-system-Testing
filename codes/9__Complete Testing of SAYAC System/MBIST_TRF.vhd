--******************************************************************************
--	Filename:		MBIST_TRF.vhd
--	Project:		SAYAC Testing
--  Version:		0.90
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
--	memory BIST module for SAYAC Register File testing (Controller, Datapath, Top)                               
--******************************************************************************

--------------------------------------------------------------------------------
-- TRF MBIST CONTROLLER
--------------------------------------------------------------------------------
LIBRARY IEEE;     
USE IEEE.STD_LOGIC_1164.ALL;
USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;
	
ENTITY TRF_MBIST_Controller IS
	PORT (
		clk, rst, start, cout, writeMemT, readMemT, detected : IN STD_LOGIC;
		ld, cen, rst_cnt : OUT STD_LOGIC);
END ENTITY TRF_MBIST_Controller;

ARCHITECTURE TRF_MBIST_Controller_Arc OF TRF_MBIST_Controller IS
TYPE STATE IS (WFS, init, testR1, testW1, inter);
SIGNAL PSTATE, NSTATE : STATE;
SIGNAL end_of_TV_test : STD_LOGIC;
BEGIN
    PROCESS (clk , rst)
    BEGIN
        IF rst = '1' THEN
            PSTATE <= WFS;
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
                else
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
END ARCHITECTURE TRF_MBIST_Controller_Arc;
--------------------------------------------------------------------------------
-- TRF MBIST DATAPATH
--------------------------------------------------------------------------------
LIBRARY IEEE;     
USE IEEE.STD_LOGIC_1164.ALL;
USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;
	
ENTITY TRF_MBIST_DP IS
	PORT (
		clk, rst, ld, cen, rst_cnt : IN STD_LOGIC;
        cout : OUT STD_LOGIC;
        write_to_TRF : OUT STD_LOGIC;--WRITE INDICATOR 
        TRFAddr : OUT STD_LOGIC_VECTOR (3 DOWNTO 0); --address to TRF , RS1, RD
        TRFData_IN : OUT STD_LOGIC_VECTOR (15 DOWNTO 0); --data to TRF , WRITE_DATA
        TRFData_OUT : IN STD_LOGIC_VECTOR (15 DOWNTO 0); --data from TRF , P1
        read_t : OUT STD_LOGIC;
        write_t : OUT STD_LOGIC);
END ENTITY TRF_MBIST_DP;

ARCHITECTURE TRF_MBIST_DP_Arc OF TRF_MBIST_DP IS
    SIGNAL data_t, TRFout, test_data : STD_LOGIC_VECTOR (15 DOWNTO 0);
    SIGNAL eq, write_t_wire, read_t_wire, fail : STD_LOGIC;
    SIGNAL TRFAddr_wire : STD_LOGIC_VECTOR (3 DOWNTO 0);
    SIGNAL q_wire : STD_LOGIC_VECTOR (8 DOWNTO 0);
BEGIN
    counter: ENTITY WORK.counter GENERIC MAP (9) PORT MAP(clk => clk, rst => rst_cnt, ld =>ld, d_in => "000000000", q => q_wire, u_d => '1', cen => cen, cout => cout);
    decoder: ENTITY WORK.decoder PORT MAP ( in_dec => q_wire (8 DOWNTO 5), out_dec=> data_t );
    TRFData_in <= data_t WHEN write_t_wire = '1' ELSE (OTHERS => 'Z');
    TRFAddr <= q_wire(3 DOWNTO 0) WHEN q_wire(3 DOWNTO 0) /= "0000" ELSE (OTHERS => '0') ;
    TRFAddr_wire <= q_wire(3 DOWNTO 0) WHEN q_wire(3 DOWNTO 0) /= "0000" ELSE (OTHERS => '0') ;
    read_t_wire <= q_wire(4);
    read_t <= q_wire(4);
    write_t_wire <= NOT(q_wire(4));
    write_t <= NOT(q_wire(4));
    write_to_TRF<=NOT(q_wire(4)) WHEN q_wire(3 DOWNTO 0) /= "0000" AND q_wire(3 DOWNTO 0) /= "1111" ELSE '0';
    TRFout <= TRFData_out WHEN read_t_wire = '1' and q_wire(3 DOWNTO 0) /= "0000"AND q_wire(3 DOWNTO 0) /= "1111" ELSE (OTHERS => '0');
    eq <= '1' WHEN (data_t = TRFout AND read_t_wire = '1') ELSE '0';
    fail <= '1' WHEN (eq = '0'AND read_t_wire = '1' and q_wire(3 DOWNTO 0) /= "0000" AND q_wire(3 DOWNTO 0) /= "1111" ) ELSE '0';
    test_data <= data_t ;
END ARCHITECTURE TRF_MBIST_DP_Arc;

--------------------------------------------------------------------------------
-- TRF MBIST TOP
--------------------------------------------------------------------------------
LIBRARY IEEE;     
USE IEEE.STD_LOGIC_1164.ALL;
USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;
	
ENTITY TRF_MBIST_TOP IS
	PORT (
		clk, rst, start : IN STD_LOGIC;
        write_to_TRF : OUT STD_LOGIC;
        TRFAddr : OUT STD_LOGIC_VECTOR ( 3 DOWNTO 0); --address to TRF , RS1, RD
        TRFData_IN : OUT STD_LOGIC_VECTOR ( 15 DOWNTO 0); --data to TRF , WRITE_DATA
        TRFData_OUT : IN STD_LOGIC_VECTOR ( 15 DOWNTO 0); --data from TRF , P1
        DETECTED : IN STD_LOGIC);
END ENTITY TRF_MBIST_TOP;

ARCHITECTURE TRF_MBIST_TOP_Arc OF TRF_MBIST_TOP IS
    SIGNAL ld, cout, cen, rst_cnt : STD_LOGIC;
    SIGNAL read_t, write_t : STD_LOGIC;--To controller
BEGIN
    CONTROLLER: ENTITY WORK.TRF_MBIST_Controller(TRF_MBIST_Controller_Arc) PORT MAP 
            (clk => clk, rst => rst, start => start,
            cout => cout, ld => ld, cen => cen, writeMemT => write_t, readMemT => read_t,
            rst_cnt=>rst_cnt, detected => detected);

    DATAPATH : ENTITY WORK.TRF_MBIST_DP(TRF_MBIST_DP_Arc) PORT MAP
            (clk => clk, rst => rst, ld => ld, cen => cen, rst_cnt => rst_cnt, cout => cout,
            write_to_TRF => write_to_TRF, TRFAddr => TRFAddr, TRFData_IN => TRFData_IN,
            TRFData_OUT => TRFData_OUT, write_t => write_t, read_t => read_t);
END ARCHITECTURE TRF_MBIST_TOP_Arc;