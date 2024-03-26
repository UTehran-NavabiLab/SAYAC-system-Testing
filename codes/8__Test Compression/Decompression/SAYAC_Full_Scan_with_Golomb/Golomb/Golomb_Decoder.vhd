--******************************************************************************
--	Filename:		Golomb_Decoder.vhd
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
--	Golomb decoder top module, datapath, and controller                              
--******************************************************************************

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Golomb_Decoder_Controller IS 
    PORT( 
        clk            : IN STD_LOGIC;
        rst            : IN STD_LOGIC;

        d_in           : IN STD_LOGIC;
        start          : IN STD_LOGIC;
        eq             : IN STD_LOGIC;
        end_of_TS      : IN STD_LOGIC;
        zero_zero_flag : IN STD_LOGIC;

        cnt_rst        : OUT STD_LOGIC;
        cnt_en         : OUT STD_LOGIC; 
        q_reg_ld       : OUT STD_LOGIC;
        m_reg_ld       : OUT STD_LOGIC;
        r_shr_ld       : OUT STD_LOGIC; 
        r_shr_shift    : OUT STD_LOGIC;
        R_cnt_sel      : OUT STD_LOGIC;
        Z_cnt_sel      : OUT STD_LOGIC; 
        TS_cnt_en      : OUT STD_LOGIC;
        valid          : OUT STD_LOGIC;
        ready          : OUT STD_LOGIC;
        diff_out       : OUT STD_LOGIC;
        TV_cnt_en      : OUT STD_LOGIC
    );
END ENTITY Golomb_Decoder_Controller;

ARCHITECTURE Controller_ARC OF Golomb_Decoder_Controller IS
    --STATE:
    TYPE STATE IS (state_1 ,state_2, state_3, state_4, state_5, state_6, state_7, state_8, state_9);
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

    STATE_TRANSITION:   PROCESS (PSTATE ,start, d_in, eq, zero_zero_flag, end_of_TS)
    BEGIN
        NSTATE<=state_1; --INACTIVE VALUE
        q_reg_ld <= '0';
        CASE PSTATE IS
            WHEN state_1 =>
                IF (start='0' OR end_of_TS = '1') THEN 
                    NSTATE <= state_1;
                ELSE
                    NSTATE <= state_2;
                END IF ;
                
            WHEN state_2 =>
                IF (d_in = '1') THEN
                    NSTATE <= state_3;
                ELSE
                    NSTATE <= state_4;
                    q_reg_ld <= '1';
                END IF;
                    
            WHEN state_3 =>
                NSTATE <= state_2;

            WHEN state_4 =>
                    NSTATE <= state_5;
    
            WHEN state_5 =>
                IF ( eq  = '0') THEN
                    NSTATE <= state_6;
                ELSE 
                    NSTATE <= state_7;
                END If;

            WHEN state_6 =>
                NSTATE <= state_5;

            WHEN state_7 =>
                IF (zero_zero_flag = '1') THEN
                    NSTATE <= state_9;
                ELSIF end_of_TS ='1' THEN
                    NSTATE <= state_1;
                ELSE 
                    NSTATE <= state_8;
                END IF;
                
            WHEN state_8 =>
                IF ( eq  = '0') THEN
                    NSTATE <= state_8;
                ELSIF end_of_TS ='1' THEN
                    NSTATE <= state_1;
                ELSE  
                    NSTATE <= state_9;
                END If;
            
            WHEN state_9 => 
                NSTATE <= state_2; 
        END CASE;
    END PROCESS;

    OUTPUTS:   PROCESS (PSTATE, eq) 
    BEGIN
        --INITIALIZATION:
        cnt_rst     <= '0';
        cnt_en      <= '0';
        m_reg_ld    <= '0';
        r_shr_ld    <= '0'; 
        r_shr_shift <= '0'; 
        R_cnt_sel   <= '0'; 
        Z_cnt_sel   <= '0'; 
        ready       <= '0';
        valid       <= '0'; 
        TV_cnt_en   <= '0'; 
        TS_cnt_en   <= '0';  
        diff_out    <= '0';
        CASE PSTATE IS
            WHEN state_1 =>
                cnt_rst  <= '1';
                m_reg_ld <= '1';

            WHEN state_2 =>
                ready <= '1';

                
            WHEN state_3 =>
                cnt_en <= '1';

            WHEN state_4 =>
                cnt_rst <= '1';

            WHEN state_5 =>
                IF (eq = '0') THEN
                    ready <= '1';
                END IF;
                R_cnt_sel <='1';

            WHEN state_6 =>
                cnt_en <= '1';
                r_shr_shift <= '1';
                r_cnt_sel <='1';

            WHEN state_7 =>
                cnt_rst <= '1';
                diff_out <= '1';
                valid <= '1';
                TS_cnt_en <= '1';
                TV_cnt_en <= '1';

            WHEN state_8 =>
                cnt_en <= '1';
                diff_out <= '0';
                Z_cnt_sel <= '1';
                valid <= '1';
                TS_cnt_en <= '1';
                TV_cnt_en <= '1';

            WHEN state_9 =>
                cnt_rst <= '1';                
            WHEN OTHERS=>
        END CASE;
    END PROCESS;
