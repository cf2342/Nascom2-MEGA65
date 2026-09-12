## Mega65 R6 first bring-up constraints for Nascom2

## Clock signal, 100 MHz
set_property -dict { PACKAGE_PIN V13 IOSTANDARD LVCMOS33 } [get_ports { CLK_IN }]
create_clock -period 10.000 -name CLK_IN [get_ports { CLK_IN }]

# The AY PCM sample crosses from CLK_IN into the independent 12.288 MHz DAC
# domain through a coherent stereo mailbox.
create_generated_clock -name audio_clk [get_pins {u_ak4432_audio/i_clk_audio/CLKOUT0}]
# Only handshake synchronizer entry points are asynchronous data paths.
set_false_path -to [get_pins -hierarchical -filter {NAME =~ *u_ak4432_audio/pcm_request_meta_reg/D || NAME =~ *u_ak4432_audio/pcm_ack_meta_reg/D}]
# Common reset asserts asynchronously; each domain releases it synchronously.
set_false_path -to [get_pins -hierarchical -filter {NAME =~ *u_ak4432_audio/*reset_*_reg/CLR || NAME =~ *u_ak4432_audio/*reset_*_reg/PRE}]
# Sample data is held until acknowledged. Keep the entire bus well inside
# one 81.38 ns destination period (capture follows two synchronizer stages).
set_max_delay -datapath_only 40.000 -from [get_cells -hierarchical -filter {NAME =~ *u_ak4432_audio/pcm_hold_reg*}] -to [get_cells -hierarchical -filter {NAME =~ *u_ak4432_audio/pcm_l_sync_reg* || NAME =~ *u_ak4432_audio/pcm_r_sync_reg*}]

## T80/T80s clock-enable multicycle, same rationale as the Nexys build.
## Keep the get_cells queries inline: Vivado defers XDC constraints until after
## link_design, whereas a Tcl variable assigned while read_xdc parses the file
## is empty.  Include the T80s wrapper because its CEN-gated DI_Reg closes the
## address -> memory -> CPU input path; selecting only u_cpu/u0 misses it.
set_multicycle_path -setup 2 \
    -from [get_cells -hierarchical -filter {IS_SEQUENTIAL && NAME =~ *u_cpu/*}] \
    -to   [get_cells -hierarchical -filter {IS_SEQUENTIAL && NAME =~ *u_cpu/*}]
set_multicycle_path -hold 1 \
    -from [get_cells -hierarchical -filter {IS_SEQUENTIAL && NAME =~ *u_cpu/*}] \
    -to   [get_cells -hierarchical -filter {IS_SEQUENTIAL && NAME =~ *u_cpu/*}]

## Targeted CDC exceptions from the Nexys build. Hierarchy is below u_nascom2 here.
set_false_path -to [get_pins {u_nascom2/u_hdmi_tpg/OVERLAY_CTRL_SYNC/reg_reg[0][0]/D}]
set_false_path -to [get_pins {u_nascom2/u_hdmi_tpg/OVERLAY_CTRL_SYNC/reg_reg[0][1]/D}]
set_false_path -to [get_pins {u_nascom2/u_hdmi_tpg/OVERLAY_CTRL_SYNC/reg_reg[0][2]/D}]
set_false_path -to [get_pins {u_nascom2/u_hdmi_tpg/OVERLAY_CTRL_SYNC/reg_reg[0][3]/D}]
set_false_path -to [get_pins {u_nascom2/u_hdmi_tpg/OVERLAY_CTRL_SYNC/reg_reg[0][4]/D}]
set_false_path -to [get_pins {u_nascom2/u_hdmi_tpg/OVERLAY_CTRL_SYNC/reg_reg[0][5]/D}]
set_false_path -to [get_pins {u_nascom2/u_hdmi_tpg/OVERLAY_CTRL_SYNC/reg_reg[0][6]/D}]
set_false_path -to [get_pins {u_nascom2/u_hdmi_tpg/OVERLAY_CTRL_SYNC/reg_reg[0][7]/D}]

## AVC display control bits 3..7 and the CRTC start address cross from CLK_IN
## to the pixel clock. Bits 0..2 are CPU-side plane selectors and are optimized
## out of this synchronizer. Only the first stage of the two-stage ASYNC_REG
## synchronizer is asynchronous.
set_false_path -to [get_pins {u_nascom2/u_hdmi_tpg/AVC_CTRL_SYNC/reg_reg[0][3]/D}]
set_false_path -to [get_pins {u_nascom2/u_hdmi_tpg/AVC_CTRL_SYNC/reg_reg[0][4]/D}]
set_false_path -to [get_pins {u_nascom2/u_hdmi_tpg/AVC_CTRL_SYNC/reg_reg[0][5]/D}]
set_false_path -to [get_pins {u_nascom2/u_hdmi_tpg/AVC_CTRL_SYNC/reg_reg[0][6]/D}]
set_false_path -to [get_pins {u_nascom2/u_hdmi_tpg/AVC_CTRL_SYNC/reg_reg[0][7]/D}]
set_false_path -to [get_pins {u_nascom2/u_hdmi_tpg/AVC_CTRL_SYNC/reg_reg[0][8]/D}]
set_false_path -to [get_pins {u_nascom2/u_hdmi_tpg/AVC_CTRL_SYNC/reg_reg[0][9]/D}]
set_false_path -to [get_pins {u_nascom2/u_hdmi_tpg/AVC_CTRL_SYNC/reg_reg[0][10]/D}]
set_false_path -to [get_pins {u_nascom2/u_hdmi_tpg/AVC_CTRL_SYNC/reg_reg[0][11]/D}]
set_false_path -to [get_pins {u_nascom2/u_hdmi_tpg/AVC_CTRL_SYNC/reg_reg[0][12]/D}]
set_false_path -to [get_pins {u_nascom2/u_hdmi_tpg/AVC_CTRL_SYNC/reg_reg[0][13]/D}]
set_false_path -to [get_pins {u_nascom2/u_hdmi_tpg/AVC_CTRL_SYNC/reg_reg[0][14]/D}]
set_false_path -to [get_pins {u_nascom2/u_hdmi_tpg/AVC_CTRL_SYNC/reg_reg[0][15]/D}]
set_false_path -to [get_pins {u_nascom2/u_hdmi_tpg/AVC_CTRL_SYNC/reg_reg[0][16]/D}]
set_false_path -to [get_pins {u_nascom2/u_hdmi_tpg/AVC_CTRL_SYNC/reg_reg[0][17]/D}]
set_false_path -to [get_pins {u_nascom2/u_hdmi_tpg/AVC_CTRL_SYNC/reg_reg[0][18]/D}]
set_false_path -to [get_pins {u_nascom2/u_hdmi_tpg/AVC_CTRL_SYNC/reg_reg[0][19]/D}]
set_false_path -to [get_pins {u_nascom2/u_hdmi_tpg/AVC_CTRL_SYNC/reg_reg[0][20]/D}]
set_false_path -to [get_pins {u_nascom2/u_hdmi_tpg/AVC_CTRL_SYNC/reg_reg[0][21]/D}]

# General purpose LED on mother board
set_property -dict {PACKAGE_PIN U22 IOSTANDARD LVCMOS33} [get_ports led]
# On board LEDs direct connected to main FPGA on R4, not via MAX10
#set_property -dict {PACKAGE_PIN V19 IOSTANDARD LVCMOS33} [get_ports led_g]
#set_property -dict {PACKAGE_PIN V20 IOSTANDARD LVCMOS33} [get_ports led_r]

## Reset button
set_property -dict { PACKAGE_PIN J19 IOSTANDARD LVCMOS33 } [get_ports { reset_button }]

## MEGA65 keyboard interface
set_property -dict { PACKAGE_PIN A14 IOSTANDARD LVCMOS33 } [get_ports { kb_io0 }]
set_property -dict { PACKAGE_PIN A13 IOSTANDARD LVCMOS33 } [get_ports { kb_io1 }]
set_property -dict { PACKAGE_PIN C13 IOSTANDARD LVCMOS33 } [get_ports { kb_io2 }]
## General purpose LED on mother board
set_property -dict { PACKAGE_PIN U22 IOSTANDARD LVCMOS33 } [get_ports { led }]

## HDMI output
set_property PACKAGE_PIN W1 [get_ports { TMDS_clk_p }]
set_property IOSTANDARD TMDS_33 [get_ports { TMDS_clk_p }]
set_property PACKAGE_PIN Y1 [get_ports { TMDS_clk_n }]
set_property IOSTANDARD TMDS_33 [get_ports { TMDS_clk_n }]

set_property PACKAGE_PIN AA1 [get_ports { TMDS_data_p[0] }]
set_property IOSTANDARD TMDS_33 [get_ports { TMDS_data_p[0] }]
set_property PACKAGE_PIN AB1 [get_ports { TMDS_data_n[0] }]
set_property IOSTANDARD TMDS_33 [get_ports { TMDS_data_n[0] }]

set_property PACKAGE_PIN AB3 [get_ports { TMDS_data_p[1] }]
set_property IOSTANDARD TMDS_33 [get_ports { TMDS_data_p[1] }]
set_property PACKAGE_PIN AB2 [get_ports { TMDS_data_n[1] }]
set_property IOSTANDARD TMDS_33 [get_ports { TMDS_data_n[1] }]

set_property PACKAGE_PIN AA5 [get_ports { TMDS_data_p[2] }]
set_property IOSTANDARD TMDS_33 [get_ports { TMDS_data_p[2] }]
set_property PACKAGE_PIN AB5 [get_ports { TMDS_data_n[2] }]
set_property IOSTANDARD TMDS_33 [get_ports { TMDS_data_n[2] }]

set_property -dict { PACKAGE_PIN AB8 IOSTANDARD LVCMOS33 } [get_ports { hdmi_enable_n }]
set_property -dict { PACKAGE_PIN M15 IOSTANDARD LVCMOS33 } [get_ports { hdmi_hiz }]
set_property -dict { PACKAGE_PIN Y8  IOSTANDARD LVCMOS33 } [get_ports { hpd_a }]

## UART
set_property -dict { PACKAGE_PIN L13 IOSTANDARD LVCMOS33 } [get_ports { UART_TXD }]
set_property -dict { PACKAGE_PIN L14 IOSTANDARD LVCMOS33 } [get_ports { RsRx }]

## Direct joystick inputs and the R6 shared cartridge/joystick interface.
set_property -dict {PACKAGE_PIN T21 IOSTANDARD LVCMOS33} [get_ports {cart_and_joy_en}]
set_property -dict {PACKAGE_PIN F16 IOSTANDARD LVCMOS33} [get_ports {fa_down_n_i}]
set_property -dict {PACKAGE_PIN E17 IOSTANDARD LVCMOS33} [get_ports {fa_fire_n_i}]
set_property -dict {PACKAGE_PIN F14 IOSTANDARD LVCMOS33} [get_ports {fa_left_n_i}]
set_property -dict {PACKAGE_PIN F13 IOSTANDARD LVCMOS33} [get_ports {fa_right_n_i}]
set_property -dict {PACKAGE_PIN C14 IOSTANDARD LVCMOS33} [get_ports {fa_up_n_i}]
set_property -dict {PACKAGE_PIN P17 IOSTANDARD LVCMOS33} [get_ports {fb_down_n_i}]
set_property -dict {PACKAGE_PIN F15 IOSTANDARD LVCMOS33} [get_ports {fb_fire_n_i}]
set_property -dict {PACKAGE_PIN F21 IOSTANDARD LVCMOS33} [get_ports {fb_left_n_i}]
set_property -dict {PACKAGE_PIN C15 IOSTANDARD LVCMOS33} [get_ports {fb_right_n_i}]
set_property -dict {PACKAGE_PIN W19 IOSTANDARD LVCMOS33} [get_ports {fb_up_n_i}]
set_property -dict {PACKAGE_PIN K14 IOSTANDARD LVCMOS33} [get_ports {fa_down_drain_n}]
set_property -dict {PACKAGE_PIN J17 IOSTANDARD LVCMOS33} [get_ports {fa_fire_drain_n}]
set_property -dict {PACKAGE_PIN K13 IOSTANDARD LVCMOS33} [get_ports {fa_left_drain_n}]
set_property -dict {PACKAGE_PIN L16 IOSTANDARD LVCMOS33} [get_ports {fa_right_drain_n}]
set_property -dict {PACKAGE_PIN G16 IOSTANDARD LVCMOS33} [get_ports {fa_up_drain_n}]
set_property -dict {PACKAGE_PIN M18 IOSTANDARD LVCMOS33} [get_ports {fb_down_drain_n}]
set_property -dict {PACKAGE_PIN N19 IOSTANDARD LVCMOS33} [get_ports {fb_fire_drain_n}]
set_property -dict {PACKAGE_PIN M17 IOSTANDARD LVCMOS33} [get_ports {fb_left_drain_n}]
set_property -dict {PACKAGE_PIN E18 IOSTANDARD LVCMOS33} [get_ports {fb_right_drain_n}]
set_property -dict {PACKAGE_PIN N20 IOSTANDARD LVCMOS33} [get_ports {fb_up_drain_n}]

## SMSC Ethernet PHY (RMII), MEGA65 R6 primary network target
set_property -dict { PACKAGE_PIN P4 IOSTANDARD LVCMOS33 } [get_ports { eth_rxd[0] }]
set_property -dict { PACKAGE_PIN L1 IOSTANDARD LVCMOS33 } [get_ports { eth_rxd[1] }]
set_property -dict { PACKAGE_PIN L3 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4 } [get_ports { eth_txd[0] }]
set_property -dict { PACKAGE_PIN K3 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4 } [get_ports { eth_txd[1] }]
set_property -dict { PACKAGE_PIN K4 IOSTANDARD LVCMOS33 } [get_ports { eth_rxdv }]
set_property -dict { PACKAGE_PIN J6 IOSTANDARD LVCMOS33 } [get_ports { eth_mdc }]
set_property -dict { PACKAGE_PIN L5 IOSTANDARD LVCMOS33 } [get_ports { eth_mdio }]
set_property -dict { PACKAGE_PIN L4 IOSTANDARD LVCMOS33 SLEW FAST } [get_ports { eth_clock }]
set_property -dict { PACKAGE_PIN K6 IOSTANDARD LVCMOS33 } [get_ports { eth_reset }]
set_property -dict { PACKAGE_PIN J4 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4 } [get_ports { eth_txen }]
set_property -dict { PACKAGE_PIN M6 IOSTANDARD LVCMOS33 } [get_ports { eth_rxer }]
create_generated_clock -name eth_rmii_ref -divide_by 2 -source [get_ports { CLK_IN }] [get_ports { eth_clock }]
## RX is captured by phase-selected 200 MHz IOB registers.  The phase selector
## supplies the source-synchronous setup/hold margin; constrain the physical
## port-to-IOB datapath itself so implementation cannot route it through fabric.
set_max_delay 2.5 -datapath_only -from [get_ports { eth_rxd[1] eth_rxd[0] eth_rxdv eth_rxer }]
## RMII TX is launched on the falling REF_CLK edge.  The PHY requires data
## setup/hold around the following rising edge.
set_output_delay -clock [get_clocks eth_rmii_ref] -max 4.0 [get_ports { eth_txd[1] eth_txd[0] eth_txen }]
set_output_delay -clock [get_clocks eth_rmii_ref] -min -2.0 [get_ports { eth_txd[1] eth_txd[0] eth_txen }]

## Mega65 external SD slot in SPI mode. sd2reset is DAT3/CS on this connector.
set_property -dict { PACKAGE_PIN G2 IOSTANDARD LVCMOS33 } [get_ports { sd2Clock }]
set_property -dict { PACKAGE_PIN K2 IOSTANDARD LVCMOS33 } [get_ports { sd2reset }]
set_property -dict { PACKAGE_PIN H2 IOSTANDARD LVCMOS33 } [get_ports { sd2MISO }]
set_property -dict { PACKAGE_PIN J2 IOSTANDARD LVCMOS33 } [get_ports { sd2MOSI }]
set_property -dict { PACKAGE_PIN H3 IOSTANDARD LVCMOS33 } [get_ports { sd2_dat[1] }]
set_property -dict { PACKAGE_PIN J1 IOSTANDARD LVCMOS33 } [get_ports { sd2_dat[2] }]
set_property -dict { PACKAGE_PIN K1 IOSTANDARD LVCMOS33 } [get_ports { sd2CD }]
set_property PULLUP true [get_ports { sd2MISO }]
set_property PULLUP true [get_ports { sd2CD }]

## Bitstream/platform settings copied from the Mega65 reference constraints.
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 66 [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR YES [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]

## Pmod Header P1
set_property -dict {PACKAGE_PIN J16 IOSTANDARD LVCMOS33} [get_ports { pmod1_en }]
set_property -dict {PACKAGE_PIN K16 IOSTANDARD LVCMOS33} [get_ports { pmod1_flag }]
# B35_L5_N
set_property -dict { PACKAGE_PIN F1 IOSTANDARD LVCMOS33 } [get_ports {p1hi_rts}]
# B35_L3_N
set_property -dict { PACKAGE_PIN D1 IOSTANDARD LVCMOS33 } [get_ports {p1hi_cts}]
# B35_L2_N
set_property -dict { PACKAGE_PIN B2 IOSTANDARD LVCMOS33 } [get_ports {p1hi_rxd}]
# B35_L1_N
set_property -dict { PACKAGE_PIN A1 IOSTANDARD LVCMOS33 } [get_ports {p1hi_txd}]
# B16_L17_P
set_property -dict { PACKAGE_PIN A18 IOSTANDARD LVCMOS33 } [get_ports {p1lo_rts}]
# B35_L3_P
set_property -dict { PACKAGE_PIN E1 IOSTANDARD LVCMOS33 } [get_ports {p1lo_cts}]
# B35_L2_P
set_property -dict { PACKAGE_PIN C2 IOSTANDARD LVCMOS33 } [get_ports {p1lo_rxd}]
# B35_L1_P
set_property -dict { PACKAGE_PIN B1 IOSTANDARD LVCMOS33 } [get_ports {p1lo_txd}]

## Pmod Header P2
set_property -dict {PACKAGE_PIN M13 IOSTANDARD LVCMOS33} [get_ports { pmod2_en }]
set_property -dict {PACKAGE_PIN K17 IOSTANDARD LVCMOS33} [get_ports { pmod2_flag }]
# B35_L6_P
set_property -dict { PACKAGE_PIN F3 IOSTANDARD LVCMOS33 } [get_ports {p2hi_rts}]
# B35_L6_N
set_property -dict { PACKAGE_PIN E3 IOSTANDARD LVCMOS33 } [get_ports {p2hi_cts}]
# B35_L12_P
set_property -dict { PACKAGE_PIN H4 IOSTANDARD LVCMOS33 } [get_ports {p2hi_rxd}]
# B35_L10_N
set_property -dict { PACKAGE_PIN H5 IOSTANDARD LVCMOS33 } [get_ports {p2hi_txd}]
# B35_L4_P
set_property -dict { PACKAGE_PIN E2 IOSTANDARD LVCMOS33 } [get_ports {p2lo_rts}]
# B35_L4_N
set_property -dict { PACKAGE_PIN D2 IOSTANDARD LVCMOS33 } [get_ports {p2lo_cts}]
# B35_L12_N
set_property -dict { PACKAGE_PIN G4 IOSTANDARD LVCMOS33 } [get_ports {p2lo_rxd}]
# B35_L10_P
set_property -dict { PACKAGE_PIN J5 IOSTANDARD LVCMOS33 } [get_ports {p2lo_txd}]

# I2C bus for on-board peripherals
set_property -dict {PACKAGE_PIN A15 IOSTANDARD LVCMOS33} [get_ports fpga_scl]
set_property -dict {PACKAGE_PIN A16 IOSTANDARD LVCMOS33} [get_ports fpga_sda]
set_property -dict {PACKAGE_PIN G21 IOSTANDARD LVCMOS33 PULLUP TRUE} [get_ports grove_scl]
set_property -dict {PACKAGE_PIN G22 IOSTANDARD LVCMOS33 PULLUP TRUE} [get_ports grove_sda]

# Audio DAC. U37 = AK4432VT (MEGA65 R6)
set_property -dict {PACKAGE_PIN D16 IOSTANDARD LVCMOS33} [get_ports {audio_mclk_o}]
set_property -dict {PACKAGE_PIN E19 IOSTANDARD LVCMOS33} [get_ports {audio_bick_o}]
set_property -dict {PACKAGE_PIN E16 IOSTANDARD LVCMOS33} [get_ports {audio_sdti_o}]
set_property -dict {PACKAGE_PIN F19 IOSTANDARD LVCMOS33} [get_ports {audio_lrclk_o}]
set_property -dict {PACKAGE_PIN F18 IOSTANDARD LVCMOS33} [get_ports {audio_pdn_n_o}]
set_property -dict {PACKAGE_PIN F4 IOSTANDARD LVCMOS33} [get_ports {audio_i2cfil_o}]
set_property -dict {PACKAGE_PIN L6 IOSTANDARD LVCMOS33} [get_ports {audio_scl_io}]
set_property -dict {PACKAGE_PIN W9 IOSTANDARD LVCMOS33} [get_ports {audio_sda_io}]

## VGA Connector

# VGA I2C bus
# set_property -dict { PACKAGE_PIN T15 IOSTANDARD LVCMOS33 } [get_ports vga_sda]
# set_property -dict { PACKAGE_PIN W15 IOSTANDARD LVCMOS33 } [get_ports vga_scl]

set_property -dict { PACKAGE_PIN AA9 IOSTANDARD LVCMOS33 } [get_ports vdac_clk]
set_property -dict { PACKAGE_PIN V10 IOSTANDARD LVCMOS33 } [get_ports vdac_sync_n]
set_property -dict { PACKAGE_PIN W11 IOSTANDARD LVCMOS33 } [get_ports vdac_blank_n]
set_property -dict { PACKAGE_PIN W16 IOSTANDARD LVCMOS33 } [get_ports vdac_psave_n]

set_property -dict { PACKAGE_PIN U15 IOSTANDARD LVCMOS33 } [get_ports { vgared[0] }]
set_property -dict { PACKAGE_PIN V15 IOSTANDARD LVCMOS33 } [get_ports { vgared[1] }]
set_property -dict { PACKAGE_PIN T14 IOSTANDARD LVCMOS33 } [get_ports { vgared[2] }]
set_property -dict { PACKAGE_PIN Y17 IOSTANDARD LVCMOS33 } [get_ports { vgared[3] }]
set_property -dict { PACKAGE_PIN Y16 IOSTANDARD LVCMOS33 } [get_ports { vgared[4] }]
set_property -dict { PACKAGE_PIN AB17 IOSTANDARD LVCMOS33 } [get_ports { vgared[5] }]
set_property -dict { PACKAGE_PIN AA16 IOSTANDARD LVCMOS33 } [get_ports { vgared[6] }]
set_property -dict { PACKAGE_PIN AB16 IOSTANDARD LVCMOS33 } [get_ports { vgared[7] }]

set_property -dict { PACKAGE_PIN Y14 IOSTANDARD LVCMOS33 } [get_ports { vgagreen[0] }]
set_property -dict { PACKAGE_PIN W14 IOSTANDARD LVCMOS33 } [get_ports { vgagreen[1] }]
set_property -dict { PACKAGE_PIN AA15 IOSTANDARD LVCMOS33 } [get_ports { vgagreen[2] }]
set_property -dict { PACKAGE_PIN AB15 IOSTANDARD LVCMOS33 } [get_ports { vgagreen[3] }]
set_property -dict { PACKAGE_PIN Y13 IOSTANDARD LVCMOS33 } [get_ports { vgagreen[4] }]
set_property -dict { PACKAGE_PIN AA14 IOSTANDARD LVCMOS33 } [get_ports { vgagreen[5] }]
set_property -dict { PACKAGE_PIN AA13 IOSTANDARD LVCMOS33 } [get_ports { vgagreen[6] }]
set_property -dict { PACKAGE_PIN AB13 IOSTANDARD LVCMOS33 } [get_ports { vgagreen[7] }]

set_property -dict { PACKAGE_PIN W10 IOSTANDARD LVCMOS33 } [get_ports { vgablue[0] }]
set_property -dict { PACKAGE_PIN Y12 IOSTANDARD LVCMOS33 } [get_ports { vgablue[1] }]
set_property -dict { PACKAGE_PIN AB12 IOSTANDARD LVCMOS33 } [get_ports { vgablue[2] }]
set_property -dict { PACKAGE_PIN AA11 IOSTANDARD LVCMOS33 } [get_ports { vgablue[3] }]
set_property -dict { PACKAGE_PIN AB11 IOSTANDARD LVCMOS33 } [get_ports { vgablue[4] }]
set_property -dict { PACKAGE_PIN Y11 IOSTANDARD LVCMOS33 } [get_ports { vgablue[5] }]
set_property -dict { PACKAGE_PIN AB10 IOSTANDARD LVCMOS33 } [get_ports { vgablue[6] }]
set_property -dict { PACKAGE_PIN AA10 IOSTANDARD LVCMOS33 } [get_ports { vgablue[7] }]

set_property -dict { PACKAGE_PIN W12 IOSTANDARD LVCMOS33 } [get_ports hsync]
set_property -dict { PACKAGE_PIN V14 IOSTANDARD LVCMOS33 } [get_ports vsync]
