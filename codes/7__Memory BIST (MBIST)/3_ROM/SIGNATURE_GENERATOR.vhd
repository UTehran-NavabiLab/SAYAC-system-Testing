--******************************************************************************
--	Filename:		SIGNATURE_GENERATOR.vhd
--	Project:		SAYAC : Simple Architecture Yet Ample Circuitry
--  Version:		0.990
--	History:
--	Date:			26 July 2022
--	Last Author: 	DELARAM
--  Copyright (C) 2022 University of Teheran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--

--******************************************************************************
--	File content description:
--	creates a golden signature file from instruction file.
--  Note: for synthesizing, "produce_signature_file" process must be commented out .                              
--******************************************************************************
LIBRARY IEEE;     
USE IEEE.STD_LOGIC_1164.ALL;
USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE ieee.NUMERIC_STD.ALL;
	
ENTITY SIGNATURE_Controller IS
	PORT (
		clk, rst, start, COUT, EOP, EOF : IN STD_LOGIC;
		READINST, ld, cen, rst_cnt, MISR_LD, MISR_RST : OUT STD_LOGIC
	);
END ENTITY SIGNATURE_Controller;

ARCHITECTURE SIGNATURE_Controller_Arc OF SIGNATURE_Controller IS
    TYPE STATE IS (WFS, READ, EOP_STATE);
    SIGNAL PSTATE, NSTATE : STATE;
BEGIN
    PROCESS (clk , rst)
    BEGIN
        IF rst = '1' THEN
            PSTATE <= WFS;
        ELSIF clk = '1' AND clk'EVENT THEN 
            PSTATE <= NSTATE;
        END IF;
    END PROCESS;

    PROCESS (PSTATE, start, EOF, EOP) BEGIN
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
                    IF(EOP = '1') THEN
                        NSTATE <= EOP_STATE;
                    ELSE
                        NSTATE <= READ;
                    END IF;
                END IF;   

            WHEN EOP_STATE => 
                IF(EOF = '1') THEN
                    NSTATE <= WFS;
                ELSE
                    NSTATE <= READ;
                END IF;
        END CASE;
    END PROCESS;

    PROCESS (PSTATE)
    BEGIN
    ld <= '0'; MISR_LD <='0';cen <= '0';
    rst_cnt <= '0'; MISR_RST <= '0';
        CASE PSTATE IS
            WHEN WFS =>
                ld <='1';
                rst_cnt <= '1'; 
                MISR_RST <= '1';                               

            WHEN READ =>
                IF(EOP = '1') THEN
                    MISR_RST <= '1';
                ELSE 
                    MISR_LD <= '1';
                    cen <= '1';
                END IF;

                WHEN EOP_STATE =>
                    MISR_RST <= '1';
        END CASE;
    END PROCESS;
END ARCHITECTURE SIGNATURE_Controller_Arc;
----------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
LIBRARY IEEE;     
USE IEEE.STD_LOGIC_1164.ALL;
USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE ieee.NUMERIC_STD.ALL;
	
ENTITY SIGNATURE_TOP IS
    GENERIC (
		numofinst : INTEGER := 300);
	PORT (
        clk, rst, start: IN STD_LOGIC;
        MISR_GD_LD, MISR_GD_RST : OUT STD_LOGIC;
        SIGNATURE : OUT STD_LOGIC_VECTOR (15 DOWNTO 0));
END ENTITY SIGNATURE_TOP;

ARCHITECTURE SIGNATURE_TOP_Arc OF SIGNATURE_TOP IS
TYPE inst_mem IS ARRAY (0 TO numofinst-1) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL instMEM : inst_mem;
	
	IMPURE FUNCTION InitRomFromFile 
	RETURN inst_mem IS
		FILE RomFile : TEXT OPEN read_mode IS "INSTRUCTIONS.txt";
		VARIABLE RomFileLine : LINE;
		VARIABLE GOOD : BOOLEAN;
		VARIABLE fstatus: FILE_OPEN_STATUS;
		VARIABLE ROM : inst_mem;
	BEGIN	
	--	REPORT "Status from FILE: '" & FILE_OPEN_STATUS'IMAGE(fstatus) & "'";
		READLINE(RomFile, RomFileLine);
		FOR I IN 0 TO numofinst-1 LOOP
			IF NOT ENDFILE(RomFile) THEN
				READLINE(RomFile, RomFileLine);
				READ(RomFileLine, ROM(I), GOOD);
	--			REPORT "Status from FILE: '" & BOOLEAN'IMAGE(GOOD) & "'";
			END IF;
		END LOOP;
		FILE_close(RomFile);
		RETURN ROM;
	END FUNCTION;

    SIGNAL MISR_OUT, MISR_IN : STD_LOGIC_VECTOR (15 DOWNTO 0);
    SIGNAL ld, cout, MISR_LD, MISR_RST, RST_CNT, CEN : STD_LOGIC;
    SIGNAL EOP, EOF : STD_LOGIC := '0';
    SIGNAL q_wire : STD_LOGIC_VECTOR (15 DOWNTO 0); 
BEGIN
    INSTMEM <= InitRomFromFile;
    controller: ENTITY WORK.SIGNATURE_Controller(SIGNATURE_Controller_Arc) PORT MAP (clk => clk, rst => rst, start => start,
    cout => cout, MISR_LD => MISR_LD, MISR_RST => MISR_RST, LD => LD, RST_CNT => RST_CNT, CEN => CEN, EOP => EOP, EOF => EOF);
    FAULTY_MISR: ENTITY WORK.MISR PORT MAP(CLK, MISR_RST, MISR_LD, X"0001", X"1001", MISR_IN, MISR_OUT);
    counter: ENTITY WORK.counter GENERIC MAP(16) PORT MAP(clk => clk, rst => rst_cnt , ld => ld, d_in => "0000000000000000", q => q_wire, u_d => '1', cen => cen, cout => cout);
    EOP <= '1' WHEN (TO_INTEGER(UNSIGNED(q_wire))MOD 50) = 0 AND (NOW > 0 NS) ELSE '0';
    EOF <= '1' WHEN (TO_INTEGER(UNSIGNED(q_wire))) = numofinst-2 ELSE '0';
    MISR_IN <= instMEM(TO_INTEGER(UNSIGNED(q_wire)));
    SIGNATURE <= MISR_OUT;
    MISR_GD_LD <= MISR_LD;
    MISR_GD_RST <= MISR_RST;
    produce_signature_file: PROCESS (EOP) 
        FILE RPORT_FILE : text OPEN WRITE_MODE IS "GOLDEN_SIGNATURE.txt";
        VARIABLE R_LINE : LINE;
        VARIABLE SIGN_report : string(1 TO 20);
        VARIABLE SIGN_len : NATURAL := 16;
    BEGIN
        IF((EOP='1' AND EOP'EVENT)) THEN
        REPORT " TIME IS "&TIME'IMAGE (NOW);
        SIGN_report :=  (OTHERS => ' ');
        SIGN_report(1 to SIGN_len) := TO_STRING(MISR_OUT);
        WRITE(R_LINE, SIGN_report);
        writeline(RPORT_FILE, R_LINE);
        END IF;
    END PROCESS;
END ARCHITECTURE SIGNATURE_TOP_Arc;