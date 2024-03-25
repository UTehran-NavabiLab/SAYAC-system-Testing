LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
	
	
ENTITY bufg IS
	PORT (
		in1 : IN STD_LOGIC;
		out1   : OUT STD_LOGIC);
END ENTITY bufg;
ARCHITECTURE behaviour OF bufg IS
BEGIN
out1 <= in1;
END ARCHITECTURE behaviour;
------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
	
	
ENTITY notg IS
	PORT (
		in1 : IN STD_LOGIC;
		out1   : OUT STD_LOGIC);
END ENTITY notg;
ARCHITECTURE behaviour OF notg IS
BEGIN
out1 <= NOT in1;
END ARCHITECTURE behaviour;
------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
	
ENTITY nor_n IS
PORT (
		in1 : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		out1   : OUT STD_LOGIC);
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
		in1 : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		out1   : OUT STD_LOGIC);
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
		in1 : IN STD_LOGIC;
		out1   : OUT STD_LOGIC);
END ENTITY notg;

ARCHITECTURE behaviour OF notg IS
BEGIN
	out1 <= NOT in1;
END ARCHITECTURE behaviour;
------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY pin IS
	PORT (
		in1 : IN STD_LOGIC;
		out1   : OUT STD_LOGIC);
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
		in1 : IN STD_LOGIC;
		out1   : OUT STD_LOGIC);
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
	BEGIN
	PROCESS (C, PRE, CLR, global_reset)
	BEGIN
	IF (CLR = '1' OR global_reset = '1') THEN
	Q <= '0';
	ELSIF (PRE = '1' AND PRE'EVENT) THEN
	Q <= '1';
	ELSIF (C = '1' AND C'EVENT) THEN
	IF NbarT = '1' THEN
	Q <= Si;
	ELSIF CE = '1' THEN
	Q <= D;
	END IF;
	END IF;
	END PROCESS;
END ARCHITECTURE behaviour;
------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY DFF_NP0 IS
PORT (
	D, C, R : IN STD_LOGIC;
	Q : OUT STD_LOGIC);
	END ENTITY DFF_NP0;

ARCHITECTURE behaviour OF DFF_NP0 IS
BEGIN
	PROCESS (C, R)
	BEGIN
		IF (R = '1') THEN
			Q <= '0';
		ELSIF (C = '0' AND C'EVENT) THEN
				Q <= D;
		END IF;
	END PROCESS;
END ARCHITECTURE behaviour;
------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY DFF_NP1 IS
PORT (
	D, C, R : IN STD_LOGIC;
	Q : OUT STD_LOGIC);
	END ENTITY DFF_NP1;

ARCHITECTURE behaviour OF DFF_NP1 IS
BEGIN
	PROCESS (C, R)
	BEGIN
		IF (R = '1') THEN
			Q <= '1';
		ELSIF (C = '0' AND C'EVENT) THEN
				Q <= D;
		END IF;
	END PROCESS;
END ARCHITECTURE behaviour;
------------------------------------------
