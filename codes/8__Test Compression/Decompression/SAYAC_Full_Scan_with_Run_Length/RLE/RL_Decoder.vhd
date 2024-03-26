--******************************************************************************
--	Filename:		RL_Decoder.vhd
--	Project:		SAYAC Testing 
--  Version:		0.90
--	History:
--	Date:			18 November 2023
--	Last Author: 	Delaram
--  Copyright (C) 2023 University of Tehran
--  This source file may be used and distributed without
--  restriction provided that this copyright statement is not
--  removed from the file and that any derivative work contains
--  the original copyright notice and the associated disclaimer.
--
--******************************************************************************
--	File content description:
--	Run lengh decoder top module, datapath, and controller                              
--******************************************************************************

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY RL_Decoder_Controller IS 
    PORT( 
        clk            : IN STD_LOGIC;
        rst            : IN STD_LOGIC;
        start          : IN STD_LOGIC;
        
        lcw_eq         : IN STD_LOGIC;
        numz_eq        : IN STD_LOGIC;
        min_val_flag   : IN STD_LOGIC;
        max_val_flag   : IN STD_LOGIC;
        end_of_TS      : IN STD_LOGIC;

        numz_shr_ld    : OUT STD_LOGIC;
        numz_shr_shift : OUT STD_LOGIC;
        lcw_cnt_rst    : OUT STD_LOGIC;
        lcw_cnt_en     : OUT STD_LOGIC;
        numz_cnt_rst   : OUT STD_LOGIC;
        numz_cnt_en    : OUT STD_LOGIC;
        valid          : OUT STD_LOGIC;
        ready          : OUT STD_LOGIC;
        diff_out       : OUT STD_LOGIC;
        TV_cnt_en      : OUT STD_LOGIC
    );
END ENTITY RL_Decoder_Controller;

ARCHITECTURE Controller_ARC OF RL_Decoder_Controller IS
--STATE:
    TYPE STATE IS (state_1 ,state_2, state_3, state_4, state_5, state_6, state_7);
    SIGNAL PSTATE, NSTATE : STATE;
BEGIN
--proccesses:
    NEXT_STATE:   PROCESS (clk , rst)
    BEGIN
            IF rst = '1' THEN
                PSTATE<= state_1;
            ELSIF clk = '1' AND clk'EVENT THEN 
                PSTATE <= NSTATE;
            END IF;
    END PROCESS;

    STATE_TRANSITION:   PROCESS (PSTATE ,start, lcw_eq, numz_eq, min_val_flag, max_val_flag, end_of_TS) BEGIN
        NSTATE<=state_1; --INACTIVE VALUE
        CASE PSTATE IS
            WHEN state_1 =>
                IF (start='0' OR end_of_TS = '1') THEN 
                    NSTATE <= state_1;
                ELSE 
                    NSTATE <= state_2;
                END IF ;
                
            WHEN state_2 =>
                IF (lcw_eq = '1')THEN
                    NSTATE <= state_3;
                ELSE
                    NSTATE <= state_2;
                END IF;

            WHEN state_3 =>
                IF (max_val_flag = '1') THEN
                    NSTATE <= state_7;
                ELSE
                    NSTATE <= state_4;
                END IF;
                    
            WHEN state_4 =>
                IF (min_val_flag = '1') THEN
                    NSTATE <= state_2;
                ELSIF end_of_TS ='1' THEN
                    NSTATE <= state_1;
                ELSE 
                    NSTATE <= state_5;
                END IF;

            WHEN state_5 =>
                IF (numz_eq = '1') THEN
                    NSTATE <= state_6;
                ELSIF end_of_TS ='1' THEN
                    NSTATE <= state_1;
                ELSE
                    NSTATE <= state_5;
                END IF;
            
            WHEN state_6 =>
                IF end_of_TS ='1' THEN
                    NSTATE <= state_1;
                ELSE
                    NSTATE <= state_2;
                END IF;

            WHEN state_7 =>
                NSTATE <= state_5;
            
            WHEN OTHERS=>
        END CASE;
    END PROCESS;

    OUTPUTS:   PROCESS (PSTATE, max_val_flag) BEGIN
        --INITIALIZATION:
        numz_shr_ld    <= '0'; 
        numz_shr_shift <= '0'; 
        lcw_cnt_rst    <= '0'; 
        lcw_cnt_en     <= '0'; 
        numz_cnt_rst   <= '0'; 
        numz_cnt_en    <= '0';    
        ready          <= '0';
        valid          <= '0';
        TV_cnt_en      <= '0'; 
        diff_out       <= '0';
        CASE PSTATE IS
            WHEN state_1 =>
                lcw_cnt_rst <= '1';
            
            WHEN state_2 =>
                ready          <= '1';
                numz_shr_shift <= '1';
                lcw_cnt_en     <= '1';
                
            WHEN state_3 =>
                IF (max_val_flag = '1') THEN
                    lcw_cnt_rst <= '1';
                END IF;

            WHEN state_4 =>
                diff_out    <= '1';
                valid       <= '1';    
                lcw_cnt_rst <= '1';
                TV_cnt_en   <= '1';
                
            WHEN state_5 =>
                lcw_cnt_en <= '1'; 
                valid      <= '1';
                TV_cnt_en  <= '1';
            
            WHEN state_6 =>
                lcw_cnt_rst <= '1'; 

            WHEN state_7 =>
                lcw_cnt_rst <= '1'; 

            WHEN OTHERS=>
        END CASE;
    END PROCESS;
