LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ps2_keyboard IS
    PORT (
        clk       : IN  STD_LOGIC;  -- system clock, e.g. 100 MHz
        reset     : IN  STD_LOGIC;

        ps2_clk   : IN  STD_LOGIC;
        ps2_data  : IN  STD_LOGIC;

        code      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        valid     : OUT STD_LOGIC;
        extended  : OUT STD_LOGIC;
        released  : OUT STD_LOGIC
    );
END ENTITY ps2_keyboard;

ARCHITECTURE rtl OF ps2_keyboard IS

    --------------------------------------------------------------------
    -- Synchronizer for PS/2 signals
    --------------------------------------------------------------------
    SIGNAL ps2_clk_sync  : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '1');
    SIGNAL ps2_data_sync : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '1');

    SIGNAL ps2_clk_fall  : STD_LOGIC := '0';

    --------------------------------------------------------------------
    -- Frame reception
    -- PS/2 frame = start(0), 8 data bits (LSB first), parity, stop(1)
    --------------------------------------------------------------------
    SIGNAL bit_count     : INTEGER RANGE 0 TO 10 := 0;
    SIGNAL shift_reg     : STD_LOGIC_VECTOR(10 DOWNTO 0) := (OTHERS => '0');

    --------------------------------------------------------------------
    -- Prefix handling
    --------------------------------------------------------------------
    SIGNAL ext_seen      : STD_LOGIC := '0';
    SIGNAL break_seen    : STD_LOGIC := '0';

    --------------------------------------------------------------------
    -- Output registers
    --------------------------------------------------------------------
    SIGNAL code_r        : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL valid_r       : STD_LOGIC := '0';
    SIGNAL extended_r    : STD_LOGIC := '0';
    SIGNAL released_r    : STD_LOGIC := '0';

BEGIN

    code     <= code_r;
    valid    <= valid_r;
    extended <= extended_r;
    released <= released_r;

    --------------------------------------------------------------------
    -- Synchronize PS/2 inputs and detect falling edge on PS2 clock
    --------------------------------------------------------------------
    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            ps2_clk_sync  <= ps2_clk_sync(1 DOWNTO 0)  & ps2_clk;
            ps2_data_sync <= ps2_data_sync(1 DOWNTO 0) & ps2_data;
        END IF;
    END PROCESS;

    ps2_clk_fall <= '1' WHEN ps2_clk_sync(2 DOWNTO 1) = "10" ELSE '0';

    --------------------------------------------------------------------
    -- Main PS/2 receiver
    --------------------------------------------------------------------
    PROCESS (clk)
        VARIABLE data_byte : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE parity_ok : BOOLEAN;
        VARIABLE start_ok  : BOOLEAN;
        VARIABLE stop_ok   : BOOLEAN;
        VARIABLE ones      : INTEGER;
    BEGIN
        IF rising_edge(clk) THEN
            valid_r <= '0';

            IF reset = '1' THEN
                bit_count   <= 0;
                shift_reg   <= (OTHERS => '0');
                ext_seen    <= '0';
                break_seen  <= '0';

                code_r      <= (OTHERS => '0');
                valid_r     <= '0';
                extended_r  <= '0';
                released_r  <= '0';

            ELSE
                IF ps2_clk_fall = '1' THEN

                    ----------------------------------------------------------------
                    -- Shift in one bit per falling edge
                    ----------------------------------------------------------------
                    shift_reg(bit_count) <= ps2_data_sync(2);

                    IF bit_count = 10 THEN
                        ----------------------------------------------------------------
                        -- Complete frame received
                        ----------------------------------------------------------------
                        data_byte := shift_reg(8 DOWNTO 1);

                        -- basic frame checks
                        start_ok := (shift_reg(0) = '0');
                        stop_ok  := (ps2_data_sync(2) = '1');

                        -- odd parity over data + parity bit
                        ones := 0;
                        FOR i IN 1 TO 9 LOOP
                            IF shift_reg(i) = '1' THEN
                                ones := ones + 1;
                            END IF;
                        END LOOP;
                        parity_ok := ((ones MOD 2) = 1);

                        bit_count <= 0;

                        IF start_ok AND stop_ok AND parity_ok THEN
                            ----------------------------------------------------------------
                            -- Handle prefixes and real scancodes
                            ----------------------------------------------------------------
                            IF data_byte = x"E0" THEN
                                ext_seen <= '1';

                            ELSIF data_byte = x"F0" THEN
                                break_seen <= '1';

                            ELSE
                                code_r      <= data_byte;
                                valid_r     <= '1';
                                extended_r  <= ext_seen;
                                released_r  <= break_seen;

                                ext_seen    <= '0';
                                break_seen  <= '0';
                            END IF;
                        ELSE
                            ----------------------------------------------------------------
                            -- Bad frame: drop it and reset prefix state
                            ----------------------------------------------------------------
                            ext_seen   <= '0';
                            break_seen <= '0';
                        END IF;

                    ELSE
                        bit_count <= bit_count + 1;
                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS;

END ARCHITECTURE rtl;