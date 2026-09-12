LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY uart_rx IS
    GENERIC (
        CLK_FREQ_HZ : INTEGER := 100000000
    );
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        baud_sel : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        rxd : IN STD_LOGIC;
        data_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        valid : OUT STD_LOGIC
    );
END ENTITY;

ARCHITECTURE rtl OF uart_rx IS
    CONSTANT CLKS_PER_BIT_300 : INTEGER := 333333;
    CONSTANT CLKS_PER_BIT_1200 : INTEGER := 83333;
    CONSTANT CLKS_PER_BIT_2400 : INTEGER := 41666;
    CONSTANT CLKS_PER_BIT_4800 : INTEGER := 20833;
    CONSTANT CLKS_PER_BIT_9600 : INTEGER := 10416;
    CONSTANT CLKS_PER_BIT_14400 : INTEGER := 6944;
    CONSTANT CLKS_PER_BIT_19200 : INTEGER := 5208;
    CONSTANT CLKS_PER_BIT_38400 : INTEGER := 2604;
    CONSTANT CLKS_PER_BIT_57600 : INTEGER := 1736;
    CONSTANT CLKS_PER_BIT_115200 : INTEGER := 868;

    SIGNAL clks_per_bit : INTEGER RANGE 1 TO CLKS_PER_BIT_300 := CLKS_PER_BIT_115200;
    SIGNAL half_clks_per_bit : INTEGER RANGE 1 TO CLKS_PER_BIT_300 := CLKS_PER_BIT_115200 / 2;
    SIGNAL baud_cnt : INTEGER RANGE 0 TO CLKS_PER_BIT_300 - 1 := 0;

    TYPE state_t IS (IDLE, START_BIT, DATA_BITS, STOP_BIT);
    SIGNAL state : state_t := IDLE;

    SIGNAL bit_cnt : INTEGER RANGE 0 TO 7 := 0;
    SIGNAL shift_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL data_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL valid_reg : STD_LOGIC := '0';
BEGIN
    data_out <= data_reg;
    valid <= valid_reg;

    PROCESS (baud_sel)
BEGIN
    CASE baud_sel IS
        WHEN "0000" =>
            clks_per_bit <= CLKS_PER_BIT_300;
            half_clks_per_bit <= CLKS_PER_BIT_300 / 2;
        WHEN "0001" =>
            clks_per_bit <= CLKS_PER_BIT_1200;
            half_clks_per_bit <= CLKS_PER_BIT_1200 / 2;
        WHEN "0010" =>
            clks_per_bit <= CLKS_PER_BIT_2400;
            half_clks_per_bit <= CLKS_PER_BIT_2400 / 2;
        WHEN "0011" =>
            clks_per_bit <= CLKS_PER_BIT_4800;
            half_clks_per_bit <= CLKS_PER_BIT_4800 / 2;
        WHEN "0100" =>
            clks_per_bit <= CLKS_PER_BIT_9600;
            half_clks_per_bit <= CLKS_PER_BIT_9600 / 2;
        WHEN "0101" =>
            clks_per_bit <= CLKS_PER_BIT_14400;
            half_clks_per_bit <= CLKS_PER_BIT_14400 / 2;
        WHEN "0110" =>
            clks_per_bit <= CLKS_PER_BIT_19200;
            half_clks_per_bit <= CLKS_PER_BIT_19200 / 2;
        WHEN "0111" =>
            clks_per_bit <= CLKS_PER_BIT_38400;
            half_clks_per_bit <= CLKS_PER_BIT_38400 / 2;
        WHEN "1000" =>
            clks_per_bit <= CLKS_PER_BIT_57600;
            half_clks_per_bit <= CLKS_PER_BIT_57600 / 2;
        WHEN OTHERS =>
            clks_per_bit <= CLKS_PER_BIT_115200;
            half_clks_per_bit <= CLKS_PER_BIT_115200 / 2;
    END CASE;
END PROCESS;

    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF reset = '1' THEN
                state <= IDLE;
                baud_cnt <= 0;
                bit_cnt <= 0;
                shift_reg <= (OTHERS => '0');
                data_reg <= (OTHERS => '0');
                valid_reg <= '0';
            ELSE
                valid_reg <= '0';

                CASE state IS
                    WHEN IDLE =>
                        baud_cnt <= 0;
                        bit_cnt <= 0;

                        -- Startbit erkannt
                        IF rxd = '0' THEN
                            state <= START_BIT;
                            baud_cnt <= 0;
                        END IF;

                    WHEN START_BIT =>
                        -- In die Mitte des Startbits warten
                        IF baud_cnt = half_clks_per_bit - 1 THEN
                            baud_cnt <= 0;

                            -- Startbit pr?fen
                            IF rxd = '0' THEN
                                state <= DATA_BITS;
                                bit_cnt <= 0;
                                shift_reg <= (OTHERS => '0');
                            ELSE
                                -- war nur Glitch
                                state <= IDLE;
                            END IF;
                        ELSE
                            baud_cnt <= baud_cnt + 1;
                        END IF;

                    WHEN DATA_BITS =>
                        IF baud_cnt = clks_per_bit - 1 THEN
                            baud_cnt <= 0;

                            -- LSB zuerst empfangen
                            shift_reg(bit_cnt) <= rxd;

                            IF bit_cnt = 7 THEN
                                bit_cnt <= 0;
                                state <= STOP_BIT;
                            ELSE
                                bit_cnt <= bit_cnt + 1;
                            END IF;
                        ELSE
                            baud_cnt <= baud_cnt + 1;
                        END IF;

                    WHEN STOP_BIT =>
                        IF baud_cnt = clks_per_bit - 1 THEN
                            baud_cnt <= 0;

                            -- Stopbit idealerweise = '1'
                            IF rxd = '1' THEN
                                data_reg <= shift_reg;
                                valid_reg <= '1';
                            END IF;

                            state <= IDLE;
                        ELSE
                            baud_cnt <= baud_cnt + 1;
                        END IF;
                END CASE;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;
