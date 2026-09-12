--------------------------------------------------------------------------------
-- Z80-facing two-port network ABI shared by NASSYS and CP/M.
-- B8h: OUT command / IN status.  B9h: OUT parameter / IN response byte.
--------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY nascom2_network_ports IS
    GENERIC (
        G_CONTROL_PORT : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"B8";
        G_DATA_PORT : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"B9"
    );
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        available : IN STD_LOGIC;
        enabled : IN STD_LOGIC;
        link_up : IN STD_LOGIC;
        ipv4_address : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        ipv4_netmask : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        ipv4_gateway : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        dns_server : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        dns_result : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        dns_query_toggle : OUT STD_LOGIC;
        dns_query_length : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        dns_query_data : OUT STD_LOGIC_VECTOR(511 DOWNTO 0);
        ping_start_toggle : OUT STD_LOGIC;
        ping_target_ip : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        ping_result : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        io_addr : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        io_iorq_n : IN STD_LOGIC;
        io_rd_n : IN STD_LOGIC;
        io_wr_n : IN STD_LOGIC;
        io_data_out : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        tcp_status : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        tcp_status_socket : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        tcp_connect_toggle : OUT STD_LOGIC;
        tcp_connect_socket : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        tcp_connect_ip : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        tcp_connect_port : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        tcp_close_toggle : OUT STD_LOGIC;
        tcp_close_socket : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        tcp_send_toggle : OUT STD_LOGIC;
        tcp_send_socket : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        tcp_send_length : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        tcp_send_data : OUT STD_LOGIC_VECTOR(1023 DOWNTO 0);
        tcp_tx_ready : IN STD_LOGIC;
        tcp_rx_toggle : IN STD_LOGIC;
        tcp_rx_socket : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        tcp_rx_length : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        tcp_rx_data : IN STD_LOGIC_VECTOR(1023 DOWNTO 0);
        tcp_query_socket : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        tcp_rx_consume_toggle : OUT STD_LOGIC;
        tcp_rx_consume_socket : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        status_data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        response_data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE rtl OF nascom2_network_ports IS
    CONSTANT RESPONSE_SIZE : INTEGER := 130;
    CONSTANT PARAMETER_SIZE : INTEGER := 128;
    TYPE response_buffer_t IS ARRAY (0 TO RESPONSE_SIZE - 1) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    TYPE parameter_buffer_t IS ARRAY (0 TO PARAMETER_SIZE - 1) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    TYPE socket_ip_array_t IS ARRAY (0 TO 3) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
    TYPE socket_port_array_t IS ARRAY (0 TO 3) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL response_buffer : response_buffer_t := (OTHERS => (OTHERS => '0'));
    SIGNAL parameter_buffer : parameter_buffer_t := (OTHERS => (OTHERS => '0'));
    SIGNAL response_count : INTEGER RANGE 0 TO RESPONSE_SIZE := 0;
    SIGNAL response_index : INTEGER RANGE 0 TO RESPONSE_SIZE - 1 := 0;
    SIGNAL parameter_count : INTEGER RANGE 0 TO PARAMETER_SIZE := 0;
    SIGNAL io_wr_active : STD_LOGIC;
    SIGNAL io_rd_active : STD_LOGIC;
    SIGNAL io_wr_active_last : STD_LOGIC := '0';
    SIGNAL io_rd_data_active_last : STD_LOGIC := '0';
    SIGNAL dns_busy : STD_LOGIC;
    SIGNAL dns_ready : STD_LOGIC;
    SIGNAL dns_error : STD_LOGIC;
    SIGNAL response_ready : STD_LOGIC;
    SIGNAL selected_socket : INTEGER RANGE 0 TO 3 := 0;
    SIGNAL socket_ip : socket_ip_array_t := (OTHERS => (OTHERS => '0'));
    SIGNAL socket_port : socket_port_array_t := (OTHERS => (OTHERS => '0'));
    SIGNAL socket_configured : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tcp_connect_toggle_reg : STD_LOGIC := '0';
    SIGNAL tcp_connect_socket_reg : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL tcp_connect_ip_reg : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tcp_connect_port_reg : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tcp_close_toggle_reg : STD_LOGIC := '0';
    SIGNAL tcp_close_socket_reg : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL tcp_send_toggle_reg : STD_LOGIC := '0';
    SIGNAL tcp_send_socket_reg : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL tcp_send_length_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tcp_send_data_reg : STD_LOGIC_VECTOR(1023 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tcp_rx_seen : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL tcp_rx_consume_toggle_reg : STD_LOGIC := '0';
    SIGNAL tcp_rx_consume_socket_reg : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL dns_query_toggle_reg : STD_LOGIC := '0';
    SIGNAL dns_query_length_reg : STD_LOGIC_VECTOR(6 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dns_query_data_reg : STD_LOGIC_VECTOR(511 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ping_start_toggle_reg : STD_LOGIC := '0';
    SIGNAL ping_target_ip_reg : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');

    FUNCTION vector_byte(value_i : STD_LOGIC_VECTOR; index_i : INTEGER)
        RETURN STD_LOGIC_VECTOR IS
    BEGIN
        RETURN value_i(value_i'LEFT - index_i * 8 DOWNTO value_i'LEFT - 7 - index_i * 8);
    END FUNCTION;

    FUNCTION dns_status_code(value_i : STD_LOGIC_VECTOR(31 DOWNTO 0))
        RETURN STD_LOGIC_VECTOR IS
    BEGIN
        IF value_i = x"00000000" THEN RETURN x"01"; END IF; -- starting
        IF value_i = x"00000001" THEN RETURN x"02"; END IF; -- ARP
        IF value_i = x"00000002" THEN RETURN x"03"; END IF; -- DNS wait
        IF value_i(31 DOWNTO 16) = x"FF01" THEN RETURN x"E1"; END IF;
        IF value_i = x"FFFFFF02" THEN RETURN x"E2"; END IF;
        IF value_i = x"FFFFFF03" THEN RETURN x"E3"; END IF;
        RETURN x"00"; -- successful IPv4 A result
    END FUNCTION;
BEGIN
    tcp_connect_toggle <= tcp_connect_toggle_reg;
    tcp_connect_socket <= tcp_connect_socket_reg;
    tcp_connect_ip <= tcp_connect_ip_reg;
    tcp_connect_port <= tcp_connect_port_reg;
    tcp_close_toggle <= tcp_close_toggle_reg;
    tcp_close_socket <= tcp_close_socket_reg;
    tcp_send_toggle <= tcp_send_toggle_reg;
    tcp_send_socket <= tcp_send_socket_reg;
    tcp_send_length <= tcp_send_length_reg;
    tcp_send_data <= tcp_send_data_reg;
    tcp_rx_consume_toggle <= tcp_rx_consume_toggle_reg;
    dns_query_toggle <= dns_query_toggle_reg;
    dns_query_length <= dns_query_length_reg;
    dns_query_data <= dns_query_data_reg;
    ping_start_toggle <= ping_start_toggle_reg;
    ping_target_ip <= ping_target_ip_reg;
    tcp_query_socket <= STD_LOGIC_VECTOR(to_unsigned(selected_socket, 2));
    tcp_rx_consume_socket <= tcp_rx_consume_socket_reg;
    io_wr_active <= '1' WHEN io_iorq_n = '0' AND io_wr_n = '0' ELSE '0';
    io_rd_active <= '1' WHEN io_iorq_n = '0' AND io_rd_n = '0' ELSE '0';
    dns_busy <= '1' WHEN dns_result = x"00000000" OR dns_result = x"00000001" OR
        dns_result = x"00000002" ELSE '0';
    dns_error <= '1' WHEN dns_result(31 DOWNTO 24) = x"FF" ELSE '0';
    dns_ready <= '1' WHEN dns_busy = '0' AND dns_error = '0' ELSE '0';
    response_ready <= '1' WHEN response_count > 0 ELSE '0';

    -- Keep both CPU-visible values independent of the address bus.  Nascom2's
    -- existing I/O mux performs the B8/B9 decode.  This avoids making every
    -- memory access toggle the response-buffer mux and gives the T80 stable
    -- input data throughout the complete I/O read cycle.
    status_data <= available & link_up & enabled & response_ready & '1' &
        dns_ready & dns_busy & dns_error;
    response_data <= response_buffer(response_index)
        WHEN available = '1' AND response_count > 0 ELSE x"00";

    PROCESS (clk)
        VARIABLE command_v : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE loop_count_v : INTEGER;
    BEGIN
        IF rising_edge(clk) THEN
            IF reset = '1' OR available = '0' THEN
                response_buffer <= (OTHERS => (OTHERS => '0'));
                parameter_buffer <= (OTHERS => (OTHERS => '0'));
                response_count <= 0;
                response_index <= 0;
                parameter_count <= 0;
                io_wr_active_last <= '0';
                io_rd_data_active_last <= '0';
                selected_socket <= 0;
                socket_ip <= (OTHERS => (OTHERS => '0'));
                socket_port <= (OTHERS => (OTHERS => '0'));
                socket_configured <= (OTHERS => '0');
                tcp_connect_toggle_reg <= '0';
                tcp_connect_socket_reg <= "00";
                tcp_connect_ip_reg <= (OTHERS => '0');
                tcp_connect_port_reg <= (OTHERS => '0');
                tcp_close_toggle_reg <= '0';
                tcp_close_socket_reg <= "00";
                tcp_send_toggle_reg <= '0';
                tcp_send_socket_reg <= "00";
                tcp_send_length_reg <= (OTHERS => '0');
                tcp_send_data_reg <= (OTHERS => '0');
                tcp_rx_seen <= (OTHERS => tcp_rx_toggle);
                tcp_rx_consume_toggle_reg <= '0';
                tcp_rx_consume_socket_reg <= "00";
                dns_query_toggle_reg <= '0';
                dns_query_length_reg <= (OTHERS => '0');
                dns_query_data_reg <= (OTHERS => '0');
                ping_start_toggle_reg <= '0';
                ping_target_ip_reg <= (OTHERS => '0');
            ELSE
                -- A Z80 I/O strobe spans several 100 MHz clocks.  Capture a
                -- write once on its leading edge and consume a read once on
                -- its trailing edge, after the CPU has sampled the byte.
                IF io_wr_active_last = '0' AND io_wr_active = '1' THEN
                    IF io_addr = G_DATA_PORT THEN
                        IF parameter_count < PARAMETER_SIZE THEN
                            parameter_buffer(parameter_count) <= io_data_out;
                            parameter_count <= parameter_count + 1;
                        END IF;
                    ELSIF io_addr = G_CONTROL_PORT THEN
                        command_v := io_data_out;
                        response_index <= 0;
                        response_count <= 0;
                        CASE command_v IS
                            WHEN x"00" => -- reset/abort the CPU-side transaction
                                parameter_count <= 0;

                            WHEN x"01" => -- GET_INFO
                                response_buffer(0) <= x"4E"; -- N
                                response_buffer(1) <= x"32"; -- 2
                                response_buffer(2) <= x"04"; -- ABI version 4
                                response_buffer(3) <= x"0F"; -- ICMP + DNS + TCP stream I/O
                                response_count <= 4;

                            WHEN x"02" => -- GET_CONFIG
                                response_buffer(0) <= "000000" & enabled & link_up;
                                FOR i IN 0 TO 3 LOOP
                                    response_buffer(1 + i) <= vector_byte(ipv4_address, i);
                                    response_buffer(5 + i) <= vector_byte(ipv4_netmask, i);
                                    response_buffer(9 + i) <= vector_byte(ipv4_gateway, i);
                                    response_buffer(13 + i) <= vector_byte(dns_server, i);
                                END LOOP;
                                response_count <= 17;

                            WHEN x"03" => -- GET_DNS_RESULT
                                response_buffer(0) <= dns_status_code(dns_result);
                                FOR i IN 0 TO 3 LOOP
                                    response_buffer(1 + i) <= vector_byte(dns_result, i);
                                END LOOP;
                                response_count <= 5;

                            WHEN x"04" => -- START_DNS: wire-format QNAME, including final zero
                                IF parameter_count >= 3 AND parameter_count <= 64 AND
                                    parameter_buffer(parameter_count - 1) = x"00" AND
                                    enabled = '1' AND link_up = '1' THEN
                                    FOR i IN 0 TO 63 LOOP
                                        IF i < parameter_count THEN
                                            dns_query_data_reg(511 - i * 8 DOWNTO 504 - i * 8) <= parameter_buffer(i);
                                        ELSE
                                            dns_query_data_reg(511 - i * 8 DOWNTO 504 - i * 8) <= x"00";
                                        END IF;
                                    END LOOP;
                                    dns_query_length_reg <= STD_LOGIC_VECTOR(to_unsigned(parameter_count, 7));
                                    dns_query_toggle_reg <= NOT dns_query_toggle_reg;
                                    response_buffer(0) <= x"00";
                                ELSE
                                    response_buffer(0) <= x"E1";
                                END IF;
                                response_count <= 1;
                                parameter_count <= 0;

                            WHEN x"05" => -- START_PING: target IPv4, network byte order
                                IF parameter_count = 4 AND enabled = '1' AND link_up = '1' THEN
                                    ping_target_ip_reg <= parameter_buffer(0) & parameter_buffer(1) &
                                        parameter_buffer(2) & parameter_buffer(3);
                                    ping_start_toggle_reg <= NOT ping_start_toggle_reg;
                                    response_buffer(0) <= x"00";
                                ELSE
                                    response_buffer(0) <= x"E1";
                                END IF;
                                response_count <= 1;
                                parameter_count <= 0;

                            WHEN x"06" => -- GET_PING_RESULT
                                response_buffer(0) <= ping_result;
                                response_count <= 1;
                                parameter_count <= 0;

                            WHEN x"10" => -- SELECT_SOCKET: one byte, 0..3
                                IF parameter_count = 1 AND parameter_buffer(0)(7 DOWNTO 2) = "000000" THEN
                                    selected_socket <= to_integer(UNSIGNED(parameter_buffer(0)(1 DOWNTO 0)));
                                    response_buffer(0) <= x"00";
                                    response_buffer(1) <= parameter_buffer(0);
                                ELSE
                                    response_buffer(0) <= x"E1";
                                    response_buffer(1) <= STD_LOGIC_VECTOR(to_unsigned(parameter_count, 8));
                                END IF;
                                response_count <= 2;
                                parameter_count <= 0;

                            WHEN x"11" => -- CONFIG_SOCKET: IPv4 then TCP port, network byte order
                                IF parameter_count = 6 THEN
                                    socket_ip(selected_socket) <= parameter_buffer(0) & parameter_buffer(1) &
                                        parameter_buffer(2) & parameter_buffer(3);
                                    socket_port(selected_socket) <= parameter_buffer(4) & parameter_buffer(5);
                                    socket_configured(selected_socket) <= '1';
                                    response_buffer(0) <= x"00";
                                ELSE
                                    response_buffer(0) <= x"E1";
                                END IF;
                                response_count <= 1;
                                parameter_count <= 0;

                            WHEN x"12" => -- CONNECT selected socket
                                IF socket_configured(selected_socket) = '1' AND enabled = '1' AND link_up = '1' THEN
                                    -- A new connection starts a new byte stream.  Align the
                                    -- CPU marker so an unread toggle left by RESET/abort
                                    -- cannot cancel the first chunk of the new session.
                                    tcp_rx_seen(selected_socket) <= tcp_rx_toggle;
                                    tcp_connect_socket_reg <= STD_LOGIC_VECTOR(to_unsigned(selected_socket, 2));
                                    tcp_connect_ip_reg <= socket_ip(selected_socket);
                                    tcp_connect_port_reg <= socket_port(selected_socket);
                                    tcp_connect_toggle_reg <= NOT tcp_connect_toggle_reg;
                                    response_buffer(0) <= x"00";
                                ELSE
                                    response_buffer(0) <= x"E2";
                                END IF;
                                response_count <= 1;
                                parameter_count <= 0;

                            WHEN x"13" => -- GET_SOCKET_STATUS
                                response_buffer(0) <= STD_LOGIC_VECTOR(to_unsigned(selected_socket, 8));
                                IF tcp_status_socket = STD_LOGIC_VECTOR(to_unsigned(selected_socket, 2)) THEN
                                    response_buffer(1) <= tcp_status;
                                ELSIF socket_configured(selected_socket) = '1' THEN
                                    response_buffer(1) <= x"01"; -- configured, inactive
                                ELSE
                                    response_buffer(1) <= x"00"; -- closed/unconfigured
                                END IF;
                                FOR i IN 0 TO 3 LOOP
                                    response_buffer(2 + i) <= vector_byte(socket_ip(selected_socket), i);
                                END LOOP;
                                response_buffer(6) <= socket_port(selected_socket)(15 DOWNTO 8);
                                response_buffer(7) <= socket_port(selected_socket)(7 DOWNTO 0);
                                response_count <= 8;
                                parameter_count <= 0;

                            WHEN x"14" => -- SEND: 1..128 parameter bytes
                                IF parameter_count > 0 AND parameter_count <= 128 AND
                                    tcp_status_socket = STD_LOGIC_VECTOR(to_unsigned(selected_socket, 2)) AND
                                    tcp_status = x"03" AND tcp_tx_ready = '1' THEN
                                    tcp_send_socket_reg <= STD_LOGIC_VECTOR(to_unsigned(selected_socket, 2));
                                    tcp_send_length_reg <= STD_LOGIC_VECTOR(to_unsigned(parameter_count, 8));
                                    FOR i IN 0 TO 127 LOOP
                                        IF i < parameter_count THEN
                                            tcp_send_data_reg(1023 - i * 8 DOWNTO 1016 - i * 8) <= parameter_buffer(i);
                                        ELSE
                                            tcp_send_data_reg(1023 - i * 8 DOWNTO 1016 - i * 8) <= x"00";
                                        END IF;
                                    END LOOP;
                                    tcp_send_toggle_reg <= NOT tcp_send_toggle_reg;
                                    response_buffer(0) <= x"00";
                                    response_buffer(1) <= STD_LOGIC_VECTOR(to_unsigned(parameter_count, 8));
                                ELSE
                                    response_buffer(0) <= x"E3"; -- closed, busy or empty
                                    response_buffer(1) <= STD_LOGIC_VECTOR(to_unsigned(parameter_count, 8));
                                END IF;
                                response_count <= 2;
                                parameter_count <= 0;

                            WHEN x"15" => -- GET_RX_COUNT: status, pending byte count
                                response_buffer(0) <= x"00";
                                IF tcp_rx_toggle /= tcp_rx_seen(selected_socket) AND
                                    tcp_rx_socket = STD_LOGIC_VECTOR(to_unsigned(selected_socket, 2)) THEN
                                    response_buffer(1) <= tcp_rx_length;
                                ELSE
                                    response_buffer(1) <= x"00";
                                END IF;
                                response_count <= 2;
                                parameter_count <= 0;

                            WHEN x"16" => -- RECEIVE: status, length, then complete pending chunk
                                IF tcp_rx_toggle /= tcp_rx_seen(selected_socket) AND
                                    tcp_rx_socket = STD_LOGIC_VECTOR(to_unsigned(selected_socket, 2)) THEN
                                    response_buffer(0) <= x"00";
                                    response_buffer(1) <= tcp_rx_length;
                                    FOR i IN 0 TO 127 LOOP
                                        IF i < to_integer(UNSIGNED(tcp_rx_length)) THEN
                                            response_buffer(2 + i) <= tcp_rx_data(1023 - i * 8 DOWNTO 1016 - i * 8);
                                        END IF;
                                    END LOOP;
                                    response_count <= 2 + to_integer(UNSIGNED(tcp_rx_length));
                                    tcp_rx_seen(selected_socket) <= tcp_rx_toggle;
                                    tcp_rx_consume_socket_reg <= STD_LOGIC_VECTOR(to_unsigned(selected_socket, 2));
                                    tcp_rx_consume_toggle_reg <= NOT tcp_rx_consume_toggle_reg;
                                ELSE
                                    response_buffer(0) <= x"01"; -- no received data
                                    response_buffer(1) <= x"00";
                                    response_count <= 2;
                                END IF;
                                parameter_count <= 0;

                            WHEN x"17" => -- CLOSE selected socket (idempotent)
                                IF parameter_count = 0 AND socket_configured(selected_socket) = '1' THEN
                                    tcp_close_socket_reg <= STD_LOGIC_VECTOR(to_unsigned(selected_socket, 2));
                                    tcp_close_toggle_reg <= NOT tcp_close_toggle_reg;
                                    response_buffer(0) <= x"00";
                                ELSE
                                    response_buffer(0) <= x"E4";
                                END IF;
                                response_count <= 1;
                                parameter_count <= 0;

                            WHEN x"7F" => -- FIFO loopback/self-test
                                loop_count_v := parameter_count;
                                IF loop_count_v > PARAMETER_SIZE THEN
                                    loop_count_v := PARAMETER_SIZE;
                                END IF;
                                FOR i IN 0 TO PARAMETER_SIZE - 1 LOOP
                                    IF i < loop_count_v THEN
                                        response_buffer(i) <= parameter_buffer(i);
                                    END IF;
                                END LOOP;
                                response_count <= loop_count_v;
                                parameter_count <= 0;

                            WHEN OTHERS => -- stable unsupported-command response
                                response_buffer(0) <= x"EF";
                                response_buffer(1) <= command_v;
                                response_count <= 2;
                                parameter_count <= 0;
                        END CASE;
                    END IF;
                END IF;

                IF io_rd_data_active_last = '1' AND io_rd_active = '0' AND
                    response_count > 0 THEN
                    response_count <= response_count - 1;
                    IF response_count > 1 THEN
                        response_index <= response_index + 1;
                    ELSE
                        response_index <= 0;
                    END IF;
                END IF;

                io_wr_active_last <= io_wr_active;
                IF io_rd_active = '1' AND io_addr = G_DATA_PORT THEN
                    io_rd_data_active_last <= '1';
                ELSIF io_rd_active = '0' THEN
                    io_rd_data_active_last <= '0';
                END IF;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;
