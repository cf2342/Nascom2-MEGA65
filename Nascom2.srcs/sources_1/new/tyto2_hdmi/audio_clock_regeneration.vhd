library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity audio_clock_regeneration is
    port (
        header : out std_logic_vector(23 downto 0);

        sub0   : out std_logic_vector(55 downto 0);
        sub1   : out std_logic_vector(55 downto 0);
        sub2   : out std_logic_vector(55 downto 0);
        sub3   : out std_logic_vector(55 downto 0)
    );
end entity audio_clock_regeneration;


architecture rtl of audio_clock_regeneration is

    --------------------------------------------------------------------
    -- HDMI Audio Clock Regeneration
    --
    -- Audio:
    --     fs = 48 kHz
    --
    -- TMDS clock:
    --     40 MHz
    --
    -- Formula:
    --
    --     128 * fs = fTMDS * N / CTS
    --
    -- Therefore:
    --
    --     N   = 6144  = 0x01800
    --     CTS = 40000 = 0x09C40
    --------------------------------------------------------------------

    constant N_VALUE :
        unsigned(19 downto 0) :=
        to_unsigned(6144, 20);

    constant CTS_VALUE :
        unsigned(19 downto 0) :=
        to_unsigned(40000, 20);


    --------------------------------------------------------------------
    -- Packet bytes
    --
    -- ACR packet:
    --
    -- HB0 = 01h
    -- HB1 = 00h
    -- HB2 = 00h
    --
    -- PB0 = 00
    --
    -- PB1 = CTS[19:16]
    -- PB2 = CTS[15:8]
    -- PB3 = CTS[7:0]
    --
    -- PB4 = N[19:16]
    -- PB5 = N[15:8]
    -- PB6 = N[7:0]
    --------------------------------------------------------------------

    constant PB0 : std_logic_vector(7 downto 0) :=
        x"00";

    constant PB1 : std_logic_vector(7 downto 0) :=
        "0000" & std_logic_vector(CTS_VALUE(19 downto 16));

    constant PB2 : std_logic_vector(7 downto 0) :=
        std_logic_vector(CTS_VALUE(15 downto 8));

    constant PB3 : std_logic_vector(7 downto 0) :=
        std_logic_vector(CTS_VALUE(7 downto 0));

    constant PB4 : std_logic_vector(7 downto 0) :=
        "0000" & std_logic_vector(N_VALUE(19 downto 16));

    constant PB5 : std_logic_vector(7 downto 0) :=
        std_logic_vector(N_VALUE(15 downto 8));

    constant PB6 : std_logic_vector(7 downto 0) :=
        std_logic_vector(N_VALUE(7 downto 0));


    signal acr_subpacket :
        std_logic_vector(55 downto 0);

begin

    --------------------------------------------------------------------
    -- Packet type 01h = Audio Clock Regeneration
    --------------------------------------------------------------------

    header <= x"000001";


    --------------------------------------------------------------------
    -- hdmi_packet_assembler expects:
    --
    -- bits  7:0  = PB0
    -- bits 15:8  = PB1
    -- ...
    -- bits 55:48 = PB6
    --------------------------------------------------------------------

    acr_subpacket <=
        PB6 &
        PB5 &
        PB4 &
        PB3 &
        PB2 &
        PB1 &
        PB0;


    --------------------------------------------------------------------
    -- All four ACR subpackets contain the same N/CTS values
    --------------------------------------------------------------------

    sub0 <= acr_subpacket;
    sub1 <= acr_subpacket;
    sub2 <= acr_subpacket;
    sub3 <= acr_subpacket;

end architecture rtl;

