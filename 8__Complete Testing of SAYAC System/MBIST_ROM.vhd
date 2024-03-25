--******************************************************************************
--	Filename:		MBIST_ROM.vhd
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
--	memory BIST module for SAYAC Instruction ROM testing (Controller, Datapath, Top)                               
--******************************************************************************
--------------------------------------------------------------------------------
-- ROM MBIST CONTROLLER
--------------------------------------------------------------------------------
LIBRARY IEEE;     
USE IEEE.STD_LOGIC_1164.ALL;
USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE ieee.NUMERIC_STD.ALL;
	
ENTITY ROM_MBIST_Controller IS
	PORT (
		clk, rst, start, cout, EOP, EOF, NXT_SEG : IN STD_LOGIC;
		READINST, ld, cen, MISR_LD, rst_cnt, MISR_RST : OUT STD_LOGIC);
END ENTITY ROM_MBIST_Controller;

ARCHITECTURE ROM_MBIST_Controller_Arc OF ROM_MBIST_Controller IS
    TYPE STATE IS (WFS, READ, MISR_STATE);
    SIGNAL PSTATE, NSTATE : STATE;
BEGIN
    PROCESS (clk , rst)
    BEGIN
        IF rst = '1' THEN
            PSTATE<= WFS;
        ELSIF clk = '1' AND clk'EVENT THEN 
            PSTATE <= NSTATE;
        END IF;
    END PROCESS;

    PROCESS (PSTATE, start, EOP, EOF, NXT_SEG)
    BEGIN
        NSTATE <= WFS;
        CASE PSTATE IS
            WHEN WFS =>
                IF (start = '1') THEN 
                    NSTATE <= READ;
                ELSE
                    NSTATE <= WFS;
                END IF ;

           WHEN READ =>
                IF(EOF = '1') THEN
                    NSTATE <= WFS;
                ELSE
                    NSTATE <= MISR_STATE;
                END IF;
               
            WHEN MISR_STATE => 
                IF(EOF = '1') THEN
                    NSTATE <= WFS;
                ELSE
                    NSTATE <= READ;
                END IF;
        END CASE;
    END PROCESS;

    PROCESS (PSTATE)
    BEGIN
    ld <= '0';cen<= '0'; READINST<= '0'; MISR_LD <='0';
    rst_cnt<='0'; MISR_RST<='0';
        CASE PSTATE IS
            WHEN WFS =>
                ld <= '1';
                rst_cnt <= '1'; 
                MISR_RST <= '1';               

            WHEN READ =>
                IF (NXT_SEG = '1') THEN
                    READINST <= '1';
                    cen <= '1';
                END IF;

                IF(EOP = '1') THEN
                    MISR_RST <= '1';
                    READINST <= '1';
                ELSE 
                    MISR_LD <= '1';
                    READINST <= '1';
                    cen <= '1';
                END IF;
           
            WHEN MISR_STATE =>
                READINST <= '1';
                IF(EOP = '1') THEN
                    MISR_RST <= '1';
                ELSE
                    READINST <= '1';
                END IF;
        END CASE;
    END PROCESS;
END ARCHITECTURE ROM_MBIST_Controller_Arc;
--------------------------------------------------------------------------------
-- ROM MBIST DATAPATH
--------------------------------------------------------------------------------
LIBRARY IEEE;     
USE IEEE.STD_LOGIC_1164.ALL;
USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE ieee.NUMERIC_STD.ALL;
	
ENTITY ROM_MBIST_DP IS
    GENERIC (NUM_OF_INST : INTEGER);
	PORT (
        clk, rst, LD, CEN, rst_cnt, MISR_LD, MISR_RST: IN STD_LOGIC;
        ROMAddr : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
        ROMDATA : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
        EOP_OUT, EOF_OUT, COUT, NXT_SEG : OUT STD_LOGIC;
        SIGNATURE : OUT STD_LOGIC_VECTOR (15 DOWNTO 0));
END ENTITY ROM_MBIST_DP;

ARCHITECTURE ROM_MBIST_DP_Arc OF ROM_MBIST_DP IS
    SIGNAL MISR_OUT, MISR_DATA : STD_LOGIC_VECTOR (15 DOWNTO 0);
    SIGNAL EOP, EOF : STD_LOGIC;
    SIGNAL q_wire : STD_LOGIC_VECTOR (15 DOWNTO 0); 