END ARCHITECTURE Controller_ARC;


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.numeric_std.ALL;

ENTITY RL_Decoder_DP IS
    GENERIC (
        TV_Length : INTEGER := 293;
        TS_Length : INTEGER := 398;
        lcw       : INTEGER := 3
        );
    PORT(
        clk            :IN STD_LOGIC;
        rst            :IN STD_LOGIC;

        d_in           : IN STD_LOGIC;
        numz_shr_ld    : IN STD_LOGIC;
        numz_shr_shift : IN STD_LOGIC;
        lcw_cnt_rst    : IN STD_LOGIC;
        lcw_cnt_en     : IN STD_LOGIC;
        numz_cnt_rst   : IN STD_LOGIC;
        numz_cnt_en    : IN STD_LOGIC;
        TV_cnt_en      : IN STD_LOGIC;
        lcw_eq         : OUT STD_LOGIC;
        numz_eq        : OUT STD_LOGIC;
        max_val_flag   : OUT STD_LOGIC;
        min_val_flag   : OUT STD_LOGIC;
        end_of_TS      : OUT STD_LOGIC
   );
END ENTITY RL_Decoder_DP;

ARCHITECTURE DP_ARC OF RL_Decoder_DP IS

    -- SIGNAL lcw_reg_out       : STD_LOGIC_VECTOR(lcw-1 DOWNTO 0);
    SIGNAL numz_shr_parout   : STD_LOGIC_VECTOR(lcw-1 DOWNTO 0);
    SIGNAL lcw_cnt_out       : STD_LOGIC_VECTOR(lcw-1 DOWNTO 0);
    SIGNAL mux_out           : STD_LOGIC_VECTOR(lcw-1 DOWNTO 0);
    SIGNAL TV_cnt_out        : STD_LOGIC_VECTOR(11 DOWNTO 0);
    SIGNAL TS_cnt_out        : STD_LOGIC_VECTOR(8 DOWNTO 0);
    SIGNAL end_of_TV         : STD_LOGIC :='0';
    SIGNAL end_of_TV_wire    : STD_LOGIC :='0';
    SIGNAL end_of_TS_wire    : STD_LOGIC :='0';
    SIGNAL TV_cnt_rst        : STD_LOGIC :='0';
    SIGNAL not_max           : STD_LOGIC :='0';
    SIGNAL max_val_flag_wire : STD_LOGIC := '0';
    SIGNAL max_val           : STD_LOGIC_VECTOR(lcw-1 DOWNTO 0) := (OTHERS => '1');
    SIGNAL min_val           : STD_LOGIC_VECTOR(lcw-1 DOWNTO 0) := (OTHERS => '0');
