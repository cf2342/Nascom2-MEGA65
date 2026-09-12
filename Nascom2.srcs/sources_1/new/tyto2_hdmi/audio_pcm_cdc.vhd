--------------------------------------------------------------------------------
-- Coherent 48 kHz PCM transfer from the 100 MHz system clock to the HDMI      --
-- pixel clock domain.                                                         --
--                                                                            --
-- The source word is captured and held while a toggle crosses the clock       --
-- boundary. The toggle has one more synchronizer stage than the data bus, so  --
-- the complete 16-bit words are stable before dst_valid is asserted.          --
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY audio_pcm_cdc IS
    GENERIC (
        source_clock_hz : POSITIVE := 100000000;
        sample_rate_hz : POSITIVE := 48000
    );
    PORT (
        source_clk : IN STD_LOGIC;
        source_reset : IN STD_LOGIC;
        source_pcm_l : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        source_pcm_r : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

        destination_clk : IN STD_LOGIC;
        destination_reset : IN STD_LOGIC;
        destination_pcm_l : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        destination_pcm_r : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        destination_valid : OUT STD_LOGIC
    );
END ENTITY audio_pcm_cdc;

ARCHITECTURE rtl OF audio_pcm_cdc IS
    SIGNAL sample_accumulator : INTEGER RANGE 0 TO source_clock_hz - 1 := 0;
    SIGNAL source_hold_l : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL source_hold_r : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL source_toggle : STD_LOGIC := '0';

    SIGNAL data_l_meta : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL data_l_sync : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL data_r_meta : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL data_r_sync : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL toggle_meta : STD_LOGIC := '0';
    SIGNAL toggle_sync : STD_LOGIC := '0';
    SIGNAL toggle_delayed : STD_LOGIC := '0';
    SIGNAL toggle_seen : STD_LOGIC := '0';

    ATTRIBUTE ASYNC_REG : STRING;
    ATTRIBUTE ASYNC_REG OF data_l_meta : SIGNAL IS "TRUE";
    ATTRIBUTE ASYNC_REG OF data_l_sync : SIGNAL IS "TRUE";
    ATTRIBUTE ASYNC_REG OF data_r_meta : SIGNAL IS "TRUE";
    ATTRIBUTE ASYNC_REG OF data_r_sync : SIGNAL IS "TRUE";
    ATTRIBUTE ASYNC_REG OF toggle_meta : SIGNAL IS "TRUE";
    ATTRIBUTE ASYNC_REG OF toggle_sync : SIGNAL IS "TRUE";
    ATTRIBUTE ASYNC_REG OF toggle_delayed : SIGNAL IS "TRUE";
BEGIN
    ASSERT sample_rate_hz < source_clock_hz
        REPORT "audio_pcm_cdc sample rate must be below the source clock"
        SEVERITY FAILURE;

    SOURCE_SAMPLE : PROCESS (source_clk)
    BEGIN
        IF rising_edge(source_clk) THEN
            IF source_reset = '1' THEN
                sample_accumulator <= 0;
                source_hold_l <= (OTHERS => '0');
                source_hold_r <= (OTHERS => '0');
                source_toggle <= '0';
            ELSIF sample_accumulator >= source_clock_hz - sample_rate_hz THEN
                sample_accumulator <=
                    sample_accumulator + sample_rate_hz - source_clock_hz;
                source_hold_l <= source_pcm_l;
                source_hold_r <= source_pcm_r;
                source_toggle <= NOT source_toggle;
            ELSE
                sample_accumulator <= sample_accumulator + sample_rate_hz;
            END IF;
        END IF;
    END PROCESS SOURCE_SAMPLE;

    DESTINATION_TRANSFER : PROCESS (destination_clk)
    BEGIN
        IF rising_edge(destination_clk) THEN
            destination_valid <= '0';

            IF destination_reset = '1' THEN
                data_l_meta <= (OTHERS => '0');
                data_l_sync <= (OTHERS => '0');
                data_r_meta <= (OTHERS => '0');
                data_r_sync <= (OTHERS => '0');
                toggle_meta <= '0';
                toggle_sync <= '0';
                toggle_delayed <= '0';
                toggle_seen <= '0';
                destination_pcm_l <= (OTHERS => '0');
                destination_pcm_r <= (OTHERS => '0');
            ELSE
                data_l_meta <= source_hold_l;
                data_l_sync <= data_l_meta;
                data_r_meta <= source_hold_r;
                data_r_sync <= data_r_meta;
                toggle_meta <= source_toggle;
                toggle_sync <= toggle_meta;
                toggle_delayed <= toggle_sync;

                IF toggle_delayed /= toggle_seen THEN
                    destination_pcm_l <= data_l_sync;
                    destination_pcm_r <= data_r_sync;
                    destination_valid <= '1';
                    toggle_seen <= toggle_delayed;
                END IF;
            END IF;
        END IF;
    END PROCESS DESTINATION_TRANSFER;
END ARCHITECTURE rtl;
