----------------------------------------------------------------------------------
-- Minimal MEGA65 R3/R3A MAX10 communications interface.
--
-- Derived from max10.vhdl in the MEGA65 core.  The interface supplies the
-- physical reset button state and maintains the serial link expected by the
-- auxiliary MAX10 FPGA.  Unused J21 data is kept at its safe input default.
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY mega65_r3_max10 IS
    PORT (
        protocol_clock : IN STD_LOGIC;
        system_clock : IN STD_LOGIC;

        max10_rx : OUT STD_LOGIC := '1';
        max10_tx : IN STD_LOGIC;
        max10_clkandsync : OUT STD_LOGIC;

        reset_n : OUT STD_LOGIC := '1'
    );
END ENTITY mega65_r3_max10;

ARCHITECTURE rtl OF mega65_r3_max10 IS
    SIGNAL max10_out_vector : STD_LOGIC_VECTOR(64 DOWNTO 0) := (OTHERS => '0');
    SIGNAL max10_in_vector : STD_LOGIC_VECTOR(64 DOWNTO 0) := (OTHERS => '0');
    SIGNAL max10_in_vector_d : STD_LOGIC_VECTOR(64 DOWNTO 0) := (OTHERS => '0');
    SIGNAL max10_counter : INTEGER RANGE 0 TO 79 := 0;
    SIGNAL max10_clock_toggle : STD_LOGIC := '0';

    SIGNAL max10_saw_0 : STD_LOGIC := '0';
    SIGNAL max10_saw_1 : STD_LOGIC := '0';
    SIGNAL reset_button_drive : STD_LOGIC := '1';
    SIGNAL reset_button_counter : INTEGER RANGE 0 TO 255 := 0;
    SIGNAL clock_divider : STD_LOGIC := '0';
BEGIN
    PROCESS (protocol_clock, system_clock)
    BEGIN
        IF rising_edge(system_clock) THEN
            -- The MAX10 reports the physical reset button active-low in bit
            -- 16.  Keep reset_n deasserted unless that low level is stable.
            reset_n <= '1';
            IF reset_button_drive = '1' THEN
                reset_button_counter <= 0;
            ELSIF reset_button_counter < 255 THEN
                reset_button_counter <= reset_button_counter + 1;
            ELSE
                reset_n <= '0';
            END IF;
        END IF;

        IF rising_edge(protocol_clock) THEN
            clock_divider <= NOT clock_divider;
            IF clock_divider = '1' THEN
                max10_clock_toggle <= NOT max10_clock_toggle;

                -- 64 data clocks followed by an active-low sync window.
                IF max10_counter < 64 THEN
                    max10_clkandsync <= max10_clock_toggle;
                ELSE
                    max10_clkandsync <= '0';
                    max10_out_vector <= (OTHERS => '0');
                END IF;

                IF max10_clock_toggle = '0' THEN
                    IF max10_counter /= 79 THEN
                        max10_counter <= max10_counter + 1;
                        IF max10_tx = '1' THEN
                            max10_saw_1 <= '1';
                        ELSE
                            max10_saw_0 <= '1';
                        END IF;
                    ELSE
                        max10_counter <= 0;
                        max10_saw_1 <= '0';
                        max10_saw_0 <= '0';

                        -- Compatibility with the original one-bit protocol.
                        IF max10_saw_1 = '1' AND max10_saw_0 = '0' THEN
                            reset_button_drive <= '1';
                        ELSIF max10_saw_1 = '0' AND max10_saw_0 = '1' THEN
                            reset_button_drive <= '0';
                        END IF;
                    END IF;

                    IF max10_counter = 64 THEN
                        max10_rx <= max10_out_vector(0);
                        max10_in_vector_d <= max10_in_vector;
                        -- Accept only two consecutive identical non-zero frames.
                        IF max10_in_vector /= STD_LOGIC_VECTOR(TO_UNSIGNED(0, 65)) AND
                           max10_in_vector = max10_in_vector_d THEN
                            reset_button_drive <= max10_in_vector(16);
                        END IF;
                    END IF;
                ELSE
                    max10_in_vector(0) <= max10_tx;
                    max10_in_vector(64 DOWNTO 1) <= max10_in_vector(63 DOWNTO 0);
                END IF;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE rtl;
