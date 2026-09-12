--------------------------------------------------------------------------------
-- First-order stereo delta-sigma converter for the MEGA65 analogue audio pins.
-- The external filter on the MEGA65 board reconstructs the PCM waveform from
-- the 1-bit pulse-density streams.
--------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY pcm_to_pdm IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        pcm_l : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        pcm_r : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        pdm_l : OUT STD_LOGIC;
        pdm_r : OUT STD_LOGIC
    );
END ENTITY pcm_to_pdm;

ARCHITECTURE rtl OF pcm_to_pdm IS
    SIGNAL accumulator_l : UNSIGNED(16 DOWNTO 0) := (OTHERS => '0');
    SIGNAL accumulator_r : UNSIGNED(16 DOWNTO 0) := (OTHERS => '0');
BEGIN
    -- Adding 0x8000 converts each two's-complement sample to an unsigned
    -- density. The carry bit is the one-bit DAC output and feedback term.
    PROCESS (clk)
        VARIABLE sample_l_u : UNSIGNED(15 DOWNTO 0);
        VARIABLE sample_r_u : UNSIGNED(15 DOWNTO 0);
    BEGIN
        IF RISING_EDGE(clk) THEN
            IF reset = '1' THEN
                accumulator_l <= (OTHERS => '0');
                accumulator_r <= (OTHERS => '0');
            ELSE
                sample_l_u := UNSIGNED(pcm_l) + TO_UNSIGNED(16#8000#, 16);
                sample_r_u := UNSIGNED(pcm_r) + TO_UNSIGNED(16#8000#, 16);
                accumulator_l <= ('0' & accumulator_l(15 DOWNTO 0)) +
                                 ('0' & sample_l_u);
                accumulator_r <= ('0' & accumulator_r(15 DOWNTO 0)) +
                                 ('0' & sample_r_u);
            END IF;
        END IF;
    END PROCESS;

    pdm_l <= accumulator_l(16);
    pdm_r <= accumulator_r(16);
END ARCHITECTURE rtl;
