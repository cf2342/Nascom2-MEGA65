LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
-- HDMI packet path ported unchanged from the known-good HDMItest project.
-- Serialization remains in hdmi_tx_selectio so the R6 pin/clock path stays
-- identical to the already hardware-tested DVI build.
ENTITY hdmi_proven_tx IS
    PORT (
        ----------------------------------------------------------------
        -- Clocks
        ----------------------------------------------------------------
        PixelClk : IN STD_LOGIC; -- 40 MHz
        reset : IN STD_LOGIC;

        audio_enable : IN STD_LOGIC;
        pcm_l : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        pcm_r : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        pcm_valid : IN STD_LOGIC;

        ----------------------------------------------------------------
        -- Video input
        ----------------------------------------------------------------
        red : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        green : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        blue : IN STD_LOGIC_VECTOR(7 DOWNTO 0);

        hsync : IN STD_LOGIC;
        vsync : IN STD_LOGIC;
        de : IN STD_LOGIC;

        x_pos : IN unsigned(10 DOWNTO 0);
        y_pos : IN unsigned(9 DOWNTO 0);

        ----------------------------------------------------------------
        -- Parallel HDMI/TMDS symbols, channel 0 = blue, 1 = green, 2 = red
        ----------------------------------------------------------------
        tmds_ch0 : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
        tmds_ch1 : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
        tmds_ch2 : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
    );
