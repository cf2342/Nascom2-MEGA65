LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY uart_tx IS
    GENERIC (
        CLK_FREQ_HZ : INTEGER := 100000000
    );
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        baud_sel : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        data_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        start : IN STD_LOGIC;
        txd : OUT STD_LOGIC;
        busy : OUT STD_LOGIC
    );
END ENTITY;

ARCHITECTURE rtl OF uart_tx IS
    SIGNAL clks_per_bit : INTEGER := 868;
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

    TYPE state_t IS (IDLE, START_BIT, DATA_BITS, STOP_BIT);
    SIGNAL state : state_t := IDLE;

    SIGNAL baud_cnt : INTEGER RANGE 0 TO CLKS_PER_BIT_300 - 1 := 0;
    SIGNAL bit_cnt : INTEGER RANGE 0 TO 7 := 0;
    SIGNAL shift_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tx_reg : STD_LOGIC := '1';
    SIGNAL busy_reg : STD_LOGIC := '0';

BEGIN
    txd <= tx_reg;
    busy <= busy_reg;

    PROCESS (baud_sel)
    BEGIN
        CASE baud_sel IS
            WHEN "0000" => clks_per_bit <= CLKS_PER_BIT_300;
            WHEN "0001" => clks_per_bit <= CLKS_PER_BIT_1200;
            WHEN "0010" => clks_per_bit <= CLKS_PER_BIT_2400;
            WHEN "0011" => clks_per_bit <= CLKS_PER_BIT_4800;
            WHEN "0100" => clks_per_bit <= CLKS_PER_BIT_9600;
            WHEN "0101" => clks_per_bit <= CLKS_PER_BIT_14400;
            WHEN "0110" => clks_per_bit <= CLKS_PER_BIT_19200;
            WHEN "0111" => clks_per_bit <= CLKS_PER_BIT_38400;
            WHEN "1000" => clks_per_bit <= CLKS_PER_BIT_57600;
            WHEN OTHERS => clks_per_bit <= CLKS_PER_BIT_115200;
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
                tx_reg <= '1';
                busy_reg <= '0';
            ELSE
                CASE state IS
                    WHEN IDLE =>
                        tx_reg <= '1';
                        busy_reg <= '0';
                        baud_cnt <= 0;
                        bit_cnt <= 0;

                        IF start = '1' THEN
                            shift_reg <= data_in;
                            busy_reg <= '1';
                            state <= START_BIT;
                        END IF;

                    WHEN START_BIT =>
                        tx_reg <= '0';
                        IF baud_cnt = clks_per_bit - 1 THEN
                            baud_cnt <= 0;
                            state <= DATA_BITS;
                        ELSE
                            baud_cnt <= baud_cnt + 1;
                        END IF;

                    WHEN DATA_BITS =>
                        tx_reg <= shift_reg(0);
                        IF baud_cnt = clks_per_bit - 1 THEN
                            baud_cnt <= 0;
                            shift_reg <= '0' & shift_reg(7 DOWNTO 1);

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
                        tx_reg <= '1';
                        IF baud_cnt = clks_per_bit - 1 THEN
                            baud_cnt <= 0;
                            state <= IDLE;
                        ELSE
                            baud_cnt <= baud_cnt + 1;
                        END IF;
                END CASE;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;
