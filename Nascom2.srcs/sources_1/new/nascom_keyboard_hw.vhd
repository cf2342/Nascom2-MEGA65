LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY nascom_keyboard_hw IS
    PORT (
        clk          : IN  STD_LOGIC;
        reset        : IN  STD_LOGIC;

        -- P0 latch from motherboard keyboard control
        -- bit 0 = clock keyboard count
        -- bit 1 = reset keyboard count
        port0_reg    : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);

        -- key states from PS/2 mapping
        nk_0         : IN  STD_LOGIC;
        nk_1         : IN  STD_LOGIC;
        nk_2         : IN  STD_LOGIC;
        nk_3         : IN  STD_LOGIC;
        nk_4         : IN  STD_LOGIC;
        nk_5         : IN  STD_LOGIC;
        nk_6         : IN  STD_LOGIC;
        nk_7         : IN  STD_LOGIC;
        nk_8         : IN  STD_LOGIC;
        nk_9         : IN  STD_LOGIC;
        nk_a         : IN  STD_LOGIC;
        nk_b         : IN  STD_LOGIC;
        nk_c         : IN  STD_LOGIC;
        nk_d         : IN  STD_LOGIC;
        nk_e         : IN  STD_LOGIC;
        nk_f         : IN  STD_LOGIC;
        nk_g         : IN  STD_LOGIC;
        nk_h         : IN  STD_LOGIC;
        nk_i         : IN  STD_LOGIC;
        nk_j         : IN  STD_LOGIC;
        nk_k         : IN  STD_LOGIC;
        nk_l         : IN  STD_LOGIC;
        nk_m         : IN  STD_LOGIC;
        nk_n         : IN  STD_LOGIC;
        nk_o         : IN  STD_LOGIC;
        nk_p         : IN  STD_LOGIC;
        nk_q         : IN  STD_LOGIC;
        nk_r         : IN  STD_LOGIC;
        nk_s         : IN  STD_LOGIC;
        nk_t         : IN  STD_LOGIC;
        nk_u         : IN  STD_LOGIC;
        nk_v         : IN  STD_LOGIC;
        nk_w         : IN  STD_LOGIC;
        nk_x         : IN  STD_LOGIC;
        nk_y         : IN  STD_LOGIC;
        nk_z         : IN  STD_LOGIC;
        nk_sp        : IN  STD_LOGIC;
        nk_sh        : IN  STD_LOGIC;
        nk_ct        : IN  STD_LOGIC;
        nk_nl        : IN  STD_LOGIC;
        nk_bs        : IN  STD_LOGIC;
        nk_pu        : IN  STD_LOGIC;
        nk_pd        : IN  STD_LOGIC;
        nk_pl        : IN  STD_LOGIC;
        nk_pr        : IN  STD_LOGIC;
        nk_gr        : IN  STD_LOGIC;
        nk_tb        : IN  STD_LOGIC;
        nk_at        : IN  STD_LOGIC;
        nk_plus      : IN  STD_LOGIC;
        nk_star      : IN  STD_LOGIC;
        nk_comma     : IN  STD_LOGIC;
        nk_dot       : IN  STD_LOGIC;
        nk_minus     : IN  STD_LOGIC;
        nk_slash     : IN  STD_LOGIC;
        nk_lb        : IN  STD_LOGIC;
        nk_rb        : IN  STD_LOGIC;

        -- keyboard readback to CPU port 00h, active low
        kbd_data     : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END ENTITY nascom_keyboard_hw;

