--------------------------------------------------------------------------------
-- Mega65 wrapper for the shared/current Nascom2 top-level.
--
--------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY Mega65_Nascom2 IS
    GENERIC (
        -- The R6 build uses the default.  The R3/R3A board wrapper overrides
        -- this so the internal RTC master selects the R3 ISL12020 protocol.
        G_BOARD : STRING := "MEGA65_R6"
    );
    PORT (
        CLK_IN : IN STD_LOGIC;
        reset_button : IN STD_LOGIC;
        kb_io0 : OUT STD_LOGIC;
        kb_io1 : OUT STD_LOGIC;
        kb_io2 : IN STD_LOGIC;
        fpga_scl : INOUT STD_LOGIC;
        fpga_sda : INOUT STD_LOGIC;
        grove_scl : INOUT STD_LOGIC;
        grove_sda : INOUT STD_LOGIC;

        led : OUT STD_LOGIC;

        TMDS_clk_p : OUT STD_LOGIC;
        TMDS_clk_n : OUT STD_LOGIC;
        TMDS_data_p : OUT STD_LOGIC_VECTOR(0 TO 2);
        TMDS_data_n : OUT STD_LOGIC_VECTOR(0 TO 2);
        hdmi_enable_n : OUT STD_LOGIC;
        hdmi_hiz : OUT STD_LOGIC;
        hpd_a : OUT STD_LOGIC;

        audio_mclk_o : OUT STD_LOGIC;
        audio_bick_o : OUT STD_LOGIC;
        audio_sdti_o : OUT STD_LOGIC;
        audio_lrclk_o : OUT STD_LOGIC;
        audio_pdn_n_o : OUT STD_LOGIC;
        audio_i2cfil_o : OUT STD_LOGIC;
        audio_scl_io : INOUT STD_LOGIC;
        audio_sda_io : INOUT STD_LOGIC;

        vdac_clk : OUT STD_LOGIC;
        vdac_sync_n : OUT STD_LOGIC;
        vdac_blank_n : OUT STD_LOGIC;
        vdac_psave_n : OUT STD_LOGIC;
        vgared : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        vgagreen : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        vgablue : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        hsync : OUT STD_LOGIC;
        vsync : OUT STD_LOGIC;

        UART_TXD : OUT STD_LOGIC;
        RsRx : IN STD_LOGIC;

        pmod1_en : OUT STD_LOGIC; -- enable active_high
        pmod1_flag : IN STD_LOGIC; -- active_low, if over_current or over_temperature
        p1lo_cts : IN STD_LOGIC;  -- CTS
        p1lo_rts : OUT STD_LOGIC; -- RTS
        p1lo_txd : OUT STD_LOGIC; -- TXD
        p1lo_rxd : IN STD_LOGIC;  -- RXD

        p1hi_cts : IN STD_LOGIC;  -- CTS
        p1hi_rts : OUT STD_LOGIC; -- RTS
        p1hi_txd : OUT STD_LOGIC; -- TXD
        p1hi_rxd : IN STD_LOGIC;  -- RXD

        pmod2_en : OUT STD_LOGIC; -- enable active_high
        pmod2_flag : IN STD_LOGIC; -- active_low, if over_current or over_temperature
        p2lo_cts : IN STD_LOGIC;  -- CTS
        p2lo_rts : OUT STD_LOGIC; -- RTS
        p2lo_txd : OUT STD_LOGIC; -- TXD
        p2lo_rxd : IN STD_LOGIC;  -- RXD

        p2hi_cts : IN STD_LOGIC;  -- CTS
        p2hi_rts : OUT STD_LOGIC; -- RTS
        p2hi_txd : OUT STD_LOGIC; -- TXD
        p2hi_rxd : IN STD_LOGIC;  -- RXD

        fa_down_n_i : IN STD_LOGIC;
        fa_fire_n_i : IN STD_LOGIC;
        fa_left_n_i : IN STD_LOGIC;
        fa_right_n_i : IN STD_LOGIC;
        fa_up_n_i : IN STD_LOGIC;
        fb_down_n_i : IN STD_LOGIC;
        fb_fire_n_i : IN STD_LOGIC;
        fb_left_n_i : IN STD_LOGIC;
        fb_right_n_i : IN STD_LOGIC;
        fb_up_n_i : IN STD_LOGIC;
        cart_and_joy_en : OUT STD_LOGIC;
        fa_down_drain_n : OUT STD_LOGIC;
        fa_fire_drain_n : OUT STD_LOGIC;
        fa_left_drain_n : OUT STD_LOGIC;
        fa_right_drain_n : OUT STD_LOGIC;
        fa_up_drain_n : OUT STD_LOGIC;
        fb_down_drain_n : OUT STD_LOGIC;
        fb_fire_drain_n : OUT STD_LOGIC;
        fb_left_drain_n : OUT STD_LOGIC;
        fb_right_drain_n : OUT STD_LOGIC;
        fb_up_drain_n : OUT STD_LOGIC;

        eth_mdio : INOUT STD_LOGIC;
        eth_mdc : OUT STD_LOGIC;
        eth_reset : OUT STD_LOGIC;
        eth_rxd : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        eth_txd : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        eth_txen : OUT STD_LOGIC;
        eth_rxdv : IN STD_LOGIC;
        eth_rxer : IN STD_LOGIC;
        eth_clock : OUT STD_LOGIC;

        sd2Clock : OUT STD_LOGIC;
        sd2reset : OUT STD_LOGIC;
        sd2MISO : IN STD_LOGIC;
        sd2MOSI : OUT STD_LOGIC;
        sd2CD : IN STD_LOGIC;
        sd2_dat : OUT STD_LOGIC_VECTOR(2 DOWNTO 1)
    );
END ENTITY Mega65_Nascom2;

