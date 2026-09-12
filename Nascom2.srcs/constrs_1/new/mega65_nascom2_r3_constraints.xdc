## MEGA65 R3/R3A constraints for Nascom2
## Based on the mega65r3 target in the MEGA65 reference core.

## Clock signal, 100 MHz
set_property -dict { PACKAGE_PIN V13 IOSTANDARD LVCMOS33 } [get_ports { CLK_IN }]
create_clock -period 10.000 -name CLK_IN [get_ports { CLK_IN }]

## The AY PCM sample crosses from CLK_IN into the independent 12.288 MHz
## audio/PDM domain through a coherent stereo mailbox.
create_generated_clock -name audio_clk [get_pins {u_board_common/u_ak4432_audio/i_clk_audio/CLKOUT0}]
# Only handshake synchronizer entry points are asynchronous data paths.
set_false_path -to [get_pins -hierarchical -filter {NAME =~ *u_ak4432_audio/pcm_request_meta_reg/D || NAME =~ *u_ak4432_audio/pcm_ack_meta_reg/D}]
# Common reset asserts asynchronously; each domain releases it synchronously.
set_false_path -to [get_pins -hierarchical -filter {NAME =~ *u_ak4432_audio/*reset_*_reg/CLR || NAME =~ *u_ak4432_audio/*reset_*_reg/PRE}]
# Sample data is held until acknowledged. Keep the entire bus well inside
# one 81.38 ns destination period (capture follows two synchronizer stages).
set_max_delay -datapath_only 40.000 -from [get_cells -hierarchical -filter {NAME =~ *u_ak4432_audio/pcm_hold_reg*}] -to [get_cells -hierarchical -filter {NAME =~ *u_ak4432_audio/pcm_l_sync_reg* || NAME =~ *u_ak4432_audio/pcm_r_sync_reg*}]

## T80 core clock-enable multicycle, same rationale as the R6 and Nexys builds.
set t80_seq_cells [get_cells -hierarchical -filter {IS_SEQUENTIAL && NAME =~ *u_cpu/u0/*}]
set_multicycle_path -setup 2 -from $t80_seq_cells -to $t80_seq_cells
set_multicycle_path -hold 1  -from $t80_seq_cells -to $t80_seq_cells

## Opcode and bus-data input registers also advance only on the T80 clock
## enable.  Include their external source paths in the same conservative
## two-system-clock allowance.  Do not relax all paths into the CPU: debugger
## loads can update other registers while CEN is low and remain true 10 ns
## paths.
set t80_input_cells [get_cells -hierarchical -filter {
    IS_SEQUENTIAL &&
    (NAME =~ *u_cpu/DI_Reg_reg* || NAME =~ *u_cpu/u0/IR_reg*)
}]
set_multicycle_path -setup 2 -to $t80_input_cells
set_multicycle_path -hold 1  -to $t80_input_cells

## Targeted CDC exceptions.  R3 adds u_board_common above the R6/shared shell.
set_false_path -to [get_pins {u_board_common/u_nascom2/u_hdmi_tpg/OVERLAY_CTRL_SYNC/reg_reg[0][0]/D}]
set_false_path -to [get_pins {u_board_common/u_nascom2/u_hdmi_tpg/OVERLAY_CTRL_SYNC/reg_reg[0][1]/D}]
set_false_path -to [get_pins {u_board_common/u_nascom2/u_hdmi_tpg/OVERLAY_CTRL_SYNC/reg_reg[0][2]/D}]
set_false_path -to [get_pins {u_board_common/u_nascom2/u_hdmi_tpg/OVERLAY_CTRL_SYNC/reg_reg[0][3]/D}]
set_false_path -to [get_pins {u_board_common/u_nascom2/u_hdmi_tpg/OVERLAY_CTRL_SYNC/reg_reg[0][4]/D}]
set_false_path -to [get_pins {u_board_common/u_nascom2/u_hdmi_tpg/OVERLAY_CTRL_SYNC/reg_reg[0][5]/D}]
set_false_path -to [get_pins {u_board_common/u_nascom2/u_hdmi_tpg/OVERLAY_CTRL_SYNC/reg_reg[0][6]/D}]
set_false_path -to [get_pins {u_board_common/u_nascom2/u_hdmi_tpg/OVERLAY_CTRL_SYNC/reg_reg[0][7]/D}]

set_false_path -to [get_pins {u_board_common/u_nascom2/u_hdmi_tpg/AVC_CTRL_SYNC/reg_reg[0][3]/D}]
set_false_path -to [get_pins {u_board_common/u_nascom2/u_hdmi_tpg/AVC_CTRL_SYNC/reg_reg[0][4]/D}]
set_false_path -to [get_pins {u_board_common/u_nascom2/u_hdmi_tpg/AVC_CTRL_SYNC/reg_reg[0][5]/D}]
set_false_path -to [get_pins {u_board_common/u_nascom2/u_hdmi_tpg/AVC_CTRL_SYNC/reg_reg[0][6]/D}]
set_false_path -to [get_pins {u_board_common/u_nascom2/u_hdmi_tpg/AVC_CTRL_SYNC/reg_reg[0][7]/D}]
set_false_path -to [get_pins {u_board_common/u_nascom2/u_hdmi_tpg/AVC_CTRL_SYNC/reg_reg[0][8]/D}]
set_false_path -to [get_pins {u_board_common/u_nascom2/u_hdmi_tpg/AVC_CTRL_SYNC/reg_reg[0][9]/D}]
set_false_path -to [get_pins {u_board_common/u_nascom2/u_hdmi_tpg/AVC_CTRL_SYNC/reg_reg[0][10]/D}]
set_false_path -to [get_pins {u_board_common/u_nascom2/u_hdmi_tpg/AVC_CTRL_SYNC/reg_reg[0][11]/D}]
set_false_path -to [get_pins {u_board_common/u_nascom2/u_hdmi_tpg/AVC_CTRL_SYNC/reg_reg[0][12]/D}]
set_false_path -to [get_pins {u_board_common/u_nascom2/u_hdmi_tpg/AVC_CTRL_SYNC/reg_reg[0][13]/D}]
set_false_path -to [get_pins {u_board_common/u_nascom2/u_hdmi_tpg/AVC_CTRL_SYNC/reg_reg[0][14]/D}]
set_false_path -to [get_pins {u_board_common/u_nascom2/u_hdmi_tpg/AVC_CTRL_SYNC/reg_reg[0][15]/D}]
set_false_path -to [get_pins {u_board_common/u_nascom2/u_hdmi_tpg/AVC_CTRL_SYNC/reg_reg[0][16]/D}]
set_false_path -to [get_pins {u_board_common/u_nascom2/u_hdmi_tpg/AVC_CTRL_SYNC/reg_reg[0][17]/D}]
set_false_path -to [get_pins {u_board_common/u_nascom2/u_hdmi_tpg/AVC_CTRL_SYNC/reg_reg[0][18]/D}]
set_false_path -to [get_pins {u_board_common/u_nascom2/u_hdmi_tpg/AVC_CTRL_SYNC/reg_reg[0][19]/D}]
set_false_path -to [get_pins {u_board_common/u_nascom2/u_hdmi_tpg/AVC_CTRL_SYNC/reg_reg[0][20]/D}]
set_false_path -to [get_pins {u_board_common/u_nascom2/u_hdmi_tpg/AVC_CTRL_SYNC/reg_reg[0][21]/D}]

## General purpose motherboard LED
set_property -dict { PACKAGE_PIN U22 IOSTANDARD LVCMOS33 } [get_ports { led }]

## MEGA65 keyboard interface
set_property -dict { PACKAGE_PIN A14 IOSTANDARD LVCMOS33 } [get_ports { kb_io0 }]
set_property -dict { PACKAGE_PIN A13 IOSTANDARD LVCMOS33 } [get_ports { kb_io1 }]
set_property -dict { PACKAGE_PIN C13 IOSTANDARD LVCMOS33 } [get_ports { kb_io2 }]

## R3/R3A MAX10 interface.  M13/K16 are not PMOD power pins on this revision.
set_property -dict { PACKAGE_PIN M13 IOSTANDARD LVCMOS33 } [get_ports { max10_tx }]
set_property -dict { PACKAGE_PIN K16 IOSTANDARD LVCMOS33 } [get_ports { max10_rx }]
set_property -dict { PACKAGE_PIN L16 IOSTANDARD LVCMOS33 } [get_ports { reset_from_max10 }]
create_pblock pblock_max10
add_cells_to_pblock pblock_max10 [get_cells [list max10]]
resize_pblock pblock_max10 -add {SLICE_X0Y150:SLICE_X7Y174}

## HDMI output
set_property -dict { PACKAGE_PIN W1  IOSTANDARD TMDS_33 } [get_ports { TMDS_clk_p }]
set_property -dict { PACKAGE_PIN Y1  IOSTANDARD TMDS_33 } [get_ports { TMDS_clk_n }]
set_property -dict { PACKAGE_PIN AA1 IOSTANDARD TMDS_33 } [get_ports { TMDS_data_p[0] }]
set_property -dict { PACKAGE_PIN AB1 IOSTANDARD TMDS_33 } [get_ports { TMDS_data_n[0] }]
set_property -dict { PACKAGE_PIN AB3 IOSTANDARD TMDS_33 } [get_ports { TMDS_data_p[1] }]
set_property -dict { PACKAGE_PIN AB2 IOSTANDARD TMDS_33 } [get_ports { TMDS_data_n[1] }]
set_property -dict { PACKAGE_PIN AA5 IOSTANDARD TMDS_33 } [get_ports { TMDS_data_p[2] }]
set_property -dict { PACKAGE_PIN AB5 IOSTANDARD TMDS_33 } [get_ports { TMDS_data_n[2] }]
set_property -dict { PACKAGE_PIN AB8 IOSTANDARD LVCMOS33 } [get_ports { hdmi_ls_oe }]
set_property -dict { PACKAGE_PIN M15 IOSTANDARD LVCMOS33 } [get_ports { hdmi_ct_hpd }]
set_property -dict { PACKAGE_PIN Y8  IOSTANDARD LVCMOS33 } [get_ports { hdmi_hpd }]

## UART
set_property -dict { PACKAGE_PIN L13 IOSTANDARD LVCMOS33 } [get_ports { UART_TXD }]
set_property -dict { PACKAGE_PIN L14 IOSTANDARD LVCMOS33 } [get_ports { RsRx }]

## MEGA65 R3/R3A joystick ports (direct FPGA inputs, active low)
set_property -dict { PACKAGE_PIN F16 IOSTANDARD LVCMOS33 PULLUP TRUE } [get_ports { fa_down_n_i }]
set_property -dict { PACKAGE_PIN E17 IOSTANDARD LVCMOS33 PULLUP TRUE } [get_ports { fa_fire_n_i }]
set_property -dict { PACKAGE_PIN F14 IOSTANDARD LVCMOS33 PULLUP TRUE } [get_ports { fa_left_n_i }]
set_property -dict { PACKAGE_PIN F13 IOSTANDARD LVCMOS33 PULLUP TRUE } [get_ports { fa_right_n_i }]
set_property -dict { PACKAGE_PIN C14 IOSTANDARD LVCMOS33 PULLUP TRUE } [get_ports { fa_up_n_i }]
set_property -dict { PACKAGE_PIN P17 IOSTANDARD LVCMOS33 PULLUP TRUE } [get_ports { fb_down_n_i }]
set_property -dict { PACKAGE_PIN F15 IOSTANDARD LVCMOS33 PULLUP TRUE } [get_ports { fb_fire_n_i }]
set_property -dict { PACKAGE_PIN F21 IOSTANDARD LVCMOS33 PULLUP TRUE } [get_ports { fb_left_n_i }]
set_property -dict { PACKAGE_PIN C15 IOSTANDARD LVCMOS33 PULLUP TRUE } [get_ports { fb_right_n_i }]
set_property -dict { PACKAGE_PIN W19 IOSTANDARD LVCMOS33 PULLUP TRUE } [get_ports { fb_up_n_i }]

## MEGA65 external SD slot in SPI mode
set_property -dict { PACKAGE_PIN G2 IOSTANDARD LVCMOS33 } [get_ports { sd2Clock }]
set_property -dict { PACKAGE_PIN K2 IOSTANDARD LVCMOS33 } [get_ports { sd2reset }]
set_property -dict { PACKAGE_PIN H2 IOSTANDARD LVCMOS33 } [get_ports { sd2MISO }]
set_property -dict { PACKAGE_PIN J2 IOSTANDARD LVCMOS33 } [get_ports { sd2MOSI }]
set_property -dict { PACKAGE_PIN K1 IOSTANDARD LVCMOS33 } [get_ports { sd2CD }]
set_property PULLUP true [get_ports { sd2MISO }]
set_property PULLUP true [get_ports { sd2CD }]

## PMOD data pins.  Power control is handled outside the main FPGA on R3/R3A.
set_property -dict { PACKAGE_PIN F1 IOSTANDARD LVCMOS33 } [get_ports { p1hi_rts }]
set_property -dict { PACKAGE_PIN D1 IOSTANDARD LVCMOS33 } [get_ports { p1hi_cts }]
set_property -dict { PACKAGE_PIN B2 IOSTANDARD LVCMOS33 } [get_ports { p1hi_rxd }]
set_property -dict { PACKAGE_PIN A1 IOSTANDARD LVCMOS33 } [get_ports { p1hi_txd }]
set_property -dict { PACKAGE_PIN G1 IOSTANDARD LVCMOS33 } [get_ports { p1lo_rts }]
set_property -dict { PACKAGE_PIN E1 IOSTANDARD LVCMOS33 } [get_ports { p1lo_cts }]
set_property -dict { PACKAGE_PIN C2 IOSTANDARD LVCMOS33 } [get_ports { p1lo_rxd }]
set_property -dict { PACKAGE_PIN B1 IOSTANDARD LVCMOS33 } [get_ports { p1lo_txd }]

set_property -dict { PACKAGE_PIN F3 IOSTANDARD LVCMOS33 } [get_ports { p2hi_rts }]
set_property -dict { PACKAGE_PIN E3 IOSTANDARD LVCMOS33 } [get_ports { p2hi_cts }]
set_property -dict { PACKAGE_PIN H4 IOSTANDARD LVCMOS33 } [get_ports { p2hi_rxd }]
set_property -dict { PACKAGE_PIN H5 IOSTANDARD LVCMOS33 } [get_ports { p2hi_txd }]
set_property -dict { PACKAGE_PIN E2 IOSTANDARD LVCMOS33 } [get_ports { p2lo_rts }]
set_property -dict { PACKAGE_PIN D2 IOSTANDARD LVCMOS33 } [get_ports { p2lo_cts }]
set_property -dict { PACKAGE_PIN G4 IOSTANDARD LVCMOS33 } [get_ports { p2lo_rxd }]
set_property -dict { PACKAGE_PIN J5 IOSTANDARD LVCMOS33 } [get_ports { p2lo_txd }]

## SMSC Ethernet PHY (MEGA65 R3/R3A RMII pinout)
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

## Onboard RTC and optional external Grove DS3231 use separate I2C buses.
set_property -dict { PACKAGE_PIN A15 IOSTANDARD LVCMOS33 PULLUP TRUE } [get_ports { fpga_scl }]
set_property -dict { PACKAGE_PIN A16 IOSTANDARD LVCMOS33 PULLUP TRUE } [get_ports { fpga_sda }]
set_property -dict { PACKAGE_PIN G21 IOSTANDARD LVCMOS33 PULLUP TRUE } [get_ports { grove_scl }]
set_property -dict { PACKAGE_PIN G22 IOSTANDARD LVCMOS33 PULLUP TRUE } [get_ports { grove_sda }]

## MEGA65 analogue audio/headphone jack (one-bit delta-sigma streams)
set_property -dict { PACKAGE_PIN L6 IOSTANDARD LVCMOS33 } [get_ports { pwm_l }]
set_property -dict { PACKAGE_PIN F4 IOSTANDARD LVCMOS33 } [get_ports { pwm_r }]

## VGA connector
set_property -dict { PACKAGE_PIN AA9 IOSTANDARD LVCMOS33 } [get_ports { vdac_clk }]
set_property -dict { PACKAGE_PIN V10 IOSTANDARD LVCMOS33 } [get_ports { vdac_sync_n }]
set_property -dict { PACKAGE_PIN W11 IOSTANDARD LVCMOS33 } [get_ports { vdac_blank_n }]

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
set_property -dict { PACKAGE_PIN W12 IOSTANDARD LVCMOS33 } [get_ports { hsync }]
set_property -dict { PACKAGE_PIN V14 IOSTANDARD LVCMOS33 } [get_ports { vsync }]

## Bitstream/platform settings
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 66 [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR YES [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
