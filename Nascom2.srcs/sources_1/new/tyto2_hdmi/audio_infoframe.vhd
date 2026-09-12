library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity audio_infoframe is
    port (
        header : out std_logic_vector(23 downto 0);

        sub0   : out std_logic_vector(55 downto 0);
        sub1   : out std_logic_vector(55 downto 0);
        sub2   : out std_logic_vector(55 downto 0);
        sub3   : out std_logic_vector(55 downto 0)
    );
end entity audio_infoframe;


architecture rtl of audio_infoframe is

    type byte_array_t is array (natural range <>)
        of std_logic_vector(7 downto 0);


    --------------------------------------------------------------------
    -- HDMI Audio InfoFrame
    --
    -- Type    = 84h
    -- Version = 01h
    -- Length  = 0Ah
    --------------------------------------------------------------------

    constant HB0 : std_logic_vector(7 downto 0) := x"84";
    constant HB1 : std_logic_vector(7 downto 0) := x"01";
    constant HB2 : std_logic_vector(7 downto 0) := x"0A";


    --------------------------------------------------------------------
    -- PB1
    --
    -- bits 7:4 = CT = 0001 = LPCM
    -- bit 3     = reserved
    -- bits 2:0 = CC = channel count - 1
    --
    -- Stereo:
    --
    --     CC = 2 - 1 = 1
    --
    -- therefore:
    --
    --     PB1 = 0001 0001 = 11h
    --------------------------------------------------------------------

    constant PB1 : std_logic_vector(7 downto 0) := x"11";


    --------------------------------------------------------------------
    -- PB2
    --
    -- bits 4:2 = SF
    --
    --     011 = 48 kHz
    --
    -- bits 1:0 = SS
    --
    --     01 = 16 bit
    --
    -- 011 << 2 = 0Ch
    -- SS       = 01h
    --
    -- PB2 = 0Dh
    --------------------------------------------------------------------

    constant PB2 : std_logic_vector(7 downto 0) := x"0D";


    --------------------------------------------------------------------
    -- PB3
    --
    -- Coding Type Extension = 0
    --------------------------------------------------------------------

    constant PB3 : std_logic_vector(7 downto 0) := x"00";


    --------------------------------------------------------------------
    -- PB4
    --
    -- Channel Allocation
    --
    -- 00h = standard 2-channel stereo:
    --
    --     FL / FR
    --------------------------------------------------------------------

    constant PB4 : std_logic_vector(7 downto 0) := x"00";


    --------------------------------------------------------------------
    -- PB5
    --
    -- Downmix inhibit = 0
    -- Level shift     = 0
    --------------------------------------------------------------------

    constant PB5 : std_logic_vector(7 downto 0) := x"00";


    --------------------------------------------------------------------
    -- PB6 .. PB10 reserved / zero
    --------------------------------------------------------------------

    constant PB6  : std_logic_vector(7 downto 0) := x"00";
    constant PB7  : std_logic_vector(7 downto 0) := x"00";
    constant PB8  : std_logic_vector(7 downto 0) := x"00";
    constant PB9  : std_logic_vector(7 downto 0) := x"00";
    constant PB10 : std_logic_vector(7 downto 0) := x"00";


    --------------------------------------------------------------------
    -- Checksum
    --
    -- HB0 + HB1 + HB2 + PB0 + PB1 ... PB10
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


    constant CHECK_BYTES : byte_array_t(0 to 12) := (
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
        PB10
    );


    constant PB0 :
        std_logic_vector(7 downto 0) :=
        calc_checksum(CHECK_BYTES);


begin

    --------------------------------------------------------------------
    -- Header
    --------------------------------------------------------------------

    header <=
        HB2 &
        HB1 &
        HB0;


    --------------------------------------------------------------------
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
    -- PB7 .. PB10 + unused bytes
    --------------------------------------------------------------------

    sub1 <=
        x"00" &
        x"00" &
        x"00" &
        PB10 &
        PB9 &
        PB8 &
        PB7;


    --------------------------------------------------------------------
    -- Remaining subpackets unused
    --------------------------------------------------------------------

    sub2 <= (others => '0');
    sub3 <= (others => '0');


    --------------------------------------------------------------------
    -- Expected checksum:
    --
    -- 84 + 01 + 0A + 11 + 0D = AD
    --
    -- 100 - AD = 53
    --------------------------------------------------------------------

    assert PB0 = x"53"
        report "Unexpected Audio InfoFrame checksum"
        severity failure;

end architecture rtl;

