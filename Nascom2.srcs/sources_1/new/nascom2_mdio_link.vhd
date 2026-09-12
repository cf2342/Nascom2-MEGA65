--------------------------------------------------------------------------------
-- Minimal IEEE 802.3 Clause-22 MDIO reader for the MEGA65 SMSC PHY.
-- It polls PHY address 0, basic status register 1, and reports link bit 2.
--------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY nascom2_mdio_link IS
    PORT (
        clk50 : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        enable : IN STD_LOGIC;
        mdio : INOUT STD_LOGIC;
        mdc : OUT STD_LOGIC;
        phy_reset_n : OUT STD_LOGIC;
        link_up : OUT STD_LOGIC
    );
END ENTITY;

ARCHITECTURE rtl OF nascom2_mdio_link IS
    CONSTANT RESET_CYCLES : NATURAL := 500000;    -- 10 ms at 50 MHz
    CONSTANT STARTUP_CYCLES : NATURAL := 5000000; -- 100 ms after reset
    CONSTANT POLL_CYCLES : NATURAL := 50000000;   -- once per second
    CONSTANT MDIO_DIV : NATURAL := 25;            -- 1 MHz MDC
    SIGNAL reset_count : NATURAL RANGE 0 TO RESET_CYCLES := 0;
    SIGNAL poll_count : NATURAL RANGE 0 TO POLL_CYCLES := 0;
    SIGNAL div_count : NATURAL RANGE 0 TO MDIO_DIV - 1 := 0;
    SIGNAL mdc_reg : STD_LOGIC := '0';
    SIGNAL mdio_oe : STD_LOGIC := '0';
    SIGNAL mdio_out : STD_LOGIC := '1';
    SIGNAL command : STD_LOGIC_VECTOR(63 DOWNTO 0) :=
        x"FFFFFFFF" & "01" & "10" & "00000" & "00001" & "11" & x"FFFF";
    SIGNAL bit_index : INTEGER RANGE 0 TO 63 := 63;
    SIGNAL busy : STD_LOGIC := '0';
    SIGNAL read_value : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL link_reg : STD_LOGIC := '0';
BEGIN
    mdio <= mdio_out WHEN mdio_oe = '1' ELSE 'Z';
    mdc <= mdc_reg;
    link_up <= link_reg WHEN enable = '1' ELSE '0';
    phy_reset_n <= '1' WHEN enable = '1' AND reset_count = RESET_CYCLES ELSE '0';

    PROCESS (clk50)
        VARIABLE next_read_v : STD_LOGIC_VECTOR(15 DOWNTO 0);
    BEGIN
        IF rising_edge(clk50) THEN
            IF reset = '1' OR enable = '0' THEN
                reset_count <= 0;
                poll_count <= 0;
                div_count <= 0;
                mdc_reg <= '0';
                mdio_oe <= '0';
                mdio_out <= '1';
                bit_index <= 63;
                busy <= '0';
                read_value <= (OTHERS => '0');
                link_reg <= '0';
            ELSE
                IF reset_count < RESET_CYCLES THEN
                    reset_count <= reset_count + 1;
                    poll_count <= 0;
                    link_reg <= '0';
                ELSIF busy = '0' THEN
                    mdio_oe <= '0';
                    mdc_reg <= '0';
                    div_count <= 0;
                    IF poll_count < STARTUP_CYCLES THEN
                        poll_count <= poll_count + 1;
                    ELSIF poll_count < POLL_CYCLES THEN
                        poll_count <= poll_count + 1;
                    ELSE
                        poll_count <= STARTUP_CYCLES;
                        command <= x"FFFFFFFF" & "01" & "10" & "00000" & "00001" & "11" & x"FFFF";
                        bit_index <= 63;
                        read_value <= (OTHERS => '0');
                        busy <= '1';
                        mdio_oe <= '1';
                        mdio_out <= '1';
                    END IF;
                ELSE
                    IF div_count = MDIO_DIV - 1 THEN
                        div_count <= 0;
                        IF mdc_reg = '0' THEN
                            -- Rising MDC: sample the 16 data bits.
                            mdc_reg <= '1';
                            IF bit_index <= 15 THEN
                                next_read_v := read_value(14 DOWNTO 0) & mdio;
                                read_value <= next_read_v;
                            END IF;
                        ELSE
                            -- Falling MDC: advance and drive the next command bit.
                            mdc_reg <= '0';
                            IF bit_index = 0 THEN
                                busy <= '0';
                                mdio_oe <= '0';
                                link_reg <= read_value(2);
                            ELSE
                                bit_index <= bit_index - 1;
                                IF bit_index - 1 <= 17 THEN
                                    mdio_oe <= '0';
                                ELSE
                                    mdio_oe <= '1';
                                    mdio_out <= command(bit_index - 1);
                                END IF;
                            END IF;
                        END IF;
                    ELSE
                        div_count <= div_count + 1;
                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;