ARCHITECTURE rtl OF Mega65_Nascom2 IS
    COMPONENT Nascom2_Core IS
        PORT (
            clk100 : IN STD_LOGIC;
            led : OUT STD_LOGIC;
            uart_txd : OUT STD_LOGIC;
            uart_rxd : IN STD_LOGIC;
            pmod1_en : OUT STD_LOGIC; -- enable active_high
            pmod1_flag : IN STD_LOGIC; -- active_low, if over_current or over_temperature
            p1lo_cts : IN STD_LOGIC;  -- CTS
            p1lo_rts : OUT STD_LOGIC; -- RTS
            p1lo_txd : OUT STD_LOGIC; -- TXD
            p1lo_rxd : IN STD_LOGIC;  -- RXD
            p1hi_cts : IN STD_LOGIC;  -- CTS
            p1hi_rts : OUT STD_LOGIC; -- RTS
            p1hi_txd : OUT STD_LOGIC; -- TXD
            p1hi_rxd : IN STD_LOGIC;  -- RXD
            pmod2_en : OUT STD_LOGIC; -- enable active_high
            pmod2_flag : IN STD_LOGIC; -- active_low, if over_current or over_temperature
            p2lo_cts : IN STD_LOGIC;  -- CTS
            p2lo_rts : OUT STD_LOGIC; -- RTS
            p2lo_txd : OUT STD_LOGIC; -- TXD
            p2lo_rxd : IN STD_LOGIC;  -- RXD
            p2hi_cts : IN STD_LOGIC;  -- CTS
            p2hi_rts : OUT STD_LOGIC; -- RTS
            p2hi_txd : OUT STD_LOGIC; -- TXD
            p2hi_rxd : IN STD_LOGIC;  -- RXD
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
            manual_nmi_key_i : IN STD_LOGIC;
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
            network_ping_result_i : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            network_available_i : IN STD_LOGIC;
            network_link_i : IN STD_LOGIC;
            network_effective_ipv4_i : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            network_effective_netmask_i : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            network_effective_gateway_i : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            network_effective_dns_i : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            network_dhcp_status_i : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            network_debug_i : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            network_tcp_status_i : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            network_tcp_status_socket_i : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
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
            network_tcp_tx_ready_i : IN STD_LOGIC;
            network_tcp_rx_toggle_i : IN STD_LOGIC;
            network_tcp_rx_socket_i : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            network_tcp_rx_length_i : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            network_tcp_rx_data_i : IN STD_LOGIC_VECTOR(1023 DOWNTO 0);
            network_tcp_query_socket_o : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            network_tcp_rx_consume_toggle_o : OUT STD_LOGIC;
            network_tcp_rx_consume_socket_o : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
        );
    END COMPONENT;


    SIGNAL mega_sd_cmd : STD_LOGIC;
    SIGNAL mega_sd_d : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL mega_sd_cclk : STD_LOGIC;
    SIGNAL mega_sd_reset_unused : STD_LOGIC;
    SIGNAL nexys_reset_btn_n : STD_LOGIC;
    SIGNAL nascom_audio_pdm_l : STD_LOGIC;
    SIGNAL nascom_audio_pdm_r : STD_LOGIC;
    SIGNAL nascom_audio_pcm : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL r3_audio_pdm_l : STD_LOGIC;
    SIGNAL r3_audio_pdm_r : STD_LOGIC;
    SIGNAL mega_ps2_clk : STD_LOGIC;
    SIGNAL mega_ps2_data : STD_LOGIC;
    SIGNAL mega_nmi_chord : STD_LOGIC;
    SIGNAL mega_kbd_reset : STD_LOGIC;
    SIGNAL nascom_drive_led : STD_LOGIC := '0';
    SIGNAL rtc_scl_i : STD_LOGIC;
    SIGNAL rtc_scl_oe_n : STD_LOGIC := '1';
    SIGNAL rtc_sda_i : STD_LOGIC;
    SIGNAL rtc_sda_oe_n : STD_LOGIC := '1';
    SIGNAL rtc_core_scl_oe_n_unused : STD_LOGIC;
    SIGNAL rtc_core_sda_oe_n_unused : STD_LOGIC;
    SIGNAL rtc_seconds : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL rtc_minutes : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL rtc_hours : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL rtc_weekday : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL rtc_day : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL rtc_month : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL rtc_year : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL rtc_valid : STD_LOGIC := '0';
    SIGNAL rtc_busy : STD_LOGIC := '0';
    SIGNAL rtc_error : STD_LOGIC := '0';
    SIGNAL rtc_toggle : STD_LOGIC := '0';
    SIGNAL rtc_error_code : STD_LOGIC_VECTOR(3 DOWNTO 0) := x"0";
    SIGNAL rtc_debug_busy_count : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL rtc_debug_status : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL rtc_debug_last_byte : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL rtc_debug_addr : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    CONSTANT RTC_REFRESH_CYCLES : INTEGER := 25000000;
    CONSTANT RTC_STARTUP_CYCLES : INTEGER := 100000;
    SIGNAL rtc_internal_refresh_counter : INTEGER RANGE 0 TO RTC_REFRESH_CYCLES := RTC_STARTUP_CYCLES;
    SIGNAL rtc_internal_busy : STD_LOGIC := '0';
    SIGNAL rtc_internal_busy_last : STD_LOGIC := '0';
    SIGNAL rtc_internal_request : STD_LOGIC := '0';
    SIGNAL rtc_internal_data : STD_LOGIC_VECTOR(63 DOWNTO 0) := (OTHERS => '0');
    SIGNAL rtc_internal_read_valid : STD_LOGIC := '0';
    SIGNAL rtc_internal_data_valid : STD_LOGIC := '0';
    SIGNAL rtc_internal_i2c_wait : STD_LOGIC := '0';
    SIGNAL rtc_internal_i2c_ce : STD_LOGIC := '0';
    SIGNAL rtc_internal_i2c_we : STD_LOGIC := '0';
    SIGNAL rtc_internal_i2c_addr : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL rtc_internal_i2c_wr_data : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL rtc_internal_i2c_rd_data : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL internal_i2c_wait : STD_LOGIC := '0';
    SIGNAL internal_i2c_ce : STD_LOGIC := '0';
    SIGNAL internal_i2c_we : STD_LOGIC := '0';
    SIGNAL internal_i2c_addr : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL internal_i2c_wr_data : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL internal_i2c_rd_data : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL joystick_core_a_n : STD_LOGIC_VECTOR(4 DOWNTO 0) := (OTHERS => '1');
    SIGNAL joystick_core_b_n : STD_LOGIC_VECTOR(4 DOWNTO 0) := (OTHERS => '1');
    SIGNAL rtc_internal_scl_in_bus : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '1');
    SIGNAL rtc_internal_sda_in_bus : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '1');
    SIGNAL rtc_internal_scl_out_bus : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL rtc_internal_sda_out_bus : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL rtc_grove_refresh_counter : INTEGER RANGE 0 TO RTC_REFRESH_CYCLES := RTC_STARTUP_CYCLES;
    SIGNAL rtc_grove_busy : STD_LOGIC := '0';
    SIGNAL rtc_grove_busy_last : STD_LOGIC := '0';
    SIGNAL rtc_grove_request : STD_LOGIC := '0';
    SIGNAL rtc_grove_data : STD_LOGIC_VECTOR(63 DOWNTO 0) := (OTHERS => '0');
    SIGNAL rtc_grove_read_valid : STD_LOGIC := '0';
    SIGNAL rtc_grove_i2c_wait : STD_LOGIC := '0';
    SIGNAL rtc_grove_i2c_ce : STD_LOGIC := '0';
    SIGNAL rtc_grove_i2c_we : STD_LOGIC := '0';
    SIGNAL rtc_grove_i2c_addr : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL rtc_grove_i2c_wr_data : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL rtc_grove_i2c_rd_data : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL rtc_grove_scl_in_bus : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '1');
    SIGNAL rtc_grove_sda_in_bus : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '1');
    SIGNAL rtc_grove_scl_out_bus : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL rtc_grove_sda_out_bus : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL rtc_grove_present : STD_LOGIC := '0';
    SIGNAL rtc_grove_good_count : INTEGER RANGE 0 TO 3 := 0;
    SIGNAL rtc_grove_bad_count : INTEGER RANGE 0 TO 3 := 0;

    FUNCTION rtc_bcd_valid(value : STD_LOGIC_VECTOR(7 DOWNTO 0);
                           max_tens : NATURAL;
                           allow_zero : BOOLEAN) RETURN BOOLEAN IS
        VARIABLE tens : NATURAL;
        VARIABLE ones : NATURAL;
    BEGIN
        tens := TO_INTEGER(UNSIGNED(value(7 DOWNTO 4)));
        ones := TO_INTEGER(UNSIGNED(value(3 DOWNTO 0)));
        RETURN ones <= 9 AND tens <= max_tens AND
               (allow_zero OR value(6 DOWNTO 0) /= "0000000");
    END FUNCTION;

    FUNCTION rtc_data_plausible(value : STD_LOGIC_VECTOR(63 DOWNTO 0)) RETURN BOOLEAN IS
        VARIABLE hours : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE month : STD_LOGIC_VECTOR(7 DOWNTO 0);
    BEGIN
        hours := '0' & value(30 DOWNTO 24);
        month := '0' & value(46 DOWNTO 40);
        RETURN rtc_bcd_valid(value(15 DOWNTO 8), 5, TRUE) AND
               rtc_bcd_valid(value(23 DOWNTO 16), 5, TRUE) AND
               rtc_bcd_valid(hours, 2, TRUE) AND UNSIGNED(hours) <= X"23" AND
               rtc_bcd_valid(value(39 DOWNTO 32), 3, FALSE) AND
               UNSIGNED(value(39 DOWNTO 32)) <= X"31" AND
               rtc_bcd_valid(month, 1, FALSE) AND UNSIGNED(month) <= X"12" AND
               rtc_bcd_valid(value(55 DOWNTO 48), 9, TRUE);
    END FUNCTION;
    SIGNAL network_enable : STD_LOGIC := '0';
    SIGNAL network_dhcp : STD_LOGIC := '0';
    SIGNAL network_ipv4 : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"C0A80141";
    SIGNAL network_netmask : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"FFFFFF00";
    SIGNAL network_gateway : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"C0A80101";
    SIGNAL network_dns : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"C0A80101";
    SIGNAL network_link : STD_LOGIC := '0';
    SIGNAL network_effective_ipv4_raw : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL network_effective_ipv4_meta : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL network_effective_ipv4 : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL network_effective_netmask_raw : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL network_effective_netmask_meta : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL network_effective_netmask : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL network_effective_gateway_raw : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL network_effective_gateway_meta : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL network_effective_gateway : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL network_effective_dns_raw : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL network_effective_dns_meta : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL network_effective_dns : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL network_dhcp_status_raw : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL network_dhcp_status_meta : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL network_dhcp_status : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL network_link_raw : STD_LOGIC := '0';
    SIGNAL network_link_meta : STD_LOGIC := '0';
    SIGNAL network_debug_raw : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL network_debug_meta : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL network_debug : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL network_available : STD_LOGIC := '0';
    SIGNAL network_cpu_reset : STD_LOGIC := '1';
    SIGNAL network_dns_query_toggle : STD_LOGIC := '0';
    SIGNAL network_dns_query_length : STD_LOGIC_VECTOR(6 DOWNTO 0) := (OTHERS => '0');
    SIGNAL network_dns_query_data : STD_LOGIC_VECTOR(511 DOWNTO 0) := (OTHERS => '0');
    SIGNAL network_ping_start_toggle : STD_LOGIC := '0';
    SIGNAL network_ping_target_ip : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL network_ping_result : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"E0";
    SIGNAL network_tcp_connect_toggle : STD_LOGIC := '0';
    SIGNAL network_tcp_connect_socket : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL network_tcp_connect_ip : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL network_tcp_connect_port : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL network_tcp_close_toggle : STD_LOGIC := '0';
    SIGNAL network_tcp_close_socket : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL network_tcp_status_raw : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL network_tcp_status_meta : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL network_tcp_status : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL network_tcp_status_socket_raw : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL network_tcp_status_socket_meta : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL network_tcp_status_socket : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL network_tcp_send_toggle : STD_LOGIC := '0';
    SIGNAL network_tcp_send_socket : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL network_tcp_send_length : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL network_tcp_send_data : STD_LOGIC_VECTOR(1023 DOWNTO 0) := (OTHERS => '0');
    SIGNAL network_tcp_tx_ready_raw : STD_LOGIC := '0';
    SIGNAL network_tcp_tx_ready_meta : STD_LOGIC := '0';
    SIGNAL network_tcp_tx_ready : STD_LOGIC := '0';
    SIGNAL network_tcp_rx_toggle_raw : STD_LOGIC := '0';
    SIGNAL network_tcp_rx_toggle_meta : STD_LOGIC := '0';
    SIGNAL network_tcp_rx_toggle : STD_LOGIC := '0';
    SIGNAL network_tcp_rx_socket_raw : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL network_tcp_rx_socket_meta : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL network_tcp_rx_socket : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL network_tcp_rx_length_raw : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL network_tcp_rx_length_meta : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL network_tcp_rx_length : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL network_tcp_rx_data_raw : STD_LOGIC_VECTOR(1023 DOWNTO 0) := (OTHERS => '0');
    SIGNAL network_tcp_rx_data_meta : STD_LOGIC_VECTOR(1023 DOWNTO 0) := (OTHERS => '0');
    SIGNAL network_tcp_rx_data : STD_LOGIC_VECTOR(1023 DOWNTO 0) := (OTHERS => '0');
    SIGNAL network_tcp_query_socket : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL network_tcp_rx_consume_toggle : STD_LOGIC := '0';
    SIGNAL network_tcp_rx_consume_socket : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
