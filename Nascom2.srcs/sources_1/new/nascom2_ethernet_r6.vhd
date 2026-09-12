--------------------------------------------------------------------------------
-- MEGA65 R6 Ethernet shell: 100 MHz board clock to 50 MHz RMII, PHY management,
-- and the first-stage ARP/ICMP endpoint.
--------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

LIBRARY UNISIM;
USE UNISIM.VComponents.ALL;

ENTITY nascom2_ethernet_r6 IS
    PORT (
        clk100 : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        cpu_reset : IN STD_LOGIC;
        enable : IN STD_LOGIC;
        dhcp_enable : IN STD_LOGIC;
        ipv4_address : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        ipv4_netmask : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        ipv4_gateway : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        dns_server : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
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
        link_up : OUT STD_LOGIC;
        debug_counters : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        eth_mdio : INOUT STD_LOGIC;
        eth_mdc : OUT STD_LOGIC;
        eth_reset : OUT STD_LOGIC;
        eth_rxd : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        eth_txd : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        eth_txen : OUT STD_LOGIC;
        eth_rxdv : IN STD_LOGIC;
        eth_rxer : IN STD_LOGIC;
        eth_clock : OUT STD_LOGIC
    );
END ENTITY;

ARCHITECTURE rtl OF nascom2_ethernet_r6 IS
    SIGNAL clk50_unbuffered : STD_LOGIC := '0';
    SIGNAL clk50 : STD_LOGIC := '0';
    SIGNAL clk200_unbuffered : STD_LOGIC := '0';
    SIGNAL clk200 : STD_LOGIC := '0';
    SIGNAL clkfb_unbuffered : STD_LOGIC := '0';
    SIGNAL clkfb : STD_LOGIC := '0';
    SIGNAL mmcm_locked : STD_LOGIC := '0';
    SIGNAL reset50 : STD_LOGIC := '1';
    SIGNAL cpu_reset_meta : STD_LOGIC := '0';
    SIGNAL cpu_reset_sync : STD_LOGIC := '0';
    SIGNAL enable_meta : STD_LOGIC := '0';
    SIGNAL enable_sync : STD_LOGIC := '0';
    SIGNAL dhcp_enable_meta : STD_LOGIC := '0';
    SIGNAL dhcp_enable_sync : STD_LOGIC := '0';
    SIGNAL ipv4_meta : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ipv4_sync : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL netmask_meta : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL netmask_sync : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL gateway_meta : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL gateway_sync : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dns_meta : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dns_sync : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dns_query_toggle_meta : STD_LOGIC := '0';
    SIGNAL dns_query_toggle_sync : STD_LOGIC := '0';
    SIGNAL dns_query_length_meta : STD_LOGIC_VECTOR(6 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dns_query_length_sync : STD_LOGIC_VECTOR(6 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dns_query_data_meta : STD_LOGIC_VECTOR(511 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dns_query_data_sync : STD_LOGIC_VECTOR(511 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ping_toggle_meta : STD_LOGIC := '0';
    SIGNAL ping_toggle_sync : STD_LOGIC := '0';
    SIGNAL ping_ip_meta : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ping_ip_sync : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL link_up_internal : STD_LOGIC := '0';
    SIGNAL tcp_toggle_meta : STD_LOGIC := '0';
    SIGNAL tcp_toggle_sync : STD_LOGIC := '0';
    SIGNAL tcp_socket_meta : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL tcp_socket_sync : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL tcp_ip_meta : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tcp_ip_sync : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tcp_port_meta : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tcp_port_sync : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tcp_close_toggle_meta : STD_LOGIC := '0';
    SIGNAL tcp_close_toggle_sync : STD_LOGIC := '0';
    SIGNAL tcp_close_socket_meta : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL tcp_close_socket_sync : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL tcp_send_toggle_meta : STD_LOGIC := '0';
    SIGNAL tcp_send_toggle_sync : STD_LOGIC := '0';
    SIGNAL tcp_send_socket_meta : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL tcp_send_socket_sync : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL tcp_send_length_meta : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tcp_send_length_sync : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tcp_send_data_meta : STD_LOGIC_VECTOR(1023 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tcp_send_data_sync : STD_LOGIC_VECTOR(1023 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tcp_rx_consume_meta : STD_LOGIC := '0';
    SIGNAL tcp_rx_consume_sync : STD_LOGIC := '0';
    SIGNAL tcp_query_socket_meta : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL tcp_query_socket_sync : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL tcp_rx_consume_socket_meta : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL tcp_rx_consume_socket_sync : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
BEGIN
    u_mmcm : MMCME2_BASE
        GENERIC MAP (
            BANDWIDTH => "OPTIMIZED",
            CLKIN1_PERIOD => 10.0,
            DIVCLK_DIVIDE => 1,
            CLKFBOUT_MULT_F => 10.0,
            CLKOUT0_DIVIDE_F => 20.0,
            CLKOUT1_DIVIDE => 5,
            STARTUP_WAIT => FALSE
        )
        PORT MAP (
            CLKIN1 => clk100,
            CLKFBIN => clkfb,
            RST => reset,
            PWRDWN => '0',
            CLKFBOUT => clkfb_unbuffered,
            CLKOUT0 => clk50_unbuffered,
            CLKOUT1 => clk200_unbuffered,
            LOCKED => mmcm_locked
        );

    u_clkfb_bufg : BUFG PORT MAP (I => clkfb_unbuffered, O => clkfb);
    u_clk50_bufg : BUFG PORT MAP (I => clk50_unbuffered, O => clk50);
    u_clk200_bufg : BUFG PORT MAP (I => clk200_unbuffered, O => clk200);
    eth_clock <= clk50;
    reset50 <= reset OR NOT mmcm_locked;
    link_up <= link_up_internal;

    PROCESS (clk50)
    BEGIN
        IF rising_edge(clk50) THEN
            IF reset50 = '1' THEN
                cpu_reset_meta <= '0';
                cpu_reset_sync <= '0';
                enable_meta <= '0';
                enable_sync <= '0';
                dhcp_enable_meta <= '0';
                dhcp_enable_sync <= '0';
                ipv4_meta <= (OTHERS => '0');
                ipv4_sync <= (OTHERS => '0');
                netmask_meta <= (OTHERS => '0');
                netmask_sync <= (OTHERS => '0');
                gateway_meta <= (OTHERS => '0');
                gateway_sync <= (OTHERS => '0');
                dns_meta <= (OTHERS => '0');
                dns_sync <= (OTHERS => '0');
                dns_query_toggle_meta <= '0';
                dns_query_toggle_sync <= '0';
                dns_query_length_meta <= (OTHERS => '0');
                dns_query_length_sync <= (OTHERS => '0');
                dns_query_data_meta <= (OTHERS => '0');
                dns_query_data_sync <= (OTHERS => '0');
                ping_toggle_meta <= '0';
                ping_toggle_sync <= '0';
                ping_ip_meta <= (OTHERS => '0');
                ping_ip_sync <= (OTHERS => '0');
                tcp_toggle_meta <= '0';
                tcp_toggle_sync <= '0';
                tcp_socket_meta <= "00";
                tcp_socket_sync <= "00";
                tcp_ip_meta <= (OTHERS => '0');
                tcp_ip_sync <= (OTHERS => '0');
                tcp_port_meta <= (OTHERS => '0');
                tcp_port_sync <= (OTHERS => '0');
                tcp_close_toggle_meta <= '0';
                tcp_close_toggle_sync <= '0';
                tcp_close_socket_meta <= "00";
                tcp_close_socket_sync <= "00";
                tcp_send_toggle_meta <= '0';
                tcp_send_toggle_sync <= '0';
                tcp_send_socket_meta <= "00";
                tcp_send_socket_sync <= "00";
                tcp_send_length_meta <= (OTHERS => '0');
                tcp_send_length_sync <= (OTHERS => '0');
                tcp_send_data_meta <= (OTHERS => '0');
                tcp_send_data_sync <= (OTHERS => '0');
                tcp_rx_consume_meta <= '0';
                tcp_rx_consume_sync <= '0';
                tcp_query_socket_meta <= "00";
                tcp_query_socket_sync <= "00";
                tcp_rx_consume_socket_meta <= "00";
                tcp_rx_consume_socket_sync <= "00";
            ELSE
                cpu_reset_meta <= cpu_reset;
                cpu_reset_sync <= cpu_reset_meta;
                enable_meta <= enable;
                enable_sync <= enable_meta;
                dhcp_enable_meta <= dhcp_enable;
                dhcp_enable_sync <= dhcp_enable_meta;
                ipv4_meta <= ipv4_address;
                ipv4_sync <= ipv4_meta;
                netmask_meta <= ipv4_netmask;
                netmask_sync <= netmask_meta;
                gateway_meta <= ipv4_gateway;
                gateway_sync <= gateway_meta;
                dns_meta <= dns_server;
                dns_sync <= dns_meta;
                dns_query_toggle_meta <= dns_query_toggle;
                dns_query_toggle_sync <= dns_query_toggle_meta;
                dns_query_length_meta <= dns_query_length;
                dns_query_length_sync <= dns_query_length_meta;
                dns_query_data_meta <= dns_query_data;
                dns_query_data_sync <= dns_query_data_meta;
                ping_toggle_meta <= ping_start_toggle;
                ping_toggle_sync <= ping_toggle_meta;
                ping_ip_meta <= ping_target_ip;
                ping_ip_sync <= ping_ip_meta;
                tcp_toggle_meta <= tcp_connect_toggle;
                tcp_toggle_sync <= tcp_toggle_meta;
                tcp_socket_meta <= tcp_connect_socket;
                tcp_socket_sync <= tcp_socket_meta;
                tcp_ip_meta <= tcp_connect_ip;
                tcp_ip_sync <= tcp_ip_meta;
                tcp_port_meta <= tcp_connect_port;
                tcp_port_sync <= tcp_port_meta;
                tcp_close_toggle_meta <= tcp_close_toggle;
                tcp_close_toggle_sync <= tcp_close_toggle_meta;
                tcp_close_socket_meta <= tcp_close_socket;
                tcp_close_socket_sync <= tcp_close_socket_meta;
                tcp_send_toggle_meta <= tcp_send_toggle;
                tcp_send_toggle_sync <= tcp_send_toggle_meta;
                tcp_send_socket_meta <= tcp_send_socket;
                tcp_send_socket_sync <= tcp_send_socket_meta;
                tcp_send_length_meta <= tcp_send_length;
                tcp_send_length_sync <= tcp_send_length_meta;
                tcp_send_data_meta <= tcp_send_data;
                tcp_send_data_sync <= tcp_send_data_meta;
                tcp_rx_consume_meta <= tcp_rx_consume_toggle;
                tcp_rx_consume_sync <= tcp_rx_consume_meta;
                tcp_query_socket_meta <= tcp_query_socket;
                tcp_query_socket_sync <= tcp_query_socket_meta;
                tcp_rx_consume_socket_meta <= tcp_rx_consume_socket;
                tcp_rx_consume_socket_sync <= tcp_rx_consume_socket_meta;
            END IF;
        END IF;
    END PROCESS;

    u_mdio : ENTITY work.nascom2_mdio_link
        PORT MAP (
            clk50 => clk50,
            reset => reset50,
            enable => enable_sync,
            mdio => eth_mdio,
            mdc => eth_mdc,
            phy_reset_n => eth_reset,
            link_up => link_up_internal
        );

    u_ipv4 : ENTITY work.nascom2_ipv4_core
        PORT MAP (
            clk50 => clk50,
            clk200 => clk200,
            reset => reset50,
            tcp_abort => cpu_reset_sync,
            -- Do not start autonomous ARP/DNS traffic while the PHY is still
            -- negotiating.  The core's enable-low path resets its DNS timer,
            -- so the configured start delay begins at the real link-up edge.
            enable => enable_sync AND link_up_internal,
            dhcp_enable => dhcp_enable_sync,
            static_ipv4_address => ipv4_sync,
            static_ipv4_netmask => netmask_sync,
            static_ipv4_gateway => gateway_sync,
            static_dns_server => dns_sync,
            effective_ipv4_address => effective_ipv4_address,
            effective_ipv4_netmask => effective_ipv4_netmask,
            effective_ipv4_gateway => effective_ipv4_gateway,
            effective_dns_server => effective_dns_server,
            dhcp_status => dhcp_status,
            dns_query_toggle => dns_query_toggle_sync,
            dns_query_length => dns_query_length_sync,
            dns_query_data => dns_query_data_sync,
            ping_start_toggle => ping_toggle_sync,
            ping_target_ip => ping_ip_sync,
            ping_result => ping_result,
            tcp_connect_toggle => tcp_toggle_sync,
            tcp_connect_socket => tcp_socket_sync,
            tcp_connect_ip => tcp_ip_sync,
            tcp_connect_port => tcp_port_sync,
            tcp_close_toggle => tcp_close_toggle_sync,
            tcp_close_socket => tcp_close_socket_sync,
            tcp_send_toggle => tcp_send_toggle_sync,
            tcp_send_socket => tcp_send_socket_sync,
            tcp_send_length => tcp_send_length_sync,
            tcp_send_data => tcp_send_data_sync,
            tcp_tx_ready => tcp_tx_ready,
            tcp_rx_toggle => tcp_rx_toggle,
            tcp_rx_socket => tcp_rx_socket,
            tcp_rx_length => tcp_rx_length,
            tcp_rx_data => tcp_rx_data,
            tcp_query_socket => tcp_query_socket_sync,
            tcp_rx_consume_toggle => tcp_rx_consume_sync,
            tcp_rx_consume_socket => tcp_rx_consume_socket_sync,
            tcp_status => tcp_status,
            tcp_status_socket => tcp_status_socket,
            rmii_rxd => eth_rxd,
            rmii_crs_dv => eth_rxdv,
            rmii_rx_er => eth_rxer,
            rmii_txd => eth_txd,
            rmii_tx_en => eth_txen,
            debug_counters => debug_counters
        );
END ARCHITECTURE;
