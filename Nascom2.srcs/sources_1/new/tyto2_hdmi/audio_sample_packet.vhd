library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity audio_sample_packet is
    port (
        ----------------------------------------------------------------
        -- Number of first IEC-60958 frame in this packet
        -- 0 .. 191
        ----------------------------------------------------------------
        frame_counter : in unsigned(7 downto 0);

        ----------------------------------------------------------------
        -- Four consecutive stereo samples
        -- Signed 16-bit PCM
        ----------------------------------------------------------------
        sample_l0 : in std_logic_vector(15 downto 0);
        sample_r0 : in std_logic_vector(15 downto 0);

        sample_l1 : in std_logic_vector(15 downto 0);
        sample_r1 : in std_logic_vector(15 downto 0);

        sample_l2 : in std_logic_vector(15 downto 0);
        sample_r2 : in std_logic_vector(15 downto 0);

        sample_l3 : in std_logic_vector(15 downto 0);
        sample_r3 : in std_logic_vector(15 downto 0);

        ----------------------------------------------------------------
        -- HDMI packet
        ----------------------------------------------------------------
        header : out std_logic_vector(23 downto 0);

        sub0   : out std_logic_vector(55 downto 0);
        sub1   : out std_logic_vector(55 downto 0);
        sub2   : out std_logic_vector(55 downto 0);
        sub3   : out std_logic_vector(55 downto 0)
    );
end entity audio_sample_packet;


architecture rtl of audio_sample_packet is

    subtype sample24_t is std_logic_vector(23 downto 0);


    --------------------------------------------------------------------
    -- XOR reduction
    --
    -- IEC-60958 parity is even.
    --------------------------------------------------------------------

    function xor_reduce(
        data : std_logic_vector
    )
    return std_logic is

        variable result : std_logic := '0';

    begin

        for i in data'range loop
            result := result xor data(i);
        end loop;

        return result;

    end function;


    --------------------------------------------------------------------
    -- IEC-60958 Channel Status
    --
    -- Consumer LPCM
    -- 48 kHz
    -- 16 bit
    --
    -- The status block consists of 192 frames.
    --
    -- Left/right differ in channel number.
    --------------------------------------------------------------------

    function channel_status_bit(
        frame_number   : natural;
        channel_number : natural
    )
    return std_logic is

    begin

        case frame_number is

            ------------------------------------------------------------
            -- Consumer / LPCM
            --
            -- bit 0 = 0 consumer
            -- bit 1 = 0 LPCM
            -- bit 2 = 1 copyright not asserted
            ------------------------------------------------------------

            when 2 =>
                return '1';


            ------------------------------------------------------------
            -- Channel number
            --
            -- Left  = 1
            -- Right = 2
            ------------------------------------------------------------

            when 20 =>

                if channel_number = 1 then
                    return '1';
                else
                    return '0';
                end if;

            when 21 =>

                if channel_number = 2 then
                    return '1';
                else
                    return '0';
                end if;


            ------------------------------------------------------------
            -- Sampling frequency = 48 kHz
            --
            -- IEC-60958 code = 0010
            ------------------------------------------------------------

            when 25 =>
                return '1';


            ------------------------------------------------------------
            -- Word length = 16 bit
            --
            -- IEC-60958 word-length code = 0010
            ------------------------------------------------------------

            when 33 =>
                return '1';


            when others =>
                return '0';

        end case;

    end function;


    --------------------------------------------------------------------
    -- Build one 56-bit HDMI Audio Sample Subpacket
    --------------------------------------------------------------------

    function make_subpacket(
        sample_l       : std_logic_vector(15 downto 0);
        sample_r       : std_logic_vector(15 downto 0);
        frame_number   : natural
    )
    return std_logic_vector is

        variable left24  : sample24_t;
        variable right24 : sample24_t;

        variable c_l : std_logic;
        variable c_r : std_logic;

        variable p_l : std_logic;
        variable p_r : std_logic;

        variable status_byte :
            std_logic_vector(7 downto 0);

    begin

        --------------------------------------------------------------
        -- HDMI transports a 24-bit audio sample field.
        --
        -- 16-bit samples are MSB aligned:
        --
        -- ABCD -> ABCD00
        --------------------------------------------------------------

        left24  := sample_l & x"00";
        right24 := sample_r & x"00";


        --------------------------------------------------------------
        -- IEC-60958 Channel Status
        --------------------------------------------------------------

        c_l := channel_status_bit(frame_number, 1);
        c_r := channel_status_bit(frame_number, 2);


        --------------------------------------------------------------
        -- V = 0 : valid audio
        -- U = 0 : no user data
        --
        -- P produces even parity over:
        --
        -- sample + V + U + C + P
        --------------------------------------------------------------

        p_l := xor_reduce(left24 & c_l & '0' & '0');
        p_r := xor_reduce(right24 & c_r & '0' & '0');


        --------------------------------------------------------------
        -- HDMI Audio Sample Subpacket high byte:
        --
        -- bit 7 = P_R
        -- bit 6 = C_R
        -- bit 5 = U_R
        -- bit 4 = V_R
        --
        -- bit 3 = P_L
        -- bit 2 = C_L
        -- bit 1 = U_L
        -- bit 0 = V_L
        --------------------------------------------------------------

        status_byte :=
            p_r & c_r & '0' & '0' &
            p_l & c_l & '0' & '0';


        --------------------------------------------------------------
        -- 56-bit Subpacket:
        --
        -- [23:0]  Left
        -- [47:24] Right
        -- [55:48] IEC status/parity
        --------------------------------------------------------------

        return
            status_byte &
            right24 &
            left24;

    end function;


begin

    process(all)

        variable hb1 :
            std_logic_vector(7 downto 0);

        variable hb2 :
            std_logic_vector(7 downto 0);

        variable f0 :
            natural;

        variable f1 :
            natural;

        variable f2 :
            natural;

        variable f3 :
            natural;

    begin

        --------------------------------------------------------------
        -- Four consecutive IEC-60958 frames
        --------------------------------------------------------------

        f0 := to_integer(frame_counter);
        f1 := (f0 + 1) mod 192;
        f2 := (f0 + 2) mod 192;
        f3 := (f0 + 3) mod 192;


        --------------------------------------------------------------
        -- HB1
        --
        -- bit 4    Layout = 0 (2 channel)
        -- bits 3:0 SP3..SP0
        --
        -- All four samples are present.
        --------------------------------------------------------------

        hb1 := x"0F";


        --------------------------------------------------------------
        -- HB2
        --
        -- B bits mark IEC-60958 block start for each Subpacket.
        --------------------------------------------------------------

        hb2 := (others => '0');

        if f0 = 0 then
            hb2(4) := '1';
        end if;

        if f1 = 0 then
            hb2(5) := '1';
        end if;

        if f2 = 0 then
            hb2(6) := '1';
        end if;

        if f3 = 0 then
            hb2(7) := '1';
        end if;


        --------------------------------------------------------------
        -- HDMI Packet Type 02h = Audio Sample
        --------------------------------------------------------------

        header <=
            hb2 &
            hb1 &
            x"02";


        --------------------------------------------------------------
        -- Four consecutive Stereo sample frames
        --------------------------------------------------------------

        sub0 <= make_subpacket(sample_l0, sample_r0, f0);
        sub1 <= make_subpacket(sample_l1, sample_r1, f1);
        sub2 <= make_subpacket(sample_l2, sample_r2, f2);
        sub3 <= make_subpacket(sample_l3, sample_r3, f3);

    end process;

end architecture rtl;