BEGIN
    -- Enable the Mega65 HDMI output buffer. These levels match the signal
    -- names used by the reference constraints and are kept wrapper-local.
    hdmi_enable_n <= '0';
    hdmi_hiz <= '0';
    hpd_a <= '1';
    -- R4/R5/R6 route the joystick sockets through a shared enable and
    -- open-drain output stage.  Enable the interface and leave every drain
    -- inactive while the Nascom core uses the sockets strictly as inputs.
    cart_and_joy_en <= '1';
    fa_down_drain_n <= '1';
    fa_fire_drain_n <= '1';
    fa_left_drain_n <= '1';
    fa_right_drain_n <= '1';
    fa_up_drain_n <= '1';
    fb_down_drain_n <= '1';
    fb_fire_drain_n <= '1';
    fb_left_drain_n <= '1';
    fb_right_drain_n <= '1';
    fb_up_drain_n <= '1';
    network_available <= '1' WHEN
        G_BOARD = "MEGA65_R6" OR G_BOARD = "MEGA65_R3"
        ELSE '0';

    -- The onboard RTC and optional Grove DS3231 use separate physical buses.
    -- Poll both continuously, prefer Grove after three plausible reads, and
    -- return to the onboard RTC after three failed Grove reads.
    rtc_scl_i <= grove_scl WHEN rtc_grove_present = '1' ELSE fpga_scl;
    rtc_sda_i <= grove_sda WHEN rtc_grove_present = '1' ELSE fpga_sda;
    rtc_internal_scl_in_bus <= "1111111" & fpga_scl;
    rtc_internal_sda_in_bus <= "1111111" & fpga_sda;
    fpga_scl <= '0' WHEN rtc_internal_scl_out_bus(0) = '0' ELSE 'Z';
    fpga_sda <= '0' WHEN rtc_internal_sda_out_bus(0) = '0' ELSE 'Z';
    rtc_grove_scl_in_bus <= "1111111" & grove_scl;
    rtc_grove_sda_in_bus <= "1111111" & grove_sda;
    grove_scl <= '0' WHEN rtc_grove_scl_out_bus(0) = '0' ELSE 'Z';
    grove_sda <= '0' WHEN rtc_grove_sda_out_bus(0) = '0' ELSE 'Z';

    RTC_INTERNAL_I2C_CTRL_INST : entity work.i2c_controller
        GENERIC MAP(
            G_I2C_CLK_DIV => 500
        )
        PORT MAP(
            clk_i => CLK_IN,
            rst_i => reset_button,
            cpu_wait_o => internal_i2c_wait,
            cpu_ce_i => internal_i2c_ce,
            cpu_we_i => internal_i2c_we,
            cpu_addr_i => X"00000" & internal_i2c_addr,
            cpu_wr_data_i => internal_i2c_wr_data,
            cpu_rd_data_o => internal_i2c_rd_data,
            scl_in_i => rtc_internal_scl_in_bus,
            sda_in_i => rtc_internal_sda_in_bus,
            scl_out_o => rtc_internal_scl_out_bus,
            sda_out_o => rtc_internal_sda_out_bus
        );

    internal_i2c_ce <= rtc_internal_i2c_ce;
    internal_i2c_we <= rtc_internal_i2c_we;
    internal_i2c_addr <= rtc_internal_i2c_addr;
    internal_i2c_wr_data <= rtc_internal_i2c_wr_data;
    rtc_internal_i2c_wait <= internal_i2c_wait;
    rtc_internal_i2c_rd_data <= internal_i2c_rd_data;

    RTC_INTERNAL_MASTER_INST : entity work.rtc_master
        GENERIC MAP(
            G_BOARD => G_BOARD
        )
        PORT MAP(
            clk_i => CLK_IN,
            rst_i => reset_button,
            rtc_busy_o => rtc_internal_busy,
            rtc_read_valid_o => rtc_internal_read_valid,
            rtc_read_i => rtc_internal_request,
            rtc_write_i => '0',
            rtc_wr_data_i => (OTHERS => '0'),
            rtc_rd_data_o => rtc_internal_data,
            cpu_m_wait_i => rtc_internal_i2c_wait,
            cpu_m_ce_o => rtc_internal_i2c_ce,
            cpu_m_we_o => rtc_internal_i2c_we,
            cpu_m_addr_o => rtc_internal_i2c_addr,
            cpu_m_wr_data_o => rtc_internal_i2c_wr_data,
            cpu_m_rd_data_i => rtc_internal_i2c_rd_data
        );

    RTC_GROVE_I2C_CTRL_INST : entity work.i2c_controller
        GENERIC MAP(
            G_I2C_CLK_DIV => 500
        )
        PORT MAP(
            clk_i => CLK_IN,
            rst_i => reset_button,
            cpu_wait_o => rtc_grove_i2c_wait,
            cpu_ce_i => rtc_grove_i2c_ce,
            cpu_we_i => rtc_grove_i2c_we,
            cpu_addr_i => X"00000" & rtc_grove_i2c_addr,
            cpu_wr_data_i => rtc_grove_i2c_wr_data,
            cpu_rd_data_o => rtc_grove_i2c_rd_data,
            scl_in_i => rtc_grove_scl_in_bus,
            sda_in_i => rtc_grove_sda_in_bus,
            scl_out_o => rtc_grove_scl_out_bus,
            sda_out_o => rtc_grove_sda_out_bus
        );

    RTC_GROVE_MASTER_INST : entity work.rtc_master
        GENERIC MAP(
            G_BOARD => "MEGA65_R3_GROVE"
        )
        PORT MAP(
            clk_i => CLK_IN,
            rst_i => reset_button,
            rtc_busy_o => rtc_grove_busy,
            rtc_read_valid_o => rtc_grove_read_valid,
            rtc_read_i => rtc_grove_request,
            rtc_write_i => '0',
            rtc_wr_data_i => (OTHERS => '0'),
            rtc_rd_data_o => rtc_grove_data,
            cpu_m_wait_i => rtc_grove_i2c_wait,
            cpu_m_ce_o => rtc_grove_i2c_ce,
            cpu_m_we_o => rtc_grove_i2c_we,
            cpu_m_addr_o => rtc_grove_i2c_addr,
            cpu_m_wr_data_o => rtc_grove_i2c_wr_data,
            cpu_m_rd_data_i => rtc_grove_i2c_rd_data
        );

    PROCESS (CLK_IN)
    BEGIN
        IF rising_edge(CLK_IN) THEN
            rtc_internal_request <= '0';
            rtc_grove_request <= '0';

            IF reset_button = '1' THEN
                rtc_busy <= '0';
                rtc_valid <= '0';
                rtc_error <= '0';
                rtc_error_code <= x"0";
                rtc_debug_busy_count <= x"00";
                rtc_debug_status <= x"00";
                rtc_debug_last_byte <= x"00";
                rtc_debug_addr <= x"00";
                rtc_toggle <= '0';
                rtc_internal_refresh_counter <= RTC_STARTUP_CYCLES;
                rtc_grove_refresh_counter <= RTC_STARTUP_CYCLES;
                rtc_internal_busy_last <= '0';
                rtc_grove_busy_last <= '0';
                rtc_internal_data_valid <= '0';
                rtc_grove_present <= '0';
                rtc_grove_good_count <= 0;
                rtc_grove_bad_count <= 0;
                rtc_seconds <= x"00";
                rtc_minutes <= x"00";
                rtc_hours <= x"00";
                rtc_weekday <= x"00";
                rtc_day <= x"00";
                rtc_month <= x"00";
                rtc_year <= x"00";
            ELSE
                rtc_busy <= rtc_internal_busy OR rtc_grove_busy;
                rtc_debug_status <= rtc_grove_present & rtc_grove_busy &
                                    rtc_internal_busy & rtc_valid &
                                    grove_scl & grove_sda & fpga_scl & fpga_sda;

                IF rtc_internal_busy = '0' THEN
                    IF rtc_internal_refresh_counter > 0 THEN
                        rtc_internal_refresh_counter <= rtc_internal_refresh_counter - 1;
                    ELSE
                        rtc_internal_request <= '1';
                        rtc_internal_refresh_counter <= RTC_REFRESH_CYCLES;
                    END IF;
                END IF;

                IF rtc_grove_busy = '0' THEN
                    IF rtc_grove_refresh_counter > 0 THEN
                        rtc_grove_refresh_counter <= rtc_grove_refresh_counter - 1;
                    ELSE
                        rtc_grove_request <= '1';
                        rtc_grove_refresh_counter <= RTC_REFRESH_CYCLES;
                    END IF;
                END IF;

                IF rtc_internal_busy_last = '1' AND rtc_internal_busy = '0' THEN
                    IF rtc_internal_read_valid = '1' AND
                       rtc_data_plausible(rtc_internal_data) THEN
                        rtc_internal_data_valid <= '1';
                        IF rtc_grove_present = '0' THEN
                            rtc_seconds <= rtc_internal_data(15 DOWNTO 8);
                            rtc_minutes <= rtc_internal_data(23 DOWNTO 16);
                            rtc_hours <= rtc_internal_data(31 DOWNTO 24);
                            rtc_day <= rtc_internal_data(39 DOWNTO 32);
                            rtc_month <= rtc_internal_data(47 DOWNTO 40);
                            rtc_year <= rtc_internal_data(55 DOWNTO 48);
                            rtc_weekday <= rtc_internal_data(63 DOWNTO 56);
                            rtc_valid <= '1';
                            rtc_toggle <= NOT rtc_toggle;
                            rtc_debug_last_byte <= rtc_internal_data(15 DOWNTO 8);
                            rtc_debug_addr <= x"A3";
                        END IF;
                    ELSE
                        rtc_internal_data_valid <= '0';
                        IF rtc_grove_present = '0' THEN
                            rtc_valid <= '0';
                        END IF;
                    END IF;
                END IF;

                IF rtc_grove_busy_last = '1' AND rtc_grove_busy = '0' THEN
                    IF rtc_grove_read_valid = '1' AND
                       rtc_data_plausible(rtc_grove_data) THEN
                        rtc_grove_bad_count <= 0;
                        IF rtc_grove_good_count < 3 THEN
                            rtc_grove_good_count <= rtc_grove_good_count + 1;
                        END IF;
                        IF rtc_grove_good_count >= 2 THEN
                            rtc_grove_present <= '1';
                            rtc_seconds <= rtc_grove_data(15 DOWNTO 8);
                            rtc_minutes <= rtc_grove_data(23 DOWNTO 16);
                            rtc_hours <= rtc_grove_data(31 DOWNTO 24);
                            rtc_day <= rtc_grove_data(39 DOWNTO 32);
                            rtc_month <= rtc_grove_data(47 DOWNTO 40);
                            rtc_year <= rtc_grove_data(55 DOWNTO 48);
                            rtc_weekday <= rtc_grove_data(63 DOWNTO 56);
                            rtc_valid <= '1';
                            rtc_toggle <= NOT rtc_toggle;
                            rtc_debug_last_byte <= rtc_grove_data(15 DOWNTO 8);
                            rtc_debug_addr <= x"D1";
                        END IF;
                    ELSE
                        rtc_grove_good_count <= 0;
                        IF rtc_grove_bad_count < 3 THEN
                            rtc_grove_bad_count <= rtc_grove_bad_count + 1;
                        END IF;
                        IF rtc_grove_bad_count >= 2 THEN
                            rtc_grove_present <= '0';
                            IF rtc_internal_data_valid = '1' THEN
                                rtc_seconds <= rtc_internal_data(15 DOWNTO 8);
                                rtc_minutes <= rtc_internal_data(23 DOWNTO 16);
                                rtc_hours <= rtc_internal_data(31 DOWNTO 24);
                                rtc_day <= rtc_internal_data(39 DOWNTO 32);
                                rtc_month <= rtc_internal_data(47 DOWNTO 40);
                                rtc_year <= rtc_internal_data(55 DOWNTO 48);
                                rtc_weekday <= rtc_internal_data(63 DOWNTO 56);
                                rtc_valid <= '1';
                                rtc_toggle <= NOT rtc_toggle;
                                rtc_debug_last_byte <= rtc_internal_data(15 DOWNTO 8);
                                rtc_debug_addr <= x"A3";
                            ELSE
                                rtc_valid <= '0';
                            END IF;
                        END IF;
                    END IF;
                END IF;

                rtc_error <= NOT rtc_valid;
                IF rtc_valid = '1' THEN
                    rtc_error_code <= x"0";
                ELSE
                    rtc_error_code <= x"1";
                END IF;
                rtc_debug_busy_count <= x"10";
                rtc_internal_busy_last <= rtc_internal_busy;
                rtc_grove_busy_last <= rtc_grove_busy;
            END IF;
        END IF;
    END PROCESS;

    -- Mega65 external SD slot in SPI mode. The Mega65 sd2reset pin is the card DAT3/CS
    -- pin in the reference constraints, so it carries the shared core CS signal.
    sd2Clock <= mega_sd_cclk;
    sd2MOSI <= mega_sd_cmd;
    sd2reset <= mega_sd_d(3);
    sd2_dat(1) <= mega_sd_d(1);
    sd2_dat(2) <= mega_sd_d(2);
    mega_sd_d(0) <= sd2MISO;

    -- The wrapped Nexys top expects reset_btn active-low. The Mega65 side
    -- reset button pin is treated as active-high for this wrapper.
    nexys_reset_btn_n <= NOT reset_button;

    -- Diagnostic for first hardware tests: LED follows the raw Mega65 button.
    led <= reset_button;

    mega_kbd_reset <= NOT nexys_reset_btn_n;

    MEGA65_ETHERNET : IF
        G_BOARD = "MEGA65_R6" OR G_BOARD = "MEGA65_R3" GENERATE
        u_ethernet : ENTITY work.nascom2_ethernet_r6
            PORT MAP (
                clk100 => CLK_IN,
                -- The front-panel reset is a Nascom/Z80 reset, not a power
                -- cycle of the Ethernet subsystem.  Feeding it into the
                -- Ethernet MMCM restarted the whole IP core and reused TCP
                -- source ports while the peer still retained orphaned
                -- sessions.  FPGA configuration/MMCM_LOCKED supplies the
                -- Ethernet power-on reset; network_cpu_reset aborts sockets.
                reset => '0',
                cpu_reset => network_cpu_reset,
                enable => network_enable,
                dhcp_enable => network_dhcp,
                ipv4_address => network_ipv4,
                ipv4_netmask => network_netmask,
                ipv4_gateway => network_gateway,
                dns_server => network_dns,
                effective_ipv4_address => network_effective_ipv4_raw,
                effective_ipv4_netmask => network_effective_netmask_raw,
                effective_ipv4_gateway => network_effective_gateway_raw,
                effective_dns_server => network_effective_dns_raw,
                dhcp_status => network_dhcp_status_raw,
                dns_query_toggle => network_dns_query_toggle,
                dns_query_length => network_dns_query_length,
                dns_query_data => network_dns_query_data,
                ping_start_toggle => network_ping_start_toggle,
                ping_target_ip => network_ping_target_ip,
                ping_result => network_ping_result,
                tcp_connect_toggle => network_tcp_connect_toggle,
                tcp_connect_socket => network_tcp_connect_socket,
                tcp_connect_ip => network_tcp_connect_ip,
                tcp_connect_port => network_tcp_connect_port,
                tcp_close_toggle => network_tcp_close_toggle,
                tcp_close_socket => network_tcp_close_socket,
                tcp_send_toggle => network_tcp_send_toggle,
                tcp_send_socket => network_tcp_send_socket,
                tcp_send_length => network_tcp_send_length,
                tcp_send_data => network_tcp_send_data,
                tcp_tx_ready => network_tcp_tx_ready_raw,
                tcp_rx_toggle => network_tcp_rx_toggle_raw,
                tcp_rx_socket => network_tcp_rx_socket_raw,
                tcp_rx_length => network_tcp_rx_length_raw,
                tcp_rx_data => network_tcp_rx_data_raw,
                tcp_query_socket => network_tcp_query_socket,
                tcp_rx_consume_toggle => network_tcp_rx_consume_toggle,
                tcp_rx_consume_socket => network_tcp_rx_consume_socket,
                tcp_status => network_tcp_status_raw,
                tcp_status_socket => network_tcp_status_socket_raw,
                link_up => network_link_raw,
                debug_counters => network_debug_raw,
                eth_mdio => eth_mdio,
                eth_mdc => eth_mdc,
                eth_reset => eth_reset,
                eth_rxd => eth_rxd,
                eth_txd => eth_txd,
                eth_txen => eth_txen,
                eth_rxdv => eth_rxdv,
                eth_rxer => eth_rxer,
                eth_clock => eth_clock
            );
    END GENERATE;

    NO_MEGA65_ETHERNET : IF
        G_BOARD /= "MEGA65_R6" AND G_BOARD /= "MEGA65_R3" GENERATE
        eth_mdio <= 'Z';
        eth_mdc <= '0';
        eth_reset <= '0';
        eth_txd <= "00";
        eth_txen <= '0';
        eth_clock <= '0';
        network_link_raw <= '0';
        network_effective_ipv4_raw <= (OTHERS => '0');
        network_effective_netmask_raw <= (OTHERS => '0');
        network_effective_gateway_raw <= (OTHERS => '0');
        network_effective_dns_raw <= (OTHERS => '0');
        network_dhcp_status_raw <= (OTHERS => '0');
        network_debug_raw <= (OTHERS => '0');
        network_tcp_status_raw <= (OTHERS => '0');
        network_tcp_status_socket_raw <= (OTHERS => '0');
        network_tcp_tx_ready_raw <= '0';
        network_tcp_rx_toggle_raw <= '0';
        network_tcp_rx_socket_raw <= (OTHERS => '0');
        network_tcp_rx_length_raw <= (OTHERS => '0');
        network_tcp_rx_data_raw <= (OTHERS => '0');
    END GENERATE;

    PROCESS (CLK_IN)
    BEGIN
        IF rising_edge(CLK_IN) THEN
            network_link_meta <= network_link_raw;
            network_link <= network_link_meta;
            network_effective_ipv4_meta <= network_effective_ipv4_raw;
            network_effective_ipv4 <= network_effective_ipv4_meta;
            network_effective_netmask_meta <= network_effective_netmask_raw;
            network_effective_netmask <= network_effective_netmask_meta;
            network_effective_gateway_meta <= network_effective_gateway_raw;
            network_effective_gateway <= network_effective_gateway_meta;
            network_effective_dns_meta <= network_effective_dns_raw;
            network_effective_dns <= network_effective_dns_meta;
            network_dhcp_status_meta <= network_dhcp_status_raw;
            network_dhcp_status <= network_dhcp_status_meta;
            network_debug_meta <= network_debug_raw;
            network_debug <= network_debug_meta;
            network_tcp_status_meta <= network_tcp_status_raw;
            network_tcp_status <= network_tcp_status_meta;
            network_tcp_status_socket_meta <= network_tcp_status_socket_raw;
            network_tcp_status_socket <= network_tcp_status_socket_meta;
            network_tcp_tx_ready_meta <= network_tcp_tx_ready_raw;
            network_tcp_tx_ready <= network_tcp_tx_ready_meta;
            network_tcp_rx_toggle_meta <= network_tcp_rx_toggle_raw;
            network_tcp_rx_toggle <= network_tcp_rx_toggle_meta;
            network_tcp_rx_socket_meta <= network_tcp_rx_socket_raw;
            network_tcp_rx_socket <= network_tcp_rx_socket_meta;
            network_tcp_rx_length_meta <= network_tcp_rx_length_raw;
            network_tcp_rx_length <= network_tcp_rx_length_meta;
            network_tcp_rx_data_meta <= network_tcp_rx_data_raw;
            network_tcp_rx_data <= network_tcp_rx_data_meta;
        END IF;
    END PROCESS;

    u_mega65_keyboard : ENTITY work.mega65_keyboard_ps2
        PORT MAP (
            clk => CLK_IN,
            reset => mega_kbd_reset,
            kb_io0 => kb_io0,
            kb_io1 => kb_io1,
            kb_io2 => kb_io2,
            drive_led => nascom_drive_led,
            ps2_clk => mega_ps2_clk,
            ps2_data => mega_ps2_data,
            nmi_chord => mega_nmi_chord
        );

    -- R4 and newer boards feed the 3.5 mm jack through the AK4432VT DAC.
    u_ak4432_audio : ENTITY work.ak4432_audio
        PORT MAP (
            clk100 => CLK_IN,
            reset => reset_button,
            pcm_l => nascom_audio_pcm,
            pcm_r => nascom_audio_pcm,
            audio_mclk_o => audio_mclk_o,
            audio_bick_o => audio_bick_o,
            audio_sdti_o => audio_sdti_o,
            audio_lrclk_o => audio_lrclk_o,
            audio_pdn_n_o => audio_pdn_n_o,
            audio_pdm_l_o => r3_audio_pdm_l,
            audio_pdm_r_o => r3_audio_pdm_r
        );

    -- AK4432 interface selection on R6.  R3 uses these two common-wrapper
    -- connections to retain its separate one-bit analogue jack outputs.
    audio_i2cfil_o <= r3_audio_pdm_l WHEN G_BOARD = "MEGA65_R3" ELSE '0';
    audio_scl_io <= r3_audio_pdm_r WHEN G_BOARD = "MEGA65_R3" ELSE 'Z';
    audio_sda_io <= 'Z';

    joystick_core_a_n <= fa_fire_n_i & fa_right_n_i & fa_left_n_i &
                         fa_down_n_i & fa_up_n_i;
    joystick_core_b_n <= fb_fire_n_i & fb_right_n_i & fb_left_n_i &
                         fb_down_n_i & fb_up_n_i;

    u_nascom2 : Nascom2_Core
        PORT MAP (
            clk100 => CLK_IN,
            led => nascom_drive_led,
            uart_txd => UART_TXD,
            uart_rxd => RsRx,
            pmod1_en => pmod1_en,
            pmod1_flag => pmod1_flag,
            p1lo_cts => p1lo_cts,
            p1lo_rts => p1lo_rts,
            p1lo_txd => p1lo_txd,
            p1lo_rxd => p1lo_rxd,
            p1hi_cts => p1hi_cts,
            p1hi_rts => p1hi_rts,
            p1hi_txd => p1hi_txd,
            p1hi_rxd => p1hi_rxd,
            pmod2_en => pmod2_en,
            pmod2_flag => pmod2_flag,
            p2lo_cts => p2lo_cts,
            p2lo_rts => p2lo_rts,
            p2lo_txd => p2lo_txd,
            p2lo_rxd => p2lo_rxd,
            p2hi_cts => p2hi_cts,
            p2hi_rts => p2hi_rts,
            p2hi_txd => p2hi_txd,
            p2hi_rxd => p2hi_rxd,
            joystick_a_n_i => joystick_core_a_n,
            joystick_b_n_i => joystick_core_b_n,
            hdmi_tx_clk_p => TMDS_clk_p,
            hdmi_tx_clk_n => TMDS_clk_n,
            hdmi_tx_p => TMDS_data_p,
            hdmi_tx_n => TMDS_data_n,
            audio_pdm_l => nascom_audio_pdm_l,
            audio_pdm_r => nascom_audio_pdm_r,
            audio_pcm_o => nascom_audio_pcm,
            vga_clk_out => vdac_clk,
            vga_blank_n_out => vdac_blank_n,
            vga_sync_n_out => vdac_sync_n,
            vga_psave_n_out => vdac_psave_n,
            vga_red_out => vgared,
            vga_green_out => vgagreen,
            vga_blue_out => vgablue,
            vga_hsync_out => hsync,
            vga_vsync_out => vsync,
            ps2_clk => mega_ps2_clk,
            ps2_data => mega_ps2_data,
            manual_nmi_key_i => mega_nmi_chord,
            reset_btn => nexys_reset_btn_n,
            rtc_scl_i => rtc_scl_i,
            rtc_scl_oe_n => rtc_core_scl_oe_n_unused,
            rtc_sda_i => rtc_sda_i,
            rtc_sda_oe_n => rtc_core_sda_oe_n_unused,
            rtc_seconds_i => rtc_seconds,
            rtc_minutes_i => rtc_minutes,
            rtc_hours_i => rtc_hours,
            rtc_weekday_i => rtc_weekday,
            rtc_day_i => rtc_day,
            rtc_month_i => rtc_month,
            rtc_year_i => rtc_year,
            rtc_valid_i => rtc_valid,
            rtc_busy_i => rtc_busy,
            rtc_error_i => rtc_error,
            rtc_toggle_i => rtc_toggle,
            rtc_error_code_i => rtc_error_code,
            rtc_debug_busy_count_i => rtc_debug_busy_count,
            rtc_debug_status_i => rtc_debug_status,
            rtc_debug_last_byte_i => rtc_debug_last_byte,
            rtc_debug_addr_i => rtc_debug_addr,
            sd_cclk => mega_sd_cclk,
            sd_cd => sd2CD,
            sd_cmd => mega_sd_cmd,
            sd_d => mega_sd_d,
            sd_reset => mega_sd_reset_unused,
            network_enable_o => network_enable,
            network_cpu_reset_o => network_cpu_reset,
            network_dhcp_o => network_dhcp,
            network_ipv4_o => network_ipv4,
            network_netmask_o => network_netmask,
            network_gateway_o => network_gateway,
            network_dns_o => network_dns,
            network_dns_query_toggle_o => network_dns_query_toggle,
            network_dns_query_length_o => network_dns_query_length,
            network_dns_query_data_o => network_dns_query_data,
            network_ping_start_toggle_o => network_ping_start_toggle,
            network_ping_target_ip_o => network_ping_target_ip,
            network_ping_result_i => network_ping_result,
            network_available_i => network_available,
            network_link_i => network_link,
            network_effective_ipv4_i => network_effective_ipv4,
            network_effective_netmask_i => network_effective_netmask,
            network_effective_gateway_i => network_effective_gateway,
            network_effective_dns_i => network_effective_dns,
            network_dhcp_status_i => network_dhcp_status,
            network_debug_i => network_debug,
            network_tcp_status_i => network_tcp_status,
            network_tcp_status_socket_i => network_tcp_status_socket,
            network_tcp_connect_toggle_o => network_tcp_connect_toggle,
            network_tcp_connect_socket_o => network_tcp_connect_socket,
            network_tcp_connect_ip_o => network_tcp_connect_ip,
            network_tcp_connect_port_o => network_tcp_connect_port,
            network_tcp_close_toggle_o => network_tcp_close_toggle,
            network_tcp_close_socket_o => network_tcp_close_socket,
            network_tcp_send_toggle_o => network_tcp_send_toggle,
            network_tcp_send_socket_o => network_tcp_send_socket,
            network_tcp_send_length_o => network_tcp_send_length,
            network_tcp_send_data_o => network_tcp_send_data,
            network_tcp_tx_ready_i => network_tcp_tx_ready,
            network_tcp_rx_toggle_i => network_tcp_rx_toggle,
            network_tcp_rx_socket_i => network_tcp_rx_socket,
            network_tcp_rx_length_i => network_tcp_rx_length,
            network_tcp_rx_data_i => network_tcp_rx_data,
            network_tcp_query_socket_o => network_tcp_query_socket,
            network_tcp_rx_consume_toggle_o => network_tcp_rx_consume_toggle,
            network_tcp_rx_consume_socket_o => network_tcp_rx_consume_socket
        );
END ARCHITECTURE rtl;