END ENTITY hdmi_proven_tx;
ARCHITECTURE rtl OF hdmi_proven_tx IS

    --------------------------------------------------------------------
    -- Types
    --------------------------------------------------------------------

    TYPE data8_array_t IS ARRAY (0 TO 2)
    OF STD_LOGIC_VECTOR(7 DOWNTO 0);

    TYPE data10_array_t IS ARRAY (0 TO 2)
    OF STD_LOGIC_VECTOR(9 DOWNTO 0);

    TYPE nibble_array_t IS ARRAY (0 TO 2)
    OF STD_LOGIC_VECTOR(3 DOWNTO 0);

    TYPE nibble_pipe_t IS ARRAY (0 TO 2)
    OF nibble_array_t;
    --------------------------------------------------------------------
    -- Normal TMDS video/control path
    --
    -- Channel 0 = Blue
    -- Channel 1 = Green
    -- Channel 2 = Red
    --------------------------------------------------------------------

    SIGNAL pixel_data : data8_array_t;
    SIGNAL encoded : data10_array_t;
    SIGNAL tx_word : data10_array_t;

    SIGNAL ctrl_c0 : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL ctrl_c1 : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL vde_ch : STD_LOGIC_VECTOR(2 DOWNTO 0);
    --------------------------------------------------------------------
    -- HDMI periods
    --------------------------------------------------------------------

    SIGNAL video_preamble : STD_LOGIC;
    SIGNAL video_guard : STD_LOGIC;

    SIGNAL data_preamble : STD_LOGIC;
    SIGNAL data_guard : STD_LOGIC;
    SIGNAL data_island : STD_LOGIC;
    --------------------------------------------------------------------
    -- Pipeline compensation
    --
    -- Digilent TMDS_Encoder has a pipelined output.
    -- Fixed/TERC4 symbols bypass that encoder, therefore their mode
    -- information and data must be delayed accordingly.
    --------------------------------------------------------------------

    SIGNAL video_guard_pipe :
    STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');

    SIGNAL data_guard_pipe :
    STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');

    SIGNAL data_island_pipe :
    STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    --------------------------------------------------------------------
    -- TERC4 path
    --------------------------------------------------------------------

    SIGNAL terc4_nibble_now :
    nibble_array_t;

    SIGNAL terc4_nibble_pipe :
    nibble_pipe_t :=
        (OTHERS => (OTHERS => (OTHERS => '0')));

    SIGNAL terc4_encoded :
    data10_array_t;
    --------------------------------------------------------------------
    -- HDMI packet assembler output
    --------------------------------------------------------------------

    SIGNAL packet_header_bit :
    STD_LOGIC;

    SIGNAL packet_body_ch1 :
    STD_LOGIC_VECTOR(3 DOWNTO 0);

    SIGNAL packet_body_ch2 :
    STD_LOGIC_VECTOR(3 DOWNTO 0);

    SIGNAL packet_index :
    unsigned(4 DOWNTO 0);

    SIGNAL packet_marker :
    STD_LOGIC;
    --------------------------------------------------------------------
    -- Packet selected for transmission
    --------------------------------------------------------------------

    SIGNAL packet_header :
    STD_LOGIC_VECTOR(23 DOWNTO 0);

    SIGNAL packet_sub0 :
    STD_LOGIC_VECTOR(55 DOWNTO 0);

    SIGNAL packet_sub1 :
    STD_LOGIC_VECTOR(55 DOWNTO 0);

    SIGNAL packet_sub2 :
    STD_LOGIC_VECTOR(55 DOWNTO 0);

    SIGNAL packet_sub3 :
    STD_LOGIC_VECTOR(55 DOWNTO 0);
    --------------------------------------------------------------------
    -- AVI InfoFrame
    --------------------------------------------------------------------

    SIGNAL avi_header :
    STD_LOGIC_VECTOR(23 DOWNTO 0);

    SIGNAL avi_sub0 :
    STD_LOGIC_VECTOR(55 DOWNTO 0);

    SIGNAL avi_sub1 :
    STD_LOGIC_VECTOR(55 DOWNTO 0);

    SIGNAL avi_sub2 :
    STD_LOGIC_VECTOR(55 DOWNTO 0);

    SIGNAL avi_sub3 :
    STD_LOGIC_VECTOR(55 DOWNTO 0);
    --------------------------------------------------------------------
    -- Audio Clock Regeneration packet
    --------------------------------------------------------------------

    SIGNAL acr_header :
    STD_LOGIC_VECTOR(23 DOWNTO 0);

    SIGNAL acr_sub0 :
    STD_LOGIC_VECTOR(55 DOWNTO 0);

    SIGNAL acr_sub1 :
    STD_LOGIC_VECTOR(55 DOWNTO 0);

    SIGNAL acr_sub2 :
    STD_LOGIC_VECTOR(55 DOWNTO 0);

    SIGNAL acr_sub3 :
    STD_LOGIC_VECTOR(55 DOWNTO 0);
    --------------------------------------------------------------------
    -- Packet scheduler
    --
    -- ACR:
    --     fs   = 48 kHz
    --     N    = 6144
    --
    -- Nominal ACR rate:
    --
    --     128 * fs / N
    --   = 128 * 48000 / 6144
    --   = 1000 packets/second
    --
    -- At 40 MHz:
    --
    --     40 MHz / 1000 = 40000 PixelClks
    --------------------------------------------------------------------

    SIGNAL acr_counter :
    unsigned(15 DOWNTO 0) := (OTHERS => '0');

    SIGNAL acr_due :
    STD_LOGIC := '1';

    SIGNAL send_acr_line :
    STD_LOGIC := '0';

    SIGNAL send_avi_line :
    STD_LOGIC;

    SIGNAL packet_this_line :
    STD_LOGIC;
    --------------------------------------------------------------------
    -- HDMI Video Guard Band
    --------------------------------------------------------------------

    CONSTANT VIDEO_GUARD_CH0 :
    STD_LOGIC_VECTOR(9 DOWNTO 0) :=
    "1011001100";

    CONSTANT VIDEO_GUARD_CH1 :
    STD_LOGIC_VECTOR(9 DOWNTO 0) :=
    "0100110011";

    CONSTANT VIDEO_GUARD_CH2 :
    STD_LOGIC_VECTOR(9 DOWNTO 0) :=
    "1011001100";
    --------------------------------------------------------------------
    -- HDMI Data Island Guard Band
    --
    -- Channel 0 is TERC4 encoded from:
    --
    --     11 VSYNC HSYNC
    --
    -- Channels 1 and 2 use a fixed symbol.
    --------------------------------------------------------------------

    CONSTANT DATA_GUARD_CH1 :
    STD_LOGIC_VECTOR(9 DOWNTO 0) :=
    "0100110011";

    CONSTANT DATA_GUARD_CH2 :
    STD_LOGIC_VECTOR(9 DOWNTO 0) :=
    "0100110011";

    --------------------------------------------------------------------
    -- Audio InfoFrame
    --------------------------------------------------------------------

    SIGNAL audio_header :
    STD_LOGIC_VECTOR(23 DOWNTO 0);

    SIGNAL audio_sub0 :
    STD_LOGIC_VECTOR(55 DOWNTO 0);

    SIGNAL audio_sub1 :
    STD_LOGIC_VECTOR(55 DOWNTO 0);

    SIGNAL audio_sub2 :
    STD_LOGIC_VECTOR(55 DOWNTO 0);

    SIGNAL audio_sub3 :
    STD_LOGIC_VECTOR(55 DOWNTO 0);
    SIGNAL send_audio_line :
    STD_LOGIC;

    --------------------------------------------------------------------
    -- Audio Sample Packet
    --------------------------------------------------------------------

    SIGNAL audio_sample_header :
    STD_LOGIC_VECTOR(23 DOWNTO 0);

    SIGNAL audio_sample_sub0 :
    STD_LOGIC_VECTOR(55 DOWNTO 0);

    SIGNAL audio_sample_sub1 :
    STD_LOGIC_VECTOR(55 DOWNTO 0);

    SIGNAL audio_sample_sub2 :
    STD_LOGIC_VECTOR(55 DOWNTO 0);

    SIGNAL audio_sample_sub3 :
    STD_LOGIC_VECTOR(55 DOWNTO 0);
    --------------------------------------------------------------------
    -- Four-sample PCM packet buffer
    --------------------------------------------------------------------

    SUBTYPE sample16_t IS
    STD_LOGIC_VECTOR(15 DOWNTO 0);

    SIGNAL audio_frame_counter :
    unsigned(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL sample_l0, sample_r0 :
    sample16_t;

    SIGNAL sample_l1, sample_r1 :
    sample16_t;

    SIGNAL sample_l2, sample_r2 :
    sample16_t;

    SIGNAL sample_l3, sample_r3 :
    sample16_t;
    --------------------------------------------------------------------
    -- Audio packet scheduler
    --
    -- Four samples per packet:
    --
    -- 48000 / 4 = 12000 packets/s
    --------------------------------------------------------------------

    SIGNAL audio_capture_index :
    INTEGER RANGE 0 TO 3 := 0;

    SIGNAL capture_l0, capture_r0 : sample16_t := (OTHERS => '0');
    SIGNAL capture_l1, capture_r1 : sample16_t := (OTHERS => '0');
    SIGNAL capture_l2, capture_r2 : sample16_t := (OTHERS => '0');

    TYPE sample_bank_t IS ARRAY (0 TO 3) OF sample16_t;
    SIGNAL packet_l_bank0 : sample_bank_t := (OTHERS => (OTHERS => '0'));
    SIGNAL packet_r_bank0 : sample_bank_t := (OTHERS => (OTHERS => '0'));
    SIGNAL packet_l_bank1 : sample_bank_t := (OTHERS => (OTHERS => '0'));
    SIGNAL packet_r_bank1 : sample_bank_t := (OTHERS => (OTHERS => '0'));
    SIGNAL packet_write_bank : STD_LOGIC := '0';
    SIGNAL packet_read_bank : STD_LOGIC := '0';

    SIGNAL audio_pending :
    INTEGER RANGE 0 TO 2 := 0;

    SIGNAL send_audio_sample_line :
    STD_LOGIC := '0';
BEGIN

    sample_l0 <= packet_l_bank0(0) WHEN packet_read_bank = '0' ELSE packet_l_bank1(0);
    sample_r0 <= packet_r_bank0(0) WHEN packet_read_bank = '0' ELSE packet_r_bank1(0);
    sample_l1 <= packet_l_bank0(1) WHEN packet_read_bank = '0' ELSE packet_l_bank1(1);
    sample_r1 <= packet_r_bank0(1) WHEN packet_read_bank = '0' ELSE packet_r_bank1(1);
    sample_l2 <= packet_l_bank0(2) WHEN packet_read_bank = '0' ELSE packet_l_bank1(2);
    sample_r2 <= packet_r_bank0(2) WHEN packet_read_bank = '0' ELSE packet_r_bank1(2);
    sample_l3 <= packet_l_bank0(3) WHEN packet_read_bank = '0' ELSE packet_l_bank1(3);
    sample_r3 <= packet_r_bank0(3) WHEN packet_read_bank = '0' ELSE packet_r_bank1(3);

    --------------------------------------------------------------------
    -- RGB -> TMDS channel assignment
    --------------------------------------------------------------------

    pixel_data(0) <= blue;
    pixel_data(1) <= green;
    pixel_data(2) <= red;

    vde_ch <= (OTHERS => de);
    --------------------------------------------------------------------
    -- AVI InfoFrame generator
    --------------------------------------------------------------------

    avi_packet : ENTITY work.avi_infoframe
        PORT MAP(
            header => avi_header,

            sub0 => avi_sub0,
            sub1 => avi_sub1,
            sub2 => avi_sub2,
            sub3 => avi_sub3
        );
    --------------------------------------------------------------------
    -- Audio Clock Regeneration packet generator
    --
    -- 48 kHz:
    --
    --     N   = 6144
    --     CTS = 40000
    --------------------------------------------------------------------

    acr_packet : ENTITY work.audio_clock_regeneration
        PORT MAP(
            header => acr_header,

            sub0 => acr_sub0,
            sub1 => acr_sub1,
            sub2 => acr_sub2,
            sub3 => acr_sub3
        );

    --------------------------------------------------------------------
    -- Audio InfoFrame generator
    --
    -- 2-channel LPCM
    -- 48 kHz
    -- 16 bit
    --------------------------------------------------------------------

    audio_packet : ENTITY work.audio_infoframe
        PORT MAP(
            header => audio_header,

            sub0 => audio_sub0,
            sub1 => audio_sub1,
            sub2 => audio_sub2,
            sub3 => audio_sub3
        );

    --------------------------------------------------------------------
    -- Samples are captured at 48 kHz by the scheduler below.  A completed
    -- four-sample group remains stable for the whole HDMI data island.
    --------------------------------------------------------------------

    --------------------------------------------------------------------
    -- ACR timing
    --
    -- Every 40000 PixelClks an ACR packet becomes due.
    --
    -- "due" does NOT mean that transmission starts immediately.
    -- Actual transmission waits until a suitable complete video line.
    --------------------------------------------------------------------

    PROCESS (PixelClk)
    BEGIN
        IF rising_edge(PixelClk) THEN

            IF reset = '1' THEN

                acr_counter <= (OTHERS => '0');

                -- Send an ACR packet soon after startup
                acr_due <= '1';

            ELSE

                --------------------------------------------------------
                -- New ACR value becomes due every 1 ms
                --------------------------------------------------------

                IF acr_counter = 39999 THEN

                    acr_counter <= (OTHERS => '0');
                    acr_due <= '1';

                ELSE

                    acr_counter <= acr_counter + 1;

                END IF;
                --------------------------------------------------------
                -- Packet transmission complete
                --
                -- Actual 32-pixel packet:
                --
                -- x = 982 .. 1013
                --------------------------------------------------------

                IF (
                    send_acr_line = '1' AND
                    to_integer(x_pos) = 1013
                    ) THEN

                    acr_due <= '0';

                END IF;

            END IF;

        END IF;
    END PROCESS;
    --------------------------------------------------------------------
    -- ACR line scheduler
    --
    -- At the BEGINNING of a video line we decide whether the complete
    -- line will contain an ACR packet.
    --
    -- The decision then stays stable until the next line.
    --
    -- y=627 is reserved for the AVI InfoFrame.
    --------------------------------------------------------------------

    PROCESS (PixelClk)
    BEGIN
        IF rising_edge(PixelClk) THEN

            IF reset = '1' THEN

                send_acr_line <= '0';

            ELSIF to_integer(x_pos) = 0 THEN

                IF (
                    acr_due = '1' AND
                    to_integer(y_pos) /= 626 AND
                    to_integer(y_pos) /= 627
                    ) THEN

                    send_acr_line <= '1';

                ELSE

                    send_acr_line <= '0';

                END IF;

            END IF;

        END IF;
    END PROCESS;

    --------------------------------------------------------------------
-- Audio Sample Packet line scheduler
--
-- Decide at the beginning of each line whether this line carries
-- one Audio Sample Packet.
--
-- Priority:
--
--   ACR has priority over Audio Sample Packets.
--
-- Lines:
--
--   y = 626   Audio InfoFrame
--   y = 627   AVI InfoFrame
--
-- are reserved.
--------------------------------------------------------------------

PROCESS (PixelClk)
BEGIN
    IF rising_edge(PixelClk) THEN

        IF reset = '1' THEN

            send_audio_sample_line <= '0';

        ELSIF to_integer(x_pos) = 0 THEN

            IF (
                audio_pending > 0 AND
                acr_due = '0' AND
                to_integer(y_pos) /= 626 AND
                to_integer(y_pos) /= 627
            ) THEN

                send_audio_sample_line <= '1';

            ELSE

                send_audio_sample_line <= '0';

            END IF;

        END IF;

    END IF;
END PROCESS;
    --------------------------------------------------------------------
    -- AVI InfoFrame is transmitted once per frame.
    --
    -- y=627 is the final line before y wraps to zero.
    --------------------------------------------------------------------

    send_avi_line <=
        '1'
        WHEN to_integer(y_pos) = 627
        ELSE
        '0';
    --------------------------------------------------------------------
    -- Does this line contain any HDMI Data Island packet?
    --------------------------------------------------------------------

    packet_this_line <=
        send_acr_line OR
        send_audio_sample_line OR
        send_audio_line OR
        send_avi_line;

    --------------------------------------------------------------------
    -- Actual LPCM Audio Sample Packet
    --------------------------------------------------------------------

    audio_samples : ENTITY work.audio_sample_packet
        PORT MAP(
            frame_counter => audio_frame_counter,

            sample_l0 => sample_l0,
            sample_r0 => sample_r0,

            sample_l1 => sample_l1,
            sample_r1 => sample_r1,

            sample_l2 => sample_l2,
            sample_r2 => sample_r2,

            sample_l3 => sample_l3,
            sample_r3 => sample_r3,

            header => audio_sample_header,

            sub0 => audio_sample_sub0,
            sub1 => audio_sample_sub1,
            sub2 => audio_sample_sub2,
            sub3 => audio_sample_sub3
        );
    --------------------------------------------------------------------
    -- Packet multiplexer
    --
    -- ACR has priority when send_acr_line is active.
    --
    -- y=627 can never have send_acr_line=1, so AVI is selected there.
    --------------------------------------------------------------------

    packet_header <=
        acr_header
        WHEN send_acr_line = '1'
        ELSE
        audio_sample_header
        WHEN send_audio_sample_line = '1'
        ELSE
        audio_header
        WHEN send_audio_line = '1'
        ELSE
        avi_header;
    packet_sub0 <=
        acr_sub0
        WHEN send_acr_line = '1'
        ELSE
        audio_sample_sub0
        WHEN send_audio_sample_line = '1'
        ELSE
        audio_sub0
        WHEN send_audio_line = '1'
        ELSE
        avi_sub0;
    packet_sub1 <=
        acr_sub1
        WHEN send_acr_line = '1'
        ELSE
        audio_sample_sub1
        WHEN send_audio_sample_line = '1'
        ELSE
        audio_sub1
        WHEN send_audio_line = '1'
        ELSE
        avi_sub1;
    packet_sub2 <=
        acr_sub2
        WHEN send_acr_line = '1'
        ELSE
        audio_sample_sub2
        WHEN send_audio_sample_line = '1'
        ELSE
        audio_sub2
        WHEN send_audio_line = '1'
        ELSE
        avi_sub2;
    packet_sub3 <=
        acr_sub3
        WHEN send_acr_line = '1'
        ELSE
        audio_sample_sub3
        WHEN send_audio_sample_line = '1'
        ELSE
        audio_sub3
        WHEN send_audio_line = '1'
        ELSE
        avi_sub3;

    --------------------------------------------------------------------
    -- HDMI Data Island placement
    --
    -- 800x600:
    --
    -- Active video:
    --
    --       0 .. 799
    --
    -- Horizontal blanking:
    --
    --     800 .. 971    Control
    --
    --     972 .. 979    Data Island Preamble   8 clocks
    --     980 .. 981    Leading Guard Band     2 clocks
    --     982 .. 1013   Packet                 32 clocks
    --    1014 .. 1015   Trailing Guard Band    2 clocks
    --
    --    1016 .. 1045   Control
    --
    --    1046 .. 1053   Video Preamble         8 clocks
    --    1054 .. 1055   Video Guard Band       2 clocks
    --------------------------------------------------------------------

    data_preamble <=
        '1'
        WHEN (
        packet_this_line = '1' AND
        to_integer(x_pos) >= 972 AND
        to_integer(x_pos) <= 979
        )
        ELSE
        '0';
    data_guard <=
        '1'
        WHEN (
        packet_this_line = '1' AND
        (
        (
        to_integer(x_pos) >= 980 AND
        to_integer(x_pos) <= 981
        )
        OR
        (
        to_integer(x_pos) >= 1014 AND
        to_integer(x_pos) <= 1015
        )
        )
        )
        ELSE
        '0';
    data_island <=
        '1'
        WHEN (
        packet_this_line = '1' AND
        to_integer(x_pos) >= 982 AND
        to_integer(x_pos) <= 1013
        )
        ELSE
        '0';
    --------------------------------------------------------------------
    -- Video Preamble
    --
    -- Only before a line whose NEXT line is active video:
    --
    -- y=0..598 -> next line 1..599
    -- y=627    -> next line 0
    --------------------------------------------------------------------

    video_preamble <=
        '1'
        WHEN (
        to_integer(x_pos) >= 1046 AND
        to_integer(x_pos) <= 1053 AND
        (
        to_integer(y_pos) < 599 OR
        to_integer(y_pos) = 627
        )
        )
        ELSE
        '0';
    --------------------------------------------------------------------
    -- Video Guard Band
    --------------------------------------------------------------------

    video_guard <=
        '1'
        WHEN (
        to_integer(x_pos) >= 1054 AND
        to_integer(x_pos) <= 1055 AND
        (
        to_integer(y_pos) < 599 OR
        to_integer(y_pos) = 627
        )
        )
        ELSE
        '0';
    --------------------------------------------------------------------
    -- HDMI control bits
    --
    -- Channel 0:
    --
    --     C0 = HSYNC
    --     C1 = VSYNC
    --
    -- Channel 1:
    --
    --     C0 = CTL0
    --     C1 = CTL1
    --
    -- Channel 2:
    --
    --     C0 = CTL2
    --     C1 = CTL3
    --
    --
    -- Video Preamble:
    --
    --     CTL3..0 = 0001
    --
    -- Data Island Preamble:
    --
    --     CTL3..0 = 0101
    --------------------------------------------------------------------

    ctrl_c0(0) <= hsync;
    ctrl_c1(0) <= vsync;

    -- CTL0
    ctrl_c0(1) <=
    video_preamble OR data_preamble;

    -- CTL1
    ctrl_c1(1) <=
    '0';

    -- CTL2
    ctrl_c0(2) <=
    data_preamble;

    -- CTL3
    ctrl_c1(2) <=
    '0';
    --------------------------------------------------------------------
    -- HDMI Packet Assembler
    --
    -- Converts:
    --
    --     HB0..HB2
    --     PB0..PB27
    --
    -- into the 32-character Data Island representation including BCH.
    --------------------------------------------------------------------

    packet_assembler : ENTITY work.hdmi_packet_assembler
        PORT MAP(
            PixelClk => PixelClk,
            reset => reset,

            data_island => data_island,

            header => packet_header,

            sub0 => packet_sub0,
            sub1 => packet_sub1,
            sub2 => packet_sub2,
            sub3 => packet_sub3,

            header_bit => packet_header_bit,

            body_ch1 => packet_body_ch1,
            body_ch2 => packet_body_ch2,

            packet_index => packet_index
        );
    --------------------------------------------------------------------
    -- Packet marker
    --
    -- During Data Island:
    --
    --     first character  D3 = 0
    --     remaining        D3 = 1
    --------------------------------------------------------------------

    packet_marker <=
        '0'
        WHEN packet_index = 0
        ELSE
        '1';

    --------------------------------------------------------------------
    -- Audio InfoFrame once per frame
    --------------------------------------------------------------------

    send_audio_line <=
        '1'
        WHEN to_integer(y_pos) = 626
        ELSE
        '0';

    --------------------------------------------------------------------
    -- Generate current TERC4 input nibbles
    --------------------------------------------------------------------

    PROCESS (ALL)
    BEGIN

        --------------------------------------------------------------
        -- Defaults
        --------------------------------------------------------------

        terc4_nibble_now(0) <= "0000";
        terc4_nibble_now(1) <= "0000";
        terc4_nibble_now(2) <= "0000";
        --------------------------------------------------------------
        -- Data Island Guard Band
        --
        -- Channel 0:
        --
        --     D3 = 1
        --     D2 = 1
        --     D1 = VSYNC
        --     D0 = HSYNC
        --------------------------------------------------------------

        IF data_guard = '1' THEN

            terc4_nibble_now(0) <=
            "11" & vsync & hsync;
            --------------------------------------------------------------
            -- Data Island
            --------------------------------------------------------------

        ELSIF data_island = '1' THEN

            ----------------------------------------------------------
            -- Channel 0
            --
            -- D3 = packet marker
            -- D2 = packet header bit
            -- D1 = VSYNC
            -- D0 = HSYNC
            ----------------------------------------------------------

            terc4_nibble_now(0) <=
            packet_marker &
            packet_header_bit &
            vsync &
            hsync;
            ----------------------------------------------------------
            -- Channels 1 and 2 carry the four packet substreams.
            ----------------------------------------------------------

            terc4_nibble_now(1) <=
            packet_body_ch1;

            terc4_nibble_now(2) <=
            packet_body_ch2;

        END IF;

    END PROCESS;
    --------------------------------------------------------------------
    -- Pipeline HDMI bypass paths
    --
    -- Align them to the output latency of TMDS_Encoder.
    --------------------------------------------------------------------

    PROCESS (PixelClk)
    BEGIN
        IF rising_edge(PixelClk) THEN

            IF reset = '1' THEN

                video_guard_pipe <=
                    (OTHERS => '0');

                data_guard_pipe <=
                    (OTHERS => '0');

                data_island_pipe <=
                    (OTHERS => '0');

                terc4_nibble_pipe <=
                    (OTHERS => (OTHERS => (OTHERS => '0')));

            ELSE

                --------------------------------------------------------
                -- Mode pipeline
                --------------------------------------------------------

                video_guard_pipe <=
                    video_guard_pipe(1 DOWNTO 0) &
                    video_guard;

                data_guard_pipe <=
                    data_guard_pipe(1 DOWNTO 0) &
                    data_guard;

                data_island_pipe <=
                    data_island_pipe(1 DOWNTO 0) &
                    data_island;
                --------------------------------------------------------
                -- TERC4 input pipeline
                --------------------------------------------------------

                terc4_nibble_pipe(0) <=
                terc4_nibble_now;

                terc4_nibble_pipe(1) <=
                terc4_nibble_pipe(0);

                terc4_nibble_pipe(2) <=
                terc4_nibble_pipe(1);

            END IF;

        END IF;
    END PROCESS;

    --------------------------------------------------------------------
    -- Audio Sample Packet timing
    --
    -- Pixel clock = 40 MHz
    --
    -- pcm_valid presents coherent 48-kHz samples from the source clock
    -- domain. Every fourth sample is queued as one HDMI Audio Sample Packet.
    -- Two packet banks ensure that a packet being transmitted cannot be
    -- changed by the following group of samples.
    --------------------------------------------------------------------

    PROCESS (PixelClk)

        VARIABLE pending_next :
        INTEGER RANGE 0 TO 2;

    BEGIN

        IF rising_edge(PixelClk) THEN

            IF reset = '1' THEN

                audio_capture_index <= 0;
                capture_l0 <= (OTHERS => '0');
                capture_r0 <= (OTHERS => '0');
                capture_l1 <= (OTHERS => '0');
                capture_r1 <= (OTHERS => '0');
                capture_l2 <= (OTHERS => '0');
                capture_r2 <= (OTHERS => '0');
                packet_l_bank0 <= (OTHERS => (OTHERS => '0'));
                packet_r_bank0 <= (OTHERS => (OTHERS => '0'));
                packet_l_bank1 <= (OTHERS => (OTHERS => '0'));
                packet_r_bank1 <= (OTHERS => (OTHERS => '0'));
                packet_write_bank <= '0';
                packet_read_bank <= '0';
                audio_pending <= 0;

                audio_frame_counter <=
                    (OTHERS => '0');

            ELSE

                pending_next := audio_pending;
                --------------------------------------------------------
                -- Audio packet transmission finished. Free its bank before
                -- accepting a simultaneous completed sample group.
                --------------------------------------------------------

                IF (
                    send_audio_sample_line = '1' AND
                    to_integer(x_pos) = 1013
                    ) THEN

                    IF pending_next > 0 THEN
                        pending_next := pending_next - 1;
                        packet_read_bank <= NOT packet_read_bank;
                    END IF;

                    IF audio_frame_counter >= 188 THEN
                        audio_frame_counter <=
                            audio_frame_counter + 4 - 192;
                    ELSE
                        audio_frame_counter <=
                            audio_frame_counter + 4;
                    END IF;
                END IF;
                --------------------------------------------------------
                -- Capture one coherent PCM frame at 48 kHz.
                --------------------------------------------------------

                IF pcm_valid = '1' THEN

                    CASE audio_capture_index IS
                        WHEN 0 =>
                            IF audio_enable = '1' THEN
                                capture_l0 <= pcm_l;
                                capture_r0 <= pcm_r;
                            ELSE
                                capture_l0 <= (OTHERS => '0');
                                capture_r0 <= (OTHERS => '0');
                            END IF;
                            audio_capture_index <= 1;
                        WHEN 1 =>
                            IF audio_enable = '1' THEN
                                capture_l1 <= pcm_l;
                                capture_r1 <= pcm_r;
                            ELSE
                                capture_l1 <= (OTHERS => '0');
                                capture_r1 <= (OTHERS => '0');
                            END IF;
                            audio_capture_index <= 2;
                        WHEN 2 =>
                            IF audio_enable = '1' THEN
                                capture_l2 <= pcm_l;
                                capture_r2 <= pcm_r;
                            ELSE
                                capture_l2 <= (OTHERS => '0');
                                capture_r2 <= (OTHERS => '0');
                            END IF;
                            audio_capture_index <= 3;
                        WHEN OTHERS =>
                            IF pending_next < 2 THEN
                                IF packet_write_bank = '0' THEN
                                    packet_l_bank0(0) <= capture_l0;
                                    packet_r_bank0(0) <= capture_r0;
                                    packet_l_bank0(1) <= capture_l1;
                                    packet_r_bank0(1) <= capture_r1;
                                    packet_l_bank0(2) <= capture_l2;
                                    packet_r_bank0(2) <= capture_r2;
                                    IF audio_enable = '1' THEN
                                        packet_l_bank0(3) <= pcm_l;
                                        packet_r_bank0(3) <= pcm_r;
                                    ELSE
                                        packet_l_bank0(3) <= (OTHERS => '0');
                                        packet_r_bank0(3) <= (OTHERS => '0');
                                    END IF;
                                ELSE
                                    packet_l_bank1(0) <= capture_l0;
                                    packet_r_bank1(0) <= capture_r0;
                                    packet_l_bank1(1) <= capture_l1;
                                    packet_r_bank1(1) <= capture_r1;
                                    packet_l_bank1(2) <= capture_l2;
                                    packet_r_bank1(2) <= capture_r2;
                                    IF audio_enable = '1' THEN
                                        packet_l_bank1(3) <= pcm_l;
                                        packet_r_bank1(3) <= pcm_r;
                                    ELSE
                                        packet_l_bank1(3) <= (OTHERS => '0');
                                        packet_r_bank1(3) <= (OTHERS => '0');
                                    END IF;
                                END IF;
                                packet_write_bank <= NOT packet_write_bank;
                                pending_next := pending_next + 1;
                            END IF;
                            audio_capture_index <= 0;
                    END CASE;
                END IF;
                audio_pending <= pending_next;

            END IF;

        END IF;

    END PROCESS;

    --------------------------------------------------------------------
    -- Three normal TMDS encoders
    --------------------------------------------------------------------

    TMDS_ENCODERS : FOR i IN 0 TO 2 GENERATE

        encoder : ENTITY work.TMDS_Encoder
            PORT MAP(
                PixelClk => PixelClk,
                -- This input is not used by the Digilent encoder logic; keep
                -- it on the pixel clock now that serialization is external.
                SerialClk => PixelClk,
                aRst => reset,

                pDataOutRaw => encoded(i),

                pDataOut => pixel_data(i),

                pC0 => ctrl_c0(i),
                pC1 => ctrl_c1(i),

                pVde => vde_ch(i)
            );

    END GENERATE;
    --------------------------------------------------------------------
    -- Three TERC4 encoders
    --------------------------------------------------------------------

    TERC4_ENCODERS : FOR i IN 0 TO 2 GENERATE

        terc4 : ENTITY work.terc4_encoder
            PORT MAP(
                data => terc4_nibble_pipe(2)(i),
                encoded => terc4_encoded(i)
            );

    END GENERATE;
    --------------------------------------------------------------------
    -- Final HDMI symbol multiplexer
    --------------------------------------------------------------------

    PROCESS (ALL)
    BEGIN

        --------------------------------------------------------------
        -- Default:
        -- ordinary video / control generated by TMDS_Encoder
        --------------------------------------------------------------

        tx_word(0) <= encoded(0);
        tx_word(1) <= encoded(1);
        tx_word(2) <= encoded(2);
        --------------------------------------------------------------
        -- HDMI Video Guard Band
        --------------------------------------------------------------

        IF video_guard_pipe(2) = '1' THEN

            tx_word(0) <= VIDEO_GUARD_CH0;
            tx_word(1) <= VIDEO_GUARD_CH1;
            tx_word(2) <= VIDEO_GUARD_CH2;
            --------------------------------------------------------------
            -- HDMI Data Island Guard Band
            --------------------------------------------------------------

        ELSIF data_guard_pipe(2) = '1' THEN

            -- Channel 0 is TERC4 encoded
            tx_word(0) <= terc4_encoded(0);

            -- Channels 1 and 2 are fixed Guard Band symbols
            tx_word(1) <= DATA_GUARD_CH1;
            tx_word(2) <= DATA_GUARD_CH2;
            --------------------------------------------------------------
            -- HDMI Data Island
            --------------------------------------------------------------

        ELSIF data_island_pipe(2) = '1' THEN

            tx_word(0) <= terc4_encoded(0);
            tx_word(1) <= terc4_encoded(1);
            tx_word(2) <= terc4_encoded(2);

        END IF;

    END PROCESS;
    -- R6 uses the existing, timing-proven SelectIO serializer.  Both it and
    -- HDMItest transmit bit 0 first, so no bit reversal is required here.
    tmds_ch0 <= tx_word(0);
    tmds_ch1 <= tx_word(1);
    tmds_ch2 <= tx_word(2);

END ARCHITECTURE rtl;