ARCHITECTURE rtl OF nascom_keyboard_hw IS

    SIGNAL kbd_count      : UNSIGNED(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL port0_clk_last : STD_LOGIC := '0';
    SIGNAL port0_reset_last : STD_LOGIC := '0';

    SIGNAL kbd_data_r     : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"FF";

    SIGNAL nk_sp_snap     : STD_LOGIC := '0';
    SIGNAL nk_sh_snap     : STD_LOGIC := '0';
    SIGNAL nk_ct_snap     : STD_LOGIC := '0';
    SIGNAL nk_nl_snap     : STD_LOGIC := '0';
    SIGNAL nk_nl_consumed : STD_LOGIC := '0';
    SIGNAL nk_bs_snap     : STD_LOGIC := '0';
    SIGNAL nk_pu_snap     : STD_LOGIC := '0';
    SIGNAL nk_pd_snap     : STD_LOGIC := '0';
    SIGNAL nk_pl_snap     : STD_LOGIC := '0';
    SIGNAL nk_pr_snap     : STD_LOGIC := '0';
    SIGNAL nk_gr_snap     : STD_LOGIC := '0';
    SIGNAL nk_tb_snap     : STD_LOGIC := '0';
    SIGNAL nk_at_snap     : STD_LOGIC := '0';
    SIGNAL nk_plus_snap   : STD_LOGIC := '0';
    SIGNAL nk_star_snap   : STD_LOGIC := '0';
    SIGNAL nk_comma_snap  : STD_LOGIC := '0';
    SIGNAL nk_dot_snap    : STD_LOGIC := '0';
    SIGNAL nk_minus_snap  : STD_LOGIC := '0';
    SIGNAL nk_slash_snap  : STD_LOGIC := '0';
    SIGNAL nk_lb_snap     : STD_LOGIC := '0';
    SIGNAL nk_rb_snap     : STD_LOGIC := '0';

BEGIN

    kbd_data <= kbd_data_r;

    --------------------------------------------------------------------
    -- Keyboard counter
    --
    -- P0 bit 1 = reset keyboard count
    -- P0 bit 0 = clock keyboard count
    --------------------------------------------------------------------
    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF reset = '1' THEN
                kbd_count <= (OTHERS => '0');
                port0_clk_last <= '0';
            ELSE
                -- remember previous state of P0 bit 0
                port0_clk_last <= port0_reg(0);

                -- reset has priority
                IF port0_reg(1) = '1' THEN
                    kbd_count <= (OTHERS => '0');

                -- rising edge on P0 bit 0 clocks the keyboard counter
                ELSIF port0_clk_last = '0' AND port0_reg(0) = '1' THEN
                    IF kbd_count = "111" THEN
                        kbd_count <= (OTHERS => '0');
                    ELSE
                        kbd_count <= kbd_count + 1;
                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    --------------------------------------------------------------------
    -- Snapshot selected special-key states at the beginning of a scan
    --
    -- This keeps synthetic or convenience mappings stable across a full
    -- Nascom scan sequence instead of letting them drift with live key
    -- timing inside one keyboard poll.
    --------------------------------------------------------------------
    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF reset = '1' THEN
                nk_sp_snap <= '0';
                nk_sh_snap <= '0';
                nk_ct_snap <= '0';
                nk_nl_snap <= '0';
                nk_nl_consumed <= '0';
                port0_reset_last <= '0';
                nk_bs_snap <= '0';
                nk_pu_snap <= '0';
                nk_pd_snap <= '0';
                nk_pl_snap <= '0';
                nk_pr_snap <= '0';
                nk_gr_snap <= '0';
                nk_tb_snap <= '0';
                nk_at_snap <= '0';
                nk_plus_snap <= '0';
                nk_star_snap <= '0';
                nk_comma_snap <= '0';
                nk_dot_snap <= '0';
                nk_minus_snap <= '0';
                nk_slash_snap <= '0';
                nk_lb_snap <= '0';
                nk_rb_snap <= '0';
            ELSE
                port0_reset_last <= port0_reg(1);

                IF nk_nl = '0' THEN
                    nk_nl_consumed <= '0';
                END IF;

                IF port0_reset_last = '0' AND port0_reg(1) = '1' THEN
                    nk_sp_snap <= nk_sp;
                    nk_sh_snap <= nk_sh;
                    nk_ct_snap <= nk_ct;
                    IF nk_nl = '0' THEN
                        nk_nl_snap <= '0';
                        nk_nl_consumed <= '0';
                    ELSIF nk_nl_consumed = '0' THEN
                        nk_nl_snap <= '1';
                        nk_nl_consumed <= '1';
                    ELSE
                        nk_nl_snap <= '0';
                    END IF;
                    nk_bs_snap <= nk_bs;
                    nk_pu_snap <= nk_pu;
                    nk_pd_snap <= nk_pd;
                    nk_pl_snap <= nk_pl;
                    nk_pr_snap <= nk_pr;
                    nk_gr_snap <= nk_gr;
                    nk_tb_snap <= nk_tb;
                    nk_at_snap <= nk_at;
                    nk_plus_snap <= nk_plus;
                    nk_star_snap <= nk_star;
                    nk_comma_snap <= nk_comma;
                    nk_dot_snap <= nk_dot;
                    nk_minus_snap <= nk_minus;
                    nk_slash_snap <= nk_slash;
                    nk_lb_snap <= nk_lb;
                    nk_rb_snap <= nk_rb;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    --------------------------------------------------------------------
    -- Keyboard readback
    --
    -- Current mapping for letters and digits:
    --   derived from the NASSYS keyboard table in helper/Nassys3.mac
    --   and anchored by the confirmed A = S5 / D4 test.
    --
    -- CPU bit assignment from your note:
    --   bit0 = S1
    --   bit1 = S2
    --   bit2 = S0
    --   bit3 = S4
    --   bit4 = S5
    --   bit5 = S3
    --   bit6 = S6
    --
    -- The confirmed A path gave:
    --   key status code 2Ch -> row 5, bit 4
    --   hardware scan position D4 -> kbd_count = "100"
    --
    -- The remaining unshifted letters/digits in the NASSYS table are
    -- mapped here using the same row/bit interpretation.
    --------------------------------------------------------------------
    PROCESS (ALL)
        VARIABLE tmp : STD_LOGIC_VECTOR(7 DOWNTO 0);
    BEGIN
        tmp := x"FF";

        CASE kbd_count IS
            WHEN "000" =>  -- D0
                IF nk_tb_snap = '1' THEN
                    tmp(6) := '0';
                END IF;
                IF nk_bs_snap = '1' THEN
                    tmp(0) := '0';
                END IF;
                IF nk_nl_snap = '1' THEN
                    tmp(1) := '0';
                END IF;
                IF nk_minus_snap = '1' THEN
                    tmp(2) := '0';
                END IF;
                IF nk_ct_snap = '1' THEN
                    tmp(3) := '0';
                END IF;
                IF nk_sh_snap = '1' THEN
                    tmp(4) := '0';
                END IF;
                IF nk_at_snap = '1' THEN
                    tmp(5) := '0';
                    tmp(4) := '0';
                END IF;
            
            WHEN "001" =>  -- D1
                IF nk_pu_snap = '1' THEN
                    tmp(6) := '0';
                END IF;
                IF nk_h = '1' THEN
                    tmp(0) := '0';
                END IF;
                IF nk_b = '1' THEN
                    tmp(1) := '0';
                END IF;
                IF nk_5 = '1' THEN
                    tmp(2) := '0';
                END IF;
                IF nk_f = '1' THEN
                    tmp(3) := '0';
                END IF;
                IF nk_x = '1' THEN
                    tmp(4) := '0';
                END IF;
                IF nk_t = '1' THEN
                    tmp(5) := '0';
                END IF;

            WHEN "010" =>  -- D2
                IF nk_pl_snap = '1' THEN
                    tmp(6) := '0';
                END IF;
                IF nk_j = '1' THEN
                    tmp(0) := '0';
                END IF;
                IF nk_n = '1' THEN
                    tmp(1) := '0';
                END IF;
                IF nk_6 = '1' THEN
                    tmp(2) := '0';
                END IF;
                IF nk_d = '1' THEN
                    tmp(3) := '0';
                END IF;
                IF nk_z = '1' THEN
                    tmp(4) := '0';
                END IF;
                IF nk_y = '1' THEN
                    tmp(5) := '0';
                END IF;

            WHEN "011" =>  -- D3
                IF nk_pd_snap = '1' THEN
                    tmp(6) := '0';
                END IF;
                IF nk_k = '1' THEN
                    tmp(0) := '0';
                END IF;
                IF nk_m = '1' THEN
                    tmp(1) := '0';
                END IF;
                IF nk_7 = '1' THEN
                    tmp(2) := '0';
                END IF;
                IF nk_e = '1' THEN
                    tmp(3) := '0';
                END IF;
                IF nk_s = '1' THEN
                    tmp(4) := '0';
                END IF;
                IF nk_u = '1' THEN
                    tmp(5) := '0';
                END IF;

            WHEN "100" =>  -- D4
                IF nk_pr_snap = '1' THEN
                    tmp(6) := '0';
                END IF;
                IF nk_comma_snap = '1' THEN
                    tmp(1) := '0';
                END IF;
                IF nk_l = '1' THEN
                    tmp(0) := '0';
                END IF;
                IF nk_8 = '1' THEN
                    tmp(2) := '0';
                END IF;
                IF nk_w = '1' THEN
                    tmp(3) := '0';
                END IF;
                IF nk_a = '1' THEN
                    tmp(4) := '0';
                END IF;
                IF nk_i = '1' THEN
                    tmp(5) := '0';
                END IF;

            WHEN "101" =>  -- D5
                IF nk_gr_snap = '1' THEN
                    tmp(6) := '0';
                END IF;
                IF nk_plus_snap = '1' THEN
                    tmp(0) := '0';
                END IF;
                IF nk_dot_snap = '1' THEN
                    tmp(1) := '0';
                END IF;
                IF nk_9 = '1' THEN
                    tmp(2) := '0';
                END IF;
                IF nk_3 = '1' THEN
                    tmp(3) := '0';
                END IF;
                IF nk_q = '1' THEN
                    tmp(4) := '0';
                END IF;
                IF nk_o = '1' THEN
                    tmp(5) := '0';
                END IF;

            WHEN "110" =>  -- D6
                IF nk_star_snap = '1' THEN
                    tmp(0) := '0';
                END IF;
                IF nk_slash_snap = '1' THEN
                    tmp(1) := '0';
                END IF;
                IF nk_lb_snap = '1' THEN
                    tmp(6) := '0';
                END IF;
                IF nk_0 = '1' THEN
                    tmp(2) := '0';
                END IF;
                IF nk_2 = '1' THEN
                    tmp(3) := '0';
                END IF;
                IF nk_1 = '1' THEN
                    tmp(4) := '0';
                END IF;
                IF nk_p = '1' THEN
                    tmp(5) := '0';
                END IF;

            WHEN "111" =>  -- D7
                IF nk_sp_snap = '1' THEN
                    tmp(4) := '0';
                END IF;
                IF nk_rb_snap = '1' THEN
                    tmp(6) := '0';
                END IF;
                IF nk_g = '1' THEN
                    tmp(0) := '0';
                END IF;
                IF nk_v = '1' THEN
                    tmp(1) := '0';
                END IF;
                IF nk_4 = '1' THEN
                    tmp(2) := '0';
                END IF;
                IF nk_c = '1' THEN
                    tmp(3) := '0';
                END IF;
                IF nk_r = '1' THEN
                    tmp(5) := '0';
                END IF;

            WHEN OTHERS =>
                NULL;
        END CASE;

        kbd_data_r <= tmp;
    END PROCESS;

END ARCHITECTURE rtl;
