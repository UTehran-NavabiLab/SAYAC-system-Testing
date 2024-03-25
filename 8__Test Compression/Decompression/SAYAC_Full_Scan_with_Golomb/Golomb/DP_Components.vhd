--******************************************************************************
--	Filename:		DP_Components.vhd
--	Project:		SAYAC Testing 
--  Version:		0.90
--	History:
--	Date:			11 November 2023
--	Last Author: 	Delaram
--  Copyright (C) 2023 University of Tehran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--
--******************************************************************************
--	File content description:
--	                              
--******************************************************************************

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE IEEE.numeric_std.ALL;

ENTITY Reg_P IS
  PORT (
    clk, rst: IN STD_LOGIC;
    in_P    : IN STD_LOGIC_VECTOR;
    Out_P   : OUT STD_LOGIC_VECTOR;
	ld, clr : IN STD_LOGIC
	);
END ENTITY Reg_P;
--
ARCHITECTURE behaviour OF Reg_P IS
BEGIN
  PROCESS (clk, rst)
  BEGIN
    IF rst = '1' THEN
      Out_P <= (Out_P'RANGE =>'0');
    ELSIF clk = '1' AND clk'event THEN
      IF clr = '1' THEN
        Out_P <= (Out_P'RANGE =>'0');
      ELSIF ld = '1' THEN
        Out_P <= in_P;
      END IF;
    END IF;
  END PROCESS;
END ARCHITECTURE behaviour;
------------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY Mux2to1 IS
	PORT (
		in0, in1   : IN STD_LOGIC_VECTOR;
		sel0, sel1 : IN STD_LOGIC;
		out_P      : OUT STD_LOGIC_VECTOR
	);
END ENTITY Mux2to1;

ARCHITECTURE behaviour OF Mux2to1 IS
BEGIN
	out_P <= in0 WHEN sel0 = '1' ELSE
			  in1 WHEN sel1 = '1' ELSE 
			  (Out_P'RANGE =>'0');
END ARCHITECTURE behaviour;
------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY Mux4to1 IS
	PORT (
		in0, in1, in2, in3     : IN STD_LOGIC_VECTOR;
		sel0, sel1, sel2, sel3 : IN STD_LOGIC;
		out_P                 : OUT STD_LOGIC_VECTOR
	);
END ENTITY Mux4to1;

ARCHITECTURE behaviour OF Mux4to1 IS
BEGIN
	out_P <=  in0 WHEN sel0 = '1' ELSE
			  in1 WHEN sel1 = '1' ELSE 
			  in2 WHEN sel2 = '1' ELSE 
			  in3 WHEN sel3 = '1' ELSE 
			  (Out_P'RANGE =>'0');
END ARCHITECTURE behaviour;
-----------------------------------------------------------------------------------------------
--modified
--counter
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;
USE IEEE.numeric_std.ALL;
	
ENTITY counter_4 IS
	PORT (
		ld_counter,clk,rst : IN STD_LOGIC;
		cnt_out            : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END ENTITY counter_4;

ARCHITECTURE counter_arc OF counter_4 IS
SIGNAL temp :STD_LOGIC_VECTOR(3 DOWNTO 0);
BEGIN
cnt_out<= temp;
PROCESS(clk,rst)
BEGIN
	IF rst='1' THEN
		temp<=(OTHERS=>'0');
	ELSIF clk='1' AND clk'EVENT THEN
			IF ld_counter ='1' THEN
				temp<="1100";
			ELSE 
				temp<=temp +"0001";
		END IF;
	END IF; 

END PROCESS;
END ARCHITECTURE counter_arc;

--modified
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY Mux3to1 IS
	PORT (
		in0, in1, in2     : IN STD_LOGIC_VECTOR;
		sel0, sel1, sel2  : IN STD_LOGIC;
		out_P             : OUT STD_LOGIC_VECTOR
	);
END ENTITY Mux3to1;

ARCHITECTURE behaviour OF Mux3to1 IS
BEGIN
	out_P <=  in0 WHEN sel0 = '1' ELSE
			  in1 WHEN sel1 = '1' ELSE 
			  in2 WHEN sel2 = '1' ELSE 
			  (Out_P'RANGE =>'0');
END ARCHITECTURE behaviour;
-----------------------------------------------------------------------------

------------------------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Reg IS
  PORT (
    clk, rst: IN STD_LOGIC;
    in_P    : IN STD_LOGIC_VECTOR;
    Out_P   : OUT STD_LOGIC_VECTOR;
	ld, clr : IN STD_LOGIC
	);
END ENTITY Reg;
--
ARCHITECTURE behaviour OF Reg IS
BEGIN
  PROCESS (clk, rst)
  BEGIN
    IF rst = '1' THEN
      Out_P <= (Out_P'RANGE =>'0');
    ELSIF clk = '1' AND clk'event THEN
      IF clr = '1' THEN
        Out_P <= (Out_P'RANGE =>'0');
      ELSIF ld = '1' THEN
        Out_P <= in_P;
      END IF;
    END IF;
  END PROCESS;
END ARCHITECTURE behaviour;

-------------------------------------------------------------------------------------------------
LIBRARY IEEE;
    USE IEEE.STD_LOGIC_1164.ALL;
    USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY COUNTER IS
    GENERIC(inputbit:INTEGER:=4);
    port (clk:IN STD_LOGIC;
    rst:IN STD_LOGIC;
    en:IN STD_LOGIC;
    output:OUT STD_LOGIC_VECTOR(inputbit-1 DOWNTO 0));
END COUNTER ;
ARCHITECTURE ARCH OF COUNTER  IS
    SIGNAL oup:STD_LOGIC_VECTOR(inputbit-1 DOWNTO 0);
BEGIN
    identifier : PROCESS( clk,rst )
    BEGIN
        IF(rst='1') THEN
            oup<=(OTHERS=>'0');
        ELSIF(clk='1' AND clk'EVENT) THEN 
            IF(en='1') THEN
                oup<=oup+1;
            END IF;
        END IF;
    END PROCESS ;
    output<=oup;
end ARCHITECTURE;
-------------------------------------------------------------------------------------------------------

library ieee;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
-- GENERIC BIT REGISTER
ENTITY GENERIC_REG IS 
GENERIC (N : INTEGER );
PORT( clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;--reset
    ld : IN STD_LOGIC;--load 
    reg_in : IN STD_LOGIC_VECTOR (N-1 DOWNTO 0);
    reg_out : OUT STD_LOGIC_VECTOR (N-1 DOWNTO 0));
END ENTITY GENERIC_REG;

ARCHITECTURE GENERIC_REG_ARC OF GENERIC_REG IS
SIGNAL temp_reg : STD_LOGIC_VECTOR (N-1 DOWNTO 0);
BEGIN
reg_out <= temp_reg;
P3: PROCESS(clk , rst)
BEGIN
    IF rst = '1' THEN
        temp_reg <= (OTHERS => '0');
    ELSIF clk = '1' AND clk'EVENT THEN  
        IF ld = '1' THEN
        temp_reg <= reg_in;
        END IF;
    ELSE
    END IF;
END PROCESS;
END ARCHITECTURE GENERIC_REG_ARC;

-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
library ieee;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
-- One BIT REGISTER
ENTITY OneBit_REG IS 
PORT( clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;--reset
    ld : IN STD_LOGIC;--load 
    reg_in : IN STD_LOGIC;
    reg_out : OUT STD_LOGIC);
END ENTITY OneBit_REG;

ARCHITECTURE OneBit_REG_ARC OF OneBit_REG IS
SIGNAL temp_reg : STD_LOGIC;
BEGIN
reg_out <= temp_reg;
P3: PROCESS(clk , rst)
BEGIN
    IF rst = '1' THEN
        temp_reg <= '0';
    ELSIF clk = '1' AND clk'EVENT THEN  
        IF ld = '1' THEN
          temp_reg <= reg_in;
        END IF;
    ELSE
    END IF;
END PROCESS;
END ARCHITECTURE OneBit_REG_ARC;

-- ---------------------------------------------------------------------
library ieee;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
    -- 4 BIT COUNTER
ENTITY COUNTER_4_D IS 
PORT( clk : IN STD_LOGIC;
    rst_cnt : IN STD_LOGIC;--reset counter
    cnt_enable : IN STD_LOGIC;--enable counting
    clear_counter : IN STD_LOGIC;--load counter with zero
    cnt_out : OUT STD_LOGIC_VECTOR (3 DOWNTO 0));
END ENTITY COUNTER_4_D;

ARCHITECTURE COUNTER_ARC OF COUNTER_4_D IS
SIGNAL temp : STD_LOGIC_VECTOR ( 3 DOWNTO 0 );
BEGIN
cnt_out <= temp;
P4: PROCESS(clk , rst_cnt)
BEGIN
    IF rst_cnt = '1' THEN
        temp <= (OTHERS => '0');
    ELSIF clk = '1' AND clk'EVENT THEN 
        IF cnt_enable ='1' THEN
            IF (temp = "1111") THEN temp <= "0000"; 
            ELSE temp <= temp + "0001";--count up 
            END IF;
        ELSIF clear_counter = '1' THEN
            temp <= "0000";
        END IF;
    ELSE 
    END IF;
END PROCESS;
END ARCHITECTURE COUNTER_ARC;
-- ----------------------------------------------------------------------
-- ---------------------------------------------------------------------
library ieee;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
-- GENERIC SHIFT REGISTER
ENTITY GENERIC_SHIFT_REG IS 
GENERIC (N : INTEGER := 4 ; active : STD_LOGIC := '1'; RL : STD_LOGIC :='1'); -- RL = '1' LSB OUT
PORT( clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;--reset
    ld : IN STD_LOGIC;--load 
    shift : IN STD_LOGIC;
    par_in : IN STD_LOGIC_VECTOR (N-1 DOWNTO 0);
    par_out : OUT STD_LOGIC_VECTOR (N-1 DOWNTO 0);
    Sin : IN STD_LOGIC;
    So : OUT STD_LOGIC);
END ENTITY GENERIC_SHIFT_REG;

ARCHITECTURE GENERIC_SHIFT_REG_ARC OF GENERIC_SHIFT_REG IS
SIGNAL temp_reg : STD_LOGIC_VECTOR (N-1 DOWNTO 0);
BEGIN
P3: PROCESS(clk , rst, ld, temp_reg, Sin, par_in)
BEGIN
    IF rst = '1' THEN
        temp_reg <= (OTHERS => '0');
    -- ELSIF clk = active AND clk'EVENT THEN  
    -- END IF;
    ELSIF ld = '1' THEN
      temp_reg <= par_in;
    -- END IF;
    -- End IF;

    ELSIF clk = active AND clk'EVENT THEN  
        IF shift = '1' THEN
          IF RL = '1'THEN
            temp_reg <= Sin & temp_reg(N-1 DOWNTO 1);
          ELSE
            temp_reg <=  temp_reg(N-2 DOWNTO 0) & Sin;
          END IF;
        ELSE
          temp_reg <= temp_reg;
        END IF;
    END IF;
  END PROCESS;
        
    So <= temp_reg(0) WHEN RL = '1' ELSE temp_reg(N-1);
    par_out <= temp_reg;
END ARCHITECTURE GENERIC_SHIFT_REG_ARC;

-- ---------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
	
ENTITY Mux2to1_OneBit IS
	PORT (
		in0, in1   : IN STD_LOGIC;
		sel0, sel1 : IN STD_LOGIC;
		out_P      : OUT STD_LOGIC
	);
END ENTITY Mux2to1_OneBit;

ARCHITECTURE behaviour OF Mux2to1_OneBit IS
BEGIN
	out_P <= in0 WHEN sel0 = '1' ELSE
			  in1 WHEN sel1 = '1' ELSE '0';
END ARCHITECTURE behaviour;

-----------------------------------------------------
LIBRARY IEEE;
    USE IEEE.STD_LOGIC_1164.ALL;
    USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY COUNTER_n IS
    GENERIC(inputbit:INTEGER:=4);
    port (clk:IN STD_LOGIC;
    rst:IN STD_LOGIC;
    en:IN STD_LOGIC;
    output:OUT STD_LOGIC_VECTOR(inputbit-1 DOWNTO 0));
END COUNTER_n ;
ARCHITECTURE ARCH OF COUNTER_n  IS
    SIGNAL oup:STD_LOGIC_VECTOR(inputbit-1 DOWNTO 0);
BEGIN
    identifier : PROCESS( clk,rst )
    BEGIN
        IF(rst='1') THEN
            oup<=(OTHERS=>'0');
        ELSIF(clk='0' AND clk'EVENT) THEN 
            IF(en='1') THEN
                oup<=oup+1;
            END IF;
        END IF;
    END PROCESS ;
    output<=oup;
end ARCHITECTURE;
-------------------------------------------------------------------------------------------------------

-----------------------------------------------------
LIBRARY IEEE;
    USE IEEE.STD_LOGIC_1164.ALL;
    USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY CSR IS
    GENERIC(Reg_num:INTEGER:=4);
    port (clk:IN STD_LOGIC;
    rst:IN STD_LOGIC;
    diff_in:IN STD_LOGIC;
    load:IN STD_LOGIC;
    shift:IN STD_LOGIC;
    initial_value:IN STD_LOGIC_VECTOR (Reg_num-1 DOWNTO 0);
    data_out:OUT STD_LOGIC_VECTOR(Reg_num-1 DOWNTO 0);
    So: OUT STD_LOGIC);
    END CSR ;
ARCHITECTURE ARCH OF CSR  IS
    -- SIGNAL data:STD_LOGIC_VECTOR(Reg_num DOWNTO 0):= (OTHERS =>'0');
    SIGNAL So_wire, Sin_wire: STD_LOGIC;
    -- SIGNAL dummy_parout : STD_LOGIC_VECTOR(Reg_num-1 DOWNTO 0);
BEGIN
  Sin_wire <= diff_in XOR So_wire;
  CSC_shr: ENTITY WORK.GENERIC_SHIFT_REG GENERIC MAP(Reg_num, '1') PORT MAP(clk=>clk, rst=>rst, ld=>load, shift=>shift, par_in=>initial_value, par_out=>data_out, Sin=>Sin_wire, So => So_wire); 
  So <= So_wire;
END ARCHITECTURE;
-------------------------------------------------------------------------------------------------------