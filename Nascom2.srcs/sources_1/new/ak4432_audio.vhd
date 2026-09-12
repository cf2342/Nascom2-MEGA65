--------------------------------------------------------------------------------
-- MEGA65 AK4432VT audio interface.
--
-- Clock and serial format follow the proven MiSTer2MEGA65 implementation:
-- 12.288 MHz MCLK, 3.072 MHz BICK, 48 kHz LRCLK and 32-bit MSB-justified
-- stereo frames.  The AK4432 power-on default selects this data format, so no
-- I2C register programming is required.
--------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY UNISIM;
USE UNISIM.VComponents.ALL;

ENTITY ak4432_audio IS
    PORT (
        clk100 : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        pcm_l : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        pcm_r : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        audio_mclk_o : OUT STD_LOGIC;
        audio_bick_o : OUT STD_LOGIC;
        audio_sdti_o : OUT STD_LOGIC;
        audio_lrclk_o : OUT STD_LOGIC;
        audio_pdn_n_o : OUT STD_LOGIC;
        audio_pdm_l_o : OUT STD_LOGIC;
        audio_pdm_r_o : OUT STD_LOGIC
    );
END ENTITY ak4432_audio;

ARCHITECTURE rtl OF ak4432_audio IS
    SIGNAL audio_fb_mmcm : STD_LOGIC;
    SIGNAL audio_clk_mmcm : STD_LOGIC;
    SIGNAL audio_clk : STD_LOGIC;
    SIGNAL audio_locked : STD_LOGIC;
    SIGNAL audio_reset_meta : STD_LOGIC := '1';
    SIGNAL audio_reset_sync : STD_LOGIC := '1';
    SIGNAL pcm_l_sync : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL pcm_r_sync : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL pcm_l_pdm_gain : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL pcm_r_pdm_gain : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL fs_counter : INTEGER RANGE 0 TO 255 := 0;
    SIGNAL serial_data : STD_LOGIC_VECTOR(63 DOWNTO 0) := (OTHERS => '0');

    FUNCTION saturating_double(sample : STD_LOGIC_VECTOR(15 DOWNTO 0))
        RETURN STD_LOGIC_VECTOR IS
        VARIABLE doubled : SIGNED(16 DOWNTO 0);
    BEGIN
        doubled := SHIFT_LEFT(RESIZE(SIGNED(sample), doubled'LENGTH), 1);
        IF doubled > TO_SIGNED(32767, doubled'LENGTH) THEN
            RETURN STD_LOGIC_VECTOR(TO_SIGNED(32767, 16));
        ELSIF doubled < TO_SIGNED(-32768, doubled'LENGTH) THEN
            RETURN STD_LOGIC_VECTOR(TO_SIGNED(-32768, 16));
        ELSE
            RETURN STD_LOGIC_VECTOR(RESIZE(doubled, 16));
        END IF;
    END FUNCTION;

    -- Four-phase mailbox: hold both channels until the destination acknowledges.
    SIGNAL pcm_hold : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL pcm_request : STD_LOGIC := '0';
    SIGNAL pcm_request_meta : STD_LOGIC := '0';
    SIGNAL pcm_request_sync : STD_LOGIC := '0';
    SIGNAL pcm_ack : STD_LOGIC := '0';
    SIGNAL pcm_ack_meta : STD_LOGIC := '0';
    SIGNAL pcm_ack_sync : STD_LOGIC := '0';
    SIGNAL cdc_reset : STD_LOGIC;
    SIGNAL source_reset_meta : STD_LOGIC := '1';
    SIGNAL source_reset_sync : STD_LOGIC := '1';
    ATTRIBUTE ASYNC_REG : STRING;
    ATTRIBUTE ASYNC_REG OF pcm_request_meta, pcm_request_sync : SIGNAL IS "TRUE";
    ATTRIBUTE ASYNC_REG OF pcm_ack_meta, pcm_ack_sync : SIGNAL IS "TRUE";
    ATTRIBUTE ASYNC_REG OF source_reset_meta, source_reset_sync : SIGNAL IS "TRUE";
    ATTRIBUTE ASYNC_REG OF audio_reset_meta, audio_reset_sync : SIGNAL IS "TRUE";
BEGIN
    -- 100 MHz * 48 / 5 / 78.125 = exactly 12.288 MHz.
    i_clk_audio : MMCME2_BASE
        GENERIC MAP (
            BANDWIDTH => "OPTIMIZED",
            CLKFBOUT_MULT_F => 48.000,
            CLKFBOUT_PHASE => 0.000,
            CLKIN1_PERIOD => 10.0,
            CLKOUT0_DIVIDE_F => 78.125,
            CLKOUT0_DUTY_CYCLE => 0.500,
            CLKOUT0_PHASE => 0.000,
            DIVCLK_DIVIDE => 5,
            REF_JITTER1 => 0.010,
            STARTUP_WAIT => FALSE
        )
        PORT MAP (
            CLKFBIN => audio_fb_mmcm,
            CLKFBOUT => audio_fb_mmcm,
            CLKIN1 => clk100,
            CLKOUT0 => audio_clk_mmcm,
            LOCKED => audio_locked,
            PWRDWN => '0',
            RST => '0'
        );

    i_audio_clk_bufg : BUFG
        PORT MAP (
            I => audio_clk_mmcm,
            O => audio_clk
        );

    -- Common asynchronous assertion, synchronous release in each clock domain.
    cdc_reset <= reset OR NOT audio_locked;
    PROCESS (audio_clk, audio_locked, reset)
    BEGIN
        IF audio_locked = '0' OR reset = '1' THEN
            audio_reset_meta <= '1';
            audio_reset_sync <= '1';
        ELSIF rising_edge(audio_clk) THEN
            audio_reset_meta <= '0';
            audio_reset_sync <= audio_reset_meta;
        END IF;
    END PROCESS;

    PROCESS (clk100, cdc_reset)
    BEGIN
        IF cdc_reset = '1' THEN
            source_reset_meta <= '1';
            source_reset_sync <= '1';
        ELSIF rising_edge(clk100) THEN
            source_reset_meta <= '0';
            source_reset_sync <= source_reset_meta;
        END IF;
    END PROCESS;

    PROCESS (clk100, source_reset_sync)
    BEGIN
        IF source_reset_sync = '1' THEN
            pcm_hold <= (OTHERS => '0');
            pcm_request <= '0';
            pcm_ack_meta <= '0';
            pcm_ack_sync <= '0';
        ELSIF rising_edge(clk100) THEN
            pcm_ack_meta <= pcm_ack;
            pcm_ack_sync <= pcm_ack_meta;
            IF pcm_request = '0' AND pcm_ack_sync = '0' THEN
                pcm_hold <= pcm_l & pcm_r;
                pcm_request <= '1';
            ELSIF pcm_request = '1' AND pcm_ack_sync = '1' THEN
                pcm_request <= '0';
            END IF;
        END IF;
    END PROCESS;

    PROCESS (audio_clk, audio_reset_sync)
    BEGIN
        IF audio_reset_sync = '1' THEN
            pcm_request_meta <= '0';
            pcm_request_sync <= '0';
            pcm_ack <= '0';
            pcm_l_sync <= (OTHERS => '0');
            pcm_r_sync <= (OTHERS => '0');
        ELSIF rising_edge(audio_clk) THEN
            pcm_request_meta <= pcm_request;
            pcm_request_sync <= pcm_request_meta;
            IF pcm_request_sync = '1' AND pcm_ack = '0' THEN
                -- The held bus has settled for at least two audio clocks.
                -- Its maximum datapath delay is bounded in the board XDC.
                pcm_l_sync <= pcm_hold(31 DOWNTO 16);
                pcm_r_sync <= pcm_hold(15 DOWNTO 0);
                pcm_ack <= '1';
            ELSIF pcm_request_sync = '0' THEN
                pcm_ack <= '0';
            END IF;
        END IF;
    END PROCESS;

    PROCESS (audio_clk)
    BEGIN
        IF rising_edge(audio_clk) THEN
            IF audio_reset_sync = '1' THEN
                fs_counter <= 0;
                serial_data <= (OTHERS => '0');
                audio_bick_o <= '0';
                audio_sdti_o <= '0';
                audio_lrclk_o <= '1';
            ELSE
                audio_sdti_o <= serial_data(63);
                IF fs_counter < 128 THEN
                    audio_lrclk_o <= '1';
                ELSE
                    audio_lrclk_o <= '0';
                END IF;

                IF (fs_counter MOD 4) < 2 THEN
                    audio_bick_o <= '0';
                ELSE
                    audio_bick_o <= '1';
                END IF;

                IF fs_counter = 255 THEN
                    fs_counter <= 0;
                    serial_data <= (OTHERS => '0');
                    serial_data(63 DOWNTO 48) <= pcm_l_sync;
                    serial_data(31 DOWNTO 16) <= pcm_r_sync;
                ELSE
                    fs_counter <= fs_counter + 1;
                    IF (fs_counter MOD 4) = 3 THEN
                        serial_data(63 DOWNTO 1) <= serial_data(62 DOWNTO 0);
                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    audio_mclk_o <= audio_clk;
    audio_pdn_n_o <= NOT audio_reset_sync;

    -- The passive R3/R3A analogue output is quieter than the R6 AK4432 DAC.
    -- Apply +6.02 dB only to the R3 PDM path and saturate instead of wrapping
    -- at the signed 16-bit limits.  The R6 serial DAC path above is unchanged.
    pcm_l_pdm_gain <= saturating_double(pcm_l_sync);
    pcm_r_pdm_gain <= saturating_double(pcm_r_sync);

    -- The R3/R3A analogue jack is fed directly by one-bit pulse-density
    -- streams.  Generate them on the proven 12.288 MHz audio clock; running
    -- this converter at the 100 MHz system clock produces pulses which are
    -- too short for the R3 output filter to reconstruct reliably.
    i_r3_audio_pdm : ENTITY work.pcm_to_pdm
        PORT MAP (
            clk => audio_clk,
            reset => audio_reset_sync,
            pcm_l => pcm_l_pdm_gain,
            pcm_r => pcm_r_pdm_gain,
            pdm_l => audio_pdm_l_o,
            pdm_r => audio_pdm_r_o
        );
END ARCHITECTURE rtl;
