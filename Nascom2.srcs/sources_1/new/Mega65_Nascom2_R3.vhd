--------------------------------------------------------------------------------
-- MEGA65 R3/R3A board wrapper for the shared Nascom2 MEGA65 implementation.
--
-- R3 and R3A use the same mega65r3 core target.  Unlike R6, their reset button
-- is reported by the auxiliary MAX10 FPGA over a three-wire serial interface.
-- M13 and K16 are therefore reserved for MAX10 and must not be used as PMOD
-- enable/fault pins as they are on the R6 board.
--------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY Mega65_Nascom2_R3 IS
    PORT (
        CLK_IN : IN STD_LOGIC;

        max10_tx : IN STD_LOGIC;
        max10_rx : OUT STD_LOGIC;
        reset_from_max10 : OUT STD_LOGIC;

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
        hdmi_ls_oe : OUT STD_LOGIC;
        hdmi_ct_hpd : OUT STD_LOGIC;
        hdmi_hpd : IN STD_LOGIC;

        pwm_l : OUT STD_LOGIC;
        pwm_r : OUT STD_LOGIC;

        vdac_clk : OUT STD_LOGIC;
        vdac_sync_n : OUT STD_LOGIC;
        vdac_blank_n : OUT STD_LOGIC;
        vgared : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        vgagreen : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        vgablue : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        hsync : OUT STD_LOGIC;
        vsync : OUT STD_LOGIC;

        UART_TXD : OUT STD_LOGIC;
        RsRx : IN STD_LOGIC;

        p1lo_cts : IN STD_LOGIC;
        p1lo_rts : OUT STD_LOGIC;
        p1lo_txd : OUT STD_LOGIC;
        p1lo_rxd : IN STD_LOGIC;
        p1hi_cts : IN STD_LOGIC;
        p1hi_rts : OUT STD_LOGIC;
        p1hi_txd : OUT STD_LOGIC;
        p1hi_rxd : IN STD_LOGIC;
        p2lo_cts : IN STD_LOGIC;
        p2lo_rts : OUT STD_LOGIC;
        p2lo_txd : OUT STD_LOGIC;
        p2lo_rxd : IN STD_LOGIC;
        p2hi_cts : IN STD_LOGIC;
        p2hi_rts : OUT STD_LOGIC;
        p2hi_txd : OUT STD_LOGIC;
        p2hi_rxd : IN STD_LOGIC;

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
        sd2CD : IN STD_LOGIC
    );
END ENTITY Mega65_Nascom2_R3;

ARCHITECTURE rtl OF Mega65_Nascom2_R3 IS
    SIGNAL r3_reset_n : STD_LOGIC := '1';
    SIGNAL r3_reset_active_high : STD_LOGIC;
BEGIN
    -- R3/R3A HDMI level shifter controls.  HPD is driven by the display and
    -- is intentionally only sampled at the package pin.
    hdmi_ls_oe <= '1';
    hdmi_ct_hpd <= '1';

    -- MAX10 supplies reset_n, while the shared R6 shell accepts a raw
    -- active-high reset button level.
    r3_reset_active_high <= NOT r3_reset_n;

    max10 : ENTITY work.mega65_r3_max10
        PORT MAP (
            protocol_clock => CLK_IN,
            system_clock => CLK_IN,
            max10_rx => max10_rx,
            max10_tx => max10_tx,
            max10_clkandsync => reset_from_max10,
            reset_n => r3_reset_n
        );

    u_board_common : ENTITY work.Mega65_Nascom2
        GENERIC MAP (
            G_BOARD => "MEGA65_R3"
        )
        PORT MAP (
            CLK_IN => CLK_IN,
            reset_button => r3_reset_active_high,
            kb_io0 => kb_io0,
            kb_io1 => kb_io1,
            kb_io2 => kb_io2,
            fpga_scl => fpga_scl,
            fpga_sda => fpga_sda,
            grove_scl => grove_scl,
            grove_sda => grove_sda,
            led => led,
            TMDS_clk_p => TMDS_clk_p,
            TMDS_clk_n => TMDS_clk_n,
            TMDS_data_p => TMDS_data_p,
            TMDS_data_n => TMDS_data_n,
            hdmi_enable_n => OPEN,
            hdmi_hiz => OPEN,
            hpd_a => OPEN,
            audio_mclk_o => OPEN,
            audio_bick_o => OPEN,
            audio_sdti_o => OPEN,
            audio_lrclk_o => OPEN,
            audio_pdn_n_o => OPEN,
            audio_i2cfil_o => pwm_l,
            audio_scl_io => pwm_r,
            audio_sda_io => OPEN,
            vdac_clk => vdac_clk,
            vdac_sync_n => vdac_sync_n,
            vdac_blank_n => vdac_blank_n,
            vdac_psave_n => OPEN,
            vgared => vgared,
            vgagreen => vgagreen,
            vgablue => vgablue,
            hsync => hsync,
            vsync => vsync,
            UART_TXD => UART_TXD,
            RsRx => RsRx,
            pmod1_en => OPEN,
            pmod1_flag => '1',
            p1lo_cts => p1lo_cts,
            p1lo_rts => p1lo_rts,
            p1lo_txd => p1lo_txd,
            p1lo_rxd => p1lo_rxd,
            p1hi_cts => p1hi_cts,
            p1hi_rts => p1hi_rts,
            p1hi_txd => p1hi_txd,
            p1hi_rxd => p1hi_rxd,
            pmod2_en => OPEN,
            pmod2_flag => '1',
            p2lo_cts => p2lo_cts,
            p2lo_rts => p2lo_rts,
            p2lo_txd => p2lo_txd,
            p2lo_rxd => p2lo_rxd,
            p2hi_cts => p2hi_cts,
            p2hi_rts => p2hi_rts,
            p2hi_txd => p2hi_txd,
            p2hi_rxd => p2hi_rxd,
            fa_down_n_i => fa_down_n_i,
            fa_fire_n_i => fa_fire_n_i,
            fa_left_n_i => fa_left_n_i,
            fa_right_n_i => fa_right_n_i,
            fa_up_n_i => fa_up_n_i,
            fb_down_n_i => fb_down_n_i,
            fb_fire_n_i => fb_fire_n_i,
            fb_left_n_i => fb_left_n_i,
            fb_right_n_i => fb_right_n_i,
            fb_up_n_i => fb_up_n_i,
            cart_and_joy_en => OPEN,
            fa_down_drain_n => OPEN,
            fa_fire_drain_n => OPEN,
            fa_left_drain_n => OPEN,
            fa_right_drain_n => OPEN,
            fa_up_drain_n => OPEN,
            fb_down_drain_n => OPEN,
            fb_fire_drain_n => OPEN,
            fb_left_drain_n => OPEN,
            fb_right_drain_n => OPEN,
            fb_up_drain_n => OPEN,
            eth_mdio => eth_mdio,
            eth_mdc => eth_mdc,
            eth_reset => eth_reset,
            eth_rxd => eth_rxd,
            eth_txd => eth_txd,
            eth_txen => eth_txen,
            eth_rxdv => eth_rxdv,
            eth_rxer => eth_rxer,
            eth_clock => eth_clock,
            sd2Clock => sd2Clock,
            sd2reset => sd2reset,
            sd2MISO => sd2MISO,
            sd2MOSI => sd2MOSI,
            sd2CD => sd2CD,
            sd2_dat => OPEN
        );
END ARCHITECTURE rtl;
