--------------------------------------------------------------------------------
-- Small fixed-function IPv4 endpoint for the Nascom2 MEGA65 core.
-- First development stage: Ethernet II, ARP and ICMP echo replies.
--------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY nascom2_ipv4_core IS
    GENERIC (
        G_MAC : STD_LOGIC_VECTOR(47 DOWNTO 0) := x"024E41533236";
        G_DNS_START_DELAY : NATURAL := 5000000;
        G_DNS_TIMEOUT : NATURAL := 25000000;
        G_TCP_RETRY_INTERVAL : NATURAL := 5000000;
        G_TCP_MAX_RETRIES : NATURAL := 3
    );
    PORT (
        clk50 : IN STD_LOGIC;
        clk200 : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        tcp_abort : IN STD_LOGIC;
        enable : IN STD_LOGIC;
        dhcp_enable : IN STD_LOGIC;
        static_ipv4_address : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        static_ipv4_netmask : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        static_ipv4_gateway : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        static_dns_server : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        effective_ipv4_address : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        effective_ipv4_netmask : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        effective_ipv4_gateway : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        effective_dns_server : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        dhcp_status : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        dns_query_toggle : IN STD_LOGIC;
        dns_query_length : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
        dns_query_data : IN STD_LOGIC_VECTOR(511 DOWNTO 0);
        ping_start_toggle : IN STD_LOGIC;
        ping_target_ip : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        ping_result : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        tcp_connect_toggle : IN STD_LOGIC;
        tcp_connect_socket : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        tcp_connect_ip : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        tcp_connect_port : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        tcp_close_toggle : IN STD_LOGIC;
        tcp_close_socket : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        tcp_send_toggle : IN STD_LOGIC;
        tcp_send_socket : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        tcp_send_length : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        tcp_send_data : IN STD_LOGIC_VECTOR(1023 DOWNTO 0);
        tcp_tx_ready : OUT STD_LOGIC;
        tcp_rx_toggle : OUT STD_LOGIC;
        tcp_rx_socket : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        tcp_rx_length : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        tcp_rx_data : OUT STD_LOGIC_VECTOR(1023 DOWNTO 0);
        tcp_query_socket : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        tcp_rx_consume_toggle : IN STD_LOGIC;
        tcp_rx_consume_socket : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        tcp_status : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        tcp_status_socket : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        rmii_rxd : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        rmii_crs_dv : IN STD_LOGIC;
        rmii_rx_er : IN STD_LOGIC;
        rmii_txd : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        rmii_tx_en : OUT STD_LOGIC;
        debug_counters : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE rtl OF nascom2_ipv4_core IS
    -- Stage one needs ARP and ordinary diagnostic pings, not full-size TCP
    -- segments yet.  TCP/FTP will replace these compact buffers with BRAM
    -- FIFOs; 576 bytes already covers the traditional minimum IPv4 MTU.
    CONSTANT MAX_FRAME : INTEGER := 594; -- Ethernet header + 576-byte IPv4 packet + FCS
    TYPE frame_buffer_t IS ARRAY (0 TO MAX_FRAME - 1) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    TYPE state_t IS (
        ST_IDLE, ST_BUILD_ARP, ST_BUILD_ARP_QUERY, ST_BUILD_PING_ARP, ST_BUILD_TCP_ARP,
        ST_BUILD_DHCP, ST_BUILD_DNS, ST_BUILD_PING, ST_BUILD_TCP,
        ST_DHCP_SCAN_OPTIONS,
        ST_DNS_SCAN_NAME, ST_DNS_SCAN_RR,
        ST_COPY_ICMP, ST_PATCH_ICMP,
        ST_IP_SUM, ST_IP_FOLD1, ST_IP_FOLD2, ST_IP_STORE,
        ST_ICMP_SUM, ST_ICMP_FOLD1, ST_ICMP_FOLD2, ST_ICMP_STORE,
        ST_TCP_SUM, ST_TCP_FOLD1, ST_TCP_FOLD2, ST_TCP_STORE,
        ST_PAD, ST_TX_PREAMBLE, ST_TX_FRAME, ST_TX_CRC, ST_TX_GAP
    );
    TYPE dns_state_t IS (
        DNS_BOOT_WAIT, DNS_ARP_START, DNS_ARP_WAIT,
        DNS_QUERY_START, DNS_RESPONSE_WAIT, DNS_DONE, DNS_ERROR
    );
    TYPE dhcp_state_t IS (
        DHCP_STATIC, DHCP_DISCOVER_START, DHCP_OFFER_WAIT,
        DHCP_REQUEST_START, DHCP_ACK_WAIT, DHCP_BOUND, DHCP_RENEW_START,
        DHCP_RENEW_WAIT, DHCP_ERROR
    );
    TYPE ping_state_t IS (
        PING_IDLE, PING_ARP_START, PING_ARP_WAIT, PING_SEND,
        PING_REPLY_WAIT, PING_DONE, PING_ERROR
    );
    TYPE tcp_byte_array_t IS ARRAY (0 TO 3) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    TYPE tcp_word_array_t IS ARRAY (0 TO 3) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
    TYPE tcp_dword_array_t IS ARRAY (0 TO 3) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
    TYPE tcp_mac_array_t IS ARRAY (0 TO 3) OF STD_LOGIC_VECTOR(47 DOWNTO 0);
    TYPE tcp_data_array_t IS ARRAY (0 TO 3) OF STD_LOGIC_VECTOR(1023 DOWNTO 0);
    TYPE tcp_length_array_t IS ARRAY (0 TO 3) OF INTEGER RANGE 0 TO 128;
    TYPE tcp_timer_array_t IS ARRAY (0 TO 3) OF NATURAL RANGE 0 TO G_DNS_TIMEOUT;
    TYPE tcp_retry_count_array_t IS ARRAY (0 TO 3) OF NATURAL RANGE 0 TO G_TCP_MAX_RETRIES;

    FUNCTION crc32_byte(
        crc_i : STD_LOGIC_VECTOR(31 DOWNTO 0);
        data_i : STD_LOGIC_VECTOR(7 DOWNTO 0)
    ) RETURN STD_LOGIC_VECTOR IS
        VARIABLE crc_v : UNSIGNED(31 DOWNTO 0) := UNSIGNED(crc_i);
        VARIABLE data_v : UNSIGNED(7 DOWNTO 0) := UNSIGNED(data_i);
    BEGIN
        FOR bit_i IN 0 TO 7 LOOP
            IF (crc_v(0) XOR data_v(bit_i)) = '1' THEN
                crc_v := shift_right(crc_v, 1) XOR x"EDB88320";
            ELSE
                crc_v := shift_right(crc_v, 1);
            END IF;
        END LOOP;
        RETURN STD_LOGIC_VECTOR(crc_v);
    END FUNCTION;

    FUNCTION mac_byte(index_i : INTEGER) RETURN STD_LOGIC_VECTOR IS
    BEGIN
        RETURN G_MAC(47 - index_i * 8 DOWNTO 40 - index_i * 8);
    END FUNCTION;

    FUNCTION ip_byte(ip_i : STD_LOGIC_VECTOR(31 DOWNTO 0); index_i : INTEGER)
        RETURN STD_LOGIC_VECTOR IS
    BEGIN
        RETURN ip_i(31 - index_i * 8 DOWNTO 24 - index_i * 8);
    END FUNCTION;

    FUNCTION find_connect_socket(
        pending_i : STD_LOGIC_VECTOR(3 DOWNTO 0);
        status_i : tcp_byte_array_t
    ) RETURN INTEGER IS
    BEGIN
        FOR i IN 0 TO 3 LOOP
            IF pending_i(i) = '1' AND (status_i(i) = x"00" OR status_i(i)(7) = '1') THEN
                RETURN i;
            END IF;
        END LOOP;
        RETURN -1;
    END FUNCTION;

    FUNCTION find_close_socket(
        pending_i : STD_LOGIC_VECTOR(3 DOWNTO 0);
        status_i : tcp_byte_array_t;
        outstanding_i : STD_LOGIC_VECTOR(3 DOWNTO 0)
    ) RETURN INTEGER IS
    BEGIN
        FOR i IN 0 TO 3 LOOP
            IF pending_i(i) = '1' AND status_i(i) = x"03" AND outstanding_i(i) = '0' THEN
                RETURN i;
            END IF;
        END LOOP;
        RETURN -1;
    END FUNCTION;

    FUNCTION find_send_socket(
        pending_i : STD_LOGIC_VECTOR(3 DOWNTO 0);
        status_i : tcp_byte_array_t;
        outstanding_i : STD_LOGIC_VECTOR(3 DOWNTO 0)
    ) RETURN INTEGER IS
    BEGIN
        FOR i IN 0 TO 3 LOOP
            IF pending_i(i) = '1' AND status_i(i) = x"03" AND outstanding_i(i) = '0' THEN
                RETURN i;
            END IF;
        END LOOP;
        RETURN -1;
    END FUNCTION;

    FUNCTION find_window_socket(
        pending_i : STD_LOGIC_VECTOR(3 DOWNTO 0);
        status_i : tcp_byte_array_t
    ) RETURN INTEGER IS
    BEGIN
        FOR i IN 0 TO 3 LOOP
            IF pending_i(i) = '1' AND status_i(i) = x"03" THEN
                RETURN i;
            END IF;
        END LOOP;
        RETURN -1;
    END FUNCTION;

    FUNCTION find_retry_socket(pending_i : STD_LOGIC_VECTOR(3 DOWNTO 0)) RETURN INTEGER IS
    BEGIN
        FOR i IN 0 TO 3 LOOP
            IF pending_i(i) = '1' THEN
                RETURN i;
            END IF;
        END LOOP;
        RETURN -1;
    END FUNCTION;

    SIGNAL rx_buffer : frame_buffer_t := (OTHERS => (OTHERS => '0'));
    SIGNAL tx_buffer : frame_buffer_t := (OTHERS => (OTHERS => '0'));
    SIGNAL rx_shift : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL rx_phase : INTEGER RANGE 0 TO 3 := 0;
    SIGNAL rx_index : INTEGER RANGE 0 TO MAX_FRAME := 0;
    SIGNAL rx_receiving : STD_LOGIC := '0';
    SIGNAL rx_carrier_active : STD_LOGIC := '0';
    SIGNAL rx_dv_low_count : INTEGER RANGE 0 TO 2 := 0;
    SIGNAL rx_error_seen : STD_LOGIC := '0';
    SIGNAL rx_accepting : STD_LOGIC := '0';
    SIGNAL rx_frame_toggle : STD_LOGIC := '0';
    SIGNAL rx_length : INTEGER RANGE 0 TO MAX_FRAME := 0;
    SIGNAL rx_frame_seen : STD_LOGIC := '0';

    SIGNAL state : state_t := ST_IDLE;
    SIGNAL build_index : INTEGER RANGE 0 TO MAX_FRAME := 0;
    SIGNAL tx_length : INTEGER RANGE 0 TO MAX_FRAME := 0;
    SIGNAL ip_total_length : INTEGER RANGE 0 TO 1500 := 0;
    SIGNAL checksum_index : INTEGER RANGE 0 TO MAX_FRAME := 0;
    SIGNAL checksum_end : INTEGER RANGE 0 TO MAX_FRAME := 0;
    SIGNAL checksum_sum : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');

    SIGNAL tx_byte_index : INTEGER RANGE 0 TO MAX_FRAME := 0;
    SIGNAL tx_phase : INTEGER RANGE 0 TO 3 := 0;
    SIGNAL tx_crc : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '1');
    SIGNAL tx_crc_final : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tx_preamble_index : INTEGER RANGE 0 TO 7 := 0;
    SIGNAL tx_crc_byte_index : INTEGER RANGE 0 TO 3 := 0;
    SIGNAL tx_gap_count : INTEGER RANGE 0 TO 47 := 0;
    SIGNAL txd_reg : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL tx_en_reg : STD_LOGIC := '0';
    SIGNAL rmii_rxd_iob : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL rmii_crs_dv_iob : STD_LOGIC := '0';
    SIGNAL rmii_rx_er_iob : STD_LOGIC := '0';
    SIGNAL rmii_rxd_sync : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL rmii_crs_dv_sync : STD_LOGIC := '0';
    SIGNAL rmii_rx_er_sync : STD_LOGIC := '0';
    SIGNAL rmii_rx_phase : INTEGER RANGE 0 TO 3 := 0;
    SIGNAL rmii_txd_fall : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL rmii_tx_en_fall : STD_LOGIC := '0';
    SIGNAL debug_arp_type_frames : UNSIGNED(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL debug_gateway_arp_frames : UNSIGNED(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL debug_tcp_syn_sent : UNSIGNED(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL debug_tcp_syn_tx_complete : UNSIGNED(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL debug_tcp_any_frames : UNSIGNED(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL debug_tcp_local_frames : UNSIGNED(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dns_state : dns_state_t := DNS_DONE;
    SIGNAL ipv4_address : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ipv4_netmask : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ipv4_gateway : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dns_server : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dhcp_state : dhcp_state_t := DHCP_STATIC;
    SIGNAL dhcp_enable_seen : STD_LOGIC := '0';
    SIGNAL dhcp_timer : NATURAL RANGE 0 TO G_DNS_TIMEOUT := 0;
    SIGNAL dhcp_retry_count : INTEGER RANGE 0 TO 7 := 0;
    SIGNAL dhcp_xid : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"4E324448";
    SIGNAL dhcp_tx_message_type : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"01";
    SIGNAL dhcp_renewing : STD_LOGIC := '0';
    SIGNAL dhcp_offered_ip : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dhcp_server_id : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dhcp_candidate_netmask : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dhcp_candidate_gateway : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dhcp_candidate_dns : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dhcp_candidate_lease : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dhcp_rx_message_type : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL dhcp_parse_offset : INTEGER RANGE 0 TO MAX_FRAME - 1 := 0;
    SIGNAL dhcp_parse_limit : INTEGER RANGE 0 TO MAX_FRAME := 0;
    SIGNAL dhcp_option_code : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL dhcp_option_length : INTEGER RANGE 0 TO 255 := 0;
    SIGNAL dhcp_option_index : INTEGER RANGE 0 TO 255 := 0;
    SIGNAL dhcp_seconds_divider : NATURAL RANGE 0 TO 49999999 := 0;
    SIGNAL dhcp_lease_remaining : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dhcp_renew_at : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dns_timer : NATURAL RANGE 0 TO G_DNS_TIMEOUT := 0;
    SIGNAL dns_retry_count : INTEGER RANGE 0 TO 3 := 0;
    SIGNAL dns_next_hop : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dns_next_hop_mac : STD_LOGIC_VECTOR(47 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dns_display : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dns_query_seen : STD_LOGIC := '0';
    SIGNAL dns_qname_length : INTEGER RANGE 1 TO 64 := 1;
    SIGNAL dns_qname_data : STD_LOGIC_VECTOR(511 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dns_parse_offset : INTEGER RANGE 0 TO MAX_FRAME - 1 := 0;
    SIGNAL dns_parse_limit : INTEGER RANGE 0 TO MAX_FRAME := 0;
    SIGNAL dns_answers_remaining : INTEGER RANGE 0 TO 65535 := 0;
    SIGNAL ping_state : ping_state_t := PING_IDLE;
    SIGNAL ping_start_seen : STD_LOGIC := '0';
    SIGNAL ping_target : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ping_next_hop : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ping_next_hop_mac : STD_LOGIC_VECTOR(47 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ping_timer : NATURAL RANGE 0 TO G_DNS_TIMEOUT := 0;
    SIGNAL ping_retry_count : INTEGER RANGE 0 TO 2 := 0;
    SIGNAL ping_sequence : UNSIGNED(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ping_result_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"E0";
    SIGNAL config_ipv4_seen : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL config_netmask_seen : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL config_gateway_seen : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL config_dns_seen : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tcp_connect_seen : STD_LOGIC := '0';
    SIGNAL tcp_connect_pending : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tcp_connect_ip_pending : tcp_dword_array_t := (OTHERS => (OTHERS => '0'));
    SIGNAL tcp_connect_port_pending : tcp_word_array_t := (OTHERS => (OTHERS => '0'));
    SIGNAL tcp_close_seen : STD_LOGIC := '0';
    SIGNAL tcp_close_pending : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tcp_status_reg : tcp_byte_array_t := (OTHERS => x"00");
    SIGNAL tcp_remote_ip : tcp_dword_array_t := (OTHERS => (OTHERS => '0'));
    SIGNAL tcp_remote_mac : tcp_mac_array_t := (OTHERS => (OTHERS => '0'));
    SIGNAL tcp_remote_port : tcp_word_array_t := (OTHERS => (OTHERS => '0'));
    SIGNAL tcp_local_port : tcp_word_array_t := (OTHERS => x"C100");
    SIGNAL tcp_local_seq : tcp_dword_array_t := (OTHERS => x"4E320001");
    SIGNAL tcp_remote_ack : tcp_dword_array_t := (OTHERS => (OTHERS => '0'));
    SIGNAL tcp_flags : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"02";
    SIGNAL tcp_timer : tcp_timer_array_t := (OTHERS => 0);
    SIGNAL tcp_retry_count : tcp_retry_count_array_t := (OTHERS => 0);
    SIGNAL tcp_retry_pending : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tcp_connection_nonce : UNSIGNED(13 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tcp_arp_active : STD_LOGIC := '0';
    SIGNAL tcp_arp_target : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tcp_arp_socket : INTEGER RANGE 0 TO 3 := 0;
    SIGNAL tcp_arp_timer : NATURAL RANGE 0 TO G_DNS_TIMEOUT := 0;
    SIGNAL tcp_arp_retry_count : INTEGER RANGE 0 TO 2 := 0;
    SIGNAL tcp_fin_waiting : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tcp_close_after_tx : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tcp_send_seen : STD_LOGIC := '0';
    SIGNAL tcp_send_pending : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tcp_send_data_reg : tcp_data_array_t := (OTHERS => (OTHERS => '0'));
    SIGNAL tcp_send_length_reg : tcp_length_array_t := (OTHERS => 0);
    SIGNAL tcp_payload_length : INTEGER RANGE 0 TO 128 := 0;
    SIGNAL tcp_tx_outstanding : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tcp_tx_outstanding_length : tcp_length_array_t := (OTHERS => 0);
    SIGNAL tcp_rx_toggle_reg : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tcp_rx_length_reg : tcp_byte_array_t := (OTHERS => (OTHERS => '0'));
    SIGNAL tcp_rx_data_reg : tcp_data_array_t := (OTHERS => (OTHERS => '0'));
    SIGNAL tcp_rx_occupied : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tcp_window_update_pending : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tcp_rx_consume_seen : STD_LOGIC := '0';
    SIGNAL tcp_work_socket : INTEGER RANGE 0 TO 3 := 0;
    SIGNAL checksum_mode : INTEGER RANGE 0 TO 2 := 0; -- 0 IP only, 1 ICMP, 2 TCP

    ATTRIBUTE IOB : STRING;
    ATTRIBUTE IOB OF rmii_rxd_iob : SIGNAL IS "TRUE";
    ATTRIBUTE IOB OF rmii_crs_dv_iob : SIGNAL IS "TRUE";
    ATTRIBUTE IOB OF rmii_rx_er_iob : SIGNAL IS "TRUE";
    ATTRIBUTE IOB OF rmii_txd_fall : SIGNAL IS "TRUE";
    ATTRIBUTE IOB OF rmii_tx_en_fall : SIGNAL IS "TRUE";
BEGIN
    ASSERT G_TCP_RETRY_INTERVAL <= G_DNS_TIMEOUT
        REPORT "G_TCP_RETRY_INTERVAL must not exceed G_DNS_TIMEOUT"
        SEVERITY FAILURE;
    tcp_status <= tcp_status_reg(to_integer(UNSIGNED(tcp_query_socket)));
    ping_result <= ping_result_reg;
    effective_ipv4_address <= ipv4_address;
    effective_ipv4_netmask <= ipv4_netmask;
    effective_ipv4_gateway <= ipv4_gateway;
    effective_dns_server <= dns_server;
    dhcp_status <= x"00" WHEN dhcp_enable = '0' ELSE
        x"03" WHEN dhcp_state = DHCP_BOUND ELSE
        x"04" WHEN dhcp_state = DHCP_RENEW_START OR dhcp_state = DHCP_RENEW_WAIT ELSE
        x"E1" WHEN dhcp_state = DHCP_ERROR ELSE x"01";
    tcp_status_socket <= tcp_query_socket;
    tcp_tx_ready <= '1' WHEN
        tcp_status_reg(to_integer(UNSIGNED(tcp_query_socket))) = x"03" AND
        tcp_send_pending(to_integer(UNSIGNED(tcp_query_socket))) = '0' AND
        tcp_tx_outstanding(to_integer(UNSIGNED(tcp_query_socket))) = '0' ELSE '0';
    tcp_rx_toggle <= tcp_rx_toggle_reg(to_integer(UNSIGNED(tcp_query_socket)));
    tcp_rx_socket <= tcp_query_socket;
    tcp_rx_length <= tcp_rx_length_reg(to_integer(UNSIGNED(tcp_query_socket)));
    tcp_rx_data <= tcp_rx_data_reg(to_integer(UNSIGNED(tcp_query_socket)));
    rmii_txd <= rmii_txd_fall;
    rmii_tx_en <= rmii_tx_en_fall;
    -- During DNS bring-up this word is displayed directly on the network
    -- page: small values are progress states, FFFFFFxx are errors, and any
    -- other value is the resolved IPv4 A record.
    -- On TCP timeout expose a compact wire-level diagnostic through the
    -- existing four-byte configuration-page/ABI diagnostic channel:
    -- SYN requested, SYN physically transmitted, any received TCP frame,
    -- and TCP addressed to this MAC/IP.
    debug_counters <= STD_LOGIC_VECTOR(debug_tcp_syn_sent) &
        STD_LOGIC_VECTOR(debug_tcp_syn_tx_complete) &
        STD_LOGIC_VECTOR(debug_tcp_any_frames) &
        STD_LOGIC_VECTOR(debug_tcp_local_frames)
        WHEN tcp_status_reg(to_integer(UNSIGNED(tcp_query_socket))) = x"E2" ELSE dns_display;

    -- REF_CLK reaches the PHY only after the FPGA output buffer and board
    -- delay.  The PHY then returns RXD/CRS_DV after its own clock-to-out delay.
    -- Sampling on the internal 50 MHz edge therefore sits close to a data
    -- transition on real MEGA65 hardware.  As in the official MEGA65 core,
    -- oversample at 200 MHz and select a phase between REF_CLK edges.  Phase 1
    -- is 5 ns after the internal rising edge and captures the preceding RMII
    -- dibit well away from the returned-data transition.
    PROCESS (clk200)
    BEGIN
        IF rising_edge(clk200) THEN
            IF reset = '1' OR enable = '0' THEN
                rmii_rxd_iob <= "00";
                rmii_crs_dv_iob <= '0';
                rmii_rx_er_iob <= '0';
                rmii_rx_phase <= 0;
            ELSE
                IF rmii_rx_phase = 3 THEN
                    rmii_rx_phase <= 0;
                ELSE
                    rmii_rx_phase <= rmii_rx_phase + 1;
                END IF;
                IF rmii_rx_phase = 1 THEN
                    rmii_rxd_iob <= rmii_rxd;
                    rmii_crs_dv_iob <= rmii_crs_dv;
                    rmii_rx_er_iob <= rmii_rx_er;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    PROCESS (clk50)
    BEGIN
        IF rising_edge(clk50) THEN
            IF reset = '1' OR enable = '0' THEN
                rmii_rxd_sync <= "00";
                rmii_crs_dv_sync <= '0';
                rmii_rx_er_sync <= '0';
            ELSE
                rmii_rxd_sync <= rmii_rxd_iob;
                rmii_crs_dv_sync <= rmii_crs_dv_iob;
                rmii_rx_er_sync <= rmii_rx_er_iob;
            END IF;
        END IF;
    END PROCESS;

    PROCESS (clk50)
    BEGIN
        IF falling_edge(clk50) THEN
            IF reset = '1' OR enable = '0' THEN
                rmii_txd_fall <= "00";
                rmii_tx_en_fall <= '0';
            ELSE
                rmii_txd_fall <= txd_reg;
                rmii_tx_en_fall <= tx_en_reg;
            END IF;
        END IF;
    END PROCESS;

    -- RMII receive byte collector. Preamble/SFD are removed; the stored length
    -- includes the four received FCS bytes, which protocol parsing excludes.
    PROCESS (clk50)
        VARIABLE byte_v : STD_LOGIC_VECTOR(7 DOWNTO 0);
    BEGIN
        IF rising_edge(clk50) THEN
            IF reset = '1' OR enable = '0' THEN
                rx_phase <= 0;
                rx_index <= 0;
                rx_receiving <= '0';
                rx_carrier_active <= '0';
                rx_dv_low_count <= 0;
                rx_error_seen <= '0';
                rx_accepting <= '0';
                rx_length <= 0;
                rx_frame_toggle <= '0';
            ELSIF rmii_crs_dv_sync = '1' THEN
                rx_dv_low_count <= 0;
                IF rx_carrier_active = '0' THEN
                    rx_phase <= 0;
                    rx_index <= 0;
                    rx_receiving <= '0';
                    rx_carrier_active <= '1';
                    rx_error_seen <= '0';
                    rx_shift <= (OTHERS => '0');
                    -- There is one complete-frame buffer.  Preserve a frame
                    -- until the protocol state machine has claimed it.  In
                    -- particular, two frames arriving before ST_IDLE runs
                    -- must not toggle the notification twice and silently
                    -- erase the first one.  TCP retransmits a dropped frame.
                    IF rx_frame_toggle = rx_frame_seen THEN
                        rx_accepting <= '1';
                    ELSE
                        rx_accepting <= '0';
                    END IF;
                END IF;
                IF rmii_rx_er_sync = '1' THEN
                    rx_error_seen <= '1';
                END IF;
                IF rx_accepting = '1' AND rx_receiving = '0' THEN
                    -- CRS_DV may become active on any dibit of the preamble,
                    -- not necessarily on an Ethernet byte boundary.  Search
                    -- for the SFD in a sliding 8-bit window and establish the
                    -- four-dibit byte phase only after D5 was really seen.
                    byte_v := rmii_rxd_sync & rx_shift(7 DOWNTO 2);
                    rx_shift <= byte_v;
                    IF byte_v = x"D5" THEN
                        rx_receiving <= '1';
                        rx_index <= 0;
                        rx_phase <= 0;
                    END IF;
                ELSIF rx_accepting = '1' THEN
                    CASE rx_phase IS
                        WHEN 0 =>
                            rx_shift(1 DOWNTO 0) <= rmii_rxd_sync;
                            rx_phase <= 1;
                        WHEN 1 =>
                            rx_shift(3 DOWNTO 2) <= rmii_rxd_sync;
                            rx_phase <= 2;
                        WHEN 2 =>
                            rx_shift(5 DOWNTO 4) <= rmii_rxd_sync;
                            rx_phase <= 3;
                        WHEN OTHERS =>
                            byte_v := rmii_rxd_sync & rx_shift(5 DOWNTO 0);
                            rx_phase <= 0;
                            IF rx_index < MAX_FRAME THEN
                            rx_buffer(rx_index) <= byte_v;
                            rx_index <= rx_index + 1;
                            END IF;
                    END CASE;
                END IF;
            ELSIF rx_carrier_active = '1' THEN
                -- CRS_DV multiplexes receive-data-valid with carrier sense on
                -- the R6 PHY.  A lone low sample does not end the frame.  As
                -- in the official MEGA65 receiver, wait for three consecutive
                -- lows and keep consuming RXD meanwhile, or the final FCS
                -- byte (and sometimes the final payload byte) is truncated.
                IF rx_dv_low_count < 2 THEN
                    rx_dv_low_count <= rx_dv_low_count + 1;
                    IF rx_receiving = '1' THEN
                        CASE rx_phase IS
                            WHEN 0 =>
                                rx_shift(1 DOWNTO 0) <= rmii_rxd_sync;
                                rx_phase <= 1;
                            WHEN 1 =>
                                rx_shift(3 DOWNTO 2) <= rmii_rxd_sync;
                                rx_phase <= 2;
                            WHEN 2 =>
                                rx_shift(5 DOWNTO 4) <= rmii_rxd_sync;
                                rx_phase <= 3;
                            WHEN OTHERS =>
                                byte_v := rmii_rxd_sync & rx_shift(5 DOWNTO 0);
                                rx_phase <= 0;
                                IF rx_index < MAX_FRAME THEN
                                    rx_buffer(rx_index) <= byte_v;
                                    rx_index <= rx_index + 1;
                                END IF;
                        END CASE;
                    END IF;
                ELSE
                    IF rx_accepting = '1' AND rx_receiving = '1' AND
                        rx_error_seen = '0' AND rx_index >= 18 THEN
                        rx_length <= rx_index;
                        rx_frame_toggle <= NOT rx_frame_toggle;
                    END IF;
                    rx_carrier_active <= '0';
                    rx_receiving <= '0';
                    rx_accepting <= '0';
                    rx_phase <= 0;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    PROCESS (clk50)
        VARIABLE byte_v : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE word_v : UNSIGNED(15 DOWNTO 0);
        VARIABLE total_v : INTEGER;
        VARIABLE frame_v : INTEGER;
        VARIABLE destination_ok_v : BOOLEAN;
        VARIABLE destination_local_v : BOOLEAN;
        VARIABLE destination_broadcast_v : BOOLEAN;
        VARIABLE ip_match_v : BOOLEAN;
        VARIABLE tcp_total_length_v : INTEGER;
        VARIABLE tcp_header_length_v : INTEGER;
        VARIABLE tcp_payload_length_v : INTEGER;
        VARIABLE tcp_sequence_v : UNSIGNED(31 DOWNTO 0);
        VARIABLE tcp_ack_v : UNSIGNED(31 DOWNTO 0);
        VARIABLE tcp_socket_index_v : INTEGER RANGE 0 TO 3;
        VARIABLE tcp_match_socket_v : INTEGER RANGE -1 TO 3;
        VARIABLE tcp_next_hop_v : STD_LOGIC_VECTOR(31 DOWNTO 0);
        VARIABLE dns_answer_offset_v : INTEGER RANGE 0 TO MAX_FRAME - 1;
    BEGIN
        IF rising_edge(clk50) THEN
            IF reset = '1' OR enable = '0' THEN
                state <= ST_IDLE;
                rx_frame_seen <= rx_frame_toggle;
                build_index <= 0;
                tx_length <= 0;
                tx_byte_index <= 0;
                tx_phase <= 0;
                tx_crc <= (OTHERS => '1');
                tx_crc_final <= (OTHERS => '0');
                tx_preamble_index <= 0;
                tx_crc_byte_index <= 0;
                tx_gap_count <= 0;
                txd_reg <= "00";
                tx_en_reg <= '0';
                debug_arp_type_frames <= (OTHERS => '0');
                debug_gateway_arp_frames <= (OTHERS => '0');
                debug_tcp_syn_sent <= (OTHERS => '0');
                debug_tcp_syn_tx_complete <= (OTHERS => '0');
                debug_tcp_any_frames <= (OTHERS => '0');
                debug_tcp_local_frames <= (OTHERS => '0');
                dns_state <= DNS_DONE;
                dhcp_enable_seen <= dhcp_enable;
                IF dhcp_enable = '1' THEN
                    ipv4_address <= (OTHERS => '0');
                    ipv4_netmask <= (OTHERS => '0');
                    ipv4_gateway <= (OTHERS => '0');
                    dns_server <= (OTHERS => '0');
                    dhcp_state <= DHCP_DISCOVER_START;
                ELSE
                    ipv4_address <= static_ipv4_address;
                    ipv4_netmask <= static_ipv4_netmask;
                    ipv4_gateway <= static_ipv4_gateway;
                    dns_server <= static_dns_server;
                    dhcp_state <= DHCP_STATIC;
                END IF;
                dhcp_timer <= 0;
                dhcp_retry_count <= 0;
                dhcp_xid <= x"4E324448";
                dhcp_tx_message_type <= x"01";
                dhcp_renewing <= '0';
                dhcp_offered_ip <= (OTHERS => '0');
                dhcp_server_id <= (OTHERS => '0');
                dhcp_candidate_netmask <= (OTHERS => '0');
                dhcp_candidate_gateway <= (OTHERS => '0');
                dhcp_candidate_dns <= (OTHERS => '0');
                dhcp_candidate_lease <= (OTHERS => '0');
                dhcp_rx_message_type <= x"00";
                dhcp_parse_offset <= 0;
                dhcp_parse_limit <= 0;
                dhcp_option_code <= x"00";
                dhcp_option_length <= 0;
                dhcp_option_index <= 0;
                dhcp_seconds_divider <= 0;
                dhcp_lease_remaining <= (OTHERS => '0');
                dhcp_renew_at <= (OTHERS => '0');
                dns_timer <= 0;
                dns_retry_count <= 0;
                dns_next_hop <= (OTHERS => '0');
                dns_next_hop_mac <= (OTHERS => '0');
                dns_display <= x"00000000";
                dns_query_seen <= dns_query_toggle;
                dns_qname_length <= 1;
                dns_qname_data <= (OTHERS => '0');
                dns_parse_offset <= 0;
                dns_parse_limit <= 0;
                dns_answers_remaining <= 0;
                ping_state <= PING_IDLE;
                ping_start_seen <= ping_start_toggle;
                ping_target <= (OTHERS => '0');
                ping_next_hop <= (OTHERS => '0');
                ping_next_hop_mac <= (OTHERS => '0');
                ping_timer <= 0;
                ping_retry_count <= 0;
                ping_sequence <= (OTHERS => '0');
                ping_result_reg <= x"E0";
                config_ipv4_seen <= static_ipv4_address;
                config_netmask_seen <= static_ipv4_netmask;
                config_gateway_seen <= static_ipv4_gateway;
                config_dns_seen <= static_dns_server;
                tcp_connect_seen <= tcp_connect_toggle;
                tcp_connect_pending <= (OTHERS => '0');
                tcp_connect_ip_pending <= (OTHERS => (OTHERS => '0'));
                tcp_connect_port_pending <= (OTHERS => (OTHERS => '0'));
                tcp_close_seen <= tcp_close_toggle;
                tcp_close_pending <= (OTHERS => '0');
                tcp_status_reg <= (OTHERS => x"00");
                tcp_remote_ip <= (OTHERS => (OTHERS => '0'));
                tcp_remote_mac <= (OTHERS => (OTHERS => '0'));
                tcp_remote_port <= (OTHERS => (OTHERS => '0'));
                tcp_local_port <= (OTHERS => x"C100");
                tcp_local_seq <= (OTHERS => x"4E320001");
                tcp_remote_ack <= (OTHERS => (OTHERS => '0'));
                tcp_flags <= x"02";
                tcp_timer <= (OTHERS => 0);
                tcp_retry_count <= (OTHERS => 0);
                tcp_retry_pending <= (OTHERS => '0');
                tcp_connection_nonce <= (OTHERS => '0');
                tcp_arp_active <= '0';
                tcp_arp_target <= (OTHERS => '0');
                tcp_arp_socket <= 0;
                tcp_arp_timer <= 0;
                tcp_arp_retry_count <= 0;
                tcp_fin_waiting <= (OTHERS => '0');
                tcp_close_after_tx <= (OTHERS => '0');
                tcp_send_seen <= tcp_send_toggle;
                tcp_send_pending <= (OTHERS => '0');
                tcp_send_data_reg <= (OTHERS => (OTHERS => '0'));
                tcp_send_length_reg <= (OTHERS => 0);
                tcp_payload_length <= 0;
                tcp_tx_outstanding <= (OTHERS => '0');
                tcp_tx_outstanding_length <= (OTHERS => 0);
                tcp_rx_toggle_reg <= (OTHERS => '0');
                tcp_rx_length_reg <= (OTHERS => (OTHERS => '0'));
                tcp_rx_data_reg <= (OTHERS => (OTHERS => '0'));
                tcp_rx_occupied <= (OTHERS => '0');
                tcp_window_update_pending <= (OTHERS => '0');
                tcp_rx_consume_seen <= tcp_rx_consume_toggle;
                tcp_work_socket <= 0;
                checksum_mode <= 0;
            ELSE
                -- DHCP leases are transient.  Static values remain untouched
                -- and become effective again immediately when DHCP is disabled.
                IF dhcp_enable /= dhcp_enable_seen THEN
                    dhcp_enable_seen <= dhcp_enable;
                    dhcp_timer <= 0;
                    dhcp_retry_count <= 0;
                    dhcp_xid <= STD_LOGIC_VECTOR(UNSIGNED(dhcp_xid) + 1);
                    IF dhcp_enable = '1' THEN
                        ipv4_address <= (OTHERS => '0');
                        ipv4_netmask <= (OTHERS => '0');
                        ipv4_gateway <= (OTHERS => '0');
                        dns_server <= (OTHERS => '0');
                        dhcp_state <= DHCP_DISCOVER_START;
                    ELSE
                        ipv4_address <= static_ipv4_address;
                        ipv4_netmask <= static_ipv4_netmask;
                        ipv4_gateway <= static_ipv4_gateway;
                        dns_server <= static_dns_server;
                        dhcp_state <= DHCP_STATIC;
                    END IF;
                    state <= ST_IDLE;
                END IF;
                IF dhcp_enable = '1' AND dhcp_state = DHCP_BOUND THEN
                    IF dhcp_seconds_divider = 49999999 THEN
                        dhcp_seconds_divider <= 0;
                        IF dhcp_lease_remaining > 0 THEN
                            dhcp_lease_remaining <= dhcp_lease_remaining - 1;
                            IF dhcp_lease_remaining <= dhcp_renew_at THEN
                                dhcp_state <= DHCP_RENEW_START;
                                dhcp_timer <= 0;
                                dhcp_retry_count <= 0;
                            END IF;
                        ELSE
                            ipv4_address <= (OTHERS => '0');
                            ipv4_netmask <= (OTHERS => '0');
                            ipv4_gateway <= (OTHERS => '0');
                            dns_server <= (OTHERS => '0');
                            dhcp_state <= DHCP_DISCOVER_START;
                        END IF;
                    ELSE
                        dhcp_seconds_divider <= dhcp_seconds_divider + 1;
                    END IF;
                ELSIF dhcp_enable = '1' AND
                    (dhcp_state = DHCP_RENEW_START OR dhcp_state = DHCP_RENEW_WAIT) THEN
                    IF dhcp_seconds_divider = 49999999 THEN
                        dhcp_seconds_divider <= 0;
                        IF dhcp_lease_remaining > 1 THEN
                            dhcp_lease_remaining <= dhcp_lease_remaining - 1;
                        ELSE
                            ipv4_address <= (OTHERS => '0');
                            ipv4_netmask <= (OTHERS => '0');
                            ipv4_gateway <= (OTHERS => '0');
                            dns_server <= (OTHERS => '0');
                            dhcp_xid <= STD_LOGIC_VECTOR(UNSIGNED(dhcp_xid) + 1);
                            dhcp_retry_count <= 0;
                            dhcp_state <= DHCP_DISCOVER_START;
                        END IF;
                    ELSE
                        dhcp_seconds_divider <= dhcp_seconds_divider + 1;
                    END IF;
                END IF;
                -- A Nascom/Z80 reset is independent of the Ethernet PHY and
                -- the saved IP configuration.  Abort transport activity here
                -- without restarting link negotiation, ARP or DNS.  Keeping
                -- the event markers aligned for the whole reset interval is
                -- essential because the producer resets its toggle bits too.
                IF tcp_abort = '1' THEN
                    state <= ST_IDLE;
                    rx_frame_seen <= rx_frame_toggle;
                    build_index <= 0;
                    tx_length <= 0;
                    tx_byte_index <= 0;
                    tx_phase <= 0;
                    tx_crc <= (OTHERS => '1');
                    tx_crc_final <= (OTHERS => '0');
                    tx_preamble_index <= 0;
                    tx_crc_byte_index <= 0;
                    tx_gap_count <= 0;
                    txd_reg <= "00";
                    tx_en_reg <= '0';
                    tcp_connect_seen <= tcp_connect_toggle;
                    tcp_connect_pending <= (OTHERS => '0');
                    tcp_connect_ip_pending <= (OTHERS => (OTHERS => '0'));
                    tcp_connect_port_pending <= (OTHERS => (OTHERS => '0'));
                    tcp_close_seen <= tcp_close_toggle;
                    tcp_close_pending <= (OTHERS => '0');
                    tcp_status_reg <= (OTHERS => x"00");
                    tcp_remote_ip <= (OTHERS => (OTHERS => '0'));
                    tcp_remote_mac <= (OTHERS => (OTHERS => '0'));
                    tcp_arp_active <= '0';
                    tcp_arp_timer <= 0;
                    tcp_arp_retry_count <= 0;
                    tcp_remote_port <= (OTHERS => (OTHERS => '0'));
                    tcp_local_port <= (OTHERS => x"C100");
                    tcp_local_seq <= (OTHERS => x"4E320001");
                    tcp_remote_ack <= (OTHERS => (OTHERS => '0'));
                    tcp_flags <= x"02";
                    tcp_timer <= (OTHERS => 0);
                    tcp_retry_count <= (OTHERS => 0);
                    tcp_retry_pending <= (OTHERS => '0');
                    tcp_fin_waiting <= (OTHERS => '0');
                    tcp_close_after_tx <= (OTHERS => '0');
                    tcp_send_seen <= tcp_send_toggle;
                    tcp_send_pending <= (OTHERS => '0');
                    tcp_send_data_reg <= (OTHERS => (OTHERS => '0'));
                    tcp_send_length_reg <= (OTHERS => 0);
                    tcp_payload_length <= 0;
                    tcp_tx_outstanding <= (OTHERS => '0');
                    tcp_tx_outstanding_length <= (OTHERS => 0);
                    tcp_rx_toggle_reg <= (OTHERS => '0');
                    tcp_rx_length_reg <= (OTHERS => (OTHERS => '0'));
                    tcp_rx_data_reg <= (OTHERS => (OTHERS => '0'));
                    tcp_rx_occupied <= (OTHERS => '0');
                    tcp_window_update_pending <= (OTHERS => '0');
                    tcp_rx_consume_seen <= tcp_rx_consume_toggle;
                    tcp_work_socket <= 0;
                    dns_query_seen <= dns_query_toggle;
                    ping_start_seen <= ping_start_toggle;
                    ping_state <= PING_IDLE;
                    ping_result_reg <= x"E0";
                    ping_timer <= 0;
                    ping_retry_count <= 0;
                ELSE
                IF dns_query_seen /= dns_query_toggle THEN
                    dns_query_seen <= dns_query_toggle;
                    IF UNSIGNED(dns_query_length) >= 3 AND UNSIGNED(dns_query_length) <= 64 THEN
                        dns_qname_length <= to_integer(UNSIGNED(dns_query_length));
                        dns_qname_data <= dns_query_data;
                        IF (dns_server AND ipv4_netmask) = (ipv4_address AND ipv4_netmask) THEN
                            dns_next_hop <= dns_server;
                        ELSE
                            dns_next_hop <= ipv4_gateway;
                        END IF;
                        dns_timer <= 0;
                        dns_retry_count <= 0;
                        dns_state <= DNS_ARP_START;
                        dns_display <= x"00000001";
                    ELSE
                        dns_state <= DNS_ERROR;
                        dns_display <= x"FFFFFF03";
                    END IF;
                END IF;
                IF ping_start_seen /= ping_start_toggle THEN
                    ping_start_seen <= ping_start_toggle;
                    ping_target <= ping_target_ip;
                    IF (ping_target_ip AND ipv4_netmask) = (ipv4_address AND ipv4_netmask) THEN
                        ping_next_hop <= ping_target_ip;
                    ELSE
                        ping_next_hop <= ipv4_gateway;
                    END IF;
                    ping_timer <= 0;
                    ping_retry_count <= 0;
                    ping_sequence <= ping_sequence + 1;
                    ping_result_reg <= x"01";
                    IF ping_target_ip = x"00000000" OR ipv4_address = x"00000000" THEN
                        ping_state <= PING_ERROR;
                        ping_result_reg <= x"E1";
                    ELSE
                        ping_state <= PING_ARP_START;
                    END IF;
                END IF;
                IF tcp_connect_seen /= tcp_connect_toggle THEN
                    tcp_connect_seen <= tcp_connect_toggle;
                    tcp_socket_index_v := to_integer(UNSIGNED(tcp_connect_socket));
                    -- CONNECT starts a new local socket instance.  A Z80 reset
                    -- does not reset this 50 MHz core, so discard every piece
                    -- of transport state that an interrupted client may have
                    -- left behind before queueing the fresh SYN.
                    tcp_status_reg(tcp_socket_index_v) <= x"00";
                    tcp_close_pending(tcp_socket_index_v) <= '0';
                    tcp_send_pending(tcp_socket_index_v) <= '0';
                    tcp_tx_outstanding(tcp_socket_index_v) <= '0';
                    tcp_tx_outstanding_length(tcp_socket_index_v) <= 0;
                    tcp_rx_occupied(tcp_socket_index_v) <= '0';
                    tcp_fin_waiting(tcp_socket_index_v) <= '0';
                    tcp_close_after_tx(tcp_socket_index_v) <= '0';
                    tcp_window_update_pending(tcp_socket_index_v) <= '0';
                    tcp_timer(tcp_socket_index_v) <= 0;
                    tcp_retry_count(tcp_socket_index_v) <= 0;
                    tcp_retry_pending(tcp_socket_index_v) <= '0';
                    tcp_connect_pending(tcp_socket_index_v) <= '1';
                    tcp_connect_ip_pending(tcp_socket_index_v) <= tcp_connect_ip;
                    tcp_connect_port_pending(tcp_socket_index_v) <= tcp_connect_port;
                END IF;
                IF tcp_close_seen /= tcp_close_toggle THEN
                    tcp_close_seen <= tcp_close_toggle;
                    tcp_socket_index_v := to_integer(UNSIGNED(tcp_close_socket));
                    IF tcp_arp_active = '1' AND tcp_arp_socket = tcp_socket_index_v THEN
                        tcp_arp_active <= '0';
                        tcp_arp_timer <= 0;
                    END IF;
                    IF tcp_status_reg(tcp_socket_index_v) = x"03" THEN
                        tcp_close_pending(tcp_socket_index_v) <= '1';
                    ELSE
                        -- CONNECTING, CLOSING, error and already-closed sockets
                        -- have no useful graceful handshake left.  Make CLOSE
                        -- idempotent and release them immediately.
                        tcp_status_reg(tcp_socket_index_v) <= x"00";
                        tcp_send_pending(tcp_socket_index_v) <= '0';
                        tcp_tx_outstanding(tcp_socket_index_v) <= '0';
                        tcp_tx_outstanding_length(tcp_socket_index_v) <= 0;
                        tcp_rx_occupied(tcp_socket_index_v) <= '0';
                        tcp_close_pending(tcp_socket_index_v) <= '0';
                        tcp_fin_waiting(tcp_socket_index_v) <= '0';
                        tcp_close_after_tx(tcp_socket_index_v) <= '0';
                        tcp_window_update_pending(tcp_socket_index_v) <= '0';
                        tcp_retry_count(tcp_socket_index_v) <= 0;
                        tcp_retry_pending(tcp_socket_index_v) <= '0';
                    END IF;
                END IF;
                IF tcp_send_seen /= tcp_send_toggle THEN
                    tcp_send_seen <= tcp_send_toggle;
                    tcp_socket_index_v := to_integer(UNSIGNED(tcp_send_socket));
                    IF tcp_status_reg(tcp_socket_index_v) = x"03" AND
                        tcp_send_length /= x"00" AND tcp_send_pending(tcp_socket_index_v) = '0' AND
                        tcp_tx_outstanding(tcp_socket_index_v) = '0' THEN
                        tcp_send_data_reg(tcp_socket_index_v) <= tcp_send_data;
                        tcp_send_length_reg(tcp_socket_index_v) <= to_integer(UNSIGNED(tcp_send_length));
                        tcp_send_pending(tcp_socket_index_v) <= '1';
                    END IF;
                END IF;
                IF tcp_rx_consume_seen /= tcp_rx_consume_toggle THEN
                    tcp_rx_consume_seen <= tcp_rx_consume_toggle;
                    tcp_socket_index_v := to_integer(UNSIGNED(tcp_rx_consume_socket));
                    IF tcp_rx_occupied(tcp_socket_index_v) = '1' AND
                        tcp_status_reg(tcp_socket_index_v) = x"03" THEN
                        tcp_window_update_pending(tcp_socket_index_v) <= '1';
                    END IF;
                    tcp_rx_occupied(tcp_socket_index_v) <= '0';
                END IF;
                FOR i IN 0 TO 3 LOOP
                    -- Retransmit the one segment that a socket may have in
                    -- flight.  This endpoint deliberately uses stop-and-wait,
                    -- so SYN, payload and FIN can all reuse their retained
                    -- sequence number and payload without a second queue.
                    IF tcp_status_reg(i) = x"02" OR
                        (tcp_status_reg(i) = x"03" AND tcp_tx_outstanding(i) = '1') OR
                        (tcp_status_reg(i) = x"04" AND tcp_fin_waiting(i) = '1') THEN
                        IF tcp_timer(i) >= G_TCP_RETRY_INTERVAL THEN
                            tcp_timer(i) <= 0;
                            IF tcp_retry_count(i) < G_TCP_MAX_RETRIES THEN
                                tcp_retry_count(i) <= tcp_retry_count(i) + 1;
                                tcp_retry_pending(i) <= '1';
                            ELSE
                                tcp_retry_pending(i) <= '0';
                                tcp_send_pending(i) <= '0';
                                tcp_tx_outstanding(i) <= '0';
                                tcp_fin_waiting(i) <= '0';
                                tcp_close_after_tx(i) <= '0';
                                tcp_window_update_pending(i) <= '0';
                                IF tcp_status_reg(i) = x"02" THEN
                                    tcp_status_reg(i) <= x"E2"; -- connect timeout
                                ELSIF tcp_status_reg(i) = x"03" THEN
                                    tcp_status_reg(i) <= x"E5"; -- data ACK timeout
                                ELSE
                                    tcp_status_reg(i) <= x"00"; -- forced close
                                END IF;
                            END IF;
                        ELSE
                            tcp_timer(i) <= tcp_timer(i) + 1;
                        END IF;
                    ELSIF tcp_status_reg(i) = x"04" THEN
                        -- Our FIN was acknowledged but the peer never sent
                        -- its FIN.  Do not retain that half-closed socket
                        -- forever.
                        IF tcp_timer(i) >= G_DNS_TIMEOUT THEN
                            tcp_status_reg(i) <= x"00";
                            tcp_close_after_tx(i) <= '0';
                            tcp_window_update_pending(i) <= '0';
                            tcp_timer(i) <= 0;
                        ELSE
                            tcp_timer(i) <= tcp_timer(i) + 1;
                        END IF;
                    ELSE
                        tcp_timer(i) <= 0;
                    END IF;
                    IF tcp_connect_pending(i) = '1' AND
                        (tcp_status_reg(i) = x"00" OR tcp_status_reg(i)(7) = '1') AND
                        dns_state = DNS_ERROR THEN
                        tcp_connect_pending(i) <= '0';
                        tcp_status_reg(i) <= x"E1";
                    END IF;
                END LOOP;
                IF static_ipv4_address /= config_ipv4_seen OR static_ipv4_netmask /= config_netmask_seen OR
                    static_ipv4_gateway /= config_gateway_seen OR static_dns_server /= config_dns_seen THEN
                    config_ipv4_seen <= static_ipv4_address;
                    config_netmask_seen <= static_ipv4_netmask;
                    config_gateway_seen <= static_ipv4_gateway;
                    config_dns_seen <= static_dns_server;
                    IF dhcp_enable = '0' THEN
                        ipv4_address <= static_ipv4_address;
                        ipv4_netmask <= static_ipv4_netmask;
                        ipv4_gateway <= static_ipv4_gateway;
                        dns_server <= static_dns_server;
                    END IF;
                    dns_state <= DNS_DONE;
                    dns_timer <= 0;
                    dns_retry_count <= 0;
                    dns_display <= x"00000000";
                ELSE
                    CASE state IS
                    WHEN ST_IDLE =>
                        tx_en_reg <= '0';
                        txd_reg <= "00";
                        IF rx_frame_seen /= rx_frame_toggle THEN
                            rx_frame_seen <= rx_frame_toggle;
                            destination_local_v := TRUE;
                            destination_broadcast_v := TRUE;
                            FOR i IN 0 TO 5 LOOP
                                IF rx_buffer(i) /= mac_byte(i) THEN destination_local_v := FALSE; END IF;
                                IF rx_buffer(i) /= x"FF" THEN destination_broadcast_v := FALSE; END IF;
                            END LOOP;
                            destination_ok_v := destination_local_v OR destination_broadcast_v;
                            IF destination_ok_v AND rx_buffer(12) = x"08" AND rx_buffer(13) = x"06" THEN
                                debug_arp_type_frames <= debug_arp_type_frames + 1;
                            END IF;
                            ip_match_v := TRUE;
                            FOR i IN 0 TO 3 LOOP
                                IF rx_buffer(30 + i) /= ip_byte(ipv4_address, i) THEN
                                    ip_match_v := FALSE;
                                END IF;
                            END LOOP;
                            tcp_match_socket_v := -1;
                            IF destination_local_v AND ip_match_v AND rx_length >= 58 AND
                                rx_buffer(12) = x"08" AND rx_buffer(13) = x"00" AND
                                rx_buffer(14) = x"45" AND rx_buffer(23) = x"06" THEN
                                FOR i IN 0 TO 3 LOOP
                                    IF tcp_match_socket_v = -1 AND
                                        (tcp_status_reg(i) = x"02" OR tcp_status_reg(i) = x"03" OR
                                         tcp_status_reg(i) = x"04") AND
                                        rx_buffer(26) & rx_buffer(27) & rx_buffer(28) & rx_buffer(29) = tcp_remote_ip(i) AND
                                        rx_buffer(34) & rx_buffer(35) = tcp_remote_port(i) AND
                                        rx_buffer(36) & rx_buffer(37) = tcp_local_port(i) THEN
                                        tcp_match_socket_v := i;
                                    END IF;
                                END LOOP;
                            END IF;

                            IF rx_length >= 38 AND rx_buffer(12) = x"08" AND
                                rx_buffer(13) = x"00" AND rx_buffer(14) = x"45" AND
                                rx_buffer(23) = x"06" THEN
                                debug_tcp_any_frames <= debug_tcp_any_frames + 1;
                            END IF;

                            IF destination_local_v AND ip_match_v AND rx_length >= 58 AND
                                rx_buffer(12) = x"08" AND rx_buffer(13) = x"00" AND
                                rx_buffer(14) = x"45" AND rx_buffer(23) = x"06" THEN
                                debug_tcp_local_frames <= debug_tcp_local_frames + 1;
                            END IF;

                            -- ARP cache learning deliberately does not require a particular
                            -- opcode, Ethernet destination or target address.  RFC-style ARP
                            -- implementations may learn the sender tuple from any valid ARP
                            -- packet, and this also accepts replies emitted as broadcasts.
                            IF dhcp_enable = '1' AND
                                (dhcp_state = DHCP_OFFER_WAIT OR dhcp_state = DHCP_ACK_WAIT OR
                                 dhcp_state = DHCP_RENEW_WAIT) AND destination_ok_v AND rx_length >= 286 AND
                                rx_buffer(12) = x"08" AND rx_buffer(13) = x"00" AND
                                rx_buffer(14) = x"45" AND rx_buffer(23) = x"11" AND
                                rx_buffer(34) = x"00" AND rx_buffer(35) = x"43" AND
                                rx_buffer(36) = x"00" AND rx_buffer(37) = x"44" AND
                                rx_buffer(42) = x"02" AND
                                rx_buffer(46) & rx_buffer(47) & rx_buffer(48) & rx_buffer(49) = dhcp_xid AND
                                rx_buffer(70) = mac_byte(0) AND rx_buffer(71) = mac_byte(1) AND
                                rx_buffer(72) = mac_byte(2) AND rx_buffer(73) = mac_byte(3) AND
                                rx_buffer(74) = mac_byte(4) AND rx_buffer(75) = mac_byte(5) AND
                                rx_buffer(278) = x"63" AND rx_buffer(279) = x"82" AND
                                rx_buffer(280) = x"53" AND rx_buffer(281) = x"63" THEN
                                total_v := to_integer(UNSIGNED(rx_buffer(16)) & UNSIGNED(rx_buffer(17)));
                                IF total_v >= 272 AND 14 + total_v <= rx_length - 4 AND
                                    14 + total_v <= MAX_FRAME THEN
                                    IF rx_buffer(58) & rx_buffer(59) & rx_buffer(60) & rx_buffer(61) /= x"00000000" THEN
                                        dhcp_offered_ip <= rx_buffer(58) & rx_buffer(59) & rx_buffer(60) & rx_buffer(61);
                                    END IF;
                                    dhcp_server_id <= rx_buffer(26) & rx_buffer(27) & rx_buffer(28) & rx_buffer(29);
                                    IF dhcp_state = DHCP_RENEW_WAIT THEN
                                        dhcp_candidate_netmask <= ipv4_netmask;
                                        dhcp_candidate_gateway <= ipv4_gateway;
                                        dhcp_candidate_dns <= dns_server;
                                        dhcp_candidate_lease <= dhcp_lease_remaining;
                                    ELSE
                                        dhcp_candidate_netmask <= (OTHERS => '0');
                                        dhcp_candidate_gateway <= (OTHERS => '0');
                                        dhcp_candidate_dns <= (OTHERS => '0');
                                        dhcp_candidate_lease <= to_unsigned(3600, 32);
                                    END IF;
                                    dhcp_rx_message_type <= x"00";
                                    dhcp_parse_offset <= 282;
                                    dhcp_parse_limit <= 14 + total_v;
                                    dhcp_option_length <= 0;
                                    dhcp_option_index <= 0;
                                    dhcp_timer <= 0;
                                    state <= ST_DHCP_SCAN_OPTIONS;
                                END IF;
                            ELSIF tcp_arp_active = '1' AND rx_length >= 46 AND
                                rx_buffer(12) = x"08" AND rx_buffer(13) = x"06" AND
                                rx_buffer(14) = x"00" AND rx_buffer(15) = x"01" AND
                                rx_buffer(16) = x"08" AND rx_buffer(17) = x"00" AND
                                rx_buffer(18) = x"06" AND rx_buffer(19) = x"04" AND
                                rx_buffer(28) = ip_byte(tcp_arp_target, 0) AND
                                rx_buffer(29) = ip_byte(tcp_arp_target, 1) AND
                                rx_buffer(30) = ip_byte(tcp_arp_target, 2) AND
                                rx_buffer(31) = ip_byte(tcp_arp_target, 3) THEN
                                FOR i IN 0 TO 5 LOOP
                                    tcp_remote_mac(tcp_arp_socket)(47 - i * 8 DOWNTO 40 - i * 8) <=
                                        rx_buffer(22 + i);
                                END LOOP;
                                tcp_arp_active <= '0';
                                tcp_arp_timer <= 0;
                                tcp_flags <= x"02"; -- initial SYN after next-hop ARP
                                tcp_remote_ack(tcp_arp_socket) <= (OTHERS => '0');
                                tcp_status_reg(tcp_arp_socket) <= x"02";
                                tcp_timer(tcp_arp_socket) <= 0;
                                tcp_retry_count(tcp_arp_socket) <= 0;
                                tcp_retry_pending(tcp_arp_socket) <= '0';
                                tcp_send_pending(tcp_arp_socket) <= '0';
                                tcp_tx_outstanding(tcp_arp_socket) <= '0';
                                tcp_payload_length <= 0;
                                tcp_rx_occupied(tcp_arp_socket) <= '0';
                                tcp_close_pending(tcp_arp_socket) <= '0';
                                tcp_fin_waiting(tcp_arp_socket) <= '0';
                                tcp_close_after_tx(tcp_arp_socket) <= '0';
                                tcp_window_update_pending(tcp_arp_socket) <= '0';
                                tcp_work_socket <= tcp_arp_socket;
                                build_index <= 0;
                                tx_length <= 60;
                                state <= ST_BUILD_TCP;
                            ELSIF ping_state = PING_ARP_WAIT AND rx_length >= 46 AND
                                rx_buffer(12) = x"08" AND rx_buffer(13) = x"06" AND
                                rx_buffer(14) = x"00" AND rx_buffer(15) = x"01" AND
                                rx_buffer(16) = x"08" AND rx_buffer(17) = x"00" AND
                                rx_buffer(18) = x"06" AND rx_buffer(19) = x"04" AND
                                rx_buffer(28) = ip_byte(ping_next_hop, 0) AND
                                rx_buffer(29) = ip_byte(ping_next_hop, 1) AND
                                rx_buffer(30) = ip_byte(ping_next_hop, 2) AND
                                rx_buffer(31) = ip_byte(ping_next_hop, 3) THEN
                                FOR i IN 0 TO 5 LOOP
                                    ping_next_hop_mac(47 - i * 8 DOWNTO 40 - i * 8) <= rx_buffer(22 + i);
                                END LOOP;
                                ping_state <= PING_SEND;
                                ping_timer <= 0;
                                ping_retry_count <= 0;
                            ELSIF ping_state = PING_REPLY_WAIT AND destination_local_v AND ip_match_v AND
                                rx_length >= 46 AND rx_buffer(12) = x"08" AND rx_buffer(13) = x"00" AND
                                rx_buffer(14) = x"45" AND rx_buffer(23) = x"01" AND
                                rx_buffer(26) & rx_buffer(27) & rx_buffer(28) & rx_buffer(29) = ping_target AND
                                rx_buffer(34) = x"00" AND rx_buffer(35) = x"00" AND
                                rx_buffer(38) = x"4E" AND rx_buffer(39) = x"32" AND
                                rx_buffer(40) & rx_buffer(41) = STD_LOGIC_VECTOR(ping_sequence) THEN
                                ping_state <= PING_DONE;
                                ping_result_reg <= x"00";
                                ping_timer <= 0;
                            ELSIF dns_state = DNS_ARP_WAIT AND rx_length >= 46 AND
                                rx_buffer(12) = x"08" AND rx_buffer(13) = x"06" AND
                                rx_buffer(14) = x"00" AND rx_buffer(15) = x"01" AND
                                rx_buffer(16) = x"08" AND rx_buffer(17) = x"00" AND
                                rx_buffer(18) = x"06" AND rx_buffer(19) = x"04" AND
                                rx_buffer(28) = ip_byte(dns_next_hop, 0) AND
                                rx_buffer(29) = ip_byte(dns_next_hop, 1) AND
                                rx_buffer(30) = ip_byte(dns_next_hop, 2) AND
                                rx_buffer(31) = ip_byte(dns_next_hop, 3) THEN
                                debug_gateway_arp_frames <= debug_gateway_arp_frames + 1;
                                FOR i IN 0 TO 5 LOOP
                                    dns_next_hop_mac(47 - i * 8 DOWNTO 40 - i * 8) <= rx_buffer(22 + i);
                                END LOOP;
                                dns_state <= DNS_QUERY_START;
                                dns_timer <= 0;
                                dns_retry_count <= 0;
                                dns_display <= x"00000002";
                            ELSIF dns_state = DNS_RESPONSE_WAIT AND destination_local_v AND ip_match_v AND
                                rx_length >= 77 AND rx_buffer(12) = x"08" AND rx_buffer(13) = x"00" AND
                                rx_buffer(14) = x"45" AND rx_buffer(23) = x"11" AND
                                rx_buffer(26) = ip_byte(dns_server, 0) AND
                                rx_buffer(27) = ip_byte(dns_server, 1) AND
                                rx_buffer(28) = ip_byte(dns_server, 2) AND
                                rx_buffer(29) = ip_byte(dns_server, 3) AND
                                rx_buffer(34) = x"00" AND rx_buffer(35) = x"35" AND
                                rx_buffer(36) = x"C0" AND rx_buffer(37) = x"00" AND
                                rx_buffer(42) = x"4E" AND rx_buffer(43) = x"32" AND
                                rx_buffer(44)(7) = '1' THEN
                                dns_answer_offset_v := 58 + dns_qname_length;
                                total_v := to_integer(UNSIGNED(rx_buffer(16))) * 256 +
                                    to_integer(UNSIGNED(rx_buffer(17)));
                                IF rx_length < dns_answer_offset_v + 16 OR total_v < 44 + dns_qname_length OR
                                    14 + total_v > rx_length - 4 OR 14 + total_v > MAX_FRAME OR
                                    rx_buffer(45)(3 DOWNTO 0) /= "0000" OR
                                    (rx_buffer(48) = x"00" AND rx_buffer(49) = x"00") THEN
                                    dns_state <= DNS_ERROR;
                                    dns_display <= x"FFFFFF03";
                                ELSE
                                    -- Walk every answer RR.  Public names commonly return one
                                    -- or more CNAME records before the final A record.
                                    dns_parse_offset <= dns_answer_offset_v;
                                    dns_parse_limit <= 14 + total_v;
                                    dns_answers_remaining <=
                                        to_integer(UNSIGNED(rx_buffer(48))) * 256 +
                                        to_integer(UNSIGNED(rx_buffer(49)));
                                    dns_timer <= 0;
                                    state <= ST_DNS_SCAN_NAME;
                                END IF;
                            ELSIF destination_local_v AND ip_match_v AND tcp_match_socket_v >= 0 AND
                                tcp_status_reg(tcp_match_socket_v) = x"02" AND
                                rx_length >= 58 AND rx_buffer(12) = x"08" AND rx_buffer(13) = x"00" AND
                                rx_buffer(14) = x"45" AND rx_buffer(23) = x"06" AND
                                rx_buffer(47)(4) = '1' AND rx_buffer(47)(1) = '1' THEN
                                tcp_remote_ack(tcp_match_socket_v) <= STD_LOGIC_VECTOR((UNSIGNED(rx_buffer(38)) &
                                    UNSIGNED(rx_buffer(39)) & UNSIGNED(rx_buffer(40)) &
                                    UNSIGNED(rx_buffer(41))) + 1);
                                tcp_local_seq(tcp_match_socket_v) <= STD_LOGIC_VECTOR(
                                    UNSIGNED(tcp_local_seq(tcp_match_socket_v)) + 1);
                                tcp_flags <= x"10"; -- ACK
                                tcp_status_reg(tcp_match_socket_v) <= x"03"; -- established
                                tcp_timer(tcp_match_socket_v) <= 0;
                                tcp_retry_count(tcp_match_socket_v) <= 0;
                                tcp_retry_pending(tcp_match_socket_v) <= '0';
                                tcp_work_socket <= tcp_match_socket_v;
                                build_index <= 0;
                                tx_length <= 60;
                                state <= ST_BUILD_TCP;
                            ELSIF destination_local_v AND ip_match_v AND
                                tcp_match_socket_v >= 0 AND
                                (tcp_status_reg(tcp_match_socket_v) = x"03" OR
                                 tcp_status_reg(tcp_match_socket_v) = x"04") AND
                                rx_length >= 58 AND rx_buffer(12) = x"08" AND rx_buffer(13) = x"00" AND
                                rx_buffer(14) = x"45" AND rx_buffer(23) = x"06" THEN
                                tcp_total_length_v := to_integer(UNSIGNED(rx_buffer(16)) & UNSIGNED(rx_buffer(17)));
                                tcp_header_length_v := to_integer(UNSIGNED(rx_buffer(46)(7 DOWNTO 4))) * 4;
                                tcp_payload_length_v := tcp_total_length_v - 20 - tcp_header_length_v;
                                tcp_sequence_v := UNSIGNED(rx_buffer(38)) & UNSIGNED(rx_buffer(39)) &
                                    UNSIGNED(rx_buffer(40)) & UNSIGNED(rx_buffer(41));
                                tcp_ack_v := UNSIGNED(rx_buffer(42)) & UNSIGNED(rx_buffer(43)) &
                                    UNSIGNED(rx_buffer(44)) & UNSIGNED(rx_buffer(45));

                                IF rx_buffer(47)(2) = '1' THEN -- RST
                                    IF tcp_status_reg(tcp_match_socket_v) = x"04" THEN
                                        tcp_status_reg(tcp_match_socket_v) <= x"00";
                                    ELSE
                                        tcp_status_reg(tcp_match_socket_v) <= x"E4";
                                    END IF;
                                    tcp_send_pending(tcp_match_socket_v) <= '0';
                                    tcp_tx_outstanding(tcp_match_socket_v) <= '0';
                                    tcp_payload_length <= 0;
                                    tcp_close_pending(tcp_match_socket_v) <= '0';
                                    tcp_fin_waiting(tcp_match_socket_v) <= '0';
                                    tcp_window_update_pending(tcp_match_socket_v) <= '0';
                                    tcp_retry_count(tcp_match_socket_v) <= 0;
                                    tcp_retry_pending(tcp_match_socket_v) <= '0';
                                ELSE
                                    IF rx_buffer(47)(4) = '1' AND tcp_tx_outstanding(tcp_match_socket_v) = '1' AND
                                        tcp_ack_v = UNSIGNED(tcp_local_seq(tcp_match_socket_v)) +
                                            tcp_tx_outstanding_length(tcp_match_socket_v) THEN
                                        tcp_local_seq(tcp_match_socket_v) <= STD_LOGIC_VECTOR(tcp_ack_v);
                                        tcp_tx_outstanding(tcp_match_socket_v) <= '0';
                                        tcp_timer(tcp_match_socket_v) <= 0;
                                        tcp_retry_count(tcp_match_socket_v) <= 0;
                                        tcp_retry_pending(tcp_match_socket_v) <= '0';
                                    END IF;
                                    IF tcp_status_reg(tcp_match_socket_v) = x"04" THEN
                                        IF rx_buffer(47)(4) = '1' AND tcp_fin_waiting(tcp_match_socket_v) = '1' AND
                                            tcp_ack_v = UNSIGNED(tcp_local_seq(tcp_match_socket_v)) + 1 THEN
                                            tcp_local_seq(tcp_match_socket_v) <= STD_LOGIC_VECTOR(tcp_ack_v);
                                            tcp_fin_waiting(tcp_match_socket_v) <= '0';
                                            tcp_timer(tcp_match_socket_v) <= 0;
                                            tcp_retry_count(tcp_match_socket_v) <= 0;
                                            tcp_retry_pending(tcp_match_socket_v) <= '0';
                                        END IF;
                                        IF rx_buffer(47)(0) = '1' AND
                                            tcp_sequence_v = UNSIGNED(tcp_remote_ack(tcp_match_socket_v)) THEN
                                            tcp_remote_ack(tcp_match_socket_v) <= STD_LOGIC_VECTOR(
                                                UNSIGNED(tcp_remote_ack(tcp_match_socket_v)) + tcp_payload_length_v + 1);
                                            tcp_payload_length <= 0;
                                            tcp_flags <= x"10"; -- final ACK of peer FIN
                                            tcp_close_after_tx(tcp_match_socket_v) <= '1';
                                            tcp_work_socket <= tcp_match_socket_v;
                                            build_index <= 0;
                                            tx_length <= 60;
                                            state <= ST_BUILD_TCP;
                                        END IF;
                                    ELSIF tcp_payload_length_v > 0 AND tcp_payload_length_v <= 128 AND
                                        14 + tcp_total_length_v + 4 <= rx_length AND
                                        tcp_sequence_v = UNSIGNED(tcp_remote_ack(tcp_match_socket_v)) AND
                                        tcp_rx_occupied(tcp_match_socket_v) = '0' THEN
                                        FOR i IN 0 TO 127 LOOP
                                            IF i < tcp_payload_length_v THEN
                                                tcp_rx_data_reg(tcp_match_socket_v)(1023 - i * 8 DOWNTO 1016 - i * 8) <=
                                                    rx_buffer(54 + i);
                                            ELSE
                                                tcp_rx_data_reg(tcp_match_socket_v)(1023 - i * 8 DOWNTO 1016 - i * 8) <= x"00";
                                            END IF;
                                        END LOOP;
                                        tcp_rx_length_reg(tcp_match_socket_v) <=
                                            STD_LOGIC_VECTOR(to_unsigned(tcp_payload_length_v, 8));
                                        tcp_rx_occupied(tcp_match_socket_v) <= '1';
                                        tcp_rx_toggle_reg(tcp_match_socket_v) <=
                                            NOT tcp_rx_toggle_reg(tcp_match_socket_v);
                                        IF rx_buffer(47)(0) = '1' THEN
                                            tcp_remote_ack(tcp_match_socket_v) <= STD_LOGIC_VECTOR(
                                                UNSIGNED(tcp_remote_ack(tcp_match_socket_v)) + tcp_payload_length_v + 1);
                                            tcp_status_reg(tcp_match_socket_v) <= x"04";
                                            tcp_close_after_tx(tcp_match_socket_v) <= '1';
                                        ELSE
                                            tcp_remote_ack(tcp_match_socket_v) <= STD_LOGIC_VECTOR(
                                                UNSIGNED(tcp_remote_ack(tcp_match_socket_v)) + tcp_payload_length_v);
                                        END IF;
                                        tcp_payload_length <= 0;
                                        tcp_flags <= x"10"; -- ACK accepted stream bytes
                                        tcp_work_socket <= tcp_match_socket_v;
                                        build_index <= 0;
                                        tx_length <= 60;
                                        state <= ST_BUILD_TCP;
                                    ELSIF rx_buffer(47)(0) = '1' AND
                                        tcp_sequence_v = UNSIGNED(tcp_remote_ack(tcp_match_socket_v)) THEN
                                        tcp_remote_ack(tcp_match_socket_v) <= STD_LOGIC_VECTOR(
                                            UNSIGNED(tcp_remote_ack(tcp_match_socket_v)) + 1);
                                        tcp_payload_length <= 0;
                                        tcp_flags <= x"10"; -- ACK peer-initiated FIN
                                        tcp_status_reg(tcp_match_socket_v) <= x"04";
                                        tcp_close_after_tx(tcp_match_socket_v) <= '1';
                                        tcp_work_socket <= tcp_match_socket_v;
                                        build_index <= 0;
                                        tx_length <= 60;
                                        state <= ST_BUILD_TCP;
                                    ELSIF (tcp_payload_length_v > 0 OR rx_buffer(47)(0) = '1') AND
                                        tcp_sequence_v /= UNSIGNED(tcp_remote_ack(tcp_match_socket_v)) THEN
                                        -- A retransmitted or out-of-order segment must not be
                                        -- delivered twice.  Re-advertise the next sequence byte
                                        -- expected so the peer can recover a lost ACK.
                                        tcp_payload_length <= 0;
                                        tcp_flags <= x"10";
                                        tcp_work_socket <= tcp_match_socket_v;
                                        build_index <= 0;
                                        tx_length <= 60;
                                        state <= ST_BUILD_TCP;
                                    END IF;
                                END IF;
                            ELSIF destination_ok_v AND rx_length >= 46 AND
                                rx_buffer(12) = x"08" AND rx_buffer(13) = x"06" AND
                                rx_buffer(14) = x"00" AND rx_buffer(15) = x"01" AND
                                rx_buffer(16) = x"08" AND rx_buffer(17) = x"00" AND
                                rx_buffer(18) = x"06" AND rx_buffer(19) = x"04" AND
                                rx_buffer(20) = x"00" AND rx_buffer(21) = x"01" AND
                                rx_buffer(38) = ip_byte(ipv4_address, 0) AND
                                rx_buffer(39) = ip_byte(ipv4_address, 1) AND
                                rx_buffer(40) = ip_byte(ipv4_address, 2) AND
                                rx_buffer(41) = ip_byte(ipv4_address, 3) THEN
                                build_index <= 0;
                                tx_length <= 60;
                                state <= ST_BUILD_ARP;
                            ELSIF destination_ok_v AND ip_match_v AND rx_length >= 46 AND
                                rx_buffer(12) = x"08" AND rx_buffer(13) = x"00" AND
                                rx_buffer(14) = x"45" AND rx_buffer(23) = x"01" AND
                                rx_buffer(20)(5 DOWNTO 0) = "000000" AND rx_buffer(21) = x"00" AND
                                rx_buffer(34) = x"08" AND rx_buffer(35) = x"00" THEN
                                total_v := to_integer(UNSIGNED(rx_buffer(16)) & UNSIGNED(rx_buffer(17)));
                                frame_v := 14 + total_v;
                                IF total_v >= 28 AND total_v <= 1500 AND frame_v + 4 <= rx_length THEN
                                    ip_total_length <= total_v;
                                    tx_length <= frame_v;
                                    build_index <= 0;
                                    state <= ST_COPY_ICMP;
                                END IF;
                            END IF;
                        ELSIF dhcp_enable = '1' AND dhcp_state = DHCP_DISCOVER_START THEN
                            dhcp_tx_message_type <= x"01";
                            dhcp_renewing <= '0';
                            dhcp_state <= DHCP_OFFER_WAIT;
                            dhcp_timer <= 0;
                            build_index <= 0;
                            tx_length <= 302;
                            state <= ST_BUILD_DHCP;
                        ELSIF dhcp_enable = '1' AND dhcp_state = DHCP_REQUEST_START THEN
                            dhcp_tx_message_type <= x"03";
                            dhcp_renewing <= '0';
                            dhcp_state <= DHCP_ACK_WAIT;
                            dhcp_timer <= 0;
                            build_index <= 0;
                            tx_length <= 314;
                            state <= ST_BUILD_DHCP;
                        ELSIF dhcp_enable = '1' AND dhcp_state = DHCP_RENEW_START THEN
                            dhcp_tx_message_type <= x"03";
                            dhcp_renewing <= '1';
                            dhcp_state <= DHCP_RENEW_WAIT;
                            dhcp_timer <= 0;
                            build_index <= 0;
                            tx_length <= 302;
                            state <= ST_BUILD_DHCP;
                        ELSIF dhcp_enable = '1' AND
                            (dhcp_state = DHCP_OFFER_WAIT OR dhcp_state = DHCP_ACK_WAIT OR
                             dhcp_state = DHCP_RENEW_WAIT) THEN
                            IF dhcp_timer >= G_DNS_TIMEOUT THEN
                                dhcp_timer <= 0;
                                IF dhcp_retry_count < 5 THEN
                                    dhcp_retry_count <= dhcp_retry_count + 1;
                                    IF dhcp_state = DHCP_OFFER_WAIT THEN
                                        dhcp_state <= DHCP_DISCOVER_START;
                                    ELSIF dhcp_state = DHCP_ACK_WAIT THEN
                                        dhcp_state <= DHCP_REQUEST_START;
                                    ELSE
                                        dhcp_state <= DHCP_RENEW_START;
                                    END IF;
                                ELSIF dhcp_state = DHCP_RENEW_WAIT AND dhcp_lease_remaining /= 0 THEN
                                    dhcp_retry_count <= 0;
                                    dhcp_state <= DHCP_RENEW_START;
                                ELSE
                                    dhcp_state <= DHCP_ERROR;
                                END IF;
                            ELSE
                                dhcp_timer <= dhcp_timer + 1;
                            END IF;
                        ELSIF dhcp_enable = '1' AND dhcp_state = DHCP_ERROR THEN
                            IF dhcp_timer >= G_DNS_TIMEOUT THEN
                                dhcp_timer <= 0;
                                dhcp_retry_count <= 0;
                                dhcp_xid <= STD_LOGIC_VECTOR(UNSIGNED(dhcp_xid) + 1);
                                dhcp_state <= DHCP_DISCOVER_START;
                            ELSE
                                dhcp_timer <= dhcp_timer + 1;
                            END IF;
                        ELSIF find_retry_socket(tcp_retry_pending) >= 0 THEN
                            tcp_match_socket_v := find_retry_socket(tcp_retry_pending);
                            tcp_retry_pending(tcp_match_socket_v) <= '0';
                            tcp_work_socket <= tcp_match_socket_v;
                            build_index <= 0;
                            IF tcp_status_reg(tcp_match_socket_v) = x"02" THEN
                                tcp_payload_length <= 0;
                                tcp_flags <= x"02"; -- retransmit SYN
                                tx_length <= 60;
                            ELSIF tcp_status_reg(tcp_match_socket_v) = x"03" AND
                                tcp_tx_outstanding(tcp_match_socket_v) = '1' THEN
                                tcp_payload_length <= tcp_tx_outstanding_length(tcp_match_socket_v);
                                tcp_flags <= x"18"; -- retransmit PSH + ACK
                                IF 54 + tcp_tx_outstanding_length(tcp_match_socket_v) < 60 THEN
                                    tx_length <= 60;
                                ELSE
                                    tx_length <= 54 + tcp_tx_outstanding_length(tcp_match_socket_v);
                                END IF;
                            ELSE
                                tcp_payload_length <= 0;
                                tcp_flags <= x"11"; -- retransmit FIN + ACK
                                tx_length <= 60;
                            END IF;
                            state <= ST_BUILD_TCP;
                        ELSIF find_connect_socket(tcp_connect_pending, tcp_status_reg) >= 0 AND
                            (dhcp_enable = '0' OR dhcp_state = DHCP_BOUND OR
                             dhcp_state = DHCP_RENEW_START OR dhcp_state = DHCP_RENEW_WAIT) AND
                            dns_state = DNS_DONE AND tcp_arp_active = '0' THEN
                            tcp_match_socket_v := find_connect_socket(tcp_connect_pending, tcp_status_reg);
                            tcp_connect_pending(tcp_match_socket_v) <= '0';
                            tcp_remote_ip(tcp_match_socket_v) <= tcp_connect_ip_pending(tcp_match_socket_v);
                            tcp_remote_port(tcp_match_socket_v) <= tcp_connect_port_pending(tcp_match_socket_v);
                            tcp_local_port(tcp_match_socket_v) <= STD_LOGIC_VECTOR(
                                to_unsigned(16#C100#, 16) + RESIZE(tcp_connection_nonce, 16));
                            tcp_local_seq(tcp_match_socket_v) <= STD_LOGIC_VECTOR(
                                UNSIGNED'(x"4E320000") + RESIZE(tcp_connection_nonce, 32));
                            IF tcp_connection_nonce = to_unsigned(16#3EFF#, 14) THEN
                                tcp_connection_nonce <= (OTHERS => '0');
                            ELSE
                                tcp_connection_nonce <= tcp_connection_nonce + 1;
                            END IF;
                            debug_tcp_syn_sent <= to_unsigned(1, debug_tcp_syn_sent'length);
                            debug_tcp_syn_tx_complete <= (OTHERS => '0');
                            debug_tcp_any_frames <= (OTHERS => '0');
                            debug_tcp_local_frames <= (OTHERS => '0');
                            -- Resolve the correct Ethernet next hop for every
                            -- connection.  A local peer needs its own MAC;
                            -- only routed destinations use the gateway MAC.
                            IF (tcp_connect_ip_pending(tcp_match_socket_v) AND ipv4_netmask) =
                                (ipv4_address AND ipv4_netmask) THEN
                                tcp_next_hop_v := tcp_connect_ip_pending(tcp_match_socket_v);
                            ELSE
                                tcp_next_hop_v := ipv4_gateway;
                            END IF;
                            tcp_arp_target <= tcp_next_hop_v;
                            tcp_arp_socket <= tcp_match_socket_v;
                            tcp_arp_active <= '1';
                            tcp_arp_timer <= 0;
                            tcp_arp_retry_count <= 0;
                            tcp_status_reg(tcp_match_socket_v) <= x"01"; -- awaiting ARP
                            build_index <= 0;
                            tx_length <= 60;
                            state <= ST_BUILD_TCP_ARP;
                        ELSIF find_close_socket(tcp_close_pending, tcp_status_reg,
                            tcp_tx_outstanding) >= 0 THEN
                            tcp_match_socket_v := find_close_socket(tcp_close_pending,
                                tcp_status_reg, tcp_tx_outstanding);
                            tcp_close_pending(tcp_match_socket_v) <= '0';
                            tcp_send_pending(tcp_match_socket_v) <= '0';
                            tcp_payload_length <= 0;
                            tcp_flags <= x"11"; -- FIN + ACK
                            tcp_status_reg(tcp_match_socket_v) <= x"04"; -- closing
                            tcp_fin_waiting(tcp_match_socket_v) <= '1';
                            tcp_timer(tcp_match_socket_v) <= 0;
                            tcp_retry_count(tcp_match_socket_v) <= 0;
                            tcp_retry_pending(tcp_match_socket_v) <= '0';
                            tcp_work_socket <= tcp_match_socket_v;
                            build_index <= 0;
                            tx_length <= 60;
                            state <= ST_BUILD_TCP;
                        ELSIF find_window_socket(tcp_window_update_pending,
                            tcp_status_reg) >= 0 THEN
                            tcp_match_socket_v := find_window_socket(tcp_window_update_pending,
                                tcp_status_reg);
                            tcp_window_update_pending(tcp_match_socket_v) <= '0';
                            tcp_payload_length <= 0;
                            tcp_flags <= x"10";
                            tcp_work_socket <= tcp_match_socket_v;
                            build_index <= 0;
                            tx_length <= 60;
                            state <= ST_BUILD_TCP;
                        ELSIF find_send_socket(tcp_send_pending, tcp_status_reg,
                            tcp_tx_outstanding) >= 0 THEN
                            tcp_match_socket_v := find_send_socket(tcp_send_pending,
                                tcp_status_reg, tcp_tx_outstanding);
                            tcp_send_pending(tcp_match_socket_v) <= '0';
                            tcp_payload_length <= tcp_send_length_reg(tcp_match_socket_v);
                            tcp_tx_outstanding(tcp_match_socket_v) <= '1';
                            tcp_tx_outstanding_length(tcp_match_socket_v) <=
                                tcp_send_length_reg(tcp_match_socket_v);
                            tcp_timer(tcp_match_socket_v) <= 0;
                            tcp_retry_count(tcp_match_socket_v) <= 0;
                            tcp_retry_pending(tcp_match_socket_v) <= '0';
                            tcp_flags <= x"18"; -- PSH + ACK
                            tcp_work_socket <= tcp_match_socket_v;
                            build_index <= 0;
                            IF 54 + tcp_send_length_reg(tcp_match_socket_v) < 60 THEN
                                tx_length <= 60;
                            ELSE
                                tx_length <= 54 + tcp_send_length_reg(tcp_match_socket_v);
                            END IF;
                            state <= ST_BUILD_TCP;
                        ELSIF tcp_arp_active = '1' THEN
                            IF tcp_arp_timer >= G_TCP_RETRY_INTERVAL THEN
                                IF tcp_arp_retry_count < 2 THEN
                                    tcp_arp_retry_count <= tcp_arp_retry_count + 1;
                                    tcp_arp_timer <= 0;
                                    build_index <= 0;
                                    tx_length <= 60;
                                    state <= ST_BUILD_TCP_ARP;
                                ELSE
                                    tcp_arp_active <= '0';
                                    tcp_status_reg(tcp_arp_socket) <= x"E1";
                                    tcp_arp_timer <= 0;
                                END IF;
                            ELSE
                                tcp_arp_timer <= tcp_arp_timer + 1;
                            END IF;
                        ELSIF ping_state = PING_ARP_START THEN
                            build_index <= 0;
                            tx_length <= 60;
                            ping_timer <= 0;
                            ping_state <= PING_ARP_WAIT;
                            state <= ST_BUILD_PING_ARP;
                        ELSIF ping_state = PING_ARP_WAIT THEN
                            IF ping_timer >= G_TCP_RETRY_INTERVAL THEN
                                IF ping_retry_count < 2 THEN
                                    ping_retry_count <= ping_retry_count + 1;
                                    ping_timer <= 0;
                                    ping_state <= PING_ARP_START;
                                ELSE
                                    ping_state <= PING_ERROR;
                                    ping_result_reg <= x"E1";
                                END IF;
                            ELSE
                                ping_timer <= ping_timer + 1;
                            END IF;
                        ELSIF ping_state = PING_SEND THEN
                            build_index <= 0;
                            tx_length <= 60;
                            ip_total_length <= 28;
                            ping_timer <= 0;
                            ping_state <= PING_REPLY_WAIT;
                            state <= ST_BUILD_PING;
                        ELSIF ping_state = PING_REPLY_WAIT THEN
                            IF ping_timer >= G_DNS_TIMEOUT THEN
                                ping_state <= PING_ERROR;
                                ping_result_reg <= x"E2";
                            ELSE
                                ping_timer <= ping_timer + 1;
                            END IF;
                        ELSIF dns_state = DNS_BOOT_WAIT THEN
                            IF dns_timer >= G_DNS_START_DELAY THEN
                                IF dns_server = x"00000000" OR ipv4_address = x"00000000" THEN
                                    dns_state <= DNS_ERROR;
                                    dns_display <= x"FFFFFF03";
                                ELSE
                                    IF (dns_server AND ipv4_netmask) = (ipv4_address AND ipv4_netmask) THEN
                                        dns_next_hop <= dns_server;
                                    ELSE
                                        dns_next_hop <= ipv4_gateway;
                                    END IF;
                                    dns_timer <= 0;
                                    dns_retry_count <= 0;
                                    dns_state <= DNS_ARP_START;
                                    dns_display <= x"00000001";
                                END IF;
                            ELSE
                                dns_timer <= dns_timer + 1;
                            END IF;
                        ELSIF dns_state = DNS_ARP_START THEN
                            build_index <= 0;
                            tx_length <= 60;
                            dns_timer <= 0;
                            dns_state <= DNS_ARP_WAIT;
                            dns_display <= x"00000001";
                            state <= ST_BUILD_ARP_QUERY;
                        ELSIF dns_state = DNS_ARP_WAIT THEN
                            IF dns_timer >= G_DNS_TIMEOUT THEN
                                IF dns_retry_count < 2 THEN
                                    dns_retry_count <= dns_retry_count + 1;
                                    dns_timer <= 0;
                                    dns_state <= DNS_ARP_START;
                                ELSE
                                    dns_state <= DNS_ERROR;
                                    -- FF01 identifies the error.  The low bytes retain the
                                    -- total received ARP count and matching gateway-sender
                                    -- count for the configuration-page diagnostic.
                                    dns_display <= x"FF01" & STD_LOGIC_VECTOR(debug_arp_type_frames) &
                                        STD_LOGIC_VECTOR(debug_gateway_arp_frames);
                                END IF;
                            ELSE
                                dns_timer <= dns_timer + 1;
                            END IF;
                        ELSIF dns_state = DNS_QUERY_START THEN
                            build_index <= 0;
                            IF 58 + dns_qname_length < 60 THEN
                                tx_length <= 60;
                            ELSE
                                tx_length <= 58 + dns_qname_length;
                            END IF;
                            dns_timer <= 0;
                            dns_state <= DNS_RESPONSE_WAIT;
                            dns_display <= x"00000002";
                            state <= ST_BUILD_DNS;
                        ELSIF dns_state = DNS_RESPONSE_WAIT THEN
                            IF dns_timer >= G_DNS_TIMEOUT THEN
                                IF dns_retry_count < 2 THEN
                                    dns_retry_count <= dns_retry_count + 1;
                                    dns_timer <= 0;
                                    dns_state <= DNS_QUERY_START;
                                ELSE
                                    dns_state <= DNS_ERROR;
                                    dns_display <= x"FFFFFF02";
                                END IF;
                            ELSE
                                dns_timer <= dns_timer + 1;
                            END IF;
                        END IF;

                    WHEN ST_DNS_SCAN_NAME =>
                        -- A DNS owner name is either a sequence of labels ending
                        -- in zero or a two-byte compression pointer.  Advance one
                        -- label per clock so this parser stays small and fast.
                        IF dns_answers_remaining = 0 OR dns_parse_offset >= dns_parse_limit THEN
                            dns_state <= DNS_ERROR;
                            dns_display <= x"FFFFFF03";
                            state <= ST_IDLE;
                        ELSIF rx_buffer(dns_parse_offset)(7 DOWNTO 6) = "11" THEN
                            IF dns_parse_offset + 2 > dns_parse_limit THEN
                                dns_state <= DNS_ERROR;
                                dns_display <= x"FFFFFF03";
                                state <= ST_IDLE;
                            ELSE
                                dns_parse_offset <= dns_parse_offset + 2;
                                state <= ST_DNS_SCAN_RR;
                            END IF;
                        ELSIF rx_buffer(dns_parse_offset) = x"00" THEN
                            dns_parse_offset <= dns_parse_offset + 1;
                            state <= ST_DNS_SCAN_RR;
                        ELSIF rx_buffer(dns_parse_offset)(7 DOWNTO 6) /= "00" OR
                            dns_parse_offset + 1 + to_integer(UNSIGNED(rx_buffer(dns_parse_offset))) >
                                dns_parse_limit THEN
                            dns_state <= DNS_ERROR;
                            dns_display <= x"FFFFFF03";
                            state <= ST_IDLE;
                        ELSE
                            dns_parse_offset <= dns_parse_offset + 1 +
                                to_integer(UNSIGNED(rx_buffer(dns_parse_offset)));
                        END IF;

                    WHEN ST_DNS_SCAN_RR =>
                        -- TYPE(2), CLASS(2), TTL(4), RDLENGTH(2), RDATA.
                        IF dns_parse_offset + 10 > dns_parse_limit THEN
                            dns_state <= DNS_ERROR;
                            dns_display <= x"FFFFFF03";
                            state <= ST_IDLE;
                        ELSE
                            total_v := to_integer(UNSIGNED(rx_buffer(dns_parse_offset + 8))) * 256 +
                                to_integer(UNSIGNED(rx_buffer(dns_parse_offset + 9)));
                            IF dns_parse_offset + 10 + total_v > dns_parse_limit THEN
                                dns_state <= DNS_ERROR;
                                dns_display <= x"FFFFFF03";
                                state <= ST_IDLE;
                            ELSIF rx_buffer(dns_parse_offset) = x"00" AND
                                rx_buffer(dns_parse_offset + 1) = x"01" AND
                                rx_buffer(dns_parse_offset + 2) = x"00" AND
                                rx_buffer(dns_parse_offset + 3) = x"01" AND total_v = 4 THEN
                                dns_display <= rx_buffer(dns_parse_offset + 10) &
                                    rx_buffer(dns_parse_offset + 11) &
                                    rx_buffer(dns_parse_offset + 12) &
                                    rx_buffer(dns_parse_offset + 13);
                                dns_state <= DNS_DONE;
                                state <= ST_IDLE;
                            ELSIF dns_answers_remaining <= 1 THEN
                                dns_state <= DNS_ERROR;
                                dns_display <= x"FFFFFF03";
                                state <= ST_IDLE;
                            ELSE
                                dns_answers_remaining <= dns_answers_remaining - 1;
                                dns_parse_offset <= dns_parse_offset + 10 + total_v;
                                state <= ST_DNS_SCAN_NAME;
                            END IF;
                        END IF;

                    WHEN ST_BUILD_ARP =>
                        byte_v := x"00";
                        CASE build_index IS
                            WHEN 0 TO 5 => byte_v := rx_buffer(22 + build_index);
                            WHEN 6 TO 11 => byte_v := mac_byte(build_index - 6);
                            WHEN 12 => byte_v := x"08";
                            WHEN 13 => byte_v := x"06";
                            WHEN 14 => byte_v := x"00";
                            WHEN 15 => byte_v := x"01";
                            WHEN 16 => byte_v := x"08";
                            WHEN 17 => byte_v := x"00";
                            WHEN 18 => byte_v := x"06";
                            WHEN 19 => byte_v := x"04";
                            WHEN 20 => byte_v := x"00";
                            WHEN 21 => byte_v := x"02";
                            WHEN 22 TO 27 => byte_v := mac_byte(build_index - 22);
                            WHEN 28 TO 31 => byte_v := ip_byte(ipv4_address, build_index - 28);
                            WHEN 32 TO 37 => byte_v := rx_buffer(build_index - 10);
                            WHEN 38 TO 41 => byte_v := rx_buffer(build_index - 10);
                            WHEN OTHERS => byte_v := x"00";
                        END CASE;
                        tx_buffer(build_index) <= byte_v;
                        IF build_index = 59 THEN
                            tx_preamble_index <= 0;
                            tx_phase <= 0;
                            tx_crc <= (OTHERS => '1');
                            state <= ST_TX_PREAMBLE;
                        ELSE
                            build_index <= build_index + 1;
                        END IF;

                    WHEN ST_BUILD_ARP_QUERY =>
                        byte_v := x"00";
                        CASE build_index IS
                            WHEN 0 TO 5 => byte_v := x"FF";
                            WHEN 6 TO 11 => byte_v := mac_byte(build_index - 6);
                            WHEN 12 => byte_v := x"08";
                            WHEN 13 => byte_v := x"06";
                            WHEN 14 => byte_v := x"00";
                            WHEN 15 => byte_v := x"01";
                            WHEN 16 => byte_v := x"08";
                            WHEN 17 => byte_v := x"00";
                            WHEN 18 => byte_v := x"06";
                            WHEN 19 => byte_v := x"04";
                            WHEN 20 => byte_v := x"00";
                            WHEN 21 => byte_v := x"01";
                            WHEN 22 TO 27 => byte_v := mac_byte(build_index - 22);
                            WHEN 28 TO 31 => byte_v := ip_byte(ipv4_address, build_index - 28);
                            WHEN 38 TO 41 => byte_v := ip_byte(dns_next_hop, build_index - 38);
                            WHEN OTHERS => byte_v := x"00";
                        END CASE;
                        tx_buffer(build_index) <= byte_v;
                        IF build_index = 59 THEN
                            tx_preamble_index <= 0;
                            tx_phase <= 0;
                            tx_crc <= (OTHERS => '1');
                            state <= ST_TX_PREAMBLE;
                        ELSE
                            build_index <= build_index + 1;
                        END IF;

                    WHEN ST_BUILD_TCP_ARP =>
                        byte_v := x"00";
                        CASE build_index IS
                            WHEN 0 TO 5 => byte_v := x"FF";
                            WHEN 6 TO 11 => byte_v := mac_byte(build_index - 6);
                            WHEN 12 => byte_v := x"08";
                            WHEN 13 => byte_v := x"06";
                            WHEN 14 => byte_v := x"00";
                            WHEN 15 => byte_v := x"01";
                            WHEN 16 => byte_v := x"08";
                            WHEN 17 => byte_v := x"00";
                            WHEN 18 => byte_v := x"06";
                            WHEN 19 => byte_v := x"04";
                            WHEN 20 => byte_v := x"00";
                            WHEN 21 => byte_v := x"01";
                            WHEN 22 TO 27 => byte_v := mac_byte(build_index - 22);
                            WHEN 28 TO 31 => byte_v := ip_byte(ipv4_address, build_index - 28);
                            WHEN 38 TO 41 => byte_v := ip_byte(tcp_arp_target, build_index - 38);
                            WHEN OTHERS => byte_v := x"00";
                        END CASE;
                        tx_buffer(build_index) <= byte_v;
                        IF build_index = 59 THEN
                            tx_preamble_index <= 0;
                            tx_phase <= 0;
                            tx_crc <= (OTHERS => '1');
                            state <= ST_TX_PREAMBLE;
                        ELSE
                            build_index <= build_index + 1;
                        END IF;

                    WHEN ST_BUILD_PING_ARP =>
                        byte_v := x"00";
                        CASE build_index IS
                            WHEN 0 TO 5 => byte_v := x"FF";
                            WHEN 6 TO 11 => byte_v := mac_byte(build_index - 6);
                            WHEN 12 => byte_v := x"08";
                            WHEN 13 => byte_v := x"06";
                            WHEN 14 => byte_v := x"00";
                            WHEN 15 => byte_v := x"01";
                            WHEN 16 => byte_v := x"08";
                            WHEN 17 => byte_v := x"00";
                            WHEN 18 => byte_v := x"06";
                            WHEN 19 => byte_v := x"04";
                            WHEN 20 => byte_v := x"00";
                            WHEN 21 => byte_v := x"01";
                            WHEN 22 TO 27 => byte_v := mac_byte(build_index - 22);
                            WHEN 28 TO 31 => byte_v := ip_byte(ipv4_address, build_index - 28);
                            WHEN 38 TO 41 => byte_v := ip_byte(ping_next_hop, build_index - 38);
                            WHEN OTHERS => byte_v := x"00";
                        END CASE;
                        tx_buffer(build_index) <= byte_v;
                        IF build_index = 59 THEN
                            tx_preamble_index <= 0;
                            tx_phase <= 0;
                            tx_crc <= (OTHERS => '1');
                            state <= ST_TX_PREAMBLE;
                        ELSE
                            build_index <= build_index + 1;
                        END IF;

                    WHEN ST_DHCP_SCAN_OPTIONS =>
                        IF dhcp_option_length = 0 THEN
                            IF dhcp_parse_offset >= dhcp_parse_limit THEN
                                IF dhcp_rx_message_type = x"02" AND dhcp_state = DHCP_OFFER_WAIT THEN
                                    dhcp_state <= DHCP_REQUEST_START;
                                    dhcp_retry_count <= 0;
                                ELSIF dhcp_rx_message_type = x"05" AND
                                    (dhcp_state = DHCP_ACK_WAIT OR dhcp_state = DHCP_RENEW_WAIT) THEN
                                    ipv4_address <= dhcp_offered_ip;
                                    dhcp_candidate_lease <= dhcp_candidate_lease;
                                    IF dhcp_candidate_netmask = x"00000000" THEN
                                        ipv4_netmask <= x"FFFFFF00";
                                    ELSE
                                        ipv4_netmask <= dhcp_candidate_netmask;
                                    END IF;
                                    dhcp_candidate_gateway <= dhcp_candidate_gateway;
                                    ipv4_gateway <= dhcp_candidate_gateway;
                                    dhcp_candidate_dns <= dhcp_candidate_dns;
                                    dns_server <= dhcp_candidate_dns;
                                    dhcp_lease_remaining <= dhcp_candidate_lease;
                                    dhcp_renew_at <= shift_right(dhcp_candidate_lease, 1);
                                    dhcp_seconds_divider <= 0;
                                    dhcp_retry_count <= 0;
                                    dhcp_state <= DHCP_BOUND;
                                ELSIF dhcp_rx_message_type = x"06" THEN
                                    ipv4_address <= (OTHERS => '0');
                                    ipv4_netmask <= (OTHERS => '0');
                                    ipv4_gateway <= (OTHERS => '0');
                                    dns_server <= (OTHERS => '0');
                                    dhcp_xid <= STD_LOGIC_VECTOR(UNSIGNED(dhcp_xid) + 1);
                                    dhcp_retry_count <= 0;
                                    dhcp_state <= DHCP_DISCOVER_START;
                                END IF;
                                state <= ST_IDLE;
                            ELSIF rx_buffer(dhcp_parse_offset) = x"00" THEN
                                dhcp_parse_offset <= dhcp_parse_offset + 1;
                            ELSIF rx_buffer(dhcp_parse_offset) = x"FF" THEN
                                dhcp_parse_offset <= dhcp_parse_limit;
                            ELSIF dhcp_parse_offset + 1 < dhcp_parse_limit THEN
                                dhcp_option_code <= rx_buffer(dhcp_parse_offset);
                                dhcp_option_length <= to_integer(UNSIGNED(rx_buffer(dhcp_parse_offset + 1)));
                                dhcp_option_index <= 0;
                                dhcp_parse_offset <= dhcp_parse_offset + 2;
                            ELSE
                                dhcp_parse_offset <= dhcp_parse_limit;
                            END IF;
                        ELSE
                            IF dhcp_parse_offset < dhcp_parse_limit THEN
                                IF dhcp_option_code = x"35" AND dhcp_option_index = 0 THEN
                                    dhcp_rx_message_type <= rx_buffer(dhcp_parse_offset);
                                ELSIF dhcp_option_code = x"01" AND dhcp_option_index < 4 THEN
                                    dhcp_candidate_netmask(31 - dhcp_option_index * 8 DOWNTO
                                        24 - dhcp_option_index * 8) <= rx_buffer(dhcp_parse_offset);
                                ELSIF dhcp_option_code = x"03" AND dhcp_option_index < 4 THEN
                                    dhcp_candidate_gateway(31 - dhcp_option_index * 8 DOWNTO
                                        24 - dhcp_option_index * 8) <= rx_buffer(dhcp_parse_offset);
                                ELSIF dhcp_option_code = x"06" AND dhcp_option_index < 4 THEN
                                    dhcp_candidate_dns(31 - dhcp_option_index * 8 DOWNTO
                                        24 - dhcp_option_index * 8) <= rx_buffer(dhcp_parse_offset);
                                ELSIF dhcp_option_code = x"33" AND dhcp_option_index < 4 THEN
                                    dhcp_candidate_lease(31 - dhcp_option_index * 8 DOWNTO
                                        24 - dhcp_option_index * 8) <= UNSIGNED(rx_buffer(dhcp_parse_offset));
                                ELSIF dhcp_option_code = x"36" AND dhcp_option_index < 4 THEN
                                    dhcp_server_id(31 - dhcp_option_index * 8 DOWNTO
                                        24 - dhcp_option_index * 8) <= rx_buffer(dhcp_parse_offset);
                                END IF;
                                dhcp_parse_offset <= dhcp_parse_offset + 1;
                            ELSE
                                dhcp_parse_offset <= dhcp_parse_limit;
                            END IF;
                            IF dhcp_option_index + 1 >= dhcp_option_length THEN
                                dhcp_option_length <= 0;
                                dhcp_option_index <= 0;
                            ELSE
                                dhcp_option_index <= dhcp_option_index + 1;
                            END IF;
                        END IF;

                    WHEN ST_BUILD_DHCP =>
                        byte_v := x"00";
                        frame_v := tx_length;
                        total_v := frame_v - 14;
                        CASE build_index IS
                            WHEN 0 TO 5 => byte_v := x"FF";
                            WHEN 6 TO 11 => byte_v := mac_byte(build_index - 6);
                            WHEN 12 => byte_v := x"08";
                            WHEN 13 => byte_v := x"00";
                            WHEN 14 => byte_v := x"45";
                            WHEN 15 => byte_v := x"00";
                            WHEN 16 => byte_v := STD_LOGIC_VECTOR(to_unsigned(total_v, 16)(15 DOWNTO 8));
                            WHEN 17 => byte_v := STD_LOGIC_VECTOR(to_unsigned(total_v, 16)(7 DOWNTO 0));
                            WHEN 18 => byte_v := x"4E";
                            WHEN 19 => byte_v := x"44";
                            WHEN 20 TO 21 => byte_v := x"00";
                            WHEN 22 => byte_v := x"40";
                            WHEN 23 => byte_v := x"11";
                            WHEN 24 TO 25 => byte_v := x"00";
                            WHEN 26 TO 29 =>
                                IF dhcp_renewing = '1' THEN byte_v := ip_byte(ipv4_address, build_index - 26); END IF;
                            WHEN 30 TO 33 => byte_v := x"FF";
                            WHEN 34 => byte_v := x"00";
                            WHEN 35 => byte_v := x"44";
                            WHEN 36 => byte_v := x"00";
                            WHEN 37 => byte_v := x"43";
                            WHEN 38 => byte_v := STD_LOGIC_VECTOR(to_unsigned(total_v - 20, 16)(15 DOWNTO 8));
                            WHEN 39 => byte_v := STD_LOGIC_VECTOR(to_unsigned(total_v - 20, 16)(7 DOWNTO 0));
                            WHEN 40 TO 41 => byte_v := x"00";
                            WHEN 42 => byte_v := x"01";
                            WHEN 43 => byte_v := x"01";
                            WHEN 44 => byte_v := x"06";
                            WHEN 45 => byte_v := x"00";
                            WHEN 46 TO 49 => byte_v := dhcp_xid(31 - (build_index - 46) * 8 DOWNTO
                                24 - (build_index - 46) * 8);
                            WHEN 50 TO 51 => byte_v := x"00";
                            WHEN 52 => byte_v := x"80";
                            WHEN 53 => byte_v := x"00";
                            WHEN 54 TO 57 =>
                                IF dhcp_renewing = '1' THEN byte_v := ip_byte(ipv4_address, build_index - 54); END IF;
                            WHEN 70 TO 75 => byte_v := mac_byte(build_index - 70);
                            WHEN 278 => byte_v := x"63";
                            WHEN 279 => byte_v := x"82";
                            WHEN 280 => byte_v := x"53";
                            WHEN 281 => byte_v := x"63";
                            WHEN 282 => byte_v := x"35";
                            WHEN 283 => byte_v := x"01";
                            WHEN 284 => byte_v := dhcp_tx_message_type;
                            WHEN 285 => byte_v := x"3D";
                            WHEN 286 => byte_v := x"07";
                            WHEN 287 => byte_v := x"01";
                            WHEN 288 TO 293 => byte_v := mac_byte(build_index - 288);
                            WHEN 294 => byte_v := x"37";
                            WHEN 295 => byte_v := x"05";
                            WHEN 296 => byte_v := x"01";
                            WHEN 297 => byte_v := x"03";
                            WHEN 298 => byte_v := x"06";
                            WHEN 299 => byte_v := x"33";
                            WHEN 300 => byte_v := x"3A";
                            WHEN 301 =>
                                IF dhcp_renewing = '0' AND dhcp_tx_message_type = x"03" THEN
                                    byte_v := x"32";
                                ELSE
                                    byte_v := x"FF";
                                END IF;
                            WHEN 302 => byte_v := x"04";
                            WHEN 303 TO 306 => byte_v := ip_byte(dhcp_offered_ip, build_index - 303);
                            WHEN 307 => byte_v := x"36";
                            WHEN 308 => byte_v := x"04";
                            WHEN 309 TO 312 => byte_v := ip_byte(dhcp_server_id, build_index - 309);
                            WHEN 313 => byte_v := x"FF";
                            WHEN OTHERS => byte_v := x"00";
                        END CASE;
                        tx_buffer(build_index) <= byte_v;
                        IF build_index = frame_v - 1 THEN
                            ip_total_length <= total_v;
                            checksum_index <= 14;
                            checksum_end <= 34;
                            checksum_sum <= (OTHERS => '0');
                            checksum_mode <= 0;
                            state <= ST_IP_SUM;
                        ELSE
                            build_index <= build_index + 1;
                        END IF;

                    WHEN ST_BUILD_DNS =>
                        byte_v := x"00";
                        total_v := 44 + dns_qname_length;
                        frame_v := 58 + dns_qname_length;
                        IF frame_v < 60 THEN frame_v := 60; END IF;
                        CASE build_index IS
                            WHEN 0 TO 5 =>
                                byte_v := dns_next_hop_mac(47 - build_index * 8 DOWNTO 40 - build_index * 8);
                            WHEN 6 TO 11 => byte_v := mac_byte(build_index - 6);
                            WHEN 12 => byte_v := x"08";
                            WHEN 13 => byte_v := x"00";
                            WHEN 14 => byte_v := x"45";
                            WHEN 15 => byte_v := x"00";
                            WHEN 16 => byte_v := x"00";
                            WHEN 17 => byte_v := STD_LOGIC_VECTOR(to_unsigned(total_v, 8));
                            WHEN 18 => byte_v := x"4E";
                            WHEN 19 => byte_v := x"32";
                            WHEN 20 => byte_v := x"00";
                            WHEN 21 => byte_v := x"00";
                            WHEN 22 => byte_v := x"40";
                            WHEN 23 => byte_v := x"11";
                            WHEN 24 TO 25 => byte_v := x"00";
                            WHEN 26 TO 29 => byte_v := ip_byte(ipv4_address, build_index - 26);
                            WHEN 30 TO 33 => byte_v := ip_byte(dns_server, build_index - 30);
                            WHEN 34 => byte_v := x"C0";
                            WHEN 35 => byte_v := x"00";
                            WHEN 36 => byte_v := x"00";
                            WHEN 37 => byte_v := x"35";
                            WHEN 38 => byte_v := x"00";
                            WHEN 39 => byte_v := STD_LOGIC_VECTOR(to_unsigned(24 + dns_qname_length, 8));
                            -- A zero UDP checksum is valid for IPv4.
                            WHEN 40 TO 41 => byte_v := x"00";
                            WHEN 42 => byte_v := x"4E";
                            WHEN 43 => byte_v := x"32";
                            WHEN 44 => byte_v := x"01";
                            WHEN 45 => byte_v := x"00";
                            WHEN 46 => byte_v := x"00";
                            WHEN 47 => byte_v := x"01";
                            WHEN 48 TO 53 => byte_v := x"00";
                            WHEN OTHERS => byte_v := x"00";
                        END CASE;
                        IF build_index >= 54 AND build_index < 54 + dns_qname_length THEN
                            byte_v := dns_qname_data(511 - (build_index - 54) * 8 DOWNTO
                                504 - (build_index - 54) * 8);
                        ELSIF build_index = 54 + dns_qname_length OR
                            build_index = 56 + dns_qname_length THEN
                            byte_v := x"00";
                        ELSIF build_index = 55 + dns_qname_length OR
                            build_index = 57 + dns_qname_length THEN
                            byte_v := x"01";
                        END IF;
                        tx_buffer(build_index) <= byte_v;
                        IF build_index = frame_v - 1 THEN
                            ip_total_length <= total_v;
                            checksum_index <= 14;
                            checksum_end <= 34;
                            checksum_sum <= (OTHERS => '0');
                            checksum_mode <= 0;
                            state <= ST_IP_SUM;
                        ELSE
                            build_index <= build_index + 1;
                        END IF;

                    WHEN ST_BUILD_PING =>
                        byte_v := x"00";
                        CASE build_index IS
                            WHEN 0 TO 5 =>
                                byte_v := ping_next_hop_mac(47 - build_index * 8 DOWNTO 40 - build_index * 8);
                            WHEN 6 TO 11 => byte_v := mac_byte(build_index - 6);
                            WHEN 12 => byte_v := x"08";
                            WHEN 13 => byte_v := x"00";
                            WHEN 14 => byte_v := x"45";
                            WHEN 15 => byte_v := x"00";
                            WHEN 16 => byte_v := x"00";
                            WHEN 17 => byte_v := x"1C";
                            WHEN 18 => byte_v := x"4E";
                            WHEN 19 => byte_v := x"33";
                            WHEN 20 TO 21 => byte_v := x"00";
                            WHEN 22 => byte_v := x"40";
                            WHEN 23 => byte_v := x"01";
                            WHEN 24 TO 25 => byte_v := x"00";
                            WHEN 26 TO 29 => byte_v := ip_byte(ipv4_address, build_index - 26);
                            WHEN 30 TO 33 => byte_v := ip_byte(ping_target, build_index - 30);
                            WHEN 34 => byte_v := x"08";
                            WHEN 35 => byte_v := x"00";
                            WHEN 36 TO 37 => byte_v := x"00";
                            WHEN 38 => byte_v := x"4E";
                            WHEN 39 => byte_v := x"32";
                            WHEN 40 => byte_v := STD_LOGIC_VECTOR(ping_sequence(15 DOWNTO 8));
                            WHEN 41 => byte_v := STD_LOGIC_VECTOR(ping_sequence(7 DOWNTO 0));
                            WHEN OTHERS => byte_v := x"00";
                        END CASE;
                        tx_buffer(build_index) <= byte_v;
                        IF build_index = 59 THEN
                            checksum_index <= 14;
                            checksum_end <= 34;
                            checksum_sum <= (OTHERS => '0');
                            checksum_mode <= 1;
                            state <= ST_IP_SUM;
                        ELSE
                            build_index <= build_index + 1;
                        END IF;

                    WHEN ST_BUILD_TCP =>
                        byte_v := x"00";
                        IF tcp_payload_length = 0 THEN
                            -- Preserve the exact fixed-length packet builder used by the
                            -- first TCP-handshake hardware milestone.
                            word_v := x"0028";
                        ELSE
                            word_v := to_unsigned(40 + tcp_payload_length, 16);
                        END IF;
                        CASE build_index IS
                            WHEN 0 TO 5 =>
                                byte_v := tcp_remote_mac(tcp_work_socket)(47 - build_index * 8 DOWNTO
                                    40 - build_index * 8);
                            WHEN 6 TO 11 => byte_v := mac_byte(build_index - 6);
                            WHEN 12 => byte_v := x"08";
                            WHEN 13 => byte_v := x"00";
                            WHEN 14 => byte_v := x"45";
                            WHEN 15 => byte_v := x"00";
                            WHEN 16 => byte_v := STD_LOGIC_VECTOR(word_v(15 DOWNTO 8));
                            WHEN 17 => byte_v := STD_LOGIC_VECTOR(word_v(7 DOWNTO 0));
                            WHEN 18 => byte_v := x"4E";
                            WHEN 19 => byte_v := x"33";
                            WHEN 20 TO 21 => byte_v := x"00";
                            WHEN 22 => byte_v := x"40";
                            WHEN 23 => byte_v := x"06";
                            WHEN 24 TO 25 => byte_v := x"00";
                            WHEN 26 TO 29 => byte_v := ip_byte(ipv4_address, build_index - 26);
                            WHEN 30 TO 33 => byte_v := ip_byte(tcp_remote_ip(tcp_work_socket), build_index - 30);
                            WHEN 34 => byte_v := tcp_local_port(tcp_work_socket)(15 DOWNTO 8);
                            WHEN 35 => byte_v := tcp_local_port(tcp_work_socket)(7 DOWNTO 0);
                            WHEN 36 => byte_v := tcp_remote_port(tcp_work_socket)(15 DOWNTO 8);
                            WHEN 37 => byte_v := tcp_remote_port(tcp_work_socket)(7 DOWNTO 0);
                            WHEN 38 TO 41 => byte_v := tcp_local_seq(tcp_work_socket)(31 - (build_index - 38) * 8 DOWNTO
                                24 - (build_index - 38) * 8);
                            WHEN 42 TO 45 => byte_v := tcp_remote_ack(tcp_work_socket)(31 - (build_index - 42) * 8 DOWNTO
                                24 - (build_index - 42) * 8);
                            WHEN 46 => byte_v := x"50"; -- data offset 5, no options
                            WHEN 47 => byte_v := tcp_flags;
                            WHEN 48 => byte_v := x"00";
                            WHEN 49 =>
                                IF tcp_rx_occupied(tcp_work_socket) = '1' THEN
                                    byte_v := x"00";
                                ELSE
                                    byte_v := x"80"; -- one complete ABI receive chunk
                                END IF;
                            WHEN 50 TO 53 => byte_v := x"00"; -- checksum + urgent pointer
                            WHEN 54 TO 181 =>
                                IF build_index - 54 < tcp_payload_length THEN
                                    byte_v := tcp_send_data_reg(tcp_work_socket)(1023 - (build_index - 54) * 8 DOWNTO
                                        1016 - (build_index - 54) * 8);
                                ELSE
                                    byte_v := x"00";
                                END IF;
                            WHEN OTHERS => byte_v := x"00"; -- Ethernet minimum padding
                        END CASE;
                        tx_buffer(build_index) <= byte_v;
                        IF (tcp_payload_length = 0 AND build_index = 59) OR
                            (tcp_payload_length /= 0 AND build_index = tx_length - 1) THEN
                            IF tcp_payload_length = 0 THEN
                                ip_total_length <= 40;
                            ELSE
                                ip_total_length <= 40 + tcp_payload_length;
                            END IF;
                            checksum_index <= 14;
                            checksum_end <= 34;
                            checksum_sum <= (OTHERS => '0');
                            checksum_mode <= 2;
                            state <= ST_IP_SUM;
                        ELSE
                            build_index <= build_index + 1;
                        END IF;

                    WHEN ST_COPY_ICMP =>
                        tx_buffer(build_index) <= rx_buffer(build_index);
                        IF build_index = tx_length - 1 THEN
                            state <= ST_PATCH_ICMP;
                        ELSE
                            build_index <= build_index + 1;
                        END IF;

                    WHEN ST_PATCH_ICMP =>
                        FOR i IN 0 TO 5 LOOP
                            tx_buffer(i) <= rx_buffer(6 + i);
                            tx_buffer(6 + i) <= mac_byte(i);
                        END LOOP;
                        FOR i IN 0 TO 3 LOOP
                            tx_buffer(26 + i) <= ip_byte(ipv4_address, i);
                            tx_buffer(30 + i) <= rx_buffer(26 + i);
                        END LOOP;
                        tx_buffer(22) <= x"40";
                        tx_buffer(24) <= x"00";
                        tx_buffer(25) <= x"00";
                        tx_buffer(34) <= x"00";
                        tx_buffer(36) <= x"00";
                        tx_buffer(37) <= x"00";
                        checksum_index <= 14;
                        checksum_end <= 34;
                        checksum_sum <= (OTHERS => '0');
                        checksum_mode <= 1;
                        state <= ST_IP_SUM;

                    WHEN ST_IP_SUM =>
                        word_v := UNSIGNED(tx_buffer(checksum_index)) & UNSIGNED(tx_buffer(checksum_index + 1));
                        checksum_sum <= checksum_sum + RESIZE(word_v, checksum_sum'LENGTH);
                        IF checksum_index + 2 >= checksum_end THEN
                            state <= ST_IP_FOLD1;
                        ELSE
                            checksum_index <= checksum_index + 2;
                        END IF;

                    WHEN ST_IP_FOLD1 =>
                        checksum_sum <= RESIZE(checksum_sum(15 DOWNTO 0), 32) + RESIZE(checksum_sum(31 DOWNTO 16), 32);
                        state <= ST_IP_FOLD2;
                    WHEN ST_IP_FOLD2 =>
                        checksum_sum <= RESIZE(checksum_sum(15 DOWNTO 0), 32) + RESIZE(checksum_sum(31 DOWNTO 16), 32);
                        state <= ST_IP_STORE;
                    WHEN ST_IP_STORE =>
                        tx_buffer(24) <= STD_LOGIC_VECTOR(NOT checksum_sum(15 DOWNTO 8));
                        tx_buffer(25) <= STD_LOGIC_VECTOR(NOT checksum_sum(7 DOWNTO 0));
                        IF checksum_mode = 1 THEN
                            checksum_index <= 34;
                            checksum_end <= 14 + ip_total_length;
                            checksum_sum <= (OTHERS => '0');
                            state <= ST_ICMP_SUM;
                        ELSIF checksum_mode = 2 THEN
                            checksum_index <= 0;
                            IF tcp_payload_length = 0 THEN
                                checksum_end <= 32;
                            ELSE
                                checksum_end <= 32 + tcp_payload_length;
                            END IF;
                            checksum_sum <= (OTHERS => '0');
                            state <= ST_TCP_SUM;
                        ELSE
                            tx_preamble_index <= 0;
                            tx_phase <= 0;
                            tx_crc <= (OTHERS => '1');
                            state <= ST_TX_PREAMBLE;
                        END IF;

                    WHEN ST_TCP_SUM =>
                        IF checksum_index < 8 THEN
                            word_v := UNSIGNED(tx_buffer(26 + checksum_index)) &
                                UNSIGNED(tx_buffer(27 + checksum_index));
                        ELSIF checksum_index = 8 THEN
                            word_v := x"0006";
                        ELSIF checksum_index = 10 THEN
                            IF tcp_payload_length = 0 THEN
                                word_v := x"0014";
                            ELSE
                                word_v := to_unsigned(20 + tcp_payload_length, 16);
                            END IF;
                        ELSE
                            IF checksum_index + 1 < checksum_end THEN
                                word_v := UNSIGNED(tx_buffer(22 + checksum_index)) &
                                    UNSIGNED(tx_buffer(23 + checksum_index));
                            ELSE
                                -- TCP checksums zero-pad an odd final payload
                                -- byte.  Do not include stale frame-buffer data
                                -- when the Ethernet frame itself needs no pad.
                                word_v := UNSIGNED(tx_buffer(22 + checksum_index)) &
                                    to_unsigned(0, 8);
                            END IF;
                        END IF;
                        checksum_sum <= checksum_sum + RESIZE(word_v, checksum_sum'LENGTH);
                        IF checksum_index + 2 >= checksum_end THEN
                            state <= ST_TCP_FOLD1;
                        ELSE
                            checksum_index <= checksum_index + 2;
                        END IF;
                    WHEN ST_TCP_FOLD1 =>
                        checksum_sum <= RESIZE(checksum_sum(15 DOWNTO 0), 32) +
                            RESIZE(checksum_sum(31 DOWNTO 16), 32);
                        state <= ST_TCP_FOLD2;
                    WHEN ST_TCP_FOLD2 =>
                        checksum_sum <= RESIZE(checksum_sum(15 DOWNTO 0), 32) +
                            RESIZE(checksum_sum(31 DOWNTO 16), 32);
                        state <= ST_TCP_STORE;
                    WHEN ST_TCP_STORE =>
                        tx_buffer(50) <= STD_LOGIC_VECTOR(NOT checksum_sum(15 DOWNTO 8));
                        tx_buffer(51) <= STD_LOGIC_VECTOR(NOT checksum_sum(7 DOWNTO 0));
                        IF tcp_payload_length = 0 THEN
                            build_index <= 60;
                        ELSE
                            build_index <= tx_length;
                        END IF;
                        tx_preamble_index <= 0;
                        tx_phase <= 0;
                        tx_crc <= (OTHERS => '1');
                        state <= ST_TX_PREAMBLE;

                    WHEN ST_ICMP_SUM =>
                        IF checksum_index + 1 < checksum_end THEN
                            word_v := UNSIGNED(tx_buffer(checksum_index)) & UNSIGNED(tx_buffer(checksum_index + 1));
                        ELSE
                            word_v := UNSIGNED(tx_buffer(checksum_index)) & to_unsigned(0, 8);
                        END IF;
                        checksum_sum <= checksum_sum + RESIZE(word_v, checksum_sum'LENGTH);
                        IF checksum_index + 2 >= checksum_end THEN
                            state <= ST_ICMP_FOLD1;
                        ELSE
                            checksum_index <= checksum_index + 2;
                        END IF;
                    WHEN ST_ICMP_FOLD1 =>
                        checksum_sum <= RESIZE(checksum_sum(15 DOWNTO 0), 32) + RESIZE(checksum_sum(31 DOWNTO 16), 32);
                        state <= ST_ICMP_FOLD2;
                    WHEN ST_ICMP_FOLD2 =>
                        checksum_sum <= RESIZE(checksum_sum(15 DOWNTO 0), 32) + RESIZE(checksum_sum(31 DOWNTO 16), 32);
                        state <= ST_ICMP_STORE;
                    WHEN ST_ICMP_STORE =>
                        tx_buffer(36) <= STD_LOGIC_VECTOR(NOT checksum_sum(15 DOWNTO 8));
                        tx_buffer(37) <= STD_LOGIC_VECTOR(NOT checksum_sum(7 DOWNTO 0));
                        build_index <= tx_length;
                        IF tx_length < 60 THEN
                            state <= ST_PAD;
                        ELSE
                            tx_preamble_index <= 0;
                            tx_phase <= 0;
                            tx_crc <= (OTHERS => '1');
                            state <= ST_TX_PREAMBLE;
                        END IF;

                    WHEN ST_PAD =>
                        tx_buffer(build_index) <= x"00";
                        IF build_index = 59 THEN
                            tx_length <= 60;
                            tx_preamble_index <= 0;
                            tx_phase <= 0;
                            tx_crc <= (OTHERS => '1');
                            state <= ST_TX_PREAMBLE;
                        ELSE
                            build_index <= build_index + 1;
                        END IF;

                    WHEN ST_TX_PREAMBLE =>
                        tx_en_reg <= '1';
                        IF tx_preamble_index = 7 THEN byte_v := x"D5"; ELSE byte_v := x"55"; END IF;
                        CASE tx_phase IS
                            WHEN 0 => txd_reg <= byte_v(1 DOWNTO 0); tx_phase <= 1;
                            WHEN 1 => txd_reg <= byte_v(3 DOWNTO 2); tx_phase <= 2;
                            WHEN 2 => txd_reg <= byte_v(5 DOWNTO 4); tx_phase <= 3;
                            WHEN OTHERS =>
                                txd_reg <= byte_v(7 DOWNTO 6);
                                tx_phase <= 0;
                                IF tx_preamble_index = 7 THEN
                                    tx_byte_index <= 0;
                                    state <= ST_TX_FRAME;
                                ELSE
                                    tx_preamble_index <= tx_preamble_index + 1;
                                END IF;
                        END CASE;

                    WHEN ST_TX_FRAME =>
                        byte_v := tx_buffer(tx_byte_index);
                        CASE tx_phase IS
                            WHEN 0 =>
                                txd_reg <= byte_v(1 DOWNTO 0);
                                tx_crc <= crc32_byte(tx_crc, byte_v);
                                tx_phase <= 1;
                            WHEN 1 => txd_reg <= byte_v(3 DOWNTO 2); tx_phase <= 2;
                            WHEN 2 => txd_reg <= byte_v(5 DOWNTO 4); tx_phase <= 3;
                            WHEN OTHERS =>
                                txd_reg <= byte_v(7 DOWNTO 6);
                                tx_phase <= 0;
                                IF tx_byte_index = tx_length - 1 THEN
                                    tx_crc_final <= NOT tx_crc;
                                    tx_crc_byte_index <= 0;
                                    state <= ST_TX_CRC;
                                ELSE
                                    tx_byte_index <= tx_byte_index + 1;
                                END IF;
                        END CASE;

                    WHEN ST_TX_CRC =>
                        byte_v := tx_crc_final(tx_crc_byte_index * 8 + 7 DOWNTO tx_crc_byte_index * 8);
                        CASE tx_phase IS
                            WHEN 0 => txd_reg <= byte_v(1 DOWNTO 0); tx_phase <= 1;
                            WHEN 1 => txd_reg <= byte_v(3 DOWNTO 2); tx_phase <= 2;
                            WHEN 2 => txd_reg <= byte_v(5 DOWNTO 4); tx_phase <= 3;
                            WHEN OTHERS =>
                                txd_reg <= byte_v(7 DOWNTO 6);
                                tx_phase <= 0;
                                IF tx_crc_byte_index = 3 THEN
                                    tx_gap_count <= 0;
                                    IF tx_buffer(12) = x"08" AND tx_buffer(13) = x"00" AND
                                        tx_buffer(23) = x"06" AND tx_buffer(47) = x"02" THEN
                                        debug_tcp_syn_tx_complete <= debug_tcp_syn_tx_complete + 1;
                                    END IF;
                                    IF tx_buffer(12) = x"08" AND tx_buffer(13) = x"00" AND
                                        tx_buffer(23) = x"06" THEN
                                        -- Payload is scoped to this transmitted segment.  It
                                        -- must never leak into a later ACK, FIN or reconnect SYN.
                                        tcp_payload_length <= 0;
                                    END IF;
                                    IF tcp_close_after_tx(tcp_work_socket) = '1' THEN
                                        tcp_close_after_tx(tcp_work_socket) <= '0';
                                        tcp_fin_waiting(tcp_work_socket) <= '0';
                                        tcp_status_reg(tcp_work_socket) <= x"00";
                                        tcp_timer(tcp_work_socket) <= 0;
                                    END IF;
                                    state <= ST_TX_GAP;
                                ELSE
                                    tx_crc_byte_index <= tx_crc_byte_index + 1;
                                END IF;
                        END CASE;

                    WHEN ST_TX_GAP =>
                        tx_en_reg <= '0';
                        txd_reg <= "00";
                        IF tx_gap_count = 47 THEN
                            state <= ST_IDLE;
                        ELSE
                            tx_gap_count <= tx_gap_count + 1;
                        END IF;
                    END CASE;
                END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;