BEGIN
    TEST_MISR : ENTITY WORK.MISR PORT MAP(clk, MISR_RST, MISR_LD, X"0001", X"1001", MISR_DATA, MISR_OUT);
    counter: ENTITY WORK.counter GENERIC MAP (16) PORT MAP(clk => clk, rst => rst_cnt, ld =>ld, d_in => "0000000000000000", q => q_wire, u_d => '1', cen=> cen, cout => cout);
    EOP <= '1' WHEN  (TO_INTEGER(UNSIGNED(q_wire))MOD 50) = 0 AND (TO_INTEGER(UNSIGNED(q_wire)) > 1) ELSE '0';--SEGMENTS OF 50 INSTRUCTIONS
    EOF <= '1' WHEN (TO_INTEGER(UNSIGNED(q_wire))) = NUM_OF_INST-2 ELSE '0';
    EOP_OUT<=EOP;
    EOF_OUT <= EOF;
    MISR_DATA<= ROMDATA;
    ROMADDR <= q_wire;
    SIGNATURE <= MISR_OUT;
    --PRODUCING FAULTY SIGNATURE FILE
    PROCESS (EOP) 
        FILE RPORT_FILE : text OPEN WRITE_MODE IS "FAULTY_SIGNATURE.txt";
            VARIABLE R_LINE : LINE;
            VARIABLE SIGN_report : string(1 TO 20);
            VARIABLE SIGN_len : NATURAL := 16;
        BEGIN
            IF((EOP='1' AND EOP'EVENT)) THEN
                SIGN_report := (OTHERS => ' ');
                SIGN_report(1 to SIGN_len) := TO_STRING(MISR_OUT);
                WRITE(R_LINE, SIGN_report);
                writeline(RPORT_FILE, R_LINE);
                NXT_SEG <= '1';
            ELSE
                NXT_SEG <= '0';
            END IF;
    END PROCESS;
END ARCHITECTURE ROM_MBIST_DP_Arc;
--------------------------------------------------------------------------------
-- ROM MBIST TOP
--------------------------------------------------------------------------------
LIBRARY IEEE;     
USE IEEE.STD_LOGIC_1164.ALL;
USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE ieee.NUMERIC_STD.ALL;
	
ENTITY ROM_MBIST_TOP IS
    GENERIC (NUM_OF_INST : INTEGER);
	PORT (
        clk, rst, start: IN STD_LOGIC;
        READINST : OUT STD_LOGIC;
        ROMAddr : OUT STD_LOGIC_VECTOR ( 15 DOWNTO 0);
        ROMDATA : IN STD_LOGIC_VECTOR ( 15 DOWNTO 0);
        SIGNATURE : OUT STD_LOGIC_VECTOR ( 15 DOWNTO 0));
END ENTITY ROM_MBIST_TOP;

ARCHITECTURE ROM_MBIST_TOP_Arc OF ROM_MBIST_TOP IS
    SIGNAL ld, cout, cen, rst_cnt, MISR_LD, MISR_RST, EOP, EOF, NXT_SEG : STD_LOGIC;
    SIGNAL ROMADDR_WIRE : STD_LOGIC_VECTOR (15 DOWNTO 0);
BEGIN
    CONTROLLER: ENTITY WORK.ROM_MBIST_Controller(ROM_MBIST_Controller_Arc) PORT MAP (clk => clk, rst => rst, start => start,
    cout => cout, ld => ld , cen => cen, rst_cnt => rst_cnt, READINST => READINST,
    MISR_LD => MISR_LD, MISR_RST => MISR_RST, EOP => EOP, EOF => EOF, NXT_SEG => NXT_SEG);

    DATAPATH: ENTITY WORK.ROM_MBIST_DP(ROM_MBIST_DP_Arc) GENERIC MAP (NUM_OF_INST) PORT MAP (clk => clk, rst => rst, cout => cout,
    ld => ld, cen => cen, rst_cnt => rst_cnt, MISR_LD => MISR_LD, MISR_RST => MISR_RST, ROMAddr => ROMAddr_WIRE, ROMDATA => ROMDATA,
    SIGNATURE => SIGNATURE, NXT_SEG => NXT_SEG, EOP_OUT => EOP, EOF_OUT => EOF);
    ROMAddr <= ROMAddr_WIRE WHEN START = '1' ELSE (OTHERS => 'Z');
END ARCHITECTURE ROM_MBIST_TOP_Arc;