END ARCHITECTURE Controller_ARC;
-- -------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.numeric_std.ALL;

ENTITY Golomb_Decoder_DP IS
    GENERIC (
        TV_Length : INTEGER := 293;
        TS_Length : INTEGER := 398
        );
    PORT(
        clk            : IN STD_LOGIC;
        rst            : IN STD_LOGIC;
        d_in           : IN STD_LOGIC;
        m_input        : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        cnt_rst        : IN STD_LOGIC; 
        cnt_en         : IN STD_LOGIC;
        q_reg_ld       : IN STD_LOGIC;
        m_reg_ld       : IN STD_LOGIC;
        r_shr_ld       : IN STD_LOGIC;
        r_shr_shift    : IN STD_LOGIC;
        R_cnt_sel      : IN STD_LOGIC;
        Z_cnt_sel      : IN STD_LOGIC;
        TV_cnt_en      : IN STD_LOGIC;
        TS_cnt_en      : IN STD_LOGIC;

        eq             : OUT STD_LOGIC;
        zero_zero_flag : OUT STD_LOGIC;
        end_of_TS      : OUT STD_LOGIC
   );
END ENTITY Golomb_Decoder_DP;

ARCHITECTURE DP_ARC OF Golomb_Decoder_DP IS
    SIGNAL r_shr_parout      : STD_LOGIC_VECTOR (1 DOWNTO 0);
    SIGNAL cnt_out           : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL q_reg_out         : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL cmp_in,log_2m_reg : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL TV_cnt_out        : STD_LOGIC_VECTOR (11 DOWNTO 0);
    SIGNAL m_reg_out         : STD_LOGIC_VECTOR (2 DOWNTO 0);
    SIGNAL mul_out           : STD_LOGIC_VECTOR (10 DOWNTO 0);
    SIGNAL num_of_zeros      : STD_LOGIC_VECTOR (10 DOWNTO 0);
    SIGNAL TS_cnt_out        : STD_LOGIC_VECTOR (8 DOWNTO 0);
    SIGNAL end_of_TV         : STD_LOGIC :='0';
    SIGNAL TV_cnt_rst        : STD_LOGIC :='0';
    SIGNAL TS_cnt_rst        : STD_LOGIC :='0';
