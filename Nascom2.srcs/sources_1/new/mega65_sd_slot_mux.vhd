LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Select one of the two physical MEGA65 SD-card slots for the shared SPI
-- controller. R6 prefers the rear micro-SD slot. R3 starts with the internal
-- tray because its internal card-detect input is not reliable on all R3 boards.
ENTITY mega65_sd_slot_mux IS
    GENERIC (
        PREFER_EXTERNAL      : BOOLEAN := TRUE;
        INTERNAL_CD_RELIABLE : BOOLEAN := TRUE;
        RESET_CYCLES         : POSITIVE := 16
    );
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        controller_init_error : IN STD_LOGIC;

        internal_cd_n : IN STD_LOGIC;
        internal_miso : IN STD_LOGIC;
        internal_sclk : OUT STD_LOGIC;
        internal_mosi : OUT STD_LOGIC;
        internal_cs_n : OUT STD_LOGIC;
        external_cd_n : IN STD_LOGIC;
        external_miso : IN STD_LOGIC;
        external_sclk : OUT STD_LOGIC;
        external_mosi : OUT STD_LOGIC;
        external_cs_n : OUT STD_LOGIC;

        controller_cd_n : OUT STD_LOGIC;
        controller_miso : OUT STD_LOGIC;
        controller_sclk : IN STD_LOGIC;
        controller_mosi : IN STD_LOGIC;
        controller_cs_n : IN STD_LOGIC;
        controller_reset : OUT STD_LOGIC;
        external_active : OUT STD_LOGIC
    );
END ENTITY;

ARCHITECTURE rtl OF mega65_sd_slot_mux IS
    TYPE mux_state_t IS (WAIT_DETECT, RESET_CONTROLLER, ACTIVE);
    SIGNAL state : mux_state_t := WAIT_DETECT;
    SIGNAL active_external : STD_LOGIC := '0';
    SIGNAL internal_cd_meta : STD_LOGIC := '1';
    SIGNAL internal_cd_sync : STD_LOGIC := '1';
    SIGNAL external_cd_meta : STD_LOGIC := '1';
    SIGNAL external_cd_sync : STD_LOGIC := '1';
    SIGNAL wait_count : NATURAL RANGE 0 TO 3 := 3;
    SIGNAL reset_count : NATURAL RANGE 0 TO RESET_CYCLES - 1 := RESET_CYCLES - 1;
    SIGNAL fallback_used : STD_LOGIC := '0';
    ATTRIBUTE ASYNC_REG : STRING;
    ATTRIBUTE ASYNC_REG OF internal_cd_meta, internal_cd_sync : SIGNAL IS "TRUE";
    ATTRIBUTE ASYNC_REG OF external_cd_meta, external_cd_sync : SIGNAL IS "TRUE";
BEGIN
    external_active <= active_external;
    controller_reset <= '1' WHEN state /= ACTIVE ELSE '0';

    -- An R3 tray card is treated as present while selected. This avoids the
    -- broken tray card-detect connection on original R3 PCBs. A failed SPI
    -- initialisation can still fall back to a detected rear card.
    controller_cd_n <= '1' WHEN state /= ACTIVE ELSE
        external_cd_sync WHEN active_external = '1' ELSE
        internal_cd_sync WHEN INTERNAL_CD_RELIABLE ELSE '0';
    controller_miso <= external_miso WHEN active_external = '1' ELSE internal_miso;

    internal_sclk <= controller_sclk WHEN state = ACTIVE AND active_external = '0' ELSE '0';
    internal_mosi <= controller_mosi WHEN state = ACTIVE AND active_external = '0' ELSE '0';
    internal_cs_n <= controller_cs_n WHEN state = ACTIVE AND active_external = '0' ELSE '1';
    external_sclk <= controller_sclk WHEN state = ACTIVE AND active_external = '1' ELSE '0';
    external_mosi <= controller_mosi WHEN state = ACTIVE AND active_external = '1' ELSE '0';
    external_cs_n <= controller_cs_n WHEN state = ACTIVE AND active_external = '1' ELSE '1';

    PROCESS (clk)
        VARIABLE initial_external : STD_LOGIC;
    BEGIN
        IF rising_edge(clk) THEN
            internal_cd_meta <= internal_cd_n;
            internal_cd_sync <= internal_cd_meta;
            external_cd_meta <= external_cd_n;
            external_cd_sync <= external_cd_meta;

            IF reset = '1' THEN
                state <= WAIT_DETECT;
                wait_count <= 3;
                reset_count <= RESET_CYCLES - 1;
                fallback_used <= '0';
                IF PREFER_EXTERNAL THEN
                    active_external <= '1';
                ELSE
                    active_external <= '0';
                END IF;
            ELSE
                CASE state IS
                    WHEN WAIT_DETECT =>
                        IF wait_count = 0 THEN
                            initial_external := '0';
                            IF PREFER_EXTERNAL AND external_cd_sync = '0' THEN
                                initial_external := '1';
                            END IF;
                            active_external <= initial_external;
                            fallback_used <= '0';
                            reset_count <= RESET_CYCLES - 1;
                            state <= RESET_CONTROLLER;
                        ELSE
                            wait_count <= wait_count - 1;
                        END IF;

                    WHEN RESET_CONTROLLER =>
                        IF reset_count = 0 THEN
                            state <= ACTIVE;
                        ELSE
                            reset_count <= reset_count - 1;
                        END IF;

                    WHEN ACTIVE =>
                        IF PREFER_EXTERNAL THEN
                            IF active_external = '0' AND external_cd_sync = '1' THEN
                                fallback_used <= '0';
                            ELSIF active_external = '0' AND external_cd_sync = '0' AND
                                fallback_used = '0' THEN
                                active_external <= '1';
                                fallback_used <= '0';
                                reset_count <= RESET_CYCLES - 1;
                                state <= RESET_CONTROLLER;
                            ELSIF active_external = '1' AND external_cd_sync = '1' THEN
                                active_external <= '0';
                                fallback_used <= '0';
                                reset_count <= RESET_CYCLES - 1;
                                state <= RESET_CONTROLLER;
                            ELSIF controller_init_error = '1' AND fallback_used = '0' AND
                                active_external = '1' AND internal_cd_sync = '0' THEN
                                active_external <= '0';
                                fallback_used <= '1';
                                reset_count <= RESET_CYCLES - 1;
                                state <= RESET_CONTROLLER;
                            END IF;
                        ELSE
                            IF active_external = '1' AND external_cd_sync = '1' THEN
                                active_external <= '0';
                                fallback_used <= '0';
                                reset_count <= RESET_CYCLES - 1;
                                state <= RESET_CONTROLLER;
                            ELSIF controller_init_error = '1' AND fallback_used = '0' AND
                                active_external = '0' AND external_cd_sync = '0' THEN
                                active_external <= '1';
                                fallback_used <= '1';
                                reset_count <= RESET_CYCLES - 1;
                                state <= RESET_CONTROLLER;
                            END IF;
                        END IF;
                END CASE;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;
