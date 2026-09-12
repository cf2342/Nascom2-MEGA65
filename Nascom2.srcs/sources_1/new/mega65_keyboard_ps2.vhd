LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY mega65_keyboard_ps2 IS
    PORT (
        clk      : IN  STD_LOGIC;
        reset    : IN  STD_LOGIC;

        kb_io0   : OUT STD_LOGIC; -- MEGA65 keyboard clock/sync
        kb_io1   : OUT STD_LOGIC; -- MEGA65 keyboard LED data
        kb_io2   : IN  STD_LOGIC; -- MEGA65 keyboard serial key data
        drive_led : IN STD_LOGIC;

        ps2_clk  : OUT STD_LOGIC;
        ps2_data : OUT STD_LOGIC;
        nmi_chord : OUT STD_LOGIC
    );
END ENTITY mega65_keyboard_ps2;

ARCHITECTURE rtl OF mega65_keyboard_ps2 IS
    CONSTANT KBD_DIV_MAX : INTEGER := 64;
    CONSTANT PS2_DIV_MAX : INTEGER := 2500;

    SIGNAL kbd_divider : INTEGER RANGE 0 TO KBD_DIV_MAX := 0;
    SIGNAL kbd_clock   : STD_LOGIC := '0';
    SIGNAL sync_pulse  : STD_LOGIC := '0';
    SIGNAL phase       : INTEGER RANGE 0 TO 140 := 0;
    SIGNAL output_vector : STD_LOGIC_VECTOR(127 DOWNTO 0) := (OTHERS => '0');

    SIGNAL current_keys : STD_LOGIC_VECTOR(127 DOWNTO 0) := (OTHERS => '1');
    SIGNAL last_keys    : STD_LOGIC_VECTOR(73 DOWNTO 0) := (OTHERS => '1');
    SIGNAL scan_idx     : INTEGER RANGE 0 TO 73 := 0;
    SIGNAL deletekey    : STD_LOGIC := '1';
    SIGNAL returnkey    : STD_LOGIC := '1';

    SIGNAL seq_len : INTEGER RANGE 0 TO 3 := 0;
    SIGNAL seq_pos : INTEGER RANGE 0 TO 3 := 0;
    SIGNAL seq_b0  : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL seq_b1  : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL seq_b2  : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');

    SIGNAL tx_active  : STD_LOGIC := '0';
    SIGNAL tx_frame   : STD_LOGIC_VECTOR(10 DOWNTO 0) := (OTHERS => '1');
    SIGNAL tx_bit_idx : INTEGER RANGE 0 TO 10 := 0;
    SIGNAL tx_divider : INTEGER RANGE 0 TO PS2_DIV_MAX := 0;
    SIGNAL tx_low_phase : STD_LOGIC := '0';
    SIGNAL ps2_clk_r  : STD_LOGIC := '1';
    SIGNAL ps2_data_r : STD_LOGIC := '1';

    FUNCTION ps2_code_for(idx : INTEGER) RETURN STD_LOGIC_VECTOR IS
    BEGIN
        CASE idx IS
            WHEN 0  => RETURN x"66"; -- DEL -> Backspace
            WHEN 1  => RETURN x"5A"; -- Return
            WHEN 2  => RETURN x"74"; -- Cursor right
            WHEN 3  => RETURN x"83"; -- F7
            WHEN 4  => RETURN x"05"; -- F1
            WHEN 7  => RETURN x"72"; -- Cursor down
            WHEN 8  => RETURN x"26"; -- 3
            WHEN 9  => RETURN x"1D"; -- W
            WHEN 10 => RETURN x"1C"; -- A
            WHEN 11 => RETURN x"25"; -- 4
            WHEN 12 => RETURN x"1A"; -- Z
            WHEN 13 => RETURN x"1B"; -- S
            WHEN 14 => RETURN x"24"; -- E
            WHEN 15 => RETURN x"12"; -- Left shift
            WHEN 16 => RETURN x"2E"; -- 5
            WHEN 17 => RETURN x"2D"; -- R
            WHEN 18 => RETURN x"23"; -- D
            WHEN 19 => RETURN x"36"; -- 6
            WHEN 20 => RETURN x"21"; -- C
            WHEN 21 => RETURN x"2B"; -- F
            WHEN 22 => RETURN x"2C"; -- T
            WHEN 23 => RETURN x"22"; -- X
            WHEN 24 => RETURN x"3D"; -- 7
            WHEN 25 => RETURN x"35"; -- Y
            WHEN 26 => RETURN x"34"; -- G
            WHEN 27 => RETURN x"3E"; -- 8
            WHEN 28 => RETURN x"32"; -- B
            WHEN 29 => RETURN x"33"; -- H
            WHEN 30 => RETURN x"3C"; -- U
            WHEN 31 => RETURN x"2A"; -- V
            WHEN 32 => RETURN x"46"; -- 9
            WHEN 33 => RETURN x"43"; -- I
            WHEN 34 => RETURN x"3B"; -- J
            WHEN 35 => RETURN x"45"; -- 0
            WHEN 36 => RETURN x"3A"; -- M
            WHEN 37 => RETURN x"42"; -- K
            WHEN 38 => RETURN x"44"; -- O
            WHEN 39 => RETURN x"31"; -- N
            WHEN 40 => RETURN x"4C"; -- +
            WHEN 41 => RETURN x"4D"; -- P
            WHEN 42 => RETURN x"4B"; -- L
            WHEN 43 => RETURN x"4A"; -- -
            WHEN 44 => RETURN x"49"; -- .
            WHEN 45 => RETURN x"52"; -- : key -> Nascom colon
            WHEN 46 => RETURN x"54"; -- @
            WHEN 47 => RETURN x"41"; -- ,
            WHEN 48 => RETURN x"55"; -- MEGA65 English Pound key -> Nascom right bracket
            WHEN 49 => RETURN x"4E"; -- * key -> Nascom left bracket
            WHEN 50 => RETURN x"4C"; -- ; key -> Nascom semicolon
            WHEN 51 => RETURN x"6C"; -- Home
            WHEN 52 => RETURN x"59"; -- Right shift
            WHEN 53 => RETURN x"55"; -- =
            WHEN 55 => RETURN x"5D"; -- /
            WHEN 56 => RETURN x"16"; -- 1
            WHEN 58 => RETURN x"14"; -- Ctrl
            WHEN 59 => RETURN x"1E"; -- 2
            WHEN 60 => RETURN x"29"; -- Space
            WHEN 62 => RETURN x"15"; -- Q
            WHEN 65 => RETURN x"0D"; -- Tab -> Nascom GRAPH
            WHEN 67 => RETURN x"61"; -- Restore/Help -> Nascom LF/CH
            WHEN 5  => RETURN x"04"; -- F3
            WHEN 6  => RETURN x"03"; -- F5
            WHEN 68 => RETURN x"01"; -- F9
            WHEN 69 => RETURN x"78"; -- F11
            WHEN 70 => RETURN x"85"; -- F13 (internal extension)
            WHEN 71 => RETURN x"76"; -- Escape
            WHEN 72 => RETURN x"75"; -- Dedicated cursor up
            WHEN 73 => RETURN x"6B"; -- Dedicated cursor left
            WHEN OTHERS => RETURN x"00";
        END CASE;
    END FUNCTION;

    FUNCTION ps2_ext_for(idx : INTEGER) RETURN STD_LOGIC IS
    BEGIN
        CASE idx IS
            WHEN 2 | 7 | 51 | 72 | 73 => RETURN '1';
            WHEN OTHERS => RETURN '0';
        END CASE;
    END FUNCTION;

    FUNCTION ps2_frame_for(data_byte : STD_LOGIC_VECTOR(7 DOWNTO 0)) RETURN STD_LOGIC_VECTOR IS
        VARIABLE frame_v : STD_LOGIC_VECTOR(10 DOWNTO 0);
        VARIABLE parity_v : STD_LOGIC := '0';
    BEGIN
        frame_v(0) := '0';
        FOR i IN 0 TO 7 LOOP
            frame_v(i + 1) := data_byte(i);
            parity_v := parity_v XOR data_byte(i);
        END LOOP;
        frame_v(9) := NOT parity_v;
        frame_v(10) := '1';
        RETURN frame_v;
    END FUNCTION;

    FUNCTION seq_byte(pos : INTEGER; b0, b1, b2 : STD_LOGIC_VECTOR(7 DOWNTO 0)) RETURN STD_LOGIC_VECTOR IS
    BEGIN
        CASE pos IS
            WHEN 0 => RETURN b0;
            WHEN 1 => RETURN b1;
            WHEN OTHERS => RETURN b2;
        END CASE;
    END FUNCTION;