BEGIN
    --numz_shr INSTANCE:
    numz_shr: ENTITY WORK.GENERIC_SHIFT_REG GENERIC MAP(lcw, '1') 
        PORT MAP (
            clk     => clk, 
            rst     => rst, 
            ld      => numz_shr_ld, 
            shift   => numz_shr_shift, 
            par_in  => (OTHERS => '0'), 
            par_out => numz_shr_parout, 
            Sin     => d_in
            ); 

    --counter INSTANCE:
    lcw_counter: ENTITY WORK.COUNTER GENERIC MAP(inputbit=>lcw) 
        PORT MAP (
            clk    => clk, 
            rst    => lcw_cnt_rst,
            en     => lcw_cnt_en, 
            output => lcw_cnt_out
            );
    
    multiplexer: ENTITY WORK.Mux2to1 
        PORT MAP (
            in0   => numz_shr_parout, 
            in1   => max_val, 
            sel0  => not_max, 
            sel1  => max_val_flag_wire, 
            out_P => mux_out 
            );

    --counter INSTANCE: To count the test vector and test set length
    TV_Len_counter: ENTITY WORK.COUNTER GENERIC MAP(inputbit=>12) 
        PORT MAP (
            clk    => clk, 
            rst    => TV_cnt_rst, 
            en     => TV_cnt_en, 
            output => TV_cnt_out
            );
    TS_counter: ENTITY WORK.COUNTER GENERIC MAP(inputbit=>9) 
        PORT MAP (
            clk    => end_of_TV, 
            rst    => rst, 
            en     => '1', 
            output => TS_cnt_out
            );

    TV_cnt_rst <= '1' WHEN (TV_cnt_out = std_logic_vector(to_unsigned(TV_Length, TV_cnt_out'length)) OR rst = '1') ELSE '0';
    end_of_TV_wire <= '1' WHEN (TV_cnt_out = std_logic_vector(to_unsigned(TV_Length-1, TV_cnt_out'length)) AND end_of_TS_wire = '0') ELSE '0';
    end_of_TS_wire <= '1' WHEN (TS_cnt_out = std_logic_vector(to_unsigned(TS_Length, TS_cnt_out'length)) AND end_of_TV_wire = '0') ELSE '0';

    end_of_TV <= end_of_TV_wire;
    end_of_TS <= end_of_TS_wire;
    
    -- COPMARATORS
    lcw_eq <= '1' WHEN (lcw_cnt_out) = std_logic_vector(to_unsigned(lcw, lcw_cnt_out'length)-1) ELSE '0';
    numz_eq <= '1' WHEN (mux_out-1) = lcw_cnt_out ELSE '0';
    max_val_flag_wire <= '1' WHEN (numz_shr_parout = max_val) ELSE '0';
    max_val_flag <= max_val_flag_wire;
    min_val_flag <= '1' WHEN (numz_shr_parout = min_val) ELSE '0';
    not_max <= NOT(max_val_flag_wire);
    
END ARCHITECTURE DP_ARC;

-- -------------------------------------------------------------

library ieee;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.Numeric_Std.all;


ENTITY RL_Decoder_TOP IS 
GENERIC (
    TV_Length : INTEGER := 293;
    TS_Length : INTEGER := 398;
    lcw       : INTEGER := 3
    );
PORT(
    clk      : IN STD_LOGIC;
    rst      : IN STD_LOGIC;
    d_in     : IN STD_LOGIC;
    start    : IN STD_LOGIC;

    valid    : OUT STD_LOGIC;
    ready    : OUT STD_LOGIC;
    diff_out : OUT STD_LOGIC
    );
END ENTITY RL_Decoder_TOP;

ARCHITECTURE TOP_ARC OF RL_Decoder_TOP IS
    SIGNAL numz_shr_ld_wire    : STD_LOGIC;
    SIGNAL numz_shr_shift_wire : STD_LOGIC;
    SIGNAL lcw_cnt_rst_wire    : STD_LOGIC;
    SIGNAL lcw_cnt_en_wire     : STD_LOGIC;
    SIGNAL numz_cnt_rst_wire   : STD_LOGIC;
    SIGNAL numz_cnt_en_wire    : STD_LOGIC;
    SIGNAL lcw_eq_wire         : STD_LOGIC;
    SIGNAL numz_eq_wire        : STD_LOGIC;
    SIGNAL min_val_flag_wire   : STD_LOGIC;
    SIGNAL max_val_flag_wire   : STD_LOGIC;
    SIGNAL TV_cnt_en_wire      : STD_LOGIC;
    SIGNAL end_of_TS_wire      : STD_LOGIC;
    SIGNAL difference_out      : STD_LOGIC;
    BEGIN
--DATA PATH INSTANTIATION:
    DataPath: ENTITY WORK.RL_Decoder_DP(DP_ARC)     
        GENERIC MAP (TV_Length, TS_Length)
        PORT MAP (
            clk            => clk, 
            rst            => rst,
            d_in           => d_in,
            numz_shr_ld    => numz_shr_ld_wire, 
            numz_shr_shift => numz_shr_shift_wire,
            lcw_cnt_rst    => lcw_cnt_rst_wire, 
            lcw_cnt_en     => lcw_cnt_en_wire,
            numz_cnt_rst   => numz_cnt_rst_wire, 
            numz_cnt_en    => numz_cnt_en_wire, 
            lcw_eq         => lcw_eq_wire, 
            numz_eq        => numz_eq_wire,
            min_val_flag   => min_val_flag_wire, 
            max_val_flag   => max_val_flag_wire, 
            TV_cnt_en      => TV_cnt_en_wire, 
            end_of_TS      => end_of_TS_wire
            );
--CONTROLLER INSTANTIATION:
    Controller : ENTITY WORK.RL_Decoder_Controller(Controller_ARC) 
        PORT MAP (
            clk            => clk, 
            rst            => rst,
            start          => start,
            numz_shr_ld    => numz_shr_ld_wire, 
            numz_shr_shift => numz_shr_shift_wire,
            lcw_cnt_rst    => lcw_cnt_rst_wire, 
            lcw_cnt_en     => lcw_cnt_en_wire,
            numz_cnt_rst   => numz_cnt_rst_wire, 
            numz_cnt_en    => numz_cnt_en_wire, 
            lcw_eq         => lcw_eq_wire, 
            numz_eq        => numz_eq_wire,
            min_val_flag   => min_val_flag_wire, 
            max_val_flag   => max_val_flag_wire,
            valid          => valid, 
            ready          => ready, 
            diff_out       => diff_out, 
            TV_cnt_en      => TV_cnt_en_wire, 
            end_of_TS      => end_of_TS_wire
            );
END ARCHITECTURE TOP_ARC ;

