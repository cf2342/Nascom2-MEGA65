library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity hdmi_packet_assembler is
    port (
        ----------------------------------------------------------------
        -- Clock / Reset
        ----------------------------------------------------------------
        PixelClk    : in std_logic;
        reset       : in std_logic;

        ----------------------------------------------------------------
        -- '1' for exactly 32 PixelClks while a packet is transmitted
        ----------------------------------------------------------------
        data_island : in std_logic;

        ----------------------------------------------------------------
        -- Packet Header
        --
        -- Bit layout:
        --
        --   header(7 downto 0)   = HB0
        --   header(15 downto 8)  = HB1
        --   header(23 downto 16) = HB2
        --
        -- Convenient construction:
        --
        --   header <= HB2 & HB1 & HB0;
        ----------------------------------------------------------------
        header : in std_logic_vector(23 downto 0);

        ----------------------------------------------------------------
        -- Four HDMI subpackets
        --
        -- Each contains 7 bytes = 56 bits.
        --
        -- Subpacket 0 = PB0  .. PB6
        -- Subpacket 1 = PB7  .. PB13
        -- Subpacket 2 = PB14 .. PB20
        -- Subpacket 3 = PB21 .. PB27
        --
        -- Lowest bit is transmitted first.
        ----------------------------------------------------------------
        sub0 : in std_logic_vector(55 downto 0);
        sub1 : in std_logic_vector(55 downto 0);
        sub2 : in std_logic_vector(55 downto 0);
        sub3 : in std_logic_vector(55 downto 0);

        ----------------------------------------------------------------
        -- Output for TERC4
        --
        -- Header contributes one bit per PixelClk.
        --
        -- Each of the four subpackets contributes two bits per
        -- PixelClk:
        --
        --   body_ch1(0) = Subpacket 0 bit 2*n
        --   body_ch2(0) = Subpacket 0 bit 2*n+1
        --
        --   ...
        --
        -- Hence each TMDS channel carries one nibble.
        ----------------------------------------------------------------
        header_bit : out std_logic;

        body_ch1 : out std_logic_vector(3 downto 0);
        body_ch2 : out std_logic_vector(3 downto 0);

        ----------------------------------------------------------------
        -- Current pixel inside packet, useful for D3 marker/debugging
        ----------------------------------------------------------------
        packet_index : out unsigned(4 downto 0)
    );
end entity hdmi_packet_assembler;


architecture rtl of hdmi_packet_assembler is

    --------------------------------------------------------------------
    -- Array types
    --------------------------------------------------------------------

    type sub_array_t is array (0 to 3)
        of std_logic_vector(55 downto 0);

    type parity_array_t is array (0 to 4)
        of std_logic_vector(7 downto 0);


    signal sub_data : sub_array_t;

    --------------------------------------------------------------------
    -- BCH parity:
    --
    -- parity(0..3) = four body subpackets
    -- parity(4)    = packet header
    --------------------------------------------------------------------

    signal parity : parity_array_t :=
        (others => (others => '0'));

    signal counter : unsigned(4 downto 0) :=
        (others => '0');


    --------------------------------------------------------------------
    -- HDMI BCH ECC
    --
    -- This is the serial BCH update operation used by HDMI.
    --
    -- Data is processed LSB first.
    --------------------------------------------------------------------

    function next_ecc(
        ecc      : std_logic_vector(7 downto 0);
        data_bit : std_logic
    )
    return std_logic_vector is

        variable result   : std_logic_vector(7 downto 0);
        variable feedback : std_logic;

    begin

        feedback := ecc(0) xor data_bit;

        --------------------------------------------------------------
        -- Shift right
        --------------------------------------------------------------

        result := '0' & ecc(7 downto 1);

        --------------------------------------------------------------
        -- BCH feedback polynomial
        --------------------------------------------------------------

        if feedback = '1' then
            result := result xor x"83";
        end if;

        return result;

    end function;