BEGIN
    ps2_clk <= ps2_clk_r;
    ps2_data <= ps2_data_r;
    -- Direct MEGA65-only path for the manual NMI button.  This level bypasses
    -- PS/2 serialization; the consumer performs edge detection.
    nmi_chord <= '1' WHEN current_keys(51) = '0' AND (
        current_keys(58) = '0' OR current_keys(15) = '0' OR
        current_keys(52) = '0') ELSE '0';

    PROCESS (clk)
        VARIABLE code_v : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE ext_v  : STD_LOGIC;
        VARIABLE frame_v : STD_LOGIC_VECTOR(10 DOWNTO 0);
    BEGIN
        IF rising_edge(clk) THEN
            IF reset = '1' THEN
                kbd_divider <= 0;
                kbd_clock <= '0';
                sync_pulse <= '0';
                phase <= 0;
                output_vector <= (OTHERS => '0');
                current_keys <= (OTHERS => '1');
                last_keys <= (OTHERS => '1');
                scan_idx <= 0;
                deletekey <= '1';
                returnkey <= '1';
                seq_len <= 0;
                seq_pos <= 0;
                tx_active <= '0';
                tx_bit_idx <= 0;
                tx_divider <= 0;
                tx_low_phase <= '0';
                ps2_clk_r <= '1';
                ps2_data_r <= '1';
                kb_io0 <= '1';
                kb_io1 <= '0';
            ELSE
                ----------------------------------------------------------------
                -- MEGA65 keyboard serial scanner. This follows the official
                -- core protocol for matrix acquisition and the case LEDs.
                ----------------------------------------------------------------
                IF kbd_divider /= KBD_DIV_MAX THEN
                    kbd_divider <= kbd_divider + 1;
                ELSE
                    kbd_divider <= 0;
                    kbd_clock <= NOT kbd_clock;
                    kb_io0 <= kbd_clock OR sync_pulse;

                    IF kbd_clock = '1' AND phase < 128 THEN
                        IF phase = 73 THEN
                            current_keys(72) <= kb_io2;
                        END IF;
                        IF phase = 74 THEN
                            current_keys(73) <= kb_io2;
                        END IF;
                        IF phase = 76 THEN
                            deletekey <= kb_io2;
                        END IF;
                        IF phase = 77 THEN
                            returnkey <= kb_io2;
                        END IF;

                        IF phase = 0 THEN
                            current_keys(0) <= deletekey;
                        ELSIF phase = 1 THEN
                            current_keys(1) <= returnkey;
                        ELSIF phase < 72 THEN
                            current_keys(phase) <= kb_io2;
                        END IF;
                    END IF;

                    IF kbd_clock = '0' THEN
                        IF phase /= 140 THEN
                            phase <= phase + 1;
                        ELSE
                            phase <= 0;
                        END IF;

                        IF phase = 127 THEN
                            sync_pulse <= '1';
                            output_vector <= (OTHERS => '0');
                            IF drive_led = '1' THEN
                                -- Two identical 24-bit RGB fields feed the
                                -- duplicated drive-LED channels.
                                output_vector(23 DOWNTO 0) <= x"0000FF";
                                output_vector(47 DOWNTO 24) <= x"0000FF";
                            END IF;
                            output_vector(71 DOWNTO 48) <= x"0080FF";
                            output_vector(95 DOWNTO 72) <= x"0080FF";
                        ELSIF phase = 140 THEN
                            sync_pulse <= '0';
                        ELSIF phase < 127 THEN
                            kb_io1 <= output_vector(127);
                            output_vector(127 DOWNTO 1) <= output_vector(126 DOWNTO 0);
                            output_vector(0) <= '0';
                        END IF;
                    END IF;
                END IF;

                ----------------------------------------------------------------
                -- PS/2 transmitter into the existing Nascom2 PS/2 receiver.
                ----------------------------------------------------------------
                IF tx_active = '0' THEN
                    ps2_clk_r <= '1';
                    ps2_data_r <= '1';

                    IF seq_len /= 0 THEN
                        frame_v := ps2_frame_for(seq_byte(seq_pos, seq_b0, seq_b1, seq_b2));
                        tx_frame <= frame_v;
                        tx_active <= '1';
                        tx_bit_idx <= 0;
                        tx_divider <= 0;
                        tx_low_phase <= '0';
                        ps2_data_r <= frame_v(0);
                    END IF;
                ELSE
                    IF tx_divider /= PS2_DIV_MAX THEN
                        tx_divider <= tx_divider + 1;
                    ELSE
                        tx_divider <= 0;
                        IF tx_low_phase = '0' THEN
                            ps2_clk_r <= '0';
                            tx_low_phase <= '1';
                        ELSE
                            ps2_clk_r <= '1';
                            tx_low_phase <= '0';
                            IF tx_bit_idx = 10 THEN
                                tx_active <= '0';
                                ps2_data_r <= '1';
                                IF seq_pos + 1 >= seq_len THEN
                                    seq_len <= 0;
                                    seq_pos <= 0;
                                ELSE
                                    seq_pos <= seq_pos + 1;
                                END IF;
                            ELSE
                                tx_bit_idx <= tx_bit_idx + 1;
                                ps2_data_r <= tx_frame(tx_bit_idx + 1);
                            END IF;
                        END IF;
                    END IF;
                END IF;

                ----------------------------------------------------------------
                -- Convert matrix changes to PS/2 make/break byte sequences.
                ----------------------------------------------------------------
                IF seq_len = 0 AND tx_active = '0' THEN
                    code_v := ps2_code_for(scan_idx);
                    ext_v := ps2_ext_for(scan_idx);

                    -- The MEGA65 has seven physical F-key pairs.  The odd
                    -- function number is selected without Shift and the even
                    -- number with either Shift key.  Derive the logical key
                    -- from the complete matrix so F1..F14 remain distinct.
                    IF current_keys(15) = '0' OR current_keys(52) = '0' THEN
                        CASE scan_idx IS
                            WHEN 4  => code_v := x"06"; -- F2
                            WHEN 5  => code_v := x"0C"; -- F4
                            WHEN 6  => code_v := x"0B"; -- F6
                            WHEN 3  => code_v := x"0A"; -- F8
                            WHEN 68 => code_v := x"09"; -- F10
                            WHEN 69 => code_v := x"07"; -- F12
                            WHEN 70 => code_v := x"86"; -- F14 (internal extension)
                            WHEN OTHERS => NULL;
                        END CASE;
                    END IF;

                    -- Encode Ctrl+CLR/Home or Shift+CLR/Home directly from the
                    -- complete MEGA65 matrix.  Some keyboard revisions do not
                    -- report Ctrl and Home as a stable simultaneous chord;
                    -- Shift is known to be reliable because the same bits
                    -- select F2/F4/.../F14 above.  84h is internal-only.
                    IF scan_idx = 51 AND (
                        current_keys(58) = '0' OR
                        current_keys(15) = '0' OR
                        current_keys(52) = '0') THEN
                        code_v := x"84";
                        ext_v := '0';
                    END IF;

                    IF current_keys(scan_idx) /= last_keys(scan_idx) THEN
                        last_keys(scan_idx) <= current_keys(scan_idx);
                        IF code_v /= x"00" THEN
                            IF current_keys(scan_idx) = '0' THEN
                                IF ext_v = '1' THEN
                                    seq_b0 <= x"E0";
                                    seq_b1 <= code_v;
                                    seq_len <= 2;
                                ELSE
                                    seq_b0 <= code_v;
                                    seq_len <= 1;
                                END IF;
                            ELSE
                                IF ext_v = '1' THEN
                                    seq_b0 <= x"E0";
                                    seq_b1 <= x"F0";
                                    seq_b2 <= code_v;
                                    seq_len <= 3;
                                ELSE
                                    seq_b0 <= x"F0";
                                    seq_b1 <= code_v;
                                    seq_len <= 2;
                                END IF;
                            END IF;
                        END IF;
                    END IF;

                    IF scan_idx = 73 THEN
                        scan_idx <= 0;
                    ELSE
                        scan_idx <= scan_idx + 1;
                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE rtl;
