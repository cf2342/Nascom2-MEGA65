--------------------------------------------------------------------------------
-- MEGA65 Nascom2                                                             --
--                                                                            --
--------------------------------------------------------------------------------
-- (C) Copyright 2026 Thomas Linke <mega65@nascom2.de>                        --
-- This file is the head of The Nascom2 Project. It is free software:         --
-- you can redistribute it and/or modify it under the terms of the GNU Lesser --
-- General Public License as published by the Free Software Foundation,       --
-- either version 3 of the License, or (at your option) any later version.    --
-- This project is distributed in the hope that it will be useful, but        --
-- WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY --
-- or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public     --
-- License for more details. You should have received a copy of the GNU       --
-- Lesser General Public License along with this project. If not, see         --
-- https://www.gnu.org/licenses/.                                             --
--                                                                            --
-- uses T80s from Daniel Wallner http://www.opencores.org/cvsweb.shtml/t80/   --
--------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.rom_image_pkg.ALL;
USE work.basic_rom_image_pkg.ALL;
USE work.expansion_rom_image_pkg.ALL;
USE work.nasdos_rom_image_pkg.ALL;
USE work.sd_file_pkg.ALL;
USE work.tyto_utils_pkg.ALL;
USE work.charrom_image_pkg.ALL;

LIBRARY UNISIM;
USE UNISIM.VComponents.ALL;

LIBRARY xpm;
USE xpm.vcomponents.ALL;

ENTITY Nascom2_Core IS
    PORT (
        clk100 : IN STD_LOGIC;
        led : OUT STD_LOGIC;
        uart_txd : OUT STD_LOGIC;
        uart_rxd : IN STD_LOGIC;
        pmod1_en : OUT STD_LOGIC;
        pmod1_flag : IN STD_LOGIC;
        p1lo_cts : IN STD_LOGIC;
        p1lo_rts : OUT STD_LOGIC;
        p1lo_txd : OUT STD_LOGIC;
        p1lo_rxd : IN STD_LOGIC;
        p1hi_cts : IN STD_LOGIC;
        p1hi_rts : OUT STD_LOGIC;
        p1hi_txd : OUT STD_LOGIC;
        p1hi_rxd : IN STD_LOGIC;
        pmod2_en : OUT STD_LOGIC;
        pmod2_flag : IN STD_LOGIC;
        p2lo_cts : IN STD_LOGIC;
        p2lo_rts : OUT STD_LOGIC;
        p2lo_txd : OUT STD_LOGIC;
        p2lo_rxd : IN STD_LOGIC;
        p2hi_cts : IN STD_LOGIC;
        p2hi_rts : OUT STD_LOGIC;
        p2hi_txd : OUT STD_LOGIC;
        p2hi_rxd : IN STD_LOGIC;
        joystick_a_n_i : IN STD_LOGIC_VECTOR(4 DOWNTO 0) := (OTHERS => '1');
        joystick_b_n_i : IN STD_LOGIC_VECTOR(4 DOWNTO 0) := (OTHERS => '1');
        hdmi_tx_clk_p : OUT STD_LOGIC;
        hdmi_tx_clk_n : OUT STD_LOGIC;
        hdmi_tx_p : OUT STD_LOGIC_VECTOR(0 TO 2);
        hdmi_tx_n : OUT STD_LOGIC_VECTOR(0 TO 2);
        audio_pdm_l : OUT STD_LOGIC;
        audio_pdm_r : OUT STD_LOGIC;
        audio_pcm_o : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        vga_clk_out : OUT STD_LOGIC;
        vga_blank_n_out : OUT STD_LOGIC;
        vga_sync_n_out : OUT STD_LOGIC;
        vga_psave_n_out : OUT STD_LOGIC;
        vga_red_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        vga_green_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        vga_blue_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        vga_hsync_out : OUT STD_LOGIC;
        vga_vsync_out : OUT STD_LOGIC;
        ps2_clk : IN STD_LOGIC;
        ps2_data : IN STD_LOGIC;
        manual_nmi_key_i : IN STD_LOGIC := '0';
        reset_btn : IN STD_LOGIC;
        rtc_scl_i : IN STD_LOGIC;
        rtc_scl_oe_n : OUT STD_LOGIC;
        rtc_sda_i : IN STD_LOGIC;
        rtc_sda_oe_n : OUT STD_LOGIC;
        rtc_seconds_i : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        rtc_minutes_i : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        rtc_hours_i : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        rtc_weekday_i : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        rtc_day_i : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        rtc_month_i : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        rtc_year_i : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        rtc_valid_i : IN STD_LOGIC;
        rtc_busy_i : IN STD_LOGIC;
        rtc_error_i : IN STD_LOGIC;
        rtc_toggle_i : IN STD_LOGIC;
        rtc_error_code_i : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        rtc_debug_busy_count_i : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        rtc_debug_status_i : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        rtc_debug_last_byte_i : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        rtc_debug_addr_i : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        sd_cclk : OUT STD_LOGIC;
        sd_cd : IN STD_LOGIC;
        sd_cmd : INOUT STD_LOGIC;
        sd_d : INOUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        sd_reset : OUT STD_LOGIC;
        network_enable_o : OUT STD_LOGIC;
        network_cpu_reset_o : OUT STD_LOGIC;
        network_dhcp_o : OUT STD_LOGIC;
        network_ipv4_o : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        network_netmask_o : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        network_gateway_o : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        network_dns_o : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        network_dns_query_toggle_o : OUT STD_LOGIC;
        network_dns_query_length_o : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        network_dns_query_data_o : OUT STD_LOGIC_VECTOR(511 DOWNTO 0);
        network_ping_start_toggle_o : OUT STD_LOGIC;
        network_ping_target_ip_o : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        network_ping_result_i : IN STD_LOGIC_VECTOR(7 DOWNTO 0) := x"E0";
        network_available_i : IN STD_LOGIC := '0';
        network_link_i : IN STD_LOGIC := '0';
        network_effective_ipv4_i : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        network_effective_netmask_i : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        network_effective_gateway_i : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        network_effective_dns_i : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        network_dhcp_status_i : IN STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
        network_debug_i : IN STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        network_tcp_status_i : IN STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
        network_tcp_status_socket_i : IN STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
        network_tcp_connect_toggle_o : OUT STD_LOGIC;
        network_tcp_connect_socket_o : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        network_tcp_connect_ip_o : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        network_tcp_connect_port_o : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        network_tcp_close_toggle_o : OUT STD_LOGIC;
        network_tcp_close_socket_o : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        network_tcp_send_toggle_o : OUT STD_LOGIC;
        network_tcp_send_socket_o : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        network_tcp_send_length_o : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        network_tcp_send_data_o : OUT STD_LOGIC_VECTOR(1023 DOWNTO 0);
        network_tcp_tx_ready_i : IN STD_LOGIC := '0';
        network_tcp_rx_toggle_i : IN STD_LOGIC := '0';
        network_tcp_rx_socket_i : IN STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
        network_tcp_rx_length_i : IN STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
        network_tcp_rx_data_i : IN STD_LOGIC_VECTOR(1023 DOWNTO 0) := (OTHERS => '0');
        network_tcp_query_socket_o : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        network_tcp_rx_consume_toggle_o : OUT STD_LOGIC;
        network_tcp_rx_consume_socket_o : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
    );
END Nascom2_Core;

ARCHITECTURE Behavioral OF Nascom2_Core IS

    FUNCTION slv8(ch : CHARACTER) RETURN STD_LOGIC_VECTOR IS
    BEGIN
        RETURN STD_LOGIC_VECTOR(to_unsigned(CHARACTER'POS(ch), 8));
    END FUNCTION;

    FUNCTION save_name_char_from_ps2(code_v : STD_LOGIC_VECTOR(7 DOWNTO 0)) RETURN STD_LOGIC_VECTOR IS
    BEGIN
        CASE code_v IS
            WHEN x"1C" => RETURN slv8('A');
            WHEN x"32" => RETURN slv8('B');
            WHEN x"21" => RETURN slv8('C');
            WHEN x"23" => RETURN slv8('D');
            WHEN x"24" => RETURN slv8('E');
            WHEN x"2B" => RETURN slv8('F');
            WHEN x"34" => RETURN slv8('G');
            WHEN x"33" => RETURN slv8('H');
            WHEN x"43" => RETURN slv8('I');
            WHEN x"3B" => RETURN slv8('J');
            WHEN x"42" => RETURN slv8('K');
            WHEN x"4B" => RETURN slv8('L');
            WHEN x"3A" => RETURN slv8('M');
            WHEN x"31" => RETURN slv8('N');
            WHEN x"44" => RETURN slv8('O');
            WHEN x"4D" => RETURN slv8('P');
            WHEN x"15" => RETURN slv8('Q');
            WHEN x"2D" => RETURN slv8('R');
            WHEN x"1B" => RETURN slv8('S');
            WHEN x"2C" => RETURN slv8('T');
            WHEN x"3C" => RETURN slv8('U');
            WHEN x"2A" => RETURN slv8('V');
            WHEN x"1D" => RETURN slv8('W');
            WHEN x"22" => RETURN slv8('X');
            WHEN x"35" => RETURN slv8('Y');
            WHEN x"1A" => RETURN slv8('Z');
            WHEN x"45" => RETURN slv8('0');
            WHEN x"16" => RETURN slv8('1');
            WHEN x"1E" => RETURN slv8('2');
            WHEN x"26" => RETURN slv8('3');
            WHEN x"25" => RETURN slv8('4');
            WHEN x"2E" => RETURN slv8('5');
            WHEN x"36" => RETURN slv8('6');
            WHEN x"3D" => RETURN slv8('7');
            WHEN x"3E" => RETURN slv8('8');
            WHEN x"46" => RETURN slv8('9');
            WHEN OTHERS => RETURN x"20";
        END CASE;
    END FUNCTION;

    FUNCTION adjust_ipv4_octet(
        value_i : STD_LOGIC_VECTOR(31 DOWNTO 0);
        octet_i : INTEGER;
        increment_i : BOOLEAN
    ) RETURN STD_LOGIC_VECTOR IS
        VARIABLE result_v : STD_LOGIC_VECTOR(31 DOWNTO 0) := value_i;
        VARIABLE octet_v : UNSIGNED(7 DOWNTO 0);
    BEGIN
        CASE octet_i IS
            WHEN 0 => octet_v := UNSIGNED(result_v(31 DOWNTO 24));
            WHEN 1 => octet_v := UNSIGNED(result_v(23 DOWNTO 16));
            WHEN 2 => octet_v := UNSIGNED(result_v(15 DOWNTO 8));
            WHEN OTHERS => octet_v := UNSIGNED(result_v(7 DOWNTO 0));
        END CASE;
        IF increment_i THEN
            IF octet_v = x"FF" THEN octet_v := x"00"; ELSE octet_v := octet_v + 1; END IF;
        ELSE
            IF octet_v = x"00" THEN octet_v := x"FF"; ELSE octet_v := octet_v - 1; END IF;
        END IF;
        CASE octet_i IS
            WHEN 0 => result_v(31 DOWNTO 24) := STD_LOGIC_VECTOR(octet_v);
            WHEN 1 => result_v(23 DOWNTO 16) := STD_LOGIC_VECTOR(octet_v);
            WHEN 2 => result_v(15 DOWNTO 8) := STD_LOGIC_VECTOR(octet_v);
            WHEN OTHERS => result_v(7 DOWNTO 0) := STD_LOGIC_VECTOR(octet_v);
        END CASE;
        RETURN result_v;
    END FUNCTION;

    FUNCTION save_hex_nibble_from_ps2(code_v : STD_LOGIC_VECTOR(7 DOWNTO 0)) RETURN STD_LOGIC_VECTOR IS
    BEGIN
        CASE code_v IS
            WHEN x"45" => RETURN x"0";
            WHEN x"16" => RETURN x"1";
            WHEN x"1E" => RETURN x"2";
            WHEN x"26" => RETURN x"3";
            WHEN x"25" => RETURN x"4";
            WHEN x"2E" => RETURN x"5";
            WHEN x"36" => RETURN x"6";
            WHEN x"3D" => RETURN x"7";
            WHEN x"3E" => RETURN x"8";
            WHEN x"46" => RETURN x"9";
            WHEN x"1C" => RETURN x"A";
            WHEN x"32" => RETURN x"B";
            WHEN x"21" => RETURN x"C";
            WHEN x"23" => RETURN x"D";
            WHEN x"24" => RETURN x"E";
            WHEN x"2B" => RETURN x"F";
            WHEN OTHERS => RETURN x"0";
        END CASE;
    END FUNCTION;

    FUNCTION save_hex_key(code_v : STD_LOGIC_VECTOR(7 DOWNTO 0)) RETURN BOOLEAN IS
    BEGIN
        CASE code_v IS
            WHEN x"45" | x"16" | x"1E" | x"26" | x"25" | x"2E" | x"36" | x"3D" |
                x"3E" | x"46" | x"1C" | x"32" | x"21" | x"23" | x"24" | x"2B" =>
                RETURN TRUE;
            WHEN OTHERS =>
                RETURN FALSE;
        END CASE;
    END FUNCTION;

    FUNCTION prev_rs232_speed_sel(sel_v : STD_LOGIC_VECTOR(3 DOWNTO 0)) RETURN STD_LOGIC_VECTOR IS
    BEGIN
        CASE sel_v IS
            WHEN "0000" => RETURN "1001";
            WHEN "0001" => RETURN "0000";
            WHEN "0010" => RETURN "0001";
            WHEN "0011" => RETURN "0010";
            WHEN "0100" => RETURN "0011";
            WHEN "0101" => RETURN "0100";
            WHEN "0110" => RETURN "0101";
            WHEN "0111" => RETURN "0110";
            WHEN "1000" => RETURN "0111";
            WHEN OTHERS => RETURN "1000";
        END CASE;
    END FUNCTION;

    FUNCTION next_rs232_speed_sel(sel_v : STD_LOGIC_VECTOR(3 DOWNTO 0)) RETURN STD_LOGIC_VECTOR IS
    BEGIN
        CASE sel_v IS
            WHEN "0000" => RETURN "0001";
            WHEN "0001" => RETURN "0010";
            WHEN "0010" => RETURN "0011";
            WHEN "0011" => RETURN "0100";
            WHEN "0100" => RETURN "0101";
            WHEN "0101" => RETURN "0110";
            WHEN "0110" => RETURN "0111";
            WHEN "0111" => RETURN "1000";
            WHEN "1000" => RETURN "1001";
            WHEN OTHERS => RETURN "0000";
        END CASE;
    END FUNCTION;

    --------------------------------------------------------------------
    -- CPU-Signale (T80s)
    --------------------------------------------------------------------
    SIGNAL cpu_a : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL cpu_dinst : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL cpu_di : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL cpu_do : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL cpu_page_b_data : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL cpu_page_c_data : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL cpu_page_d_data : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL cpu_page_ef_data : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL cpu_page_a_data : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL cpu_fetch_b_data : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL cpu_fetch_c_data : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL cpu_fetch_d_data : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL cpu_fetch_ef_data : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL cpu_fetch_a_data : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";

    -- F5 hardware monitor ("GOD mode") state exported by the T80 core.
    SIGNAL god_reg_addr : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
    SIGNAL god_debug_en : STD_LOGIC := '0';
    SIGNAL god_reg_data : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0000";
    SIGNAL god_af : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0000";
    SIGNAL god_af_alt : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0000";
    SIGNAL god_pc : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0000";
    SIGNAL god_sp : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0000";
    SIGNAL god_i : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL god_r : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL god_ir : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL god_im : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL god_iff : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL god_mc : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
    SIGNAL god_ts : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
    SIGNAL god_bc : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0000";
    SIGNAL god_de : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0000";
    SIGNAL god_hl : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0000";
    SIGNAL god_iy : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0000";
    SIGNAL god_bc_alt : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0000";
    SIGNAL god_de_alt : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0000";
    SIGNAL god_hl_alt : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0000";
    SIGNAL god_ix : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0000";
    TYPE god_run_state_t IS (
        GOD_RUN_IDLE,
        GOD_RUN_WAIT_HIGH,
        GOD_RUN_WAIT_BOUNDARY,
        GOD_RUN_WAIT_COMMIT,
        GOD_RUN_PC_LOAD
    );
    SIGNAL god_run_state : god_run_state_t := GOD_RUN_IDLE;
    SIGNAL god_run_active : STD_LOGIC := '0';
    SIGNAL god_step_req : STD_LOGIC := '0';
    SIGNAL god_exec_req : STD_LOGIC := '0';
    SIGNAL god_exec_addr : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"1000";
    SIGNAL god_pc_load : STD_LOGIC := '0';
    SIGNAL god_pc_load_data : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0000";
    SIGNAL god_commit : STD_LOGIC := '0';
    SIGNAL bls_low_exec_fault : STD_LOGIC := '0';
    SIGNAL bls_low_exec_from_pc : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0000";
    SIGNAL bls_low_exec_to_pc : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0000";
    SIGNAL bls_low_exec_sp : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0000";
    SIGNAL bls_last_m1_pc : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0000";
    SIGNAL bls_m1_n_last : STD_LOGIC := '1';

    SIGNAL m1_n : STD_LOGIC;
    SIGNAL mreq_n : STD_LOGIC;
    SIGNAL iorq_n : STD_LOGIC;
    SIGNAL rd_n : STD_LOGIC;
    SIGNAL wr_n : STD_LOGIC;
    SIGNAL rfsh_n : STD_LOGIC;
    SIGNAL halt_n : STD_LOGIC;
    SIGNAL busak_n : STD_LOGIC;
    SIGNAL cpu_nmi_n : STD_LOGIC := '1';
    SIGNAL m1_b : STD_LOGIC := '0';
    SIGNAL step_port3_last : STD_LOGIC := '0';
    SIGNAL step_m1b_last : STD_LOGIC := '0';
    SIGNAL step_ic14a_q : STD_LOGIC := '0';
    SIGNAL step_ic14b_q : STD_LOGIC := '1';
    SIGNAL step_ic15a_q : STD_LOGIC := '1';
    SIGNAL step_ic15b_q : STD_LOGIC := '0';
    SIGNAL manual_nmi_n_i : STD_LOGIC := '1';
    -- Keep the manual NMI low long enough to cross the emulated CPU clock
    -- enables at every selectable speed.  A 20 us one-shot is still short
    -- for a human-operated button but cannot fall between Z80 sample points.
    SIGNAL manual_nmi_pulse_cnt : INTEGER RANGE 0 TO 4095 := 0;
    SIGNAL manual_nmi_key_last : STD_LOGIC := '0';

    --------------------------------------------------------------------
    -- CPU-Takt
    --------------------------------------------------------------------
    SIGNAL clk_div : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL cpu_phase : STD_LOGIC := '0';
    SIGNAL cpu_cen : STD_LOGIC := '0';
    SIGNAL div_value : UNSIGNED(31 DOWNTO 0);

    --------------------------------------------------------------------
    -- AY-3-8910 sound generator
    --------------------------------------------------------------------
    SIGNAL ay_clock_divider : INTEGER RANGE 0 TO 49 := 0;
    SIGNAL ay_clock_enable_2mhz : STD_LOGIC := '0';
    SIGNAL ay_register_select_write : STD_LOGIC := '0';
    SIGNAL ay_register_data_write : STD_LOGIC := '0';
    SIGNAL ay_io_write_last : STD_LOGIC := '0';
    SIGNAL ay_register_data : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL ay_pcm : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0000";
    SIGNAL joystick_a_meta : STD_LOGIC_VECTOR(4 DOWNTO 0) := (OTHERS => '1');
    SIGNAL joystick_a_sync : STD_LOGIC_VECTOR(4 DOWNTO 0) := (OTHERS => '1');
    SIGNAL joystick_b_meta : STD_LOGIC_VECTOR(4 DOWNTO 0) := (OTHERS => '1');
    SIGNAL joystick_b_sync : STD_LOGIC_VECTOR(4 DOWNTO 0) := (OTHERS => '1');
    ATTRIBUTE ASYNC_REG : STRING;
    ATTRIBUTE ASYNC_REG OF joystick_a_meta : SIGNAL IS "TRUE";
    ATTRIBUTE ASYNC_REG OF joystick_a_sync : SIGNAL IS "TRUE";
    ATTRIBUTE ASYNC_REG OF joystick_b_meta : SIGNAL IS "TRUE";
    ATTRIBUTE ASYNC_REG OF joystick_b_sync : SIGNAL IS "TRUE";

    --------------------------------------------------------------------
    -- Reset
    --------------------------------------------------------------------
    SIGNAL reset_cnt : UNSIGNED(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL startup_reset_cnt : UNSIGNED(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL sys_reset_hold_cnt : UNSIGNED(19 DOWNTO 0) := (OTHERS => '0');
    SIGNAL cpu_reset_n : STD_LOGIC := '0';
    SIGNAL raw_reset_req : STD_LOGIC := '1';
    SIGNAL sys_reset : STD_LOGIC := '1';
    SIGNAL reset_req_last : STD_LOGIC := '1';
    SIGNAL reset_event_count : UNSIGNED(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ui_reset_event_count : UNSIGNED(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL cfg_reset_event_count : UNSIGNED(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL reset_btn_meta : STD_LOGIC := '1';
    SIGNAL reset_btn_sync : STD_LOGIC := '1';
    SIGNAL reset_btn_debounced : STD_LOGIC := '1';
    SIGNAL reset_btn_pulse : STD_LOGIC := '0';
    SIGNAL reset_btn_debounce_count : INTEGER RANGE 0 TO 99999 := 0;
    SIGNAL hdmi_reset_meta : STD_LOGIC := '1';
    SIGNAL hdmi_reset_sync : STD_LOGIC := '1';
    SIGNAL sd_cd_meta : STD_LOGIC := '1';
    SIGNAL sd_cd_sync : STD_LOGIC := '1';
    --------------------------------------------------------------------
    -- RAM
    --------------------------------------------------------------------
    CONSTANT FAST_BUILD_TRIM_MEMORY : BOOLEAN := FALSE;
    CONSTANT DEBUG_ISOLATE_VRAM_WRITES : BOOLEAN := FALSE;
    CONSTANT DEBUG_ISOLATE_VRAM_READS : BOOLEAN := FALSE;

    FUNCTION addr_in_main_ram(addr_v : STD_LOGIC_VECTOR(15 DOWNTO 0)) RETURN BOOLEAN IS
        VARIABLE high_nibble_v : UNSIGNED(3 DOWNTO 0);
    BEGIN
        high_nibble_v := unsigned(addr_v(15 DOWNTO 12));

        IF addr_v(15 DOWNTO 12) = x"0" THEN
            RETURN addr_v(11 DOWNTO 10) = "11";
        ELSIF FAST_BUILD_TRIM_MEMORY THEN
            RETURN addr_v(15 DOWNTO 12) = x"1";
        ELSE
            RETURN high_nibble_v >= to_unsigned(1, 4) AND high_nibble_v <= to_unsigned(10, 4);
        END IF;
    END FUNCTION;

    FUNCTION addr_is_vram(addr_v : STD_LOGIC_VECTOR(15 DOWNTO 0)) RETURN BOOLEAN IS
    BEGIN
        RETURN addr_v(15 DOWNTO 12) = x"0" AND addr_v(11 DOWNTO 10) = "10";
    END FUNCTION;

    FUNCTION calc_main_ram_size_bytes RETURN INTEGER IS
    BEGIN
        IF FAST_BUILD_TRIM_MEMORY THEN
            RETURN 16#1400#; -- 0C00..1FFF
        ELSE
            -- The address is stored as (CPU address - 0C00h) modulo 64 KiB.
            -- This retains the normal 0C00h..AFFFh map and also provides the
            -- low/high shadow RAM required by CP/M banking.
            RETURN 16#10000#;
        END IF;
    END FUNCTION;

    CONSTANT MAIN_RAM_SIZE_BYTES : INTEGER := calc_main_ram_size_bytes;
    CONSTANT MAIN_RAM_ADDR_WIDTH : INTEGER := log2(MAIN_RAM_SIZE_BYTES);

    TYPE slot2k_ram_t IS ARRAY (0 TO 16#07FF#) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    TYPE slot4k_ram_t IS ARRAY (0 TO 16#0FFF#) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    TYPE cpm_monitor_ram_t IS ARRAY (0 TO 16#03FF#) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL TOOLKIT_RAM : slot2k_ram_t := (OTHERS => (OTHERS => '0'));
    SIGNAL NASPEN_RAM : slot2k_ram_t := (OTHERS => (OTHERS => '0'));
    SIGNAL NASDIS_RAM : slot4k_ram_t := (OTHERS => (OTHERS => '0'));
    SIGNAL ZEAP_RAM : slot4k_ram_t := (OTHERS => (OTHERS => '0'));
    -- The historical CP/M overlay has a private 1 KiB workspace at
    -- FC00h..FFFFh.  It must not alias the CP/M system RAM underneath.
    SIGNAL CPM_MONITOR_RAM : cpm_monitor_ram_t := (OTHERS => (OTHERS => '0'));

    --------------------------------------------------------------------
    -- RS232
    --------------------------------------------------------------------
    SIGNAL rs232_use_jtag : STD_LOGIC;
    SIGNAL rs232_use_pmod1 : STD_LOGIC;
    SIGNAL rs232_use_pmod2 : STD_LOGIC;
    SIGNAL rs232_use_p1hi : STD_LOGIC;
    SIGNAL rs232_use_p1lo : STD_LOGIC;
    SIGNAL rs232_use_p2hi : STD_LOGIC;
    SIGNAL rs232_use_p2lo : STD_LOGIC;
    SIGNAL rs232_selected_flag_ok : STD_LOGIC;
    SIGNAL rs232_cts_ok : STD_LOGIC;
    SIGNAL rs232_rts_out : STD_LOGIC;
    SIGNAL rs232_tx_ready : STD_LOGIC;
    SIGNAL overlay_pmod_fault_active : STD_LOGIC;
    SIGNAL overlay_pmod_fault_pmod2 : STD_LOGIC;
    SIGNAL rs232_uart_txd : STD_LOGIC := '1';
    SIGNAL rs232_uart_rxd : STD_LOGIC := '1';
    SIGNAL uart_baud_sel : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1001";

    --------------------------------------------------------------------
    -- UART-TX
    --------------------------------------------------------------------
    SIGNAL uart_start : STD_LOGIC := '0';
    SIGNAL uart_busy : STD_LOGIC;
    SIGNAL uart_data : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL wr_n_last : STD_LOGIC := '1';

    TYPE esc_state_t IS (ESC_IDLE, ESC_SEEN, CSI_SEEN);
    SIGNAL esc_state : esc_state_t := ESC_IDLE;

    --------------------------------------------------------------------
    -- UART-RX + 4-Byte FIFO
    --------------------------------------------------------------------
    SIGNAL uart_rx_data : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL uart_rx_valid : STD_LOGIC;

    TYPE rx_fifo_t IS ARRAY (0 TO 3) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL rx_fifo : rx_fifo_t := (OTHERS => x"00");

    SIGNAL rx_wr_ptr : INTEGER RANGE 0 TO 3 := 0;
    SIGNAL rx_rd_ptr : INTEGER RANGE 0 TO 3 := 0;
    SIGNAL rx_count : INTEGER RANGE 0 TO 4 := 0;

    SIGNAL rd_n_last : STD_LOGIC := '1';
    SIGNAL rx_pop_pending : STD_LOGIC := '0';
    SIGNAL basic_autostart_req : STD_LOGIC := '0';
    SIGNAL basic_autostart_seen : STD_LOGIC := '0';
    SIGNAL basic_autostart_ui_seen : STD_LOGIC := '0';

    --------------------------------------------------------------------
    -- HDMI
    --------------------------------------------------------------------
    SIGNAL hdmi_mode : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL hdmi_heartbeat : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL hdmi_status : STD_LOGIC_VECTOR(1 DOWNTO 0);

    --------------------------------------------------------------------
    -- Memory Map
    --------------------------------------------------------------------
    CONSTANT VIDEO_RAM_BASE : unsigned(15 DOWNTO 0) := x"0800";

    CONSTANT RAM_BASE : unsigned(15 DOWNTO 0) := x"0C00";

    CONSTANT TOOLKIT_BASE : unsigned(15 DOWNTO 0) := x"B000";
    CONSTANT NASPEN_BASE : unsigned(15 DOWNTO 0) := x"B800";

    CONSTANT NASDIS_BASE : unsigned(15 DOWNTO 0) := x"C000";
    CONSTANT BLS_PASCAL_BASE : unsigned(15 DOWNTO 0) := x"A000";

    CONSTANT ZEAP_BASE : unsigned(15 DOWNTO 0) := x"D000";

    --------------------------------------------------------------------
    -- Video RAM
    --------------------------------------------------------------------
    SIGNAL vram_clk : STD_LOGIC := '0';
    SIGNAL vram_addr : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
    SIGNAL vram_data : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"20";
    SIGNAL vram_sys_en : STD_LOGIC := '0';
    SIGNAL vram_sys_we : STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
    SIGNAL vram_sys_addr : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
    SIGNAL vram_sys_din : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"20";
    SIGNAL vram_sys_dout : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"20";
    TYPE vram_read_state_t IS (VRAM_READ_IDLE, VRAM_READ_WAIT_DATA, VRAM_READ_CAPTURE, VRAM_READ_RELEASE);
    SIGNAL vram_read_state : vram_read_state_t := VRAM_READ_IDLE;
    SIGNAL vram_read_addr : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
    SIGNAL vram_read_data : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"20";
    SIGNAL vram_clear_active : STD_LOGIC := '1';
    SIGNAL vram_clear_addr : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
    SIGNAL cpu_wait_n : STD_LOGIC := '1';
    SIGNAL vram_wait_n_i : STD_LOGIC := '1';
    --------------------------------------------------------------------
    -- Lucas Logic Advanced Video Controller (AVC Model B)
    --
    -- The original card provides three independent 16 KiB bit planes at
    -- 8000h..BFFFh.  Control-port bits 0..2 page those planes over normal
    -- memory; writes may target several planes, reads select the first
    -- enabled plane.  The second BRAM ports feed the HDMI rasterizer.
    --------------------------------------------------------------------
    TYPE avc_crtc_regs_t IS ARRAY (0 TO 17) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    TYPE avc_plane_data_t IS ARRAY (0 TO 2) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    TYPE avc_read_state_t IS (AVC_READ_IDLE, AVC_READ_WAIT_DATA, AVC_READ_CAPTURE, AVC_READ_RELEASE);
    TYPE avc_terminal_state_t IS (
        AVC_TERM_IDLE,
        AVC_TERM_DRAW,
        AVC_TERM_ADVANCE,
        AVC_TERM_CLEAR,
        AVC_TERM_CLEAR_EOL,
        AVC_TERM_SCROLL_CLEAR
    );
    SIGNAL avc_crtc_regs : avc_crtc_regs_t := (OTHERS => (OTHERS => '0'));
    SIGNAL avc_crtc_index : UNSIGNED(4 DOWNTO 0) := (OTHERS => '0');
    SIGNAL avc_programmed_start_addr : STD_LOGIC_VECTOR(13 DOWNTO 0) := (OTHERS => '0');
    SIGNAL avc_crtc_start_addr : STD_LOGIC_VECTOR(14 DOWNTO 0) := (OTHERS => '0');
    SIGNAL avc_control_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"80";
    SIGNAL avc_cpu_mem_sel : STD_LOGIC := '0';
    SIGNAL avc_cpu_rd_sel : STD_LOGIC := '0';
    SIGNAL avc_cpu_wr_sel : STD_LOGIC := '0';
    SIGNAL avc_wait_n_i : STD_LOGIC := '1';
    SIGNAL avc_read_state : avc_read_state_t := AVC_READ_IDLE;
    SIGNAL avc_read_addr : STD_LOGIC_VECTOR(13 DOWNTO 0) := (OTHERS => '0');
    SIGNAL avc_read_plane : INTEGER RANGE 0 TO 2 := 0;
    SIGNAL avc_read_data : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL avc_sys_en : STD_LOGIC := '0';
    SIGNAL avc_sys_we : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL avc_sys_addr : STD_LOGIC_VECTOR(14 DOWNTO 0) := (OTHERS => '0');
    SIGNAL avc_sys_din : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL avc_sys_dout : avc_plane_data_t := (OTHERS => (OTHERS => '0'));
    SIGNAL avc_video_addr : STD_LOGIC_VECTOR(14 DOWNTO 0) := (OTHERS => '0');
    SIGNAL avc_video_data : avc_plane_data_t := (OTHERS => (OTHERS => '0'));
    SIGNAL avc_terminal_enabled : STD_LOGIC := '0';
    SIGNAL avc_terminal_busy : STD_LOGIC := '0';
    SIGNAL avc_terminal_char : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"20";
    SIGNAL avc_terminal_req_toggle : STD_LOGIC := '0';
    SIGNAL avc_terminal_ack_toggle : STD_LOGIC := '0';
    SIGNAL avc_terminal_io_write_last : STD_LOGIC := '0';
    SIGNAL avc_terminal_state : avc_terminal_state_t := AVC_TERM_IDLE;
    SIGNAL avc_terminal_col : INTEGER RANGE 0 TO 95 := 0;
    SIGNAL avc_terminal_row : INTEGER RANGE 0 TO 23 := 0;
    SIGNAL avc_terminal_glyph_row : INTEGER RANGE 0 TO 15 := 0;
    SIGNAL avc_terminal_start_addr : UNSIGNED(14 DOWNTO 0) := (OTHERS => '0');
    SIGNAL avc_terminal_clear_addr : UNSIGNED(14 DOWNTO 0) := (OTHERS => '0');
    SIGNAL avc_terminal_clear_col : INTEGER RANGE 0 TO 95 := 0;
    -- VT52 subset for screen-oriented CP/M programs: ESC Y row+32 col+32,
    -- and ESC K to erase from the current cursor to the end of the line.
    SIGNAL avc_terminal_escape_state : INTEGER RANGE 0 TO 3 := 0;
    SIGNAL avc_terminal_scroll_base : UNSIGNED(14 DOWNTO 0) := (OTHERS => '0');
    SIGNAL avc_terminal_scroll_offset : INTEGER RANGE 0 TO 1023 := 0;
    TYPE mainram_read_state_t IS (MAINRAM_READ_IDLE, MAINRAM_READ_WAIT_DATA, MAINRAM_READ_CAPTURE, MAINRAM_READ_RELEASE);
    SIGNAL mainram_read_state : mainram_read_state_t := MAINRAM_READ_IDLE;
    SIGNAL mainram_wait_n_i : STD_LOGIC := '1';
    SIGNAL mainram_sys_we : STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
    SIGNAL mainram_sys_addr : STD_LOGIC_VECTOR(MAIN_RAM_ADDR_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL mainram_sys_din : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL mainram_sys_dout : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL mainram_rd_addr : STD_LOGIC_VECTOR(MAIN_RAM_ADDR_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL mainram_rd_mux_addr : STD_LOGIC_VECTOR(MAIN_RAM_ADDR_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL mainram_rd_dout : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL mainram_read_data : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL god_mem_base : UNSIGNED(15 DOWNTO 0) := x"1000";
    SIGNAL god_mem_cursor : INTEGER RANGE 0 TO 63 := 0;
    SIGNAL god_mem_scan_index : INTEGER RANGE 0 TO 63 := 0;
    SIGNAL god_mem_scan_phase : INTEGER RANGE 0 TO 2 := 0;
    SIGNAL god_mem_snapshot : STD_LOGIC_VECTOR(511 DOWNTO 0) := (OTHERS => '0');
    SIGNAL god_mem_wr : STD_LOGIC := '0';
    SIGNAL god_mem_wr_addr : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"1000";
    SIGNAL god_mem_wr_data : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL god_mem_edit_high : STD_LOGIC := '1';
    SIGNAL god_mem_high_nibble : STD_LOGIC_VECTOR(3 DOWNTO 0) := x"0";
    SIGNAL god_addr_edit : STD_LOGIC := '0';
    SIGNAL god_addr_digit : INTEGER RANGE 0 TO 3 := 0;
    SIGNAL god_addr_pending : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"1000";
    SIGNAL basic_init_lo_shadow : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL basic_init_hi_shadow : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL basic_endptr_lo_shadow : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL basic_endptr_hi_shadow : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL bls_text_end_lo_shadow : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL bls_text_end_hi_shadow : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    CONSTANT BASIC_LOAD_START_ADDR : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"10FA";
    CONSTANT BASIC_CAS_LOAD_START_ADDR : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"10D6";
    CONSTANT BASIC_LOAD_PRE_START_ADDR : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"10F9";
    CONSTANT BASIC_LOAD_MAX_RAM_ADDR : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"AFFF";
    CONSTANT BASIC_LOAD_STRING_TOP_ADDR : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"AFCD";
    CONSTANT BASIC_LOAD_WORK_START_ADDR : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"10B3";
    CONSTANT BASIC_WORK_INIT_RAM_BASE : UNSIGNED(15 DOWNTO 0) := x"1000";
    CONSTANT BASIC_WORK_INIT_ROM_BASE : INTEGER := 16#02DF#;
    CONSTANT BASIC_WORK_INIT_LAST : UNSIGNED(6 DOWNTO 0) := to_unsigned(16#62#, 7);
    CONSTANT BLS_LOAD_START_ADDR : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"1000";
    CONSTANT BLS_LOAD_LIMIT_ADDR : UNSIGNED(15 DOWNTO 0) := x"A000";
    TYPE basic_load_fix_state_t IS (
        BASIC_LOAD_FIX_IDLE,
        BASIC_LOAD_FIX_COPY_WORK_INIT,
        BASIC_LOAD_FIX_INIT_LO,
        BASIC_LOAD_FIX_INIT_HI,
        BASIC_LOAD_FIX_ENDPTR_LO,
        BASIC_LOAD_FIX_ENDPTR_HI,
        BASIC_LOAD_FIX_VARTAB_LO,
        BASIC_LOAD_FIX_VARTAB_HI,
        BASIC_LOAD_FIX_ARYTAB_LO,
        BASIC_LOAD_FIX_ARYTAB_HI,
        BASIC_LOAD_FIX_CURTXT_LO,
        BASIC_LOAD_FIX_CURTXT_HI,
        BASIC_LOAD_FIX_MEMTOP_LO,
        BASIC_LOAD_FIX_MEMTOP_HI,
        BASIC_LOAD_FIX_STRTOP_LO,
        BASIC_LOAD_FIX_STRTOP_HI,
        BASIC_LOAD_FIX_WORKPTR_LO,
        BASIC_LOAD_FIX_WORKPTR_HI,
        BASIC_LOAD_FIX_MEMCOPY_LO,
        BASIC_LOAD_FIX_MEMCOPY_HI,
        BLS_LOAD_FIX_TEXT_END_LO,
        BLS_LOAD_FIX_TEXT_END_HI,
        BLS_LOAD_FIX_OBJECT_END_LO,
        BLS_LOAD_FIX_OBJECT_END_HI,
        BLS_LOAD_FIX_EDITOR_POS_LO,
        BLS_LOAD_FIX_EDITOR_POS_HI,
        BLS_LOAD_FIX_EDITOR_TOP_LO,
        BLS_LOAD_FIX_EDITOR_TOP_HI
    );
    SIGNAL basic_load_track_active : STD_LOGIC := '0';
    SIGNAL basic_load_last_addr : UNSIGNED(15 DOWNTO 0) := x"0000";
    SIGNAL basic_load_fix_start_pending : STD_LOGIC := '0';
    SIGNAL basic_load_fix_eval_pending : STD_LOGIC := '0';
    SIGNAL basic_load_fix_pending_end_ptr : UNSIGNED(15 DOWNTO 0) := x"0000";
    SIGNAL basic_load_fix_end_ptr : UNSIGNED(15 DOWNTO 0) := x"0000";
    SIGNAL basic_load_init_index : UNSIGNED(6 DOWNTO 0) := (OTHERS => '0');
    SIGNAL basic_load_fix_state : basic_load_fix_state_t := BASIC_LOAD_FIX_IDLE;
    SIGNAL basic_load_fix_wr : STD_LOGIC := '0';
    SIGNAL basic_load_fix_addr : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0000";
    SIGNAL basic_load_fix_data : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL basic_load_first_link_lo : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL basic_load_first_link_hi : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL basic_load_first_term : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL basic_load_first_term_valid : STD_LOGIC := '0';
    SIGNAL basic_load_tail_prev : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL basic_load_tail_last : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL bls_load_track_active : STD_LOGIC := '0';
    SIGNAL bls_load_last_addr : UNSIGNED(15 DOWNTO 0) := x"0000";
    SIGNAL bls_load_tail_last : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL bls_load_fix_eval_pending : STD_LOGIC := '0';
    SIGNAL bls_load_fix_end_ptr : UNSIGNED(15 DOWNTO 0) := x"1000";

    --------------------------------------------------------------------
    -- Port Configuration
    --------------------------------------------------------------------
    SIGNAL port0_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL cpm_low_ram_enabled : STD_LOGIC := '0';
    SIGNAL cpm_boot_overlay_enabled : STD_LOGIC := '0';
    SIGNAL network_status_data : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL network_response_data : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";

    TYPE rtc_reg_array_t IS ARRAY (0 TO 6) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL rtc_busy_reg : STD_LOGIC := '0';
    SIGNAL rtc_valid_reg : STD_LOGIC := '0';
    SIGNAL rtc_error_reg : STD_LOGIC := '0';
    SIGNAL rtc_error_code_reg : STD_LOGIC_VECTOR(3 DOWNTO 0) := x"0";
    SIGNAL rtc_update_toggle_reg : STD_LOGIC := '0';
    SIGNAL rtc_regs_reg : rtc_reg_array_t := (OTHERS => x"00");

    TYPE browser_action_t IS (BROWSE_NONE, BROWSE_RESET, BROWSE_UP, BROWSE_DOWN, BROWSE_PAGE_UP, BROWSE_PAGE_DOWN, BROWSE_LOAD);
    TYPE browser_manage_mode_t IS (
        BROWSER_MANAGE_IDLE,
        BROWSER_MANAGE_RENAME_EDIT,
        BROWSER_MANAGE_RENAME_CONFIRM,
        BROWSER_MANAGE_DELETE_CONFIRM,
        BROWSER_MANAGE_BUSY,
        BROWSER_MANAGE_RESULT
    );
    SIGNAL tape_led_active : STD_LOGIC := '0';
    SIGNAL halt_active : STD_LOGIC := '0';

    --------------------------------------------------------------------
    -- Tastatur PS/2
    --------------------------------------------------------------------
    SIGNAL ps2_code : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL ps2_valid : STD_LOGIC;
    SIGNAL ps2_extended : STD_LOGIC;
    SIGNAL ps2_released : STD_LOGIC;
    SIGNAL kbd_diag_make_code : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL kbd_diag_make_extended : STD_LOGIC := '0';
    SIGNAL kbd_diag_make_ctrl : STD_LOGIC := '0';
    SIGNAL kbd_diag_make_shift_l : STD_LOGIC := '0';
    SIGNAL kbd_diag_make_shift_r : STD_LOGIC := '0';
    SIGNAL kbd_diag_make_nmi_match : STD_LOGIC := '0';
    SIGNAL kbd_diag_make_count : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";

    --------------------------------------------------------------------
    -- Nascom Keyboard State
    --------------------------------------------------------------------
    SIGNAL nk_0 : STD_LOGIC := '0';
    SIGNAL nk_1 : STD_LOGIC := '0';
    SIGNAL nk_2 : STD_LOGIC := '0';
    SIGNAL nk_3 : STD_LOGIC := '0';
    SIGNAL nk_4 : STD_LOGIC := '0';
    SIGNAL nk_5 : STD_LOGIC := '0';
    SIGNAL nk_6 : STD_LOGIC := '0';
    SIGNAL nk_7 : STD_LOGIC := '0';
    SIGNAL nk_8 : STD_LOGIC := '0';
    SIGNAL nk_9 : STD_LOGIC := '0';
    SIGNAL nk_a : STD_LOGIC := '0';
    SIGNAL nk_b : STD_LOGIC := '0';
    SIGNAL nk_c : STD_LOGIC := '0';
    SIGNAL nk_d : STD_LOGIC := '0';
    SIGNAL nk_e : STD_LOGIC := '0';
    SIGNAL nk_f : STD_LOGIC := '0';
    SIGNAL nk_g : STD_LOGIC := '0';
    SIGNAL nk_h : STD_LOGIC := '0';
    SIGNAL nk_i : STD_LOGIC := '0';
    SIGNAL nk_j : STD_LOGIC := '0';
    SIGNAL nk_k : STD_LOGIC := '0';
    SIGNAL nk_l : STD_LOGIC := '0';
    SIGNAL nk_m : STD_LOGIC := '0';
    SIGNAL nk_n : STD_LOGIC := '0';
    SIGNAL nk_o : STD_LOGIC := '0';
    SIGNAL nk_p : STD_LOGIC := '0';
    SIGNAL nk_q : STD_LOGIC := '0';
    SIGNAL nk_r : STD_LOGIC := '0';
    SIGNAL nk_s : STD_LOGIC := '0';
    SIGNAL nk_t : STD_LOGIC := '0';
    SIGNAL nk_u : STD_LOGIC := '0';
    SIGNAL nk_v : STD_LOGIC := '0';
    SIGNAL nk_w : STD_LOGIC := '0';
    SIGNAL nk_x : STD_LOGIC := '0';
    SIGNAL nk_y : STD_LOGIC := '0';
    SIGNAL nk_z : STD_LOGIC := '0';
    SIGNAL nk_sp : STD_LOGIC := '0';
    SIGNAL nk_sh : STD_LOGIC := '0';
    SIGNAL nk_sh_l : STD_LOGIC := '0';
    SIGNAL nk_sh_r : STD_LOGIC := '0';
    SIGNAL nk_ct : STD_LOGIC := '0';
    SIGNAL nk_esc : STD_LOGIC := '0';
    SIGNAL nk_ct_matrix : STD_LOGIC := '0';
    SIGNAL nk_lb_matrix : STD_LOGIC := '0';
    SIGNAL nk_nl : STD_LOGIC := '0';
    SIGNAL nk_bs : STD_LOGIC := '0';
    SIGNAL nk_pu : STD_LOGIC := '0';
    SIGNAL nk_pd : STD_LOGIC := '0';
    SIGNAL nk_pl : STD_LOGIC := '0';
    SIGNAL nk_pr : STD_LOGIC := '0';
    SIGNAL nk_gr : STD_LOGIC := '0';
    SIGNAL nk_tb : STD_LOGIC := '0';
    SIGNAL nk_at : STD_LOGIC := '0';
    SIGNAL nk_plus : STD_LOGIC := '0';
    SIGNAL nk_star : STD_LOGIC := '0';
    SIGNAL nk_comma : STD_LOGIC := '0';
    SIGNAL nk_dot : STD_LOGIC := '0';
    SIGNAL nk_minus : STD_LOGIC := '0';
    SIGNAL nk_slash : STD_LOGIC := '0';
    SIGNAL nk_lb : STD_LOGIC := '0';
    SIGNAL nk_rb : STD_LOGIC := '0';

    --------------------------------------------------------------------
    -- Overlay-/Browser-/Save-UI-Zustand
    --------------------------------------------------------------------
    SIGNAL kbd_port0_in : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"FF";

    SIGNAL port0_wr_n_last : STD_LOGIC := '1';
    SIGNAL ui_overlay_enable : STD_LOGIC := '0';
    SIGNAL ui_overlay_page : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
    SIGNAL ui_cfg_row_sel : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
    SIGNAL ui_sd_page_base : INTEGER RANGE 0 TO SD_BROWSER_LAST_INDEX := 0;
    SIGNAL ui_sd_page_row : INTEGER RANGE 0 TO SD_BROWSER_PAGE_LAST := 0;
    SIGNAL ui_sd_file_read_start : STD_LOGIC := '0';
    SIGNAL ui_browser_action : browser_action_t := BROWSE_NONE;
    SIGNAL ui_save_reset_req : STD_LOGIC := '0';
    SIGNAL ui_save_row_sel : INTEGER RANGE 0 TO 4 := 0;
    SIGNAL ui_save_name : STD_LOGIC_VECTOR(63 DOWNTO 0) := x"2020202020202020";
    SIGNAL ui_save_name_len : INTEGER RANGE 0 TO 8 := 0;
    SIGNAL ui_save_mode_basic : STD_LOGIC := '0';
    SIGNAL ui_save_mode_bls : STD_LOGIC := '0';
    SIGNAL ui_save_start_addr_digit : INTEGER RANGE 0 TO 3 := 0;
    SIGNAL ui_save_end_addr_digit : INTEGER RANGE 0 TO 3 := 0;
    SIGNAL ui_save_start_addr_manual : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0C00";
    SIGNAL ui_save_end_addr_manual : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"1FFF";
    SIGNAL ui_save_basic_available : STD_LOGIC := '0';
    SIGNAL ui_save_basic_ready : STD_LOGIC := '0';
    SIGNAL ui_save_basic_start_addr : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"10FA";
    SIGNAL ui_save_basic_end_addr : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"10FA";
    SIGNAL ui_save_bls_available : STD_LOGIC := '0';
    SIGNAL ui_save_bls_ready : STD_LOGIC := '0';
    SIGNAL ui_save_bls_start_addr : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"1000";
    SIGNAL ui_save_bls_end_addr : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"1000";
    SIGNAL ui_save_effective_start_addr : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0C00";
    SIGNAL ui_save_effective_end_addr : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"1FFF";
    SIGNAL ui_save_effective_len : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"1400";
    SIGNAL ui_save_check_start : STD_LOGIC := '0';
    SIGNAL ui_save_status_clear : STD_LOGIC := '0';
    SIGNAL ui_save_write_start : STD_LOGIC := '0';
    SIGNAL ui_save_checked : STD_LOGIC := '0';
    SIGNAL ui_save_name_exists : STD_LOGIC := '0';
    SIGNAL ui_save_overwrite_confirmed : STD_LOGIC := '0';
    SIGNAL ui_save_ready_to_write : STD_LOGIC := '0';
    SIGNAL ui_save_write_after_check : STD_LOGIC := '0';
    SIGNAL ui_cfg_dirty : STD_LOGIC := '0';
    SIGNAL cfg_cpu_speed_active : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL cfg_cpu_speed_pending : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL cfg_phosphor_amber_active : STD_LOGIC := '0';
    SIGNAL cfg_phosphor_amber_pending : STD_LOGIC := '0';
    SIGNAL cfg_scanlines_active : STD_LOGIC := '0';
    SIGNAL cfg_scanlines_pending : STD_LOGIC := '0';
    SIGNAL cfg_video_zoom_active : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL cfg_video_zoom_pending : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL cfg_rs232_active : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
    SIGNAL cfg_rs232_pending : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
    SIGNAL cfg_rs232_speed_active : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1001";
    SIGNAL cfg_rs232_speed_pending : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1001";
    SIGNAL cfg_rs232_flow_active : STD_LOGIC := '0';
    SIGNAL cfg_rs232_flow_pending : STD_LOGIC := '0';
    SIGNAL cfg_slot_rom_active : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1111";
    SIGNAL cfg_slot_rom_pending : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1111";
    SIGNAL cfg_slot_rom_restore_active : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1111";
    SIGNAL cfg_slot_rom_restore_pending : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1111";
    SIGNAL cfg_slot_rom_persist : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1111";
    SIGNAL cfg_fdd_active : STD_LOGIC := '0';
    SIGNAL cfg_fdd_pending : STD_LOGIC := '0';
    SIGNAL cfg_cpm_active : STD_LOGIC := '0';
    SIGNAL cfg_cpm_pending : STD_LOGIC := '0';
    SIGNAL cfg_avc_active : STD_LOGIC := '0';
    SIGNAL cfg_avc_pending : STD_LOGIC := '0';
    SIGNAL cfg_bls_active : STD_LOGIC := '0';
    SIGNAL cfg_bls_pending : STD_LOGIC := '0';
    SIGNAL cfg_network_active : STD_LOGIC := '0';
    SIGNAL cfg_network_pending : STD_LOGIC := '0';
    SIGNAL cfg_network_dhcp_active : STD_LOGIC := '0';
    SIGNAL cfg_network_dhcp_pending : STD_LOGIC := '0';
    SIGNAL cfg_network_ipv4_active : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"C0A80141";
    SIGNAL cfg_network_ipv4_pending : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"C0A80141";
    SIGNAL cfg_network_netmask_active : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"FFFFFF00";
    SIGNAL cfg_network_netmask_pending : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"FFFFFF00";
    SIGNAL cfg_network_gateway_active : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"C0A80101";
    SIGNAL cfg_network_gateway_pending : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"C0A80101";
    SIGNAL cfg_network_dns_active : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"C0A80101";
    SIGNAL cfg_network_dns_pending : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"C0A80101";
    SIGNAL ui_network_octet_sel : INTEGER RANGE 0 TO 3 := 0;
    SIGNAL ui_sys_reset_req : STD_LOGIC := '0';
    SIGNAL ui_cfg_apply_pending : STD_LOGIC := '0';
    SIGNAL ui_cfg_apply_error : STD_LOGIC := '0';

    --------------------------------------------------------------------
    -- SD-Overlaystatus, Browserfenster und Loader-/Save-Handshake
    --------------------------------------------------------------------
    SIGNAL sd_spi_sclk : STD_LOGIC := '0';
    SIGNAL sd_spi_mosi : STD_LOGIC := '1';
    SIGNAL sd_spi_cs_n : STD_LOGIC := '1';
    SIGNAL sd_cd_raw : STD_LOGIC := '0';
    SIGNAL sd_init_busy : STD_LOGIC := '0';
    SIGNAL sd_init_done : STD_LOGIC := '0';
    SIGNAL sd_init_error : STD_LOGIC := '0';
    SIGNAL sd_read_busy : STD_LOGIC := '0';
    SIGNAL sd_read_done : STD_LOGIC := '0';
    SIGNAL sd_read_error : STD_LOGIC := '0';
    SIGNAL sd_read_stage : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL sd_read_lba : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"00000000";
    SIGNAL sd_read_token : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"FF";
    SIGNAL sd_read_count : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0000";
    SIGNAL sd_card_block_addressing : STD_LOGIC := '0';
    SIGNAL sd_debug_read_cmd17_r1 : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"FF";
    SIGNAL sd_debug_read_error_code : STD_LOGIC_VECTOR(3 DOWNTO 0) := x"0";
    SIGNAL sd_last_r1 : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"FF";
    SIGNAL sd_state_code : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL sd_debug_root_current_cluster : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"00000000";
    SIGNAL sd_debug_root_next_cluster : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"00000000";
    SIGNAL sd_debug_root_sectors_left : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL sd_debug_root_scan_phase : STD_LOGIC := '0';
    SIGNAL sd_debug_root_scan_job : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL sd_browser_dir_found : STD_LOGIC := '0';
    SIGNAL sd_read_first_word : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"00000000";
    SIGNAL sd_part_lba : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"00000000";
    SIGNAL sd_boot_spc : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL sd_boot_reserved : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0000";
    SIGNAL sd_boot_num_fats : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL sd_boot_spf : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"00000000";
    SIGNAL sd_boot_root_cluster : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"00000000";
    SIGNAL sd_root_dir_lba : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"00000000";
    SIGNAL sd_root_file_count : INTEGER RANGE 0 TO SD_BROWSER_MAX_FILES := 0;
    SIGNAL sd_root_total_file_count : INTEGER RANGE 0 TO 255 := 0;
    SIGNAL sd_selected_valid : STD_LOGIC := '0';
    SIGNAL sd_page_valid : sd_page_valid_array_t := (OTHERS => '0');
    SIGNAL sd_page_name : sd_page_name_array_t := (OTHERS => (OTHERS => '0'));
    SIGNAL sd_page_kind : sd_page_kind_array_t := (OTHERS => SD_DSK_KIND_UNKNOWN);
    SIGNAL sd_browser_has_files : STD_LOGIC := '0';
    SIGNAL sd_selected_name : STD_LOGIC_VECTOR(87 DOWNTO 0) := (OTHERS => '0');
    SIGNAL sd_selected_cluster : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"00000000";
    SIGNAL sd_selected_size : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"00000000";
    SIGNAL sd_selected_is_cas : STD_LOGIC := '0';
    SIGNAL sd_selected_is_pas : STD_LOGIC := '0';
    SIGNAL sd_selected_is_dsk : STD_LOGIC := '0';
    SIGNAL ui_browser_manage_mode : browser_manage_mode_t := BROWSER_MANAGE_IDLE;
    SIGNAL ui_browser_manage_name : STD_LOGIC_VECTOR(63 DOWNTO 0) := x"2020202020202020";
    SIGNAL ui_browser_manage_name_len : INTEGER RANGE 0 TO 8 := 0;
    SIGNAL ui_browser_manage_old_name : STD_LOGIC_VECTOR(87 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ui_browser_manage_start : STD_LOGIC := '0';
    SIGNAL ui_browser_manage_delete : STD_LOGIC := '0';
    SIGNAL ui_browser_manage_new_name : STD_LOGIC_VECTOR(87 DOWNTO 0) := (OTHERS => '0');
    SIGNAL sd_manage_busy : STD_LOGIC := '0';
    SIGNAL sd_manage_done : STD_LOGIC := '0';
    SIGNAL sd_manage_error : STD_LOGIC := '0';
    SIGNAL sd_manage_status : STD_LOGIC_VECTOR(3 DOWNTO 0) := x"0";
    SIGNAL ui_browser_manage_mode_code : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
    SIGNAL fdd_mount_a_valid : STD_LOGIC := '0';
    SIGNAL fdd_mount_b_valid : STD_LOGIC := '0';
    SIGNAL fdd_mount_a_name : STD_LOGIC_VECTOR(87 DOWNTO 0) := (OTHERS => '0');
    SIGNAL fdd_mount_b_name : STD_LOGIC_VECTOR(87 DOWNTO 0) := (OTHERS => '0');
    SIGNAL fdd_mount_a_cluster : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL fdd_mount_b_cluster : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL fdd_read_start : STD_LOGIC := '0';
    SIGNAL fdd_read_cluster : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL fdd_read_sd_sector : STD_LOGIC_VECTOR(10 DOWNTO 0) := (OTHERS => '0');
    SIGNAL fdd_read_half : STD_LOGIC := '0';
    SIGNAL fdd_read_busy : STD_LOGIC := '0';
    SIGNAL fdd_read_done : STD_LOGIC := '0';
    SIGNAL fdd_read_error : STD_LOGIC := '0';
    SIGNAL fdd_request_armed : STD_LOGIC := '0';
    SIGNAL fdd_buffer_addr : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL fdd_buffer_data : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"FF";
    SIGNAL fdd_buffer_write_enable : STD_LOGIC := '0';
    SIGNAL fdd_buffer_write_addr : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL fdd_buffer_write_data : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL fdd_write_start : STD_LOGIC := '0';
    SIGNAL fdd_write_cluster : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL fdd_write_sd_sector : STD_LOGIC_VECTOR(10 DOWNTO 0) := (OTHERS => '0');
    SIGNAL fdd_write_half : STD_LOGIC := '0';
    SIGNAL fdd_write_busy : STD_LOGIC := '0';
    SIGNAL fdd_write_done : STD_LOGIC := '0';
    SIGNAL fdd_write_error : STD_LOGIC := '0';
    SIGNAL fdd_write_request_armed : STD_LOGIC := '0';
    SIGNAL fdd_format_start : STD_LOGIC := '0';
    SIGNAL fdd_format_name : STD_LOGIC_VECTOR(87 DOWNTO 0) := (OTHERS => '0');
    SIGNAL fdd_format_cluster : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL fdd_format_busy : STD_LOGIC := '0';
    SIGNAL fdd_format_done : STD_LOGIC := '0';
    SIGNAL fdd_format_error : STD_LOGIC := '0';
    SIGNAL fdd_format_new_cluster : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL fdd_format_request_armed : STD_LOGIC := '0';
    SIGNAL fdd_mount_a_format_cluster : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL fdd_mount_b_format_cluster : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    TYPE fdc_track_buffer_t IS ARRAY (0 TO 4095) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL fdc_track_buffer_reg : fdc_track_buffer_t := (OTHERS => x"E5");
    ATTRIBUTE ram_style : STRING;
    ATTRIBUTE ram_style OF fdc_track_buffer_reg : SIGNAL IS "block";
    SIGNAL fdc_write_track_active : STD_LOGIC := '0';
    SIGNAL fdc_track_parse_state : INTEGER RANGE 0 TO 6 := 0;
    SIGNAL fdc_track_sector_id : INTEGER RANGE 0 TO 16 := 0;
    SIGNAL fdc_track_data_index : INTEGER RANGE 0 TO 255 := 0;
    SIGNAL fdc_track_sector_count : INTEGER RANGE 0 TO 16 := 0;
    SIGNAL fdc_track_tail_active : STD_LOGIC := '0';
    SIGNAL fdc_track_tail_count : INTEGER RANGE 0 TO 218 := 0;
    SIGNAL fdc_track_commit_active : STD_LOGIC := '0';
    SIGNAL fdc_track_commit_sector : INTEGER RANGE 0 TO 15 := 0;
    SIGNAL fdc_track_commit_index : INTEGER RANGE 0 TO 256 := 0;
    SIGNAL fdc_track_commit_wait : STD_LOGIC := '0';
    SIGNAL fdc_track_drive_b : STD_LOGIC := '0';
    SIGNAL fdc_track_side : STD_LOGIC := '0';
    SIGNAL fdc_track_number : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL fdc_format_last_track_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"FF";
    -- After the final WRITE TRACK, the original NAS-DOS formatter writes
    -- sectors 1..16 once more while displaying "Creating Directory".
    -- Track this sequence through the physical SD completions so the
    -- diagnostic result cannot report success before the directory data is
    -- actually persistent.
    SIGNAL fdc_format_directory_writes_left : INTEGER RANGE 0 TO 16 := 0;
    SIGNAL fdc_format_directory_sequence_active : STD_LOGIC := '0';
    SIGNAL fdc_status_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL fdc_track_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL fdc_sector_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"01";
    SIGNAL fdc_data_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"FF";
    SIGNAL fdc_control_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL fdc_intrq_reg : STD_LOGIC := '0';
    SIGNAL fdc_drq_reg : STD_LOGIC := '0';
    SIGNAL fdc_format_debug_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL fdc_data_index : INTEGER RANGE 0 TO 255 := 0;
    SIGNAL fdc_data_last_index : INTEGER RANGE 0 TO 255 := 255;
    SIGNAL fdc_read_address_active : STD_LOGIC := '0';
    SIGNAL fdc_write_sector_active : STD_LOGIC := '0';
    SIGNAL fdc_multi_sector_active : STD_LOGIC := '0';
    SIGNAL fdc_io_wr_last : STD_LOGIC := '0';
    SIGNAL fdc_io_rd_last : STD_LOGIC := '0';
    SIGNAL fdc_data_read_pending : STD_LOGIC := '0';
    SIGNAL fdc_diag_read_active : STD_LOGIC := '0';
    SIGNAL fdc_diag_data_reads : INTEGER RANGE 0 TO 256 := 0;
    -- F7 CP/M/FDD diagnostic page.  Freeze the first backend read error so
    -- later BDOS retries cannot overwrite the evidence.
    SIGNAL fdd_diag_valid : STD_LOGIC := '0';
    SIGNAL fdd_diag_cpm_position : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL fdd_diag_fdd_position : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL fdd_diag_cluster : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL fdd_diag_sd_lba : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL fdd_diag_sd_status : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL fdd_diag_read_count : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL fdd_diag_first_word : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL sd_file_read_is_cas_active : STD_LOGIC := '0';
    SIGNAL sd_file_read_is_pas_active : STD_LOGIC := '0';
    SIGNAL sd_save_check_busy : STD_LOGIC := '0';
    SIGNAL sd_save_check_done : STD_LOGIC := '0';
    SIGNAL sd_save_check_exists : STD_LOGIC := '0';
    SIGNAL sd_save_check_can_create : STD_LOGIC := '0';
    SIGNAL sd_save_check_can_allocate : STD_LOGIC := '0';
    SIGNAL sd_save_check_requires_dir_growth : STD_LOGIC := '0';
    SIGNAL sd_save_check_dir_full : STD_LOGIC := '0';
    SIGNAL sd_save_write_busy : STD_LOGIC := '0';
    SIGNAL sd_save_write_done : STD_LOGIC := '0';
    SIGNAL sd_save_write_error : STD_LOGIC := '0';
    SIGNAL sd_save_write_status : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
    SIGNAL sd_save_mem_addr : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0000";
    SIGNAL sd_save_mem_data_comb : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL sd_save_mem_data : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL sd_cfg_load_start : STD_LOGIC := '0';
    SIGNAL sd_cfg_load_busy : STD_LOGIC := '0';
    SIGNAL sd_cfg_load_done : STD_LOGIC := '0';
    SIGNAL sd_cfg_load_error : STD_LOGIC := '0';
    SIGNAL sd_cfg_loaded_valid : STD_LOGIC := '0';
    SIGNAL sd_cfg_loaded_speed : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL sd_cfg_loaded_phosphor_amber : STD_LOGIC := '0';
    SIGNAL sd_cfg_loaded_scanlines : STD_LOGIC := '0';
    SIGNAL sd_cfg_loaded_video_zoom : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL sd_cfg_loaded_rs232 : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
    SIGNAL sd_cfg_loaded_rs232_speed : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1001";
    SIGNAL sd_cfg_loaded_rs232_flow : STD_LOGIC := '0';
    SIGNAL sd_cfg_loaded_slot_rom : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1111";
    SIGNAL sd_cfg_loaded_fdd : STD_LOGIC := '0';
    SIGNAL sd_cfg_loaded_cpm : STD_LOGIC := '0';
    SIGNAL sd_cfg_loaded_avc : STD_LOGIC := '0';
    SIGNAL sd_cfg_loaded_bls : STD_LOGIC := '0';
    SIGNAL sd_cfg_loaded_network : STD_LOGIC := '0';
    SIGNAL sd_cfg_loaded_network_dhcp : STD_LOGIC := '0';
    SIGNAL sd_cfg_loaded_network_ipv4 : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"C0A80141";
    SIGNAL sd_cfg_loaded_network_netmask : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"FFFFFF00";
    SIGNAL sd_cfg_loaded_network_gateway : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"C0A80101";
    SIGNAL sd_cfg_loaded_network_dns : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"C0A80101";
    SIGNAL sd_cfg_save_start : STD_LOGIC := '0';
    SIGNAL sd_cfg_save_busy : STD_LOGIC := '0';
    SIGNAL sd_cfg_save_done : STD_LOGIC := '0';
    SIGNAL sd_cfg_save_error : STD_LOGIC := '0';
    SIGNAL sd_cfg_load_seen_this_card : STD_LOGIC := '0';
    SIGNAL sd_cfg_load_pending : STD_LOGIC := '1';
    SIGNAL sd_cfg_last_load_ok : STD_LOGIC := '0';
    SIGNAL sd_cfg_last_load_error : STD_LOGIC := '0';
    SIGNAL sd_cfg_save_pending : STD_LOGIC := '0';
    SIGNAL sd_cfg_reset_pending : STD_LOGIC := '0';
    SIGNAL sd_cfg_reset_req : STD_LOGIC := '0';
    SIGNAL sd_cfg_prev_speed : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL sd_cfg_prev_phosphor_amber : STD_LOGIC := '0';
    SIGNAL sd_cfg_prev_scanlines : STD_LOGIC := '0';
    SIGNAL sd_cfg_prev_video_zoom : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL sd_cfg_prev_rs232 : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
    SIGNAL sd_cfg_prev_rs232_speed : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1001";
    SIGNAL sd_cfg_prev_rs232_flow : STD_LOGIC := '0';
    SIGNAL sd_cfg_prev_slot_rom : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1111";
    SIGNAL sd_cfg_prev_fdd : STD_LOGIC := '0';
    SIGNAL sd_cfg_prev_cpm : STD_LOGIC := '0';
    SIGNAL sd_cfg_prev_avc : STD_LOGIC := '0';
    SIGNAL sd_cfg_prev_bls : STD_LOGIC := '0';
    SIGNAL sd_cfg_prev_network : STD_LOGIC := '0';
    SIGNAL sd_cfg_prev_network_dhcp : STD_LOGIC := '0';
    SIGNAL sd_cfg_prev_network_ipv4 : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"C0A80141";
    SIGNAL sd_cfg_prev_network_netmask : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"FFFFFF00";
    SIGNAL sd_cfg_prev_network_gateway : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"C0A80101";
    SIGNAL sd_cfg_prev_network_dns : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"C0A80101";
    SIGNAL sd_file_load_addr_valid : STD_LOGIC := '0';
    SIGNAL sd_file_load_addr : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0000";
    SIGNAL sd_file_mem_wr : STD_LOGIC := '0';
    SIGNAL sd_file_mem_addr : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0000";
    SIGNAL sd_file_mem_data : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL sd_file_mem_wr_q : STD_LOGIC := '0';
    SIGNAL sd_file_mem_addr_q : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0000";
    SIGNAL sd_file_mem_data_q : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL sd_file_read_done_q : STD_LOGIC := '0';
    SIGNAL cpu_mainram_rd_sel : STD_LOGIC := '0';
    SIGNAL cpu_mainram_wr_sel : STD_LOGIC := '0';
    SIGNAL cpu_cpm_monitor_wr_sel : STD_LOGIC := '0';
    SIGNAL sdq_mainram_wr_sel : STD_LOGIC := '0';
    SIGNAL basic_fix_mainram_wr_sel : STD_LOGIC := '0';
    SIGNAL cpu_vram_rd_sel : STD_LOGIC := '0';
    SIGNAL cpu_vram_wr_sel : STD_LOGIC := '0';
    SIGNAL sdq_vram_wr_sel : STD_LOGIC := '0';
    SIGNAL ui_nav_keys_captured : STD_LOGIC := '0';
    SIGNAL overlay_cfg_speed_mux : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL overlay_cfg_phosphor_mux : STD_LOGIC := '0';
    SIGNAL overlay_cfg_scanlines_mux : STD_LOGIC := '0';
    SIGNAL overlay_debug_lba_mux : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL overlay_debug_first_word_mux : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL overlay_debug_root_current_mux : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL overlay_debug_root_next_mux : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL overlay_debug_error_mux : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL overlay_debug_read_token_mux : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL overlay_debug_cmd17_mux : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL overlay_debug_last_r1_mux : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL overlay_debug_sectors_left_mux : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL network_dhcp_bound_display : STD_LOGIC := '0';

    ATTRIBUTE max_fanout : INTEGER;
    ATTRIBUTE max_fanout OF cpu_a : SIGNAL IS 16;
    ATTRIBUTE max_fanout OF cpu_cen : SIGNAL IS 128;
    ATTRIBUTE max_fanout OF cpu_reset_n : SIGNAL IS 16;
    ATTRIBUTE max_fanout OF sd_file_mem_addr_q : SIGNAL IS 8;
    ATTRIBUTE max_fanout OF sd_save_mem_addr : SIGNAL IS 32;
    ATTRIBUTE max_fanout OF cpu_fetch_b_data : SIGNAL IS 1;
    ATTRIBUTE max_fanout OF cpu_fetch_c_data : SIGNAL IS 1;
    ATTRIBUTE max_fanout OF cpu_fetch_d_data : SIGNAL IS 1;
    ATTRIBUTE max_fanout OF cpu_fetch_ef_data : SIGNAL IS 1;
    ATTRIBUTE max_fanout OF cpu_fetch_a_data : SIGNAL IS 1;

BEGIN

    network_enable_o <= cfg_network_active AND network_available_i;
    network_cpu_reset_o <= sys_reset;
    network_dhcp_o <= cfg_network_dhcp_active;
    network_ipv4_o <= cfg_network_ipv4_active;
    network_netmask_o <= cfg_network_netmask_active;
    network_gateway_o <= cfg_network_gateway_active;
    network_dns_o <= cfg_network_dns_active;

    u_network_ports : ENTITY work.nascom2_network_ports
        PORT MAP (
            clk => clk100,
            reset => sys_reset,
            available => network_available_i,
            enabled => cfg_network_active,
            link_up => network_link_i,
            ipv4_address => network_effective_ipv4_i,
            ipv4_netmask => network_effective_netmask_i,
            ipv4_gateway => network_effective_gateway_i,
            dns_server => network_effective_dns_i,
            dns_result => network_debug_i,
            dns_query_toggle => network_dns_query_toggle_o,
            dns_query_length => network_dns_query_length_o,
            dns_query_data => network_dns_query_data_o,
            ping_start_toggle => network_ping_start_toggle_o,
            ping_target_ip => network_ping_target_ip_o,
            ping_result => network_ping_result_i,
            io_addr => cpu_a(7 DOWNTO 0),
            io_iorq_n => iorq_n,
            io_rd_n => rd_n,
            io_wr_n => wr_n,
            io_data_out => cpu_do,
            tcp_status => network_tcp_status_i,
            tcp_status_socket => network_tcp_status_socket_i,
            tcp_connect_toggle => network_tcp_connect_toggle_o,
            tcp_connect_socket => network_tcp_connect_socket_o,
            tcp_connect_ip => network_tcp_connect_ip_o,
            tcp_connect_port => network_tcp_connect_port_o,
            tcp_close_toggle => network_tcp_close_toggle_o,
            tcp_close_socket => network_tcp_close_socket_o,
            tcp_send_toggle => network_tcp_send_toggle_o,
            tcp_send_socket => network_tcp_send_socket_o,
            tcp_send_length => network_tcp_send_length_o,
            tcp_send_data => network_tcp_send_data_o,
            tcp_tx_ready => network_tcp_tx_ready_i,
            tcp_rx_toggle => network_tcp_rx_toggle_i,
            tcp_rx_socket => network_tcp_rx_socket_i,
            tcp_rx_length => network_tcp_rx_length_i,
            tcp_rx_data => network_tcp_rx_data_i,
            tcp_query_socket => network_tcp_query_socket_o,
            tcp_rx_consume_toggle => network_tcp_rx_consume_toggle_o,
            tcp_rx_consume_socket => network_tcp_rx_consume_socket_o,
            status_data => network_status_data,
            response_data => network_response_data
        );
    --------------------------------------------------------------------------
    -- NETWORK OVERLAY TRANSPORT NOTE
    -- Page 3 temporarily carries network display values over existing HDMI
    -- overlay arguments.  This mux affects display transport only; the real
    -- CPU/video configuration and SD debug signals remain unchanged.  See the
    -- matching note in help_overlay_pkg.vhd before the page-3 renderer.
    --------------------------------------------------------------------------
    overlay_cfg_speed_mux <= STD_LOGIC_VECTOR(to_unsigned(ui_network_octet_sel, 2))
        WHEN ui_overlay_page = "1000" ELSE cfg_cpu_speed_pending;
    overlay_cfg_phosphor_mux <= cfg_network_pending
        WHEN ui_overlay_page = "1000" ELSE cfg_phosphor_amber_pending;
    overlay_cfg_scanlines_mux <= network_link_i
        WHEN ui_overlay_page = "1000" ELSE cfg_scanlines_pending;
    overlay_debug_lba_mux <= network_effective_ipv4_i
        WHEN ui_overlay_page = "1000" AND cfg_network_dhcp_pending = '1' AND
            cfg_network_dhcp_active = '1' ELSE cfg_network_ipv4_pending
        WHEN ui_overlay_page = "1000" ELSE sd_read_lba;
    overlay_debug_first_word_mux <= network_effective_netmask_i
        WHEN ui_overlay_page = "1000" AND cfg_network_dhcp_pending = '1' AND
            cfg_network_dhcp_active = '1' ELSE cfg_network_netmask_pending
        WHEN ui_overlay_page = "1000" ELSE sd_read_first_word;
    overlay_debug_root_current_mux <= network_effective_gateway_i
        WHEN ui_overlay_page = "1000" AND cfg_network_dhcp_pending = '1' AND
            cfg_network_dhcp_active = '1' ELSE cfg_network_gateway_pending
        WHEN ui_overlay_page = "1000" ELSE sd_debug_root_current_cluster;
    overlay_debug_root_next_mux <= network_effective_dns_i
        WHEN ui_overlay_page = "1000" AND cfg_network_dhcp_pending = '1' AND
            cfg_network_dhcp_active = '1' ELSE cfg_network_dns_pending
        WHEN ui_overlay_page = "1000" ELSE sd_debug_root_next_cluster;
    network_dhcp_bound_display <= '1' WHEN network_dhcp_status_i = x"03" ELSE '0';
    overlay_debug_error_mux <= network_dhcp_status_i(1) &
        network_dhcp_bound_display &
        cfg_network_dhcp_pending & network_available_i
        WHEN ui_overlay_page = "0010" OR ui_overlay_page = "0011" OR ui_overlay_page = "1000"
        ELSE sd_debug_read_error_code;
    overlay_debug_read_token_mux <= network_debug_i(31 DOWNTO 24)
        WHEN ui_overlay_page = "1000" ELSE sd_read_token;
    overlay_debug_cmd17_mux <= network_debug_i(23 DOWNTO 16)
        WHEN ui_overlay_page = "1000" ELSE sd_debug_read_cmd17_r1;
    overlay_debug_last_r1_mux <= network_debug_i(15 DOWNTO 8)
        WHEN ui_overlay_page = "1000" ELSE sd_last_r1;
    overlay_debug_sectors_left_mux <= network_debug_i(7 DOWNTO 0)
        WHEN ui_overlay_page = "1000" ELSE sd_debug_root_sectors_left;

    -- CP/M forces the live sockets to RAM, but N2CONF.CFG retains the
    -- selection that is to be restored when CP/M mode is disabled again.
    cfg_slot_rom_persist <= cfg_slot_rom_restore_active WHEN cfg_cpm_active = '1' ELSE
                            cfg_slot_rom_active;

    nk_sh <= nk_sh_l OR nk_sh_r;
    -- The original keyboard has no dedicated Escape key.  Present the PC
    -- Escape key as Ctrl+[ so NASSYS returns the standard ASCII ESC (1Bh).
    nk_ct_matrix <= nk_ct OR nk_esc;
    nk_lb_matrix <= nk_lb OR nk_esc;
    m1_b <= NOT m1_n;
    cpu_wait_n <= vram_wait_n_i AND mainram_wait_n_i AND avc_wait_n_i;
    tape_led_active <= port0_reg(4);
    halt_active <= NOT halt_n;
    god_debug_en <= '1' WHEN ui_overlay_enable = '1' AND ui_overlay_page = "0110" AND god_run_active = '0' ELSE '0';
    ui_nav_keys_captured <= '1' WHEN ui_overlay_enable = '1' AND
        (ui_overlay_page = "0010" OR ui_overlay_page = "0011" OR ui_overlay_page = "1000" OR ui_overlay_page = "0100" OR
         ui_overlay_page = "0101" OR ui_overlay_page = "0110" OR ui_overlay_page = "0111")
        ELSE
        '0';
    avc_cpu_mem_sel <= '1' WHEN cfg_avc_active = '1' AND cpu_a(15 DOWNTO 14) = "10" AND
        avc_control_reg(2 DOWNTO 0) /= "000" ELSE '0';
    avc_cpu_rd_sel <= '1' WHEN mreq_n = '0' AND rd_n = '0' AND avc_cpu_mem_sel = '1' ELSE '0';
    avc_cpu_wr_sel <= '1' WHEN mreq_n = '0' AND wr_n = '0' AND avc_cpu_mem_sel = '1' ELSE '0';
    avc_programmed_start_addr <= avc_crtc_regs(12)(5 DOWNTO 0) & avc_crtc_regs(13);
    avc_crtc_start_addr <= STD_LOGIC_VECTOR(avc_terminal_start_addr)
        WHEN avc_terminal_enabled = '1' AND avc_control_reg = x"28"
        ELSE '0' & avc_programmed_start_addr;
    avc_terminal_busy <= '1' WHEN
        avc_terminal_state /= AVC_TERM_IDLE OR
        avc_terminal_req_toggle /= avc_terminal_ack_toggle ELSE '0';
    cpu_mainram_rd_sel <= '1' WHEN mreq_n = '0' AND rd_n = '0' AND avc_cpu_mem_sel = '0' AND
        ((addr_in_main_ram(cpu_a) AND NOT (cfg_bls_active = '1' AND cpu_a(15 DOWNTO 12) = x"A")) OR
         (cfg_bls_active = '1' AND (cpu_a(15 DOWNTO 12) = x"E" OR cpu_a(15 DOWNTO 12) = x"F")) OR
         (cfg_cpm_active = '1' AND
          ((cpu_a(15 DOWNTO 12) = x"0" AND cpm_low_ram_enabled = '1') OR
           (unsigned(cpu_a(15 DOWNTO 12)) >= to_unsigned(11, 4) AND
            unsigned(cpu_a(15 DOWNTO 12)) <= to_unsigned(13, 4)) OR
           cpu_a(15 DOWNTO 12) = x"E" OR
           (cpu_a(15 DOWNTO 12) = x"F" AND
            cpm_boot_overlay_enabled = '0')))) ELSE
        '0';
    cpu_mainram_wr_sel <= '1' WHEN mreq_n = '0' AND wr_n = '0' AND avc_cpu_mem_sel = '0' AND
        ((addr_in_main_ram(cpu_a) AND NOT (cfg_bls_active = '1' AND cpu_a(15 DOWNTO 12) = x"A")) OR
         (cfg_bls_active = '1' AND (cpu_a(15 DOWNTO 12) = x"E" OR cpu_a(15 DOWNTO 12) = x"F")) OR
         (cfg_cpm_active = '1' AND
          ((cpu_a(15 DOWNTO 12) = x"0" AND cpm_low_ram_enabled = '1') OR
           (unsigned(cpu_a(15 DOWNTO 12)) >= to_unsigned(11, 4) AND
            unsigned(cpu_a(15 DOWNTO 12)) <= to_unsigned(13, 4)) OR
           cpu_a(15 DOWNTO 12) = x"E" OR
           (cpu_a(15 DOWNTO 12) = x"F" AND
            (cpm_boot_overlay_enabled = '0' OR cpu_a(11) = '0'))))) ELSE
        '0';
    cpu_cpm_monitor_wr_sel <= '1' WHEN cfg_cpm_active = '1' AND
        cpm_boot_overlay_enabled = '1' AND mreq_n = '0' AND wr_n = '0' AND
        cpu_a(15 DOWNTO 10) = "111111" ELSE '0';
    sdq_mainram_wr_sel <= '1' WHEN sd_file_mem_wr_q = '1' AND
        ((addr_in_main_ram(sd_file_mem_addr_q) AND
          NOT (cfg_bls_active = '1' AND sd_file_mem_addr_q(15 DOWNTO 12) = x"A")) OR
         (cfg_bls_active = '1' AND
          (sd_file_mem_addr_q(15 DOWNTO 12) = x"E" OR sd_file_mem_addr_q(15 DOWNTO 12) = x"F"))) ELSE
        '0';
    basic_fix_mainram_wr_sel <= '1' WHEN basic_load_fix_wr = '1' AND addr_in_main_ram(basic_load_fix_addr) ELSE
        '0';
    cpu_vram_rd_sel <= '1' WHEN mreq_n = '0' AND rd_n = '0' AND
        ((addr_is_vram(cpu_a) AND (cfg_cpm_active = '0' OR cpm_low_ram_enabled = '0')) OR
         (cfg_cpm_active = '1' AND cpm_boot_overlay_enabled = '1' AND
          cpu_a(15 DOWNTO 10) = "111110")) ELSE
        '0';
    cpu_vram_wr_sel <= '1' WHEN mreq_n = '0' AND wr_n = '0' AND
        ((addr_is_vram(cpu_a) AND (cfg_cpm_active = '0' OR cpm_low_ram_enabled = '0')) OR
         (cfg_cpm_active = '1' AND cpm_boot_overlay_enabled = '1' AND
          cpu_a(15 DOWNTO 10) = "111110")) ELSE
        '0';
    sdq_vram_wr_sel <= '1' WHEN (NOT DEBUG_ISOLATE_VRAM_WRITES) AND sd_file_mem_wr_q = '1' AND addr_is_vram(sd_file_mem_addr_q) ELSE
        '0';
    sd_selected_is_cas <= '1' WHEN sd_selected_name(23 DOWNTO 0) = x"434153" ELSE
        '0';
    sd_selected_is_pas <= '1' WHEN sd_selected_name(23 DOWNTO 0) = x"504153" ELSE
        '0';
    sd_selected_is_dsk <= '1' WHEN sd_selected_name(23 DOWNTO 0) = x"44534B" ELSE
        '0';
    mainram_rd_mux_addr <= STD_LOGIC_VECTOR(resize(god_mem_base + to_unsigned(god_mem_scan_index, 16) - RAM_BASE, MAIN_RAM_ADDR_WIDTH))
        WHEN ui_overlay_enable = '1' AND ui_overlay_page = "0110" AND god_run_active = '0' ELSE
        mainram_rd_addr WHEN mainram_read_state /= MAINRAM_READ_IDLE ELSE
        STD_LOGIC_VECTOR(resize(unsigned(sd_save_mem_addr) - RAM_BASE, MAIN_RAM_ADDR_WIDTH))
        WHEN addr_in_main_ram(sd_save_mem_addr) OR
             (cfg_bls_active = '1' AND
              (sd_save_mem_addr(15 DOWNTO 12) = x"E" OR sd_save_mem_addr(15 DOWNTO 12) = x"F")) OR
             (cfg_cpm_active = '1' AND
              (sd_save_mem_addr(15 DOWNTO 12) = x"0" OR
               (unsigned(sd_save_mem_addr(15 DOWNTO 12)) >= to_unsigned(11, 4) AND
                unsigned(sd_save_mem_addr(15 DOWNTO 12)) <= to_unsigned(13, 4)) OR
               sd_save_mem_addr(15 DOWNTO 12) = x"E" OR
               sd_save_mem_addr(15 DOWNTO 12) = x"F"))
        ELSE
        (OTHERS => '0');

    --------------------------------------------------------------------
    -- Nascom single-step / NMI path
    --
    -- Port-0 bit 3 does not directly drive CPU NMI. The original
    -- hardware clocks a small chain of 74LS74 devices that eventually
    -- pulls NMI low after a short M1-qualified sequence.
    --
    -- We model that path here synchronously in the clk100 domain, using:
    --   IC14a : step request latch from P0.3
    --   IC14b : toggles on M1B
    --   IC15a : toggles on IC14b.Q rising edges
    --   IC15b : asserts the single-step NMI request
    --
    -- Manual/external NMI sources from the motherboard are not yet wired
    -- into this FPGA top-level, so they remain logically inactive here.
    --------------------------------------------------------------------
    PROCESS (clk100)
        VARIABLE next_ic14a_q : STD_LOGIC;
        VARIABLE next_ic14b_q : STD_LOGIC;
        VARIABLE next_ic15a_q : STD_LOGIC;
        VARIABLE next_ic15b_q : STD_LOGIC;
        VARIABLE port3_rise_v : BOOLEAN;
        VARIABLE m1b_rise_v : BOOLEAN;
        VARIABLE ic14b_rise_v : BOOLEAN;
        VARIABLE ic15a_rise_v : BOOLEAN;
    BEGIN
        IF rising_edge(clk100) THEN
            port3_rise_v := port0_reg(3) = '1' AND step_port3_last = '0';
            m1b_rise_v := m1_b = '1' AND step_m1b_last = '0';

            next_ic14a_q := step_ic14a_q;
            next_ic14b_q := step_ic14b_q;
            next_ic15a_q := step_ic15a_q;
            next_ic15b_q := step_ic15b_q;

            -- IC14a: P0.3 step request latch, cleared by RESET_n low or
            -- when the IC15b /Q leg has driven the LS08 low.
            IF cpu_reset_n = '0' OR step_ic15b_q = '1' THEN
                next_ic14a_q := '0';
            ELSIF port3_rise_v THEN
                next_ic14a_q := '1';
            END IF;

            -- IC14b/IC15a: asynchronously preset while IC14a.Q is low.
            IF next_ic14a_q = '0' THEN
                next_ic14b_q := '1';
                next_ic15a_q := '1';
            ELSE
                IF m1b_rise_v THEN
                    next_ic14b_q := NOT step_ic14b_q;
                END IF;

                ic14b_rise_v := step_ic14b_q = '0' AND next_ic14b_q = '1';
                IF ic14b_rise_v THEN
                    next_ic15a_q := NOT step_ic15a_q;
                END IF;
            END IF;

            -- IC15b: set by an IC15a.Q rising edge, cleared only when the
            -- IC10a OR output would pull /CLR low (IC14a.Q = 0 and M1B = 0).
            IF next_ic14a_q = '0' AND m1_b = '0' THEN
                next_ic15b_q := '0';
            ELSE
                ic15a_rise_v := step_ic15a_q = '0' AND next_ic15a_q = '1';
                IF ic15a_rise_v THEN
                    next_ic15b_q := '1';
                END IF;
            END IF;

            IF raw_reset_req = '1' THEN
                step_ic14a_q <= '0';
                step_ic14b_q <= '1';
                step_ic15a_q <= '1';
                step_ic15b_q <= '0';
                step_port3_last <= '0';
                step_m1b_last <= '0';
            ELSE
                step_ic14a_q <= next_ic14a_q;
                step_ic14b_q <= next_ic14b_q;
                step_ic15a_q <= next_ic15a_q;
                step_ic15b_q <= next_ic15b_q;
                step_port3_last <= port0_reg(3);
                step_m1b_last <= m1_b;
            END IF;
        END IF;
    END PROCESS;

    --------------------------------------------------------------------
    -- Manual NMI pulse from Ctrl/Shift+PC Pos1/Home
    --
    -- The original motherboard button is cleaned up by LS14 + LS221 and
    -- then enters the final NMI AND stage as an active-low pulse.
    -- We model only that short low-active pulse here and combine it with
    -- the single-step NMI source below.  Requiring a modifier prevents an
    -- accidental CLR/Home press from destroying a running BASIC program.
    -- CP/M installs its own warm-boot vector at 0066h, so the deliberate
    -- chord remains useful there as well.
    --------------------------------------------------------------------
    PROCESS (clk100)
    BEGIN
        IF rising_edge(clk100) THEN
            IF raw_reset_req = '1' THEN
                manual_nmi_pulse_cnt <= 0;
                manual_nmi_n_i <= '1';
                manual_nmi_key_last <= manual_nmi_key_i;
                kbd_diag_make_code <= x"00";
                kbd_diag_make_extended <= '0';
                kbd_diag_make_ctrl <= '0';
                kbd_diag_make_shift_l <= '0';
                kbd_diag_make_shift_r <= '0';
                kbd_diag_make_nmi_match <= '0';
                kbd_diag_make_count <= x"00";
            ELSE
                IF ps2_valid = '1' AND ps2_released = '0' THEN
                    -- Retain the last make event so releasing the chord does
                    -- not erase the evidence before F7 is observed.
                    kbd_diag_make_code <= ps2_code;
                    kbd_diag_make_extended <= ps2_extended;
                    kbd_diag_make_ctrl <= nk_ct;
                    kbd_diag_make_shift_l <= nk_sh_l;
                    kbd_diag_make_shift_r <= nk_sh_r;
                    kbd_diag_make_count <= STD_LOGIC_VECTOR(UNSIGNED(kbd_diag_make_count) + 1);
                    IF (ps2_extended = '1' AND ps2_code = x"6C" AND nk_ct = '1') OR
                        (ps2_extended = '0' AND ps2_code = x"84") THEN
                        kbd_diag_make_nmi_match <= '1';
                    ELSE
                        kbd_diag_make_nmi_match <= '0';
                    END IF;
                END IF;

                IF manual_nmi_key_i = '1' AND manual_nmi_key_last = '0' THEN
                    manual_nmi_pulse_cnt <= 2047;
                ELSIF manual_nmi_key_i = '0' AND
                    ps2_valid = '1' AND ps2_released = '0' AND (
                    (ps2_extended = '1' AND ps2_code = x"6C" AND nk_ct = '1') OR
                    (ps2_extended = '0' AND ps2_code = x"84")) THEN
                    manual_nmi_pulse_cnt <= 2047;
                ELSIF manual_nmi_pulse_cnt > 0 THEN
                    manual_nmi_pulse_cnt <= manual_nmi_pulse_cnt - 1;
                END IF;

                IF manual_nmi_pulse_cnt > 0 THEN
                    manual_nmi_n_i <= '0';
                ELSE
                    manual_nmi_n_i <= '1';
                END IF;
                manual_nmi_key_last <= manual_nmi_key_i;
            END IF;
        END IF;
    END PROCESS;

    -- Preserve the first unexpected BLS ROM-to-low-RAM execution transfer.
    -- A normal compiler run executes in A000-CFFFh; generated code in
    -- 1000-9FFFh is entered only by RUN. If compilation corrupts its return
    -- stack, this latch survives the ensuing software jump through 0000h and
    -- exposes the source PC and post-transfer SP in the F5 monitor.
    PROCESS (clk100)
    BEGIN
        IF rising_edge(clk100) THEN
            IF sys_reset = '1' OR cfg_bls_active = '0' THEN
                bls_low_exec_fault <= '0';
                bls_low_exec_from_pc <= x"0000";
                bls_low_exec_to_pc <= x"0000";
                bls_low_exec_sp <= x"0000";
                bls_last_m1_pc <= x"0000";
                bls_m1_n_last <= '1';
            ELSE
                IF bls_m1_n_last = '1' AND m1_n = '0' THEN
                    IF bls_low_exec_fault = '0' AND
                        unsigned(bls_last_m1_pc) >= to_unsigned(16#A000#, 16) AND
                        unsigned(bls_last_m1_pc) <= to_unsigned(16#CFFF#, 16) AND
                        unsigned(cpu_a) >= to_unsigned(16#1000#, 16) AND
                        unsigned(cpu_a) <= to_unsigned(16#9FFF#, 16) THEN
                        bls_low_exec_fault <= '1';
                        bls_low_exec_from_pc <= bls_last_m1_pc;
                        bls_low_exec_to_pc <= cpu_a;
                        bls_low_exec_sp <= god_sp;
                    END IF;
                    bls_last_m1_pc <= cpu_a;
                END IF;
                bls_m1_n_last <= m1_n;
            END IF;
        END IF;
    END PROCESS;

    cpu_nmi_n <= (NOT step_ic15b_q) AND manual_nmi_n_i;

    --------------------------------------------------------------------
    -- Synchronize slow/asynchronous control inputs before they reach
    -- timing-sensitive HDMI and SD state paths.
    --------------------------------------------------------------------
    PROCESS (clk100)
    BEGIN
        IF rising_edge(clk100) THEN
            reset_btn_pulse <= '0';
            reset_btn_meta <= reset_btn;
            reset_btn_sync <= reset_btn_meta;
            IF reset_btn_sync = reset_btn_debounced THEN
                reset_btn_debounce_count <= 0;
            ELSIF reset_btn_debounce_count = 99999 THEN
                reset_btn_debounce_count <= 0;
                reset_btn_debounced <= reset_btn_sync;
                IF reset_btn_sync = '0' THEN
                    reset_btn_pulse <= '1';
                END IF;
            ELSE
                reset_btn_debounce_count <= reset_btn_debounce_count + 1;
            END IF;

            IF startup_reset_cnt /= x"FF" THEN
                startup_reset_cnt <= startup_reset_cnt + 1;
            END IF;
            sd_cd_meta <= sd_cd;
            sd_cd_sync <= sd_cd_meta;

            IF ui_sys_reset_req = '1' OR sd_cfg_reset_req = '1' OR reset_btn_pulse = '1' THEN
                sys_reset_hold_cnt <= to_unsigned(500000, sys_reset_hold_cnt'LENGTH);
            ELSIF sys_reset_hold_cnt /= 0 THEN
                sys_reset_hold_cnt <= sys_reset_hold_cnt - 1;
            END IF;

            hdmi_reset_meta <= sys_reset;
            hdmi_reset_sync <= hdmi_reset_meta;

            IF reset_req_last = '0' AND raw_reset_req = '1' THEN
                reset_event_count <= reset_event_count + 1;
            END IF;
            reset_req_last <= raw_reset_req;
            IF ui_sys_reset_req = '1' THEN
                ui_reset_event_count <= ui_reset_event_count + 1;
            END IF;
            IF sd_cfg_reset_req = '1' THEN
                cfg_reset_event_count <= cfg_reset_event_count + 1;
            END IF;
        END IF;
    END PROCESS;

    -- All runtime reset sources now produce the same defined 5 ms system
    -- reset.  The asynchronous mechanical button is synchronized and must
    -- remain stable for 1 ms before its single press pulse is accepted.
    raw_reset_req <= '1' WHEN startup_reset_cnt /= x"FF" OR sys_reset_hold_cnt /= 0 ELSE
        '0';

    --------------------------------------------------------------------
    -- Reset-Prozess
    --------------------------------------------------------------------
    PROCESS (clk100)
    BEGIN
        IF rising_edge(clk100) THEN
            IF raw_reset_req = '1' OR vram_clear_active = '1' THEN
                reset_cnt <= (OTHERS => '0');
                cpu_reset_n <= '0';
            ELSIF cfg_cpm_active = '1' AND sd_init_done = '0' THEN
                -- sys_reset also restarts the SD backend.  Do not let the
                -- boot ROM issue its first FDC request while that backend is
                -- still scanning the card; the one-cycle request would be
                -- lost and boot success would then depend on reset timing.
                -- Only the CPU remains held here, so SD initialization can
                -- run to completion without creating a reset deadlock.
                reset_cnt <= (OTHERS => '0');
                cpu_reset_n <= '0';
            ELSE
                IF reset_cnt /= x"FF" THEN
                    reset_cnt <= reset_cnt + 1;
                    cpu_reset_n <= '0';
                ELSE
                    cpu_reset_n <= '1';
                END IF;
            END IF;
        END IF;
    END PROCESS;

    --------------------------------------------------------------------
    -- CP/M memory view (historical N2MD-style banking)
    --
    -- On reset, the 2 KiB CP/M EPROM is visible both at 0000h (reset
    -- trampoline) and at its assembled address F000h.  The original EPROM
    -- used B2h, but that is the AVC control port.  The generated EPROM and
    -- our loader/BIOS use the private core port BFh instead, exposing RAM
    -- at 0000h..0BFFh while retaining
    -- the high boot/video overlay.  Our second-stage loader can use C0h to
    -- expose the RAM shadow at F000h..FFFFh as well.
    --------------------------------------------------------------------
    PROCESS (clk100)
    BEGIN
        IF rising_edge(clk100) THEN
            IF raw_reset_req = '1' THEN
                cpm_low_ram_enabled <= '0';
                cpm_boot_overlay_enabled <= cfg_cpm_active;
            ELSIF cfg_cpm_active = '0' THEN
                cpm_low_ram_enabled <= '0';
                cpm_boot_overlay_enabled <= '0';
            ELSIF iorq_n = '0' AND wr_n = '0' AND cpu_a(7 DOWNTO 0) = x"BF" THEN
                cpm_low_ram_enabled <= cpu_do(7);
                cpm_boot_overlay_enabled <= NOT cpu_do(6);
            END IF;
        END IF;
    END PROCESS;

    --------------------------------------------------------------------
    -- Lucas Logic AVC Model B registers
    --
    -- B0h selects one of the MC6845 registers, B1h accesses its data and
    -- B2h controls plane paging, density, visible colour planes and the
    -- external (normal NASCOM) video input.  The CRTC timing is rendered
    -- inside the fixed HDMI timing domain; its start address still drives
    -- hardware scrolling exactly as software expects.
    --------------------------------------------------------------------
    PROCESS (clk100)
        VARIABLE crtc_index_v : INTEGER;
    BEGIN
        IF rising_edge(clk100) THEN
            IF raw_reset_req = '1' OR cfg_avc_active = '0' THEN
                avc_crtc_index <= (OTHERS => '0');
                avc_crtc_regs <= (OTHERS => (OTHERS => '0'));
                avc_control_reg <= x"80";
                avc_terminal_enabled <= '0';
                avc_terminal_char <= x"20";
                avc_terminal_req_toggle <= '0';
                avc_terminal_io_write_last <= '0';
            ELSIF iorq_n = '0' AND wr_n = '0' THEN
                CASE cpu_a(7 DOWNTO 0) IS
                    WHEN x"B0" =>
                        avc_crtc_index <= unsigned(cpu_do(4 DOWNTO 0));
                    WHEN x"B1" =>
                        crtc_index_v := to_integer(avc_crtc_index);
                        IF crtc_index_v <= 17 THEN
                            avc_crtc_regs(crtc_index_v) <= cpu_do;
                        END IF;
                    WHEN x"B2" =>
                        avc_control_reg <= cpu_do;
                    WHEN x"B3" =>
                        avc_terminal_io_write_last <= '1';
                        IF avc_terminal_io_write_last = '0' AND
                            avc_terminal_enabled = '1' AND avc_terminal_busy = '0' THEN
                            avc_terminal_char <= cpu_do;
                            avc_terminal_req_toggle <= NOT avc_terminal_req_toggle;
                            avc_control_reg <= x"28";
                        END IF;
                    WHEN x"B4" =>
                        avc_terminal_io_write_last <= '1';
                        IF avc_terminal_io_write_last = '0' THEN
                            IF cpu_do(0) = '1' THEN
                                avc_terminal_enabled <= '1';
                                avc_terminal_char <= x"0C";
                                avc_terminal_req_toggle <= NOT avc_terminal_req_toggle;
                                avc_control_reg <= x"28";
                            ELSE
                                avc_terminal_enabled <= '0';
                                avc_control_reg <= x"80";
                            END IF;
                        END IF;
                    WHEN OTHERS =>
                        NULL;
                END CASE;
            ELSE
                avc_terminal_io_write_last <= '0';
            END IF;
        END IF;
    END PROCESS;

    --------------------------------------------------------------------
    -- Private monitor workspace visible at FC00h..FFFFh while the CP/M
    -- boot/video overlay is enabled.  The CP/M RAM at the same CPU
    -- addresses remains untouched underneath and reappears with OUT BF,C0.
    --------------------------------------------------------------------
    PROCESS (clk100)
    BEGIN
        IF rising_edge(clk100) THEN
            IF cpu_cpm_monitor_wr_sel = '1' THEN
                CPM_MONITOR_RAM(to_integer(unsigned(cpu_a(9 DOWNTO 0)))) <= cpu_do;
            END IF;
        END IF;
    END PROCESS;

    --------------------------------------------------------------------
    -- Frequenzwahl
    --------------------------------------------------------------------
    PROCESS (cfg_cpu_speed_active)
    BEGIN
        CASE cfg_cpu_speed_active IS
            WHEN "00" =>
                div_value <= to_unsigned(50, 32); -- 1 MHz
            WHEN "01" =>
                div_value <= to_unsigned(25, 32); -- 2 MHz
            WHEN "10" =>
                div_value <= to_unsigned(12, 32); -- ~4.166 MHz
            WHEN OTHERS =>
                div_value <= to_unsigned(12, 32); -- ~4.166 MHz
        END CASE;
    END PROCESS;

    --------------------------------------------------------------------
    -- CPU enable generator
    --
    -- The T80 core now stays in the clk100 domain and only advances when
    -- cpu_cen pulses high. This keeps the previous effective CPU speed
    -- selection while removing the separate fabric-generated CPU clock
    -- domain from the design.
    --
    -- While any overlay page is visible, the divider state is held and
    -- cpu_cen stays low so the emulated machine pauses underneath the UI.
    --------------------------------------------------------------------
    PROCESS (clk100)
    BEGIN
        IF rising_edge(clk100) THEN
            cpu_cen <= '0';
            IF sys_reset = '1' THEN
                clk_div <= (OTHERS => '0');
                cpu_phase <= '0';
            ELSIF ui_overlay_enable = '1' AND god_run_active = '0' THEN
                NULL;
            ELSE
                IF clk_div = div_value THEN
                    clk_div <= (OTHERS => '0');
                    IF cpu_phase = '0' THEN
                        cpu_cen <= '1';
                    END IF;
                    cpu_phase <= NOT cpu_phase;
                ELSE
                    clk_div <= clk_div + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    --------------------------------------------------------------------
    -- PS/2 -> Nascom key state for letters, digits, and selected special keys
    --------------------------------------------------------------------
    PROCESS (clk100)
    BEGIN
        IF rising_edge(clk100) THEN
            IF sys_reset = '1' THEN
                nk_0 <= '0';
                nk_1 <= '0';
                nk_2 <= '0';
                nk_3 <= '0';
                nk_4 <= '0';
                nk_5 <= '0';
                nk_6 <= '0';
                nk_7 <= '0';
                nk_8 <= '0';
                nk_9 <= '0';
                nk_a <= '0';
                nk_b <= '0';
                nk_c <= '0';
                nk_d <= '0';
                nk_e <= '0';
                nk_f <= '0';
                nk_g <= '0';
                nk_h <= '0';
                nk_i <= '0';
                nk_j <= '0';
                nk_k <= '0';
                nk_l <= '0';
                nk_m <= '0';
                nk_n <= '0';
                nk_o <= '0';
                nk_p <= '0';
                nk_q <= '0';
                nk_r <= '0';
                nk_s <= '0';
                nk_t <= '0';
                nk_u <= '0';
                nk_v <= '0';
                nk_w <= '0';
                nk_x <= '0';
                nk_y <= '0';
                nk_z <= '0';
                nk_sp <= '0';
                nk_sh_l <= '0';
                nk_sh_r <= '0';
                nk_ct <= '0';
                nk_esc <= '0';
                nk_nl <= '0';
                nk_bs <= '0';
                nk_pu <= '0';
                nk_pd <= '0';
                nk_pl <= '0';
                nk_pr <= '0';
                nk_gr <= '0';
                nk_tb <= '0';
                nk_at <= '0';
                nk_plus <= '0';
                nk_star <= '0';
                nk_comma <= '0';
                nk_dot <= '0';
                nk_minus <= '0';
                nk_slash <= '0';
                nk_lb <= '0';
                nk_rb <= '0';
            ELSE
                IF ps2_valid = '1' THEN
                    IF ps2_extended = '0' THEN
                        CASE ps2_code IS
                            WHEN x"45" => nk_0 <= NOT ps2_released;
                            WHEN x"16" => nk_1 <= NOT ps2_released;
                            WHEN x"1E" => nk_2 <= NOT ps2_released;
                            WHEN x"26" => nk_3 <= NOT ps2_released;
                            WHEN x"25" => nk_4 <= NOT ps2_released;
                            WHEN x"2E" => nk_5 <= NOT ps2_released;
                            WHEN x"36" => nk_6 <= NOT ps2_released;
                            WHEN x"3D" => nk_7 <= NOT ps2_released;
                            WHEN x"3E" => nk_8 <= NOT ps2_released;
                            WHEN x"46" => nk_9 <= NOT ps2_released;
                            WHEN x"1C" => nk_a <= NOT ps2_released;
                            WHEN x"32" => nk_b <= NOT ps2_released;
                            WHEN x"21" => nk_c <= NOT ps2_released;
                            WHEN x"23" => nk_d <= NOT ps2_released;
                            WHEN x"24" => nk_e <= NOT ps2_released;
                            WHEN x"2B" => nk_f <= NOT ps2_released;
                            WHEN x"34" => nk_g <= NOT ps2_released;
                            WHEN x"33" => nk_h <= NOT ps2_released;
                            WHEN x"43" => nk_i <= NOT ps2_released;
                            WHEN x"3B" => nk_j <= NOT ps2_released;
                            WHEN x"42" => nk_k <= NOT ps2_released;
                            WHEN x"4B" => nk_l <= NOT ps2_released;
                            WHEN x"3A" => nk_m <= NOT ps2_released;
                            WHEN x"31" => nk_n <= NOT ps2_released;
                            WHEN x"44" => nk_o <= NOT ps2_released;
                            WHEN x"4D" => nk_p <= NOT ps2_released;
                            WHEN x"15" => nk_q <= NOT ps2_released;
                            WHEN x"2D" => nk_r <= NOT ps2_released;
                            WHEN x"1B" => nk_s <= NOT ps2_released;
                            WHEN x"2C" => nk_t <= NOT ps2_released;
                            WHEN x"3C" => nk_u <= NOT ps2_released;
                            WHEN x"2A" => nk_v <= NOT ps2_released;
                            WHEN x"1D" => nk_w <= NOT ps2_released;
                            WHEN x"22" => nk_x <= NOT ps2_released;
                            WHEN x"35" => nk_y <= NOT ps2_released;
                            WHEN x"1A" => nk_z <= NOT ps2_released;
                            WHEN x"29" => nk_sp <= NOT ps2_released;
                            WHEN x"12" => nk_sh_l <= NOT ps2_released;
                            WHEN x"59" => nk_sh_r <= NOT ps2_released;
                            WHEN x"14" => nk_ct <= NOT ps2_released;
                            WHEN x"76" =>
                                IF ui_overlay_enable = '0' THEN
                                    nk_esc <= NOT ps2_released;
                                ELSE
                                    nk_esc <= '0';
                                END IF;
                            WHEN x"5A" =>
                                IF ui_nav_keys_captured = '0' THEN
                                    nk_nl <= NOT ps2_released;
                                END IF;
                            WHEN x"66" => nk_bs <= NOT ps2_released;
                                -- Accept cursor keys both with and without E0 so
                                -- the PC cursor cluster and any keypad-style variant
                                -- can reach the same Nascom cursor state.
                            WHEN x"75" =>
                                IF ui_nav_keys_captured = '0' THEN
                                    nk_pu <= NOT ps2_released;
                                END IF;
                            WHEN x"72" =>
                                IF ui_nav_keys_captured = '0' THEN
                                    nk_pd <= NOT ps2_released;
                                END IF;
                            WHEN x"6B" =>
                                IF ui_nav_keys_captured = '0' THEN
                                    nk_pl <= NOT ps2_released;
                                END IF;
                            WHEN x"74" =>
                                IF ui_nav_keys_captured = '0' THEN
                                    nk_pr <= NOT ps2_released;
                                END IF;
                            WHEN x"0D" => nk_gr <= NOT ps2_released;
                            WHEN x"61" => nk_tb <= NOT ps2_released;
                            WHEN x"54" => nk_at <= NOT ps2_released;
                            WHEN x"4C" => nk_plus <= NOT ps2_released;
                            WHEN x"52" => nk_star <= NOT ps2_released;
                            WHEN x"41" => nk_comma <= NOT ps2_released;
                            WHEN x"49" => nk_dot <= NOT ps2_released;
                            WHEN x"4A" => nk_minus <= NOT ps2_released;
                            WHEN x"5D" => nk_slash <= NOT ps2_released;
                            WHEN x"4E" => nk_lb <= NOT ps2_released;
                            WHEN x"55" => nk_rb <= NOT ps2_released;
                            WHEN OTHERS =>
                                NULL;
                        END CASE;
                    ELSE
                        CASE ps2_code IS
                            WHEN x"14" => nk_ct <= NOT ps2_released;
                            WHEN x"75" =>
                                IF ui_nav_keys_captured = '0' THEN
                                    nk_pu <= NOT ps2_released;
                                END IF;
                            WHEN x"72" =>
                                IF ui_nav_keys_captured = '0' THEN
                                    nk_pd <= NOT ps2_released;
                                END IF;
                            WHEN x"6B" =>
                                IF ui_nav_keys_captured = '0' THEN
                                    nk_pl <= NOT ps2_released;
                                END IF;
                            WHEN x"74" =>
                                IF ui_nav_keys_captured = '0' THEN
                                    nk_pr <= NOT ps2_released;
                                END IF;
                            WHEN x"5A" =>
                                IF ui_nav_keys_captured = '0' THEN
                                    nk_nl <= NOT ps2_released;
                                END IF;
                            WHEN OTHERS =>
                                NULL;
                        END CASE;
                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    --------------------------------------------------------------------
    -- UI overlay control and runtime configuration.
    --
    -- F1 toggles keyboard help.
    -- F3 toggles the NASSYS command help.
    -- F13 cycles through the runtime configuration pages.
    --------------------------------------------------------------------
    PROCESS (clk100)
        VARIABLE next_overlay_enable : STD_LOGIC;
        VARIABLE next_overlay_page : STD_LOGIC_VECTOR(3 DOWNTO 0);
        VARIABLE next_cfg_row_sel : STD_LOGIC_VECTOR(2 DOWNTO 0);
        VARIABLE next_browser_action : browser_action_t;
        VARIABLE next_cfg_speed_active : STD_LOGIC_VECTOR(1 DOWNTO 0);
        VARIABLE next_cfg_speed_pending : STD_LOGIC_VECTOR(1 DOWNTO 0);
        VARIABLE next_cfg_phosphor_active : STD_LOGIC;
        VARIABLE next_cfg_phosphor_pending : STD_LOGIC;
        VARIABLE next_cfg_scanlines_active : STD_LOGIC;
        VARIABLE next_cfg_scanlines_pending : STD_LOGIC;
        VARIABLE next_cfg_video_zoom_active : STD_LOGIC_VECTOR(1 DOWNTO 0);
        VARIABLE next_cfg_video_zoom_pending : STD_LOGIC_VECTOR(1 DOWNTO 0);
        VARIABLE next_cfg_rs232_active : STD_LOGIC_VECTOR(2 DOWNTO 0);
        VARIABLE next_cfg_rs232_pending : STD_LOGIC_VECTOR(2 DOWNTO 0);
        VARIABLE next_cfg_rs232_speed_active : STD_LOGIC_VECTOR(3 DOWNTO 0);
        VARIABLE next_cfg_rs232_speed_pending : STD_LOGIC_VECTOR(3 DOWNTO 0);
        VARIABLE next_cfg_rs232_flow_active : STD_LOGIC;
        VARIABLE next_cfg_rs232_flow_pending : STD_LOGIC;
        VARIABLE next_cfg_slot_active : STD_LOGIC_VECTOR(3 DOWNTO 0);
        VARIABLE next_cfg_slot_pending : STD_LOGIC_VECTOR(3 DOWNTO 0);
        VARIABLE next_cfg_slot_restore_active : STD_LOGIC_VECTOR(3 DOWNTO 0);
        VARIABLE next_cfg_slot_restore_pending : STD_LOGIC_VECTOR(3 DOWNTO 0);
        VARIABLE next_cfg_fdd_active : STD_LOGIC;
        VARIABLE next_cfg_fdd_pending : STD_LOGIC;
        VARIABLE next_cfg_cpm_active : STD_LOGIC;
        VARIABLE next_cfg_cpm_pending : STD_LOGIC;
        VARIABLE next_cfg_avc_active : STD_LOGIC;
        VARIABLE next_cfg_avc_pending : STD_LOGIC;
        VARIABLE next_cfg_bls_active : STD_LOGIC;
        VARIABLE next_cfg_bls_pending : STD_LOGIC;
        VARIABLE next_cfg_network_active : STD_LOGIC;
        VARIABLE next_cfg_network_pending : STD_LOGIC;
        VARIABLE next_cfg_network_dhcp_active : STD_LOGIC;
        VARIABLE next_cfg_network_dhcp_pending : STD_LOGIC;
        VARIABLE next_cfg_network_ipv4_active : STD_LOGIC_VECTOR(31 DOWNTO 0);
        VARIABLE next_cfg_network_ipv4_pending : STD_LOGIC_VECTOR(31 DOWNTO 0);
        VARIABLE next_cfg_network_netmask_active : STD_LOGIC_VECTOR(31 DOWNTO 0);
        VARIABLE next_cfg_network_netmask_pending : STD_LOGIC_VECTOR(31 DOWNTO 0);
        VARIABLE next_cfg_network_gateway_active : STD_LOGIC_VECTOR(31 DOWNTO 0);
        VARIABLE next_cfg_network_gateway_pending : STD_LOGIC_VECTOR(31 DOWNTO 0);
        VARIABLE next_cfg_network_dns_active : STD_LOGIC_VECTOR(31 DOWNTO 0);
        VARIABLE next_cfg_network_dns_pending : STD_LOGIC_VECTOR(31 DOWNTO 0);
        VARIABLE next_sys_reset_req : STD_LOGIC;
        VARIABLE next_save_reset_req : STD_LOGIC;
        VARIABLE next_cfg_apply_pending : STD_LOGIC;
        VARIABLE next_cfg_apply_error : STD_LOGIC;
        VARIABLE apply_cfg_change_v : BOOLEAN;
    BEGIN
        IF rising_edge(clk100) THEN
            IF sys_reset = '1' THEN
                ui_overlay_enable <= '0';
                ui_overlay_page <= "0000";
                ui_cfg_row_sel <= "000";
                ui_network_octet_sel <= 0;
                ui_browser_action <= BROWSE_NONE;
                ui_cfg_dirty <= '0';
                cfg_cpu_speed_active <= cfg_cpu_speed_active;
                cfg_cpu_speed_pending <= cfg_cpu_speed_active;
                cfg_phosphor_amber_active <= cfg_phosphor_amber_active;
                cfg_phosphor_amber_pending <= cfg_phosphor_amber_active;
                cfg_scanlines_active <= cfg_scanlines_active;
                cfg_scanlines_pending <= cfg_scanlines_active;
                cfg_video_zoom_active <= cfg_video_zoom_active;
                cfg_video_zoom_pending <= cfg_video_zoom_active;
                cfg_rs232_active <= cfg_rs232_active;
                cfg_rs232_pending <= cfg_rs232_active;
                cfg_rs232_speed_active <= cfg_rs232_speed_active;
                cfg_rs232_speed_pending <= cfg_rs232_speed_active;
                cfg_slot_rom_active <= cfg_slot_rom_active;
                cfg_slot_rom_pending <= cfg_slot_rom_active;
                cfg_slot_rom_restore_active <= cfg_slot_rom_restore_active;
                cfg_slot_rom_restore_pending <= cfg_slot_rom_restore_active;
                cfg_fdd_active <= cfg_fdd_active;
                cfg_fdd_pending <= cfg_fdd_active;
                cfg_cpm_active <= cfg_cpm_active;
                cfg_cpm_pending <= cfg_cpm_active;
                cfg_avc_active <= cfg_avc_active;
                cfg_avc_pending <= cfg_avc_active;
                cfg_bls_active <= cfg_bls_active;
                cfg_bls_pending <= cfg_bls_active;
                cfg_network_active <= cfg_network_active;
                cfg_network_pending <= cfg_network_active;
                cfg_network_dhcp_active <= cfg_network_dhcp_active;
                cfg_network_dhcp_pending <= cfg_network_dhcp_active;
                cfg_network_ipv4_active <= cfg_network_ipv4_active;
                cfg_network_ipv4_pending <= cfg_network_ipv4_active;
                cfg_network_netmask_active <= cfg_network_netmask_active;
                cfg_network_netmask_pending <= cfg_network_netmask_active;
                cfg_network_gateway_active <= cfg_network_gateway_active;
                cfg_network_gateway_pending <= cfg_network_gateway_active;
                cfg_network_dns_active <= cfg_network_dns_active;
                cfg_network_dns_pending <= cfg_network_dns_active;
                ui_sys_reset_req <= '0';
                ui_save_reset_req <= '0';
                ui_cfg_apply_pending <= '0';
                ui_cfg_apply_error <= '0';
                basic_autostart_ui_seen <= '0';
            ELSE
                next_overlay_enable := ui_overlay_enable;
                next_overlay_page := ui_overlay_page;
                next_cfg_row_sel := ui_cfg_row_sel;
                next_browser_action := BROWSE_NONE;
                next_cfg_speed_active := cfg_cpu_speed_active;
                next_cfg_speed_pending := cfg_cpu_speed_pending;
                next_cfg_phosphor_active := cfg_phosphor_amber_active;
                next_cfg_phosphor_pending := cfg_phosphor_amber_pending;
                next_cfg_scanlines_active := cfg_scanlines_active;
                next_cfg_scanlines_pending := cfg_scanlines_pending;
                next_cfg_video_zoom_active := cfg_video_zoom_active;
                next_cfg_video_zoom_pending := cfg_video_zoom_pending;
                next_cfg_rs232_active := cfg_rs232_active;
                next_cfg_rs232_pending := cfg_rs232_pending;
                next_cfg_rs232_speed_active := cfg_rs232_speed_active;
                next_cfg_rs232_speed_pending := cfg_rs232_speed_pending;
                next_cfg_slot_active := cfg_slot_rom_active;
                next_cfg_slot_pending := cfg_slot_rom_pending;
                next_cfg_slot_restore_active := cfg_slot_rom_restore_active;
                next_cfg_slot_restore_pending := cfg_slot_rom_restore_pending;
                next_cfg_fdd_active := cfg_fdd_active;
                next_cfg_fdd_pending := cfg_fdd_pending;
                next_cfg_cpm_active := cfg_cpm_active;
                next_cfg_cpm_pending := cfg_cpm_pending;
                next_cfg_avc_active := cfg_avc_active;
                next_cfg_avc_pending := cfg_avc_pending;
                next_cfg_bls_active := cfg_bls_active;
                next_cfg_bls_pending := cfg_bls_pending;
                next_cfg_network_active := cfg_network_active;
                next_cfg_network_pending := cfg_network_pending;
                next_cfg_network_dhcp_active := cfg_network_dhcp_active;
                next_cfg_network_dhcp_pending := cfg_network_dhcp_pending;
                next_cfg_network_ipv4_active := cfg_network_ipv4_active;
                next_cfg_network_ipv4_pending := cfg_network_ipv4_pending;
                next_cfg_network_netmask_active := cfg_network_netmask_active;
                next_cfg_network_netmask_pending := cfg_network_netmask_pending;
                next_cfg_network_gateway_active := cfg_network_gateway_active;
                next_cfg_network_gateway_pending := cfg_network_gateway_pending;
                next_cfg_network_dns_active := cfg_network_dns_active;
                next_cfg_network_dns_pending := cfg_network_dns_pending;
                next_sys_reset_req := '0';
                next_save_reset_req := '0';
                next_cfg_apply_pending := ui_cfg_apply_pending;
                next_cfg_apply_error := ui_cfg_apply_error;
                apply_cfg_change_v := FALSE;

                IF basic_autostart_ui_seen /= basic_autostart_req THEN
                    basic_autostart_ui_seen <= basic_autostart_req;
                    next_overlay_enable := '0';
                    next_overlay_page := "0000";
                END IF;

                IF FAST_BUILD_TRIM_MEMORY THEN
                    next_cfg_slot_active := (OTHERS => '0');
                    next_cfg_slot_pending := (OTHERS => '0');
                END IF;

                IF sd_cfg_loaded_valid = '1' THEN
                    next_cfg_speed_active := sd_cfg_loaded_speed;
                    next_cfg_speed_pending := sd_cfg_loaded_speed;
                    next_cfg_phosphor_active := sd_cfg_loaded_phosphor_amber;
                    next_cfg_phosphor_pending := sd_cfg_loaded_phosphor_amber;
                    next_cfg_scanlines_active := sd_cfg_loaded_scanlines;
                    next_cfg_scanlines_pending := sd_cfg_loaded_scanlines;
                    next_cfg_video_zoom_active := sd_cfg_loaded_video_zoom;
                    next_cfg_video_zoom_pending := sd_cfg_loaded_video_zoom;
                    next_cfg_rs232_active := sd_cfg_loaded_rs232;
                    next_cfg_rs232_pending := sd_cfg_loaded_rs232;
                    next_cfg_rs232_speed_active := sd_cfg_loaded_rs232_speed;
                    next_cfg_rs232_speed_pending := sd_cfg_loaded_rs232_speed;
                    next_cfg_rs232_flow_active := sd_cfg_loaded_rs232_flow;
                    next_cfg_rs232_flow_pending := sd_cfg_loaded_rs232_flow;
                    IF FAST_BUILD_TRIM_MEMORY THEN
                        next_cfg_slot_active := (OTHERS => '0');
                        next_cfg_slot_pending := (OTHERS => '0');
                    ELSE
                        next_cfg_slot_restore_active := sd_cfg_loaded_slot_rom;
                        next_cfg_slot_restore_pending := sd_cfg_loaded_slot_rom;
                        IF sd_cfg_loaded_cpm = '1' THEN
                            next_cfg_slot_active := (OTHERS => '0');
                            next_cfg_slot_pending := (OTHERS => '0');
                        ELSE
                            next_cfg_slot_active := sd_cfg_loaded_slot_rom;
                            next_cfg_slot_pending := sd_cfg_loaded_slot_rom;
                        END IF;
                    END IF;
                    next_cfg_fdd_active := sd_cfg_loaded_fdd;
                    next_cfg_fdd_pending := sd_cfg_loaded_fdd;
                    next_cfg_cpm_active := sd_cfg_loaded_cpm;
                    next_cfg_cpm_pending := sd_cfg_loaded_cpm;
                    next_cfg_avc_active := sd_cfg_loaded_avc;
                    next_cfg_avc_pending := sd_cfg_loaded_avc;
                    next_cfg_bls_active := sd_cfg_loaded_bls;
                    next_cfg_bls_pending := sd_cfg_loaded_bls;
                    next_cfg_network_active := sd_cfg_loaded_network;
                    next_cfg_network_pending := sd_cfg_loaded_network;
                    next_cfg_network_dhcp_active := sd_cfg_loaded_network_dhcp;
                    next_cfg_network_dhcp_pending := sd_cfg_loaded_network_dhcp;
                    next_cfg_network_ipv4_active := sd_cfg_loaded_network_ipv4;
                    next_cfg_network_ipv4_pending := sd_cfg_loaded_network_ipv4;
                    next_cfg_network_netmask_active := sd_cfg_loaded_network_netmask;
                    next_cfg_network_netmask_pending := sd_cfg_loaded_network_netmask;
                    next_cfg_network_gateway_active := sd_cfg_loaded_network_gateway;
                    next_cfg_network_gateway_pending := sd_cfg_loaded_network_gateway;
                    next_cfg_network_dns_active := sd_cfg_loaded_network_dns;
                    next_cfg_network_dns_pending := sd_cfg_loaded_network_dns;
                    IF sd_cfg_loaded_cpm = '1' THEN
                        next_cfg_slot_active := (OTHERS => '0');
                        next_cfg_slot_pending := (OTHERS => '0');
                        next_cfg_fdd_active := '1';
                        next_cfg_fdd_pending := '1';
                        next_cfg_bls_active := '0';
                        next_cfg_bls_pending := '0';
                    END IF;

                    IF (sd_cfg_loaded_avc = '1' AND sd_cfg_loaded_speed = "00") OR
                        sd_cfg_loaded_speed /= cfg_cpu_speed_active OR
                        (NOT FAST_BUILD_TRIM_MEMORY AND sd_cfg_loaded_slot_rom /= cfg_slot_rom_persist) OR
                        (sd_cfg_loaded_fdd OR sd_cfg_loaded_cpm) /= cfg_fdd_active OR
                        sd_cfg_loaded_cpm /= cfg_cpm_active OR
                        sd_cfg_loaded_avc /= cfg_avc_active OR
                        sd_cfg_loaded_bls /= cfg_bls_active THEN
                        next_sys_reset_req := '1';
                    END IF;
                    next_cfg_apply_pending := '0';
                    next_cfg_apply_error := '0';
                ELSIF sd_cfg_save_done = '1' THEN
                    next_cfg_apply_pending := '0';
                    next_cfg_apply_error := '0';
                ELSIF sd_cfg_save_error = '1' THEN
                    next_cfg_apply_pending := '0';
                    next_cfg_apply_error := '1';
                END IF;

                IF ps2_valid = '1' AND ps2_released = '0' THEN
                    IF ps2_extended = '0' THEN
                        CASE ps2_code IS
                            WHEN x"05" => -- F1
                                IF next_overlay_enable = '1' AND next_overlay_page = "0000" THEN
                                    next_overlay_enable := '0';
                                ELSE
                                    next_overlay_enable := '1';
                                    next_overlay_page := "0000";
                                END IF;

                            WHEN x"04" => -- F3
                                IF next_overlay_enable = '1' AND next_overlay_page = "0001" THEN
                                    next_overlay_enable := '0';
                                ELSE
                                    next_overlay_enable := '1';
                                    next_overlay_page := "0001";
                                END IF;

                            WHEN x"03" => -- F5: hardware monitor / GOD mode
                                IF next_overlay_enable = '1' AND next_overlay_page = "0110" THEN
                                    next_overlay_enable := '0';
                                ELSE
                                    next_overlay_enable := '1';
                                    next_overlay_page := "0110";
                                END IF;

                            WHEN x"83" => -- F7: latched CP/M/FDD diagnostics
                                IF next_overlay_enable = '1' AND next_overlay_page = "0111" THEN
                                    next_overlay_enable := '0';
                                ELSE
                                    next_overlay_enable := '1';
                                    next_overlay_page := "0111";
                                END IF;

                            WHEN x"78" => -- F11
                                IF next_overlay_enable = '1' AND next_overlay_page = "0100" THEN
                                    next_overlay_enable := '0';
                                ELSE
                                    next_overlay_enable := '1';
                                    next_overlay_page := "0100";
                                    next_browser_action := BROWSE_RESET;
                                END IF;

                            WHEN x"01" => -- F9
                                IF next_overlay_enable = '1' AND next_overlay_page = "0101" THEN
                                    next_overlay_enable := '0';
                                ELSE
                                    next_overlay_enable := '1';
                                    next_overlay_page := "0101";
                                    next_save_reset_req := '1';
                                END IF;

                            WHEN x"0D" => -- Tab: select IPv4 octet on network page
                                IF next_overlay_enable = '1' AND next_overlay_page = "1000" THEN
                                    IF ui_network_octet_sel = 3 THEN
                                        ui_network_octet_sel <= 0;
                                    ELSE
                                        ui_network_octet_sel <= ui_network_octet_sel + 1;
                                    END IF;
                                END IF;

                            WHEN x"85" => -- F13 (internal extension)
                                IF next_overlay_enable = '0' THEN
                                    next_overlay_enable := '1';
                                    next_overlay_page := "0010";
                                    next_cfg_row_sel := "000";
                                    next_cfg_speed_pending := next_cfg_speed_active;
                                    next_cfg_phosphor_pending := next_cfg_phosphor_active;
                                    next_cfg_scanlines_pending := next_cfg_scanlines_active;
                                    next_cfg_video_zoom_pending := next_cfg_video_zoom_active;
                                    next_cfg_rs232_pending := next_cfg_rs232_active;
                                    next_cfg_rs232_speed_pending := next_cfg_rs232_speed_active;
                                    next_cfg_rs232_flow_pending := next_cfg_rs232_flow_active;
                                    next_cfg_slot_pending := next_cfg_slot_active;
                                    next_cfg_slot_restore_pending := next_cfg_slot_restore_active;
                                    next_cfg_fdd_pending := next_cfg_fdd_active;
                                    next_cfg_cpm_pending := next_cfg_cpm_active;
                                    next_cfg_avc_pending := next_cfg_avc_active;
                                    next_cfg_bls_pending := next_cfg_bls_active;
                                    next_cfg_network_pending := next_cfg_network_active;
                                    next_cfg_network_dhcp_pending := next_cfg_network_dhcp_active;
                                    next_cfg_network_ipv4_pending := next_cfg_network_ipv4_active;
                                    next_cfg_network_netmask_pending := next_cfg_network_netmask_active;
                                    next_cfg_network_gateway_pending := next_cfg_network_gateway_active;
                                    next_cfg_network_dns_pending := next_cfg_network_dns_active;
                                ELSIF next_overlay_page = "0010" THEN
                                    next_overlay_page := "0011";
                                    next_cfg_row_sel := "000";
                                    next_cfg_slot_pending := next_cfg_slot_active;
                                    next_cfg_slot_restore_pending := next_cfg_slot_restore_active;
                                    next_cfg_fdd_pending := next_cfg_fdd_active;
                                    next_cfg_cpm_pending := next_cfg_cpm_active;
                                    next_cfg_avc_pending := next_cfg_avc_active;
                                    next_cfg_bls_pending := next_cfg_bls_active;
                                ELSIF next_overlay_page = "0011" THEN
                                    IF network_available_i = '1' THEN
                                        next_overlay_page := "1000";
                                        next_cfg_row_sel := "000";
                                        ui_network_octet_sel <= 0;
                                        next_cfg_network_pending := next_cfg_network_active;
                                        next_cfg_network_dhcp_pending := next_cfg_network_dhcp_active;
                                        next_cfg_network_ipv4_pending := next_cfg_network_ipv4_active;
                                        next_cfg_network_netmask_pending := next_cfg_network_netmask_active;
                                        next_cfg_network_gateway_pending := next_cfg_network_gateway_active;
                                        next_cfg_network_dns_pending := next_cfg_network_dns_active;
                                    ELSE
                                        next_overlay_enable := '0';
                                        next_cfg_row_sel := "000";
                                        next_cfg_speed_pending := next_cfg_speed_active;
                                        next_cfg_phosphor_pending := next_cfg_phosphor_active;
                                        next_cfg_scanlines_pending := next_cfg_scanlines_active;
                                        next_cfg_video_zoom_pending := next_cfg_video_zoom_active;
                                        next_cfg_rs232_pending := next_cfg_rs232_active;
                                        next_cfg_rs232_speed_pending := next_cfg_rs232_speed_active;
                                        next_cfg_rs232_flow_pending := next_cfg_rs232_flow_active;
                                        next_cfg_slot_pending := next_cfg_slot_active;
                                        next_cfg_slot_restore_pending := next_cfg_slot_restore_active;
                                        next_cfg_fdd_pending := next_cfg_fdd_active;
                                        next_cfg_cpm_pending := next_cfg_cpm_active;
                                        next_cfg_avc_pending := next_cfg_avc_active;
                                        next_cfg_bls_pending := next_cfg_bls_active;
                                    END IF;
                                ELSIF next_overlay_page = "1000" THEN
                                    next_overlay_enable := '0';
                                    next_cfg_row_sel := "000";
                                    next_cfg_speed_pending := next_cfg_speed_active;
                                    next_cfg_phosphor_pending := next_cfg_phosphor_active;
                                    next_cfg_scanlines_pending := next_cfg_scanlines_active;
                                    next_cfg_video_zoom_pending := next_cfg_video_zoom_active;
                                    next_cfg_rs232_pending := next_cfg_rs232_active;
                                    next_cfg_rs232_speed_pending := next_cfg_rs232_speed_active;
                                    next_cfg_rs232_flow_pending := next_cfg_rs232_flow_active;
                                    next_cfg_slot_pending := next_cfg_slot_active;
                                    next_cfg_slot_restore_pending := next_cfg_slot_restore_active;
                                    next_cfg_fdd_pending := next_cfg_fdd_active;
                                    next_cfg_cpm_pending := next_cfg_cpm_active;
                                    next_cfg_avc_pending := next_cfg_avc_active;
                                    next_cfg_bls_pending := next_cfg_bls_active;
                                    next_cfg_network_pending := next_cfg_network_active;
                                    next_cfg_network_dhcp_pending := next_cfg_network_dhcp_active;
                                    next_cfg_network_ipv4_pending := next_cfg_network_ipv4_active;
                                    next_cfg_network_netmask_pending := next_cfg_network_netmask_active;
                                    next_cfg_network_gateway_pending := next_cfg_network_gateway_active;
                                    next_cfg_network_dns_pending := next_cfg_network_dns_active;
                                ELSE
                                    next_overlay_enable := '1';
                                    next_overlay_page := "0010";
                                    next_cfg_row_sel := "000";
                                    next_cfg_speed_pending := next_cfg_speed_active;
                                    next_cfg_phosphor_pending := next_cfg_phosphor_active;
                                    next_cfg_scanlines_pending := next_cfg_scanlines_active;
                                    next_cfg_video_zoom_pending := next_cfg_video_zoom_active;
                                    next_cfg_rs232_pending := next_cfg_rs232_active;
                                    next_cfg_rs232_speed_pending := next_cfg_rs232_speed_active;
                                    next_cfg_rs232_flow_pending := next_cfg_rs232_flow_active;
                                    next_cfg_slot_pending := next_cfg_slot_active;
                                    next_cfg_slot_restore_pending := next_cfg_slot_restore_active;
                                    next_cfg_fdd_pending := next_cfg_fdd_active;
                                    next_cfg_cpm_pending := next_cfg_cpm_active;
                                    next_cfg_avc_pending := next_cfg_avc_active;
                                    next_cfg_bls_pending := next_cfg_bls_active;
                                END IF;

                            WHEN x"5A" => -- Enter
                                IF next_overlay_enable = '1' AND next_overlay_page = "0010" THEN
                                    IF next_cfg_row_sel = "000" THEN
                                        next_overlay_enable := '0';
                                        next_overlay_page := "0000";
                                        next_cfg_row_sel := "000";
                                        next_sys_reset_req := '1';
                                    ELSE
                                        IF next_cfg_speed_pending /= next_cfg_speed_active THEN
                                            next_cfg_speed_active := next_cfg_speed_pending;
                                            apply_cfg_change_v := TRUE;
                                        END IF;
                                        IF next_cfg_phosphor_pending /= next_cfg_phosphor_active THEN
                                            next_cfg_phosphor_active := next_cfg_phosphor_pending;
                                            apply_cfg_change_v := TRUE;
                                        END IF;
                                        IF next_cfg_scanlines_pending /= next_cfg_scanlines_active THEN
                                            next_cfg_scanlines_active := next_cfg_scanlines_pending;
                                            apply_cfg_change_v := TRUE;
                                        END IF;
                                        IF next_cfg_video_zoom_pending /= next_cfg_video_zoom_active THEN
                                            next_cfg_video_zoom_active := next_cfg_video_zoom_pending;
                                            apply_cfg_change_v := TRUE;
                                        END IF;
                                        IF next_cfg_rs232_pending /= next_cfg_rs232_active THEN
                                            next_cfg_rs232_active := next_cfg_rs232_pending;
                                            apply_cfg_change_v := TRUE;
                                        END IF;
                                        IF next_cfg_rs232_speed_pending /= next_cfg_rs232_speed_active THEN
                                            next_cfg_rs232_speed_active := next_cfg_rs232_speed_pending;
                                            apply_cfg_change_v := TRUE;
                                        END IF;
                                        IF next_cfg_rs232_flow_pending /= next_cfg_rs232_flow_active THEN
                                            next_cfg_rs232_flow_active := next_cfg_rs232_flow_pending;
                                            apply_cfg_change_v := TRUE;
                                        END IF;
                                        IF apply_cfg_change_v THEN
                                            next_overlay_enable := '0';
                                            next_overlay_page := "0000";
                                            next_cfg_row_sel := "000";
                                        END IF;
                                    END IF;
                                ELSIF next_overlay_enable = '1' AND next_overlay_page = "0011" THEN
                                    -- The original AVC is specified for 4 MHz
                                    -- and can be linked for a 2 MHz processor;
                                    -- 1 MHz is not a supported configuration.
                                    IF next_cfg_avc_pending = '1' AND next_cfg_speed_pending = "00" THEN
                                        next_cfg_speed_pending := "01";
                                    END IF;
                                    IF next_cfg_slot_pending /= next_cfg_slot_active OR
                                        next_cfg_slot_restore_pending /= next_cfg_slot_restore_active OR
                                        next_cfg_fdd_pending /= next_cfg_fdd_active OR
                                        next_cfg_cpm_pending /= next_cfg_cpm_active OR
                                        next_cfg_avc_pending /= next_cfg_avc_active OR
                                        next_cfg_bls_pending /= next_cfg_bls_active OR
                                        next_cfg_speed_pending /= next_cfg_speed_active THEN
                                        next_cfg_slot_active := next_cfg_slot_pending;
                                        next_cfg_slot_restore_active := next_cfg_slot_restore_pending;
                                        next_cfg_fdd_active := next_cfg_fdd_pending;
                                        next_cfg_cpm_active := next_cfg_cpm_pending;
                                        next_cfg_avc_active := next_cfg_avc_pending;
                                        next_cfg_bls_active := next_cfg_bls_pending;
                                        next_cfg_speed_active := next_cfg_speed_pending;
                                        apply_cfg_change_v := TRUE;
                                        -- ROM/FDD changes need a reset, but only after
                                        -- N2CONF.CFG has been written successfully.
                                        -- The config-save process raises sd_cfg_reset_req
                                        -- when sd_cfg_save_done arrives.
                                        next_overlay_enable := '0';
                                        next_overlay_page := "0000";
                                        next_cfg_row_sel := "000";
                                    END IF;
                                ELSIF next_overlay_enable = '1' AND next_overlay_page = "1000" THEN
                                    IF next_cfg_network_pending /= next_cfg_network_active OR
                                        next_cfg_network_dhcp_pending /= next_cfg_network_dhcp_active OR
                                        next_cfg_network_ipv4_pending /= next_cfg_network_ipv4_active OR
                                        next_cfg_network_netmask_pending /= next_cfg_network_netmask_active OR
                                        next_cfg_network_gateway_pending /= next_cfg_network_gateway_active OR
                                        next_cfg_network_dns_pending /= next_cfg_network_dns_active THEN
                                        next_cfg_network_active := next_cfg_network_pending;
                                        next_cfg_network_dhcp_active := next_cfg_network_dhcp_pending;
                                        next_cfg_network_ipv4_active := next_cfg_network_ipv4_pending;
                                        next_cfg_network_netmask_active := next_cfg_network_netmask_pending;
                                        next_cfg_network_gateway_active := next_cfg_network_gateway_pending;
                                        next_cfg_network_dns_active := next_cfg_network_dns_pending;
                                        apply_cfg_change_v := TRUE;
                                        next_overlay_enable := '0';
                                        next_overlay_page := "0000";
                                        next_cfg_row_sel := "000";
                                    END IF;
                                ELSIF next_overlay_enable = '1' AND next_overlay_page = "0100" AND
                                    ui_browser_manage_mode = BROWSER_MANAGE_IDLE THEN
                                    IF sd_selected_valid = '1' AND sd_read_busy = '0' THEN
                                        next_browser_action := BROWSE_LOAD;
                                    END IF;
                                END IF;

                            WHEN x"75" | x"72" | x"6B" | x"74" =>
                                NULL;

                            WHEN OTHERS =>
                                NULL;
                        END CASE;

                    ELSE
                        CASE ps2_code IS
                            WHEN x"75" => -- extended Up
                                IF next_overlay_enable = '1' THEN
                                    IF next_overlay_page = "0010" THEN
                                        CASE next_cfg_row_sel IS
                                            WHEN "000" => next_cfg_row_sel := "110";
                                            WHEN "001" => next_cfg_row_sel := "000";
                                            WHEN "010" => next_cfg_row_sel := "001";
                                            WHEN "011" => next_cfg_row_sel := "010";
                                            WHEN "100" => next_cfg_row_sel := "011";
                                            WHEN "101" => next_cfg_row_sel := "100";
                                            WHEN OTHERS => next_cfg_row_sel := "101";
                                        END CASE;
                                    ELSIF next_overlay_page = "0011" THEN
                                        CASE next_cfg_row_sel IS
                                            WHEN "000" => next_cfg_row_sel := "111";
                                            WHEN "001" => next_cfg_row_sel := "000";
                                            WHEN "010" => next_cfg_row_sel := "001";
                                            WHEN "011" => next_cfg_row_sel := "010";
                                            WHEN "100" => next_cfg_row_sel := "011";
                                            WHEN "101" => next_cfg_row_sel := "100";
                                            WHEN "110" => next_cfg_row_sel := "101";
                                            WHEN OTHERS => next_cfg_row_sel := "110";
                                        END CASE;
                                    ELSIF next_overlay_page = "1000" THEN
                                        CASE next_cfg_row_sel IS
                                            WHEN "000" => next_cfg_row_sel := "101";
                                            WHEN "001" => next_cfg_row_sel := "000";
                                            WHEN "010" => next_cfg_row_sel := "001";
                                            WHEN "011" => next_cfg_row_sel := "010";
                                            WHEN "100" => next_cfg_row_sel := "011";
                                            WHEN OTHERS => next_cfg_row_sel := "100";
                                        END CASE;
                                    ELSIF next_overlay_page = "0100" THEN
                                        IF ui_browser_manage_mode = BROWSER_MANAGE_IDLE AND
                                            sd_read_busy = '0' AND sd_root_file_count > 0 THEN
                                            next_browser_action := BROWSE_UP;
                                        END IF;
                                    END IF;
                                END IF;

                            WHEN x"72" => -- extended Down
                                IF next_overlay_enable = '1' THEN
                                    IF next_overlay_page = "0010" THEN
                                        CASE next_cfg_row_sel IS
                                            WHEN "000" => next_cfg_row_sel := "001";
                                            WHEN "001" => next_cfg_row_sel := "010";
                                            WHEN "010" => next_cfg_row_sel := "011";
                                            WHEN "011" => next_cfg_row_sel := "100";
                                            WHEN "100" => next_cfg_row_sel := "101";
                                            WHEN "101" => next_cfg_row_sel := "110";
                                            WHEN OTHERS => next_cfg_row_sel := "000";
                                        END CASE;
                                    ELSIF next_overlay_page = "0011" THEN
                                        CASE next_cfg_row_sel IS
                                            WHEN "000" => next_cfg_row_sel := "001";
                                            WHEN "001" => next_cfg_row_sel := "010";
                                            WHEN "010" => next_cfg_row_sel := "011";
                                            WHEN "011" => next_cfg_row_sel := "100";
                                            WHEN "100" => next_cfg_row_sel := "101";
                                            WHEN "101" => next_cfg_row_sel := "110";
                                            WHEN "110" => next_cfg_row_sel := "111";
                                            WHEN OTHERS => next_cfg_row_sel := "000";
                                        END CASE;
                                    ELSIF next_overlay_page = "1000" THEN
                                        CASE next_cfg_row_sel IS
                                            WHEN "000" => next_cfg_row_sel := "001";
                                            WHEN "001" => next_cfg_row_sel := "010";
                                            WHEN "010" => next_cfg_row_sel := "011";
                                            WHEN "011" => next_cfg_row_sel := "100";
                                            WHEN "100" => next_cfg_row_sel := "101";
                                            WHEN OTHERS => next_cfg_row_sel := "000";
                                        END CASE;
                                    ELSIF next_overlay_page = "0100" THEN
                                        IF ui_browser_manage_mode = BROWSER_MANAGE_IDLE AND
                                            sd_read_busy = '0' AND sd_root_file_count > 0 THEN
                                            next_browser_action := BROWSE_DOWN;
                                        END IF;
                                    END IF;
                                END IF;

                            WHEN x"6B" => -- extended Left
                                IF next_overlay_enable = '1' THEN
                                    IF next_overlay_page = "0010" THEN
                                        IF next_cfg_row_sel = "001" THEN
                                            IF next_cfg_avc_active = '1' OR next_cfg_avc_pending = '1' THEN
                                                CASE next_cfg_speed_pending IS
                                                    WHEN "01" => next_cfg_speed_pending := "10";
                                                    WHEN OTHERS => next_cfg_speed_pending := "01";
                                                END CASE;
                                            ELSE
                                                CASE next_cfg_speed_pending IS
                                                    WHEN "00" => next_cfg_speed_pending := "10";
                                                    WHEN "01" => next_cfg_speed_pending := "00";
                                                    WHEN OTHERS => next_cfg_speed_pending := "01";
                                                END CASE;
                                            END IF;
                                        ELSIF next_cfg_row_sel = "010" THEN
                                            IF next_cfg_phosphor_pending = '0' AND next_cfg_scanlines_pending = '0' THEN
                                                next_cfg_phosphor_pending := '1';
                                                next_cfg_scanlines_pending := '1';
                                            ELSIF next_cfg_phosphor_pending = '0' AND next_cfg_scanlines_pending = '1' THEN
                                                next_cfg_phosphor_pending := '0';
                                                next_cfg_scanlines_pending := '0';
                                            ELSIF next_cfg_phosphor_pending = '1' AND next_cfg_scanlines_pending = '0' THEN
                                                next_cfg_phosphor_pending := '0';
                                                next_cfg_scanlines_pending := '1';
                                            ELSE
                                                next_cfg_phosphor_pending := '1';
                                                next_cfg_scanlines_pending := '0';
                                            END IF;
                                        ELSIF next_cfg_row_sel = "011" THEN
                                            CASE next_cfg_video_zoom_pending IS
                                                WHEN "00" => next_cfg_video_zoom_pending := "10";
                                                WHEN "10" => next_cfg_video_zoom_pending := "01";
                                                WHEN OTHERS => next_cfg_video_zoom_pending := "00";
                                            END CASE;
                                        ELSIF next_cfg_row_sel = "100" THEN
                                            CASE next_cfg_rs232_pending IS
                                                WHEN "000" => next_cfg_rs232_pending := "100";
                                                WHEN "001" => next_cfg_rs232_pending := "000";
                                                WHEN "010" => next_cfg_rs232_pending := "001";
                                                WHEN "011" => next_cfg_rs232_pending := "010";
                                                WHEN OTHERS => next_cfg_rs232_pending := "011";
                                            END CASE;
                                        ELSIF next_cfg_row_sel = "101" THEN
                                            IF next_cfg_rs232_pending /= "000" THEN
                                                next_cfg_rs232_speed_pending := prev_rs232_speed_sel(next_cfg_rs232_speed_pending);
                                            END IF;
                                        ELSIF next_cfg_row_sel = "110" THEN
                                            IF next_cfg_rs232_pending /= "000" THEN
                                                next_cfg_rs232_flow_pending := NOT next_cfg_rs232_flow_pending;
                                            END IF;
                                        END IF;
                                    ELSIF next_overlay_page = "0011" THEN
                                        CASE next_cfg_row_sel IS
                                            WHEN "000" =>
                                                IF next_cfg_cpm_pending = '0' THEN
                                                    next_cfg_slot_pending(0) := NOT next_cfg_slot_pending(0);
                                                END IF;
                                            WHEN "001" =>
                                                IF next_cfg_cpm_pending = '0' THEN
                                                    next_cfg_slot_pending(1) := NOT next_cfg_slot_pending(1);
                                                END IF;
                                            WHEN "010" =>
                                                IF next_cfg_cpm_pending = '0' THEN
                                                    next_cfg_slot_pending(2) := NOT next_cfg_slot_pending(2);
                                                END IF;
                                            WHEN "011" =>
                                                IF next_cfg_fdd_pending = '0' AND next_cfg_cpm_pending = '0' THEN
                                                    next_cfg_slot_pending(3) := NOT next_cfg_slot_pending(3);
                                                END IF;
                                            WHEN "100" =>
                                                IF next_cfg_cpm_pending = '0' THEN
                                                    next_cfg_fdd_pending := NOT next_cfg_fdd_pending;
                                                END IF;
                                            WHEN "101" =>
                                                next_cfg_cpm_pending := NOT next_cfg_cpm_pending;
                                                IF next_cfg_cpm_pending = '1' THEN
                                                    next_cfg_slot_restore_pending := next_cfg_slot_pending;
                                                    next_cfg_slot_pending := (OTHERS => '0');
                                                    next_cfg_fdd_pending := '1';
                                                    next_cfg_bls_pending := '0';
                                                ELSE
                                                    next_cfg_slot_pending := next_cfg_slot_restore_pending;
                                                END IF;
                                            WHEN "110" =>
                                                next_cfg_avc_pending := NOT next_cfg_avc_pending;
                                                IF next_cfg_avc_pending = '1' AND next_cfg_speed_pending = "00" THEN
                                                    next_cfg_speed_pending := "01";
                                                END IF;
                                            WHEN OTHERS =>
                                                next_cfg_bls_pending := NOT next_cfg_bls_pending;
                                                IF next_cfg_bls_pending = '1' THEN
                                                    next_cfg_cpm_pending := '0';
                                                END IF;
                                        END CASE;
                                    ELSIF next_overlay_page = "1000" THEN
                                        CASE next_cfg_row_sel IS
                                            WHEN "000" => next_cfg_network_pending := NOT next_cfg_network_pending;
                                            WHEN "001" => next_cfg_network_dhcp_pending := NOT next_cfg_network_dhcp_pending;
                                            WHEN "010" => IF next_cfg_network_dhcp_pending = '0' THEN next_cfg_network_ipv4_pending := adjust_ipv4_octet(next_cfg_network_ipv4_pending, ui_network_octet_sel, FALSE); END IF;
                                            WHEN "011" => IF next_cfg_network_dhcp_pending = '0' THEN next_cfg_network_netmask_pending := adjust_ipv4_octet(next_cfg_network_netmask_pending, ui_network_octet_sel, FALSE); END IF;
                                            WHEN "100" => IF next_cfg_network_dhcp_pending = '0' THEN next_cfg_network_gateway_pending := adjust_ipv4_octet(next_cfg_network_gateway_pending, ui_network_octet_sel, FALSE); END IF;
                                            WHEN OTHERS => IF next_cfg_network_dhcp_pending = '0' THEN next_cfg_network_dns_pending := adjust_ipv4_octet(next_cfg_network_dns_pending, ui_network_octet_sel, FALSE); END IF;
                                        END CASE;
                                    ELSIF next_overlay_page = "0100" THEN
                                        IF ui_browser_manage_mode = BROWSER_MANAGE_IDLE AND
                                            sd_read_busy = '0' AND sd_root_file_count > 0 THEN
                                            next_browser_action := BROWSE_PAGE_UP;
                                        END IF;
                                    END IF;
                                END IF;

                            WHEN x"74" => -- extended Right
                                IF next_overlay_enable = '1' THEN
                                    IF next_overlay_page = "0010" THEN
                                        IF next_cfg_row_sel = "001" THEN
                                            IF next_cfg_avc_active = '1' OR next_cfg_avc_pending = '1' THEN
                                                CASE next_cfg_speed_pending IS
                                                    WHEN "01" => next_cfg_speed_pending := "10";
                                                    WHEN OTHERS => next_cfg_speed_pending := "01";
                                                END CASE;
                                            ELSE
                                                CASE next_cfg_speed_pending IS
                                                    WHEN "00" => next_cfg_speed_pending := "01";
                                                    WHEN "01" => next_cfg_speed_pending := "10";
                                                    WHEN OTHERS => next_cfg_speed_pending := "00";
                                                END CASE;
                                            END IF;
                                        ELSIF next_cfg_row_sel = "010" THEN
                                            IF next_cfg_phosphor_pending = '0' AND next_cfg_scanlines_pending = '0' THEN
                                                next_cfg_phosphor_pending := '0';
                                                next_cfg_scanlines_pending := '1';
                                            ELSIF next_cfg_phosphor_pending = '0' AND next_cfg_scanlines_pending = '1' THEN
                                                next_cfg_phosphor_pending := '1';
                                                next_cfg_scanlines_pending := '0';
                                            ELSIF next_cfg_phosphor_pending = '1' AND next_cfg_scanlines_pending = '0' THEN
                                                next_cfg_phosphor_pending := '1';
                                                next_cfg_scanlines_pending := '1';
                                            ELSE
                                                next_cfg_phosphor_pending := '0';
                                                next_cfg_scanlines_pending := '0';
                                            END IF;
                                        ELSIF next_cfg_row_sel = "011" THEN
                                            CASE next_cfg_video_zoom_pending IS
                                                WHEN "00" => next_cfg_video_zoom_pending := "01";
                                                WHEN "01" => next_cfg_video_zoom_pending := "10";
                                                WHEN OTHERS => next_cfg_video_zoom_pending := "00";
                                            END CASE;
                                        ELSIF next_cfg_row_sel = "100" THEN
                                            CASE next_cfg_rs232_pending IS
                                                WHEN "000" => next_cfg_rs232_pending := "001";
                                                WHEN "001" => next_cfg_rs232_pending := "010";
                                                WHEN "010" => next_cfg_rs232_pending := "011";
                                                WHEN "011" => next_cfg_rs232_pending := "100";
                                                WHEN OTHERS => next_cfg_rs232_pending := "000";
                                            END CASE;
                                        ELSIF next_cfg_row_sel = "101" THEN
                                            IF next_cfg_rs232_pending /= "000" THEN
                                                next_cfg_rs232_speed_pending := next_rs232_speed_sel(next_cfg_rs232_speed_pending);
                                            END IF;
                                        ELSIF next_cfg_row_sel = "110" THEN
                                            IF next_cfg_rs232_pending /= "000" THEN
                                                next_cfg_rs232_flow_pending := NOT next_cfg_rs232_flow_pending;
                                            END IF;
                                        END IF;
                                    ELSIF next_overlay_page = "0011" THEN
                                        CASE next_cfg_row_sel IS
                                            WHEN "000" =>
                                                IF next_cfg_cpm_pending = '0' THEN
                                                    next_cfg_slot_pending(0) := NOT next_cfg_slot_pending(0);
                                                END IF;
                                            WHEN "001" =>
                                                IF next_cfg_cpm_pending = '0' THEN
                                                    next_cfg_slot_pending(1) := NOT next_cfg_slot_pending(1);
                                                END IF;
                                            WHEN "010" =>
                                                IF next_cfg_cpm_pending = '0' THEN
                                                    next_cfg_slot_pending(2) := NOT next_cfg_slot_pending(2);
                                                END IF;
                                            WHEN "011" =>
                                                IF next_cfg_fdd_pending = '0' AND next_cfg_cpm_pending = '0' THEN
                                                    next_cfg_slot_pending(3) := NOT next_cfg_slot_pending(3);
                                                END IF;
                                            WHEN "100" =>
                                                IF next_cfg_cpm_pending = '0' THEN
                                                    next_cfg_fdd_pending := NOT next_cfg_fdd_pending;
                                                END IF;
                                            WHEN "101" =>
                                                next_cfg_cpm_pending := NOT next_cfg_cpm_pending;
                                                IF next_cfg_cpm_pending = '1' THEN
                                                    next_cfg_slot_restore_pending := next_cfg_slot_pending;
                                                    next_cfg_slot_pending := (OTHERS => '0');
                                                    next_cfg_fdd_pending := '1';
                                                    next_cfg_bls_pending := '0';
                                                ELSE
                                                    next_cfg_slot_pending := next_cfg_slot_restore_pending;
                                                END IF;
                                            WHEN "110" =>
                                                next_cfg_avc_pending := NOT next_cfg_avc_pending;
                                                IF next_cfg_avc_pending = '1' AND next_cfg_speed_pending = "00" THEN
                                                    next_cfg_speed_pending := "01";
                                                END IF;
                                            WHEN OTHERS =>
                                                next_cfg_bls_pending := NOT next_cfg_bls_pending;
                                                IF next_cfg_bls_pending = '1' THEN
                                                    next_cfg_cpm_pending := '0';
                                                END IF;
                                        END CASE;
                                    ELSIF next_overlay_page = "1000" THEN
                                        CASE next_cfg_row_sel IS
                                            WHEN "000" => next_cfg_network_pending := NOT next_cfg_network_pending;
                                            WHEN "001" => next_cfg_network_dhcp_pending := NOT next_cfg_network_dhcp_pending;
                                            WHEN "010" => IF next_cfg_network_dhcp_pending = '0' THEN next_cfg_network_ipv4_pending := adjust_ipv4_octet(next_cfg_network_ipv4_pending, ui_network_octet_sel, TRUE); END IF;
                                            WHEN "011" => IF next_cfg_network_dhcp_pending = '0' THEN next_cfg_network_netmask_pending := adjust_ipv4_octet(next_cfg_network_netmask_pending, ui_network_octet_sel, TRUE); END IF;
                                            WHEN "100" => IF next_cfg_network_dhcp_pending = '0' THEN next_cfg_network_gateway_pending := adjust_ipv4_octet(next_cfg_network_gateway_pending, ui_network_octet_sel, TRUE); END IF;
                                            WHEN OTHERS => IF next_cfg_network_dhcp_pending = '0' THEN next_cfg_network_dns_pending := adjust_ipv4_octet(next_cfg_network_dns_pending, ui_network_octet_sel, TRUE); END IF;
                                        END CASE;
                                    ELSIF next_overlay_page = "0100" THEN
                                        IF ui_browser_manage_mode = BROWSER_MANAGE_IDLE AND
                                            sd_read_busy = '0' AND sd_root_file_count > 0 THEN
                                            next_browser_action := BROWSE_PAGE_DOWN;
                                        END IF;
                                    END IF;
                                END IF;

                            WHEN OTHERS =>
                                NULL;
                        END CASE;
                    END IF;
                END IF;

                IF apply_cfg_change_v THEN
                    next_cfg_apply_pending := '1';
                    next_cfg_apply_error := '0';
                END IF;

                IF FAST_BUILD_TRIM_MEMORY THEN
                    next_cfg_slot_active := (OTHERS => '0');
                    next_cfg_slot_pending := (OTHERS => '0');
                    next_cfg_bls_active := '0';
                    next_cfg_bls_pending := '0';
                END IF;

                -- CP/M always owns the floppy controller and needs writable
                -- memory in every configurable ROM socket.
                IF next_cfg_cpm_active = '1' THEN
                    next_cfg_slot_active := (OTHERS => '0');
                    next_cfg_fdd_active := '1';
                    next_cfg_bls_active := '0';
                END IF;
                IF next_cfg_cpm_pending = '1' THEN
                    next_cfg_slot_pending := (OTHERS => '0');
                    next_cfg_fdd_pending := '1';
                    next_cfg_bls_pending := '0';
                END IF;

                -- Keep the active and editable configurations valid even
                -- when an older N2CONF.CFG contains AVC=ON with CPU=1 MHz.
                IF next_cfg_avc_active = '1' AND next_cfg_speed_active = "00" THEN
                    next_cfg_speed_active := "01";
                END IF;
                IF next_cfg_avc_pending = '1' AND next_cfg_speed_pending = "00" THEN
                    next_cfg_speed_pending := "01";
                END IF;

                -- DIRTY is display status only.  Compare the registered
                -- configurations instead of the large next-state mux.  This
                -- removes the cfg-load pulse from a 17-level 100 MHz path;
                -- the resulting one-clock (10 ns) display latency is invisible.
                IF cfg_cpu_speed_pending /= cfg_cpu_speed_active OR
                    cfg_phosphor_amber_pending /= cfg_phosphor_amber_active OR
                    cfg_scanlines_pending /= cfg_scanlines_active OR
                    cfg_video_zoom_pending /= cfg_video_zoom_active OR
                    cfg_rs232_pending /= cfg_rs232_active OR
                    cfg_rs232_speed_pending /= cfg_rs232_speed_active OR
                    cfg_rs232_flow_pending /= cfg_rs232_flow_active OR
                    cfg_slot_rom_pending /= cfg_slot_rom_active OR
                    cfg_slot_rom_restore_pending /= cfg_slot_rom_restore_active OR
                    cfg_fdd_pending /= cfg_fdd_active OR
                    cfg_cpm_pending /= cfg_cpm_active OR
                    cfg_avc_pending /= cfg_avc_active OR
                    cfg_bls_pending /= cfg_bls_active OR
                    cfg_network_pending /= cfg_network_active OR
                    cfg_network_dhcp_pending /= cfg_network_dhcp_active OR
                    cfg_network_ipv4_pending /= cfg_network_ipv4_active OR
                    cfg_network_netmask_pending /= cfg_network_netmask_active OR
                    cfg_network_gateway_pending /= cfg_network_gateway_active OR
                    cfg_network_dns_pending /= cfg_network_dns_active THEN
                    ui_cfg_dirty <= '1';
                ELSE
                    ui_cfg_dirty <= '0';
                END IF;

                ui_overlay_enable <= next_overlay_enable;
                ui_overlay_page <= next_overlay_page;
                ui_cfg_row_sel <= next_cfg_row_sel;
                ui_browser_action <= next_browser_action;
                cfg_cpu_speed_active <= next_cfg_speed_active;
                cfg_cpu_speed_pending <= next_cfg_speed_pending;
                cfg_phosphor_amber_active <= next_cfg_phosphor_active;
                cfg_phosphor_amber_pending <= next_cfg_phosphor_pending;
                cfg_scanlines_active <= next_cfg_scanlines_active;
                cfg_scanlines_pending <= next_cfg_scanlines_pending;
                cfg_video_zoom_active <= next_cfg_video_zoom_active;
                cfg_video_zoom_pending <= next_cfg_video_zoom_pending;
                cfg_rs232_active <= next_cfg_rs232_active;
                cfg_rs232_pending <= next_cfg_rs232_pending;
                cfg_rs232_speed_active <= next_cfg_rs232_speed_active;
                cfg_rs232_speed_pending <= next_cfg_rs232_speed_pending;
                cfg_rs232_flow_active <= next_cfg_rs232_flow_active;
                cfg_rs232_flow_pending <= next_cfg_rs232_flow_pending;
                cfg_slot_rom_active <= next_cfg_slot_active;
                cfg_slot_rom_pending <= next_cfg_slot_pending;
                cfg_slot_rom_restore_active <= next_cfg_slot_restore_active;
                cfg_slot_rom_restore_pending <= next_cfg_slot_restore_pending;
                cfg_fdd_active <= next_cfg_fdd_active;
                cfg_fdd_pending <= next_cfg_fdd_pending;
                cfg_cpm_active <= next_cfg_cpm_active;
                cfg_cpm_pending <= next_cfg_cpm_pending;
                cfg_avc_active <= next_cfg_avc_active;
                cfg_avc_pending <= next_cfg_avc_pending;
                cfg_bls_active <= next_cfg_bls_active;
                cfg_bls_pending <= next_cfg_bls_pending;
                cfg_network_active <= next_cfg_network_active;
                cfg_network_pending <= next_cfg_network_pending;
                cfg_network_dhcp_active <= next_cfg_network_dhcp_active;
                cfg_network_dhcp_pending <= next_cfg_network_dhcp_pending;
                cfg_network_ipv4_active <= next_cfg_network_ipv4_active;
                cfg_network_ipv4_pending <= next_cfg_network_ipv4_pending;
                cfg_network_netmask_active <= next_cfg_network_netmask_active;
                cfg_network_netmask_pending <= next_cfg_network_netmask_pending;
                cfg_network_gateway_active <= next_cfg_network_gateway_active;
                cfg_network_gateway_pending <= next_cfg_network_gateway_pending;
                cfg_network_dns_active <= next_cfg_network_dns_active;
                cfg_network_dns_pending <= next_cfg_network_dns_pending;
                ui_sys_reset_req <= next_sys_reset_req;
                ui_save_reset_req <= next_save_reset_req;
                ui_cfg_apply_pending <= next_cfg_apply_pending;
                ui_cfg_apply_error <= next_cfg_apply_error;
            END IF;
        END IF;
    END PROCESS;

    --------------------------------------------------------------------
    -- SD-Konfigdatei laden/speichern
    --
    -- Die Laufzeitkonfiguration wird in /NASCOM2/N2CONF.CFG gehalten.
    -- Beim Erreichen von sd_init_done wird einmal ein Load angestossen.
    --------------------------------------------------------------------
    -- F5 hardware monitor: register snapshot and RAM editor.
    --
    -- The CPU clock enable is already suppressed by every overlay.  While
    -- page 6 is visible, the otherwise CPU-owned third T80 register-file
    -- read port and main-RAM port B can therefore be used without changing
    -- architectural state.
    --------------------------------------------------------------------
    PROCESS (clk100)
    BEGIN
        IF rising_edge(clk100) THEN
            IF sys_reset = '1' OR ui_overlay_enable = '0' OR ui_overlay_page /= "0110" OR god_run_active = '1' THEN
                god_reg_addr <= "000";
            ELSE
                CASE god_reg_addr IS
                    WHEN "000" => god_bc <= god_reg_data;
                    WHEN "001" => god_de <= god_reg_data;
                    WHEN "010" => god_hl <= god_reg_data;
                    WHEN "011" => god_iy <= god_reg_data;
                    WHEN "100" => god_bc_alt <= god_reg_data;
                    WHEN "101" => god_de_alt <= god_reg_data;
                    WHEN "110" => god_hl_alt <= god_reg_data;
                    WHEN OTHERS => god_ix <= god_reg_data;
                END CASE;
                god_reg_addr <= STD_LOGIC_VECTOR(unsigned(god_reg_addr) + 1);
            END IF;
        END IF;
    END PROCESS;

    PROCESS (clk100)
    BEGIN
        IF rising_edge(clk100) THEN
            IF sys_reset = '1' OR ui_overlay_enable = '0' OR ui_overlay_page /= "0110" OR god_run_active = '1' THEN
                god_mem_scan_index <= 0;
                god_mem_scan_phase <= 0;
            ELSE
                CASE god_mem_scan_phase IS
                    WHEN 0 =>
                        god_mem_scan_phase <= 1;
                    WHEN 1 =>
                        god_mem_scan_phase <= 2;
                    WHEN OTHERS =>
                        god_mem_snapshot((god_mem_scan_index * 8) + 7 DOWNTO god_mem_scan_index * 8) <= mainram_rd_dout;
                        god_mem_scan_phase <= 0;
                        IF god_mem_scan_index = 63 THEN
                            god_mem_scan_index <= 0;
                        ELSE
                            god_mem_scan_index <= god_mem_scan_index + 1;
                        END IF;
                END CASE;
            END IF;
        END IF;
    END PROCESS;

    --------------------------------------------------------------------
    -- Hardware debugger run control.
    --
    -- A step reaches the next opcode-fetch boundary (falling M1_n), then
    -- applies a debugger-only commit pulse. It clocks the T80's delayed
    -- architectural register writeback without advancing its microstate
    -- or starting the next bus cycle. The CPU therefore remains at the
    -- clean T1 fetch of the next PC and RAM edits take immediate effect.
    -- If the debugger was entered in the middle of an instruction, the
    -- first step finishes that instruction; all following steps execute
    -- exactly one complete instruction. Execute aborts the paused
    -- microcycle, resets the T80 to a clean T1 opcode-fetch state and
    -- loads PC/A while CEN remains low. The overlay stays open, so no
    -- instruction at the selected address runs before the next step.
    --------------------------------------------------------------------
    PROCESS (clk100)
    BEGIN
        IF rising_edge(clk100) THEN
            god_pc_load <= '0';
            god_commit <= '0';

            IF sys_reset = '1' THEN
                god_run_state <= GOD_RUN_IDLE;
                god_run_active <= '0';
                god_pc_load_data <= x"0000";
                basic_autostart_seen <= '0';
            ELSE
                CASE god_run_state IS
                    WHEN GOD_RUN_IDLE =>
                        god_run_active <= '0';
                        IF basic_autostart_seen /= basic_autostart_req THEN
                            -- F11 can be opened while the CPU is stopped in
                            -- either NAS-SYS or BASIC.  Restart directly via
                            -- the freshly restored BASIC workspace entry at
                            -- 1000h; feeding the NAS-SYS command "Z" is only
                            -- valid when NAS-SYS happens to be active.
                            basic_autostart_seen <= basic_autostart_req;
                            god_pc_load_data <= x"1000";
                            god_pc_load <= '1';
                            god_run_state <= GOD_RUN_PC_LOAD;
                        ELSIF god_exec_req = '1' THEN
                            god_pc_load_data <= god_exec_addr;
                            god_pc_load <= '1';
                            god_run_state <= GOD_RUN_PC_LOAD;
                        ELSIF god_step_req = '1' THEN
                            god_run_active <= '1';
                            IF m1_n = '0' THEN
                                god_run_state <= GOD_RUN_WAIT_HIGH;
                            ELSE
                                god_run_state <= GOD_RUN_WAIT_BOUNDARY;
                            END IF;
                        END IF;

                    WHEN GOD_RUN_WAIT_HIGH =>
                        IF m1_n = '1' THEN
                            god_run_state <= GOD_RUN_WAIT_BOUNDARY;
                        END IF;

                    WHEN GOD_RUN_WAIT_BOUNDARY =>
                        IF m1_n = '0' THEN
                            god_commit <= '1';
                            god_run_state <= GOD_RUN_WAIT_COMMIT;
                        END IF;

                    WHEN GOD_RUN_WAIT_COMMIT =>
                        god_run_active <= '0';
                        god_run_state <= GOD_RUN_IDLE;

                    WHEN GOD_RUN_PC_LOAD =>
                        god_run_active <= '0';
                        god_run_state <= GOD_RUN_IDLE;
                END CASE;
            END IF;
        END IF;
    END PROCESS;

    PROCESS (clk100)
        VARIABLE nibble_v : STD_LOGIC_VECTOR(3 DOWNTO 0);
        VARIABLE pc_page_v : UNSIGNED(15 DOWNTO 0);
    BEGIN
        IF rising_edge(clk100) THEN
            god_mem_wr <= '0';
            god_step_req <= '0';
            god_exec_req <= '0';

            IF sys_reset = '1' THEN
                god_mem_base <= x"1000";
                god_mem_cursor <= 0;
                god_mem_edit_high <= '1';
                god_mem_high_nibble <= x"0";
                god_mem_wr_addr <= x"1000";
                god_mem_wr_data <= x"00";
                god_addr_edit <= '0';
                god_addr_digit <= 0;
                god_addr_pending <= x"1000";
                god_exec_addr <= x"1000";
            ELSIF ui_overlay_enable = '0' OR ui_overlay_page /= "0110" THEN
                god_addr_edit <= '0';
            ELSIF ps2_valid = '1' AND ps2_released = '0' AND
                ui_overlay_enable = '1' AND ui_overlay_page = "0110" AND
                god_run_state = GOD_RUN_IDLE THEN
                god_mem_edit_high <= god_mem_edit_high;

                IF god_addr_edit = '1' THEN
                    IF ps2_extended = '1' THEN
                        CASE ps2_code IS
                            WHEN x"6B" => -- cursor left: previous address digit
                                IF god_addr_digit > 0 THEN
                                    god_addr_digit <= god_addr_digit - 1;
                                END IF;
                            WHEN x"74" => -- cursor right: next address digit
                                IF god_addr_digit < 3 THEN
                                    god_addr_digit <= god_addr_digit + 1;
                                END IF;
                            WHEN x"72" => -- cursor down: cancel address editing
                                god_addr_edit <= '0';
                            WHEN OTHERS =>
                                NULL;
                        END CASE;
                    ELSIF ps2_code = x"5A" THEN -- Enter: go to entered address
                        IF (cfg_cpm_active = '1' OR cfg_bls_active = '1') AND
                            unsigned(god_addr_pending) > to_unsigned(16#FFC0#, 16) THEN
                            god_mem_base <= x"FFC0";
                        ELSIF cfg_cpm_active = '1' OR cfg_bls_active = '1' THEN
                            god_mem_base <= unsigned(god_addr_pending);
                        ELSIF unsigned(god_addr_pending) < to_unsigned(16#0C00#, 16) THEN
                            god_mem_base <= x"0C00";
                        ELSIF unsigned(god_addr_pending) > to_unsigned(16#AFC0#, 16) THEN
                            god_mem_base <= x"AFC0";
                        ELSE
                            god_mem_base <= unsigned(god_addr_pending);
                        END IF;
                        god_mem_cursor <= 0;
                        god_mem_edit_high <= '1';
                        god_addr_edit <= '0';
                    ELSIF ps2_code = x"76" THEN -- Escape: cancel
                        god_addr_edit <= '0';
                    ELSIF save_hex_key(ps2_code) THEN
                        nibble_v := save_hex_nibble_from_ps2(ps2_code);
                        CASE god_addr_digit IS
                            WHEN 0 => god_addr_pending(15 DOWNTO 12) <= nibble_v;
                            WHEN 1 => god_addr_pending(11 DOWNTO 8) <= nibble_v;
                            WHEN 2 => god_addr_pending(7 DOWNTO 4) <= nibble_v;
                            WHEN OTHERS => god_addr_pending(3 DOWNTO 0) <= nibble_v;
                        END CASE;
                        IF god_addr_digit < 3 THEN
                            god_addr_digit <= god_addr_digit + 1;
                        END IF;
                    END IF;
                ELSIF ps2_extended = '1' THEN
                    CASE ps2_code IS
                        WHEN x"6B" => -- cursor left
                            IF god_mem_cursor > 0 THEN
                                god_mem_cursor <= god_mem_cursor - 1;
                            END IF;
                            god_mem_edit_high <= '1';
                        WHEN x"74" => -- cursor right
                            IF god_mem_cursor < 63 THEN
                                god_mem_cursor <= god_mem_cursor + 1;
                            END IF;
                            god_mem_edit_high <= '1';
                        WHEN x"75" => -- cursor up
                            IF god_mem_cursor >= 8 THEN
                                god_mem_cursor <= god_mem_cursor - 8;
                            ELSE
                                god_addr_pending <= STD_LOGIC_VECTOR(god_mem_base);
                                god_addr_digit <= 0;
                                god_addr_edit <= '1';
                            END IF;
                            god_mem_edit_high <= '1';
                        WHEN x"72" => -- cursor down
                            IF god_mem_cursor <= 55 THEN
                                god_mem_cursor <= god_mem_cursor + 8;
                            END IF;
                            god_mem_edit_high <= '1';
                        WHEN x"7D" => -- page up
                            IF (cfg_cpm_active = '1' OR cfg_bls_active = '1') AND
                                god_mem_base > to_unsigned(16#003F#, 16) THEN
                                god_mem_base <= god_mem_base - 64;
                            ELSIF cfg_cpm_active = '1' OR cfg_bls_active = '1' THEN
                                god_mem_base <= x"0000";
                            ELSIF god_mem_base > to_unsigned(16#0C3F#, 16) THEN
                                god_mem_base <= god_mem_base - 64;
                            ELSE
                                god_mem_base <= x"0C00";
                            END IF;
                            god_mem_edit_high <= '1';
                        WHEN x"7A" => -- page down
                            IF (cfg_cpm_active = '1' OR cfg_bls_active = '1') AND
                                god_mem_base < to_unsigned(16#FF80#, 16) THEN
                                god_mem_base <= god_mem_base + 64;
                            ELSIF cfg_cpm_active = '1' OR cfg_bls_active = '1' THEN
                                god_mem_base <= x"FFC0";
                            ELSIF god_mem_base < to_unsigned(16#AF80#, 16) THEN
                                god_mem_base <= god_mem_base + 64;
                            ELSE
                                god_mem_base <= x"AFC0";
                            END IF;
                            god_mem_edit_high <= '1';
                        WHEN x"6C" => -- Home: show the page containing PC
                            pc_page_v := unsigned(god_pc);
                            pc_page_v(5 DOWNTO 0) := (OTHERS => '0');
                            IF cfg_cpm_active = '1' OR cfg_bls_active = '1' THEN
                                god_mem_base <= pc_page_v;
                            ELSIF pc_page_v < to_unsigned(16#0C00#, 16) THEN
                                god_mem_base <= x"0C00";
                            ELSIF pc_page_v > to_unsigned(16#AFC0#, 16) THEN
                                god_mem_base <= x"AFC0";
                            ELSE
                                god_mem_base <= pc_page_v;
                            END IF;
                            god_mem_cursor <= 0;
                            god_mem_edit_high <= '1';
                        WHEN OTHERS =>
                            NULL;
                    END CASE;
                ELSIF ps2_code = x"29" THEN -- Space: execute one instruction
                    god_step_req <= '1';
                    god_mem_edit_high <= '1';
                ELSIF ps2_code = x"5A" THEN -- Enter: execute selected address
                    god_exec_addr <= STD_LOGIC_VECTOR(
                        god_mem_base + to_unsigned(god_mem_cursor, 16));
                    god_exec_req <= '1';
                    god_mem_edit_high <= '1';
                ELSIF ps2_code = x"4A" THEN -- MEGA65 minus: previous 64-byte page
                    IF (cfg_cpm_active = '1' OR cfg_bls_active = '1') AND
                        god_mem_base > to_unsigned(16#003F#, 16) THEN
                        god_mem_base <= god_mem_base - 64;
                    ELSIF cfg_cpm_active = '1' OR cfg_bls_active = '1' THEN
                        god_mem_base <= x"0000";
                    ELSIF god_mem_base > to_unsigned(16#0C3F#, 16) THEN
                        god_mem_base <= god_mem_base - 64;
                    ELSE
                        god_mem_base <= x"0C00";
                    END IF;
                    god_mem_edit_high <= '1';
                ELSIF ps2_code = x"4C" THEN -- MEGA65 plus: next 64-byte page
                    IF (cfg_cpm_active = '1' OR cfg_bls_active = '1') AND
                        god_mem_base < to_unsigned(16#FF80#, 16) THEN
                        god_mem_base <= god_mem_base + 64;
                    ELSIF cfg_cpm_active = '1' OR cfg_bls_active = '1' THEN
                        god_mem_base <= x"FFC0";
                    ELSIF god_mem_base < to_unsigned(16#AF80#, 16) THEN
                        god_mem_base <= god_mem_base + 64;
                    ELSE
                        god_mem_base <= x"AFC0";
                    END IF;
                    god_mem_edit_high <= '1';
                ELSIF save_hex_key(ps2_code) AND sd_file_mem_wr_q = '0' AND
                    basic_load_fix_state = BASIC_LOAD_FIX_IDLE THEN
                    nibble_v := save_hex_nibble_from_ps2(ps2_code);
                    IF god_mem_edit_high = '1' THEN
                        god_mem_high_nibble <= nibble_v;
                        god_mem_edit_high <= '0';
                    ELSE
                        god_mem_wr_addr <= STD_LOGIC_VECTOR(god_mem_base + to_unsigned(god_mem_cursor, 16));
                        god_mem_wr_data <= god_mem_high_nibble & nibble_v;
                        god_mem_wr <= '1';
                        god_mem_edit_high <= '1';
                        IF god_mem_cursor < 63 THEN
                            god_mem_cursor <= god_mem_cursor + 1;
                        END IF;
                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    -- Jede spaetere Aenderung an den aktiven F12-Werten markiert einen
    -- einzelnen Save-Versuch, der ausserhalb laufender SD-Operationen
    -- automatisch gestartet wird.
    --------------------------------------------------------------------
    PROCESS (clk100)
        VARIABLE speed_changed_v : BOOLEAN;
        VARIABLE rs232_changed_v : BOOLEAN;
        VARIABLE rs232_speed_changed_v : BOOLEAN;
        VARIABLE rs232_flow_changed_v : BOOLEAN;
        VARIABLE slot_changed_v : BOOLEAN;
        VARIABLE fdd_changed_v : BOOLEAN;
        VARIABLE cpm_changed_v : BOOLEAN;
        VARIABLE avc_changed_v : BOOLEAN;
        VARIABLE bls_changed_v : BOOLEAN;
        VARIABLE network_changed_v : BOOLEAN;
    BEGIN
        IF rising_edge(clk100) THEN
            sd_cfg_load_start <= '0';
            sd_cfg_save_start <= '0';
            sd_cfg_reset_req <= '0';
            -- A CPU/system reset also restarts the SD controller, but the
            -- active configuration registers intentionally survive it.  Do
            -- not schedule another N2CONF.CFG load merely because SD init is
            -- temporarily low: that could overwrite the setting which was
            -- just saved/applied and compete with the following CP/M boot.
            -- A cold FPGA start begins with sd_cfg_load_pending='1'; an actual
            -- card removal arms a fresh load for the next insertion.
            IF sd_cd_sync = '1' THEN
                sd_cfg_load_seen_this_card <= '0';
                sd_cfg_load_pending <= '1';
                sd_cfg_last_load_ok <= '0';
                sd_cfg_last_load_error <= '0';
            ELSIF sd_init_done = '0' THEN
                sd_cfg_last_load_ok <= '0';
                sd_cfg_last_load_error <= '0';
            ELSIF sd_cfg_loaded_valid = '1' THEN
                sd_cfg_load_seen_this_card <= '1';
                sd_cfg_load_pending <= '0';
                sd_cfg_last_load_ok <= '1';
                sd_cfg_last_load_error <= '0';
            ELSIF sd_cfg_load_error = '1' THEN
                sd_cfg_load_seen_this_card <= '1';
                sd_cfg_load_pending <= '0';
                sd_cfg_last_load_ok <= '0';
                sd_cfg_last_load_error <= '1';
            ELSIF sd_cfg_load_done = '1' THEN
                sd_cfg_load_seen_this_card <= '1';
                sd_cfg_load_pending <= '0';
                sd_cfg_last_load_ok <= '0';
                sd_cfg_last_load_error <= '0';
            END IF;
            IF sd_cfg_loaded_valid = '1' THEN
                sd_cfg_prev_speed <= sd_cfg_loaded_speed;
                sd_cfg_prev_phosphor_amber <= sd_cfg_loaded_phosphor_amber;
                sd_cfg_prev_scanlines <= sd_cfg_loaded_scanlines;
                sd_cfg_prev_video_zoom <= sd_cfg_loaded_video_zoom;
                sd_cfg_prev_rs232 <= sd_cfg_loaded_rs232;
                sd_cfg_prev_rs232_speed <= sd_cfg_loaded_rs232_speed;
                sd_cfg_prev_rs232_flow <= sd_cfg_loaded_rs232_flow;
                IF FAST_BUILD_TRIM_MEMORY THEN
                    sd_cfg_prev_slot_rom <= (OTHERS => '0');
                ELSE
                    sd_cfg_prev_slot_rom <= sd_cfg_loaded_slot_rom;
                END IF;
                -- CP/M implies a live FDD even when an older N2CONF.CFG
                -- still contains FDD=0.  Compare against that effective
                -- value or every config reload would request another reset.
                sd_cfg_prev_fdd <= sd_cfg_loaded_fdd OR sd_cfg_loaded_cpm;
                sd_cfg_prev_cpm <= sd_cfg_loaded_cpm;
                sd_cfg_prev_avc <= sd_cfg_loaded_avc;
                sd_cfg_prev_bls <= sd_cfg_loaded_bls;
                sd_cfg_prev_network <= sd_cfg_loaded_network;
                sd_cfg_prev_network_ipv4 <= sd_cfg_loaded_network_ipv4;
                sd_cfg_prev_network_netmask <= sd_cfg_loaded_network_netmask;
                sd_cfg_prev_network_gateway <= sd_cfg_loaded_network_gateway;
                sd_cfg_prev_network_dns <= sd_cfg_loaded_network_dns;
                sd_cfg_save_pending <= '0';
                sd_cfg_reset_pending <= '0';
            ELSIF sd_cfg_save_done = '1' THEN
                sd_cfg_prev_speed <= cfg_cpu_speed_active;
                sd_cfg_prev_phosphor_amber <= cfg_phosphor_amber_active;
                sd_cfg_prev_scanlines <= cfg_scanlines_active;
                sd_cfg_prev_video_zoom <= cfg_video_zoom_active;
                sd_cfg_prev_rs232 <= cfg_rs232_active;
                sd_cfg_prev_rs232_speed <= cfg_rs232_speed_active;
                sd_cfg_prev_rs232_flow <= cfg_rs232_flow_active;
                IF FAST_BUILD_TRIM_MEMORY THEN
                    sd_cfg_prev_slot_rom <= (OTHERS => '0');
                ELSE
                    sd_cfg_prev_slot_rom <= cfg_slot_rom_persist;
                END IF;
                sd_cfg_prev_fdd <= cfg_fdd_active;
                sd_cfg_prev_cpm <= cfg_cpm_active;
                sd_cfg_prev_avc <= cfg_avc_active;
                sd_cfg_prev_bls <= cfg_bls_active;
                sd_cfg_prev_network <= cfg_network_active;
                sd_cfg_prev_network_dhcp <= cfg_network_dhcp_active;
                sd_cfg_prev_network_ipv4 <= cfg_network_ipv4_active;
                sd_cfg_prev_network_netmask <= cfg_network_netmask_active;
                sd_cfg_prev_network_gateway <= cfg_network_gateway_active;
                sd_cfg_prev_network_dns <= cfg_network_dns_active;
                sd_cfg_save_pending <= '0';
                IF sd_cfg_reset_pending = '1' THEN
                    sd_cfg_reset_req <= '1';
                    sd_cfg_reset_pending <= '0';
                END IF;
            ELSIF sd_cfg_save_error = '1' THEN
                sd_cfg_save_pending <= '0';
                IF sd_cfg_reset_pending = '1' THEN
                    -- A failed persistence write must not leave a live
                    -- ROM/FDD/CP/M remap half-applied with the old CPU state.
                    -- Apply it for this session and reset anyway; the overlay
                    -- has already reported that N2CONF.CFG was not saved.
                    sd_cfg_reset_req <= '1';
                    sd_cfg_reset_pending <= '0';
                END IF;
            ELSE
                speed_changed_v := cfg_cpu_speed_active /= sd_cfg_prev_speed;
                rs232_changed_v := cfg_rs232_active /= sd_cfg_prev_rs232;
                rs232_speed_changed_v := cfg_rs232_speed_active /= sd_cfg_prev_rs232_speed;
                rs232_flow_changed_v := cfg_rs232_flow_active /= sd_cfg_prev_rs232_flow;
                slot_changed_v := cfg_slot_rom_persist /= sd_cfg_prev_slot_rom;
                fdd_changed_v := cfg_fdd_active /= sd_cfg_prev_fdd;
                cpm_changed_v := cfg_cpm_active /= sd_cfg_prev_cpm;
                avc_changed_v := cfg_avc_active /= sd_cfg_prev_avc;
                bls_changed_v := cfg_bls_active /= sd_cfg_prev_bls;
                network_changed_v := cfg_network_active /= sd_cfg_prev_network OR
                    cfg_network_dhcp_active /= sd_cfg_prev_network_dhcp OR
                    cfg_network_ipv4_active /= sd_cfg_prev_network_ipv4 OR
                    cfg_network_netmask_active /= sd_cfg_prev_network_netmask OR
                    cfg_network_gateway_active /= sd_cfg_prev_network_gateway OR
                    cfg_network_dns_active /= sd_cfg_prev_network_dns;

                IF speed_changed_v OR
                    cfg_phosphor_amber_active /= sd_cfg_prev_phosphor_amber OR
                    cfg_scanlines_active /= sd_cfg_prev_scanlines OR
                    cfg_video_zoom_active /= sd_cfg_prev_video_zoom OR
                    rs232_changed_v OR rs232_speed_changed_v OR rs232_flow_changed_v OR
                    slot_changed_v OR fdd_changed_v OR cpm_changed_v OR avc_changed_v OR bls_changed_v OR network_changed_v THEN
                    sd_cfg_prev_speed <= cfg_cpu_speed_active;
                    sd_cfg_prev_phosphor_amber <= cfg_phosphor_amber_active;
                    sd_cfg_prev_scanlines <= cfg_scanlines_active;
                    sd_cfg_prev_video_zoom <= cfg_video_zoom_active;
                    sd_cfg_prev_rs232 <= cfg_rs232_active;
                    sd_cfg_prev_rs232_speed <= cfg_rs232_speed_active;
                    sd_cfg_prev_rs232_flow <= cfg_rs232_flow_active;
                    sd_cfg_prev_slot_rom <= cfg_slot_rom_persist;
                    sd_cfg_prev_fdd <= cfg_fdd_active;
                    sd_cfg_prev_cpm <= cfg_cpm_active;
                    sd_cfg_prev_avc <= cfg_avc_active;
                    sd_cfg_prev_bls <= cfg_bls_active;
                    sd_cfg_prev_network <= cfg_network_active;
                    sd_cfg_prev_network_dhcp <= cfg_network_dhcp_active;
                    sd_cfg_prev_network_ipv4 <= cfg_network_ipv4_active;
                    sd_cfg_prev_network_netmask <= cfg_network_netmask_active;
                    sd_cfg_prev_network_gateway <= cfg_network_gateway_active;
                    sd_cfg_prev_network_dns <= cfg_network_dns_active;
                    sd_cfg_save_pending <= '1';
                    IF speed_changed_v OR slot_changed_v OR fdd_changed_v OR cpm_changed_v OR avc_changed_v OR bls_changed_v THEN
                        sd_cfg_reset_pending <= '1';
                    END IF;
                END IF;
            END IF;

            IF sd_init_done = '1' AND sd_browser_dir_found = '1' AND sd_cfg_load_pending = '1' AND
                sd_cfg_loaded_valid = '0' AND sd_cfg_load_done = '0' AND sd_cfg_load_error = '0' AND
                sd_cfg_load_busy = '0' AND sd_cfg_save_busy = '0' AND
                sd_read_busy = '0' AND sd_save_check_busy = '0' AND sd_save_write_busy = '0' AND
                NOT (ui_overlay_enable = '1' AND (ui_overlay_page = "0100" OR ui_overlay_page = "0101")) THEN
                sd_cfg_load_start <= '1';
            ELSIF sd_cfg_save_pending = '1' AND sd_init_done = '1' AND sd_cfg_load_pending = '0' AND
                sd_cfg_load_busy = '0' AND sd_cfg_save_busy = '0' AND
                sd_read_busy = '0' AND sd_save_check_busy = '0' AND sd_save_write_busy = '0' AND
                NOT (ui_overlay_enable = '1' AND (ui_overlay_page = "0100" OR ui_overlay_page = "0101")) THEN
                sd_cfg_save_start <= '1';
            END IF;

        END IF;
    END PROCESS;

    --------------------------------------------------------------------
    -- Browser-Seitenbasis fuer das sichtbare 10er-Fenster
    --------------------------------------------------------------------
    PROCESS (clk100)
        VARIABLE next_sd_page_base : INTEGER RANGE 0 TO SD_BROWSER_LAST_INDEX;
        VARIABLE max_page_base_v : INTEGER RANGE 0 TO SD_BROWSER_LAST_INDEX;
    BEGIN
        IF rising_edge(clk100) THEN
            IF sys_reset = '1' THEN
                ui_sd_page_base <= 0;
            ELSE
                next_sd_page_base := ui_sd_page_base;
                max_page_base_v := 0;

                IF sd_root_file_count > SD_BROWSER_PAGE_SIZE THEN
                    max_page_base_v := sd_root_file_count - SD_BROWSER_PAGE_SIZE;
                END IF;

                IF sd_read_busy = '1' THEN
                    NULL;
                ELSIF ui_overlay_enable = '1' AND ui_overlay_page = "0100" AND sd_root_file_count > 0 THEN
                    CASE ui_browser_action IS
                        WHEN BROWSE_RESET =>
                            next_sd_page_base := 0;

                        WHEN BROWSE_UP =>
                            IF ui_sd_page_row = 0 AND next_sd_page_base > 0 THEN
                                next_sd_page_base := next_sd_page_base - 1;
                            END IF;

                        WHEN BROWSE_DOWN =>
                            IF ui_sd_page_row = SD_BROWSER_PAGE_LAST AND next_sd_page_base + SD_BROWSER_PAGE_SIZE < sd_root_file_count THEN
                                next_sd_page_base := next_sd_page_base + 1;
                            END IF;

                        WHEN BROWSE_PAGE_UP =>
                            IF next_sd_page_base >= SD_BROWSER_PAGE_SIZE THEN
                                next_sd_page_base := next_sd_page_base - SD_BROWSER_PAGE_SIZE;
                            ELSE
                                next_sd_page_base := max_page_base_v;
                            END IF;

                        WHEN BROWSE_PAGE_DOWN =>
                            IF next_sd_page_base + SD_BROWSER_PAGE_SIZE < sd_root_file_count THEN
                                next_sd_page_base := next_sd_page_base + SD_BROWSER_PAGE_SIZE;
                            ELSE
                                next_sd_page_base := 0;
                            END IF;

                        WHEN OTHERS =>
                            NULL;
                    END CASE;
                ELSE
                    IF sd_read_busy = '1' THEN
                        NULL;
                    ELSIF sd_root_file_count = 0 THEN
                        next_sd_page_base := 0;
                    ELSIF next_sd_page_base > max_page_base_v THEN
                        next_sd_page_base := max_page_base_v;
                    END IF;
                END IF;

                IF next_sd_page_base > max_page_base_v THEN
                    next_sd_page_base := max_page_base_v;
                END IF;

                ui_sd_page_base <= next_sd_page_base;
            END IF;
        END IF;
    END PROCESS;

    --------------------------------------------------------------------
    -- Kleine Dateiverwaltung im SD-Browser (FAT 8.3, Basisname)
    --------------------------------------------------------------------
    ui_browser_manage_mode_code <=
        "001" WHEN ui_browser_manage_mode = BROWSER_MANAGE_RENAME_EDIT ELSE
        "010" WHEN ui_browser_manage_mode = BROWSER_MANAGE_RENAME_CONFIRM ELSE
        "011" WHEN ui_browser_manage_mode = BROWSER_MANAGE_DELETE_CONFIRM ELSE
        "100" WHEN ui_browser_manage_mode = BROWSER_MANAGE_BUSY ELSE
        "101" WHEN ui_browser_manage_mode = BROWSER_MANAGE_RESULT ELSE
        "000";

    PROCESS (clk100)
        VARIABLE name_v : STD_LOGIC_VECTOR(63 DOWNTO 0);
        VARIABLE name_len_v : INTEGER RANGE 0 TO 8;
        VARIABLE ch_v : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE mounted_v : BOOLEAN;
    BEGIN
        IF rising_edge(clk100) THEN
            ui_browser_manage_start <= '0';

            IF sys_reset = '1' THEN
                ui_browser_manage_mode <= BROWSER_MANAGE_IDLE;
                ui_browser_manage_name <= x"2020202020202020";
                ui_browser_manage_name_len <= 0;
                ui_browser_manage_old_name <= (OTHERS => '0');
                ui_browser_manage_new_name <= (OTHERS => '0');
                ui_browser_manage_delete <= '0';
            ELSE
                mounted_v :=
                    (fdd_mount_a_valid = '1' AND fdd_mount_a_name = sd_selected_name) OR
                    (fdd_mount_b_valid = '1' AND fdd_mount_b_name = sd_selected_name);

                IF ui_browser_manage_mode = BROWSER_MANAGE_BUSY THEN
                    IF sd_manage_done = '1' THEN
                        ui_browser_manage_mode <= BROWSER_MANAGE_IDLE;
                    ELSIF sd_manage_error = '1' THEN
                        ui_browser_manage_mode <= BROWSER_MANAGE_RESULT;
                    END IF;
                ELSIF ui_overlay_enable = '0' OR ui_overlay_page /= "0100" THEN
                    ui_browser_manage_mode <= BROWSER_MANAGE_IDLE;
                ELSIF ps2_valid = '1' AND ps2_released = '0' THEN
                    CASE ui_browser_manage_mode IS
                        WHEN BROWSER_MANAGE_IDLE =>
                            IF sd_selected_valid = '1' AND sd_read_busy = '0' AND
                                sd_manage_busy = '0' AND NOT mounted_v THEN
                                IF ps2_extended = '0' AND ps2_code = x"2D" THEN
                                    name_v := sd_selected_name(87 DOWNTO 24);
                                    name_len_v := 0;
                                    FOR i IN 0 TO 7 LOOP
                                        IF name_v(63 - (i * 8) DOWNTO 56 - (i * 8)) /= x"20" THEN
                                            name_len_v := i + 1;
                                        END IF;
                                    END LOOP;
                                    ui_browser_manage_name <= name_v;
                                    ui_browser_manage_name_len <= name_len_v;
                                    ui_browser_manage_old_name <= sd_selected_name;
                                    ui_browser_manage_mode <= BROWSER_MANAGE_RENAME_EDIT;
                                ELSIF (ps2_extended = '0' AND ps2_code = x"66") OR
                                    (ps2_extended = '1' AND ps2_code = x"71") THEN
                                    ui_browser_manage_old_name <= sd_selected_name;
                                    ui_browser_manage_mode <= BROWSER_MANAGE_DELETE_CONFIRM;
                                END IF;
                            END IF;

                        WHEN BROWSER_MANAGE_RENAME_EDIT =>
                            name_v := ui_browser_manage_name;
                            name_len_v := ui_browser_manage_name_len;
                            IF ps2_code = x"76" THEN
                                ui_browser_manage_mode <= BROWSER_MANAGE_IDLE;
                            ELSIF ps2_code = x"66" THEN
                                IF name_len_v > 0 THEN
                                    name_len_v := name_len_v - 1;
                                    name_v(63 - (name_len_v * 8) DOWNTO 56 - (name_len_v * 8)) := x"20";
                                    ui_browser_manage_name <= name_v;
                                    ui_browser_manage_name_len <= name_len_v;
                                END IF;
                            ELSIF ps2_code = x"5A" THEN
                                IF name_len_v > 0 THEN
                                    ui_browser_manage_new_name <= name_v & ui_browser_manage_old_name(23 DOWNTO 0);
                                    ui_browser_manage_mode <= BROWSER_MANAGE_RENAME_CONFIRM;
                                END IF;
                            ELSIF ps2_extended = '0' THEN
                                ch_v := save_name_char_from_ps2(ps2_code);
                                IF ch_v /= x"20" AND name_len_v < 8 THEN
                                    name_v(63 - (name_len_v * 8) DOWNTO 56 - (name_len_v * 8)) := ch_v;
                                    ui_browser_manage_name <= name_v;
                                    ui_browser_manage_name_len <= name_len_v + 1;
                                END IF;
                            END IF;

                        WHEN BROWSER_MANAGE_RENAME_CONFIRM =>
                            IF ps2_extended = '0' AND ps2_code = x"35" THEN
                                ui_browser_manage_delete <= '0';
                                ui_browser_manage_start <= '1';
                                ui_browser_manage_mode <= BROWSER_MANAGE_BUSY;
                            ELSIF ps2_code = x"76" OR
                                (ps2_extended = '0' AND ps2_code = x"31") THEN
                                ui_browser_manage_mode <= BROWSER_MANAGE_IDLE;
                            END IF;

                        WHEN BROWSER_MANAGE_DELETE_CONFIRM =>
                            IF ps2_extended = '0' AND ps2_code = x"35" THEN
                                ui_browser_manage_delete <= '1';
                                ui_browser_manage_new_name <= ui_browser_manage_old_name;
                                ui_browser_manage_start <= '1';
                                ui_browser_manage_mode <= BROWSER_MANAGE_BUSY;
                            ELSIF ps2_code = x"76" OR
                                (ps2_extended = '0' AND ps2_code = x"31") THEN
                                ui_browser_manage_mode <= BROWSER_MANAGE_IDLE;
                            END IF;

                        WHEN BROWSER_MANAGE_RESULT =>
                            IF ps2_code = x"5A" OR ps2_code = x"76" THEN
                                ui_browser_manage_mode <= BROWSER_MANAGE_IDLE;
                            END IF;

                        WHEN OTHERS =>
                            NULL;
                    END CASE;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    --------------------------------------------------------------------
    -- Browser-Zeilen-Cursor und Startpuls fuer Datei-Ladevorgaenge
    --------------------------------------------------------------------
    PROCESS (clk100)
        VARIABLE next_sd_page_row : INTEGER RANGE 0 TO SD_BROWSER_PAGE_LAST;
    BEGIN
        IF rising_edge(clk100) THEN
            ui_sd_file_read_start <= '0';

            IF sd_cd_sync = '1' THEN
                fdd_mount_a_valid <= '0';
                fdd_mount_b_valid <= '0';
                fdd_mount_a_name <= (OTHERS => '0');
                fdd_mount_b_name <= (OTHERS => '0');
                fdd_mount_a_cluster <= (OTHERS => '0');
                fdd_mount_b_cluster <= (OTHERS => '0');
            END IF;

            IF fdd_format_done = '1' THEN
                IF fdc_track_drive_b = '0' THEN
                    fdd_mount_a_cluster <= fdd_format_new_cluster;
                ELSE
                    fdd_mount_b_cluster <= fdd_format_new_cluster;
                END IF;
            END IF;

            IF sys_reset = '1' THEN
                ui_sd_page_row <= 0;
            ELSE
                next_sd_page_row := ui_sd_page_row;

                IF sd_read_busy = '1' THEN
                    NULL;
                ELSIF sd_root_file_count = 0 THEN
                    next_sd_page_row := 0;
                ELSIF sd_root_file_count <= SD_BROWSER_PAGE_SIZE AND next_sd_page_row >= sd_root_file_count THEN
                    next_sd_page_row := sd_root_file_count - 1;
                ELSIF ui_overlay_enable = '1' AND ui_overlay_page = "0100" THEN
                    CASE ui_browser_action IS
                        WHEN BROWSE_RESET =>
                            next_sd_page_row := 0;

                        WHEN BROWSE_UP =>
                            IF next_sd_page_row > 0 THEN
                                next_sd_page_row := next_sd_page_row - 1;
                            END IF;

                        WHEN BROWSE_DOWN =>
                            IF next_sd_page_row < SD_BROWSER_PAGE_LAST THEN
                                IF sd_root_file_count > SD_BROWSER_PAGE_SIZE OR next_sd_page_row + 1 < sd_root_file_count THEN
                                    next_sd_page_row := next_sd_page_row + 1;
                                END IF;
                            END IF;

                        WHEN BROWSE_PAGE_UP =>
                            next_sd_page_row := 0;

                        WHEN BROWSE_PAGE_DOWN =>
                            next_sd_page_row := 0;

                        WHEN BROWSE_LOAD =>
                            IF sd_selected_valid = '1' THEN
                                IF sd_selected_is_dsk = '1' AND sd_selected_size = x"000A0000" THEN
                                    IF nk_sh = '1' THEN
                                        IF fdd_mount_b_valid = '1' AND
                                            fdd_mount_b_cluster = sd_selected_cluster THEN
                                            fdd_mount_b_valid <= '0';
                                            fdd_mount_b_name <= (OTHERS => '0');
                                            fdd_mount_b_cluster <= (OTHERS => '0');
                                        ELSE
                                            fdd_mount_b_valid <= '1';
                                            fdd_mount_b_name <= sd_selected_name;
                                            fdd_mount_b_cluster <= sd_selected_cluster;
                                        END IF;
                                    ELSE
                                        IF fdd_mount_a_valid = '1' AND
                                            fdd_mount_a_cluster = sd_selected_cluster THEN
                                            fdd_mount_a_valid <= '0';
                                            fdd_mount_a_name <= (OTHERS => '0');
                                            fdd_mount_a_cluster <= (OTHERS => '0');
                                        ELSE
                                            fdd_mount_a_valid <= '1';
                                            fdd_mount_a_name <= sd_selected_name;
                                            fdd_mount_a_cluster <= sd_selected_cluster;
                                        END IF;
                                    END IF;
                                ELSE
                                    ui_sd_file_read_start <= '1';
                                END IF;
                            END IF;

                        WHEN OTHERS =>
                            NULL;
                    END CASE;
                END IF;

                ui_sd_page_row <= next_sd_page_row;
            END IF;
        END IF;
    END PROCESS;

    --------------------------------------------------------------------
    -- BASIC-Erkennung ueber die bekannten Schattenregister im RAM
    --------------------------------------------------------------------
    PROCESS (clk100)
        VARIABLE basic_end_ptr_v : UNSIGNED(15 DOWNTO 0);
    BEGIN
        IF rising_edge(clk100) THEN
            IF sys_reset = '1' THEN
                ui_save_basic_available <= '0';
                ui_save_basic_ready <= '0';
                ui_save_basic_start_addr <= x"10FA";
                ui_save_basic_end_addr <= x"10FA";
            ELSE
                ui_save_basic_start_addr <= x"10FA";

                IF basic_init_lo_shadow = x"FA" AND basic_init_hi_shadow = x"10" THEN
                    ui_save_basic_available <= '1';
                    basic_end_ptr_v(15 DOWNTO 8) := unsigned(basic_endptr_hi_shadow);
                    basic_end_ptr_v(7 DOWNTO 0) := unsigned(basic_endptr_lo_shadow);
                    IF basic_end_ptr_v > to_unsigned(16#10FC#, 16) THEN
                        ui_save_basic_ready <= '1';
                        ui_save_basic_end_addr <= STD_LOGIC_VECTOR(basic_end_ptr_v - 1);
                    ELSE
                        ui_save_basic_ready <= '0';
                        ui_save_basic_end_addr <= x"10FA";
                    END IF;
                ELSE
                    ui_save_basic_available <= '0';
                    ui_save_basic_ready <= '0';
                    ui_save_basic_end_addr <= x"10FA";
                END IF;
            END IF;
        END IF;
    END PROCESS;

    --------------------------------------------------------------------
    -- AY-3-8910 fixed 2 MHz clock and direct NAS-BUS style I/O ports.
    --   OUT 08h,register  selects one of the sixteen AY registers
    --   OUT 09h,data      writes the selected register
    --   IN  09h           reads the selected register
    --------------------------------------------------------------------
    -- The joystick contacts are asynchronous to clk100. Bits 0..4 are
    -- Up, Down, Left, Right and Fire respectively, all active low.
    PROCESS (clk100)
    BEGIN
        IF rising_edge(clk100) THEN
            joystick_a_meta <= joystick_a_n_i;
            joystick_a_sync <= joystick_a_meta;
            joystick_b_meta <= joystick_b_n_i;
            joystick_b_sync <= joystick_b_meta;
        END IF;
    END PROCESS;

    PROCESS (clk100)
        VARIABLE ay_io_write_now_v : STD_LOGIC;
    BEGIN
        IF rising_edge(clk100) THEN
            ay_clock_enable_2mhz <= '0';
            ay_register_select_write <= '0';
            ay_register_data_write <= '0';

            IF sys_reset = '1' THEN
                ay_clock_divider <= 0;
                ay_io_write_last <= '0';
            ELSE
                IF ay_clock_divider = 49 THEN
                    ay_clock_divider <= 0;
                    ay_clock_enable_2mhz <= '1';
                ELSE
                    ay_clock_divider <= ay_clock_divider + 1;
                END IF;

                ay_io_write_now_v := '0';
                IF iorq_n = '0' AND wr_n = '0' AND
                    (cpu_a(7 DOWNTO 0) = x"08" OR cpu_a(7 DOWNTO 0) = x"09") THEN
                    ay_io_write_now_v := '1';
                END IF;

                IF ay_io_write_now_v = '1' AND ay_io_write_last = '0' THEN
                    IF cpu_a(7 DOWNTO 0) = x"08" THEN
                        ay_register_select_write <= '1';
                    ELSE
                        ay_register_data_write <= '1';
                    END IF;
                END IF;
                ay_io_write_last <= ay_io_write_now_v;
            END IF;
        END IF;
    END PROCESS;

    u_ay_3_8910 : ENTITY work.ay_3_8910
        PORT MAP(
            clk => clk100,
            reset => sys_reset,
            clock_enable_2mhz => ay_clock_enable_2mhz,
            register_select_write => ay_register_select_write,
            register_data_write => ay_register_data_write,
            data_in => cpu_do,
            data_out => ay_register_data,
            port_a_in => "111" & joystick_a_sync,
            port_b_in => "111" & joystick_b_sync,
            pcm_out => ay_pcm
        );

    -- The MEGA65 audio jack includes analogue reconstruction filters for
    -- these one-bit streams. The AY mix is mono, so drive both channels.
    u_audio_pdm : ENTITY work.pcm_to_pdm
        PORT MAP (
            clk => clk100,
            reset => sys_reset,
            pcm_l => ay_pcm,
            pcm_r => ay_pcm,
            pdm_l => audio_pdm_l,
            pdm_r => audio_pdm_r
        );

    audio_pcm_o <= ay_pcm;

    --------------------------------------------------------------------
    -- BLS-Pascal-Erkennung ueber den Textende-Zeiger bei 0C82/0C83
    --------------------------------------------------------------------
    PROCESS (clk100)
        VARIABLE bls_text_end_v : UNSIGNED(15 DOWNTO 0);
    BEGIN
        IF rising_edge(clk100) THEN
            ui_save_bls_start_addr <= BLS_LOAD_START_ADDR;

            bls_text_end_v(15 DOWNTO 8) := unsigned(bls_text_end_hi_shadow);
            bls_text_end_v(7 DOWNTO 0) := unsigned(bls_text_end_lo_shadow);

            IF cfg_bls_active = '1' THEN
                ui_save_bls_available <= '1';
                IF bls_text_end_v > unsigned(BLS_LOAD_START_ADDR) AND
                    bls_text_end_v < BLS_LOAD_LIMIT_ADDR THEN
                    ui_save_bls_ready <= '1';
                    ui_save_bls_end_addr <= STD_LOGIC_VECTOR(bls_text_end_v);
                ELSE
                    ui_save_bls_ready <= '0';
                    ui_save_bls_end_addr <= BLS_LOAD_START_ADDR;
                END IF;
            ELSE
                ui_save_bls_available <= '0';
                ui_save_bls_ready <= '0';
                ui_save_bls_end_addr <= BLS_LOAD_START_ADDR;
            END IF;
        END IF;
    END PROCESS;

    --------------------------------------------------------------------
    -- Effektiver Save-Bereich aus manuellem Bereich, BASIC oder BLS Pascal
    --------------------------------------------------------------------
    PROCESS (clk100)
        VARIABLE eff_start_v : UNSIGNED(15 DOWNTO 0);
        VARIABLE eff_end_v : UNSIGNED(15 DOWNTO 0);
        VARIABLE eff_len_v : UNSIGNED(15 DOWNTO 0);
    BEGIN
        IF rising_edge(clk100) THEN
            IF ui_save_mode_bls = '1' AND ui_save_bls_ready = '1' THEN
                eff_start_v := unsigned(ui_save_bls_start_addr);
                eff_end_v := unsigned(ui_save_bls_end_addr);
            ELSIF ui_save_mode_basic = '1' AND ui_save_basic_ready = '1' THEN
                eff_start_v := unsigned(ui_save_basic_start_addr);
                eff_end_v := unsigned(ui_save_basic_end_addr);
            ELSE
                eff_start_v := unsigned(ui_save_start_addr_manual);
                eff_end_v := unsigned(ui_save_end_addr_manual);
            END IF;

            ui_save_effective_start_addr <= STD_LOGIC_VECTOR(eff_start_v);
            ui_save_effective_end_addr <= STD_LOGIC_VECTOR(eff_end_v);

            IF eff_end_v >= eff_start_v THEN
                eff_len_v := eff_end_v - eff_start_v + 1;
            ELSE
                eff_len_v := (OTHERS => '0');
            END IF;
            ui_save_effective_len <= STD_LOGIC_VECTOR(eff_len_v);
        END IF;
    END PROCESS;

    --------------------------------------------------------------------
    -- F9-Overlay-Zustandsmaschine fuer Name, Bereich und Save-Aktionen
    --------------------------------------------------------------------
    PROCESS (clk100)
        VARIABLE next_name_v : STD_LOGIC_VECTOR(63 DOWNTO 0);
        VARIABLE next_name_len_v : INTEGER RANGE 0 TO 8;
        VARIABLE next_row_sel_v : INTEGER RANGE 0 TO 4;
        VARIABLE next_start_addr_digit_v : INTEGER RANGE 0 TO 3;
        VARIABLE next_end_addr_digit_v : INTEGER RANGE 0 TO 3;
        VARIABLE next_mode_basic_v : STD_LOGIC;
        VARIABLE next_mode_bls_v : STD_LOGIC;
        VARIABLE next_start_v : STD_LOGIC_VECTOR(15 DOWNTO 0);
        VARIABLE next_end_v : STD_LOGIC_VECTOR(15 DOWNTO 0);
        VARIABLE next_checked_v : STD_LOGIC;
        VARIABLE next_name_exists_v : STD_LOGIC;
        VARIABLE next_overwrite_confirmed_v : STD_LOGIC;
        VARIABLE next_ready_to_write_v : STD_LOGIC;
        VARIABLE next_write_after_check_v : STD_LOGIC;
        VARIABLE start_check_v : STD_LOGIC;
        VARIABLE clear_status_v : STD_LOGIC;
        VARIABLE start_write_v : STD_LOGIC;
        VARIABLE sd_save_backend_idle_v : BOOLEAN;
        VARIABLE invalidate_check_v : BOOLEAN;
        VARIABLE ch_v : STD_LOGIC_VECTOR(7 DOWNTO 0);
    BEGIN
        IF rising_edge(clk100) THEN
            ui_save_check_start <= '0';
            ui_save_status_clear <= '0';
            ui_save_write_start <= '0';
            IF sys_reset = '1' OR ui_save_reset_req = '1' THEN
                -- Opening F9 resets the edit form.  The backend separately
                -- clears a stale successful WRITE DONE via save_done_clear,
                -- but keeps a persistent SD/FDD error visible.  A machine
                -- reset clears the complete saved status.
                IF sys_reset = '1' THEN
                    ui_save_status_clear <= '1';
                END IF;
                ui_save_row_sel <= 0;
                ui_save_name <= x"2020202020202020";
                ui_save_name_len <= 0;
                ui_save_mode_bls <= ui_save_bls_ready;
                ui_save_mode_basic <= ui_save_basic_ready AND NOT ui_save_bls_ready;
                ui_save_start_addr_digit <= 0;
                ui_save_end_addr_digit <= 0;
                ui_save_start_addr_manual <= x"0C00";
                ui_save_end_addr_manual <= x"1FFF";
                ui_save_checked <= '0';
                ui_save_name_exists <= '0';
                ui_save_overwrite_confirmed <= '0';
                ui_save_ready_to_write <= '0';
                ui_save_write_after_check <= '0';
            ELSE
                next_name_v := ui_save_name;
                next_name_len_v := ui_save_name_len;
                next_row_sel_v := ui_save_row_sel;
                next_start_addr_digit_v := ui_save_start_addr_digit;
                next_end_addr_digit_v := ui_save_end_addr_digit;
                next_mode_basic_v := ui_save_mode_basic;
                next_mode_bls_v := ui_save_mode_bls;
                next_start_v := ui_save_start_addr_manual;
                next_end_v := ui_save_end_addr_manual;
                next_checked_v := ui_save_checked;
                next_name_exists_v := ui_save_name_exists;
                next_overwrite_confirmed_v := ui_save_overwrite_confirmed;
                next_ready_to_write_v := ui_save_ready_to_write;
                next_write_after_check_v := ui_save_write_after_check;
                start_check_v := '0';
                clear_status_v := '0';
                start_write_v := '0';
                sd_save_backend_idle_v :=
                    sd_read_busy = '0' AND
                    sd_save_check_busy = '0' AND
                    sd_save_write_busy = '0' AND
                    sd_cfg_load_busy = '0' AND
                    sd_cfg_save_busy = '0';
                invalidate_check_v := FALSE;

                IF sd_save_check_done = '1' THEN
                    next_checked_v := '1';
                    next_name_exists_v := sd_save_check_exists;
                    next_overwrite_confirmed_v := '0';
                    next_ready_to_write_v := '0';
                    IF next_write_after_check_v = '1' THEN
                        IF sd_save_check_exists = '1' OR
                            (sd_save_check_can_create = '1' AND
                            sd_save_check_can_allocate = '1' AND
                            sd_save_check_requires_dir_growth = '0') THEN
                            -- The save-check pulse arrives while the SD backend is still
                            -- finishing its return path to ST_READ_READY. Arm the actual
                            -- write here and fire it one clean cycle later.
                            next_ready_to_write_v := '1';
                        ELSE
                            next_write_after_check_v := '0';
                        END IF;
                    END IF;
                END IF;

                IF sd_save_write_busy = '1' THEN
                    next_ready_to_write_v := '0';
                END IF;

                IF (sd_save_write_done = '1' OR sd_save_write_error = '1') AND
                    (ui_save_write_after_check = '1' OR
                     ui_save_ready_to_write = '1' OR
                     sd_save_write_busy = '1') THEN
                    next_ready_to_write_v := '0';
                    next_write_after_check_v := '0';
                END IF;

                IF next_write_after_check_v = '1' AND next_ready_to_write_v = '1' AND
                    sd_save_check_done = '0' AND sd_save_backend_idle_v THEN
                    start_write_v := '1';
                END IF;
                IF next_mode_basic_v = '1' AND ui_save_basic_ready = '0' THEN
                    next_mode_basic_v := '0';
                    invalidate_check_v := TRUE;
                END IF;
                IF next_mode_bls_v = '1' AND ui_save_bls_ready = '0' THEN
                    next_mode_bls_v := '0';
                    invalidate_check_v := TRUE;
                END IF;

                IF ui_overlay_enable = '1' AND ui_overlay_page = "0101" AND ps2_valid = '1' AND ps2_released = '0' THEN
                    CASE ps2_code IS
                        WHEN x"75" =>
                            IF next_row_sel_v > 0 THEN
                                next_row_sel_v := next_row_sel_v - 1;
                            END IF;

                        WHEN x"72" =>
                            IF next_row_sel_v < 4 THEN
                                next_row_sel_v := next_row_sel_v + 1;
                            END IF;

                        WHEN x"6B" =>
                            IF next_row_sel_v = 1 AND
                                (ui_save_basic_available = '1' OR ui_save_bls_available = '1') THEN
                                next_mode_basic_v := '0';
                                next_mode_bls_v := '0';
                                invalidate_check_v := TRUE;
                            ELSIF (next_row_sel_v = 2 OR next_row_sel_v = 3) AND
                                next_mode_basic_v = '0' AND next_mode_bls_v = '0' THEN
                                IF next_row_sel_v = 2 THEN
                                    IF next_start_addr_digit_v > 0 THEN
                                        next_start_addr_digit_v := next_start_addr_digit_v - 1;
                                    END IF;
                                ELSE
                                    IF next_end_addr_digit_v > 0 THEN
                                        next_end_addr_digit_v := next_end_addr_digit_v - 1;
                                    END IF;
                                END IF;
                            END IF;

                        WHEN x"74" =>
                            IF next_row_sel_v = 1 AND
                                (ui_save_basic_available = '1' OR ui_save_bls_available = '1') THEN
                                IF ui_save_bls_ready = '1' THEN
                                    next_mode_bls_v := '1';
                                    next_mode_basic_v := '0';
                                    invalidate_check_v := TRUE;
                                ELSIF ui_save_basic_ready = '1' THEN
                                    next_mode_basic_v := '1';
                                    next_mode_bls_v := '0';
                                    invalidate_check_v := TRUE;
                                END IF;
                            ELSIF (next_row_sel_v = 2 OR next_row_sel_v = 3) AND
                                next_mode_basic_v = '0' AND next_mode_bls_v = '0' THEN
                                IF next_row_sel_v = 2 THEN
                                    IF next_start_addr_digit_v < 3 THEN
                                        next_start_addr_digit_v := next_start_addr_digit_v + 1;
                                    END IF;
                                ELSE
                                    IF next_end_addr_digit_v < 3 THEN
                                        next_end_addr_digit_v := next_end_addr_digit_v + 1;
                                    END IF;
                                END IF;
                            END IF;

                        WHEN x"66" =>
                            IF next_row_sel_v = 0 THEN
                                IF next_name_len_v > 0 THEN
                                    next_name_len_v := next_name_len_v - 1;
                                    next_name_v((7 - next_name_len_v) * 8 + 7 DOWNTO (7 - next_name_len_v) * 8) := x"20";
                                    invalidate_check_v := TRUE;
                                END IF;
                            ELSIF (next_row_sel_v = 2 OR next_row_sel_v = 3) AND
                                next_mode_basic_v = '0' AND next_mode_bls_v = '0' THEN
                                IF next_row_sel_v = 2 THEN
                                    CASE next_start_addr_digit_v IS
                                        WHEN 0 => next_start_v(15 DOWNTO 12) := x"0";
                                        WHEN 1 => next_start_v(11 DOWNTO 8) := x"0";
                                        WHEN 2 => next_start_v(7 DOWNTO 4) := x"0";
                                        WHEN OTHERS => next_start_v(3 DOWNTO 0) := x"0";
                                    END CASE;
                                ELSE
                                    CASE next_end_addr_digit_v IS
                                        WHEN 0 => next_end_v(15 DOWNTO 12) := x"0";
                                        WHEN 1 => next_end_v(11 DOWNTO 8) := x"0";
                                        WHEN 2 => next_end_v(7 DOWNTO 4) := x"0";
                                        WHEN OTHERS => next_end_v(3 DOWNTO 0) := x"0";
                                    END CASE;
                                END IF;
                                invalidate_check_v := TRUE;
                                IF next_row_sel_v = 2 THEN
                                    IF next_start_addr_digit_v > 0 THEN
                                        next_start_addr_digit_v := next_start_addr_digit_v - 1;
                                    END IF;
                                ELSE
                                    IF next_end_addr_digit_v > 0 THEN
                                        next_end_addr_digit_v := next_end_addr_digit_v - 1;
                                    END IF;
                                END IF;
                            END IF;

                        WHEN x"5A" =>
                            IF next_row_sel_v = 4 AND sd_init_done = '1' AND sd_save_backend_idle_v THEN
                                IF next_name_len_v > 0 AND
                                    (next_mode_basic_v = '1' OR next_mode_bls_v = '1' OR
                                    UNSIGNED(next_end_v) >= UNSIGNED(next_start_v)) THEN
                                    IF next_ready_to_write_v = '1' THEN
                                        start_write_v := '1';
                                    ELSIF next_checked_v = '1' THEN
                                        IF next_name_exists_v = '1' OR
                                            (sd_save_check_can_create = '1' AND
                                            sd_save_check_can_allocate = '1' AND
                                            sd_save_check_requires_dir_growth = '0') THEN
                                            start_write_v := '1';
                                        ELSE
                                            next_ready_to_write_v := '0';
                                        END IF;
                                    ELSE
                                        start_check_v := '1';
                                        next_checked_v := '0';
                                        next_name_exists_v := '0';
                                        next_overwrite_confirmed_v := '0';
                                        next_ready_to_write_v := '0';
                                        next_write_after_check_v := '1';
                                        clear_status_v := '1';
                                    END IF;
                                END IF;
                            END IF;

                        WHEN OTHERS =>
                            IF next_row_sel_v = 0 THEN
                                ch_v := save_name_char_from_ps2(ps2_code);
                                IF ch_v /= x"20" AND next_name_len_v < 8 THEN
                                    next_name_v((7 - next_name_len_v) * 8 + 7 DOWNTO (7 - next_name_len_v) * 8) := ch_v;
                                    next_name_len_v := next_name_len_v + 1;
                                    invalidate_check_v := TRUE;
                                END IF;
                            ELSIF (next_row_sel_v = 2 OR next_row_sel_v = 3) AND
                                next_mode_basic_v = '0' AND next_mode_bls_v = '0' AND save_hex_key(ps2_code) THEN
                                IF next_row_sel_v = 2 THEN
                                    CASE next_start_addr_digit_v IS
                                        WHEN 0 => next_start_v(15 DOWNTO 12) := save_hex_nibble_from_ps2(ps2_code);
                                        WHEN 1 => next_start_v(11 DOWNTO 8) := save_hex_nibble_from_ps2(ps2_code);
                                        WHEN 2 => next_start_v(7 DOWNTO 4) := save_hex_nibble_from_ps2(ps2_code);
                                        WHEN OTHERS => next_start_v(3 DOWNTO 0) := save_hex_nibble_from_ps2(ps2_code);
                                    END CASE;
                                ELSE
                                    CASE next_end_addr_digit_v IS
                                        WHEN 0 => next_end_v(15 DOWNTO 12) := save_hex_nibble_from_ps2(ps2_code);
                                        WHEN 1 => next_end_v(11 DOWNTO 8) := save_hex_nibble_from_ps2(ps2_code);
                                        WHEN 2 => next_end_v(7 DOWNTO 4) := save_hex_nibble_from_ps2(ps2_code);
                                        WHEN OTHERS => next_end_v(3 DOWNTO 0) := save_hex_nibble_from_ps2(ps2_code);
                                    END CASE;
                                END IF;
                                invalidate_check_v := TRUE;

                                IF next_row_sel_v = 2 THEN
                                    IF next_start_addr_digit_v < 3 THEN
                                        next_start_addr_digit_v := next_start_addr_digit_v + 1;
                                    END IF;
                                ELSE
                                    IF next_end_addr_digit_v < 3 THEN
                                        next_end_addr_digit_v := next_end_addr_digit_v + 1;
                                    END IF;
                                END IF;
                            END IF;
                    END CASE;
                END IF;

                IF invalidate_check_v THEN
                    next_checked_v := '0';
                    next_name_exists_v := '0';
                    next_overwrite_confirmed_v := '0';
                    next_ready_to_write_v := '0';
                    next_write_after_check_v := '0';
                    clear_status_v := '1';
                END IF;

                ui_save_row_sel <= next_row_sel_v;
                ui_save_name <= next_name_v;
                ui_save_name_len <= next_name_len_v;
                ui_save_mode_basic <= next_mode_basic_v;
                ui_save_mode_bls <= next_mode_bls_v;
                ui_save_start_addr_digit <= next_start_addr_digit_v;
                ui_save_end_addr_digit <= next_end_addr_digit_v;
                ui_save_start_addr_manual <= next_start_v;
                ui_save_end_addr_manual <= next_end_v;
                ui_save_check_start <= start_check_v;
                ui_save_status_clear <= clear_status_v;
                ui_save_write_start <= start_write_v;
                ui_save_checked <= next_checked_v;
                ui_save_name_exists <= next_name_exists_v;
                ui_save_overwrite_confirmed <= next_overwrite_confirmed_v;
                ui_save_ready_to_write <= next_ready_to_write_v;
                ui_save_write_after_check <= next_write_after_check_v;
            END IF;
        END IF;
    END PROCESS;

    --------------------------------------------------------------------
    -- Speicher-Lese-Mux fuer den Save-Formatter
    --------------------------------------------------------------------
    PROCESS (ALL)
    BEGIN
        sd_save_mem_data_comb <= x"00";

        CASE sd_save_mem_addr(15 DOWNTO 12) IS
            WHEN x"0" =>
                IF cfg_cpm_active = '1' AND cpm_low_ram_enabled = '1' THEN
                    sd_save_mem_data_comb <= mainram_rd_dout;
                ELSIF cfg_cpm_active = '1' AND sd_save_mem_addr(11) = '0' THEN
                    sd_save_mem_data_comb <= CPM_BOOT_ROM(to_integer(unsigned(sd_save_mem_addr(10 DOWNTO 0))));
                ELSIF sd_save_mem_addr(11) = '0' THEN
                    sd_save_mem_data_comb <= ROM(to_integer(unsigned(sd_save_mem_addr(10 DOWNTO 0))));
                ELSIF sd_save_mem_addr(11 DOWNTO 10) = "10" THEN
                    sd_save_mem_data_comb <= x"20";
                ELSE
                    sd_save_mem_data_comb <= mainram_rd_dout;
                END IF;

            WHEN x"1" | x"2" | x"3" | x"4" | x"5" | x"6" | x"7" | x"8" | x"9" =>
                IF NOT FAST_BUILD_TRIM_MEMORY THEN
                    sd_save_mem_data_comb <= mainram_rd_dout;
                END IF;

            WHEN x"A" =>
                IF NOT FAST_BUILD_TRIM_MEMORY THEN
                    IF cfg_bls_active = '1' THEN
                        sd_save_mem_data_comb <= BLS_PASCAL_ROM(to_integer(unsigned(sd_save_mem_addr) - BLS_PASCAL_BASE));
                    ELSE
                        sd_save_mem_data_comb <= mainram_rd_dout;
                    END IF;
                END IF;

            WHEN x"B" =>
                IF NOT FAST_BUILD_TRIM_MEMORY THEN
                    IF cfg_bls_active = '1' THEN
                        sd_save_mem_data_comb <= BLS_PASCAL_ROM(to_integer(unsigned(sd_save_mem_addr) - BLS_PASCAL_BASE));
                    ELSIF cfg_cpm_active = '1' THEN
                        sd_save_mem_data_comb <= mainram_rd_dout;
                    ELSIF sd_save_mem_addr(11) = '0' THEN
                        IF cfg_slot_rom_active(0) = '1' THEN
                            sd_save_mem_data_comb <= TOOLKIT_ROM(to_integer(unsigned(sd_save_mem_addr) - TOOLKIT_BASE));
                        ELSE
                            sd_save_mem_data_comb <= TOOLKIT_RAM(to_integer(unsigned(sd_save_mem_addr) - TOOLKIT_BASE));
                        END IF;
                    ELSE
                        IF cfg_slot_rom_active(1) = '1' THEN
                            sd_save_mem_data_comb <= NASPEN_ROM(to_integer(unsigned(sd_save_mem_addr) - NASPEN_BASE));
                        ELSE
                            sd_save_mem_data_comb <= NASPEN_RAM(to_integer(unsigned(sd_save_mem_addr) - NASPEN_BASE));
                        END IF;
                    END IF;
                END IF;

            WHEN x"C" =>
                IF NOT FAST_BUILD_TRIM_MEMORY THEN
                    IF cfg_bls_active = '1' THEN
                        sd_save_mem_data_comb <= BLS_PASCAL_ROM(to_integer(unsigned(sd_save_mem_addr) - BLS_PASCAL_BASE));
                    ELSIF cfg_cpm_active = '1' THEN
                        sd_save_mem_data_comb <= mainram_rd_dout;
                    ELSIF cfg_slot_rom_active(2) = '1' THEN
                        sd_save_mem_data_comb <= NASDIS_ROM(to_integer(unsigned(sd_save_mem_addr) - NASDIS_BASE));
                    ELSE
                        sd_save_mem_data_comb <= NASDIS_RAM(to_integer(unsigned(sd_save_mem_addr) - NASDIS_BASE));
                    END IF;
                END IF;

            WHEN x"D" =>
                IF NOT FAST_BUILD_TRIM_MEMORY THEN
                    IF cfg_cpm_active = '1' THEN
                        sd_save_mem_data_comb <= mainram_rd_dout;
                    ELSIF cfg_fdd_active = '1' THEN
                        sd_save_mem_data_comb <= NASDOS_ROM(to_integer(unsigned(sd_save_mem_addr) - ZEAP_BASE));
                    ELSIF cfg_bls_active = '1' THEN
                        sd_save_mem_data_comb <= ZEAP_RAM(to_integer(unsigned(sd_save_mem_addr) - ZEAP_BASE));
                    ELSIF cfg_slot_rom_active(3) = '1' THEN
                        sd_save_mem_data_comb <= ZEAP_ROM(to_integer(unsigned(sd_save_mem_addr) - ZEAP_BASE));
                    ELSE
                        sd_save_mem_data_comb <= ZEAP_RAM(to_integer(unsigned(sd_save_mem_addr) - ZEAP_BASE));
                    END IF;
                END IF;

            WHEN x"E" | x"F" =>
                IF cfg_bls_active = '1' THEN
                    sd_save_mem_data_comb <= mainram_rd_dout;
                ELSIF cfg_cpm_active = '0' THEN
                    sd_save_mem_data_comb <= BASIC_ROM(to_integer(unsigned(sd_save_mem_addr(12 DOWNTO 0))));
                ELSIF sd_save_mem_addr(15 DOWNTO 12) = x"E" OR cpm_boot_overlay_enabled = '0' THEN
                    sd_save_mem_data_comb <= mainram_rd_dout;
                ELSIF sd_save_mem_addr(11) = '0' THEN
                    sd_save_mem_data_comb <= CPM_BOOT_ROM(to_integer(unsigned(sd_save_mem_addr(10 DOWNTO 0))));
                ELSIF sd_save_mem_addr(11 DOWNTO 10) = "10" THEN
                    sd_save_mem_data_comb <= x"20";
                ELSE
                    sd_save_mem_data_comb <= mainram_rd_dout;
                END IF;

            WHEN OTHERS =>
                NULL;
        END CASE;
    END PROCESS;

    --------------------------------------------------------------------
    -- Save-Lesedaten auf clk100 registrieren, damit der Backend-Pfad
    -- keinen breiten direkten Kombinationspfad mehr bildet.
    --------------------------------------------------------------------
    PROCESS (clk100)
    BEGIN
        IF rising_edge(clk100) THEN
            sd_save_mem_data <= sd_save_mem_data_comb;
        END IF;
    END PROCESS;

    --------------------------------------------------------------------
    -- Vorgebildete CPU-Lesedaten fuer Slot-/BASIC-Seiten
    --
    -- Diese Daten haengen nur an Adresse und Slot-Konfiguration.
    -- Der eigentliche cpu_di-Mux muss dadurch die breiten ROM/RAM-
    -- Auswahlkegel fuer B/C/D/E/F nicht mehr zusammen mit WAIT/ready
    -- Signalen in einem grossen Prozess tragen.
    --------------------------------------------------------------------
    PROCESS (ALL)
        VARIABLE trim_mem : BOOLEAN;
    BEGIN
        trim_mem := FAST_BUILD_TRIM_MEMORY;

        cpu_page_b_data <= x"00";
        cpu_page_c_data <= x"00";
        cpu_page_d_data <= x"00";
        cpu_page_ef_data <= BASIC_ROM(to_integer(unsigned(cpu_a(12 DOWNTO 0))));
        cpu_page_a_data <= x"00";

        IF NOT trim_mem THEN
            IF cfg_bls_active = '1' THEN
                CASE cpu_a(15 DOWNTO 12) IS
                    WHEN x"A" => cpu_page_a_data <= BLS_PASCAL_ROM(to_integer(unsigned(cpu_a) - BLS_PASCAL_BASE));
                    WHEN x"B" => cpu_page_b_data <= BLS_PASCAL_ROM(to_integer(unsigned(cpu_a) - BLS_PASCAL_BASE));
                    WHEN x"C" => cpu_page_c_data <= BLS_PASCAL_ROM(to_integer(unsigned(cpu_a) - BLS_PASCAL_BASE));
                    WHEN OTHERS => NULL;
                END CASE;
            ELSIF cpu_a(11) = '0' THEN
                IF cfg_slot_rom_active(0) = '1' THEN
                    cpu_page_b_data <= TOOLKIT_ROM(to_integer(unsigned(cpu_a) - TOOLKIT_BASE));
                ELSE
                    cpu_page_b_data <= TOOLKIT_RAM(to_integer(unsigned(cpu_a) - TOOLKIT_BASE));
                END IF;
            ELSE
                IF cfg_slot_rom_active(1) = '1' THEN
                    cpu_page_b_data <= NASPEN_ROM(to_integer(unsigned(cpu_a) - NASPEN_BASE));
                ELSE
                    cpu_page_b_data <= NASPEN_RAM(to_integer(unsigned(cpu_a) - NASPEN_BASE));
                END IF;
            END IF;

            IF cfg_bls_active = '0' AND cfg_slot_rom_active(2) = '1' THEN
                cpu_page_c_data <= NASDIS_ROM(to_integer(unsigned(cpu_a) - NASDIS_BASE));
            ELSIF cfg_bls_active = '0' THEN
                cpu_page_c_data <= NASDIS_RAM(to_integer(unsigned(cpu_a) - NASDIS_BASE));
            END IF;

            IF cfg_cpm_active = '1' THEN
                cpu_page_d_data <= ZEAP_RAM(to_integer(unsigned(cpu_a) - ZEAP_BASE));
            ELSIF cfg_fdd_active = '1' THEN
                cpu_page_d_data <= NASDOS_ROM(to_integer(unsigned(cpu_a) - ZEAP_BASE));
            ELSIF cfg_bls_active = '1' THEN
                cpu_page_d_data <= ZEAP_RAM(to_integer(unsigned(cpu_a) - ZEAP_BASE));
            ELSIF cfg_slot_rom_active(3) = '1' THEN
                cpu_page_d_data <= ZEAP_ROM(to_integer(unsigned(cpu_a) - ZEAP_BASE));
            ELSE
                cpu_page_d_data <= ZEAP_RAM(to_integer(unsigned(cpu_a) - ZEAP_BASE));
            END IF;
        END IF;
    END PROCESS;

    --------------------------------------------------------------------
    -- Separate CPU-Fetchdaten fuer den IR-Pfad
    --
    -- DInst bekommt eigene Slot-/BASIC-Lesedaten, damit Vivado die
    -- timingkritische A->ROM/RAM->IR-Route nicht mit dem allgemeinen
    -- cpu_di-Lesemux teilen muss. Das bleibt rein kombinatorisch und
    -- aendert keine Buszyklen.
    --------------------------------------------------------------------
    PROCESS (ALL)
        VARIABLE trim_mem : BOOLEAN;
    BEGIN
        trim_mem := FAST_BUILD_TRIM_MEMORY;

        cpu_fetch_b_data <= x"00";
        cpu_fetch_c_data <= x"00";
        cpu_fetch_d_data <= x"00";
        cpu_fetch_ef_data <= BASIC_ROM(to_integer(unsigned(cpu_a(12 DOWNTO 0))));
        cpu_fetch_a_data <= x"00";

        IF NOT trim_mem THEN
            IF cfg_bls_active = '1' THEN
                CASE cpu_a(15 DOWNTO 12) IS
                    WHEN x"A" => cpu_fetch_a_data <= BLS_PASCAL_ROM(to_integer(unsigned(cpu_a) - BLS_PASCAL_BASE));
                    WHEN x"B" => cpu_fetch_b_data <= BLS_PASCAL_ROM(to_integer(unsigned(cpu_a) - BLS_PASCAL_BASE));
                    WHEN x"C" => cpu_fetch_c_data <= BLS_PASCAL_ROM(to_integer(unsigned(cpu_a) - BLS_PASCAL_BASE));
                    WHEN OTHERS => NULL;
                END CASE;
            ELSIF cpu_a(11) = '0' THEN
                IF cfg_slot_rom_active(0) = '1' THEN
                    cpu_fetch_b_data <= TOOLKIT_ROM(to_integer(unsigned(cpu_a(10 DOWNTO 0))));
                ELSE
                    cpu_fetch_b_data <= TOOLKIT_RAM(to_integer(unsigned(cpu_a(10 DOWNTO 0))));
                END IF;
            ELSE
                IF cfg_slot_rom_active(1) = '1' THEN
                    cpu_fetch_b_data <= NASPEN_ROM(to_integer(unsigned(cpu_a(10 DOWNTO 0))));
                ELSE
                    cpu_fetch_b_data <= NASPEN_RAM(to_integer(unsigned(cpu_a(10 DOWNTO 0))));
                END IF;
            END IF;

            IF cfg_bls_active = '0' AND cfg_slot_rom_active(2) = '1' THEN
                cpu_fetch_c_data <= NASDIS_ROM(to_integer(unsigned(cpu_a(11 DOWNTO 0))));
            ELSIF cfg_bls_active = '0' THEN
                cpu_fetch_c_data <= NASDIS_RAM(to_integer(unsigned(cpu_a(11 DOWNTO 0))));
            END IF;

            IF cfg_cpm_active = '1' THEN
                cpu_fetch_d_data <= ZEAP_RAM(to_integer(unsigned(cpu_a(11 DOWNTO 0))));
            ELSIF cfg_fdd_active = '1' THEN
                cpu_fetch_d_data <= NASDOS_ROM(to_integer(unsigned(cpu_a(11 DOWNTO 0))));
            ELSIF cfg_bls_active = '1' THEN
                cpu_fetch_d_data <= ZEAP_RAM(to_integer(unsigned(cpu_a(11 DOWNTO 0))));
            ELSIF cfg_slot_rom_active(3) = '1' THEN
                cpu_fetch_d_data <= ZEAP_ROM(to_integer(unsigned(cpu_a(11 DOWNTO 0))));
            ELSE
                cpu_fetch_d_data <= ZEAP_RAM(to_integer(unsigned(cpu_a(11 DOWNTO 0))));
            END IF;
        END IF;
    END PROCESS;
    --------------------------------------------------------------------
    -- Vorgebildete CPU-Fetchdaten fuer den IR-Pfad
    --
    -- DInst wird nur fuer den Instruktionsfetch gebraucht. Deshalb
    -- halten wir diesen Pfad bewusst kleiner als den allgemeinen cpu_di-
    -- Mux und lassen I/O-Leselogik komplett draussen.
    --------------------------------------------------------------------
    PROCESS (ALL)
        VARIABLE mainram_ready : BOOLEAN;
        VARIABLE vram_ready : BOOLEAN;
        VARIABLE avc_ready : BOOLEAN;
        VARIABLE trim_mem : BOOLEAN;
        VARIABLE page_hi : STD_LOGIC_VECTOR(3 DOWNTO 0);
    BEGIN
        cpu_dinst <= x"00";

        mainram_ready := (mainram_read_state = MAINRAM_READ_RELEASE);
        vram_ready := (vram_read_state = VRAM_READ_RELEASE);
        avc_ready := (avc_read_state = AVC_READ_RELEASE);
        trim_mem := FAST_BUILD_TRIM_MEMORY;
        page_hi := cpu_a(15 DOWNTO 12);

        IF avc_cpu_mem_sel = '1' THEN
            IF avc_ready THEN
                cpu_dinst <= avc_read_data;
            END IF;
        ELSE
          CASE page_hi IS
            WHEN x"0" =>
                IF cfg_cpm_active = '1' AND cpm_low_ram_enabled = '1' THEN
                    IF mainram_ready THEN
                        cpu_dinst <= mainram_read_data;
                    END IF;
                ELSIF cfg_cpm_active = '1' AND cpu_a(11) = '0' THEN
                    cpu_dinst <= CPM_BOOT_ROM(to_integer(unsigned(cpu_a(10 DOWNTO 0))));
                ELSIF cpu_a(11) = '0' THEN
                    cpu_dinst <= ROM(to_integer(unsigned(cpu_a(10 DOWNTO 0))));

                ELSIF cpu_a(11 DOWNTO 10) = "10" THEN
                    IF DEBUG_ISOLATE_VRAM_READS THEN
                        cpu_dinst <= x"20";
                    ELSIF vram_ready THEN
                        cpu_dinst <= vram_read_data;
                    END IF;

                ELSIF mainram_ready THEN
                    cpu_dinst <= mainram_read_data;
                END IF;

            WHEN x"1" | x"2" | x"3" | x"4" | x"5" | x"6" | x"7" | x"8" | x"9" =>
                IF mainram_ready THEN
                    IF (NOT trim_mem) OR (page_hi = x"1") THEN
                        cpu_dinst <= mainram_read_data;
                    END IF;
                END IF;

            WHEN x"A" =>
                IF cfg_bls_active = '1' AND NOT trim_mem THEN
                    cpu_dinst <= cpu_fetch_a_data;
                ELSIF mainram_ready AND NOT trim_mem THEN
                    cpu_dinst <= mainram_read_data;
                END IF;

            WHEN x"B" =>
                IF cfg_cpm_active = '1' THEN
                    IF mainram_ready THEN
                        cpu_dinst <= mainram_read_data;
                    END IF;
                ELSIF NOT trim_mem THEN
                    cpu_dinst <= cpu_fetch_b_data;
                END IF;

            WHEN x"C" =>
                IF cfg_cpm_active = '1' THEN
                    IF mainram_ready THEN
                        cpu_dinst <= mainram_read_data;
                    END IF;
                ELSIF NOT trim_mem THEN
                    cpu_dinst <= cpu_fetch_c_data;
                END IF;

            WHEN x"D" =>
                IF cfg_cpm_active = '1' THEN
                    IF mainram_ready THEN
                        cpu_dinst <= mainram_read_data;
                    END IF;
                ELSIF NOT trim_mem THEN
                    cpu_dinst <= cpu_fetch_d_data;
                END IF;

            WHEN x"E" | x"F" =>
                IF cfg_bls_active = '1' THEN
                    IF mainram_ready THEN
                        cpu_dinst <= mainram_read_data;
                    END IF;
                ELSIF cfg_cpm_active = '0' THEN
                    cpu_dinst <= cpu_fetch_ef_data;
                ELSIF page_hi = x"E" OR cpm_boot_overlay_enabled = '0' THEN
                    IF mainram_ready THEN
                        cpu_dinst <= mainram_read_data;
                    END IF;
                ELSIF cpu_a(11) = '0' THEN
                    cpu_dinst <= CPM_BOOT_ROM(to_integer(unsigned(cpu_a(10 DOWNTO 0))));
                ELSIF cpu_a(11 DOWNTO 10) = "10" THEN
                    IF vram_ready THEN
                        cpu_dinst <= vram_read_data;
                    END IF;
                ELSIF cpu_a(11 DOWNTO 10) = "11" THEN
                    cpu_dinst <= CPM_MONITOR_RAM(to_integer(unsigned(cpu_a(9 DOWNTO 0))));
                ELSIF mainram_ready THEN
                    cpu_dinst <= mainram_read_data;
                END IF;

            WHEN OTHERS =>
                NULL;
          END CASE;
        END IF;
    END PROCESS;

    --------------------------------------------------------------------
    -- Speicher-/I/O-Lese-Mux
    --
    -- Port 00h: Keyboard/PIO idle (FF)
    -- Port 01h: serielle Daten
    -- Port 02h: serieller Status  bit7 = RX ready, bit6 = TX ready
    --------------------------------------------------------------------
    PROCESS (ALL)
        VARIABLE mem_rd : BOOLEAN;
        VARIABLE io_rd : BOOLEAN;
        VARIABLE mainram_ready : BOOLEAN;
        VARIABLE vram_ready : BOOLEAN;
        VARIABLE avc_ready : BOOLEAN;
        VARIABLE trim_mem : BOOLEAN;
        VARIABLE page_hi : STD_LOGIC_VECTOR(3 DOWNTO 0);
        VARIABLE io_addr : STD_LOGIC_VECTOR(7 DOWNTO 0);
    BEGIN
        cpu_di <= x"00";

        mem_rd := (mreq_n = '0') AND (rd_n = '0');
        io_rd := (iorq_n = '0') AND (rd_n = '0');
        mainram_ready := (mainram_read_state = MAINRAM_READ_RELEASE);
        vram_ready := (vram_read_state = VRAM_READ_RELEASE);
        avc_ready := (avc_read_state = AVC_READ_RELEASE);
        trim_mem := FAST_BUILD_TRIM_MEMORY;
        page_hi := cpu_a(15 DOWNTO 12);
        io_addr := cpu_a(7 DOWNTO 0);

        ----------------------------------------------------------------
        -- MEMORY READ
        ----------------------------------------------------------------
        IF mem_rd THEN
            IF avc_cpu_mem_sel = '1' THEN
                IF avc_ready THEN
                    cpu_di <= avc_read_data;
                END IF;
            ELSE
              CASE page_hi IS
                WHEN x"0" =>
                    IF cfg_cpm_active = '1' AND cpm_low_ram_enabled = '1' THEN
                        IF mainram_ready THEN
                            cpu_di <= mainram_read_data;
                        END IF;
                    ELSIF cfg_cpm_active = '1' AND cpu_a(11) = '0' THEN
                        cpu_di <= CPM_BOOT_ROM(to_integer(unsigned(cpu_a(10 DOWNTO 0))));
                    ELSIF cpu_a(11) = '0' THEN
                        cpu_di <= ROM(to_integer(unsigned(cpu_a(10 DOWNTO 0))));

                    ELSIF cpu_a(11 DOWNTO 10) = "10" THEN
                        IF DEBUG_ISOLATE_VRAM_READS THEN
                            cpu_di <= x"20";
                        ELSIF vram_ready THEN
                            cpu_di <= vram_read_data;
                        END IF;

                    ELSIF mainram_ready THEN
                        cpu_di <= mainram_read_data;
                    END IF;

                WHEN x"1" | x"2" | x"3" | x"4" | x"5" | x"6" | x"7" | x"8" | x"9" =>
                    IF mainram_ready THEN
                        IF (NOT trim_mem) OR (page_hi = x"1") THEN
                            cpu_di <= mainram_read_data;
                        END IF;
                    END IF;

                WHEN x"A" =>
                    IF cfg_bls_active = '1' AND NOT trim_mem THEN
                        cpu_di <= cpu_page_a_data;
                    ELSIF mainram_ready AND NOT trim_mem THEN
                        cpu_di <= mainram_read_data;
                    END IF;

                WHEN x"B" =>
                    IF cfg_cpm_active = '1' THEN
                        IF mainram_ready THEN
                            cpu_di <= mainram_read_data;
                        END IF;
                    ELSIF NOT trim_mem THEN
                        cpu_di <= cpu_page_b_data;
                    END IF;

                WHEN x"C" =>
                    IF cfg_cpm_active = '1' THEN
                        IF mainram_ready THEN
                            cpu_di <= mainram_read_data;
                        END IF;
                    ELSIF NOT trim_mem THEN
                        cpu_di <= cpu_page_c_data;
                    END IF;

                WHEN x"D" =>
                    IF cfg_cpm_active = '1' THEN
                        IF mainram_ready THEN
                            cpu_di <= mainram_read_data;
                        END IF;
                    ELSIF NOT trim_mem THEN
                        cpu_di <= cpu_page_d_data;
                    END IF;

                WHEN x"E" | x"F" =>
                    IF cfg_bls_active = '1' THEN
                        IF mainram_ready THEN
                            cpu_di <= mainram_read_data;
                        END IF;
                    ELSIF cfg_cpm_active = '0' THEN
                        cpu_di <= cpu_page_ef_data;
                    ELSIF page_hi = x"E" OR cpm_boot_overlay_enabled = '0' THEN
                        IF mainram_ready THEN
                            cpu_di <= mainram_read_data;
                        END IF;
                    ELSIF cpu_a(11) = '0' THEN
                        cpu_di <= CPM_BOOT_ROM(to_integer(unsigned(cpu_a(10 DOWNTO 0))));
                    ELSIF cpu_a(11 DOWNTO 10) = "10" THEN
                        IF vram_ready THEN
                            cpu_di <= vram_read_data;
                        END IF;
                    ELSIF cpu_a(11 DOWNTO 10) = "11" THEN
                        cpu_di <= CPM_MONITOR_RAM(to_integer(unsigned(cpu_a(9 DOWNTO 0))));
                    ELSIF mainram_ready THEN
                        cpu_di <= mainram_read_data;
                    END IF;

                WHEN OTHERS =>
                    NULL;
              END CASE;
            END IF;

            ----------------------------------------------------------------
            -- IO READ
            ----------------------------------------------------------------
        ELSIF io_rd THEN
            CASE io_addr IS
                WHEN x"00" =>
                    cpu_di <= kbd_port0_in;

                WHEN x"01" =>
                    IF rx_count > 0 THEN
                        cpu_di <= rx_fifo(rx_rd_ptr);
                    END IF;

                WHEN x"02" =>
                    IF rx_count > 0 THEN
                        cpu_di(7) <= '1';
                    END IF;

                    IF rs232_tx_ready = '1' THEN
                        cpu_di(6) <= '1';
                    END IF;

                WHEN x"09" =>
                    cpu_di <= ay_register_data;

                WHEN x"B1" =>
                    IF cfg_avc_active = '1' AND to_integer(avc_crtc_index) <= 17 THEN
                        cpu_di <= avc_crtc_regs(to_integer(avc_crtc_index));
                    END IF;

                WHEN x"B2" =>
                    IF cfg_avc_active = '1' THEN
                        cpu_di <= avc_control_reg;
                    END IF;

                WHEN x"B3" =>
                    IF cfg_avc_active = '1' THEN
                        cpu_di <= avc_terminal_char;
                    END IF;

                WHEN x"B4" =>
                    IF cfg_avc_active = '1' THEN
                        cpu_di(0) <= NOT avc_terminal_busy;
                        cpu_di(1) <= avc_terminal_enabled;
                    END IF;

                WHEN x"10" =>
                    cpu_di <= rtc_regs_reg(0); -- seconds (BCD)

                WHEN x"11" =>
                    cpu_di <= rtc_regs_reg(1); -- minutes (BCD)

                WHEN x"12" =>
                    cpu_di <= rtc_regs_reg(2) AND x"3F"; -- hours (mask control bits)

                WHEN x"13" =>
                    cpu_di <= rtc_regs_reg(6); -- weekday

                WHEN x"14" =>
                    cpu_di <= rtc_regs_reg(3); -- day (BCD)

                WHEN x"15" =>
                    cpu_di <= rtc_regs_reg(4); -- month (BCD)

                WHEN x"16" =>
                    cpu_di <= rtc_regs_reg(5); -- year (BCD)

                WHEN x"17" =>
                    cpu_di(7) <= rtc_valid_reg;
                    cpu_di(6) <= rtc_busy_reg;
                    cpu_di(5) <= rtc_error_reg;
                    cpu_di(4) <= rtc_update_toggle_reg;
                    cpu_di(3 DOWNTO 0) <= rtc_error_code_reg;

                WHEN x"18" =>
                    cpu_di <= rtc_debug_busy_count_i;

                WHEN x"19" =>
                    cpu_di <= rtc_debug_status_i;

                WHEN x"1A" =>
                    cpu_di <= rtc_debug_last_byte_i;

                WHEN x"1B" =>
                    cpu_di <= rtc_debug_addr_i;

                WHEN x"B8" =>
                    cpu_di <= network_status_data;

                WHEN x"B9" =>
                    cpu_di <= network_response_data;

                WHEN x"E0" =>
                    IF cfg_fdd_active = '1' THEN
                        cpu_di <= fdc_status_reg;
                    END IF;

                WHEN x"E1" =>
                    IF cfg_fdd_active = '1' THEN
                        cpu_di <= fdc_track_reg;
                    END IF;

                WHEN x"E2" =>
                    IF cfg_fdd_active = '1' THEN
                        cpu_di <= fdc_sector_reg;
                    END IF;

                WHEN x"E3" =>
                    IF cfg_fdd_active = '1' AND fdc_drq_reg = '1' THEN
                        IF fdc_read_address_active = '1' THEN
                            CASE fdc_data_index IS
                                WHEN 0 => cpu_di <= fdc_track_reg;
                                WHEN 1 => cpu_di <= "0000000" & fdc_control_reg(4);
                                WHEN 2 => cpu_di <= fdc_sector_reg;
                                WHEN 3 => cpu_di <= x"01"; -- 256-byte sector
                                WHEN OTHERS => cpu_di <= x"00"; -- CRC bytes
                            END CASE;
                        ELSE
                            cpu_di <= fdd_buffer_data;
                        END IF;
                    END IF;

                WHEN x"E4" =>
                    IF cfg_fdd_active = '1' THEN
                        IF cfg_cpm_active = '1' THEN
                            -- The CP/M 2.2 boot EPROM verifies the Lucas
                            -- control latch by writing/reading back 4Fh.
                            cpu_di <= fdc_control_reg;
                        ELSE
                            cpu_di <= fdc_control_reg AND x"BF";
                        END IF;
                    END IF;

                WHEN x"E5" =>
                    IF cfg_fdd_active = '1' THEN
                        cpu_di(7) <= fdc_drq_reg;
                        cpu_di(1) <= '1' WHEN
                            fdc_control_reg(5) = '0' OR
                            (fdc_control_reg(0) = '0' AND fdc_control_reg(1) = '0')
                            ELSE '0';
                        cpu_di(0) <= fdc_intrq_reg;
                    END IF;

                WHEN x"E6" =>
                    IF cfg_fdd_active = '1' THEN
                        cpu_di <= fdc_format_debug_reg;
                    END IF;

                WHEN x"E7" =>
                    IF cfg_fdd_active = '1' THEN
                        cpu_di <= fdc_format_last_track_reg;
                    END IF;

                WHEN x"E8" =>
                    IF cfg_fdd_active = '1' THEN
                        cpu_di <= STD_LOGIC_VECTOR(to_unsigned(
                            fdc_format_directory_writes_left, 8));
                    END IF;

                WHEN OTHERS =>
                    NULL;
            END CASE;
        END IF;
    END PROCESS;

    --------------------------------------------------------------------
    -- Port 0 latch (Nascom keyboard/control port)
    --------------------------------------------------------------------
    PROCESS (clk100)
    BEGIN
        IF rising_edge(clk100) THEN
            IF sys_reset = '1' THEN
                port0_reg <= x"00";
                port0_wr_n_last <= '1';
            ELSE
                IF port0_wr_n_last = '1' AND wr_n = '0' THEN
                    IF iorq_n = '0' AND cpu_a(7 DOWNTO 0) = x"00" THEN
                        port0_reg <= cpu_do;
                    END IF;
                END IF;

                port0_wr_n_last <= wr_n;
            END IF;
        END IF;
    END PROCESS;

    --------------------------------------------------------------------
    -- Lucas/NASCOM WD1793-compatible floppy controller.
    --
    -- E0..E3 are the WD1793 registers, E4 selects drive/side/motor and
    -- E5 exposes INTRQ (bit 0), NOT READY (bit 1) and DRQ (bit 7).
    -- READ/WRITE SECTOR, READ ADDRESS and the NAS-DOS WRITE TRACK format
    -- stream are implemented for the fixed mounted-DSK geometry.
    --------------------------------------------------------------------
    PROCESS (clk100)
        VARIABLE io_wr_now_v : STD_LOGIC;
        VARIABLE io_rd_now_v : STD_LOGIC;
        VARIABLE command_v : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE image_sector_v : INTEGER RANGE 0 TO 2559;
        VARIABLE sd_sector_v : INTEGER RANGE 0 TO 1279;
        VARIABLE drive_ready_v : BOOLEAN;
    BEGIN
        IF rising_edge(clk100) THEN
            IF fdd_read_busy = '1' THEN
                fdd_read_start <= '0';
            END IF;
            IF fdd_write_busy = '1' OR fdd_write_done = '1' OR fdd_write_error = '1' THEN
                fdd_write_start <= '0';
            END IF;
            IF fdd_format_busy = '1' OR fdd_format_done = '1' OR fdd_format_error = '1' THEN
                fdd_format_start <= '0';
            END IF;
            fdd_buffer_write_enable <= '0';
            io_wr_now_v := '0';
            io_rd_now_v := '0';
            IF iorq_n = '0' AND wr_n = '0' THEN
                io_wr_now_v := '1';
            END IF;
            IF iorq_n = '0' AND rd_n = '0' THEN
                io_rd_now_v := '1';
            END IF;

            IF sys_reset = '1' OR cfg_fdd_active = '0' THEN
                fdc_status_reg <= x"00";
                fdc_track_reg <= x"00";
                fdc_sector_reg <= x"01";
                fdc_data_reg <= x"FF";
                -- NAS-DOS initializes the Lucas controller to $21:
                -- drive 0 selected and motor enabled.  Starting in the
                -- same state also makes an unqualified ]D use drive 0.
                fdc_control_reg <= x"21";
                fdc_intrq_reg <= '0';
                fdc_drq_reg <= '0';
                fdc_format_debug_reg <= x"00";
                fdc_data_index <= 0;
                fdc_data_last_index <= 255;
                fdc_read_address_active <= '0';
                fdd_buffer_addr <= x"00";
                fdd_request_armed <= '0';
                fdd_read_start <= '0';
                fdd_buffer_write_enable <= '0';
                fdd_buffer_write_addr <= x"00";
                fdd_buffer_write_data <= x"00";
                fdd_write_start <= '0';
                fdd_write_cluster <= (OTHERS => '0');
                fdd_write_sd_sector <= (OTHERS => '0');
                fdd_write_half <= '0';
                fdd_write_request_armed <= '0';
                fdd_format_start <= '0';
                fdd_format_name <= (OTHERS => '0');
                fdd_format_cluster <= (OTHERS => '0');
                fdd_format_request_armed <= '0';
                fdc_write_track_active <= '0';
                fdc_track_parse_state <= 0;
                fdc_track_sector_id <= 0;
                fdc_track_data_index <= 0;
                fdc_track_sector_count <= 0;
                fdc_track_tail_active <= '0';
                fdc_track_tail_count <= 0;
                fdc_track_commit_active <= '0';
                fdc_track_commit_sector <= 0;
                fdc_track_commit_index <= 0;
                fdc_track_commit_wait <= '0';
                fdc_track_drive_b <= '0';
                fdc_track_side <= '0';
                fdc_track_number <= x"00";
                fdc_format_last_track_reg <= x"FF";
                fdc_format_directory_writes_left <= 0;
                fdc_format_directory_sequence_active <= '0';
                fdc_data_read_pending <= '0';
                fdc_diag_read_active <= '0';
                fdc_diag_data_reads <= 0;
                fdc_write_sector_active <= '0';
                fdc_multi_sector_active <= '0';
                fdd_diag_valid <= '0';
                fdd_diag_cpm_position <= (OTHERS => '0');
                fdd_diag_fdd_position <= (OTHERS => '0');
                fdd_diag_cluster <= (OTHERS => '0');
                fdd_diag_sd_lba <= (OTHERS => '0');
                fdd_diag_sd_status <= (OTHERS => '0');
                fdd_diag_read_count <= (OTHERS => '0');
                fdd_diag_first_word <= (OTHERS => '0');
            ELSE
                IF fdd_read_busy = '1' AND fdc_status_reg(0) = '1' THEN
                    fdd_request_armed <= '1';
                END IF;
                IF fdd_write_busy = '1' AND fdc_status_reg(0) = '1' THEN
                    fdd_write_request_armed <= '1';
                END IF;
                IF fdd_format_busy = '1' AND fdc_status_reg(0) = '1' THEN
                    fdd_format_request_armed <= '1';
                END IF;

                IF fdd_read_done = '1' AND fdd_request_armed = '1' AND fdc_status_reg(0) = '1' THEN
                    IF fdd_diag_valid = '0' THEN
                        fdd_diag_sd_lba <= sd_read_lba;
                        fdd_diag_sd_status <=
                            sd_state_code & sd_debug_read_cmd17_r1 & sd_read_token &
                            ("0000" & sd_debug_read_error_code);
                        fdd_diag_read_count <= sd_read_count;
                        fdd_diag_first_word <= sd_read_first_word;
                    END IF;
                    fdc_status_reg(0) <= '0';
                    fdc_drq_reg <= '1';
                    fdc_intrq_reg <= '0';
                    fdc_data_index <= 0;
                    fdc_data_last_index <= 255;
                    fdc_read_address_active <= '0';
                    fdd_buffer_addr <= x"00";
                    fdd_request_armed <= '0';
                    fdc_data_read_pending <= '0';
                ELSIF fdd_read_error = '1' AND fdd_request_armed = '1' AND fdc_status_reg(0) = '1' THEN
                    IF fdd_diag_valid = '0' THEN
                        fdd_diag_valid <= '1';
                        fdd_diag_cpm_position(31 DOWNTO 24) <= STD_LOGIC_VECTOR(to_unsigned(
                            (to_integer(UNSIGNED(fdc_track_reg)) * 2) +
                            to_integer(UNSIGNED(fdc_control_reg(4 DOWNTO 4))), 8));
                        IF fdd_read_half = '0' THEN
                            fdd_diag_cpm_position(23 DOWNTO 16) <= STD_LOGIC_VECTOR(to_unsigned(
                                (to_integer(UNSIGNED(fdc_sector_reg)) - 1) * 2, 8));
                        ELSE
                            fdd_diag_cpm_position(23 DOWNTO 16) <= STD_LOGIC_VECTOR(to_unsigned(
                                ((to_integer(UNSIGNED(fdc_sector_reg)) - 1) * 2) + 1, 8));
                        END IF;
                        fdd_diag_cpm_position(15 DOWNTO 8) <= fdc_track_reg;
                        fdd_diag_cpm_position(7 DOWNTO 0) <= fdc_sector_reg;
                        fdd_diag_fdd_position(31 DOWNTO 24) <= fdc_control_reg;
                        fdd_diag_fdd_position(23 DOWNTO 13) <= fdd_read_sd_sector;
                        fdd_diag_fdd_position(12) <= fdd_read_half;
                        fdd_diag_fdd_position(11 DOWNTO 0) <= (OTHERS => '0');
                        fdd_diag_cluster <= fdd_read_cluster;
                        fdd_diag_sd_lba <= sd_read_lba;
                        fdd_diag_sd_status(31 DOWNTO 24) <= sd_state_code;
                        fdd_diag_sd_status(23 DOWNTO 16) <= sd_debug_read_cmd17_r1;
                        fdd_diag_sd_status(15 DOWNTO 8) <= sd_read_token;
                        fdd_diag_sd_status(7 DOWNTO 4) <= (OTHERS => '0');
                        fdd_diag_sd_status(3 DOWNTO 0) <= sd_debug_read_error_code;
                        fdd_diag_read_count <= sd_read_count;
                        fdd_diag_first_word <= sd_read_first_word;
                    END IF;
                    fdc_status_reg <= x"10";
                    fdc_drq_reg <= '0';
                    fdc_intrq_reg <= '1';
                    fdc_read_address_active <= '0';
                    fdc_multi_sector_active <= '0';
                    fdd_request_armed <= '0';
                END IF;

                IF fdd_format_done = '1' AND fdd_format_request_armed = '1' AND
                    fdc_status_reg(0) = '1' THEN
                    fdc_format_debug_reg <= x"11";
                    IF fdc_track_drive_b = '0' THEN
                        fdd_mount_a_format_cluster <= fdd_format_new_cluster;
                    ELSE
                        fdd_mount_b_format_cluster <= fdd_format_new_cluster;
                    END IF;
                    fdd_format_request_armed <= '0';
                    fdc_track_commit_active <= '1';
                    fdc_track_commit_sector <= 0;
                    fdc_track_commit_index <= 0;
                    fdc_track_commit_wait <= '0';
                ELSIF fdd_format_error = '1' AND fdd_format_request_armed = '1' AND
                    fdc_status_reg(0) = '1' THEN
                    -- Preserve the SD backend's detailed four-bit reason.
                    -- E1..E6 are pre-write validation failures, E9..EF are
                    -- physical CMD24/FAT/verify failures.  This remains
                    -- readable through port E6 after NAS-DOS reports its
                    -- generic Fmt.Error.
                    IF sd_save_write_status = x"4" AND
                        sd_debug_read_error_code /= x"0" THEN
                        -- C1..C4 identify the underlying CMD17/read-token
                        -- failure after all automatic retries were used.
                        fdc_format_debug_reg <= x"C" & sd_debug_read_error_code;
                    ELSE
                        fdc_format_debug_reg <= x"E" & sd_save_write_status;
                    END IF;
                    fdc_status_reg <= x"20"; -- backup/create transaction failed
                    fdc_drq_reg <= '0';
                    fdc_intrq_reg <= '1';
                    fdd_format_request_armed <= '0';
                    fdc_track_commit_active <= '0';
                END IF;

                IF fdd_write_done = '1' AND fdd_write_request_armed = '1' AND
                    fdc_status_reg(0) = '1' THEN
                    fdd_write_request_armed <= '0';
                    IF fdc_track_commit_active = '1' THEN
                        fdc_track_commit_wait <= '0';
                        IF fdc_track_commit_sector = 15 THEN
                            fdc_format_debug_reg <= x"00";
                            fdc_track_commit_active <= '0';
                            fdc_status_reg <= x"00";
                            fdc_drq_reg <= '0';
                            fdc_intrq_reg <= '1';
                            -- Every fully committed raw track is a possible
                            -- final format track.  A following WRITE TRACK
                            -- clears this candidate before arming the next
                            -- one.  Only the exact track-0 sector 1..16
                            -- sequence below can consume the window.
                            fdc_format_last_track_reg <= fdc_track_number;
                            fdc_format_directory_writes_left <= 16;
                            fdc_format_directory_sequence_active <= '0';
                            fdc_format_debug_reg <= x"40";
                        ELSE
                            fdc_track_commit_sector <= fdc_track_commit_sector + 1;
                            fdc_track_commit_index <= 0;
                        END IF;
                    ELSIF fdc_multi_sector_active = '1' AND
                        unsigned(fdc_sector_reg) < to_unsigned(16, 8) THEN
                        -- WD1793 WRITE MULTIPLE keeps BUSY asserted and asks
                        -- for the next sector immediately after the previous
                        -- physical write has completed.
                        fdc_sector_reg <= STD_LOGIC_VECTOR(unsigned(fdc_sector_reg) + 1);
                        image_sector_v :=
                            to_integer(unsigned(fdc_track_reg)) * 32 +
                            to_integer(unsigned(fdc_control_reg(4 DOWNTO 4))) * 16 +
                            to_integer(unsigned(fdc_sector_reg));
                        sd_sector_v := image_sector_v / 2;
                        IF fdc_control_reg(0) = '1' THEN
                            fdd_write_cluster <= fdd_mount_a_cluster;
                        ELSE
                            fdd_write_cluster <= fdd_mount_b_cluster;
                        END IF;
                        fdd_write_sd_sector <= STD_LOGIC_VECTOR(to_unsigned(sd_sector_v, 11));
                        IF (image_sector_v MOD 2) = 0 THEN
                            fdd_write_half <= '0';
                        ELSE
                            fdd_write_half <= '1';
                        END IF;
                        fdc_status_reg <= x"01";
                        fdc_data_index <= 0;
                        fdc_data_last_index <= 255;
                        fdc_write_sector_active <= '1';
                        fdc_drq_reg <= '1';
                        fdc_intrq_reg <= '0';
                    ELSE
                        IF fdc_format_directory_writes_left > 0 AND
                            fdc_format_directory_sequence_active = '1' AND
                            fdc_track_reg = x"00" AND
                            unsigned(fdc_sector_reg) >= to_unsigned(1, 8) AND
                            unsigned(fdc_sector_reg) <= to_unsigned(16, 8) THEN
                            -- The formatter's directory clear must reach the
                            -- image, not merely be acknowledged to NAS-DOS.
                            -- Retain the diagnostic phase until the physical
                            -- SD write has completed successfully.
                            fdc_format_directory_writes_left <=
                                fdc_format_directory_writes_left - 1;
                            IF fdc_sector_reg = x"10" THEN
                                fdc_format_directory_sequence_active <= '0';
                                fdc_format_debug_reg <= x"60";
                            ELSE
                                fdc_format_debug_reg <=
                                    x"5" & fdc_sector_reg(3 DOWNTO 0);
                            END IF;
                        END IF;
                        fdc_multi_sector_active <= '0';
                        fdc_status_reg <= x"00";
                        fdc_drq_reg <= '0';
                        fdc_intrq_reg <= '1';
                    END IF;
                ELSIF fdd_write_error = '1' AND fdd_write_request_armed = '1' AND
                    fdc_status_reg(0) = '1' THEN
                    IF fdc_track_commit_active = '1' THEN
                        fdc_format_debug_reg <= x"E2";
                    ELSIF sd_debug_read_error_code /= x"0" THEN
                        -- D1..D4: normal WRITE SECTOR read/modify/write
                        -- failed even after its automatic CMD17 retries.
                        fdc_format_debug_reg <= x"D" & sd_debug_read_error_code;
                    ELSE
                        -- A9..AF: normal WRITE SECTOR reached the SD write
                        -- path but CMD24/data-response/busy handling failed.
                        fdc_format_debug_reg <= x"A" & sd_save_write_status;
                    END IF;
                    fdc_status_reg <= x"20"; -- write fault
                    fdc_drq_reg <= '0';
                    fdc_intrq_reg <= '1';
                    fdd_write_request_armed <= '0';
                    fdc_multi_sector_active <= '0';
                    fdc_track_commit_active <= '0';
                    fdc_track_commit_wait <= '0';
                END IF;

                -- Feed the captured track to the existing 256-byte sector
                -- writer.  SD latency is hidden between sector transfers.
                IF fdc_track_commit_active = '1' AND fdc_track_commit_wait = '0' THEN
                    IF fdc_track_commit_index < 256 THEN
                        fdd_buffer_write_enable <= '1';
                        fdd_buffer_write_addr <= STD_LOGIC_VECTOR(
                            to_unsigned(fdc_track_commit_index, 8));
                        fdd_buffer_write_data <= fdc_track_buffer_reg(
                            (fdc_track_commit_sector * 256) + fdc_track_commit_index);
                        fdc_track_commit_index <= fdc_track_commit_index + 1;
                    ELSIF fdd_write_busy = '0' AND fdd_read_busy = '0' THEN
                        image_sector_v :=
                            to_integer(unsigned(fdc_track_number)) * 32 +
                            fdc_track_commit_sector;
                        IF fdc_track_side = '1' THEN
                            image_sector_v := image_sector_v + 16;
                        END IF;
                        sd_sector_v := image_sector_v / 2;
                        IF fdc_track_drive_b = '0' THEN
                            fdd_write_cluster <= fdd_mount_a_cluster;
                        ELSE
                            fdd_write_cluster <= fdd_mount_b_cluster;
                        END IF;
                        fdd_write_sd_sector <= STD_LOGIC_VECTOR(to_unsigned(sd_sector_v, 11));
                        IF (image_sector_v MOD 2) = 0 THEN
                            fdd_write_half <= '0';
                        ELSE
                            fdd_write_half <= '1';
                        END IF;
                        fdd_write_request_armed <= '0';
                        fdc_track_commit_wait <= '1';
                        fdd_write_start <= '1';
                    END IF;
                END IF;

                -- Keep the addressed byte stable for the complete Z80 I/O read.
                -- Advancing on the leading /RD edge makes the CPU see byte N+1
                -- and drops byte zero from every sector.
                IF io_rd_now_v = '1' AND fdc_io_rd_last = '0' AND
                    cpu_a(7 DOWNTO 0) = x"E3" AND fdc_drq_reg = '1' THEN
                    fdc_data_read_pending <= '1';
                ELSIF io_rd_now_v = '0' AND fdc_data_read_pending = '1' THEN
                    fdc_data_read_pending <= '0';
                    IF fdc_diag_read_active = '1' AND fdc_diag_data_reads < 256 THEN
                        fdc_diag_data_reads <= fdc_diag_data_reads + 1;
                    END IF;
                    IF fdc_data_index = fdc_data_last_index THEN
                        IF fdc_multi_sector_active = '1' AND
                            fdc_read_address_active = '0' AND
                            unsigned(fdc_sector_reg) < to_unsigned(16, 8) AND
                            fdd_read_busy = '0' THEN
                            -- Continue a WD1793 READ MULTIPLE command with
                            -- the next sector while keeping BUSY asserted.
                            fdc_sector_reg <= STD_LOGIC_VECTOR(unsigned(fdc_sector_reg) + 1);
                            image_sector_v :=
                                to_integer(unsigned(fdc_track_reg)) * 32 +
                                to_integer(unsigned(fdc_control_reg(4 DOWNTO 4))) * 16 +
                                to_integer(unsigned(fdc_sector_reg));
                            sd_sector_v := image_sector_v / 2;
                            IF fdc_control_reg(0) = '1' THEN
                                fdd_read_cluster <= fdd_mount_a_cluster;
                            ELSE
                                fdd_read_cluster <= fdd_mount_b_cluster;
                            END IF;
                            fdd_read_sd_sector <= STD_LOGIC_VECTOR(to_unsigned(sd_sector_v, 11));
                            IF (image_sector_v MOD 2) = 0 THEN
                                fdd_read_half <= '0';
                            ELSE
                                fdd_read_half <= '1';
                            END IF;
                            fdc_drq_reg <= '0';
                            fdc_intrq_reg <= '0';
                            fdc_status_reg <= x"01";
                            fdd_request_armed <= '0';
                            fdd_read_start <= '1';
                        ELSE
                            fdc_multi_sector_active <= '0';
                            fdc_drq_reg <= '0';
                            fdc_intrq_reg <= '1';
                            fdc_status_reg(0) <= '0';
                            fdc_read_address_active <= '0';
                        END IF;
                    ELSE
                        fdc_data_index <= fdc_data_index + 1;
                        fdd_buffer_addr <= STD_LOGIC_VECTOR(to_unsigned(fdc_data_index + 1, 8));
                    END IF;
                END IF;

                IF io_wr_now_v = '1' AND fdc_io_wr_last = '0' THEN
                    CASE cpu_a(7 DOWNTO 0) IS
                        WHEN x"E0" =>
                            command_v := cpu_do;
                            fdc_intrq_reg <= '0';
                            fdc_drq_reg <= '0';
                            fdc_data_read_pending <= '0';
                            fdc_read_address_active <= '0';
                            fdc_write_sector_active <= '0';
                            fdc_multi_sector_active <= '0';
                            fdc_write_track_active <= '0';
                            fdc_track_tail_active <= '0';
                            fdc_track_tail_count <= 0;
                            fdc_track_commit_active <= '0';
                            fdc_track_commit_wait <= '0';

                            CASE command_v(7 DOWNTO 4) IS
                                WHEN x"0" => -- RESTORE
                                    fdc_track_reg <= x"00";
                                    fdc_status_reg <= x"04";
                                    fdc_intrq_reg <= '1';

                                WHEN x"1" => -- SEEK (target in data register)
                                    fdc_track_reg <= fdc_data_reg;
                                    IF fdc_data_reg = x"00" THEN
                                        fdc_status_reg <= x"04";
                                    ELSE
                                        fdc_status_reg <= x"00";
                                    END IF;
                                    fdc_intrq_reg <= '1';

                                WHEN x"2" | x"3" => -- STEP
                                    IF fdc_track_reg = x"00" THEN
                                        fdc_status_reg <= x"04";
                                    ELSE
                                        fdc_status_reg <= x"00";
                                    END IF;
                                    fdc_intrq_reg <= '1';

                                WHEN x"4" | x"5" => -- STEP IN
                                    IF unsigned(fdc_track_reg) < to_unsigned(79, 8) THEN
                                        fdc_track_reg <= STD_LOGIC_VECTOR(unsigned(fdc_track_reg) + 1);
                                    END IF;
                                    fdc_status_reg <= x"00";
                                    fdc_intrq_reg <= '1';

                                WHEN x"6" | x"7" => -- STEP OUT
                                    IF fdc_track_reg /= x"00" THEN
                                        fdc_track_reg <= STD_LOGIC_VECTOR(unsigned(fdc_track_reg) - 1);
                                        fdc_status_reg <= x"00";
                                    ELSE
                                        fdc_status_reg <= x"04";
                                    END IF;
                                    fdc_intrq_reg <= '1';

                                WHEN x"8" | x"9" => -- READ SECTOR
                                    IF fdc_diag_read_active = '1' AND
                                        cpm_boot_overlay_enabled = '0' AND
                                        fdd_diag_valid = '0' THEN
                                        -- A new READ without the BIOS success-path D0 means
                                        -- the preceding READ returned early to BDOS.
                                        fdd_diag_valid <= '1';
                                        fdd_diag_sd_status(3 DOWNTO 0) <= x"C";
                                        fdd_diag_read_count <= STD_LOGIC_VECTOR(
                                            to_unsigned(fdc_diag_data_reads, 16));
                                    END IF;
                                    fdc_data_read_pending <= '0';
                                    drive_ready_v :=
                                        fdc_control_reg(5) = '1' AND (
                                        (fdc_control_reg(0) = '1' AND fdd_mount_a_valid = '1') OR
                                        (fdc_control_reg(1) = '1' AND fdd_mount_b_valid = '1'));
                                    IF NOT drive_ready_v THEN
                                        IF fdd_diag_valid = '0' THEN
                                            fdd_diag_valid <= '1';
                                            fdd_diag_cpm_position(31 DOWNTO 16) <= x"FFFF";
                                            fdd_diag_cpm_position(15 DOWNTO 8) <= fdc_track_reg;
                                            fdd_diag_cpm_position(7 DOWNTO 0) <= fdc_sector_reg;
                                            fdd_diag_fdd_position <= fdc_control_reg & x"000000";
                                            IF fdc_control_reg(0) = '1' THEN
                                                fdd_diag_cluster <= fdd_mount_a_cluster;
                                            ELSE
                                                fdd_diag_cluster <= fdd_mount_b_cluster;
                                            END IF;
                                            fdd_diag_sd_lba <= sd_read_lba;
                                            fdd_diag_sd_status <= sd_state_code & sd_debug_read_cmd17_r1 & sd_read_token & x"0E";
                                            fdd_diag_read_count <= sd_read_count;
                                            fdd_diag_first_word <= sd_read_first_word;
                                        END IF;
                                        fdc_status_reg <= x"80";
                                        fdc_intrq_reg <= '1';
                                    ELSIF unsigned(fdc_track_reg) >= to_unsigned(80, 8) OR
                                        unsigned(fdc_sector_reg) < to_unsigned(1, 8) OR
                                        unsigned(fdc_sector_reg) > to_unsigned(16, 8) THEN
                                        IF fdd_diag_valid = '0' THEN
                                            fdd_diag_valid <= '1';
                                            fdd_diag_cpm_position(31 DOWNTO 16) <= x"FFFF";
                                            fdd_diag_cpm_position(15 DOWNTO 8) <= fdc_track_reg;
                                            fdd_diag_cpm_position(7 DOWNTO 0) <= fdc_sector_reg;
                                            fdd_diag_fdd_position <= fdc_control_reg & x"000000";
                                            IF fdc_control_reg(0) = '1' THEN
                                                fdd_diag_cluster <= fdd_mount_a_cluster;
                                            ELSE
                                                fdd_diag_cluster <= fdd_mount_b_cluster;
                                            END IF;
                                            fdd_diag_sd_lba <= sd_read_lba;
                                            fdd_diag_sd_status <= sd_state_code & sd_debug_read_cmd17_r1 & sd_read_token & x"0F";
                                            fdd_diag_read_count <= sd_read_count;
                                            fdd_diag_first_word <= sd_read_first_word;
                                        END IF;
                                        fdc_status_reg <= x"10";
                                        fdc_intrq_reg <= '1';
                                    ELSIF fdd_read_busy = '0' THEN
                                        IF command_v(4) = '1' THEN
                                            fdc_multi_sector_active <= '1';
                                        END IF;
                                        image_sector_v :=
                                            to_integer(unsigned(fdc_track_reg)) * 32 +
                                            to_integer(unsigned(fdc_control_reg(4 DOWNTO 4))) * 16 +
                                            to_integer(unsigned(fdc_sector_reg)) - 1;
                                        sd_sector_v := image_sector_v / 2;
                                        IF fdd_diag_valid = '0' AND fdc_diag_read_active = '0' THEN
                                            fdd_diag_cpm_position(31 DOWNTO 24) <= STD_LOGIC_VECTOR(to_unsigned(
                                                (to_integer(UNSIGNED(fdc_track_reg)) * 2) +
                                                to_integer(UNSIGNED(fdc_control_reg(4 DOWNTO 4))), 8));
                                            fdd_diag_cpm_position(23 DOWNTO 16) <= STD_LOGIC_VECTOR(to_unsigned(
                                                ((to_integer(UNSIGNED(fdc_sector_reg)) - 1) * 2) +
                                                (image_sector_v MOD 2), 8));
                                            fdd_diag_cpm_position(15 DOWNTO 8) <= fdc_track_reg;
                                            fdd_diag_cpm_position(7 DOWNTO 0) <= fdc_sector_reg;
                                            fdd_diag_fdd_position(31 DOWNTO 24) <= fdc_control_reg;
                                            fdd_diag_fdd_position(23 DOWNTO 13) <=
                                                STD_LOGIC_VECTOR(to_unsigned(sd_sector_v, 11));
                                            IF (image_sector_v MOD 2) = 0 THEN
                                                fdd_diag_fdd_position(12) <= '0';
                                            ELSE
                                                fdd_diag_fdd_position(12) <= '1';
                                            END IF;
                                            fdd_diag_fdd_position(11 DOWNTO 0) <= (OTHERS => '0');
                                            IF fdc_control_reg(0) = '1' THEN
                                                fdd_diag_cluster <= fdd_mount_a_cluster;
                                            ELSE
                                                fdd_diag_cluster <= fdd_mount_b_cluster;
                                            END IF;
                                        END IF;
                                        IF fdc_control_reg(0) = '1' THEN
                                            fdd_read_cluster <= fdd_mount_a_cluster;
                                        ELSE
                                            fdd_read_cluster <= fdd_mount_b_cluster;
                                        END IF;
                                        fdd_read_sd_sector <= STD_LOGIC_VECTOR(to_unsigned(sd_sector_v, 11));
                                        IF (image_sector_v MOD 2) = 0 THEN
                                            fdd_read_half <= '0';
                                        ELSE
                                            fdd_read_half <= '1';
                                        END IF;
                                        fdc_status_reg <= x"01";
                                        IF cpm_boot_overlay_enabled = '0' THEN
                                            fdc_diag_read_active <= '1';
                                        ELSE
                                            -- The historical EPROM/stage-2 loader may start
                                            -- the following sector without the BIOS D0 epilogue.
                                            fdc_diag_read_active <= '0';
                                        END IF;
                                        fdc_diag_data_reads <= 0;
                                        fdc_data_last_index <= 255;
                                        fdd_request_armed <= '0';
                                        fdd_read_start <= '1';
                                    END IF;

                                WHEN x"A" | x"B" => -- WRITE SECTOR
                                    drive_ready_v :=
                                        fdc_control_reg(5) = '1' AND (
                                        (fdc_control_reg(0) = '1' AND fdd_mount_a_valid = '1') OR
                                        (fdc_control_reg(1) = '1' AND fdd_mount_b_valid = '1'));
                                    IF NOT drive_ready_v THEN
                                        fdc_status_reg <= x"80";
                                        fdc_intrq_reg <= '1';
                                    ELSIF unsigned(fdc_track_reg) >= to_unsigned(80, 8) OR
                                        unsigned(fdc_sector_reg) < to_unsigned(1, 8) OR
                                        unsigned(fdc_sector_reg) > to_unsigned(16, 8) THEN
                                        fdc_status_reg <= x"10";
                                        fdc_intrq_reg <= '1';
                                    ELSIF fdd_write_busy = '0' AND fdd_read_busy = '0' THEN
                                        -- The first A0 write to track 0,
                                        -- sector 1 starts the formatter's
                                        -- directory-clear sequence.  Once
                                        -- started, retain it through sector
                                        -- 16 without re-deriving state from
                                        -- the asynchronous SD backend.
                                        IF command_v(4) = '0' AND
                                            fdc_track_reg = x"00" AND
                                            fdc_sector_reg = x"01" AND
                                            fdc_format_directory_writes_left = 16 THEN
                                            fdc_format_directory_sequence_active <= '1';
                                            fdc_format_debug_reg <= x"41";
                                        ELSIF fdc_format_directory_sequence_active = '0' OR
                                            command_v(4) = '1' OR
                                            fdc_track_reg /= x"00" OR
                                            unsigned(fdc_sector_reg) < to_unsigned(1, 8) OR
                                            unsigned(fdc_sector_reg) > to_unsigned(16, 8) THEN
                                            fdc_format_directory_writes_left <= 0;
                                            fdc_format_directory_sequence_active <= '0';
                                        END IF;
                                        IF command_v(4) = '1' THEN
                                            fdc_multi_sector_active <= '1';
                                        END IF;
                                        image_sector_v :=
                                            to_integer(unsigned(fdc_track_reg)) * 32 +
                                            to_integer(unsigned(fdc_control_reg(4 DOWNTO 4))) * 16 +
                                            to_integer(unsigned(fdc_sector_reg)) - 1;
                                        sd_sector_v := image_sector_v / 2;
                                        IF fdc_control_reg(0) = '1' THEN
                                            fdd_write_cluster <= fdd_mount_a_cluster;
                                        ELSE
                                            fdd_write_cluster <= fdd_mount_b_cluster;
                                        END IF;
                                        fdd_write_sd_sector <= STD_LOGIC_VECTOR(to_unsigned(sd_sector_v, 11));
                                        IF (image_sector_v MOD 2) = 0 THEN
                                            fdd_write_half <= '0';
                                        ELSE
                                            fdd_write_half <= '1';
                                        END IF;
                                        fdc_status_reg <= x"01";
                                        fdc_data_index <= 0;
                                        fdc_data_last_index <= 255;
                                        fdc_write_sector_active <= '1';
                                        fdd_write_request_armed <= '0';
                                        fdc_drq_reg <= '1';
                                        fdc_intrq_reg <= '0';
                                    END IF;

                                WHEN x"F" => -- WRITE TRACK / format
                                    fdc_format_directory_writes_left <= 0;
                                    fdc_format_directory_sequence_active <= '0';
                                    fdc_format_debug_reg <= x"01";
                                    drive_ready_v :=
                                        fdc_control_reg(5) = '1' AND (
                                        (fdc_control_reg(0) = '1' AND fdd_mount_a_valid = '1') OR
                                        (fdc_control_reg(1) = '1' AND fdd_mount_b_valid = '1'));
                                    IF NOT drive_ready_v THEN
                                        fdc_format_debug_reg <= x"81";
                                        fdc_status_reg <= x"80";
                                        fdc_intrq_reg <= '1';
                                    ELSE
                                        -- The raw track buffer is independent
                                        -- of the SD backend.  Accept WRITE
                                        -- TRACK even if a preceding sector
                                        -- transfer is just finishing; commit
                                        -- waits for the backend below.
                                        IF fdd_write_busy = '1' OR
                                            fdd_read_busy = '1' OR
                                            fdd_format_busy = '1' THEN
                                            fdc_format_debug_reg <= x"02";
                                        END IF;
                                        fdc_status_reg <= x"01";
                                        fdc_drq_reg <= '1';
                                        fdc_intrq_reg <= '0';
                                        fdc_write_track_active <= '1';
                                        fdc_track_parse_state <= 0;
                                        fdc_track_sector_id <= 0;
                                        fdc_track_data_index <= 0;
                                        fdc_track_sector_count <= 0;
                                        fdc_track_tail_active <= '0';
                                        fdc_track_tail_count <= 0;
                                        fdc_track_commit_active <= '0';
                                        fdc_track_commit_wait <= '0';
                                        fdc_track_number <= fdc_track_reg;
                                        fdc_track_side <= fdc_control_reg(4);
                                        IF fdc_control_reg(0) = '1' THEN
                                            fdc_track_drive_b <= '0';
                                        ELSE
                                            fdc_track_drive_b <= '1';
                                        END IF;
                                    END IF;

                                WHEN x"C" => -- READ ADDRESS
                                    -- Let NAS-DOS finish its initial track/side
                                    -- synchronization even when no image is
                                    -- mounted.  The following READ SECTOR then
                                    -- reports the actual NOT READY status $80;
                                    -- failing here would be retried and collapsed
                                    -- by NAS-DOS into its generic error $1F.
                                    drive_ready_v :=
                                        fdc_control_reg(5) = '1' AND (
                                        fdc_control_reg(0) = '1' OR
                                        fdc_control_reg(1) = '1');
                                    IF NOT drive_ready_v THEN
                                        fdc_status_reg <= x"80";
                                        fdc_intrq_reg <= '1';
                                    ELSE
                                        fdc_status_reg <= x"01";
                                        fdc_data_index <= 0;
                                        fdc_data_last_index <= 5;
                                        fdc_read_address_active <= '1';
                                        fdc_drq_reg <= '1';
                                        fdc_intrq_reg <= '0';
                                    END IF;

                                WHEN x"D" => -- FORCE INTERRUPT
                                    fdc_status_reg <= x"00";
                                    fdc_intrq_reg <= '1';
                                    fdc_diag_read_active <= '0';

                                WHEN OTHERS =>
                                    fdc_status_reg <= x"10";
                                    fdc_intrq_reg <= '1';
                            END CASE;

                        WHEN x"E1" =>
                            fdc_track_reg <= cpu_do;

                        WHEN x"E2" =>
                            fdc_sector_reg <= cpu_do;

                        WHEN x"E3" =>
                            fdc_data_reg <= cpu_do;
                            IF fdc_write_sector_active = '1' AND fdc_drq_reg = '1' THEN
                                fdd_buffer_write_enable <= '1';
                                fdd_buffer_write_addr <=
                                    STD_LOGIC_VECTOR(to_unsigned(fdc_data_index, 8));
                                fdd_buffer_write_data <= cpu_do;
                                IF fdc_data_index = fdc_data_last_index THEN
                                    fdc_drq_reg <= '0';
                                    fdc_write_sector_active <= '0';
                                    fdd_write_start <= '1';
                                ELSE
                                    fdc_data_index <= fdc_data_index + 1;
                                END IF;
                            ELSIF fdc_write_track_active = '1' AND fdc_drq_reg = '1' THEN
                                IF fdc_track_tail_active = '1' THEN
                                    -- NAS-DOS sends 218 bytes after the last
                                    -- sector payload: CRC token, final gap and
                                    -- the index postamble.  The original driver
                                    -- verifies the complete 6115-byte transfer.
                                    IF fdc_track_tail_count = 1 THEN
                                        fdc_track_tail_count <= 0;
                                        fdc_track_tail_active <= '0';
                                        fdc_drq_reg <= '0';
                                        fdc_write_track_active <= '0';
                                        IF fdc_track_drive_b = '0' AND
                                            fdd_mount_a_cluster =
                                            fdd_mount_a_format_cluster THEN
                                            fdc_track_commit_active <= '1';
                                            fdc_track_commit_sector <= 0;
                                            fdc_track_commit_index <= 0;
                                            fdc_track_commit_wait <= '0';
                                        ELSIF fdc_track_drive_b = '1' AND
                                            fdd_mount_b_cluster =
                                            fdd_mount_b_format_cluster THEN
                                            fdc_track_commit_active <= '1';
                                            fdc_track_commit_sector <= 0;
                                            fdc_track_commit_index <= 0;
                                            fdc_track_commit_wait <= '0';
                                        ELSE
                                            fdd_format_request_armed <= '0';
                                            fdc_format_debug_reg <= x"10";
                                            IF fdc_track_drive_b = '0' THEN
                                                fdd_format_name <= fdd_mount_a_name;
                                                fdd_format_cluster <= fdd_mount_a_cluster;
                                            ELSE
                                                fdd_format_name <= fdd_mount_b_name;
                                                fdd_format_cluster <= fdd_mount_b_cluster;
                                            END IF;
                                            fdd_format_start <= '1';
                                        END IF;
                                    ELSE
                                        fdc_track_tail_count <= fdc_track_tail_count - 1;
                                    END IF;
                                ELSE
                                    CASE fdc_track_parse_state IS
                                    WHEN 0 =>
                                        IF cpu_do = x"FE" THEN
                                            fdc_track_parse_state <= 1;
                                        END IF;
                                    WHEN 1 =>
                                        -- Use the ID field as the authoritative
                                        -- formatted track number.  NAS-DOS may
                                        -- issue WRITE TRACK before the WD track
                                        -- register has caught up with its
                                        -- software-side format counter.
                                        IF unsigned(cpu_do) < to_unsigned(80, 8) THEN
                                            fdc_track_number <= cpu_do;
                                        ELSE
                                            fdc_format_debug_reg <= x"82";
                                        END IF;
                                        fdc_track_parse_state <= 2;
                                    WHEN 2 =>
                                        -- Likewise retain the side encoded in
                                        -- the raw ID fields (only 0/1 is valid
                                        -- for the fixed two-sided DSK image).
                                        IF cpu_do = x"00" OR cpu_do = x"01" THEN
                                            fdc_track_side <= cpu_do(0);
                                        ELSE
                                            fdc_format_debug_reg <= x"83";
                                        END IF;
                                        fdc_track_parse_state <= 3;
                                    WHEN 3 =>
                                        IF unsigned(cpu_do) >= to_unsigned(1, 8) AND
                                            unsigned(cpu_do) <= to_unsigned(16, 8) THEN
                                            fdc_track_sector_id <= to_integer(unsigned(cpu_do));
                                        ELSE
                                            fdc_track_sector_id <= 0;
                                        END IF;
                                        fdc_track_parse_state <= 4;
                                    WHEN 4 =>
                                        -- Sector size code; NAS-DOS uses 01
                                        -- for the fixed 256-byte DSK geometry.
                                        fdc_track_parse_state <= 5;
                                    WHEN 5 =>
                                        IF (cpu_do = x"FB" OR cpu_do = x"F8") AND
                                            fdc_track_sector_id > 0 THEN
                                            fdc_track_data_index <= 0;
                                            fdc_track_parse_state <= 6;
                                        ELSIF cpu_do = x"FE" THEN
                                            fdc_track_parse_state <= 1;
                                        END IF;
                                    WHEN OTHERS =>
                                        fdc_track_buffer_reg(
                                            ((fdc_track_sector_id - 1) * 256) +
                                            fdc_track_data_index) <= cpu_do;
                                        IF fdc_track_data_index = 255 THEN
                                            fdc_track_parse_state <= 0;
                                            IF fdc_track_sector_count = 15 THEN
                                                fdc_track_sector_count <= 16;
                                                fdc_track_tail_active <= '1';
                                                fdc_track_tail_count <= 218;
                                            ELSE
                                                fdc_track_sector_count <=
                                                    fdc_track_sector_count + 1;
                                            END IF;
                                        ELSE
                                            fdc_track_data_index <= fdc_track_data_index + 1;
                                        END IF;
                                    END CASE;
                                END IF;
                            END IF;

                        WHEN x"E7" =>
                            -- Values emitted only by the CP/M BIOS READ
                            -- error path; pack them into the F7 latch.
                            fdd_diag_valid <= '1';
                            fdd_diag_sd_status(3 DOWNTO 0) <= x"B";
                            fdd_diag_first_word(31 DOWNTO 24) <= cpu_do;

                        WHEN x"E8" =>
                            fdd_diag_first_word(23 DOWNTO 16) <= cpu_do;
                            fdd_diag_cpm_position(31 DOWNTO 24) <= cpu_do;

                        WHEN x"E9" =>
                            fdd_diag_first_word(15 DOWNTO 8) <= cpu_do;
                            fdd_diag_cpm_position(23 DOWNTO 16) <= cpu_do;

                        WHEN x"EA" =>
                            fdd_diag_first_word(7 DOWNTO 0) <= cpu_do;

                        WHEN x"E4" =>
                            -- NAS-DOS uses motor-on with no explicit drive
                            -- bit for its current/default drive path.  With
                            -- no prior ]D0 selection that value is $20.
                            -- The Lucas/NAS-DOS default is drive 0, so make
                            -- the implicit and explicit forms equivalent.
                            IF cpu_do(5) = '1' AND cpu_do(1 DOWNTO 0) = "00" THEN
                                fdc_control_reg <= cpu_do OR x"01";
                            ELSE
                                fdc_control_reg <= cpu_do;
                            END IF;

                        WHEN OTHERS =>
                            NULL;
                    END CASE;
                END IF;
            END IF;

            fdc_io_wr_last <= io_wr_now_v;
            fdc_io_rd_last <= io_rd_now_v;
        END IF;
    END PROCESS;

    --------------------------------------------------------------------
    -- SD file loader write staging
    --
    -- Stage loader writes once in the top-level before the RAM decode so
    -- the long address/decode path is not driven directly from sd_spi_init.
    --------------------------------------------------------------------
    PROCESS (clk100)
    BEGIN
        IF rising_edge(clk100) THEN
            IF sys_reset = '1' THEN
                sd_file_mem_wr_q <= '0';
                sd_file_mem_addr_q <= x"0000";
                sd_file_mem_data_q <= x"00";
                sd_file_read_done_q <= '0';
                sd_file_read_is_cas_active <= '0';
                sd_file_read_is_pas_active <= '0';
            ELSE
                sd_file_mem_wr_q <= sd_file_mem_wr;
                sd_file_mem_addr_q <= sd_file_mem_addr;
                sd_file_mem_data_q <= sd_file_mem_data;
                -- Keep completion in the same pipeline stage as the staged
                -- RAM write.  Otherwise the BASIC/Pascal load trackers can
                -- finish one clock before seeing the final file byte.
                sd_file_read_done_q <= sd_read_done;
                IF ui_sd_file_read_start = '1' THEN
                    sd_file_read_is_cas_active <= sd_selected_is_cas;
                    sd_file_read_is_pas_active <= sd_selected_is_pas;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    mainram_sys_we(0) <= '1' WHEN god_mem_wr = '1' OR basic_fix_mainram_wr_sel = '1' OR sdq_mainram_wr_sel = '1' OR cpu_mainram_wr_sel = '1' ELSE
    '0';
    mainram_sys_addr <= STD_LOGIC_VECTOR(resize(unsigned(basic_load_fix_addr) - RAM_BASE, MAIN_RAM_ADDR_WIDTH))
        WHEN basic_fix_mainram_wr_sel = '1'
        ELSE
        STD_LOGIC_VECTOR(resize(unsigned(sd_file_mem_addr_q) - RAM_BASE, MAIN_RAM_ADDR_WIDTH))
        WHEN sdq_mainram_wr_sel = '1'
        ELSE
        STD_LOGIC_VECTOR(resize(unsigned(god_mem_wr_addr) - RAM_BASE, MAIN_RAM_ADDR_WIDTH))
        WHEN god_mem_wr = '1'
        ELSE
        STD_LOGIC_VECTOR(resize(unsigned(cpu_a) - RAM_BASE, MAIN_RAM_ADDR_WIDTH))
        WHEN cpu_mainram_wr_sel = '1'
        ELSE
        (OTHERS => '0');
    mainram_sys_din <= basic_load_fix_data WHEN basic_load_fix_wr = '1' ELSE
        sd_file_mem_data_q WHEN sd_file_mem_wr_q = '1' ELSE
        god_mem_wr_data WHEN god_mem_wr = '1' ELSE
        cpu_do;

    --------------------------------------------------------------------
    -- BASIC-Load-Erkennung und Pointer-Fixup nach einem BASIC-Dateiload
    --
    -- Ein F9-BASIC-Save enthaelt bewusst nur den Programmbereich ab 10FA.
    -- Nach dem Laden setzen wir deshalb die bekannten BASIC-Pointer wieder
    -- konsistent, statt den kompletten Bereich ab 1000 mitzuschleppen.
    --------------------------------------------------------------------
    PROCESS (clk100)
        VARIABLE next_last_addr_v : UNSIGNED(15 DOWNTO 0);
        VARIABLE basic_start_seen_v : BOOLEAN;
        VARIABLE basic_track_this_load_v : BOOLEAN;
        VARIABLE basic_next_line_ptr_v : UNSIGNED(15 DOWNTO 0);
        VARIABLE basic_first_link_ptr_v : UNSIGNED(15 DOWNTO 0);
        VARIABLE basic_candidate_v : BOOLEAN;
        VARIABLE bls_next_last_addr_v : UNSIGNED(15 DOWNTO 0);
        VARIABLE bls_start_seen_v : BOOLEAN;
        VARIABLE bls_track_this_load_v : BOOLEAN;
        VARIABLE bls_candidate_v : BOOLEAN;
    BEGIN
        IF rising_edge(clk100) THEN
            basic_load_fix_wr <= '0';

            IF sys_reset = '1' THEN
                basic_load_track_active <= '0';
                basic_load_last_addr <= x"0000";
                basic_load_fix_eval_pending <= '0';
                basic_load_fix_start_pending <= '0';
                basic_load_fix_pending_end_ptr <= x"0000";
                basic_load_fix_end_ptr <= x"0000";
                basic_load_init_index <= (OTHERS => '0');
                basic_load_fix_state <= BASIC_LOAD_FIX_IDLE;
                basic_load_fix_addr <= x"0000";
                basic_load_fix_data <= x"00";
                basic_load_first_link_lo <= x"00";
                basic_load_first_link_hi <= x"00";
                basic_load_first_term <= x"00";
                basic_load_first_term_valid <= '0';
                basic_load_tail_prev <= x"00";
                basic_load_tail_last <= x"00";
                bls_load_track_active <= '0';
                bls_load_last_addr <= x"0000";
                bls_load_tail_last <= x"00";
                bls_load_fix_eval_pending <= '0';
                bls_load_fix_end_ptr <= unsigned(BLS_LOAD_START_ADDR);
                basic_autostart_req <= '0';
            ELSIF sd_read_error = '1' OR ui_sd_file_read_start = '1' THEN
                -- Never finish/autostart an earlier partial load on a later SD completion.
                basic_load_track_active <= '0';
                bls_load_track_active <= '0';
                basic_load_fix_eval_pending <= '0';
                bls_load_fix_eval_pending <= '0';
                basic_load_fix_start_pending <= '0';
                basic_load_fix_state <= BASIC_LOAD_FIX_IDLE;
                basic_autostart_req <= '0';
            ELSE
                next_last_addr_v := basic_load_last_addr;
                basic_start_seen_v := FALSE;
                basic_track_this_load_v := basic_load_track_active = '1';
                bls_next_last_addr_v := bls_load_last_addr;
                bls_start_seen_v := FALSE;
                bls_track_this_load_v := bls_load_track_active = '1';

                IF sd_file_mem_wr_q = '1' THEN
                    basic_start_seen_v := sd_file_read_is_pas_active = '0' AND
                        (sd_file_mem_addr_q = BASIC_LOAD_START_ADDR OR
                        (sd_file_read_is_cas_active = '1' AND
                        (sd_file_mem_addr_q = BASIC_CAS_LOAD_START_ADDR OR
                        (sd_file_load_addr_valid = '1' AND
                         sd_file_load_addr = BASIC_CAS_LOAD_START_ADDR))));

                    IF basic_load_track_active = '0' AND basic_start_seen_v THEN
                        basic_load_track_active <= '1';
                        basic_track_this_load_v := TRUE;
                        next_last_addr_v := (OTHERS => '0');
                        basic_load_first_link_lo <= x"00";
                        basic_load_first_link_hi <= x"00";
                        basic_load_first_term <= x"00";
                        basic_load_first_term_valid <= '0';
                        basic_load_tail_prev <= x"00";
                        basic_load_tail_last <= x"00";
                    END IF;

                    IF basic_track_this_load_v THEN
                        IF sd_file_mem_addr_q = BASIC_LOAD_START_ADDR THEN
                            basic_load_first_link_lo <= sd_file_mem_data_q;
                        ELSIF sd_file_mem_addr_q = STD_LOGIC_VECTOR(unsigned(BASIC_LOAD_START_ADDR) + 1) THEN
                            basic_load_first_link_hi <= sd_file_mem_data_q;
                        END IF;

                        basic_first_link_ptr_v(15 DOWNTO 8) := unsigned(basic_load_first_link_hi);
                        basic_first_link_ptr_v(7 DOWNTO 0) := unsigned(basic_load_first_link_lo);
                        IF basic_first_link_ptr_v > unsigned(BASIC_LOAD_START_ADDR) AND
                            unsigned(sd_file_mem_addr_q) + 1 = basic_first_link_ptr_v THEN
                            basic_load_first_term <= sd_file_mem_data_q;
                            basic_load_first_term_valid <= '1';
                        END IF;
                    END IF;

                    IF basic_track_this_load_v AND
                        unsigned(sd_file_mem_addr_q) >= unsigned(BASIC_LOAD_START_ADDR) AND
                        unsigned(sd_file_mem_addr_q) > next_last_addr_v THEN
                        next_last_addr_v := unsigned(sd_file_mem_addr_q);
                        basic_load_tail_prev <= basic_load_tail_last;
                        basic_load_tail_last <= sd_file_mem_data_q;
                    END IF;

                    bls_start_seen_v := cfg_bls_active = '1' AND
                        sd_file_read_is_pas_active = '1' AND
                        sd_file_mem_addr_q = BLS_LOAD_START_ADDR;
                    IF bls_load_track_active = '0' AND bls_start_seen_v THEN
                        bls_load_track_active <= '1';
                        bls_track_this_load_v := TRUE;
                        bls_next_last_addr_v := (OTHERS => '0');
                        bls_load_tail_last <= x"00";
                    END IF;

                    IF bls_track_this_load_v AND
                        unsigned(sd_file_mem_addr_q) >= unsigned(BLS_LOAD_START_ADDR) AND
                        unsigned(sd_file_mem_addr_q) < BLS_LOAD_LIMIT_ADDR AND
                        unsigned(sd_file_mem_addr_q) > bls_next_last_addr_v THEN
                        bls_next_last_addr_v := unsigned(sd_file_mem_addr_q);
                        bls_load_tail_last <= sd_file_mem_data_q;
                    END IF;
                END IF;

                basic_load_last_addr <= next_last_addr_v;
                bls_load_last_addr <= bls_next_last_addr_v;

                IF basic_load_track_active = '1' AND sd_file_read_done_q = '1' THEN
                    basic_load_track_active <= '0';
                    basic_load_fix_eval_pending <= '1';
                END IF;
                IF bls_load_track_active = '1' AND sd_file_read_done_q = '1' THEN
                    bls_load_track_active <= '0';
                    bls_load_fix_eval_pending <= '1';
                END IF;

                IF basic_load_fix_eval_pending = '1' AND basic_load_fix_state = BASIC_LOAD_FIX_IDLE THEN
                    basic_load_fix_eval_pending <= '0';
                    basic_next_line_ptr_v(7 DOWNTO 0) := unsigned(basic_load_first_link_lo);
                    basic_next_line_ptr_v(15 DOWNTO 8) := unsigned(basic_load_first_link_hi);
                    basic_candidate_v :=
                        basic_load_last_addr >= to_unsigned(16#10FD#, 16) AND
                        basic_next_line_ptr_v >= to_unsigned(16#10FF#, 16) AND
                        basic_next_line_ptr_v <= basic_load_last_addr + 1 AND
                        basic_load_first_term_valid = '1' AND
                        basic_load_first_term = x"00" AND
                        basic_load_tail_prev = x"00" AND
                        basic_load_tail_last = x"00";
                    IF basic_candidate_v THEN
                        basic_load_fix_pending_end_ptr <= basic_load_last_addr + 1;
                        basic_load_fix_start_pending <= '1';
                    END IF;
                END IF;

                IF basic_load_fix_start_pending = '1' AND basic_load_fix_state = BASIC_LOAD_FIX_IDLE THEN
                    basic_load_fix_start_pending <= '0';
                    basic_load_fix_end_ptr <= basic_load_fix_pending_end_ptr;
                    basic_load_init_index <= (OTHERS => '0');
                    basic_load_fix_state <= BASIC_LOAD_FIX_COPY_WORK_INIT;
                END IF;

                IF bls_load_fix_eval_pending = '1' AND basic_load_fix_state = BASIC_LOAD_FIX_IDLE THEN
                    bls_load_fix_eval_pending <= '0';
                    bls_candidate_v := cfg_bls_active = '1' AND
                        bls_load_last_addr >= unsigned(BLS_LOAD_START_ADDR) AND
                        bls_load_last_addr < BLS_LOAD_LIMIT_ADDR AND
                        bls_load_tail_last = x"0D";
                    IF bls_candidate_v THEN
                        bls_load_fix_end_ptr <= bls_load_last_addr;
                        basic_load_fix_state <= BLS_LOAD_FIX_TEXT_END_LO;
                    END IF;
                END IF;

                IF basic_load_fix_state /= BASIC_LOAD_FIX_IDLE AND sd_file_mem_wr_q = '0' THEN
                    basic_load_fix_wr <= '1';

                    CASE basic_load_fix_state IS
                        WHEN BASIC_LOAD_FIX_COPY_WORK_INIT =>
                            basic_load_fix_addr <= STD_LOGIC_VECTOR(BASIC_WORK_INIT_RAM_BASE + resize(basic_load_init_index, 16));
                            basic_load_fix_data <= BASIC_ROM(BASIC_WORK_INIT_ROM_BASE + to_integer(basic_load_init_index));
                            IF basic_load_init_index = BASIC_WORK_INIT_LAST THEN
                                basic_load_fix_state <= BASIC_LOAD_FIX_INIT_LO;
                            ELSE
                                basic_load_init_index <= basic_load_init_index + 1;
                            END IF;

                        WHEN BASIC_LOAD_FIX_INIT_LO =>
                            basic_load_fix_addr <= x"105E";
                            basic_load_fix_data <= x"FA";
                            basic_load_fix_state <= BASIC_LOAD_FIX_INIT_HI;

                        WHEN BASIC_LOAD_FIX_INIT_HI =>
                            basic_load_fix_addr <= x"105F";
                            basic_load_fix_data <= x"10";
                            basic_load_fix_state <= BASIC_LOAD_FIX_ENDPTR_LO;

                        WHEN BASIC_LOAD_FIX_ENDPTR_LO =>
                            basic_load_fix_addr <= x"10D6";
                            basic_load_fix_data <= STD_LOGIC_VECTOR(basic_load_fix_end_ptr(7 DOWNTO 0));
                            basic_load_fix_state <= BASIC_LOAD_FIX_ENDPTR_HI;

                        WHEN BASIC_LOAD_FIX_ENDPTR_HI =>
                            basic_load_fix_addr <= x"10D7";
                            basic_load_fix_data <= STD_LOGIC_VECTOR(basic_load_fix_end_ptr(15 DOWNTO 8));
                            basic_load_fix_state <= BASIC_LOAD_FIX_VARTAB_LO;

                        WHEN BASIC_LOAD_FIX_VARTAB_LO =>
                            basic_load_fix_addr <= x"10D8";
                            basic_load_fix_data <= STD_LOGIC_VECTOR(basic_load_fix_end_ptr(7 DOWNTO 0));
                            basic_load_fix_state <= BASIC_LOAD_FIX_VARTAB_HI;

                        WHEN BASIC_LOAD_FIX_VARTAB_HI =>
                            basic_load_fix_addr <= x"10D9";
                            basic_load_fix_data <= STD_LOGIC_VECTOR(basic_load_fix_end_ptr(15 DOWNTO 8));
                            basic_load_fix_state <= BASIC_LOAD_FIX_ARYTAB_LO;

                        WHEN BASIC_LOAD_FIX_ARYTAB_LO =>
                            basic_load_fix_addr <= x"10DA";
                            basic_load_fix_data <= STD_LOGIC_VECTOR(basic_load_fix_end_ptr(7 DOWNTO 0));
                            basic_load_fix_state <= BASIC_LOAD_FIX_ARYTAB_HI;

                        WHEN BASIC_LOAD_FIX_ARYTAB_HI =>
                            basic_load_fix_addr <= x"10DB";
                            basic_load_fix_data <= STD_LOGIC_VECTOR(basic_load_fix_end_ptr(15 DOWNTO 8));
                            basic_load_fix_state <= BASIC_LOAD_FIX_CURTXT_LO;

                        WHEN BASIC_LOAD_FIX_CURTXT_LO =>
                            basic_load_fix_addr <= x"10CE";
                            basic_load_fix_data <= BASIC_LOAD_PRE_START_ADDR(7 DOWNTO 0);
                            basic_load_fix_state <= BASIC_LOAD_FIX_CURTXT_HI;

                        WHEN BASIC_LOAD_FIX_CURTXT_HI =>
                            basic_load_fix_addr <= x"10CF";
                            basic_load_fix_data <= BASIC_LOAD_PRE_START_ADDR(15 DOWNTO 8);
                            basic_load_fix_state <= BASIC_LOAD_FIX_MEMTOP_LO;

                        WHEN BASIC_LOAD_FIX_MEMTOP_LO =>
                            basic_load_fix_addr <= x"10AF";
                            basic_load_fix_data <= BASIC_LOAD_MAX_RAM_ADDR(7 DOWNTO 0);
                            basic_load_fix_state <= BASIC_LOAD_FIX_MEMTOP_HI;

                        WHEN BASIC_LOAD_FIX_MEMTOP_HI =>
                            basic_load_fix_addr <= x"10B0";
                            basic_load_fix_data <= BASIC_LOAD_MAX_RAM_ADDR(15 DOWNTO 8);
                            basic_load_fix_state <= BASIC_LOAD_FIX_STRTOP_LO;

                        WHEN BASIC_LOAD_FIX_STRTOP_LO =>
                            basic_load_fix_addr <= x"105A";
                            basic_load_fix_data <= BASIC_LOAD_STRING_TOP_ADDR(7 DOWNTO 0);
                            basic_load_fix_state <= BASIC_LOAD_FIX_STRTOP_HI;

                        WHEN BASIC_LOAD_FIX_STRTOP_HI =>
                            basic_load_fix_addr <= x"105B";
                            basic_load_fix_data <= BASIC_LOAD_STRING_TOP_ADDR(15 DOWNTO 8);
                            basic_load_fix_state <= BASIC_LOAD_FIX_WORKPTR_LO;

                        WHEN BASIC_LOAD_FIX_WORKPTR_LO =>
                            basic_load_fix_addr <= x"10B1";
                            basic_load_fix_data <= BASIC_LOAD_WORK_START_ADDR(7 DOWNTO 0);
                            basic_load_fix_state <= BASIC_LOAD_FIX_WORKPTR_HI;

                        WHEN BASIC_LOAD_FIX_WORKPTR_HI =>
                            basic_load_fix_addr <= x"10B2";
                            basic_load_fix_data <= BASIC_LOAD_WORK_START_ADDR(15 DOWNTO 8);
                            basic_load_fix_state <= BASIC_LOAD_FIX_MEMCOPY_LO;

                        WHEN BASIC_LOAD_FIX_MEMCOPY_LO =>
                            basic_load_fix_addr <= x"10C3";
                            basic_load_fix_data <= BASIC_LOAD_MAX_RAM_ADDR(7 DOWNTO 0);
                            basic_load_fix_state <= BASIC_LOAD_FIX_MEMCOPY_HI;

                        WHEN BASIC_LOAD_FIX_MEMCOPY_HI =>
                            basic_load_fix_addr <= x"10C4";
                            basic_load_fix_data <= BASIC_LOAD_MAX_RAM_ADDR(15 DOWNTO 8);
                            basic_load_fix_state <= BASIC_LOAD_FIX_IDLE;
                            basic_autostart_req <= NOT basic_autostart_req;

                        WHEN BLS_LOAD_FIX_TEXT_END_LO =>
                            basic_load_fix_addr <= x"0C82";
                            basic_load_fix_data <= STD_LOGIC_VECTOR(bls_load_fix_end_ptr(7 DOWNTO 0));
                            basic_load_fix_state <= BLS_LOAD_FIX_TEXT_END_HI;

                        WHEN BLS_LOAD_FIX_TEXT_END_HI =>
                            basic_load_fix_addr <= x"0C83";
                            basic_load_fix_data <= STD_LOGIC_VECTOR(bls_load_fix_end_ptr(15 DOWNTO 8));
                            basic_load_fix_state <= BLS_LOAD_FIX_OBJECT_END_LO;

                        WHEN BLS_LOAD_FIX_OBJECT_END_LO =>
                            basic_load_fix_addr <= x"0C84";
                            basic_load_fix_data <= x"00";
                            basic_load_fix_state <= BLS_LOAD_FIX_OBJECT_END_HI;

                        WHEN BLS_LOAD_FIX_OBJECT_END_HI =>
                            basic_load_fix_addr <= x"0C85";
                            basic_load_fix_data <= x"00";
                            basic_load_fix_state <= BLS_LOAD_FIX_EDITOR_POS_LO;

                        WHEN BLS_LOAD_FIX_EDITOR_POS_LO =>
                            basic_load_fix_addr <= x"0C86";
                            basic_load_fix_data <= BLS_LOAD_START_ADDR(7 DOWNTO 0);
                            basic_load_fix_state <= BLS_LOAD_FIX_EDITOR_POS_HI;

                        WHEN BLS_LOAD_FIX_EDITOR_POS_HI =>
                            basic_load_fix_addr <= x"0C87";
                            basic_load_fix_data <= BLS_LOAD_START_ADDR(15 DOWNTO 8);
                            basic_load_fix_state <= BLS_LOAD_FIX_EDITOR_TOP_LO;

                        WHEN BLS_LOAD_FIX_EDITOR_TOP_LO =>
                            basic_load_fix_addr <= x"0C88";
                            basic_load_fix_data <= BLS_LOAD_START_ADDR(7 DOWNTO 0);
                            basic_load_fix_state <= BLS_LOAD_FIX_EDITOR_TOP_HI;

                        WHEN BLS_LOAD_FIX_EDITOR_TOP_HI =>
                            basic_load_fix_addr <= x"0C89";
                            basic_load_fix_data <= BLS_LOAD_START_ADDR(15 DOWNTO 8);
                            basic_load_fix_state <= BASIC_LOAD_FIX_IDLE;

                        WHEN OTHERS =>
                            basic_load_fix_state <= BASIC_LOAD_FIX_IDLE;
                    END CASE;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    -- RAM WRITE
    ----------------------------------------------------------------
    PROCESS (clk100)
    BEGIN
        IF rising_edge(clk100) THEN
            IF god_mem_wr = '1' THEN
                IF god_mem_wr_addr = x"105E" THEN
                    basic_init_lo_shadow <= god_mem_wr_data;
                ELSIF god_mem_wr_addr = x"105F" THEN
                    basic_init_hi_shadow <= god_mem_wr_data;
                ELSIF god_mem_wr_addr = x"10D6" THEN
                    basic_endptr_lo_shadow <= god_mem_wr_data;
                ELSIF god_mem_wr_addr = x"10D7" THEN
                    basic_endptr_hi_shadow <= god_mem_wr_data;
                ELSIF god_mem_wr_addr = x"0C82" THEN
                    bls_text_end_lo_shadow <= god_mem_wr_data;
                ELSIF god_mem_wr_addr = x"0C83" THEN
                    bls_text_end_hi_shadow <= god_mem_wr_data;
                END IF;
            ELSIF basic_load_fix_wr = '1' THEN
                IF basic_fix_mainram_wr_sel = '1' THEN
                    IF basic_load_fix_addr = x"105E" THEN
                        basic_init_lo_shadow <= basic_load_fix_data;
                    ELSIF basic_load_fix_addr = x"105F" THEN
                        basic_init_hi_shadow <= basic_load_fix_data;
                    ELSIF basic_load_fix_addr = x"10D6" THEN
                        basic_endptr_lo_shadow <= basic_load_fix_data;
                    ELSIF basic_load_fix_addr = x"10D7" THEN
                        basic_endptr_hi_shadow <= basic_load_fix_data;
                    ELSIF basic_load_fix_addr = x"0C82" THEN
                        bls_text_end_lo_shadow <= basic_load_fix_data;
                    ELSIF basic_load_fix_addr = x"0C83" THEN
                        bls_text_end_hi_shadow <= basic_load_fix_data;
                    END IF;
                END IF;
            ELSIF sd_file_mem_wr_q = '1' THEN
                CASE sd_file_mem_addr_q(15 DOWNTO 12) IS
                    WHEN x"0" | x"1" | x"2" | x"3" | x"4" | x"5" | x"6" | x"7" | x"8" | x"9" | x"A" =>
                        IF sdq_mainram_wr_sel = '1' THEN
                            IF sd_file_mem_addr_q = x"105E" THEN
                                basic_init_lo_shadow <= sd_file_mem_data_q;
                            ELSIF sd_file_mem_addr_q = x"105F" THEN
                                basic_init_hi_shadow <= sd_file_mem_data_q;
                            ELSIF sd_file_mem_addr_q = x"10D6" THEN
                                basic_endptr_lo_shadow <= sd_file_mem_data_q;
                            ELSIF sd_file_mem_addr_q = x"10D7" THEN
                                basic_endptr_hi_shadow <= sd_file_mem_data_q;
                            ELSIF sd_file_mem_addr_q = x"0C82" THEN
                                bls_text_end_lo_shadow <= sd_file_mem_data_q;
                            ELSIF sd_file_mem_addr_q = x"0C83" THEN
                                bls_text_end_hi_shadow <= sd_file_mem_data_q;
                            END IF;
                        END IF;

                    WHEN x"B" =>
                        IF NOT FAST_BUILD_TRIM_MEMORY AND cfg_bls_active = '0' THEN
                            IF sd_file_mem_addr_q(11) = '0' THEN
                                IF cfg_slot_rom_active(0) = '0' THEN
                                    TOOLKIT_RAM(to_integer(unsigned(sd_file_mem_addr_q) - TOOLKIT_BASE)) <= sd_file_mem_data_q;
                                END IF;
                            ELSE
                                IF cfg_slot_rom_active(1) = '0' THEN
                                    NASPEN_RAM(to_integer(unsigned(sd_file_mem_addr_q) - NASPEN_BASE)) <= sd_file_mem_data_q;
                                END IF;
                            END IF;
                        END IF;

                    WHEN x"C" =>
                        IF (NOT FAST_BUILD_TRIM_MEMORY) AND cfg_bls_active = '0' AND cfg_slot_rom_active(2) = '0' THEN
                            NASDIS_RAM(to_integer(unsigned(sd_file_mem_addr_q) - NASDIS_BASE)) <= sd_file_mem_data_q;
                        END IF;

                    WHEN x"D" =>
                        IF (NOT FAST_BUILD_TRIM_MEMORY) AND
                            (cfg_bls_active = '1' OR cfg_slot_rom_active(3) = '0') THEN
                            ZEAP_RAM(to_integer(unsigned(sd_file_mem_addr_q) - ZEAP_BASE)) <= sd_file_mem_data_q;
                        END IF;

                    WHEN OTHERS =>
                        NULL;
                END CASE;
            ELSIF mreq_n = '0' AND wr_n = '0' THEN
                CASE cpu_a(15 DOWNTO 12) IS
                    WHEN x"0" | x"1" | x"2" | x"3" | x"4" | x"5" | x"6" | x"7" | x"8" | x"9" | x"A" =>
                        IF cpu_mainram_wr_sel = '1' THEN
                            IF cpu_a = x"105E" THEN
                                basic_init_lo_shadow <= cpu_do;
                            ELSIF cpu_a = x"105F" THEN
                                basic_init_hi_shadow <= cpu_do;
                            ELSIF cpu_a = x"10D6" THEN
                                basic_endptr_lo_shadow <= cpu_do;
                            ELSIF cpu_a = x"10D7" THEN
                                basic_endptr_hi_shadow <= cpu_do;
                            ELSIF cpu_a = x"0C82" THEN
                                bls_text_end_lo_shadow <= cpu_do;
                            ELSIF cpu_a = x"0C83" THEN
                                bls_text_end_hi_shadow <= cpu_do;
                            END IF;
                        END IF;

                    WHEN x"B" =>
                        IF NOT FAST_BUILD_TRIM_MEMORY AND avc_cpu_mem_sel = '0' AND cfg_bls_active = '0' THEN
                            IF cpu_a(11) = '0' THEN
                                IF cfg_slot_rom_active(0) = '0' THEN
                                    TOOLKIT_RAM(to_integer(unsigned(cpu_a) - TOOLKIT_BASE)) <= cpu_do;
                                END IF;
                            ELSE
                                IF cfg_slot_rom_active(1) = '0' THEN
                                    NASPEN_RAM(to_integer(unsigned(cpu_a) - NASPEN_BASE)) <= cpu_do;
                                END IF;
                            END IF;
                        END IF;

                    WHEN x"C" =>
                        IF (NOT FAST_BUILD_TRIM_MEMORY) AND cfg_bls_active = '0' AND cfg_slot_rom_active(2) = '0' THEN
                            NASDIS_RAM(to_integer(unsigned(cpu_a) - NASDIS_BASE)) <= cpu_do;
                        END IF;

                    WHEN x"D" =>
                        IF (NOT FAST_BUILD_TRIM_MEMORY) AND
                            (cfg_bls_active = '1' OR cfg_slot_rom_active(3) = '0') THEN
                            ZEAP_RAM(to_integer(unsigned(cpu_a) - ZEAP_BASE)) <= cpu_do;
                        END IF;

                    WHEN OTHERS =>
                        NULL;
                END CASE;
            END IF;

            -- MAIN_RAM deliberately survives a system reset.  Keep these
            -- mirrors as well: a BASIC warm start (NAS-SYS "Z") reuses the
            -- workspace already in RAM and does not necessarily rewrite the
            -- init/end pointers.  Clearing only the mirrors here therefore
            -- made F9 report "BASIC not initialized" although the program
            -- itself was still intact.  The declaration initial values still
            -- provide the required cleared state after FPGA configuration.
        END IF;
    END PROCESS;

    ----------------------------------------------------------------
    -- AVC PLANE MEMORY ACCESS
    --
    -- The physical AVC can page any combination of planes over the same
    -- 16 KiB CPU window.  Writes are broadcast to all selected planes.
    -- Hardware prevents a read-bus clash; software normally selects one
    -- plane, and for compatibility we give red, green, blue that priority.
    ----------------------------------------------------------------
    PROCESS (clk100)
        VARIABLE cpu_avc_addr_v : STD_LOGIC_VECTOR(13 DOWNTO 0);
        VARIABLE terminal_addr_v : INTEGER RANGE 0 TO 32767;
        VARIABLE next_terminal_start_v : UNSIGNED(14 DOWNTO 0);
        VARIABLE glyph_addr_v : INTEGER RANGE 0 TO 4095;
    BEGIN
        IF rising_edge(clk100) THEN
            avc_sys_en <= '0';
            avc_sys_we <= "000";
            avc_sys_din <= cpu_do;
            avc_wait_n_i <= '1';
            cpu_avc_addr_v := cpu_a(13 DOWNTO 0);

            IF raw_reset_req = '1' THEN
                avc_read_state <= AVC_READ_IDLE;
                avc_read_addr <= (OTHERS => '0');
                avc_read_plane <= 0;
                avc_read_data <= x"00";
                avc_terminal_ack_toggle <= '0';
                avc_terminal_state <= AVC_TERM_IDLE;
                avc_terminal_col <= 0;
                avc_terminal_row <= 0;
                avc_terminal_glyph_row <= 0;
                avc_terminal_start_addr <= (OTHERS => '0');
                avc_terminal_clear_addr <= (OTHERS => '0');
                avc_terminal_clear_col <= 0;
                avc_terminal_escape_state <= 0;
                avc_terminal_scroll_base <= (OTHERS => '0');
                avc_terminal_scroll_offset <= 0;
            ELSE
                CASE avc_terminal_state IS
                    WHEN AVC_TERM_IDLE =>
                        IF avc_terminal_req_toggle /= avc_terminal_ack_toggle THEN
                            IF avc_terminal_char = x"0C" THEN
                                avc_terminal_col <= 0;
                                avc_terminal_row <= 0;
                                avc_terminal_escape_state <= 0;
                                avc_terminal_start_addr <= (OTHERS => '0');
                                avc_terminal_clear_addr <= (OTHERS => '0');
                                avc_terminal_state <= AVC_TERM_CLEAR;
                            ELSIF avc_terminal_escape_state = 1 THEN
                                IF avc_terminal_char = x"59" THEN -- ESC Y
                                    avc_terminal_escape_state <= 2;
                                    avc_terminal_ack_toggle <= avc_terminal_req_toggle;
                                ELSIF avc_terminal_char = x"4B" THEN -- ESC K
                                    avc_terminal_escape_state <= 0;
                                    avc_terminal_clear_col <= avc_terminal_col;
                                    avc_terminal_glyph_row <= 0;
                                    avc_terminal_state <= AVC_TERM_CLEAR_EOL;
                                ELSE
                                    avc_terminal_escape_state <= 0;
                                    avc_terminal_ack_toggle <= avc_terminal_req_toggle;
                                END IF;
                            ELSIF avc_terminal_escape_state = 2 THEN
                                IF unsigned(avc_terminal_char) < to_unsigned(16#20#, 8) THEN
                                    avc_terminal_row <= 0;
                                ELSIF unsigned(avc_terminal_char) > to_unsigned(16#37#, 8) THEN
                                    avc_terminal_row <= 23;
                                ELSE
                                    avc_terminal_row <= to_integer(unsigned(avc_terminal_char)) - 16#20#;
                                END IF;
                                avc_terminal_escape_state <= 3;
                                avc_terminal_ack_toggle <= avc_terminal_req_toggle;
                            ELSIF avc_terminal_escape_state = 3 THEN
                                IF unsigned(avc_terminal_char) < to_unsigned(16#20#, 8) THEN
                                    avc_terminal_col <= 0;
                                ELSIF unsigned(avc_terminal_char) > to_unsigned(16#7F#, 8) THEN
                                    avc_terminal_col <= 95;
                                ELSE
                                    avc_terminal_col <= to_integer(unsigned(avc_terminal_char)) - 16#20#;
                                END IF;
                                avc_terminal_escape_state <= 0;
                                avc_terminal_ack_toggle <= avc_terminal_req_toggle;
                            ELSIF avc_terminal_char = x"1B" THEN
                                avc_terminal_escape_state <= 1;
                                avc_terminal_ack_toggle <= avc_terminal_req_toggle;
                            ELSIF avc_terminal_char = x"0D" THEN
                                avc_terminal_col <= 0;
                                avc_terminal_ack_toggle <= avc_terminal_req_toggle;
                            ELSIF avc_terminal_char = x"0A" THEN
                                IF avc_terminal_row < 23 THEN
                                    avc_terminal_row <= avc_terminal_row + 1;
                                    avc_terminal_ack_toggle <= avc_terminal_req_toggle;
                                ELSE
                                    next_terminal_start_v := avc_terminal_start_addr + to_unsigned(1024, 15);
                                    avc_terminal_scroll_base <= avc_terminal_start_addr;
                                    avc_terminal_start_addr <= next_terminal_start_v;
                                    avc_terminal_scroll_offset <= 0;
                                    avc_terminal_state <= AVC_TERM_SCROLL_CLEAR;
                                END IF;
                            ELSIF avc_terminal_char = x"08" THEN
                                IF avc_terminal_col > 0 THEN
                                    avc_terminal_col <= avc_terminal_col - 1;
                                END IF;
                                avc_terminal_ack_toggle <= avc_terminal_req_toggle;
                            ELSIF unsigned(avc_terminal_char) >= to_unsigned(16#20#, 8) THEN
                                avc_terminal_glyph_row <= 0;
                                avc_terminal_state <= AVC_TERM_DRAW;
                            ELSE
                                avc_terminal_ack_toggle <= avc_terminal_req_toggle;
                            END IF;
                        ELSE
                            CASE avc_read_state IS
                                WHEN AVC_READ_IDLE =>
                                    IF avc_cpu_rd_sel = '1' THEN
                                        avc_sys_en <= '1';
                                        avc_sys_addr <= '0' & cpu_avc_addr_v;
                                        avc_read_addr <= cpu_avc_addr_v;
                                        IF avc_control_reg(0) = '1' THEN
                                            avc_read_plane <= 0;
                                        ELSIF avc_control_reg(1) = '1' THEN
                                            avc_read_plane <= 1;
                                        ELSE
                                            avc_read_plane <= 2;
                                        END IF;
                                        avc_read_state <= AVC_READ_WAIT_DATA;
                                        avc_wait_n_i <= '0';
                                    ELSIF avc_cpu_wr_sel = '1' THEN
                                        avc_sys_en <= '1';
                                        avc_sys_we <= avc_control_reg(2 DOWNTO 0);
                                        avc_sys_addr <= '0' & cpu_avc_addr_v;
                                        avc_sys_din <= cpu_do;
                                    END IF;

                                WHEN AVC_READ_WAIT_DATA =>
                                    avc_sys_en <= '1';
                                    avc_sys_addr <= '0' & avc_read_addr;
                                    avc_read_state <= AVC_READ_CAPTURE;
                                    avc_wait_n_i <= '0';

                                WHEN AVC_READ_CAPTURE =>
                                    avc_sys_en <= '1';
                                    avc_sys_addr <= '0' & avc_read_addr;
                                    avc_read_data <= avc_sys_dout(avc_read_plane);
                                    avc_read_state <= AVC_READ_RELEASE;
                                    avc_wait_n_i <= '0';

                                WHEN AVC_READ_RELEASE =>
                                    avc_wait_n_i <= '1';
                                    IF avc_cpu_rd_sel = '0' THEN
                                        avc_read_state <= AVC_READ_IDLE;
                                    END IF;
                            END CASE;
                        END IF;

                    WHEN AVC_TERM_DRAW =>
                        terminal_addr_v := (
                            to_integer(avc_terminal_start_addr) +
                            avc_terminal_row * 1024 +
                            avc_terminal_glyph_row * 64 +
                            avc_terminal_col / 2) MOD 32768;
                        glyph_addr_v := to_integer(unsigned(avc_terminal_char)) * 16 +
                            avc_terminal_glyph_row;
                        avc_sys_en <= '1';
                        IF (avc_terminal_col MOD 2) = 0 THEN
                            avc_sys_we <= "001";
                        ELSE
                            avc_sys_we <= "010";
                        END IF;
                        avc_sys_addr <= STD_LOGIC_VECTOR(to_unsigned(terminal_addr_v, 15));
                        avc_sys_din <= CHARROM(glyph_addr_v);
                        IF avc_terminal_glyph_row = 15 THEN
                            avc_terminal_state <= AVC_TERM_ADVANCE;
                        ELSE
                            avc_terminal_glyph_row <= avc_terminal_glyph_row + 1;
                        END IF;

                    WHEN AVC_TERM_ADVANCE =>
                        IF avc_terminal_col < 95 THEN
                            avc_terminal_col <= avc_terminal_col + 1;
                            avc_terminal_ack_toggle <= avc_terminal_req_toggle;
                            avc_terminal_state <= AVC_TERM_IDLE;
                        ELSE
                            avc_terminal_col <= 0;
                            IF avc_terminal_row < 23 THEN
                                avc_terminal_row <= avc_terminal_row + 1;
                                avc_terminal_ack_toggle <= avc_terminal_req_toggle;
                                avc_terminal_state <= AVC_TERM_IDLE;
                            ELSE
                                next_terminal_start_v := avc_terminal_start_addr + to_unsigned(1024, 15);
                                avc_terminal_scroll_base <= avc_terminal_start_addr;
                                avc_terminal_start_addr <= next_terminal_start_v;
                                avc_terminal_scroll_offset <= 0;
                                avc_terminal_state <= AVC_TERM_SCROLL_CLEAR;
                            END IF;
                        END IF;

                    WHEN AVC_TERM_CLEAR =>
                        avc_sys_en <= '1';
                        avc_sys_we <= "111";
                        avc_sys_addr <= STD_LOGIC_VECTOR(avc_terminal_clear_addr);
                        avc_sys_din <= x"00";
                        IF avc_terminal_clear_addr = to_unsigned(32767, 15) THEN
                            avc_terminal_ack_toggle <= avc_terminal_req_toggle;
                            avc_terminal_state <= AVC_TERM_IDLE;
                        ELSE
                            avc_terminal_clear_addr <= avc_terminal_clear_addr + 1;
                        END IF;

                    WHEN AVC_TERM_CLEAR_EOL =>
                        terminal_addr_v := (
                            to_integer(avc_terminal_start_addr) +
                            avc_terminal_row * 1024 +
                            avc_terminal_glyph_row * 64 +
                            avc_terminal_clear_col / 2) MOD 32768;
                        avc_sys_en <= '1';
                        IF (avc_terminal_clear_col MOD 2) = 0 THEN
                            avc_sys_we <= "001";
                        ELSE
                            avc_sys_we <= "010";
                        END IF;
                        avc_sys_addr <= STD_LOGIC_VECTOR(to_unsigned(terminal_addr_v, 15));
                        avc_sys_din <= x"00";
                        IF avc_terminal_glyph_row = 15 THEN
                            avc_terminal_glyph_row <= 0;
                            IF avc_terminal_clear_col = 95 THEN
                                avc_terminal_ack_toggle <= avc_terminal_req_toggle;
                                avc_terminal_state <= AVC_TERM_IDLE;
                            ELSE
                                avc_terminal_clear_col <= avc_terminal_clear_col + 1;
                            END IF;
                        ELSE
                            avc_terminal_glyph_row <= avc_terminal_glyph_row + 1;
                        END IF;

                    WHEN AVC_TERM_SCROLL_CLEAR =>
                        terminal_addr_v := (to_integer(avc_terminal_scroll_base) +
                            avc_terminal_scroll_offset) MOD 32768;
                        avc_sys_en <= '1';
                        avc_sys_we <= "111";
                        avc_sys_addr <= STD_LOGIC_VECTOR(to_unsigned(terminal_addr_v, 15));
                        avc_sys_din <= x"00";
                        IF avc_terminal_scroll_offset = 1023 THEN
                            avc_terminal_ack_toggle <= avc_terminal_req_toggle;
                            avc_terminal_state <= AVC_TERM_IDLE;
                        ELSE
                            avc_terminal_scroll_offset <= avc_terminal_scroll_offset + 1;
                        END IF;
                END CASE;
            END IF;
        END IF;
    END PROCESS;

    ----------------------------------------------------------------
    -- MAIN RAM ACCESS
    --
    -- MAIN_RAM now behaves like synchronous memory for CPU reads.
    -- The CPU-side contract mirrors the VRAM handshake:
    --   IDLE -> WAIT_DATA -> CAPTURE -> RELEASE
    -- `WAIT_n` stays low until the addressed byte is captured.
    --
    -- The save path shares the read port while the CPU is idle.
    ----------------------------------------------------------------
    PROCESS (clk100)
        VARIABLE cpu_mainram_read_cycle_v : BOOLEAN;
        VARIABLE cpu_mainram_addr_v : STD_LOGIC_VECTOR(MAIN_RAM_ADDR_WIDTH - 1 DOWNTO 0);
    BEGIN
        IF rising_edge(clk100) THEN
            IF raw_reset_req = '1' THEN
                mainram_read_state <= MAINRAM_READ_IDLE;
                mainram_rd_addr <= (OTHERS => '0');
                mainram_read_data <= x"00";
                mainram_wait_n_i <= '1';
            ELSE
                cpu_mainram_read_cycle_v := cpu_mainram_rd_sel = '1';
                cpu_mainram_addr_v := STD_LOGIC_VECTOR(resize(unsigned(cpu_a) - RAM_BASE, MAIN_RAM_ADDR_WIDTH));

                mainram_wait_n_i <= '1';

                CASE mainram_read_state IS
                    WHEN MAINRAM_READ_IDLE =>
                        IF cpu_mainram_read_cycle_v THEN
                            mainram_rd_addr <= cpu_mainram_addr_v;
                            mainram_read_state <= MAINRAM_READ_WAIT_DATA;
                            mainram_wait_n_i <= '0';
                        END IF;

                    WHEN MAINRAM_READ_WAIT_DATA =>
                        mainram_wait_n_i <= '0';
                        mainram_read_state <= MAINRAM_READ_CAPTURE;

                    WHEN MAINRAM_READ_CAPTURE =>
                        mainram_wait_n_i <= '0';
                        mainram_read_data <= mainram_rd_dout;
                        mainram_read_state <= MAINRAM_READ_RELEASE;

                    WHEN MAINRAM_READ_RELEASE =>
                        mainram_wait_n_i <= '1';
                        IF NOT cpu_mainram_read_cycle_v THEN
                            mainram_read_state <= MAINRAM_READ_IDLE;
                        END IF;
                END CASE;
            END IF;
        END IF;
    END PROCESS;

    ----------------------------------------------------------------
    -- VIDEO RAM ACCESS
    --
    -- A single true dual-port BRAM now owns all screen memory.
    -- Port A serves clk100 CPU/SD accesses.
    --
    -- BRAM port A uses READ_LATENCY_A = 1, so CPU-side VRAM reads cannot
    -- behave like a combinational ROM mux.
    -- The explicit sequence is:
    --   IDLE -> WAIT_DATA -> CAPTURE -> RELEASE
    -- `WAIT_n` stays low until valid data has been captured.
    -- `cpu_di` only presents `vram_read_data` during RELEASE.
    ----------------------------------------------------------------
    PROCESS (clk100)
        VARIABLE cpu_vram_write_cycle_v : BOOLEAN;
        VARIABLE cpu_vram_read_cycle_v : BOOLEAN;
        VARIABLE sd_vram_write_cycle_v : BOOLEAN;
        VARIABLE cpu_vram_addr_v : STD_LOGIC_VECTOR(9 DOWNTO 0);
        VARIABLE sd_vram_addr_v : STD_LOGIC_VECTOR(9 DOWNTO 0);
    BEGIN
        IF rising_edge(clk100) THEN
            IF raw_reset_req = '1' THEN
                vram_clear_active <= '1';
                vram_clear_addr <= (OTHERS => '0');
                vram_read_state <= VRAM_READ_IDLE;
                vram_read_addr <= (OTHERS => '0');
                vram_read_data <= x"20";
            ELSIF vram_clear_active = '1' THEN
                IF vram_clear_addr = STD_LOGIC_VECTOR(to_unsigned(1023, vram_clear_addr'LENGTH)) THEN
                    vram_clear_active <= '0';
                ELSE
                    vram_clear_addr <= STD_LOGIC_VECTOR(unsigned(vram_clear_addr) + 1);
                END IF;
            END IF;

            vram_sys_en <= '0';
            vram_sys_we <= "0";
            vram_sys_din <= x"20";
            vram_wait_n_i <= '1';

            IF vram_clear_active = '1' THEN
                vram_sys_en <= '1';
                vram_sys_we <= "1";
                vram_sys_addr <= vram_clear_addr;
                vram_sys_din <= x"20";
            ELSE
                cpu_vram_write_cycle_v := cpu_vram_wr_sel = '1';
                cpu_vram_read_cycle_v := cpu_vram_rd_sel = '1';
                sd_vram_write_cycle_v := sdq_vram_wr_sel = '1';

                cpu_vram_addr_v := STD_LOGIC_VECTOR(resize(unsigned(cpu_a) - VIDEO_RAM_BASE, vram_addr'LENGTH));
                sd_vram_addr_v := STD_LOGIC_VECTOR(resize(unsigned(sd_file_mem_addr_q) - VIDEO_RAM_BASE, vram_addr'LENGTH));

                IF DEBUG_ISOLATE_VRAM_READS THEN
                    vram_read_state <= VRAM_READ_IDLE;
                ELSE
                    CASE vram_read_state IS
                        WHEN VRAM_READ_IDLE =>
                            IF cpu_vram_read_cycle_v THEN
                                vram_sys_en <= '1';
                                vram_sys_we <= "0";
                                vram_sys_addr <= cpu_vram_addr_v;
                                vram_read_addr <= cpu_vram_addr_v;
                                vram_read_state <= VRAM_READ_WAIT_DATA;
                                vram_wait_n_i <= '0';
                            END IF;

                        WHEN VRAM_READ_WAIT_DATA =>
                            vram_sys_en <= '1';
                            vram_sys_we <= "0";
                            vram_sys_addr <= vram_read_addr;
                            vram_read_state <= VRAM_READ_CAPTURE;
                            vram_wait_n_i <= '0';

                        WHEN VRAM_READ_CAPTURE =>
                            vram_sys_en <= '1';
                            vram_sys_we <= "0";
                            vram_sys_addr <= vram_read_addr;
                            vram_read_data <= vram_sys_dout;
                            vram_read_state <= VRAM_READ_RELEASE;
                            vram_wait_n_i <= '0';

                        WHEN VRAM_READ_RELEASE =>
                            vram_wait_n_i <= '1';
                            IF mreq_n = '0' AND rd_n = '0' THEN
                                vram_read_state <= VRAM_READ_RELEASE;
                            ELSE
                                vram_read_state <= VRAM_READ_IDLE;
                            END IF;
                    END CASE;
                END IF;

                IF (NOT DEBUG_ISOLATE_VRAM_READS) AND vram_read_state /= VRAM_READ_IDLE THEN
                    NULL;
                ELSIF sd_vram_write_cycle_v THEN
                    vram_sys_en <= '1';
                    vram_sys_we <= "1";
                    vram_sys_addr <= sd_vram_addr_v;
                    vram_sys_din <= sd_file_mem_data_q;
                ELSIF cpu_vram_write_cycle_v AND (NOT DEBUG_ISOLATE_VRAM_WRITES) THEN
                    vram_sys_en <= '1';
                    vram_sys_we <= "1";
                    vram_sys_addr <= cpu_vram_addr_v;
                    vram_sys_din <= cpu_do;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    --------------------------------------------------------------------
    -- CPU: T80s Wrapper
    --------------------------------------------------------------------
    u_cpu : ENTITY work.T80s
        GENERIC MAP(
            Mode => 0,
            T2Write => 0,
            IOWait => 1
        )
        PORT MAP(
            RESET_n => cpu_reset_n,
            CLK_n => clk100,
            CEN => cpu_cen,
            WAIT_n => cpu_wait_n,
            INT_n => '1',
            NMI_n => cpu_nmi_n,
            BUSRQ_n => '1',

            M1_n => m1_n,
            MREQ_n => mreq_n,
            IORQ_n => iorq_n,
            RD_n => rd_n,
            WR_n => wr_n,
            RFSH_n => rfsh_n,
            HALT_n => halt_n,
            BUSAK_n => busak_n,

            A => cpu_a,
            DInst => cpu_dinst,
            DI => cpu_di,
            DO => cpu_do,
            DBG_EN => god_debug_en,
            DBG_REG_ADDR => god_reg_addr,
            DBG_PC_LOAD => god_pc_load,
            DBG_PC_DATA => god_pc_load_data,
            DBG_COMMIT => god_commit,
            DBG_REG_DATA => god_reg_data,
            DBG_AF => god_af,
            DBG_AF_ALT => god_af_alt,
            DBG_PC => god_pc,
            DBG_SP => god_sp,
            DBG_I => god_i,
            DBG_R => god_r,
            DBG_IR => god_ir,
            DBG_IM => god_im,
            DBG_IFF => god_iff,
            DBG_MC => god_mc,
            DBG_TS => god_ts
        );

    --------------------------------------------------------------------
    -- RS232
    --------------------------------------------------------------------

    uart_baud_sel <= "1001" WHEN cfg_rs232_active = "000" ELSE
        cfg_rs232_speed_active;

    --------------------------------------------------------------------
    -- UART-TX-Modul
    --------------------------------------------------------------------
    u_uart_tx : ENTITY work.uart_tx
        GENERIC MAP(
            CLK_FREQ_HZ => 100000000
        )
        PORT MAP(
            clk => clk100,
            reset => sys_reset,
            baud_sel => uart_baud_sel,
            data_in => uart_data,
            start => uart_start,
            txd => rs232_uart_txd,
            busy => uart_busy
        );

    --------------------------------------------------------------------
    -- UART-RX-Modul
    --------------------------------------------------------------------
    u_uart_rx : ENTITY work.uart_rx
        GENERIC MAP(
            CLK_FREQ_HZ => 100000000
        )
        PORT MAP(
            clk => clk100,
            reset => sys_reset,
            baud_sel => uart_baud_sel,
            rxd => rs232_uart_rxd,
            data_out => uart_rx_data,
            valid => uart_rx_valid
        );

    --------------------------------------------------------------------
    -- I/O-Write auf Port 01h -> UART TX
    -- normaler UART-TX-Pfad
    --------------------------------------------------------------------
    PROCESS (clk100)
    BEGIN
        IF rising_edge(clk100) THEN
            uart_start <= '0';

            IF sys_reset = '1' THEN
                wr_n_last <= '1';
                uart_data <= x"00";
            ELSE
                IF wr_n_last = '1' AND wr_n = '0' THEN
                    IF iorq_n = '0' AND cpu_a(7 DOWNTO 0) = x"01" THEN
                        IF rs232_tx_ready = '1' THEN
                            uart_data <= cpu_do;
                            uart_start <= '1';
                        END IF;
                    END IF;

                END IF;

                wr_n_last <= wr_n;
            END IF;
        END IF;
    END PROCESS;

    --------------------------------------------------------------------
    -- UART-RX Register
    -- Neues Zeichen puffern, rx_valid setzen
    -- Lesen von Port 00h loescht rx_valid wieder
    --------------------------------------------------------------------
    PROCESS (clk100)
    BEGIN
        IF rising_edge(clk100) THEN
            IF sys_reset = '1' THEN
                rx_fifo <= (OTHERS => x"00");
                rx_wr_ptr <= 0;
                rx_rd_ptr <= 0;
                rx_count <= 0;
                rd_n_last <= '1';
                rx_pop_pending <= '0';
                esc_state <= ESC_IDLE;
            ELSE
                ----------------------------------------------------------------
                -- Neues Zeichen von UART verarbeiten
                -- ESC [ A/B/C/D -> NASSYS-Cursortasten
                ----------------------------------------------------------------
                IF uart_rx_valid = '1' THEN
                    -- CP/M communication programs such as Kermit require an
                    -- unmodified 8-bit data path.  Escape-sequence decoding is
                    -- only a convenience for the native NASSYS console.
                    IF cfg_cpm_active = '1' THEN
                        esc_state <= ESC_IDLE;
                        IF rx_count < 4 THEN
                            rx_fifo(rx_wr_ptr) <= uart_rx_data;

                            IF rx_wr_ptr = 3 THEN
                                rx_wr_ptr <= 0;
                            ELSE
                                rx_wr_ptr <= rx_wr_ptr + 1;
                            END IF;

                            rx_count <= rx_count + 1;
                        END IF;
                    ELSE
                        CASE esc_state IS

                            ----------------------------------------------------------------
                            -- Normalzustand
                            ----------------------------------------------------------------
                        WHEN ESC_IDLE =>
                            IF uart_rx_data = x"1B" THEN
                                -- ESC gesehen, erstmal abwarten
                                esc_state <= ESC_SEEN;
                            ELSE
                                IF rx_count < 4 THEN
                                    rx_fifo(rx_wr_ptr) <= uart_rx_data;

                                    IF rx_wr_ptr = 3 THEN
                                        rx_wr_ptr <= 0;
                                    ELSE
                                        rx_wr_ptr <= rx_wr_ptr + 1;
                                    END IF;

                                    rx_count <= rx_count + 1;
                                END IF;
                            END IF;

                            ----------------------------------------------------------------
                            -- ESC gesehen
                            ----------------------------------------------------------------
                        WHEN ESC_SEEN =>
                            IF uart_rx_data = x"5B" THEN
                                -- '['
                                esc_state <= CSI_SEEN;
                            ELSE
                                -- ESC erstmal ignorieren, aktuelles Zeichen normal behandeln
                                esc_state <= ESC_IDLE;

                                IF rx_count < 4 THEN
                                    rx_fifo(rx_wr_ptr) <= uart_rx_data;

                                    IF rx_wr_ptr = 3 THEN
                                        rx_wr_ptr <= 0;
                                    ELSE
                                        rx_wr_ptr <= rx_wr_ptr + 1;
                                    END IF;

                                    rx_count <= rx_count + 1;
                                END IF;
                            END IF;

                            ----------------------------------------------------------------
                            -- ESC [ gesehen
                            ----------------------------------------------------------------
                        WHEN CSI_SEEN =>
                            esc_state <= ESC_IDLE;

                            IF rx_count < 4 THEN
                                CASE uart_rx_data IS
                                    WHEN x"41" => -- A = Up
                                        rx_fifo(rx_wr_ptr) <= x"13";
                                    WHEN x"42" => -- B = Down
                                        rx_fifo(rx_wr_ptr) <= x"14";
                                    WHEN x"43" => -- C = Right
                                        rx_fifo(rx_wr_ptr) <= x"12";
                                    WHEN x"44" => -- D = Left
                                        rx_fifo(rx_wr_ptr) <= x"11";
                                    WHEN OTHERS =>
                                        -- unbekannte ESC-Sequenz ignorieren
                                        rx_fifo(rx_wr_ptr) <= x"00";
                                END CASE;

                                IF uart_rx_data = x"41" OR uart_rx_data = x"42" OR
                                    uart_rx_data = x"43" OR uart_rx_data = x"44" THEN
                                    IF rx_wr_ptr = 3 THEN
                                        rx_wr_ptr <= 0;
                                    ELSE
                                        rx_wr_ptr <= rx_wr_ptr + 1;
                                    END IF;

                                    rx_count <= rx_count + 1;
                                END IF;
                            END IF;

                        END CASE;
                    END IF;
                END IF;
                ----------------------------------------------------------------
                -- Beginn eines I/O-Reads von Port 01h:
                -- nur merken, dass nach Abschluss gepoppt werden soll
                ----------------------------------------------------------------
                IF rd_n_last = '1' AND rd_n = '0' THEN
                    IF iorq_n = '0' AND cpu_a(7 DOWNTO 0) = x"01" THEN
                        IF rx_count > 0 THEN
                            rx_pop_pending <= '1';
                        END IF;
                    END IF;
                END IF;

                ----------------------------------------------------------------
                -- Ende des Read-Zyklus:
                -- jetzt erst FIFO wirklich weiterdrehen
                ----------------------------------------------------------------
                IF rd_n_last = '0' AND rd_n = '1' THEN
                    IF rx_pop_pending = '1' THEN
                        IF rx_rd_ptr = 3 THEN
                            rx_rd_ptr <= 0;
                        ELSE
                            rx_rd_ptr <= rx_rd_ptr + 1;
                        END IF;

                        rx_count <= rx_count - 1;
                        rx_pop_pending <= '0';
                    END IF;
                END IF;

                rd_n_last <= rd_n;
            END IF;
        END IF;
    END PROCESS;

    --------------------------------------------------------------------
    -- LEDs als Debug-Anzeige
    --------------------------------------------------------------------
    --led(3 DOWNTO 0) <= hdmi_heartbeat;
    --led(7 DOWNTO 4) <= (OTHERS => '0');

    --------------------------------------------------------------------
    -- HDMI Testpagegenerator
    --------------------------------------------------------------------
    u_hdmi_tpg : ENTITY work.hdmi_tpg
        GENERIC MAP(
            fclk => 100.0
        )
        PORT MAP(
            rst => hdmi_reset_sync,
            clk => clk100,
            mode => hdmi_mode,
            dvi => '1',
            steady => '0',
            phosphor_amber => cfg_phosphor_amber_active,
            scanlines => cfg_scanlines_active,
            video_zoom => cfg_video_zoom_active,

            heartbeat => hdmi_heartbeat,
            status => hdmi_status,

            audio_pcm_l => ay_pcm,
            audio_pcm_r => ay_pcm,

            vram_clk => vram_clk,
            vram_addr => vram_addr,
            vram_data => vram_data,
            avc_control => avc_control_reg,
            avc_terminal_mode => avc_terminal_enabled,
            avc_crtc_start_addr => avc_crtc_start_addr,
            avc_crtc_horizontal_displayed => avc_crtc_regs(1),
            avc_crtc_max_scanline => avc_crtc_regs(9)(4 DOWNTO 0),
            avc_crtc_cursor_start => avc_crtc_regs(10),
            avc_crtc_cursor_end => avc_crtc_regs(11)(4 DOWNTO 0),
            avc_crtc_cursor_addr => avc_crtc_regs(14)(5 DOWNTO 0) & avc_crtc_regs(15),
            avc_vram_addr => avc_video_addr,
            avc_red_data => avc_video_data(0),
            avc_green_data => avc_video_data(1),
            avc_blue_data => avc_video_data(2),
            overlay_enable => ui_overlay_enable,
            overlay_page => ui_overlay_page,
            overlay_cfg_row => ui_cfg_row_sel,
            overlay_cfg_speed => overlay_cfg_speed_mux,
            overlay_cfg_phosphor_amber => overlay_cfg_phosphor_mux,
            overlay_cfg_scanlines => overlay_cfg_scanlines_mux,
            overlay_cfg_video_zoom => cfg_video_zoom_pending,
            overlay_cfg_rs232 => cfg_rs232_pending,
            overlay_cfg_rs232_speed => cfg_rs232_speed_pending,
            overlay_cfg_rs232_flow => cfg_rs232_flow_pending,
            overlay_cfg_slot_rom => cfg_slot_rom_pending,
            overlay_cfg_fdd => cfg_fdd_pending,
            overlay_cfg_cpm => cfg_cpm_pending,
            overlay_cfg_avc => cfg_avc_pending,
            overlay_cfg_bls => cfg_bls_pending,
            overlay_sd_cd_raw => sd_cd_raw,
            overlay_sd_init_busy => sd_init_busy,
            overlay_sd_init_done => sd_init_done,
            overlay_sd_init_error => sd_init_error,
            overlay_sd_read_busy => sd_read_busy,
            overlay_sd_read_done => sd_read_done,
            overlay_sd_read_error => sd_read_error,
            overlay_sd_read_stage => sd_read_stage,
            overlay_sd_read_lba => overlay_debug_lba_mux,
            overlay_sd_read_token => overlay_debug_read_token_mux,
            overlay_sd_read_count => sd_read_count,
            overlay_sd_read_first_word => overlay_debug_first_word_mux,
            overlay_sd_card_block_addressing => sd_card_block_addressing,
            overlay_sd_debug_read_cmd17_r1 => overlay_debug_cmd17_mux,
            overlay_sd_debug_read_error_code => overlay_debug_error_mux,
            overlay_sd_last_r1 => overlay_debug_last_r1_mux,
            overlay_sd_state_code => sd_state_code,
            overlay_sd_debug_root_current_cluster => overlay_debug_root_current_mux,
            overlay_sd_debug_root_next_cluster => overlay_debug_root_next_mux,
            overlay_sd_debug_root_sectors_left => overlay_debug_sectors_left_mux,
            overlay_sd_debug_root_scan_phase => sd_debug_root_scan_phase,
            overlay_sd_debug_root_scan_job => sd_debug_root_scan_job,
            overlay_sd_part_lba => sd_part_lba,
            overlay_sd_boot_spc => sd_boot_spc,
            overlay_sd_boot_reserved => sd_boot_reserved,
            overlay_sd_boot_num_fats => sd_boot_num_fats,
            overlay_sd_boot_spf => sd_boot_spf,
            overlay_sd_root_dir_lba => sd_root_dir_lba,
            overlay_sd_browser_dir_found => sd_browser_dir_found,
            overlay_sd_browser_has_files => sd_browser_has_files,
            overlay_sd_root_total_file_count => sd_root_total_file_count,
            overlay_sd_page_valid => sd_page_valid,
            overlay_sd_page_name => sd_page_name,
            overlay_sd_page_kind => sd_page_kind,
            overlay_fdd_mount_a_valid => fdd_mount_a_valid,
            overlay_fdd_mount_a_name => fdd_mount_a_name,
            overlay_fdd_mount_b_valid => fdd_mount_b_valid,
            overlay_fdd_mount_b_name => fdd_mount_b_name,
            overlay_sd_page_base => ui_sd_page_base,
            overlay_sd_page_row => ui_sd_page_row,
            overlay_sd_file_load_addr_valid => sd_file_load_addr_valid,
            overlay_sd_file_load_addr => sd_file_load_addr,
            overlay_browser_manage_mode => ui_browser_manage_mode_code,
            overlay_browser_manage_name => ui_browser_manage_name,
            overlay_browser_manage_status => sd_manage_status,
            overlay_cfg_dirty => ui_cfg_dirty,
            overlay_cfg_apply_pending => ui_cfg_apply_pending,
            overlay_cfg_apply_error => ui_cfg_apply_error,
            overlay_cfg_load_busy => sd_cfg_load_busy,
            overlay_cfg_load_pending => sd_cfg_load_pending,
            overlay_cfg_load_seen => sd_cfg_load_seen_this_card,
            overlay_cfg_load_ok => sd_cfg_last_load_ok,
            overlay_cfg_load_error => sd_cfg_last_load_error,
            overlay_tape_led_active => tape_led_active,
            overlay_halt_active => halt_active,
            overlay_god_af => god_af,
            overlay_god_af_alt => god_af_alt,
            overlay_god_bc => god_bc,
            overlay_god_de => god_de,
            overlay_god_hl => god_hl,
            overlay_god_bc_alt => god_bc_alt,
            overlay_god_de_alt => god_de_alt,
            overlay_god_hl_alt => god_hl_alt,
            overlay_god_ix => god_ix,
            overlay_god_iy => god_iy,
            overlay_god_sp => god_sp,
            overlay_god_pc => god_pc,
            overlay_bls_fault => bls_low_exec_fault,
            overlay_bls_fault_from_pc => bls_low_exec_from_pc,
            overlay_bls_fault_to_pc => bls_low_exec_to_pc,
            overlay_bls_fault_sp => bls_low_exec_sp,
            overlay_god_i => god_i,
            overlay_god_r => god_r,
            overlay_god_ir => god_ir,
            overlay_god_im => god_im,
            overlay_god_iff => god_iff,
            overlay_god_mc => god_mc,
            overlay_god_ts => god_ts,
            overlay_god_reset_count => STD_LOGIC_VECTOR(reset_event_count),
            overlay_god_ui_reset_count => STD_LOGIC_VECTOR(ui_reset_event_count),
            overlay_god_cfg_reset_count => STD_LOGIC_VECTOR(cfg_reset_event_count),
            overlay_god_mem_base => STD_LOGIC_VECTOR(god_mem_base),
            overlay_god_mem_cursor => god_mem_cursor,
            overlay_god_mem_data => god_mem_snapshot,
            overlay_god_edit_high => god_mem_edit_high,
            overlay_god_high_nibble => god_mem_high_nibble,
            overlay_god_addr_edit => god_addr_edit,
            overlay_god_addr_digit => god_addr_digit,
            overlay_god_addr_pending => god_addr_pending,
            overlay_diag_valid => fdd_diag_valid,
            overlay_diag_cpm_position => fdd_diag_cpm_position,
            overlay_diag_fdd_position => fdd_diag_fdd_position,
            overlay_diag_cluster => fdd_diag_cluster,
            overlay_diag_sd_lba => fdd_diag_sd_lba,
            overlay_diag_sd_status => fdd_diag_sd_status,
            overlay_diag_read_count => fdd_diag_read_count,
            overlay_diag_first_word => fdd_diag_first_word,
            overlay_key_make_code => kbd_diag_make_code,
            overlay_key_make_extended => kbd_diag_make_extended,
            overlay_key_make_ctrl => kbd_diag_make_ctrl,
            overlay_key_make_shift_l => kbd_diag_make_shift_l,
            overlay_key_make_shift_r => kbd_diag_make_shift_r,
            overlay_key_make_nmi_match => kbd_diag_make_nmi_match,
            overlay_key_make_count => kbd_diag_make_count,
            overlay_pmod_fault_active => overlay_pmod_fault_active,
            overlay_pmod_fault_pmod2 => overlay_pmod_fault_pmod2,
            overlay_save_name => ui_save_name,
            overlay_save_row_sel => ui_save_row_sel,
            overlay_save_mode_basic => ui_save_mode_basic,
            overlay_save_mode_bls => ui_save_mode_bls,
            overlay_save_start_addr_digit => ui_save_start_addr_digit,
            overlay_save_end_addr_digit => ui_save_end_addr_digit,
            overlay_save_start_addr_manual => ui_save_start_addr_manual,
            overlay_save_end_addr_manual => ui_save_end_addr_manual,
            overlay_save_basic_available => ui_save_basic_available,
            overlay_save_basic_ready => ui_save_basic_ready,
            overlay_save_basic_start_addr => ui_save_basic_start_addr,
            overlay_save_basic_end_addr => ui_save_basic_end_addr,
            overlay_save_effective_start_addr => ui_save_effective_start_addr,
            overlay_save_effective_end_addr => ui_save_effective_end_addr,
            overlay_save_effective_len => ui_save_effective_len,
            overlay_save_check_busy => sd_save_check_busy,
            overlay_save_checked => ui_save_checked,
            overlay_save_name_exists => ui_save_name_exists,
            overlay_save_check_can_create => sd_save_check_can_create,
            overlay_save_check_can_allocate => sd_save_check_can_allocate,
            overlay_save_check_requires_dir_growth => sd_save_check_requires_dir_growth,
            overlay_save_check_dir_full => sd_save_check_dir_full,
            overlay_save_overwrite_confirmed => ui_save_overwrite_confirmed,
            overlay_save_ready_to_write => ui_save_ready_to_write,
            overlay_save_write_after_check => ui_save_write_after_check,
            overlay_save_write_busy => sd_save_write_busy,
            overlay_save_write_done => sd_save_write_done,
            overlay_save_write_error => sd_save_write_error,
            overlay_save_write_status => sd_save_write_status,
            hdmi_clk_p => hdmi_tx_clk_p,
            hdmi_clk_n => hdmi_tx_clk_n,
            hdmi_d_p => hdmi_tx_p,
            hdmi_d_n => hdmi_tx_n,
            vga_clk_out => vga_clk_out,
            vga_blank_n_out => vga_blank_n_out,
            vga_sync_n_out => vga_sync_n_out,
            vga_psave_n_out => vga_psave_n_out,
            vga_red_out => vga_red_out,
            vga_green_out => vga_green_out,
            vga_blue_out => vga_blue_out,
            vga_hsync_out => vga_hsync_out,
            vga_vsync_out => vga_vsync_out
        );

    --------------------------------------------------------------------
    -- Tastatur PS/2 Instanz
    --------------------------------------------------------------------
    u_ps2_keyboard : ENTITY work.ps2_keyboard
        PORT MAP(
            clk => clk100,
            reset => sys_reset,
            ps2_clk => ps2_clk,
            ps2_data => ps2_data,
            code => ps2_code,
            valid => ps2_valid,
            extended => ps2_extended,
            released => ps2_released
        );

    --------------------------------------------------------------------
    -- SD-card SPI init / bring-up status
    --------------------------------------------------------------------
    u_sd_spi_init : ENTITY work.sd_spi_init
        GENERIC MAP(
            CLK_HZ => 100000000,
            SPI_HZ => 400000
        )
        PORT MAP(
            clk => clk100,
            reset => sys_reset,
            sd_cd => sd_cd_sync,
            sd_miso => sd_d(0),
            sd_sclk => sd_spi_sclk,
            sd_mosi => sd_spi_mosi,
            sd_cs_n => sd_spi_cs_n,
            sd_reset_n => OPEN,
            cd_raw => sd_cd_raw,
            init_busy => sd_init_busy,
            init_done => sd_init_done,
            init_error => sd_init_error,
            read_busy => sd_read_busy,
            read_done => sd_read_done,
            read_error => sd_read_error,
            read_stage => sd_read_stage,
            browser_dir_found => sd_browser_dir_found,
            browser_include_dsk => cfg_fdd_active,
            browser_include_pas => cfg_bls_active,
            read_lba => sd_read_lba,
            read_token => sd_read_token,
            read_count => sd_read_count,
            read_first_word => sd_read_first_word,
            read_signature => OPEN,
            part_type => OPEN,
            part_lba => sd_part_lba,
            boot_bps => OPEN,
            boot_spc => sd_boot_spc,
            boot_reserved => sd_boot_reserved,
            boot_num_fats => sd_boot_num_fats,
            boot_spf => sd_boot_spf,
            boot_root_cluster => sd_boot_root_cluster,
            root_dir_lba => sd_root_dir_lba,
            root_file_count => sd_root_file_count,
            root_total_file_count => sd_root_total_file_count,
            page_base_index => ui_sd_page_base,
            selected_page_row => ui_sd_page_row,
            browser_has_files => sd_browser_has_files,
            page_valid => sd_page_valid,
            page_name => sd_page_name,
            page_kind => sd_page_kind,
            selected_valid => sd_selected_valid,
            selected_name => sd_selected_name,
            selected_cluster => sd_selected_cluster,
            selected_size => sd_selected_size,
            manage_start => ui_browser_manage_start,
            manage_delete => ui_browser_manage_delete,
            manage_old_name => ui_browser_manage_old_name,
            manage_new_name => ui_browser_manage_new_name,
            manage_busy => sd_manage_busy,
            manage_done => sd_manage_done,
            manage_error => sd_manage_error,
            manage_status => sd_manage_status,
            save_check_start => ui_save_check_start,
            save_name => ui_save_name,
            save_is_pascal => ui_save_mode_bls,
            save_check_busy => sd_save_check_busy,
            save_check_done => sd_save_check_done,
            save_check_exists => sd_save_check_exists,
            save_check_can_create => sd_save_check_can_create,
            save_check_can_allocate => sd_save_check_can_allocate,
            save_check_requires_dir_growth => sd_save_check_requires_dir_growth,
            save_check_dir_full => sd_save_check_dir_full,
            save_debug_free_lba => OPEN,
            save_debug_free_slot => OPEN,
            save_debug_free_marker => OPEN,
            save_debug_free_cluster => OPEN,
            save_done_clear => ui_save_reset_req,
            save_status_clear => ui_save_status_clear,
            save_write_start => ui_save_write_start,
            save_write_start_addr => ui_save_effective_start_addr,
            save_write_end_addr => ui_save_effective_end_addr,
            save_write_busy => sd_save_write_busy,
            save_write_done => sd_save_write_done,
            save_write_error => sd_save_write_error,
            save_write_status => sd_save_write_status,
            save_mem_addr => sd_save_mem_addr,
            save_mem_data => sd_save_mem_data,
            cfg_load_start => sd_cfg_load_start,
            cfg_load_busy => sd_cfg_load_busy,
            cfg_load_done => sd_cfg_load_done,
            cfg_load_error => sd_cfg_load_error,
            cfg_loaded_valid => sd_cfg_loaded_valid,
            cfg_loaded_speed => sd_cfg_loaded_speed,
            cfg_loaded_phosphor_amber => sd_cfg_loaded_phosphor_amber,
            cfg_loaded_scanlines => sd_cfg_loaded_scanlines,
            cfg_loaded_video_zoom => sd_cfg_loaded_video_zoom,
            cfg_loaded_rs232 => sd_cfg_loaded_rs232,
            cfg_loaded_rs232_speed => sd_cfg_loaded_rs232_speed,
            cfg_loaded_rs232_flow => sd_cfg_loaded_rs232_flow,
            cfg_loaded_slot_rom => sd_cfg_loaded_slot_rom,
            cfg_loaded_fdd => sd_cfg_loaded_fdd,
            cfg_loaded_cpm => sd_cfg_loaded_cpm,
            cfg_loaded_avc => sd_cfg_loaded_avc,
            cfg_loaded_bls => sd_cfg_loaded_bls,
            cfg_loaded_network => sd_cfg_loaded_network,
            cfg_loaded_network_dhcp => sd_cfg_loaded_network_dhcp,
            cfg_loaded_network_ipv4 => sd_cfg_loaded_network_ipv4,
            cfg_loaded_network_netmask => sd_cfg_loaded_network_netmask,
            cfg_loaded_network_gateway => sd_cfg_loaded_network_gateway,
            cfg_loaded_network_dns => sd_cfg_loaded_network_dns,
            cfg_save_start => sd_cfg_save_start,
            cfg_save_busy => sd_cfg_save_busy,
            cfg_save_done => sd_cfg_save_done,
            cfg_save_error => sd_cfg_save_error,
            cfg_save_speed => cfg_cpu_speed_active,
            cfg_save_phosphor_amber => cfg_phosphor_amber_active,
            cfg_save_scanlines => cfg_scanlines_active,
            cfg_save_video_zoom => cfg_video_zoom_active,
            cfg_save_rs232 => cfg_rs232_active,
            cfg_save_rs232_speed => cfg_rs232_speed_active,
            cfg_save_rs232_flow => cfg_rs232_flow_active,
            cfg_save_slot_rom => cfg_slot_rom_persist,
            cfg_save_fdd => cfg_fdd_active,
            cfg_save_cpm => cfg_cpm_active,
            cfg_save_avc => cfg_avc_active,
            cfg_save_bls => cfg_bls_active,
            cfg_save_network => cfg_network_active,
            cfg_save_network_dhcp => cfg_network_dhcp_active,
            cfg_save_network_ipv4 => cfg_network_ipv4_active,
            cfg_save_network_netmask => cfg_network_netmask_active,
            cfg_save_network_gateway => cfg_network_gateway_active,
            cfg_save_network_dns => cfg_network_dns_active,
            fdd_read_start => fdd_read_start,
            fdd_read_cluster => fdd_read_cluster,
            fdd_read_sd_sector => fdd_read_sd_sector,
            fdd_read_half => fdd_read_half,
            fdd_read_busy => fdd_read_busy,
            fdd_read_done => fdd_read_done,
            fdd_read_error => fdd_read_error,
            fdd_buffer_addr => fdd_buffer_addr,
            fdd_buffer_data => fdd_buffer_data,
            fdd_buffer_write_enable => fdd_buffer_write_enable,
            fdd_buffer_write_addr => fdd_buffer_write_addr,
            fdd_buffer_write_data => fdd_buffer_write_data,
            fdd_write_start => fdd_write_start,
            fdd_write_cluster => fdd_write_cluster,
            fdd_write_sd_sector => fdd_write_sd_sector,
            fdd_write_half => fdd_write_half,
            fdd_write_busy => fdd_write_busy,
            fdd_write_done => fdd_write_done,
            fdd_write_error => fdd_write_error,
            fdd_format_start => fdd_format_start,
            fdd_format_name => fdd_format_name,
            fdd_format_cluster => fdd_format_cluster,
            fdd_format_busy => fdd_format_busy,
            fdd_format_done => fdd_format_done,
            fdd_format_error => fdd_format_error,
            fdd_format_new_cluster => fdd_format_new_cluster,
            file_read_start => ui_sd_file_read_start,
            file_read_cluster => sd_selected_cluster,
            file_read_size => sd_selected_size,
            file_read_is_cas => sd_selected_is_cas,
            file_load_addr_valid => sd_file_load_addr_valid,
            file_load_addr => sd_file_load_addr,
            file_mem_wr => sd_file_mem_wr,
            file_mem_addr => sd_file_mem_addr,
            file_mem_data => sd_file_mem_data,
            state_code => sd_state_code,
            last_r1 => sd_last_r1,
            debug_read_cmd17_r1 => sd_debug_read_cmd17_r1,
            debug_read_error_code => sd_debug_read_error_code,
            debug_root_current_cluster => sd_debug_root_current_cluster,
            debug_root_next_cluster => sd_debug_root_next_cluster,
            debug_root_sectors_left => sd_debug_root_sectors_left,
            debug_root_scan_phase => sd_debug_root_scan_phase,
            debug_root_scan_job => sd_debug_root_scan_job,
            card_block_addressing => sd_card_block_addressing
        );

    --------------------------------------------------------------------
    -- Nascom keyboard hardware model
    --------------------------------------------------------------------
    u_nascom_keyboard_hw : ENTITY work.nascom_keyboard_hw
        PORT MAP(
            clk => clk100,
            reset => sys_reset,
            port0_reg => port0_reg,
            nk_0 => nk_0,
            nk_1 => nk_1,
            nk_2 => nk_2,
            nk_3 => nk_3,
            nk_4 => nk_4,
            nk_5 => nk_5,
            nk_6 => nk_6,
            nk_7 => nk_7,
            nk_8 => nk_8,
            nk_9 => nk_9,
            nk_a => nk_a,
            nk_b => nk_b,
            nk_c => nk_c,
            nk_d => nk_d,
            nk_e => nk_e,
            nk_f => nk_f,
            nk_g => nk_g,
            nk_h => nk_h,
            nk_i => nk_i,
            nk_j => nk_j,
            nk_k => nk_k,
            nk_l => nk_l,
            nk_m => nk_m,
            nk_n => nk_n,
            nk_o => nk_o,
            nk_p => nk_p,
            nk_q => nk_q,
            nk_r => nk_r,
            nk_s => nk_s,
            nk_t => nk_t,
            nk_u => nk_u,
            nk_v => nk_v,
            nk_w => nk_w,
            nk_x => nk_x,
            nk_y => nk_y,
            nk_z => nk_z,
            nk_sp => nk_sp,
            nk_sh => nk_sh,
            nk_ct => nk_ct_matrix,
            nk_nl => nk_nl,
            nk_bs => nk_bs,
            nk_pu => nk_pu,
            nk_pd => nk_pd,
            nk_pl => nk_pl,
            nk_pr => nk_pr,
            nk_gr => nk_gr,
            nk_tb => nk_tb,
            nk_at => nk_at,
            nk_plus => nk_plus,
            nk_star => nk_star,
            nk_comma => nk_comma,
            nk_dot => nk_dot,
            nk_minus => nk_minus,
            nk_slash => nk_slash,
            nk_lb => nk_lb_matrix,
            nk_rb => nk_rb,

            kbd_data => kbd_port0_in
        );

    MAIN_RAM_BRAM : xpm_memory_tdpram
    GENERIC MAP(
        MEMORY_SIZE => MAIN_RAM_SIZE_BYTES * 8,
        MEMORY_PRIMITIVE => "block",
        CLOCKING_MODE => "common_clock",
        ECC_MODE => "no_ecc",
        ECC_TYPE => "none",
        ECC_BIT_RANGE => "[7:0]",
        MEMORY_INIT_FILE => "none",
        MEMORY_INIT_PARAM => "",
        USE_MEM_INIT => 0,
        USE_MEM_INIT_MMI => 0,
        WAKEUP_TIME => "disable_sleep",
        MESSAGE_CONTROL => 0,
        USE_EMBEDDED_CONSTRAINT => 0,
        MEMORY_OPTIMIZATION => "true",
        CASCADE_HEIGHT => 0,
        SIM_ASSERT_CHK => 0,
        WRITE_PROTECT => 0,
        RAM_DECOMP => "auto",
        IGNORE_INIT_SYNTH => 0,
        WRITE_DATA_WIDTH_A => 8,
        READ_DATA_WIDTH_A => 8,
        BYTE_WRITE_WIDTH_A => 8,
        ADDR_WIDTH_A => MAIN_RAM_ADDR_WIDTH,
        READ_RESET_VALUE_A => "0",
        READ_LATENCY_A => 1,
        WRITE_MODE_A => "no_change",
        RST_MODE_A => "SYNC",
        WRITE_DATA_WIDTH_B => 8,
        READ_DATA_WIDTH_B => 8,
        BYTE_WRITE_WIDTH_B => 8,
        ADDR_WIDTH_B => MAIN_RAM_ADDR_WIDTH,
        READ_RESET_VALUE_B => "0",
        READ_LATENCY_B => 1,
        WRITE_MODE_B => "no_change",
        RST_MODE_B => "SYNC"
    )
    PORT MAP(
        sleep => '0',
        clka => clk100,
        rsta => '0',
        ena => '1',
        regcea => '1',
        wea => mainram_sys_we,
        addra => mainram_sys_addr,
        dina => mainram_sys_din,
        injectsbiterra => '0',
        injectdbiterra => '0',
        douta => mainram_sys_dout,
        sbiterra => OPEN,
        dbiterra => OPEN,
        clkb => clk100,
        rstb => '0',
        enb => '1',
        regceb => '1',
        web => (OTHERS => '0'),
        addrb => mainram_rd_mux_addr,
        dinb => x"00",
        injectsbiterrb => '0',
        injectdbiterrb => '0',
        doutb => mainram_rd_dout,
        sbiterrb => OPEN,
        dbiterrb => OPEN
    );

    AVC_PLANE_BRAMS : FOR plane_i IN 0 TO 2 GENERATE
        AVC_PLANE_BRAM : xpm_memory_tdpram
        GENERIC MAP(
            MEMORY_SIZE => 262144,
            MEMORY_PRIMITIVE => "block",
            CLOCKING_MODE => "independent_clock",
            ECC_MODE => "no_ecc",
            ECC_TYPE => "none",
            ECC_BIT_RANGE => "[7:0]",
            MEMORY_INIT_FILE => "none",
            MEMORY_INIT_PARAM => "0",
            USE_MEM_INIT => 1,
            USE_MEM_INIT_MMI => 0,
            WAKEUP_TIME => "disable_sleep",
            MESSAGE_CONTROL => 0,
            USE_EMBEDDED_CONSTRAINT => 0,
            MEMORY_OPTIMIZATION => "true",
            CASCADE_HEIGHT => 0,
            SIM_ASSERT_CHK => 0,
            WRITE_PROTECT => 0,
            RAM_DECOMP => "auto",
            IGNORE_INIT_SYNTH => 0,
            WRITE_DATA_WIDTH_A => 8,
            READ_DATA_WIDTH_A => 8,
            BYTE_WRITE_WIDTH_A => 8,
            ADDR_WIDTH_A => 15,
            READ_RESET_VALUE_A => "0",
            READ_LATENCY_A => 1,
            WRITE_MODE_A => "no_change",
            RST_MODE_A => "SYNC",
            WRITE_DATA_WIDTH_B => 8,
            READ_DATA_WIDTH_B => 8,
            BYTE_WRITE_WIDTH_B => 8,
            ADDR_WIDTH_B => 15,
            READ_RESET_VALUE_B => "0",
            READ_LATENCY_B => 1,
            WRITE_MODE_B => "no_change",
            RST_MODE_B => "SYNC"
        )
        PORT MAP(
            sleep => '0',
            clka => clk100,
            rsta => '0',
            ena => avc_sys_en,
            regcea => '1',
            wea => (0 => avc_sys_we(plane_i)),
            addra => avc_sys_addr,
            dina => avc_sys_din,
            injectsbiterra => '0',
            injectdbiterra => '0',
            douta => avc_sys_dout(plane_i),
            sbiterra => OPEN,
            dbiterra => OPEN,
            clkb => vram_clk,
            rstb => '0',
            enb => '1',
            regceb => '1',
            web => "0",
            addrb => avc_video_addr,
            dinb => (OTHERS => '0'),
            injectsbiterrb => '0',
            injectdbiterrb => '0',
            doutb => avc_video_data(plane_i),
            sbiterrb => OPEN,
            dbiterrb => OPEN
        );
    END GENERATE AVC_PLANE_BRAMS;

    VIDEO_RAM_BRAM : xpm_memory_tdpram
    GENERIC MAP(
        MEMORY_SIZE => 8192,
        MEMORY_PRIMITIVE => "block",
        CLOCKING_MODE => "independent_clock",
        ECC_MODE => "no_ecc",
        ECC_TYPE => "none",
        ECC_BIT_RANGE => "[7:0]",
        MEMORY_INIT_FILE => "none",
        MEMORY_INIT_PARAM => "",
        USE_MEM_INIT => 0,
        USE_MEM_INIT_MMI => 0,
        WAKEUP_TIME => "disable_sleep",
        MESSAGE_CONTROL => 0,
        USE_EMBEDDED_CONSTRAINT => 0,
        MEMORY_OPTIMIZATION => "true",
        CASCADE_HEIGHT => 0,
        SIM_ASSERT_CHK => 0,
        WRITE_PROTECT => 0,
        RAM_DECOMP => "auto",
        IGNORE_INIT_SYNTH => 0,
        WRITE_DATA_WIDTH_A => 8,
        READ_DATA_WIDTH_A => 8,
        BYTE_WRITE_WIDTH_A => 8,
        ADDR_WIDTH_A => 10,
        READ_RESET_VALUE_A => "0",
        READ_LATENCY_A => 1,
        WRITE_MODE_A => "no_change",
        RST_MODE_A => "SYNC",
        WRITE_DATA_WIDTH_B => 8,
        READ_DATA_WIDTH_B => 8,
        BYTE_WRITE_WIDTH_B => 8,
        ADDR_WIDTH_B => 10,
        READ_RESET_VALUE_B => "0",
        READ_LATENCY_B => 1,
        WRITE_MODE_B => "no_change",
        RST_MODE_B => "SYNC"
    )
    PORT MAP(
        sleep => '0',
        clka => clk100,
        rsta => '0',
        ena => vram_sys_en,
        regcea => '1',
        wea => vram_sys_we,
        addra => vram_sys_addr,
        dina => vram_sys_din,
        injectsbiterra => '0',
        injectdbiterra => '0',
        douta => vram_sys_dout,
        sbiterra => OPEN,
        dbiterra => OPEN,
        clkb => vram_clk,
        rstb => '0',
        enb => '1',
        regceb => '1',
        web => "0",
        addrb => vram_addr,
        dinb => (OTHERS => '0'),
        injectsbiterrb => '0',
        injectdbiterrb => '0',
        doutb => vram_data,
        sbiterrb => OPEN,
        dbiterrb => OPEN
    );

    sd_cclk <= sd_spi_sclk;
    sd_reset <= '0';
    sd_cmd <= sd_spi_mosi;
    sd_d(0) <= 'Z';
    sd_d(1) <= '1';
    sd_d(2) <= '1';
    sd_d(3) <= sd_spi_cs_n;

    -- RTC data/status are provided by the Mega65 wrapper.
    rtc_scl_oe_n <= '1';
    rtc_sda_oe_n <= '1';
    rtc_regs_reg(0) <= rtc_seconds_i;
    rtc_regs_reg(1) <= rtc_minutes_i;
    rtc_regs_reg(2) <= rtc_hours_i;
    rtc_regs_reg(3) <= rtc_day_i;
    rtc_regs_reg(4) <= rtc_month_i;
    rtc_regs_reg(5) <= rtc_year_i;
    rtc_regs_reg(6) <= rtc_weekday_i;
    rtc_valid_reg <= rtc_valid_i;
    rtc_busy_reg <= rtc_busy_i;
    rtc_error_reg <= rtc_error_i;
    rtc_update_toggle_reg <= rtc_toggle_i;
    rtc_error_code_reg <= rtc_error_code_i;

    sys_reset <= raw_reset_req;

    -- RS232 routing:
    rs232_use_jtag <= '1' WHEN cfg_rs232_active = "000" ELSE
        '0';
    rs232_use_pmod1 <= '1' WHEN (cfg_rs232_active = "001" OR cfg_rs232_active = "010") ELSE
        '0';
    rs232_use_pmod2 <= '1' WHEN (cfg_rs232_active = "011" OR cfg_rs232_active = "100") ELSE
        '0';
    rs232_use_p1hi <= '1' WHEN cfg_rs232_active = "001" ELSE
        '0';
    rs232_use_p1lo <= '1' WHEN cfg_rs232_active = "010" ELSE
        '0';
    rs232_use_p2hi <= '1' WHEN cfg_rs232_active = "011" ELSE
        '0';
    rs232_use_p2lo <= '1' WHEN cfg_rs232_active = "100" ELSE
        '0';

    pmod1_en <= rs232_use_pmod1;
    pmod2_en <= rs232_use_pmod2;

    rs232_selected_flag_ok <= '1' WHEN rs232_use_jtag = '1' ELSE
        pmod1_flag WHEN rs232_use_pmod1 = '1' ELSE
        pmod2_flag WHEN rs232_use_pmod2 = '1' ELSE
        '1';

    rs232_uart_rxd <= uart_rxd WHEN rs232_use_jtag = '1' ELSE
        p1hi_rxd WHEN (rs232_use_p1hi = '1' AND pmod1_flag = '1') ELSE
        p1lo_rxd WHEN (rs232_use_p1lo = '1' AND pmod1_flag = '1') ELSE
        p2hi_rxd WHEN (rs232_use_p2hi = '1' AND pmod2_flag = '1') ELSE
        p2lo_rxd WHEN (rs232_use_p2lo = '1' AND pmod2_flag = '1') ELSE
        '1';

    rs232_cts_ok <= '1' WHEN (rs232_use_jtag = '1' OR cfg_rs232_flow_active = '0') ELSE
        NOT p1hi_cts WHEN (rs232_use_p1hi = '1' AND pmod1_flag = '1') ELSE
        NOT p1lo_cts WHEN (rs232_use_p1lo = '1' AND pmod1_flag = '1') ELSE
        NOT p2hi_cts WHEN (rs232_use_p2hi = '1' AND pmod2_flag = '1') ELSE
        NOT p2lo_cts WHEN (rs232_use_p2lo = '1' AND pmod2_flag = '1') ELSE
        '0';

    overlay_pmod_fault_active <= '1' WHEN
        ((rs232_use_pmod1 = '1') AND (pmod1_flag = '0')) OR
        ((rs232_use_pmod2 = '1') AND (pmod2_flag = '0')) ELSE
        '0';
    overlay_pmod_fault_pmod2 <= '1' WHEN ((rs232_use_pmod2 = '1') AND (pmod2_flag = '0')) ELSE
        '0';

    rs232_rts_out <= '0' WHEN (cfg_rs232_flow_active = '0' OR rx_count < 4) ELSE
        '1';
    rs232_tx_ready <= '1' WHEN (uart_busy = '0' AND rs232_selected_flag_ok = '1' AND rs232_cts_ok = '1') ELSE
        '0';

    uart_txd <= rs232_uart_txd WHEN rs232_use_jtag = '1' ELSE
        '1';
    p1lo_rts <= rs232_rts_out WHEN (rs232_use_p1lo = '1' AND pmod1_flag = '1') ELSE
        '0';
    p1lo_txd <= rs232_uart_txd WHEN (rs232_use_p1lo = '1' AND pmod1_flag = '1') ELSE
        '1';
    p1hi_rts <= rs232_rts_out WHEN (rs232_use_p1hi = '1' AND pmod1_flag = '1') ELSE
        '0';
    p1hi_txd <= rs232_uart_txd WHEN (rs232_use_p1hi = '1' AND pmod1_flag = '1') ELSE
        '1';
    p2lo_rts <= rs232_rts_out WHEN (rs232_use_p2lo = '1' AND pmod2_flag = '1') ELSE
        '0';
    p2lo_txd <= rs232_uart_txd WHEN (rs232_use_p2lo = '1' AND pmod2_flag = '1') ELSE
        '1';
    p2hi_rts <= rs232_rts_out WHEN (rs232_use_p2hi = '1' AND pmod2_flag = '1') ELSE
        '0';
    p2hi_txd <= rs232_uart_txd WHEN (rs232_use_p2hi = '1' AND pmod2_flag = '1') ELSE
        '1';

    -- Export the complete WD1793 data-transfer interval.  The MEGA65 wrapper
    -- serialises this onto both physical drive-LED channels.
    led <= cfg_fdd_active AND (
        fdc_status_reg(0) OR
        fdd_read_busy OR
        fdd_write_busy OR
        fdd_format_busy OR
        fdc_write_sector_active OR
        fdc_write_track_active OR
        fdc_track_commit_active);

END Behavioral;