BEGIN
    log_2m_reg <= B"00000010"; -- 2
    --Q_reg INSTANCE:
    q_reg : ENTITY WORK.GENERIC_REG GENERIC MAP(8)
         PORT MAP (
            clk     => clk, 
            rst     => rst, 
            ld      => q_reg_ld, 
            reg_in  => cnt_out, 
            reg_out => q_reg_out
            );
    --M_reg INSTANCE:
    m_reg : ENTITY WORK.GENERIC_REG GENERIC MAP(3) 
        PORT MAP (
            clk     => clk, 
            rst     => rst, 
            ld      => m_reg_ld, 
            reg_in  => m_input, 
            reg_out => m_reg_out
            );
    --R_shr INSTANCE:
    r_shr: ENTITY WORK.GENERIC_SHIFT_REG GENERIC MAP(2, '1') 
        PORT MAP (
            clk     => clk, 
            rst     => rst, 
            ld      => r_shr_ld, 
            shift   => r_shr_shift, 
            par_in  => (OTHERS => '0'), 
            par_out => r_shr_parout, 
            Sin     => d_in
            ); 
    --MULTIPLEXER INSTANCE:
    comp_mux: ENTITY WORK.Mux2to1 
        PORT MAP (
            in0   => log_2m_reg, 
            in1   => num_of_zeros(7 DOWNTO 0), 
            sel0  => R_cnt_sel, 
            sel1  => Z_cnt_sel, 
            out_p => cmp_in
            );
    --COUNTER INSTANCE:
    golomb_counter: ENTITY WORK.COUNTER GENERIC MAP(inputbit=>8) 
        PORT MAP (
            clk    => clk,
            rst    => cnt_rst, 
            en     => cnt_en, 
            output => cnt_out
            );
    --COUNTER INSTANCE: To count the test vector length
    TV_Len_counter: ENTITY WORK.COUNTER GENERIC MAP(inputbit=>12) 
        PORT MAP (
            clk    => clk, 
            rst    => TV_cnt_rst, 
            en     => TV_cnt_en, 
            output => TV_cnt_out
            );
    --COUNTER INSTANCE: To count the number of test vectors
    TS_counter: ENTITY WORK.COUNTER GENERIC MAP(inputbit=>9) 
        PORT MAP (
            clk    => end_of_TV, 
            rst    => rst, 
            en     => '1', 
            output => TS_cnt_out
            );
    --COMPARATORS:
    eq <= '1' WHEN cnt_out = cmp_in ELSE '0';
    end_of_TS <= '1' WHEN TS_cnt_out = std_logic_vector(to_unsigned(TS_Length, TS_cnt_out'length)) ELSE '0';
    end_of_TV <= '1' WHEN TV_cnt_out = std_logic_vector(to_unsigned(TV_Length-1, TV_cnt_out'length)) ELSE '0';
    TV_cnt_rst <= '1' WHEN TV_cnt_out = std_logic_vector(to_unsigned(TV_Length, TV_cnt_out'length)) OR rst = '1'ELSE '0';
    --Concurrent Assignments:
    mul_out <= m_reg_out * q_reg_out;
    zero_zero_flag <= '1' WHEN (mul_out) + r_shr_parout = "00000000000" ELSE '0';
    num_of_zeros <= (mul_out) +r_shr_parout - 1 WHEN ((mul_out) +r_shr_parout /= "00000000000") ELSE (mul_out) +r_shr_parout ;
    
END ARCHITECTURE DP_ARC;

-- -------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Golomb_Decoder_TOP IS 
GENERIC (
    TV_Length : INTEGER := 293;
    TS_Length : INTEGER := 398
    );
PORT(
        clk            : IN STD_LOGIC;
        rst            : IN STD_LOGIC;
        d_in           : IN STD_LOGIC;
        start          : IN STD_LOGIC;
        m_input        : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        valid          : OUT STD_LOGIC;
        ready          : OUT STD_LOGIC;
        difference_out : OUT STD_LOGIC
    );
END ENTITY Golomb_Decoder_TOP;

ARCHITECTURE TOP_ARC OF Golomb_Decoder_TOP IS
    SIGNAL cnt_rst_wire        : STD_LOGIC;
    SIGNAL cnt_en_wire         : STD_LOGIC;
    SIGNAL q_reg_ld_wire       : STD_LOGIC;
    SIGNAL m_reg_ld_wire       : STD_LOGIC;
    SIGNAL r_shr_ld_wire       : STD_LOGIC;
    SIGNAL r_shr_shift_wire    : STD_LOGIC;
    SIGNAL R_cnt_sel_wire      : STD_LOGIC;
    SIGNAL Z_cnt_sel_wire      : STD_LOGIC;
    SIGNAL eq_wire             : STD_LOGIC;
    SIGNAL zero_zero_flag_wire : STD_LOGIC;
    SIGNAL TV_cnt_en_wire      : STD_LOGIC;
    SIGNAL TS_cnt_en_wire      : STD_LOGIC;
    SIGNAL end_of_TS_wire      : STD_LOGIC;
BEGIN
--DATA PATH INSTANTIATION:
    DataPath: ENTITY WORK.Golomb_Decoder_DP(DP_ARC) 
        GENERIC MAP (TV_Length, TS_Length)
        PORT MAP (
            clk            => clk, 
            rst            => rst,
            d_in           => d_in, 
            m_input        => m_input, 
            cnt_rst        => cnt_rst_wire, 
            cnt_en         => cnt_en_wire, 
            q_reg_ld       => q_reg_ld_wire,
            m_reg_ld       => m_reg_ld_wire,
            r_shr_ld       => r_shr_ld_wire,
            r_shr_shift    => r_shr_shift_wire,
            R_cnt_sel      => R_cnt_sel_wire,
            Z_cnt_sel      => Z_cnt_sel_wire,
            eq             => eq_wire,
            zero_zero_flag => zero_zero_flag_wire, 
            TV_cnt_en      => TV_cnt_en_wire, 
            TS_cnt_en      => TS_cnt_en_wire, 
            end_of_TS      => end_of_TS_wire
        );

--CONTROLLER INSTANTIATION:
    Controller : ENTITY WORK.Golomb_Decoder_Controller(Controller_ARC) 
        PORT MAP (
            clk            => clk, 
            rst            => rst,
            d_in           => d_in,
            start          => start,
            cnt_rst        => cnt_rst_wire, 
            cnt_en         => cnt_en_wire, 
            q_reg_ld       => q_reg_ld_wire, 
            m_reg_ld       => m_reg_ld_wire,
            r_shr_ld       => r_shr_ld_wire, 
            r_shr_shift    => r_shr_shift_wire,
            R_cnt_sel      => R_cnt_sel_wire, 
            Z_cnt_sel      => Z_cnt_sel_wire, 
            eq             => eq_wire,
            valid          => valid, 
            ready          => ready, 
            diff_out       => difference_out, 
            zero_zero_flag => zero_zero_flag_wire, 
            TV_cnt_en      => TV_cnt_en_wire, 
            TS_cnt_en      => TS_cnt_en_wire, 
            end_of_TS      => end_of_TS_wire
        );
END ARCHITECTURE TOP_ARC ;

