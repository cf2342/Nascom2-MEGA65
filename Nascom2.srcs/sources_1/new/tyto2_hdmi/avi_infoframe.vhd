library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity avi_infoframe is
    port (
        header : out std_logic_vector(23 downto 0);

        sub0   : out std_logic_vector(55 downto 0);
        sub1   : out std_logic_vector(55 downto 0);
        sub2   : out std_logic_vector(55 downto 0);
        sub3   : out std_logic_vector(55 downto 0)
    );
end entity avi_infoframe;


architecture rtl of avi_infoframe is

    --------------------------------------------------------------------
    -- Byte array used for checksum calculation
    --------------------------------------------------------------------

    type byte_array_t is array (natural range <>)
        of std_logic_vector(7 downto 0);


    --------------------------------------------------------------------
    -- AVI InfoFrame Header
    --------------------------------------------------------------------

    constant HB0 : std_logic_vector(7 downto 0) := x"82";
    constant HB1 : std_logic_vector(7 downto 0) := x"02";
    constant HB2 : std_logic_vector(7 downto 0) := x"0D";


    --------------------------------------------------------------------
    -- AVI InfoFrame Payload
    --
    -- Our current video:
    --
    --   800 x 600 @ 60
    --   RGB 4:4:4
    --   4:3
    --   Full RGB range
    --   no pixel repetition
    --   no CTA VIC
    --------------------------------------------------------------------

    --------------------------------------------------------------------
    -- PB1
    --
    -- bit 7     reserved
    -- bits 6:5  Y = 00 = RGB
    -- bit 4     A = 0  = no Active Format information
    -- bits 3:2  B = 00 = no bar information
    -- bits 1:0  S = 00 = no scan information
    --------------------------------------------------------------------

    constant PB1 : std_logic_vector(7 downto 0) := x"00";


    --------------------------------------------------------------------
    -- PB2
    --
    -- bits 7:6  C = 00 = no colorimetry data
    -- bits 5:4  M = 01 = picture aspect ratio 4:3
    -- bits 3:0  R = 0000, because A=0
    --
    -- 01 << 4 = 10h
    --------------------------------------------------------------------

    constant PB2 : std_logic_vector(7 downto 0) := x"10";


    --------------------------------------------------------------------
    -- PB3
    --
    -- bit 7     ITC = 0
    -- bits 6:4  EC  = 000
    -- bits 3:2  Q   = 10 = Full Range RGB
    -- bits 1:0  SC  = 00
    --
    -- 10 << 2 = 08h
    --------------------------------------------------------------------

    constant PB3 : std_logic_vector(7 downto 0) := x"08";


    --------------------------------------------------------------------
    -- PB4
    --
    -- VIC = 0
    --
    -- 800x600@60 is not a CTA-861 Video Identification Code mode.
    --------------------------------------------------------------------

    constant PB4 : std_logic_vector(7 downto 0) := x"00";


    --------------------------------------------------------------------
    -- PB5
    --
    -- YQ = 00
    -- CN = 00
    -- PR = 0000 = no pixel repetition
    --------------------------------------------------------------------

    constant PB5 : std_logic_vector(7 downto 0) := x"00";


    --------------------------------------------------------------------
    -- No bar information
    --------------------------------------------------------------------

    constant PB6  : std_logic_vector(7 downto 0) := x"00";
    constant PB7  : std_logic_vector(7 downto 0) := x"00";
    constant PB8  : std_logic_vector(7 downto 0) := x"00";
    constant PB9  : std_logic_vector(7 downto 0) := x"00";
    constant PB10 : std_logic_vector(7 downto 0) := x"00";
    constant PB11 : std_logic_vector(7 downto 0) := x"00";
    constant PB12 : std_logic_vector(7 downto 0) := x"00";
    constant PB13 : std_logic_vector(7 downto 0) := x"00";


    --------------------------------------------------------------------
    -- AVI InfoFrame checksum
    --
    -- Sum of:
    --
    -- HB0 + HB1 + HB2 + PB0 + PB1 ... PB13
    --
    -- must equal 00 modulo 256.
    --------------------------------------------------------------------

    function calc_checksum(
        bytes : byte_array_t
    )
    return std_logic_vector is

        variable sum :
            unsigned(7 downto 0) := (others => '0');

    begin

        for i in bytes'range loop
            sum := sum + unsigned(bytes(i));
        end loop;

        return std_logic_vector(
            to_unsigned(
                (256 - to_integer(sum)) mod 256,
                8
            )
        );

    end function;


    --------------------------------------------------------------------
    -- Everything except PB0
    --------------------------------------------------------------------

    constant CHECK_BYTES : byte_array_t(0 to 15) := (
        HB0,
        HB1,
        HB2,

        PB1,
        PB2,
        PB3,
        PB4,
        PB5,
        PB6,
        PB7,
        PB8,
        PB9,
        PB10,
        PB11,
        PB12,
        PB13
    );


    constant PB0 :
        std_logic_vector(7 downto 0) :=
        calc_checksum(CHECK_BYTES);

begin

    --------------------------------------------------------------------
    -- Packet Header
    --
    -- hdmi_packet_assembler expects:
    --
    -- header(7:0)   = HB0
    -- header(15:8)  = HB1
    -- header(23:16) = HB2
    --------------------------------------------------------------------

    header <=
        HB2 &
        HB1 &
        HB0;


    --------------------------------------------------------------------
    -- HDMI Packet Body
    --
    -- Subpacket 0:
    --
    -- PB0 .. PB6
    --------------------------------------------------------------------

    sub0 <=
        PB6 &
        PB5 &
        PB4 &
        PB3 &
        PB2 &
        PB1 &
        PB0;


    --------------------------------------------------------------------
    -- Subpacket 1:
    --
    -- PB7 .. PB13
    --------------------------------------------------------------------

    sub1 <=
        PB13 &
        PB12 &
        PB11 &
        PB10 &
        PB9 &
        PB8 &
        PB7;


    --------------------------------------------------------------------
    -- Remaining packet body unused by AVI InfoFrame
    --------------------------------------------------------------------

    sub2 <= (others => '0');
    sub3 <= (others => '0');


    --------------------------------------------------------------------
    -- Our current constants should result in checksum 57h.
    --------------------------------------------------------------------

    assert PB0 = x"57"
        report "Unexpected AVI InfoFrame checksum"
        severity failure;

end architecture rtl;