begin

    --------------------------------------------------------------------
    -- Subpacket inputs
    --------------------------------------------------------------------

    sub_data(0) <= sub0;
    sub_data(1) <= sub1;
    sub_data(2) <= sub2;
    sub_data(3) <= sub3;


    packet_index <= counter;


    --------------------------------------------------------------------
    -- BCH generator + 32-pixel packet counter
    --------------------------------------------------------------------

    process(PixelClk)

        variable idx  : integer;
        variable tmp  : std_logic_vector(7 downto 0);

    begin

        if rising_edge(PixelClk) then

            if reset = '1' then

                counter <= (others => '0');
                parity  <= (others => (others => '0'));


            elsif data_island = '0' then

                --------------------------------------------------------
                -- Outside a packet we are always prepared for
                -- packet pixel 0.
                --------------------------------------------------------

                counter <= (others => '0');
                parity  <= (others => (others => '0'));


            else

                idx := to_integer(counter);


                --------------------------------------------------------
                -- BODY BCH
                --
                -- Each subpacket contains 56 data bits.
                --
                -- We transmit two bits from each subpacket per
                -- PixelClk, therefore data occupies packet clocks:
                --
                -- 0 .. 27
                --
                -- The BCH parity occupies:
                --
                -- 28 .. 31
                --------------------------------------------------------

                if idx < 28 then

                    for i in 0 to 3 loop

                        ------------------------------------------------
                        -- First bit
                        ------------------------------------------------

                        tmp :=
                            next_ecc(
                                parity(i),
                                sub_data(i)(2 * idx)
                            );

                        ------------------------------------------------
                        -- Second bit
                        ------------------------------------------------

                        parity(i) <=
                            next_ecc(
                                tmp,
                                sub_data(i)(2 * idx + 1)
                            );

                    end loop;

                end if;


                --------------------------------------------------------
                -- HEADER BCH
                --
                -- Header contains 24 data bits:
                --
                -- packet clocks 0 .. 23
                --
                -- BCH parity is emitted during clocks 24 .. 31.
                --------------------------------------------------------

                if idx < 24 then

                    parity(4) <=
                        next_ecc(
                            parity(4),
                            header(idx)
                        );

                end if;


                --------------------------------------------------------
                -- Packet counter
                --------------------------------------------------------

                if counter = 31 then

                    counter <= (others => '0');

                    ----------------------------------------------------
                    -- Ready for next HDMI packet
                    ----------------------------------------------------

                    parity <=
                        (others => (others => '0'));

                else

                    counter <= counter + 1;

                end if;

            end if;

        end if;

    end process;


    --------------------------------------------------------------------
    -- Convert assembled packet to the bits transmitted during
    -- the current PixelClk.
    --------------------------------------------------------------------

    process(all)

        variable idx      : integer;

        variable bit_even : integer;
        variable bit_odd  : integer;

    begin

        idx := to_integer(counter);


        --------------------------------------------------------------
        -- HEADER
        --
        -- First 24 clocks:
        --   HB0/HB1/HB2 bits
        --
        -- Last 8 clocks:
        --   BCH parity bits 0..7
        --------------------------------------------------------------

        if idx < 24 then

            header_bit <= header(idx);

        else

            header_bit <= parity(4)(idx - 24);

        end if;


        --------------------------------------------------------------
        -- BODY
        --
        -- Two bits from every one of the four BCH blocks are sent
        -- on every PixelClk.
        --------------------------------------------------------------

        bit_even := 2 * idx;
        bit_odd  := bit_even + 1;


        for i in 0 to 3 loop

            ----------------------------------------------------------
            -- TMDS channel 1
            ----------------------------------------------------------

            if bit_even < 56 then

                body_ch1(i) <=
                    sub_data(i)(bit_even);

            else

                body_ch1(i) <=
                    parity(i)(bit_even - 56);

            end if;


            ----------------------------------------------------------
            -- TMDS channel 2
            ----------------------------------------------------------

            if bit_odd < 56 then

                body_ch2(i) <=
                    sub_data(i)(bit_odd);

            else

                body_ch2(i) <=
                    parity(i)(bit_odd - 56);

            end if;

        end loop;

    end process;

end architecture rtl;

