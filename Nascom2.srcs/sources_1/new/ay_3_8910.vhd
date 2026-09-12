--------------------------------------------------------------------------------
-- AY-3-8910 programmable sound generator                                      --
--                                                                            --
-- The register interface follows the original device, while the analogue     --
-- outputs are mixed and DC-blocked into one signed 16-bit PCM stream.         --
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ay_3_8910 IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        clock_enable_2mhz : IN STD_LOGIC;

        register_select_write : IN STD_LOGIC;
        register_data_write : IN STD_LOGIC;
        data_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        data_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);

        port_a_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '1');
        port_b_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '1');

        pcm_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END ENTITY ay_3_8910;

ARCHITECTURE rtl OF ay_3_8910 IS
    TYPE register_array_t IS ARRAY (0 TO 15) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    TYPE tone_counter_array_t IS ARRAY (0 TO 2) OF INTEGER RANGE 0 TO 4095;

    SIGNAL registers : register_array_t := (7 => x"3F", OTHERS => x"00");
    SIGNAL selected_register : unsigned(3 DOWNTO 0) := (OTHERS => '0');

    SIGNAL tone_prescaler : INTEGER RANGE 0 TO 7 := 0;
    SIGNAL tone_counter : tone_counter_array_t := (OTHERS => 0);
    SIGNAL tone_output : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');

    SIGNAL noise_prescaler : INTEGER RANGE 0 TO 15 := 0;
    SIGNAL noise_counter : INTEGER RANGE 0 TO 31 := 0;
    SIGNAL noise_lfsr : STD_LOGIC_VECTOR(16 DOWNTO 0) := (OTHERS => '1');
    SIGNAL noise_output : STD_LOGIC := '0';

    SIGNAL envelope_prescaler : INTEGER RANGE 0 TO 255 := 0;
    SIGNAL envelope_counter : INTEGER RANGE 0 TO 65535 := 0;
    SIGNAL envelope_step : INTEGER RANGE 0 TO 15 := 15;
    SIGNAL envelope_attack : STD_LOGIC := '0';
    SIGNAL envelope_alternate : STD_LOGIC := '0';
    SIGNAL envelope_hold : STD_LOGIC := '1';
    SIGNAL envelope_holding : STD_LOGIC := '1';

    -- DC estimate in Q20.12 fixed-point form.  The fractional bits prevent
    -- the high-pass filter from sticking on a small residual offset.
    SIGNAL dc_estimate : signed(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL pcm_reg : signed(15 DOWNTO 0) := (OTHERS => '0');

    FUNCTION amplitude_level(level : NATURAL) RETURN NATURAL IS
    BEGIN
        -- Measured AY-style logarithmic volume curve, scaled so three
        -- simultaneous channels remain inside signed 16-bit PCM range.
        CASE level IS
            WHEN 0  => RETURN 0;
            WHEN 1  => RETURN 112;
            WHEN 2  => RETURN 167;
            WHEN 3  => RETURN 238;
            WHEN 4  => RETURN 347;
            WHEN 5  => RETURN 506;
            WHEN 6  => RETURN 694;
            WHEN 7  => RETURN 1121;
            WHEN 8  => RETURN 1385;
            WHEN 9  => RETURN 2168;
            WHEN 10 => RETURN 2889;
            WHEN 11 => RETURN 3686;
            WHEN 12 => RETURN 4672;
            WHEN 13 => RETURN 5630;
            WHEN 14 => RETURN 6948;
            WHEN OTHERS => RETURN 8191;
        END CASE;
    END FUNCTION;
BEGIN
    -- Mixer bits 6 and 7 select output mode for parallel ports A and B.
    -- In output mode, reads return the corresponding output latch.
    data_out <= port_a_in WHEN selected_register = 14 AND registers(7)(6) = '0' ELSE
                port_b_in WHEN selected_register = 15 AND registers(7)(7) = '0' ELSE
                registers(to_integer(selected_register));
    pcm_out <= STD_LOGIC_VECTOR(pcm_reg);

    PROCESS (clk)
        VARIABLE period_v : INTEGER;
        VARIABLE envelope_level_v : INTEGER RANGE 0 TO 15;
        VARIABLE level_a_v : NATURAL;
        VARIABLE level_b_v : NATURAL;
        VARIABLE level_c_v : NATURAL;
        VARIABLE gate_a_v : STD_LOGIC;
        VARIABLE gate_b_v : STD_LOGIC;
        VARIABLE gate_c_v : STD_LOGIC;
        VARIABLE raw_mix_v : INTEGER RANGE 0 TO 24573;
        VARIABLE raw_signed_v : signed(31 DOWNTO 0);
        VARIABLE dc_next_v : signed(31 DOWNTO 0);
        VARIABLE pcm_next_v : signed(31 DOWNTO 0);
    BEGIN
        IF rising_edge(clk) THEN
            IF reset = '1' THEN
                registers <= (7 => x"3F", OTHERS => x"00");
                selected_register <= (OTHERS => '0');
                tone_prescaler <= 0;
                tone_counter <= (OTHERS => 0);
                tone_output <= (OTHERS => '0');
                noise_prescaler <= 0;
                noise_counter <= 0;
                noise_lfsr <= (OTHERS => '1');
                noise_output <= '0';
                envelope_prescaler <= 0;
                envelope_counter <= 0;
                envelope_step <= 15;
                envelope_attack <= '0';
                envelope_alternate <= '0';
                envelope_hold <= '1';
                envelope_holding <= '1';
                dc_estimate <= (OTHERS => '0');
                pcm_reg <= (OTHERS => '0');
            ELSE
                IF clock_enable_2mhz = '1' THEN
                    ------------------------------------------------------------
                    -- Tone generators: clock / 8 counter, then toggle.        --
                    ------------------------------------------------------------
                    IF tone_prescaler = 7 THEN
                        tone_prescaler <= 0;
                        FOR channel IN 0 TO 2 LOOP
                            period_v :=
                                to_integer(unsigned(registers(channel * 2))) +
                                256 * to_integer(unsigned(
                                    registers(channel * 2 + 1)(3 DOWNTO 0)));
                            IF period_v = 0 THEN
                                period_v := 1;
                            END IF;

                            IF tone_counter(channel) >= period_v - 1 THEN
                                tone_counter(channel) <= 0;
                                tone_output(channel) <= NOT tone_output(channel);
                            ELSE
                                tone_counter(channel) <= tone_counter(channel) + 1;
                            END IF;
                        END LOOP;
                    ELSE
                        tone_prescaler <= tone_prescaler + 1;
                    END IF;

                    ------------------------------------------------------------
                    -- Noise generator: 17-bit LFSR clocked at clock / 16.     --
                    ------------------------------------------------------------
                    IF noise_prescaler = 15 THEN
                        noise_prescaler <= 0;
                        period_v := to_integer(unsigned(registers(6)(4 DOWNTO 0)));
                        IF period_v = 0 THEN
                            period_v := 1;
                        END IF;

                        IF noise_counter >= period_v - 1 THEN
                            noise_counter <= 0;
                            noise_output <= noise_lfsr(0);
                            noise_lfsr <=
                                (noise_lfsr(0) XOR noise_lfsr(3)) &
                                noise_lfsr(16 DOWNTO 1);
                        ELSE
                            noise_counter <= noise_counter + 1;
                        END IF;
                    ELSE
                        noise_prescaler <= noise_prescaler + 1;
                    END IF;

                    ------------------------------------------------------------
                    -- Envelope generator: clock / 256 programmable counter.  --
                    ------------------------------------------------------------
                    IF envelope_prescaler = 255 THEN
                        envelope_prescaler <= 0;
                        period_v :=
                            to_integer(unsigned(registers(11))) +
                            256 * to_integer(unsigned(registers(12)));
                        IF period_v = 0 THEN
                            period_v := 1;
                        END IF;

                        IF envelope_counter >= period_v - 1 THEN
                            envelope_counter <= 0;
                            IF envelope_holding = '0' THEN
                                IF envelope_step > 0 THEN
                                    envelope_step <= envelope_step - 1;
                                ELSIF envelope_hold = '1' THEN
                                    IF envelope_alternate = '1' THEN
                                        envelope_attack <= NOT envelope_attack;
                                    END IF;
                                    envelope_holding <= '1';
                                ELSE
                                    envelope_step <= 15;
                                    IF envelope_alternate = '1' THEN
                                        envelope_attack <= NOT envelope_attack;
                                    END IF;
                                END IF;
                            END IF;
                        ELSE
                            envelope_counter <= envelope_counter + 1;
                        END IF;
                    ELSE
                        envelope_prescaler <= envelope_prescaler + 1;
                    END IF;

                    ------------------------------------------------------------
                    -- Three analogue channels, followed by a simple digital  --
                    -- AC coupling stage. This preserves AY DAC-style volume  --
                    -- changes while removing inaudible DC from HDMI PCM.      --
                    ------------------------------------------------------------
                    IF envelope_attack = '1' THEN
                        envelope_level_v := 15 - envelope_step;
                    ELSE
                        envelope_level_v := envelope_step;
                    END IF;

                    IF registers(8)(4) = '1' THEN
                        level_a_v := amplitude_level(envelope_level_v);
                    ELSE
                        level_a_v := amplitude_level(to_integer(unsigned(registers(8)(3 DOWNTO 0))));
                    END IF;
                    IF registers(9)(4) = '1' THEN
                        level_b_v := amplitude_level(envelope_level_v);
                    ELSE
                        level_b_v := amplitude_level(to_integer(unsigned(registers(9)(3 DOWNTO 0))));
                    END IF;
                    IF registers(10)(4) = '1' THEN
                        level_c_v := amplitude_level(envelope_level_v);
                    ELSE
                        level_c_v := amplitude_level(to_integer(unsigned(registers(10)(3 DOWNTO 0))));
                    END IF;

                    gate_a_v := (tone_output(0) OR registers(7)(0)) AND
                                (noise_output OR registers(7)(3));
                    gate_b_v := (tone_output(1) OR registers(7)(1)) AND
                                (noise_output OR registers(7)(4));
                    gate_c_v := (tone_output(2) OR registers(7)(2)) AND
                                (noise_output OR registers(7)(5));

                    raw_mix_v := 0;
                    IF gate_a_v = '1' THEN raw_mix_v := raw_mix_v + level_a_v; END IF;
                    IF gate_b_v = '1' THEN raw_mix_v := raw_mix_v + level_b_v; END IF;
                    IF gate_c_v = '1' THEN raw_mix_v := raw_mix_v + level_c_v; END IF;

                    raw_signed_v := to_signed(raw_mix_v, raw_signed_v'length);
                    dc_next_v := dc_estimate + raw_signed_v - shift_right(dc_estimate, 12);
                    pcm_next_v := raw_signed_v - shift_right(dc_next_v, 12);
                    dc_estimate <= dc_next_v;
                    pcm_reg <= resize(pcm_next_v, pcm_reg'length);
                END IF;

                ------------------------------------------------------------
                -- Host register interface. Writes occur once per Z80 I/O   --
                -- transaction; register 13 writes restart the envelope.    --
                ------------------------------------------------------------
                IF register_select_write = '1' THEN
                    selected_register <= unsigned(data_in(3 DOWNTO 0));
                END IF;

                IF register_data_write = '1' THEN
                    CASE to_integer(selected_register) IS
                        WHEN 1 | 3 | 5 =>
                            registers(to_integer(selected_register)) <= x"0" & data_in(3 DOWNTO 0);
                        WHEN 6 =>
                            registers(6) <= "000" & data_in(4 DOWNTO 0);
                        WHEN 8 | 9 | 10 =>
                            registers(to_integer(selected_register)) <= "000" & data_in(4 DOWNTO 0);
                        WHEN 13 =>
                            registers(13) <= x"0" & data_in(3 DOWNTO 0);
                            envelope_prescaler <= 0;
                            envelope_counter <= 0;
                            envelope_step <= 15;
                            envelope_attack <= data_in(2);
                            envelope_holding <= '0';
                            IF data_in(3) = '0' THEN
                                envelope_hold <= '1';
                                envelope_alternate <= data_in(2);
                            ELSE
                                envelope_hold <= data_in(0);
                                envelope_alternate <= data_in(1);
                            END IF;
                        WHEN OTHERS =>
                            registers(to_integer(selected_register)) <= data_in;
                    END CASE;
                END IF;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE rtl;
