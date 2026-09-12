--------------------------------------------------------------------------------
-- hdmi_tpg.vhd                                                               --
-- HDMI video test pattern generator with audio test tone.                    --
--------------------------------------------------------------------------------
-- (C) Copyright 2022 Adam Barnes <ambarnes@gmail.com>                        --
-- This file is part of The Tyto Project. The Tyto Project is free software:  --
-- you can redistribute it and/or modify it under the terms of the GNU Lesser --
-- General Public License as published by the Free Software Foundation,       --
-- either version 3 of the License, or (at your option) any later version.    --
-- The Tyto Project is distributed in the hope that it will be useful, but    --
-- WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY --
-- or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public     --
-- License for more details. You should have received a copy of the GNU       --
-- Lesser General Public License along with The Tyto Project. If not, see     --
-- https://www.gnu.org/licenses/.                                             --
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.sd_file_pkg.ALL;

PACKAGE hdmi_tpg_pkg IS

  COMPONENT hdmi_tpg IS
    GENERIC (
      fclk : real
    );
    PORT (

      rst : IN STD_LOGIC;
      clk : IN STD_LOGIC;

      --mode_step : IN STD_LOGIC;
      mode : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      dvi : IN STD_LOGIC;
      steady : IN STD_LOGIC;
      phosphor_amber : IN STD_LOGIC;
      scanlines : IN STD_LOGIC;
      video_zoom : IN STD_LOGIC_VECTOR(1 DOWNTO 0);

      heartbeat : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      status : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);

      audio_pcm_l : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      audio_pcm_r : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

      vram_clk : OUT STD_LOGIC;
      vram_addr : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
      vram_data : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      avc_control : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      avc_terminal_mode : IN STD_LOGIC;
      avc_crtc_start_addr : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
      avc_crtc_horizontal_displayed : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      avc_crtc_max_scanline : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
      avc_crtc_cursor_start : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      avc_crtc_cursor_end : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
      avc_crtc_cursor_addr : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
      avc_vram_addr : OUT STD_LOGIC_VECTOR(14 DOWNTO 0);
      avc_red_data : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      avc_green_data : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      avc_blue_data : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      overlay_enable : IN STD_LOGIC;
      overlay_page : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      overlay_cfg_row : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      overlay_cfg_speed : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      overlay_cfg_phosphor_amber : IN STD_LOGIC;
      overlay_cfg_scanlines : IN STD_LOGIC;
      overlay_cfg_video_zoom : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      overlay_cfg_rs232 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      overlay_cfg_rs232_speed : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      overlay_cfg_rs232_flow : IN STD_LOGIC;
      overlay_cfg_slot_rom : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      overlay_cfg_fdd : IN STD_LOGIC;
      overlay_cfg_cpm : IN STD_LOGIC;
      overlay_cfg_avc : IN STD_LOGIC;
      overlay_cfg_bls : IN STD_LOGIC;
      overlay_sd_cd_raw : IN STD_LOGIC;
      overlay_sd_init_busy : IN STD_LOGIC;
      overlay_sd_init_done : IN STD_LOGIC;
      overlay_sd_init_error : IN STD_LOGIC;
      overlay_sd_read_busy : IN STD_LOGIC;
      overlay_sd_read_done : IN STD_LOGIC;
      overlay_sd_read_error : IN STD_LOGIC;
      overlay_sd_read_stage : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      overlay_sd_read_lba : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      overlay_sd_read_token : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      overlay_sd_read_count : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      overlay_sd_read_first_word : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      overlay_sd_card_block_addressing : IN STD_LOGIC;
      overlay_sd_debug_read_cmd17_r1 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      overlay_sd_debug_read_error_code : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      overlay_sd_last_r1 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      overlay_sd_state_code : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      overlay_sd_debug_root_current_cluster : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      overlay_sd_debug_root_next_cluster : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      overlay_sd_debug_root_sectors_left : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      overlay_sd_debug_root_scan_phase : IN STD_LOGIC;
      overlay_sd_debug_root_scan_job : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      overlay_sd_part_lba : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      overlay_sd_boot_spc : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      overlay_sd_boot_reserved : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      overlay_sd_boot_num_fats : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      overlay_sd_boot_spf : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      overlay_sd_root_dir_lba : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      overlay_sd_browser_dir_found : IN STD_LOGIC;
      overlay_sd_browser_has_files : IN STD_LOGIC;
      overlay_sd_root_total_file_count : IN INTEGER RANGE 0 TO 255;
      overlay_sd_page_valid : IN sd_page_valid_array_t;
      overlay_sd_page_name : IN sd_page_name_array_t;
      overlay_sd_page_kind : IN sd_page_kind_array_t;
      overlay_fdd_mount_a_valid : IN STD_LOGIC;
      overlay_fdd_mount_a_name : IN STD_LOGIC_VECTOR(87 DOWNTO 0);
      overlay_fdd_mount_b_valid : IN STD_LOGIC;
      overlay_fdd_mount_b_name : IN STD_LOGIC_VECTOR(87 DOWNTO 0);
      overlay_sd_page_base : IN INTEGER RANGE 0 TO SD_BROWSER_LAST_INDEX;
      overlay_sd_page_row : IN INTEGER RANGE 0 TO SD_BROWSER_PAGE_LAST;
      overlay_sd_file_load_addr_valid : IN STD_LOGIC;
      overlay_sd_file_load_addr : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      overlay_browser_manage_mode : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      overlay_browser_manage_name : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
      overlay_browser_manage_status : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      overlay_tape_led_active : IN STD_LOGIC;
      overlay_halt_active : IN STD_LOGIC;
      overlay_god_af : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      overlay_god_af_alt : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      overlay_god_bc : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      overlay_god_de : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      overlay_god_hl : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      overlay_god_bc_alt : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      overlay_god_de_alt : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      overlay_god_hl_alt : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      overlay_god_ix : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      overlay_god_iy : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      overlay_god_sp : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      overlay_god_pc : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      overlay_bls_fault : IN STD_LOGIC;
      overlay_bls_fault_from_pc : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      overlay_bls_fault_to_pc : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      overlay_bls_fault_sp : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      overlay_god_i : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      overlay_god_r : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      overlay_god_ir : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      overlay_god_im : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      overlay_god_iff : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      overlay_god_mc : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      overlay_god_ts : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      overlay_god_reset_count : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      overlay_god_ui_reset_count : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      overlay_god_cfg_reset_count : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      overlay_god_mem_base : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      overlay_god_mem_cursor : IN INTEGER RANGE 0 TO 63;
      overlay_god_mem_data : IN STD_LOGIC_VECTOR(511 DOWNTO 0);
      overlay_god_edit_high : IN STD_LOGIC;
      overlay_god_high_nibble : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      overlay_god_addr_edit : IN STD_LOGIC;
      overlay_god_addr_digit : IN INTEGER RANGE 0 TO 3;
      overlay_god_addr_pending : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      overlay_diag_valid : IN STD_LOGIC;
      overlay_diag_cpm_position : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      overlay_diag_fdd_position : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      overlay_diag_cluster : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      overlay_diag_sd_lba : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      overlay_diag_sd_status : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      overlay_diag_read_count : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      overlay_diag_first_word : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      overlay_key_make_code : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      overlay_key_make_extended : IN STD_LOGIC;
      overlay_key_make_ctrl : IN STD_LOGIC;
      overlay_key_make_shift_l : IN STD_LOGIC;
      overlay_key_make_shift_r : IN STD_LOGIC;
      overlay_key_make_nmi_match : IN STD_LOGIC;
      overlay_key_make_count : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      overlay_pmod_fault_active : IN STD_LOGIC;
      overlay_pmod_fault_pmod2 : IN STD_LOGIC;
      overlay_cfg_dirty : IN STD_LOGIC;
      overlay_cfg_apply_pending : IN STD_LOGIC;
      overlay_cfg_apply_error : IN STD_LOGIC;
      overlay_cfg_load_busy : IN STD_LOGIC;
      overlay_cfg_load_pending : IN STD_LOGIC;
      overlay_cfg_load_seen : IN STD_LOGIC;
      overlay_cfg_load_ok : IN STD_LOGIC;
      overlay_cfg_load_error : IN STD_LOGIC;
      overlay_save_name : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
      overlay_save_row_sel : IN INTEGER RANGE 0 TO 4;
      overlay_save_mode_basic : IN STD_LOGIC;
      overlay_save_mode_bls : IN STD_LOGIC;
      overlay_save_start_addr_digit : IN INTEGER RANGE 0 TO 3;
      overlay_save_end_addr_digit : IN INTEGER RANGE 0 TO 3;
      overlay_save_start_addr_manual : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      overlay_save_end_addr_manual : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      overlay_save_basic_available : IN STD_LOGIC;
      overlay_save_basic_ready : IN STD_LOGIC;
      overlay_save_basic_start_addr : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      overlay_save_basic_end_addr : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      overlay_save_effective_start_addr : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      overlay_save_effective_end_addr : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      overlay_save_effective_len : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      overlay_save_check_busy : IN STD_LOGIC;
      overlay_save_checked : IN STD_LOGIC;
      overlay_save_name_exists : IN STD_LOGIC;
      overlay_save_check_can_create : IN STD_LOGIC;
      overlay_save_check_can_allocate : IN STD_LOGIC;
      overlay_save_check_requires_dir_growth : IN STD_LOGIC;
      overlay_save_check_dir_full : IN STD_LOGIC;
      overlay_save_overwrite_confirmed : IN STD_LOGIC;
      overlay_save_ready_to_write : IN STD_LOGIC;
      overlay_save_write_after_check : IN STD_LOGIC;
      overlay_save_write_busy : IN STD_LOGIC;
      overlay_save_write_done : IN STD_LOGIC;
      overlay_save_write_error : IN STD_LOGIC;
      overlay_save_write_status : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      hdmi_clk_p : OUT STD_LOGIC;
      hdmi_clk_n : OUT STD_LOGIC;
      hdmi_d_p : OUT STD_LOGIC_VECTOR(0 TO 2);
      hdmi_d_n : OUT STD_LOGIC_VECTOR(0 TO 2);
      vga_clk_out : OUT STD_LOGIC;
      vga_blank_n_out : OUT STD_LOGIC;
      vga_sync_n_out : OUT STD_LOGIC;
      vga_psave_n_out : OUT STD_LOGIC;
      vga_red_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      vga_green_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      vga_blue_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      vga_hsync_out : OUT STD_LOGIC;
      vga_vsync_out : OUT STD_LOGIC
    );
  END COMPONENT hdmi_tpg;

END PACKAGE hdmi_tpg_pkg;

--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY unisim;
USE unisim.vcomponents.ALL;

LIBRARY xpm;
USE xpm.vcomponents.ALL;

LIBRARY work;
USE work.tyto_types_pkg.ALL;
USE work.video_mode_pkg.ALL;
USE work.video_out_clock_pkg.ALL;
USE work.video_out_timing_pkg.ALL;
USE work.sync_reg_pkg.ALL;
USE work.hdmi_tx_selectio_pkg.ALL;
USE work.charrom_image_pkg.ALL;
USE work.nascom_logo_pkg.ALL;
USE work.help_overlay_pkg.ALL;
USE work.sd_file_pkg.ALL;

ENTITY hdmi_tpg IS
  GENERIC (
    fclk : real -- clock frequency (MHz), typically 100.0
  );
  PORT (

    rst : IN STD_LOGIC; -- reference/system reset (synchronous)
    clk : IN STD_LOGIC; -- reference/system clock

    --mode_step : IN STD_LOGIC; -- video mode step (e.g. button)
    mode : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); -- current video mode
    dvi : IN STD_LOGIC; -- 1 = DVI, 0 = HDMI
    steady : IN STD_LOGIC; -- 1 = steady tone, 0 = alternating
    phosphor_amber : IN STD_LOGIC; -- 1 = amber phosphor, 0 = green phosphor
    scanlines : IN STD_LOGIC; -- 1 = scanline dimming enabled
    video_zoom : IN STD_LOGIC_VECTOR(1 DOWNTO 0); -- 00=100%, 01=150%, 10=200%

    heartbeat : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    status : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);

    audio_pcm_l : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    audio_pcm_r : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

    vram_clk : OUT STD_LOGIC;
    vram_addr : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
    vram_data : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    avc_control : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    avc_terminal_mode : IN STD_LOGIC;
    avc_crtc_start_addr : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
    avc_crtc_horizontal_displayed : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    avc_crtc_max_scanline : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    avc_crtc_cursor_start : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    avc_crtc_cursor_end : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    avc_crtc_cursor_addr : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
    avc_vram_addr : OUT STD_LOGIC_VECTOR(14 DOWNTO 0);
    avc_red_data : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    avc_green_data : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    avc_blue_data : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    overlay_enable : IN STD_LOGIC;
    overlay_page : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    overlay_cfg_row : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    overlay_cfg_speed : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    overlay_cfg_phosphor_amber : IN STD_LOGIC;
    overlay_cfg_scanlines : IN STD_LOGIC;
    overlay_cfg_video_zoom : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    overlay_cfg_rs232 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    overlay_cfg_rs232_speed : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    overlay_cfg_rs232_flow : IN STD_LOGIC;
    overlay_cfg_slot_rom : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    overlay_cfg_fdd : IN STD_LOGIC;
    overlay_cfg_cpm : IN STD_LOGIC;
    overlay_cfg_avc : IN STD_LOGIC;
    overlay_cfg_bls : IN STD_LOGIC;
    overlay_sd_cd_raw : IN STD_LOGIC;
    overlay_sd_init_busy : IN STD_LOGIC;
    overlay_sd_init_done : IN STD_LOGIC;
    overlay_sd_init_error : IN STD_LOGIC;
    overlay_sd_read_busy : IN STD_LOGIC;
    overlay_sd_read_done : IN STD_LOGIC;
    overlay_sd_read_error : IN STD_LOGIC;
    overlay_sd_read_stage : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    overlay_sd_read_lba : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    overlay_sd_read_token : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    overlay_sd_read_count : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    overlay_sd_read_first_word : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    overlay_sd_card_block_addressing : IN STD_LOGIC;
    overlay_sd_debug_read_cmd17_r1 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    overlay_sd_debug_read_error_code : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    overlay_sd_last_r1 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    overlay_sd_state_code : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    overlay_sd_debug_root_current_cluster : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    overlay_sd_debug_root_next_cluster : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    overlay_sd_debug_root_sectors_left : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    overlay_sd_debug_root_scan_phase : IN STD_LOGIC;
    overlay_sd_debug_root_scan_job : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    overlay_sd_part_lba : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    overlay_sd_boot_spc : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    overlay_sd_boot_reserved : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    overlay_sd_boot_num_fats : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    overlay_sd_boot_spf : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    overlay_sd_root_dir_lba : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    overlay_sd_browser_dir_found : IN STD_LOGIC;
    overlay_sd_browser_has_files : IN STD_LOGIC;
    overlay_sd_root_total_file_count : IN INTEGER RANGE 0 TO 255;
    overlay_sd_page_valid : IN sd_page_valid_array_t;
    overlay_sd_page_name : IN sd_page_name_array_t;
    overlay_sd_page_kind : IN sd_page_kind_array_t;
    overlay_fdd_mount_a_valid : IN STD_LOGIC;
    overlay_fdd_mount_a_name : IN STD_LOGIC_VECTOR(87 DOWNTO 0);
    overlay_fdd_mount_b_valid : IN STD_LOGIC;
    overlay_fdd_mount_b_name : IN STD_LOGIC_VECTOR(87 DOWNTO 0);
    overlay_sd_page_base : IN INTEGER RANGE 0 TO SD_BROWSER_LAST_INDEX;
    overlay_sd_page_row : IN INTEGER RANGE 0 TO SD_BROWSER_PAGE_LAST;
    overlay_sd_file_load_addr_valid : IN STD_LOGIC;
    overlay_sd_file_load_addr : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    overlay_browser_manage_mode : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    overlay_browser_manage_name : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    overlay_browser_manage_status : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    overlay_pmod_fault_active : IN STD_LOGIC;
    overlay_pmod_fault_pmod2 : IN STD_LOGIC;
    overlay_cfg_dirty : IN STD_LOGIC;
    overlay_cfg_apply_pending : IN STD_LOGIC;
    overlay_cfg_apply_error : IN STD_LOGIC;
    overlay_cfg_load_busy : IN STD_LOGIC;
    overlay_cfg_load_pending : IN STD_LOGIC;
    overlay_cfg_load_seen : IN STD_LOGIC;
    overlay_cfg_load_ok : IN STD_LOGIC;
    overlay_cfg_load_error : IN STD_LOGIC;
    overlay_tape_led_active : IN STD_LOGIC;
    overlay_halt_active : IN STD_LOGIC;
    overlay_god_af : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    overlay_god_af_alt : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    overlay_god_bc : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    overlay_god_de : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    overlay_god_hl : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    overlay_god_bc_alt : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    overlay_god_de_alt : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    overlay_god_hl_alt : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    overlay_god_ix : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    overlay_god_iy : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    overlay_god_sp : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    overlay_god_pc : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    overlay_bls_fault : IN STD_LOGIC;
    overlay_bls_fault_from_pc : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    overlay_bls_fault_to_pc : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    overlay_bls_fault_sp : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    overlay_god_i : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    overlay_god_r : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    overlay_god_ir : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    overlay_god_im : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    overlay_god_iff : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    overlay_god_mc : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    overlay_god_ts : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    overlay_god_reset_count : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    overlay_god_ui_reset_count : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    overlay_god_cfg_reset_count : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    overlay_god_mem_base : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    overlay_god_mem_cursor : IN INTEGER RANGE 0 TO 63;
    overlay_god_mem_data : IN STD_LOGIC_VECTOR(511 DOWNTO 0);
    overlay_god_edit_high : IN STD_LOGIC;
    overlay_god_high_nibble : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    overlay_god_addr_edit : IN STD_LOGIC;
    overlay_god_addr_digit : IN INTEGER RANGE 0 TO 3;
    overlay_god_addr_pending : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    overlay_diag_valid : IN STD_LOGIC;
    overlay_diag_cpm_position : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    overlay_diag_fdd_position : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    overlay_diag_cluster : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    overlay_diag_sd_lba : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    overlay_diag_sd_status : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    overlay_diag_read_count : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    overlay_diag_first_word : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    overlay_key_make_code : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    overlay_key_make_extended : IN STD_LOGIC;
    overlay_key_make_ctrl : IN STD_LOGIC;
    overlay_key_make_shift_l : IN STD_LOGIC;
    overlay_key_make_shift_r : IN STD_LOGIC;
    overlay_key_make_nmi_match : IN STD_LOGIC;
    overlay_key_make_count : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    overlay_save_name : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    overlay_save_row_sel : IN INTEGER RANGE 0 TO 4;
    overlay_save_mode_basic : IN STD_LOGIC;
    overlay_save_mode_bls : IN STD_LOGIC;
    overlay_save_start_addr_digit : IN INTEGER RANGE 0 TO 3;
    overlay_save_end_addr_digit : IN INTEGER RANGE 0 TO 3;
    overlay_save_start_addr_manual : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    overlay_save_end_addr_manual : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    overlay_save_basic_available : IN STD_LOGIC;
    overlay_save_basic_ready : IN STD_LOGIC;
    overlay_save_basic_start_addr : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    overlay_save_basic_end_addr : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    overlay_save_effective_start_addr : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    overlay_save_effective_end_addr : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    overlay_save_effective_len : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    overlay_save_check_busy : IN STD_LOGIC;
    overlay_save_checked : IN STD_LOGIC;
    overlay_save_name_exists : IN STD_LOGIC;
    overlay_save_check_can_create : IN STD_LOGIC;
    overlay_save_check_can_allocate : IN STD_LOGIC;
    overlay_save_check_requires_dir_growth : IN STD_LOGIC;
    overlay_save_check_dir_full : IN STD_LOGIC;
    overlay_save_overwrite_confirmed : IN STD_LOGIC;
    overlay_save_ready_to_write : IN STD_LOGIC;
    overlay_save_write_after_check : IN STD_LOGIC;
    overlay_save_write_busy : IN STD_LOGIC;
    overlay_save_write_done : IN STD_LOGIC;
    overlay_save_write_error : IN STD_LOGIC;
    overlay_save_write_status : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    hdmi_clk_p : OUT STD_LOGIC;
    hdmi_clk_n : OUT STD_LOGIC;
    hdmi_d_p : OUT STD_LOGIC_VECTOR(0 TO 2);
    hdmi_d_n : OUT STD_LOGIC_VECTOR(0 TO 2);
    vga_clk_out : OUT STD_LOGIC;
    vga_blank_n_out : OUT STD_LOGIC;
    vga_sync_n_out : OUT STD_LOGIC;
    vga_psave_n_out : OUT STD_LOGIC;
    vga_red_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    vga_green_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    vga_blue_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    vga_hsync_out : OUT STD_LOGIC;
    vga_vsync_out : OUT STD_LOGIC
  );

END ENTITY hdmi_tpg;

ARCHITECTURE synth OF hdmi_tpg IS

  CONSTANT TEXT_PIPELINE_DEBUG : BOOLEAN := FALSE;
  -- Debug format on the first 8 visible characters of each non-overlay text row:
  -- [0] char_y  [1] wrapped screen_row  [2..4] row-start VRAM address
  -- [5..6] first fetched character byte of that row  [7] O/X row-cache match

  SUBTYPE byte_t IS STD_LOGIC_VECTOR(7 DOWNTO 0);

  SIGNAL clken_1khz : STD_LOGIC; -- 1kHz clock enable

  SIGNAL heartbeat_i : STD_LOGIC_VECTOR(3 DOWNTO 0); -- internal copy

  SIGNAL pix_rst : STD_LOGIC; -- pixel clock domain reset
  SIGNAL pix_clk : STD_LOGIC; -- pixel clock (25.2/27/74.25/148.5 MHz)
  SIGNAL pix_clk_x5 : STD_LOGIC; -- serial clock = pixel clock x5

  SIGNAL mode_i : STD_LOGIC_VECTOR(3 DOWNTO 0); -- internal copy
  SIGNAL mode_rst : STD_LOGIC; -- mode step related reset

  SIGNAL mode_clk_sel : STD_LOGIC_VECTOR(1 DOWNTO 0); -- pixel frequency select
  SIGNAL mode_dmt : STD_LOGIC; -- 1 = DMT, 0 = CEA
  SIGNAL mode_id : STD_LOGIC_VECTOR(7 DOWNTO 0); -- DMT ID or CEA/CTA VIC
  SIGNAL mode_pix_rep : STD_LOGIC; -- 1 = pixel doubling/repetition
  SIGNAL mode_aspect : STD_LOGIC_VECTOR(1 DOWNTO 0); -- 0x = normal, 10 = force 16:9, 11 = force 4:3
  SIGNAL mode_interlace : STD_LOGIC; -- interlaced/progressive scan
  SIGNAL mode_v_tot : STD_LOGIC_VECTOR(10 DOWNTO 0); -- vertical total lines (must be odd if interlaced)
  SIGNAL mode_v_act : STD_LOGIC_VECTOR(10 DOWNTO 0); -- vertical total lines (must be odd if interlaced)
  SIGNAL mode_v_sync : STD_LOGIC_VECTOR(2 DOWNTO 0); -- vertical sync width
  SIGNAL mode_v_bp : STD_LOGIC_VECTOR(5 DOWNTO 0); -- vertical back porch
  SIGNAL mode_h_tot : STD_LOGIC_VECTOR(11 DOWNTO 0); -- horizontal total
  SIGNAL mode_h_act : STD_LOGIC_VECTOR(10 DOWNTO 0); -- vertical total lines (must be odd if interlaced)
  SIGNAL mode_h_sync : STD_LOGIC_VECTOR(7 DOWNTO 0); -- horizontal sync width
  SIGNAL mode_h_bp : STD_LOGIC_VECTOR(7 DOWNTO 0); -- horizontal back porch
  SIGNAL mode_vs_pol : STD_LOGIC; -- vertical sync polarity (1 = high)
  SIGNAL mode_hs_pol : STD_LOGIC; -- horizontal sync polarity (1 = high)

  SIGNAL raw_f : STD_LOGIC; -- field ID
  SIGNAL raw_vs : STD_LOGIC; -- vertical sync
  SIGNAL raw_hs : STD_LOGIC; -- horizontal sync
  SIGNAL raw_vblank : STD_LOGIC; -- vertical blank
  SIGNAL raw_hblank : STD_LOGIC; -- horizontal blank
  SIGNAL raw_ax : STD_LOGIC_VECTOR(11 DOWNTO 0); -- active area X (signed)
  SIGNAL raw_ay : STD_LOGIC_VECTOR(11 DOWNTO 0); -- active area Y (signed)
  SIGNAL timing_vs : STD_LOGIC := '0'; -- VIDEO_TIMING registered into pix_clk text-raster stage
  SIGNAL timing_hs : STD_LOGIC := '0'; -- "
  SIGNAL timing_vblank : STD_LOGIC := '1'; -- "
  SIGNAL timing_hblank : STD_LOGIC := '1'; -- "
  SIGNAL timing_ax : STD_LOGIC_VECTOR(11 DOWNTO 0) := (OTHERS => '0'); -- "
  SIGNAL timing_ay : STD_LOGIC_VECTOR(11 DOWNTO 0) := (OTHERS => '0'); -- "
  SIGNAL timing_h_act : STD_LOGIC_VECTOR(10 DOWNTO 0) := (OTHERS => '0'); -- "
  SIGNAL timing_v_act : STD_LOGIC_VECTOR(10 DOWNTO 0) := (OTHERS => '0'); -- "
  SIGNAL phosphor_amber_pix : STD_LOGIC := '0'; -- phosphor mode synchronised into pix_clk
  SIGNAL scanlines_pix : STD_LOGIC := '0'; -- scanline mode synchronised into pix_clk
  SIGNAL video_zoom_pix : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";

  SIGNAL vga_vs : STD_LOGIC; -- vertical sync
  SIGNAL vga_hs : STD_LOGIC; -- horizontal sync
  SIGNAL vga_vblank : STD_LOGIC; -- vertical blank
  SIGNAL vga_hblank : STD_LOGIC; -- horizontal blank
  SIGNAL vga_r : STD_LOGIC_VECTOR(7 DOWNTO 0); -- red
  SIGNAL vga_g : STD_LOGIC_VECTOR(7 DOWNTO 0); -- green
  SIGNAL vga_b : STD_LOGIC_VECTOR(7 DOWNTO 0); -- blue
  SIGNAL raster_vs : STD_LOGIC; -- combinational raster sync before HDMI pipeline register
  SIGNAL raster_hs : STD_LOGIC; -- "
  SIGNAL raster_vblank : STD_LOGIC; -- "
  SIGNAL raster_hblank : STD_LOGIC; -- "
  SIGNAL raster_r : STD_LOGIC_VECTOR(7 DOWNTO 0); -- "
  SIGNAL raster_g : STD_LOGIC_VECTOR(7 DOWNTO 0); -- "
  SIGNAL raster_b : STD_LOGIC_VECTOR(7 DOWNTO 0); -- "
  SIGNAL text_vs_s1 : STD_LOGIC := '0'; -- text-raster stage 1 registered timing/control
  SIGNAL text_hs_s1 : STD_LOGIC := '0'; -- "
  SIGNAL text_vblank_s1 : STD_LOGIC := '1'; -- "
  SIGNAL text_hblank_s1 : STD_LOGIC := '1'; -- "
  SIGNAL text_in_text_s1 : STD_LOGIC := '0'; -- "
  SIGNAL text_overlay_enable_s1 : STD_LOGIC := '0'; -- "
  SIGNAL text_phosphor_amber_s1 : STD_LOGIC := '0'; -- "
  SIGNAL text_scanlines_s1 : STD_LOGIC := '0'; -- "
  SIGNAL text_char_x_s1 : STD_LOGIC_VECTOR(5 DOWNTO 0) := (OTHERS => '0'); -- "
  SIGNAL text_char_y_s1 : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0'); -- "
  SIGNAL text_screen_row_s1 : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0'); -- "
  SIGNAL text_vram_addr_s1 : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0'); -- "
  SIGNAL text_glyph_x_s1 : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0'); -- "
  SIGNAL text_glyph_y_s1 : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0'); -- "
  SIGNAL text_vs_s2 : STD_LOGIC := '0'; -- text-raster stage 2 registered delay for sync VRAM read
  SIGNAL text_hs_s2 : STD_LOGIC := '0'; -- "
  SIGNAL text_vblank_s2 : STD_LOGIC := '1'; -- "
  SIGNAL text_hblank_s2 : STD_LOGIC := '1'; -- "
  SIGNAL text_in_text_s2 : STD_LOGIC := '0'; -- "
  SIGNAL text_overlay_enable_s2 : STD_LOGIC := '0'; -- "
  SIGNAL text_phosphor_amber_s2 : STD_LOGIC := '0'; -- "
  SIGNAL text_scanlines_s2 : STD_LOGIC := '0'; -- "
  SIGNAL text_char_x_s2 : STD_LOGIC_VECTOR(5 DOWNTO 0) := (OTHERS => '0'); -- "
  SIGNAL text_char_y_s2 : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0'); -- "
  SIGNAL text_screen_row_s2 : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0'); -- "
  SIGNAL text_vram_addr_s2 : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0'); -- "
  SIGNAL text_glyph_x_s2 : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0'); -- "
  SIGNAL text_glyph_y_s2 : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0'); -- "
  SIGNAL text_vs_s3 : STD_LOGIC := '0'; -- text-raster stage 3 registered character source selection
  SIGNAL text_hs_s3 : STD_LOGIC := '0'; -- "
  SIGNAL text_vblank_s3 : STD_LOGIC := '1'; -- "
  SIGNAL text_hblank_s3 : STD_LOGIC := '1'; -- "
  SIGNAL text_in_text_s3 : STD_LOGIC := '0'; -- "
  SIGNAL text_overlay_enable_s3 : STD_LOGIC := '0'; -- "
  SIGNAL text_phosphor_amber_s3 : STD_LOGIC := '0'; -- "
  SIGNAL text_scanlines_s3 : STD_LOGIC := '0'; -- "
  SIGNAL text_char_x_s3 : STD_LOGIC_VECTOR(5 DOWNTO 0) := (OTHERS => '0'); -- "
  SIGNAL text_char_y_s3 : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0'); -- "
  SIGNAL text_glyph_x_s3 : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0'); -- "
  SIGNAL text_glyph_y_s3 : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0'); -- "
  SIGNAL text_char_code_s3 : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0'); -- "
  SIGNAL text_debug_row_char_y : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
  SIGNAL text_debug_row_screen_row : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
  SIGNAL text_debug_row_vram_addr : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
  SIGNAL text_debug_row_first_char : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"20";
  SIGNAL text_vs_s4 : STD_LOGIC := '0'; -- text-raster stage 4 registered glyph/pixel result
  SIGNAL text_hs_s4 : STD_LOGIC := '0'; -- "
  SIGNAL text_vblank_s4 : STD_LOGIC := '1'; -- "
  SIGNAL text_hblank_s4 : STD_LOGIC := '1'; -- "
  SIGNAL text_in_text_s4 : STD_LOGIC := '0'; -- "
  SIGNAL text_phosphor_amber_s4 : STD_LOGIC := '0'; -- "
  SIGNAL text_scanlines_s4 : STD_LOGIC := '0'; -- "
  SIGNAL text_pixel_on_s4 : STD_LOGIC := '0'; -- "
  SIGNAL text_scanline_odd_s4 : STD_LOGIC := '0'; -- "
  SIGNAL text_in_tape_s1 : STD_LOGIC := '0';
  SIGNAL text_in_tape_s2 : STD_LOGIC := '0';
  SIGNAL text_in_tape_s3 : STD_LOGIC := '0';
  SIGNAL avc_ctrl_sys : STD_LOGIC_VECTOR(63 DOWNTO 0) := (OTHERS => '0');
  SIGNAL avc_ctrl_pix : STD_LOGIC_VECTOR(63 DOWNTO 0) := (OTHERS => '0');
  SIGNAL avc_control_pix : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"80";
  SIGNAL avc_terminal_mode_pix : STD_LOGIC := '0';
  SIGNAL avc_start_addr_pix : STD_LOGIC_VECTOR(14 DOWNTO 0) := (OTHERS => '0');
  SIGNAL avc_horizontal_displayed_pix : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
  SIGNAL avc_max_scanline_pix : STD_LOGIC_VECTOR(4 DOWNTO 0) := (OTHERS => '0');
  SIGNAL avc_cursor_start_pix : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
  SIGNAL avc_cursor_end_pix : STD_LOGIC_VECTOR(4 DOWNTO 0) := (OTHERS => '0');
  SIGNAL avc_cursor_addr_pix : STD_LOGIC_VECTOR(13 DOWNTO 0) := (OTHERS => '0');
  SIGNAL avc_cursor_frame_count : UNSIGNED(5 DOWNTO 0) := (OTHERS => '0');
  SIGNAL avc_cursor_vblank_last : STD_LOGIC := '1';
  SIGNAL avc_cursor_row_addr : UNSIGNED(13 DOWNTO 0) := (OTHERS => '0');
  SIGNAL avc_cursor_raster : UNSIGNED(4 DOWNTO 0) := (OTHERS => '0');
  SIGNAL avc_cursor_last_source_y : INTEGER RANGE -1 TO 511 := -1;
  SIGNAL avc_in_graphics_s1 : STD_LOGIC := '0';
  SIGNAL avc_bit_x_s1 : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
  SIGNAL avc_blue_bit_x_s1 : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
  SIGNAL avc_double_s1 : STD_LOGIC := '0';
  SIGNAL avc_high_green_s1 : STD_LOGIC := '0';
  SIGNAL avc_scanline_odd_s1 : STD_LOGIC := '0';
  SIGNAL avc_cursor_on_s1 : STD_LOGIC := '0';
  SIGNAL avc_in_graphics_s2 : STD_LOGIC := '0';
  SIGNAL avc_bit_x_s2 : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
  SIGNAL avc_blue_bit_x_s2 : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
  SIGNAL avc_double_s2 : STD_LOGIC := '0';
  SIGNAL avc_high_green_s2 : STD_LOGIC := '0';
  SIGNAL avc_scanline_odd_s2 : STD_LOGIC := '0';
  SIGNAL avc_cursor_on_s2 : STD_LOGIC := '0';
  SIGNAL avc_in_graphics_s3 : STD_LOGIC := '0';
  SIGNAL avc_red_on_s3 : STD_LOGIC := '0';
  SIGNAL avc_green_on_s3 : STD_LOGIC := '0';
  SIGNAL avc_blue_on_s3 : STD_LOGIC := '0';
  SIGNAL avc_scanline_odd_s3 : STD_LOGIC := '0';
  SIGNAL avc_cursor_on_s3 : STD_LOGIC := '0';
  SIGNAL avc_in_graphics_s4 : STD_LOGIC := '0';
  SIGNAL avc_red_on_s4 : STD_LOGIC := '0';
  SIGNAL avc_green_on_s4 : STD_LOGIC := '0';
  SIGNAL avc_blue_on_s4 : STD_LOGIC := '0';
  SIGNAL avc_scanline_odd_s4 : STD_LOGIC := '0';
  SIGNAL avc_cursor_on_s4 : STD_LOGIC := '0';

  SIGNAL audio_pcm_l_sync : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL audio_pcm_r_sync : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL audio_pcm_valid_sync : STD_LOGIC := '0';

  SIGNAL tmds : slv_9_0_t(0 TO 2); -- parallel TMDS channels
  -- Active-first 800x600 raster position used by the proven HDMI packet
  -- scheduler (active 0..799/0..599, then front porch, sync and back porch).
  SIGNAL hdmi_x_pos : UNSIGNED(10 DOWNTO 0) := (OTHERS => '0');
  SIGNAL hdmi_y_pos : UNSIGNED(9 DOWNTO 0) := (OTHERS => '0');
  SIGNAL hdmi_hblank_last : STD_LOGIC := '1';
  SIGNAL hdmi_vblank_last : STD_LOGIC := '1';
  SIGNAL hdmi_de : STD_LOGIC := '0';
  SIGNAL hdmi_hs : STD_LOGIC := '0';
  SIGNAL hdmi_vs : STD_LOGIC := '0';

  SIGNAL hdmi_clk : STD_LOGIC; -- single ended prior to diff buffers
  SIGNAL hdmi_d : STD_LOGIC_VECTOR(0 TO 2); -- "

  SIGNAL overlay_enable_pix : STD_LOGIC := '0';
  SIGNAL tape_led_active_pix : STD_LOGIC := '0';
  SIGNAL halt_active_pix : STD_LOGIC := '0';
  SIGNAL pmod_fault_active_pix : STD_LOGIC := '0';
  SIGNAL pmod_fault_pmod2_pix : STD_LOGIC := '0';
  SIGNAL overlay_ctrl_sys : STD_LOGIC_VECTOR(8 DOWNTO 0) := (OTHERS => '0');
  SIGNAL overlay_ctrl_pix : STD_LOGIC_VECTOR(8 DOWNTO 0) := (OTHERS => '0');
  SIGNAL overlay_char_addr : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
  SIGNAL overlay_char_data : byte_t := x"20";
  SIGNAL overlay_char_wr_en : STD_LOGIC := '0';
  SIGNAL overlay_char_wr_addr : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
  SIGNAL overlay_char_wr_data : byte_t := x"20";
  SIGNAL overlay_line_bits_sys : STD_LOGIC_VECTOR(383 DOWNTO 0) := (OTHERS => '0');
  SIGNAL overlay_line_loaded : STD_LOGIC := '0';
  SIGNAL overlay_cache_row : INTEGER RANGE 0 TO 15 := 0;
  SIGNAL overlay_cache_col : INTEGER RANGE 0 TO 47 := 0;

  -- Exact floor(2*x/3) for every coordinate used by the 150% raster
  -- (x < 800).  The reciprocal multiply maps efficiently to a DSP and avoids
  -- the long divider/carry chain produced by the integer "/ 3" operator.
  FUNCTION scale_150(coord_v : INTEGER) RETURN INTEGER IS
    VARIABLE product_v : UNSIGNED(20 DOWNTO 0);
  BEGIN
    product_v := to_unsigned(coord_v, 10) * to_unsigned(1366, 11);
    RETURN to_integer(product_v(20 DOWNTO 11));
  END FUNCTION;

  FUNCTION pack_line_bits(line_v : text_line_t) RETURN STD_LOGIC_VECTOR IS
    VARIABLE bits_v : STD_LOGIC_VECTOR(383 DOWNTO 0) := (OTHERS => '0');
    VARIABLE byte_v : byte_t;
  BEGIN
    FOR col_i IN 0 TO 47 LOOP
      byte_v := STD_LOGIC_VECTOR(to_unsigned(CHARACTER'pos(line_v(col_i + 1)), 8));
      bits_v((col_i * 8) + 7 DOWNTO col_i * 8) := byte_v;
    END LOOP;
    RETURN bits_v;
  END FUNCTION;

  FUNCTION hex_char(nibble_v : STD_LOGIC_VECTOR(3 DOWNTO 0)) RETURN byte_t IS
    VARIABLE value_v : INTEGER RANGE 0 TO 15;
  BEGIN
    value_v := to_integer(unsigned(nibble_v));
    IF value_v < 10 THEN
      RETURN STD_LOGIC_VECTOR(to_unsigned(CHARACTER'pos('0') + value_v, 8));
    ELSE
      RETURN STD_LOGIC_VECTOR(to_unsigned(CHARACTER'pos('A') + value_v - 10, 8));
    END IF;
  END FUNCTION;

  FUNCTION dbg_hex_character(nibble_v : STD_LOGIC_VECTOR(3 DOWNTO 0)) RETURN CHARACTER IS
    VARIABLE value_v : INTEGER RANGE 0 TO 15;
  BEGIN
    value_v := to_integer(unsigned(nibble_v));
    IF value_v < 10 THEN
      RETURN CHARACTER'val(CHARACTER'pos('0') + value_v);
    ELSE
      RETURN CHARACTER'val(CHARACTER'pos('A') + value_v - 10);
    END IF;
  END FUNCTION;

  PROCEDURE dbg_put_text(
    VARIABLE line_v : INOUT text_line_t;
    CONSTANT col_v : IN INTEGER;
    CONSTANT text_v : IN STRING
  ) IS
    VARIABLE dst_v : INTEGER;
  BEGIN
    dst_v := col_v + 1;
    FOR src_v IN text_v'RANGE LOOP
      EXIT WHEN dst_v > 48;
      IF dst_v >= 1 THEN
        line_v(dst_v) := text_v(src_v);
      END IF;
      dst_v := dst_v + 1;
    END LOOP;
  END PROCEDURE;

  PROCEDURE dbg_put_hex8(
    VARIABLE line_v : INOUT text_line_t;
    CONSTANT col_v : IN INTEGER;
    CONSTANT value_v : IN STD_LOGIC_VECTOR(7 DOWNTO 0)
  ) IS
  BEGIN
    line_v(col_v + 1) := dbg_hex_character(value_v(7 DOWNTO 4));
    line_v(col_v + 2) := dbg_hex_character(value_v(3 DOWNTO 0));
  END PROCEDURE;

  PROCEDURE dbg_put_hex16(
    VARIABLE line_v : INOUT text_line_t;
    CONSTANT col_v : IN INTEGER;
    CONSTANT value_v : IN STD_LOGIC_VECTOR(15 DOWNTO 0)
  ) IS
  BEGIN
    dbg_put_hex8(line_v, col_v, value_v(15 DOWNTO 8));
    dbg_put_hex8(line_v, col_v + 2, value_v(7 DOWNTO 0));
  END PROCEDURE;

  PROCEDURE dbg_put_hex32(
    VARIABLE line_v : INOUT text_line_t;
    CONSTANT col_v : IN INTEGER;
    CONSTANT value_v : IN STD_LOGIC_VECTOR(31 DOWNTO 0)
  ) IS
  BEGIN
    dbg_put_hex16(line_v, col_v, value_v(31 DOWNTO 16));
    dbg_put_hex16(line_v, col_v + 4, value_v(15 DOWNTO 0));
  END PROCEDURE;

  IMPURE FUNCTION cpm_diag_overlay_line(row_v : INTEGER) RETURN text_line_t IS
    VARIABLE line_v : text_line_t := (OTHERS => ' ');
  BEGIN
    CASE row_v IS
      WHEN 0 =>
        dbg_put_text(line_v, 0, "             F7 CP/M FDD DIAGNOSTICS");
      WHEN 1 =>
        IF overlay_diag_valid = '1' THEN
          dbg_put_text(line_v, 0, "FIRST FDC READ FAILURE: LATCHED");
        ELSE
          dbg_put_text(line_v, 0, "FIRST FDC READ FAILURE: NONE");
        END IF;
      WHEN 2 =>
        dbg_put_text(line_v, 0, "CP/M TRACK ");
        dbg_put_hex8(line_v, 11, overlay_diag_cpm_position(31 DOWNTO 24));
        dbg_put_text(line_v, 15, "RECORD ");
        dbg_put_hex8(line_v, 22, overlay_diag_cpm_position(23 DOWNTO 16));
      WHEN 3 =>
        dbg_put_text(line_v, 0, "PHYS CYL ");
        dbg_put_hex8(line_v, 9, overlay_diag_cpm_position(15 DOWNTO 8));
        dbg_put_text(line_v, 13, "SIDE ");
        IF overlay_diag_fdd_position(28) = '1' THEN
          line_v(19) := '1';
        ELSE
          line_v(19) := '0';
        END IF;
        dbg_put_text(line_v, 21, "SECTOR ");
        dbg_put_hex8(line_v, 28, overlay_diag_cpm_position(7 DOWNTO 0));
      WHEN 4 =>
        dbg_put_text(line_v, 0, "FDC CONTROL ");
        dbg_put_hex8(line_v, 12, overlay_diag_fdd_position(31 DOWNTO 24));
        dbg_put_text(line_v, 16, "DSK SD-SECTOR ");
        dbg_put_hex16(line_v, 30, "00000" & overlay_diag_fdd_position(23 DOWNTO 13));
      WHEN 5 =>
        dbg_put_text(line_v, 0, "DSK HALF ");
        IF overlay_diag_fdd_position(12) = '1' THEN
          line_v(10) := '1';
        ELSE
          line_v(10) := '0';
        END IF;
        dbg_put_text(line_v, 14, "FILE START CLUSTER ");
        dbg_put_hex32(line_v, 33, overlay_diag_cluster);
      WHEN 6 =>
        dbg_put_text(line_v, 0, "SD LBA ");
        dbg_put_hex32(line_v, 7, overlay_diag_sd_lba);
      WHEN 7 =>
        dbg_put_text(line_v, 0, "SD STATE ");
        dbg_put_hex8(line_v, 9, overlay_diag_sd_status(31 DOWNTO 24));
        dbg_put_text(line_v, 13, "CMD17 R1 ");
        dbg_put_hex8(line_v, 22, overlay_diag_sd_status(23 DOWNTO 16));
      WHEN 8 =>
        dbg_put_text(line_v, 0, "ERROR CODE ");
        line_v(12) := dbg_hex_character(overlay_diag_sd_status(3 DOWNTO 0));
        dbg_put_text(line_v, 15, "TOKEN ");
        dbg_put_hex8(line_v, 21, overlay_diag_sd_status(15 DOWNTO 8));
        dbg_put_text(line_v, 25, "COUNT ");
        dbg_put_hex16(line_v, 31, overlay_diag_read_count);
      WHEN 9 =>
        IF overlay_diag_sd_status(3 DOWNTO 0) = x"B" THEN
          dbg_put_text(line_v, 0, "BIOS B ");
          dbg_put_hex8(line_v, 7, overlay_diag_first_word(31 DOWNTO 24));
          dbg_put_text(line_v, 11, "TRK ");
          dbg_put_hex8(line_v, 15, overlay_diag_first_word(23 DOWNTO 16));
          dbg_put_text(line_v, 19, "REC ");
          dbg_put_hex8(line_v, 23, overlay_diag_first_word(15 DOWNTO 8));
          dbg_put_text(line_v, 27, "STATUS ");
          dbg_put_hex8(line_v, 34, overlay_diag_first_word(7 DOWNTO 0));
        ELSE
          dbg_put_text(line_v, 0, "FIRST WORD ");
          dbg_put_hex32(line_v, 11, overlay_diag_first_word);
        END IF;
      WHEN 10 =>
        dbg_put_text(line_v, 0, "FAT SPC ");
        dbg_put_hex8(line_v, 8, overlay_sd_boot_spc);
        dbg_put_text(line_v, 12, "RESERVED ");
        dbg_put_hex16(line_v, 21, overlay_sd_boot_reserved);
        dbg_put_text(line_v, 27, "FATS ");
        dbg_put_hex8(line_v, 32, overlay_sd_boot_num_fats);
      WHEN 11 =>
        dbg_put_text(line_v, 0, "FAT SECTORS ");
        dbg_put_hex32(line_v, 12, overlay_sd_boot_spf);
      WHEN 12 =>
        dbg_put_text(line_v, 0, "CURRENT LBA ");
        dbg_put_hex32(line_v, 12, overlay_sd_read_lba);
        dbg_put_text(line_v, 22, "STATE ");
        dbg_put_hex8(line_v, 28, overlay_sd_state_code);
        dbg_put_text(line_v, 32, "EC ");
        line_v(36) := dbg_hex_character(overlay_sd_debug_read_error_code);
      WHEN 13 =>
        dbg_put_text(line_v, 0, "REASON B=BIOS  C=EARLY  E=READY  F=GEOMETRY");
      WHEN 14 =>
        dbg_put_text(line_v, 0, "LATCH CLEARS ONLY ON SYSTEM/CPM RESET");
      WHEN 15 =>
        dbg_put_text(line_v, 0, "KEY ");
        dbg_put_hex8(line_v, 4, overlay_key_make_code);
        dbg_put_text(line_v, 7, "E ");
        line_v(9) := dbg_hex_character("000" & overlay_key_make_extended);
        dbg_put_text(line_v, 12, "CT ");
        line_v(15) := dbg_hex_character("000" & overlay_key_make_ctrl);
        dbg_put_text(line_v, 18, "LS ");
        line_v(21) := dbg_hex_character("000" & overlay_key_make_shift_l);
        dbg_put_text(line_v, 24, "RS ");
        line_v(27) := dbg_hex_character("000" & overlay_key_make_shift_r);
        dbg_put_text(line_v, 30, "NMI ");
        line_v(34) := dbg_hex_character("000" & overlay_key_make_nmi_match);
        dbg_put_text(line_v, 37, "COUNT ");
        dbg_put_hex8(line_v, 43, overlay_key_make_count);
      WHEN OTHERS =>
        NULL;
    END CASE;
    RETURN line_v;
  END FUNCTION;

  IMPURE FUNCTION god_overlay_line(row_v : INTEGER) RETURN text_line_t IS
    VARIABLE line_v : text_line_t := (OTHERS => ' ');
    VARIABLE mem_row_v : INTEGER RANGE 0 TO 7;
    VARIABLE mem_index_v : INTEGER RANGE 0 TO 63;
    VARIABLE mem_byte_v : STD_LOGIC_VECTOR(7 DOWNTO 0);
    VARIABLE mem_addr_v : STD_LOGIC_VECTOR(15 DOWNTO 0);
    VARIABLE cursor_addr_v : STD_LOGIC_VECTOR(15 DOWNTO 0);
  BEGIN
    CASE row_v IS
      WHEN 0 =>
        dbg_put_text(line_v, 0, "              F5 DEBUG MODE");
      WHEN 1 =>
        dbg_put_text(line_v, 0, "AF :");  dbg_put_hex16(line_v, 4, overlay_god_af);
        dbg_put_text(line_v, 10, "BC :");  dbg_put_hex16(line_v, 14, overlay_god_bc);
        dbg_put_text(line_v, 20, "DE :"); dbg_put_hex16(line_v, 24, overlay_god_de);
        dbg_put_text(line_v, 30, "HL :"); dbg_put_hex16(line_v, 34, overlay_god_hl);
      WHEN 2 =>
        dbg_put_text(line_v, 0, "AF':"); dbg_put_hex16(line_v, 4, overlay_god_af_alt);
        dbg_put_text(line_v, 10, "BC':"); dbg_put_hex16(line_v, 14, overlay_god_bc_alt);
        dbg_put_text(line_v, 20, "DE':"); dbg_put_hex16(line_v, 24, overlay_god_de_alt);
        dbg_put_text(line_v, 30, "HL':"); dbg_put_hex16(line_v, 34, overlay_god_hl_alt);
      WHEN 3 =>
        dbg_put_text(line_v, 0, "IX:");  dbg_put_hex16(line_v, 4, overlay_god_ix);
        dbg_put_text(line_v, 10, "IY:");  dbg_put_hex16(line_v, 14, overlay_god_iy);
        dbg_put_text(line_v, 20, "SP:"); dbg_put_hex16(line_v, 24, overlay_god_sp);
        dbg_put_text(line_v, 30, "PC:"); dbg_put_hex16(line_v, 34, overlay_god_pc);
      WHEN 4 =>
        dbg_put_text(line_v, 0, "I:"); dbg_put_hex8(line_v, 2, overlay_god_i);
        dbg_put_text(line_v, 5, "R:"); dbg_put_hex8(line_v, 7, overlay_god_r);
        dbg_put_text(line_v, 10, "IR:"); dbg_put_hex8(line_v, 13, overlay_god_ir);
        dbg_put_text(line_v, 16, "IM:");
        line_v(20) := CHARACTER'val(CHARACTER'pos('0') + to_integer(unsigned(overlay_god_im)));
        dbg_put_text(line_v, 21, "IFF:");
        IF overlay_god_iff(1) = '1' THEN line_v(26) := '1'; ELSE line_v(26) := '0'; END IF;
        IF overlay_god_iff(0) = '1' THEN line_v(27) := '1'; ELSE line_v(27) := '0'; END IF;
        dbg_put_text(line_v, 28, "MC:");
        line_v(32) := CHARACTER'val(CHARACTER'pos('0') + to_integer(unsigned(overlay_god_mc)));
        dbg_put_text(line_v, 33, "TS:");
        line_v(37) := CHARACTER'val(CHARACTER'pos('0') + to_integer(unsigned(overlay_god_ts)));
      WHEN 5 =>
        IF overlay_bls_fault = '1' THEN
          dbg_put_text(line_v, 0, "BLS EXEC FROM ");
          dbg_put_hex16(line_v, 14, overlay_bls_fault_from_pc);
          dbg_put_text(line_v, 19, "TO ");
          dbg_put_hex16(line_v, 22, overlay_bls_fault_to_pc);
          dbg_put_text(line_v, 27, "SP ");
          dbg_put_hex16(line_v, 30, overlay_bls_fault_sp);
        ELSE
          dbg_put_text(line_v, 0, "FLAGS S:0 Z:0 Y:0 H:0 X:0 P:0 N:0 C:0");
          FOR bit_v IN 0 TO 7 LOOP
            IF overlay_god_af(7 - bit_v) = '1' THEN
              line_v(9 + (bit_v * 4)) := '1';
            ELSE
              line_v(9 + (bit_v * 4)) := '0';
            END IF;
          END LOOP;
        END IF;
      WHEN 6 =>
        cursor_addr_v := STD_LOGIC_VECTOR(unsigned(overlay_god_mem_base) + to_unsigned(overlay_god_mem_cursor, 16));
        mem_byte_v := overlay_god_mem_data((overlay_god_mem_cursor * 8) + 7 DOWNTO overlay_god_mem_cursor * 8);
        IF overlay_god_addr_edit = '1' THEN
          dbg_put_text(line_v, 0, "EDIT RAM:");
          dbg_put_hex16(line_v, 10, overlay_god_addr_pending);
          dbg_put_text(line_v, 15, "DIGIT:");
          line_v(22) := CHARACTER'val(CHARACTER'pos('1') + overlay_god_addr_digit);
          dbg_put_text(line_v, 24, "ENTER=GO ESC=CANCEL");
        ELSE
          dbg_put_text(line_v, 0, "RAM:");
          dbg_put_hex16(line_v, 4, overlay_god_mem_base);
          dbg_put_text(line_v, 9, " CUR:");
          dbg_put_hex16(line_v, 14, cursor_addr_v);
          dbg_put_text(line_v, 19, "=");
          dbg_put_hex8(line_v, 20, mem_byte_v);
          IF overlay_god_edit_high = '0' THEN
            dbg_put_text(line_v, 24, "NEW:");
            line_v(29) := dbg_hex_character(overlay_god_high_nibble);
            line_v(30) := '_';
          END IF;
          line_v(27) := 'R';
          dbg_put_hex8(line_v, 28, overlay_god_reset_count);
          line_v(32) := 'U';
          dbg_put_hex8(line_v, 33, overlay_god_ui_reset_count);
          line_v(37) := 'C';
          dbg_put_hex8(line_v, 38, overlay_god_cfg_reset_count);
        END IF;
      WHEN 7 TO 14 =>
        mem_row_v := row_v - 7;
        IF (overlay_god_mem_cursor / 8) = mem_row_v THEN
          line_v(1) := '>';
        END IF;
        mem_addr_v := STD_LOGIC_VECTOR(unsigned(overlay_god_mem_base) + to_unsigned(mem_row_v * 8, 16));
        dbg_put_hex16(line_v, 1, mem_addr_v);
        dbg_put_text(line_v, 5, ":");
        FOR col_v IN 0 TO 7 LOOP
          mem_index_v := (mem_row_v * 8) + col_v;
          mem_byte_v := overlay_god_mem_data((mem_index_v * 8) + 7 DOWNTO mem_index_v * 8);
          dbg_put_hex8(line_v, 7 + (col_v * 3), mem_byte_v);
        END LOOP;
      WHEN OTHERS =>
        IF overlay_god_addr_edit = '1' THEN
          dbg_put_text(line_v, 0, "0-9,A-F=SET, LEFT/RIGHT=DIGIT, ENTER=GO, ESC");
        ELSE
          dbg_put_text(line_v, 0, "UP=ADDRESS, -/+=PAGE, SPACE=STEP, ENTER=SET PC");
        END IF;
    END CASE;
    RETURN line_v;
  END FUNCTION;

BEGIN

  -- MEGA65 R6 VGA DAC clocking, matching the current official R6 core.
  VGA_DAC_CLOCK_R6 : COMPONENT oddr
    PORT MAP(
      q => vga_clk_out,
      c => pix_clk,
      ce => '1',
      d1 => '0',
      d2 => '1',
      r => '0',
      s => '0'
    );

  vga_blank_n_out <= '1';
  vga_sync_n_out <= '0';
  vga_psave_n_out <= '1';
  vga_red_out <= vga_r;
  vga_green_out <= vga_g;
  vga_blue_out <= vga_b;
  vga_hsync_out <= vga_hs;
  vga_vsync_out <= vga_vs;

  status(0) <= NOT pix_rst; -- pixel clock MMCM locked
  status(1) <= NOT pix_rst; -- HDMI audio uses the pixel domain reset
  vram_clk <= pix_clk;
  overlay_ctrl_sys(0) <= overlay_enable;
  overlay_ctrl_sys(1) <= phosphor_amber;
  overlay_ctrl_sys(2) <= scanlines;
  overlay_ctrl_sys(3) <= overlay_tape_led_active;
  overlay_ctrl_sys(4) <= overlay_halt_active;
  overlay_ctrl_sys(5) <= overlay_pmod_fault_active;
  overlay_ctrl_sys(6) <= overlay_pmod_fault_pmod2;
  overlay_ctrl_sys(8 DOWNTO 7) <= video_zoom;
  avc_ctrl_sys <= avc_crtc_cursor_addr & avc_crtc_cursor_end &
    avc_crtc_cursor_start & avc_crtc_max_scanline &
    avc_crtc_horizontal_displayed & avc_terminal_mode &
    avc_crtc_start_addr & avc_control;

  DO_1KHZ : PROCESS (rst, clk) IS
    VARIABLE counter : INTEGER RANGE 0 TO 99999;
  BEGIN
    IF rst = '1' THEN
      counter := 0;
      clken_1khz <= '0';
    ELSIF rising_edge(clk) THEN
      IF counter = (1000 * INTEGER(fclk)) - 1 THEN
        counter := 0;
        clken_1khz <= '1';
      ELSE
        counter := counter + 1;
        clken_1khz <= '0';
      END IF;
    END IF;
  END PROCESS DO_1KHZ;

  -- 4 bit counter @ 1Hz => 0.5Hz, 1Hz, 2Hz and 4Hz heartbeat pulses for LEDs
  DO_HEARTBEAT : PROCESS (rst, clk, clken_1khz) IS
    VARIABLE counter : INTEGER RANGE 0 TO 124;
  BEGIN
    IF rst = '1' THEN
      counter := 0;
      heartbeat_i <= (OTHERS => '0');
    ELSIF rising_edge(clk) AND clken_1khz = '1' THEN
      IF counter = 124 THEN
        counter := 0;
        heartbeat_i <= STD_LOGIC_VECTOR(unsigned(heartbeat_i) + 1);
      ELSE
        counter := counter + 1;
      END IF;
    END IF;
  END PROCESS DO_HEARTBEAT;

  heartbeat <= heartbeat_i;

  OVERLAY_CTRL_SYNC : COMPONENT sync_reg
    GENERIC MAP(
      width => 9,
      depth => 2
    )
    PORT MAP(
      rst => pix_rst,
      clk => pix_clk,
      d => overlay_ctrl_sys,
      q => overlay_ctrl_pix
    );

  AVC_CTRL_SYNC : COMPONENT sync_reg
    GENERIC MAP(
      width => 64,
      depth => 2
    )
    PORT MAP(
      rst => pix_rst,
      clk => pix_clk,
      d => avc_ctrl_sys,
      q => avc_ctrl_pix
    );

    overlay_enable_pix <= overlay_ctrl_pix(0);
    phosphor_amber_pix <= overlay_ctrl_pix(1);
    scanlines_pix <= overlay_ctrl_pix(2);
    tape_led_active_pix <= overlay_ctrl_pix(3);
    halt_active_pix <= overlay_ctrl_pix(4);
    pmod_fault_active_pix <= overlay_ctrl_pix(5);
    pmod_fault_pmod2_pix <= overlay_ctrl_pix(6);
    video_zoom_pix <= overlay_ctrl_pix(8 DOWNTO 7);
    avc_control_pix <= avc_ctrl_pix(7 DOWNTO 0);
    avc_start_addr_pix <= avc_ctrl_pix(22 DOWNTO 8);
    avc_terminal_mode_pix <= avc_ctrl_pix(23);
    avc_horizontal_displayed_pix <= avc_ctrl_pix(31 DOWNTO 24);
    avc_max_scanline_pix <= avc_ctrl_pix(36 DOWNTO 32);
    avc_cursor_start_pix <= avc_ctrl_pix(44 DOWNTO 37);
    avc_cursor_end_pix <= avc_ctrl_pix(49 DOWNTO 45);
    avc_cursor_addr_pix <= avc_ctrl_pix(63 DOWNTO 50);

    DO_OVERLAY_CACHE : PROCESS (clk) IS
      VARIABLE line_v : text_line_t := (OTHERS => ' ');
      VARIABLE line_bits_v : STD_LOGIC_VECTOR(383 DOWNTO 0) := (OTHERS => '0');
      VARIABLE char_index_v : INTEGER;
    BEGIN
      IF rising_edge(clk) THEN
        IF rst = '1' THEN
          overlay_char_wr_en <= '0';
          overlay_char_wr_addr <= (OTHERS => '0');
          overlay_char_wr_data <= x"20";
          overlay_line_bits_sys <= (OTHERS => '0');
          overlay_line_loaded <= '0';
          overlay_cache_row <= 0;
          overlay_cache_col <= 0;
        ELSE
          overlay_char_wr_en <= '0';

          IF overlay_line_loaded = '0' THEN
            IF overlay_page = "0110" THEN
              line_v := god_overlay_line(overlay_cache_row);
            ELSIF overlay_page = "0111" THEN
              line_v := cpm_diag_overlay_line(overlay_cache_row);
            ELSE
              line_v := overlay_line_text(
              overlay_page,
              overlay_cache_row,
              overlay_cfg_row,
              overlay_cfg_speed,
              overlay_cfg_phosphor_amber,
              overlay_cfg_scanlines,
              overlay_cfg_video_zoom,
              overlay_cfg_rs232,
              overlay_cfg_rs232_speed,
              overlay_cfg_rs232_flow,
              overlay_cfg_slot_rom,
              overlay_cfg_fdd,
              overlay_cfg_cpm,
              overlay_cfg_avc,
              overlay_cfg_bls,
              overlay_sd_cd_raw,
              overlay_sd_init_busy,
              overlay_sd_init_done,
              overlay_sd_init_error,
              overlay_sd_read_busy,
              overlay_sd_read_done,
              overlay_sd_read_error,
              overlay_sd_read_stage,
              overlay_sd_read_lba,
              overlay_sd_read_token,
              overlay_sd_read_count,
              overlay_sd_read_first_word,
              overlay_sd_card_block_addressing,
              overlay_sd_debug_read_cmd17_r1,
              overlay_sd_debug_read_error_code,
              overlay_sd_debug_root_current_cluster,
              overlay_sd_debug_root_next_cluster,
              overlay_sd_debug_root_sectors_left,
              overlay_sd_debug_root_scan_phase,
              overlay_sd_debug_root_scan_job,
              overlay_sd_part_lba,
              overlay_sd_boot_spc,
              overlay_sd_boot_reserved,
              overlay_sd_boot_num_fats,
              overlay_sd_boot_spf,
              overlay_sd_root_dir_lba,
              overlay_sd_browser_dir_found,
              overlay_sd_browser_has_files,
              overlay_sd_root_total_file_count,
              overlay_sd_page_valid,
              overlay_sd_page_name,
              overlay_sd_page_kind,
              overlay_fdd_mount_a_valid,
              overlay_fdd_mount_a_name,
              overlay_fdd_mount_b_valid,
              overlay_fdd_mount_b_name,
              overlay_sd_page_base,
              overlay_sd_page_row,
              overlay_sd_file_load_addr_valid,
              overlay_sd_file_load_addr,
              overlay_browser_manage_mode,
              overlay_browser_manage_name,
              overlay_browser_manage_status,
              overlay_tape_led_active,
              overlay_cfg_dirty,
              overlay_cfg_apply_pending,
              overlay_cfg_apply_error,
              overlay_cfg_load_busy,
              overlay_cfg_load_pending,
              overlay_cfg_load_seen,
              overlay_cfg_load_ok,
              overlay_cfg_load_error,
              overlay_save_name,
              overlay_save_row_sel,
              overlay_save_mode_basic,
              overlay_save_mode_bls,
              overlay_save_start_addr_digit,
              overlay_save_end_addr_digit,
              overlay_save_start_addr_manual,
              overlay_save_end_addr_manual,
              overlay_save_basic_available,
              overlay_save_basic_ready,
              overlay_save_basic_start_addr,
              overlay_save_basic_end_addr,
              overlay_save_effective_start_addr,
              overlay_save_effective_end_addr,
              overlay_save_effective_len,
              overlay_save_check_busy,
              overlay_save_checked,
              overlay_save_name_exists,
              overlay_save_check_can_create,
              overlay_save_check_can_allocate,
              overlay_save_check_requires_dir_growth,
              overlay_save_check_dir_full,
              overlay_save_overwrite_confirmed,
              overlay_save_ready_to_write,
              overlay_save_write_after_check,
              overlay_save_write_busy,
              overlay_save_write_done,
              overlay_save_write_error,
              overlay_save_write_status,
              overlay_sd_last_r1,
              overlay_sd_state_code
              );
            END IF;
            line_bits_v := pack_line_bits(line_v);
            overlay_line_bits_sys <= line_bits_v;
            overlay_line_loaded <= '1';
          ELSE
            line_bits_v := overlay_line_bits_sys;

            overlay_char_wr_en <= '1';
            char_index_v := (overlay_cache_row * 48) + overlay_cache_col;
            overlay_char_wr_addr <= STD_LOGIC_VECTOR(to_unsigned(char_index_v, overlay_char_wr_addr'length));
            overlay_char_wr_data <= line_bits_v((overlay_cache_col * 8) + 7 DOWNTO overlay_cache_col * 8);

            IF overlay_cache_col = 47 THEN
              overlay_cache_col <= 0;
              overlay_line_loaded <= '0';
              IF overlay_cache_row = 15 THEN
                overlay_cache_row <= 0;
              ELSE
                overlay_cache_row <= overlay_cache_row + 1;
              END IF;
            ELSE
              overlay_cache_col <= overlay_cache_col + 1;
            END IF;
          END IF;
        END IF;
      END IF;
    END PROCESS DO_OVERLAY_CACHE;

    OVERLAY_CHAR_RAM : xpm_memory_sdpram
    GENERIC MAP(
      MEMORY_SIZE => 6144,
      MEMORY_PRIMITIVE => "block",
      CLOCKING_MODE => "independent_clock",
      ECC_MODE => "no_ecc",
      MEMORY_INIT_FILE => "none",
      MEMORY_INIT_PARAM => "",
      USE_MEM_INIT => 0,
      WAKEUP_TIME => "disable_sleep",
      MESSAGE_CONTROL => 0,
      USE_EMBEDDED_CONSTRAINT => 0,
      MEMORY_OPTIMIZATION => "true",
      CASCADE_HEIGHT => 0,
      SIM_ASSERT_CHK => 0,
      WRITE_DATA_WIDTH_A => 8,
      BYTE_WRITE_WIDTH_A => 8,
      ADDR_WIDTH_A => 10,
      RST_MODE_A => "SYNC",
      READ_DATA_WIDTH_B => 8,
      ADDR_WIDTH_B => 10,
      READ_RESET_VALUE_B => "0",
      READ_LATENCY_B => 1,
      WRITE_MODE_B => "no_change",
      RST_MODE_B => "SYNC"
    )
    PORT MAP(
      sleep => '0',
      clka => clk,
      ena => '1',
      wea(0) => overlay_char_wr_en,
      addra => overlay_char_wr_addr,
      dina => overlay_char_wr_data,
      injectsbiterra => '0',
      injectdbiterra => '0',
      clkb => pix_clk,
      rstb => pix_rst,
      enb => '1',
      regceb => '1',
      addrb => overlay_char_addr,
      doutb => overlay_char_data,
      sbiterrb => OPEN,
      dbiterrb => OPEN
    );

    -- Fixed 800x600 @ 60 Hz mode.  Its 800 active pixels accommodate the
    -- original AVC's complete 784-pixel double-density raster one-for-one.
    mode_i <= x"F";
    mode_rst <= '0';
    mode <= mode_i;

    -- lookup table: expand mode number to detailed timings for that mode
    VIDEO_MODE : ENTITY work.video_mode
      PORT MAP(
        mode => mode_i,
        clk_sel => mode_clk_sel,
        dmt => mode_dmt,
        id => mode_id,
        pix_rep => mode_pix_rep,
        aspect => mode_aspect,
        interlace => mode_interlace,
        v_tot => mode_v_tot,
        v_act => mode_v_act,
        v_sync => mode_v_sync,
        v_bp => mode_v_bp,
        h_tot => mode_h_tot,
        h_act => mode_h_act,
        h_sync => mode_h_sync,
        h_bp => mode_h_bp,
        vs_pol => mode_vs_pol,
        hs_pol => mode_hs_pol
      );

    -- reconfigurable MMCM: 25.2MHz, 27MHz, 74.25MHz or 148.5MHz
    VIDEO_CLOCK : COMPONENT video_out_clock
      GENERIC MAP(
        fref => fclk
      )
      PORT MAP(
        -- Keep the pixel/MMCM reset local to video-mode control. The HDMI
        -- clock tree should not be re-timed by machine-reset activity from
        -- the 100 MHz system domain.
        rsti => mode_rst,
        clki => clk,
        sel => mode_clk_sel,
        rsto => pix_rst,
        clko => pix_clk,
        clko_x5 => pix_clk_x5
      );

      -- basic video timing generation
      VIDEO_TIMING : COMPONENT video_out_timing
        PORT MAP(
          rst => pix_rst,
          clk => pix_clk,
          pix_rep => mode_pix_rep,
          interlace => mode_interlace,
          v_tot => mode_v_tot,
          v_act => mode_v_act,
          v_sync => mode_v_sync,
          v_bp => mode_v_bp,
          h_tot => mode_h_tot,
          h_act => mode_h_act,
          h_sync => mode_h_sync,
          h_bp => mode_h_bp,
          genlock => '0',
          genlocked => OPEN,
          f => raw_f,
          vs => raw_vs,
          hs => raw_hs,
          vblank => raw_vblank,
          hblank => raw_hblank,
          ax => raw_ax,
          ay => raw_ay
        );

        DO_TIMING_SYNC : PROCESS (pix_rst, pix_clk) IS
        BEGIN
          IF pix_rst = '1' THEN
            timing_vs <= '0';
            timing_hs <= '0';
            timing_vblank <= '1';
            timing_hblank <= '1';
            timing_ax <= (OTHERS => '0');
            timing_ay <= (OTHERS => '0');
            timing_h_act <= (OTHERS => '0');
            timing_v_act <= (OTHERS => '0');
          ELSIF rising_edge(pix_clk) THEN
            timing_vs <= raw_vs;
            timing_hs <= raw_hs;
            timing_vblank <= raw_vblank;
            timing_hblank <= raw_hblank;
            timing_ax <= raw_ax;
            timing_ay <= raw_ay;
            timing_h_act <= mode_h_act;
            timing_v_act <= mode_v_act;
          END IF;
        END PROCESS DO_TIMING_SYNC;

        -- MC6845 cursor blink timing is defined in video fields.  Increment
        -- once at the start of vertical blanking so R10 modes 10 and 11
        -- toggle after 16 and 32 complete fields respectively.
        DO_AVC_CURSOR_CLOCK : PROCESS (pix_rst, pix_clk) IS
        BEGIN
          IF pix_rst = '1' THEN
            avc_cursor_frame_count <= (OTHERS => '0');
            avc_cursor_vblank_last <= '1';
          ELSIF rising_edge(pix_clk) THEN
            IF timing_vblank = '1' AND avc_cursor_vblank_last = '0' THEN
              avc_cursor_frame_count <= avc_cursor_frame_count + 1;
            END IF;
            avc_cursor_vblank_last <= timing_vblank;
          END IF;
        END PROCESS DO_AVC_CURSOR_CLOCK;

        DO_TEXT_STAGE1 : PROCESS (pix_rst, pix_clk) IS
          VARIABLE ax_i : INTEGER;
          VARIABLE ay_i : INTEGER;
          VARIABLE h_act_i : INTEGER;
          VARIABLE v_act_i : INTEGER;
          VARIABLE x0_i : INTEGER;
          VARIABLE y0_i : INTEGER;
          VARIABLE px_i : INTEGER;
          VARIABLE py_i : INTEGER;
          VARIABLE char_x_i : INTEGER;
          VARIABLE char_y_i : INTEGER;
          VARIABLE screen_row_i : INTEGER;
          VARIABLE glyph_x_i : INTEGER;
          VARIABLE glyph_y_i : INTEGER;
          VARIABLE source_x_i : INTEGER;
          VARIABLE source_y_i : INTEGER;
          VARIABLE display_w_i : INTEGER;
          VARIABLE display_h_i : INTEGER;
          VARIABLE marker_h_i : INTEGER;
          VARIABLE in_text : BOOLEAN;
          VARIABLE vram_index_i : INTEGER;
          VARIABLE avc_x0_i : INTEGER;
          VARIABLE avc_y0_i : INTEGER;
          VARIABLE avc_display_w_i : INTEGER;
          VARIABLE avc_display_h_i : INTEGER;
          VARIABLE avc_source_x_i : INTEGER;
          VARIABLE avc_source_y_i : INTEGER;
          VARIABLE avc_addr_v : UNSIGNED(14 DOWNTO 0);
          VARIABLE avc_cursor_raster_i : INTEGER RANGE 0 TO 31;
          VARIABLE avc_cursor_cell_width_i : INTEGER RANGE 4 TO 8;
          VARIABLE avc_cursor_row_addr_v : UNSIGNED(13 DOWNTO 0);
          VARIABLE avc_cursor_raster_v : UNSIGNED(4 DOWNTO 0);
          VARIABLE avc_cursor_ma_v : UNSIGNED(13 DOWNTO 0);
          VARIABLE avc_cursor_start_i : INTEGER RANGE 0 TO 31;
          VARIABLE avc_cursor_end_i : INTEGER RANGE 0 TO 31;
          VARIABLE avc_cursor_scan_visible_v : BOOLEAN;
          VARIABLE avc_cursor_blink_visible_v : BOOLEAN;
          VARIABLE in_avc : BOOLEAN;
          VARIABLE in_tape : BOOLEAN;
          VARIABLE in_halt : BOOLEAN;
          VARIABLE in_pmod_fault : BOOLEAN;
        BEGIN
          IF pix_rst = '1' THEN
            text_vs_s1 <= '0';
            text_hs_s1 <= '0';
            text_vblank_s1 <= '1';
            text_hblank_s1 <= '1';
            text_in_text_s1 <= '0';
            text_overlay_enable_s1 <= '0';
            text_phosphor_amber_s1 <= '0';
            text_scanlines_s1 <= '0';
            text_char_x_s1 <= (OTHERS => '0');
            text_char_y_s1 <= (OTHERS => '0');
            text_screen_row_s1 <= (OTHERS => '0');
            text_vram_addr_s1 <= (OTHERS => '0');
            text_glyph_x_s1 <= (OTHERS => '0');
            text_glyph_y_s1 <= (OTHERS => '0');
            overlay_char_addr <= (OTHERS => '0');
            vram_addr <= (OTHERS => '0');
            avc_vram_addr <= (OTHERS => '0');
            text_in_tape_s1 <= '0';
            avc_in_graphics_s1 <= '0';
            avc_bit_x_s1 <= (OTHERS => '0');
            avc_blue_bit_x_s1 <= (OTHERS => '0');
            avc_double_s1 <= '0';
            avc_high_green_s1 <= '0';
            avc_scanline_odd_s1 <= '0';
            avc_cursor_on_s1 <= '0';
            avc_cursor_row_addr <= (OTHERS => '0');
            avc_cursor_raster <= (OTHERS => '0');
            avc_cursor_last_source_y <= -1;
          ELSIF rising_edge(pix_clk) THEN
            text_vs_s1 <= timing_vs;
            text_hs_s1 <= timing_hs;
            text_vblank_s1 <= timing_vblank;
            text_hblank_s1 <= timing_hblank;
            text_in_text_s1 <= '0';
            text_overlay_enable_s1 <= overlay_enable_pix;
            text_phosphor_amber_s1 <= phosphor_amber_pix;
            text_scanlines_s1 <= scanlines_pix;
            text_char_x_s1 <= (OTHERS => '0');
            text_char_y_s1 <= (OTHERS => '0');
            text_screen_row_s1 <= (OTHERS => '0');
            text_vram_addr_s1 <= (OTHERS => '0');
            text_glyph_x_s1 <= (OTHERS => '0');
            text_glyph_y_s1 <= (OTHERS => '0');
            overlay_char_addr <= (OTHERS => '0');
            vram_addr <= (OTHERS => '0');
            avc_vram_addr <= (OTHERS => '0');
            text_in_tape_s1 <= '0';
            avc_in_graphics_s1 <= '0';
            avc_bit_x_s1 <= (OTHERS => '0');
            avc_blue_bit_x_s1 <= (OTHERS => '0');
            avc_double_s1 <= '0';
            avc_high_green_s1 <= '0';
            avc_scanline_odd_s1 <= '0';
            avc_cursor_on_s1 <= '0';

            IF timing_vblank = '0' AND timing_hblank = '0' THEN
              ax_i := to_integer(signed(timing_ax));
              ay_i := to_integer(signed(timing_ay));
              h_act_i := to_integer(unsigned(timing_h_act));
              v_act_i := to_integer(unsigned(timing_v_act));

              IF video_zoom_pix(1) = '1' THEN
                display_w_i := 768;
                display_h_i := 512;
                marker_h_i := 32;
              ELSIF video_zoom_pix(0) = '1' THEN
                display_w_i := 576;
                display_h_i := 384;
                marker_h_i := 24;
              ELSE
                display_w_i := 384;
                display_h_i := 256;
                marker_h_i := 16;
              END IF;
              x0_i := (h_act_i - display_w_i) / 2;
              y0_i := (v_act_i - display_h_i) / 2;

              in_text := (ax_i >= x0_i) AND (ax_i < x0_i + display_w_i) AND
                (ay_i >= y0_i) AND (ay_i < y0_i + display_h_i) AND
                (overlay_enable_pix = '1' OR avc_control_pix(7) = '1');

              -- The standard AVC raster is 49 displayed bytes by 256 lines.
              -- Its historical 16 KiB address space retains 64 bytes per line.
              -- The FPGA terminal extends that internal raster to 384 lines
              -- and a 32 KiB circular address space for 96 x 24 characters.
              -- Double density contains 784 source pixels.  The fixed
              -- 800x600 HDMI mode presents them one-for-one, with eight black
              -- pixels at each side.  Do not apply normal video zoom here,
              -- since it would crop the 96-column CP/M terminal.
              IF avc_terminal_mode_pix = '1' THEN
                avc_display_w_i := 784;
                avc_display_h_i := 384;
              ELSIF avc_control_pix(3) = '1' THEN
                avc_display_w_i := 784;
                avc_display_h_i := 256;
              ELSIF video_zoom_pix(1) = '1' THEN
                avc_display_w_i := 784;
                avc_display_h_i := 512;
              ELSIF video_zoom_pix(0) = '1' THEN
                avc_display_w_i := 588;
                avc_display_h_i := 384;
              ELSE
                avc_display_w_i := 392;
                avc_display_h_i := 256;
              END IF;
              avc_x0_i := (h_act_i - avc_display_w_i) / 2;
              avc_y0_i := (v_act_i - avc_display_h_i) / 2;
              in_avc := overlay_enable_pix = '0' AND avc_control_pix(7) = '0' AND
                (ax_i >= avc_x0_i) AND (ax_i < avc_x0_i + avc_display_w_i) AND
                (ay_i >= avc_y0_i) AND (ay_i < avc_y0_i + avc_display_h_i);
              IF in_avc THEN
                IF avc_terminal_mode_pix = '1' THEN
                  avc_source_x_i := ax_i - avc_x0_i;
                  avc_source_y_i := ay_i - avc_y0_i;
                ELSIF avc_control_pix(3) = '1' THEN
                  avc_source_x_i := ax_i - avc_x0_i;
                  avc_source_y_i := ay_i - avc_y0_i;
                ELSIF video_zoom_pix(1) = '1' THEN
                  avc_source_x_i := (ax_i - avc_x0_i) / 2;
                  avc_source_y_i := (ay_i - avc_y0_i) / 2;
                ELSIF video_zoom_pix(0) = '1' THEN
                  avc_source_x_i := scale_150(ax_i - avc_x0_i);
                  avc_source_y_i := scale_150(ay_i - avc_y0_i);
                ELSE
                  avc_source_x_i := ax_i - avc_x0_i;
                  avc_source_y_i := ay_i - avc_y0_i;
                END IF;
                IF avc_terminal_mode_pix = '1' THEN
                  avc_addr_v := unsigned(avc_start_addr_pix) +
                    shift_left(to_unsigned(avc_source_y_i, 15), 6) +
                    to_unsigned(avc_source_x_i / 16, 15);
                  avc_double_s1 <= '1';
                  IF (avc_source_x_i MOD 16) >= 8 THEN
                    avc_high_green_s1 <= '1';
                  END IF;
                  avc_bit_x_s1 <= STD_LOGIC_VECTOR(to_unsigned(avc_source_x_i MOD 8, 3));
                  avc_blue_bit_x_s1 <= STD_LOGIC_VECTOR(to_unsigned((avc_source_x_i MOD 16) / 2, 3));
                ELSIF avc_control_pix(3) = '1' THEN
                  avc_addr_v := '0' & (unsigned(avc_start_addr_pix(13 DOWNTO 0)) +
                    shift_left(to_unsigned(avc_source_y_i, 14), 6) +
                    to_unsigned(avc_source_x_i / 16, 14));
                  avc_double_s1 <= '1';
                  IF (avc_source_x_i MOD 16) >= 8 THEN
                    avc_high_green_s1 <= '1';
                  END IF;
                  avc_bit_x_s1 <= STD_LOGIC_VECTOR(to_unsigned(avc_source_x_i MOD 8, 3));
                  avc_blue_bit_x_s1 <= STD_LOGIC_VECTOR(to_unsigned((avc_source_x_i MOD 16) / 2, 3));
                ELSE
                  avc_addr_v := '0' & (unsigned(avc_start_addr_pix(13 DOWNTO 0)) +
                    shift_left(to_unsigned(avc_source_y_i, 14), 6) +
                    to_unsigned(avc_source_x_i / 8, 14));
                  avc_bit_x_s1 <= STD_LOGIC_VECTOR(to_unsigned(avc_source_x_i MOD 8, 3));
                  avc_blue_bit_x_s1 <= STD_LOGIC_VECTOR(to_unsigned(avc_source_x_i MOD 8, 3));
                END IF;
                avc_vram_addr <= STD_LOGIC_VECTOR(avc_addr_v);

                -- Track the MC6845 memory address and raster address as
                -- counters.  This avoids a variable divider in the 40 MHz
                -- pixel path and mirrors how the real CRTC advances R9/R1.
                avc_cursor_row_addr_v := avc_cursor_row_addr;
                avc_cursor_raster_v := avc_cursor_raster;
                IF avc_terminal_mode_pix = '0' AND avc_source_x_i = 0 AND
                    avc_source_y_i /= avc_cursor_last_source_y THEN
                  IF avc_source_y_i = 0 OR avc_cursor_last_source_y < 0 OR
                      avc_source_y_i < avc_cursor_last_source_y THEN
                    avc_cursor_row_addr_v := unsigned(avc_start_addr_pix(13 DOWNTO 0));
                    avc_cursor_raster_v := (OTHERS => '0');
                  ELSIF avc_cursor_raster = unsigned(avc_max_scanline_pix) THEN
                    avc_cursor_row_addr_v := avc_cursor_row_addr +
                      resize(unsigned(avc_horizontal_displayed_pix), avc_cursor_row_addr'length);
                    avc_cursor_raster_v := (OTHERS => '0');
                  ELSE
                    avc_cursor_raster_v := avc_cursor_raster + 1;
                  END IF;
                  avc_cursor_row_addr <= avc_cursor_row_addr_v;
                  avc_cursor_raster <= avc_cursor_raster_v;
                  avc_cursor_last_source_y <= avc_source_y_i;
                END IF;

                -- The physical Model B exposes CURSOR only on a test point;
                -- software must arrange an external XOR connection to make
                -- it visible.  R10 bit 7 is unused by the MC6845, so this
                -- implementation uses it as the virtual XOR-link enable.
                -- The remaining R10/R11/R14/R15 behaviour follows the
                -- MC6845: address comparison is in character clocks and the
                -- cursor shape is selected by raster line within the row.
                IF avc_terminal_mode_pix = '0' AND avc_cursor_start_pix(7) = '1' THEN
                  avc_cursor_raster_i := to_integer(avc_cursor_raster_v);
                  avc_cursor_start_i := to_integer(unsigned(avc_cursor_start_pix(4 DOWNTO 0)));
                  avc_cursor_end_i := to_integer(unsigned(avc_cursor_end_pix));
                  IF avc_cursor_start_i <= avc_cursor_end_i THEN
                    avc_cursor_scan_visible_v :=
                      avc_cursor_raster_i >= avc_cursor_start_i AND
                      avc_cursor_raster_i <= avc_cursor_end_i;
                  ELSE
                    avc_cursor_scan_visible_v :=
                      avc_cursor_raster_i >= avc_cursor_start_i OR
                      avc_cursor_raster_i <= avc_cursor_end_i;
                  END IF;

                  CASE avc_cursor_start_pix(6 DOWNTO 5) IS
                    WHEN "00" => avc_cursor_blink_visible_v := TRUE;
                    WHEN "01" => avc_cursor_blink_visible_v := FALSE;
                    WHEN "10" => avc_cursor_blink_visible_v := avc_cursor_frame_count(4) = '0';
                    WHEN OTHERS => avc_cursor_blink_visible_v := avc_cursor_frame_count(5) = '0';
                  END CASE;

                  IF avc_control_pix(3) = '1' THEN
                    avc_cursor_cell_width_i := 8;
                  ELSE
                    avc_cursor_cell_width_i := 4;
                  END IF;
                  avc_cursor_ma_v := avc_cursor_row_addr_v +
                    to_unsigned(avc_source_x_i / avc_cursor_cell_width_i, 14);
                  IF avc_cursor_ma_v = unsigned(avc_cursor_addr_pix) AND
                    avc_cursor_scan_visible_v AND avc_cursor_blink_visible_v THEN
                    avc_cursor_on_s1 <= '1';
                  END IF;
                END IF;

                IF (avc_source_y_i MOD 2) = 1 THEN
                  avc_scanline_odd_s1 <= '1';
                ELSE
                  avc_scanline_odd_s1 <= '0';
                END IF;
                avc_in_graphics_s1 <= '1';
              END IF;

              in_tape := (tape_led_active_pix = '1') AND
                (ax_i >= x0_i) AND (ax_i < x0_i + (4 * marker_h_i / 2)) AND
                (ay_i >= y0_i - marker_h_i) AND (ay_i < y0_i);
              in_halt := (halt_active_pix = '1') AND
                (ax_i >= x0_i + (5 * marker_h_i / 2)) AND (ax_i < x0_i + (9 * marker_h_i / 2)) AND
                (ay_i >= y0_i - marker_h_i) AND (ay_i < y0_i);
              in_pmod_fault := (pmod_fault_active_pix = '1') AND
                (ax_i >= x0_i + (10 * marker_h_i / 2)) AND (ax_i < x0_i + (16 * marker_h_i / 2)) AND
                (ay_i >= y0_i - marker_h_i) AND (ay_i < y0_i);

              IF in_text THEN
                px_i := ax_i - x0_i;
                py_i := ay_i - y0_i;
                IF video_zoom_pix(1) = '1' THEN
                  source_x_i := px_i / 2;
                  source_y_i := py_i / 2;
                ELSIF video_zoom_pix(0) = '1' THEN
                  source_x_i := scale_150(px_i);
                  source_y_i := scale_150(py_i);
                ELSE
                  source_x_i := px_i;
                  source_y_i := py_i;
                END IF;
                char_x_i := source_x_i / 8;
                char_y_i := source_y_i / 16;
                glyph_x_i := source_x_i MOD 8;
                glyph_y_i := source_y_i MOD 16;

                text_in_text_s1 <= '1';
                text_char_x_s1 <= STD_LOGIC_VECTOR(to_unsigned(char_x_i, text_char_x_s1'length));
                text_char_y_s1 <= STD_LOGIC_VECTOR(to_unsigned(char_y_i, text_char_y_s1'length));
                text_glyph_x_s1 <= STD_LOGIC_VECTOR(to_unsigned(glyph_x_i, text_glyph_x_s1'length));
                text_glyph_y_s1 <= STD_LOGIC_VECTOR(to_unsigned(glyph_y_i, text_glyph_y_s1'length));

                IF overlay_enable_pix = '0' THEN
                  IF char_y_i = 0 THEN
                    screen_row_i := 15;
                  ELSE
                    screen_row_i := char_y_i - 1;
                  END IF;
                  vram_index_i := screen_row_i * 64 + 10 + char_x_i;
                  vram_addr <= STD_LOGIC_VECTOR(to_unsigned(vram_index_i, 10));
                  text_screen_row_s1 <= STD_LOGIC_VECTOR(to_unsigned(screen_row_i, text_screen_row_s1'length));
                  text_vram_addr_s1 <= STD_LOGIC_VECTOR(to_unsigned(vram_index_i, text_vram_addr_s1'length));
                ELSE
                  vram_index_i := (char_y_i * 48) + char_x_i;
                  overlay_char_addr <= STD_LOGIC_VECTOR(to_unsigned(vram_index_i, overlay_char_addr'length));
                END IF;

              ELSIF in_tape OR in_halt OR in_pmod_fault THEN
                px_i := ax_i - x0_i;
                py_i := ay_i - (y0_i - marker_h_i);
                IF video_zoom_pix(1) = '1' THEN
                  source_x_i := px_i / 2;
                  source_y_i := py_i / 2;
                ELSIF video_zoom_pix(0) = '1' THEN
                  source_x_i := scale_150(px_i);
                  source_y_i := scale_150(py_i);
                ELSE
                  source_x_i := px_i;
                  source_y_i := py_i;
                END IF;
                char_x_i := source_x_i / 8;
                glyph_x_i := source_x_i MOD 8;
                glyph_y_i := source_y_i MOD 16;

                text_in_text_s1 <= '1';
                text_in_tape_s1 <= '1';
                text_char_x_s1 <= STD_LOGIC_VECTOR(to_unsigned(char_x_i, text_char_x_s1'length));
                text_char_y_s1 <= (OTHERS => '0');
                text_glyph_x_s1 <= STD_LOGIC_VECTOR(to_unsigned(glyph_x_i, text_glyph_x_s1'length));
                text_glyph_y_s1 <= STD_LOGIC_VECTOR(to_unsigned(glyph_y_i, text_glyph_y_s1'length));
              END IF;
            END IF;
          END IF;
        END PROCESS DO_TEXT_STAGE1;

        -- stage 2: delay geometry/control so synchronous video RAM data can catch up
        DO_TEXT_STAGE2 : PROCESS (pix_rst, pix_clk) IS
        BEGIN
          IF pix_rst = '1' THEN
            text_vs_s2 <= '0';
            text_hs_s2 <= '0';
            text_vblank_s2 <= '1';
            text_hblank_s2 <= '1';
            text_in_text_s2 <= '0';
            text_overlay_enable_s2 <= '0';
            text_phosphor_amber_s2 <= '0';
            text_scanlines_s2 <= '0';
            text_char_x_s2 <= (OTHERS => '0');
            text_char_y_s2 <= (OTHERS => '0');
            text_screen_row_s2 <= (OTHERS => '0');
            text_vram_addr_s2 <= (OTHERS => '0');
            text_glyph_x_s2 <= (OTHERS => '0');
            text_glyph_y_s2 <= (OTHERS => '0');
            text_in_tape_s2 <= '0';
            avc_in_graphics_s2 <= '0';
            avc_bit_x_s2 <= (OTHERS => '0');
            avc_blue_bit_x_s2 <= (OTHERS => '0');
            avc_double_s2 <= '0';
            avc_high_green_s2 <= '0';
            avc_scanline_odd_s2 <= '0';
            avc_cursor_on_s2 <= '0';
          ELSIF rising_edge(pix_clk) THEN
            text_vs_s2 <= text_vs_s1;
            text_hs_s2 <= text_hs_s1;
            text_vblank_s2 <= text_vblank_s1;
            text_hblank_s2 <= text_hblank_s1;
            text_in_text_s2 <= text_in_text_s1;
            text_overlay_enable_s2 <= text_overlay_enable_s1;
            text_phosphor_amber_s2 <= text_phosphor_amber_s1;
            text_scanlines_s2 <= text_scanlines_s1;
            text_char_x_s2 <= text_char_x_s1;
            text_char_y_s2 <= text_char_y_s1;
            text_screen_row_s2 <= text_screen_row_s1;
            text_vram_addr_s2 <= text_vram_addr_s1;
            text_glyph_x_s2 <= text_glyph_x_s1;
            text_glyph_y_s2 <= text_glyph_y_s1;
            text_in_tape_s2 <= text_in_tape_s1;
            avc_in_graphics_s2 <= avc_in_graphics_s1;
            avc_bit_x_s2 <= avc_bit_x_s1;
            avc_blue_bit_x_s2 <= avc_blue_bit_x_s1;
            avc_double_s2 <= avc_double_s1;
            avc_high_green_s2 <= avc_high_green_s1;
            avc_scanline_odd_s2 <= avc_scanline_odd_s1;
            avc_cursor_on_s2 <= avc_cursor_on_s1;
          END IF;
        END PROCESS DO_TEXT_STAGE2;

        -- stage 3: select character source and register the final character code
        DO_TEXT_STAGE3 : PROCESS (pix_rst, pix_clk) IS
          VARIABLE char_code_v : STD_LOGIC_VECTOR(7 DOWNTO 0);
          VARIABLE row_char_v : STD_LOGIC_VECTOR(7 DOWNTO 0);
          VARIABLE row_char_y_v : STD_LOGIC_VECTOR(3 DOWNTO 0);
          VARIABLE row_screen_row_v : STD_LOGIC_VECTOR(3 DOWNTO 0);
          VARIABLE row_vram_addr_v : STD_LOGIC_VECTOR(9 DOWNTO 0);
          VARIABLE char_x_i : INTEGER;
          VARIABLE avc_bit_i : INTEGER RANGE 0 TO 7;
          VARIABLE avc_blue_bit_i : INTEGER RANGE 0 TO 7;
        BEGIN
          IF pix_rst = '1' THEN
            text_vs_s3 <= '0';
            text_hs_s3 <= '0';
            text_vblank_s3 <= '1';
            text_hblank_s3 <= '1';
            text_in_text_s3 <= '0';
            text_overlay_enable_s3 <= '0';
            text_phosphor_amber_s3 <= '0';
            text_scanlines_s3 <= '0';
            text_char_x_s3 <= (OTHERS => '0');
            text_char_y_s3 <= (OTHERS => '0');
            text_glyph_x_s3 <= (OTHERS => '0');
            text_glyph_y_s3 <= (OTHERS => '0');
            text_char_code_s3 <= (OTHERS => '0');
            text_debug_row_char_y <= (OTHERS => '0');
            text_debug_row_screen_row <= (OTHERS => '0');
            text_debug_row_vram_addr <= (OTHERS => '0');
            text_debug_row_first_char <= x"20";
            text_in_tape_s3 <= '0';
            avc_in_graphics_s3 <= '0';
            avc_red_on_s3 <= '0';
            avc_green_on_s3 <= '0';
            avc_blue_on_s3 <= '0';
            avc_scanline_odd_s3 <= '0';
            avc_cursor_on_s3 <= '0';
          ELSIF rising_edge(pix_clk) THEN
            text_vs_s3 <= text_vs_s2;
            text_hs_s3 <= text_hs_s2;
            text_vblank_s3 <= text_vblank_s2;
            text_hblank_s3 <= text_hblank_s2;
            text_in_text_s3 <= text_in_text_s2;
            text_overlay_enable_s3 <= text_overlay_enable_s2;
            text_phosphor_amber_s3 <= text_phosphor_amber_s2;
            text_scanlines_s3 <= text_scanlines_s2;
            text_char_x_s3 <= text_char_x_s2;
            text_char_y_s3 <= text_char_y_s2;
            text_glyph_x_s3 <= text_glyph_x_s2;
            text_glyph_y_s3 <= text_glyph_y_s2;
            text_char_code_s3 <= x"20";
            text_in_tape_s3 <= text_in_tape_s2;
            avc_in_graphics_s3 <= avc_in_graphics_s2;
            avc_red_on_s3 <= '0';
            avc_green_on_s3 <= '0';
            avc_blue_on_s3 <= '0';
            avc_scanline_odd_s3 <= avc_scanline_odd_s2;
            avc_cursor_on_s3 <= avc_cursor_on_s2;

            IF avc_in_graphics_s2 = '1' THEN
              avc_bit_i := 7 - to_integer(unsigned(avc_bit_x_s2));
              IF avc_double_s2 = '1' THEN
                -- In double density the red and green shifters form one
                -- 784-pixel stream (red byte first) presented as green.
                -- Blue remains a normal 392-pixel plane, doubled here.
                IF avc_high_green_s2 = '1' THEN
                  avc_green_on_s3 <= avc_green_data(avc_bit_i) AND avc_control_pix(5);
                ELSE
                  avc_green_on_s3 <= avc_red_data(avc_bit_i) AND avc_control_pix(5);
                END IF;
                avc_blue_bit_i := 7 - to_integer(unsigned(avc_blue_bit_x_s2));
                avc_blue_on_s3 <= avc_blue_data(avc_blue_bit_i) AND avc_control_pix(6);
              ELSE
                avc_red_on_s3 <= avc_red_data(avc_bit_i) AND avc_control_pix(4);
                avc_green_on_s3 <= avc_green_data(avc_bit_i) AND avc_control_pix(5);
                avc_blue_on_s3 <= avc_blue_data(avc_bit_i) AND avc_control_pix(6);
              END IF;
            END IF;

            IF text_in_text_s2 = '1' THEN
              char_code_v := x"20";
              row_char_v := text_debug_row_first_char;
              row_char_y_v := text_debug_row_char_y;
              row_screen_row_v := text_debug_row_screen_row;
              row_vram_addr_v := text_debug_row_vram_addr;
              char_x_i := to_integer(unsigned(text_char_x_s2));

              IF text_in_tape_s2 = '1' THEN
                CASE to_integer(unsigned(text_char_x_s2)) IS
                  WHEN 0 =>
                    IF tape_led_active_pix = '1' THEN
                      char_code_v := x"54"; -- T
                    ELSE
                      char_code_v := x"20";
                    END IF;
                  WHEN 1 =>
                    IF tape_led_active_pix = '1' THEN
                      char_code_v := x"41"; -- A
                    ELSE
                      char_code_v := x"20";
                    END IF;
                  WHEN 2 =>
                    IF tape_led_active_pix = '1' THEN
                      char_code_v := x"50"; -- P
                    ELSE
                      char_code_v := x"20";
                    END IF;
                  WHEN 3 =>
                    IF tape_led_active_pix = '1' THEN
                      char_code_v := x"45"; -- E
                    ELSE
                      char_code_v := x"20";
                    END IF;
                  WHEN 5 =>
                    IF halt_active_pix = '1' THEN
                      char_code_v := x"48"; -- H
                    ELSE
                      char_code_v := x"20";
                    END IF;
                  WHEN 6 =>
                    IF halt_active_pix = '1' THEN
                      char_code_v := x"41"; -- A
                    ELSE
                      char_code_v := x"20";
                    END IF;
                  WHEN 7 =>
                    IF halt_active_pix = '1' THEN
                      char_code_v := x"4C"; -- L
                    ELSE
                      char_code_v := x"20";
                    END IF;
                  WHEN 8 =>
                    IF halt_active_pix = '1' THEN
                      char_code_v := x"54"; -- T
                    ELSE
                      char_code_v := x"20";
                    END IF;
                  WHEN 10 =>
                    IF pmod_fault_active_pix = '1' THEN
                      char_code_v := x"50"; -- P
                    ELSE
                      char_code_v := x"20";
                    END IF;
                  WHEN 11 =>
                    IF pmod_fault_active_pix = '1' THEN
                      char_code_v := x"4D"; -- M
                    ELSE
                      char_code_v := x"20";
                    END IF;
                  WHEN 12 =>
                    IF pmod_fault_active_pix = '1' THEN
                      char_code_v := x"4F"; -- O
                    ELSE
                      char_code_v := x"20";
                    END IF;
                  WHEN 13 =>
                    IF pmod_fault_active_pix = '1' THEN
                      char_code_v := x"44"; -- D
                    ELSE
                      char_code_v := x"20";
                    END IF;
                  WHEN 14 =>
                    IF pmod_fault_active_pix = '1' THEN
                      IF pmod_fault_pmod2_pix = '1' THEN
                        char_code_v := x"32"; -- 2
                      ELSE
                        char_code_v := x"31"; -- 1
                      END IF;
                    ELSE
                      char_code_v := x"20";
                    END IF;
                  WHEN 15 =>
                    IF pmod_fault_active_pix = '1' THEN
                      char_code_v := x"21"; -- !
                    ELSE
                      char_code_v := x"20";
                    END IF;
                  WHEN OTHERS => char_code_v := x"20";
                END CASE;
              ELSIF text_overlay_enable_s2 = '1' THEN
                char_code_v := overlay_char_data;
              ELSE
                char_code_v := vram_data;
              END IF;

              IF TEXT_PIPELINE_DEBUG AND text_overlay_enable_s2 = '0' THEN
                IF char_x_i = 0 THEN
                  row_char_v := char_code_v;
                  row_char_y_v := text_char_y_s2;
                  row_screen_row_v := text_screen_row_s2;
                  row_vram_addr_v := text_vram_addr_s2;
                  text_debug_row_first_char <= char_code_v;
                  text_debug_row_char_y <= text_char_y_s2;
                  text_debug_row_screen_row <= text_screen_row_s2;
                  text_debug_row_vram_addr <= text_vram_addr_s2;
                END IF;

                CASE char_x_i IS
                  WHEN 0 =>
                    char_code_v := hex_char(text_char_y_s2);
                  WHEN 1 =>
                    char_code_v := hex_char(row_screen_row_v);
                  WHEN 2 =>
                    char_code_v := hex_char("00" & row_vram_addr_v(9 DOWNTO 8));
                  WHEN 3 =>
                    char_code_v := hex_char(row_vram_addr_v(7 DOWNTO 4));
                  WHEN 4 =>
                    char_code_v := hex_char(row_vram_addr_v(3 DOWNTO 0));
                  WHEN 5 =>
                    char_code_v := hex_char(row_char_v(7 DOWNTO 4));
                  WHEN 6 =>
                    char_code_v := hex_char(row_char_v(3 DOWNTO 0));
                  WHEN 7 =>
                    IF row_char_y_v = text_char_y_s2 THEN
                      char_code_v := STD_LOGIC_VECTOR(to_unsigned(CHARACTER'pos('O'), 8));
                    ELSE
                      char_code_v := STD_LOGIC_VECTOR(to_unsigned(CHARACTER'pos('X'), 8));
                    END IF;
                  WHEN OTHERS =>
                    NULL;
                END CASE;
              END IF;

              text_char_code_s3 <= char_code_v;
            END IF;
          END IF;
        END PROCESS DO_TEXT_STAGE3;

        -- stage 4: glyph ROM lookup and pixel-bit selection
        DO_TEXT_STAGE4 : PROCESS (pix_rst, pix_clk) IS
          VARIABLE glyph_x_i : INTEGER;
          VARIABLE glyph_y_i : INTEGER;
          VARIABLE char_x_i : INTEGER;
          VARIABLE char_addr : INTEGER;
          VARIABLE logo_addr_i : INTEGER;
          VARIABLE row_bits : STD_LOGIC_VECTOR(7 DOWNTO 0);
        BEGIN
          IF pix_rst = '1' THEN
            text_vs_s4 <= '0';
            text_hs_s4 <= '0';
            text_vblank_s4 <= '1';
            text_hblank_s4 <= '1';
            text_in_text_s4 <= '0';
            text_phosphor_amber_s4 <= '0';
            text_scanlines_s4 <= '0';
            text_pixel_on_s4 <= '0';
            text_scanline_odd_s4 <= '0';
            avc_in_graphics_s4 <= '0';
            avc_red_on_s4 <= '0';
            avc_green_on_s4 <= '0';
            avc_blue_on_s4 <= '0';
            avc_scanline_odd_s4 <= '0';
            avc_cursor_on_s4 <= '0';
          ELSIF rising_edge(pix_clk) THEN
            text_vs_s4 <= text_vs_s3;
            text_hs_s4 <= text_hs_s3;
            text_vblank_s4 <= text_vblank_s3;
            text_hblank_s4 <= text_hblank_s3;
            text_in_text_s4 <= text_in_text_s3;
            text_phosphor_amber_s4 <= text_phosphor_amber_s3;
            text_scanlines_s4 <= text_scanlines_s3;
            text_pixel_on_s4 <= '0';
            text_scanline_odd_s4 <= text_glyph_y_s3(0);
            avc_in_graphics_s4 <= avc_in_graphics_s3;
            avc_red_on_s4 <= avc_red_on_s3;
            avc_green_on_s4 <= avc_green_on_s3;
            avc_blue_on_s4 <= avc_blue_on_s3;
            avc_scanline_odd_s4 <= avc_scanline_odd_s3;
            avc_cursor_on_s4 <= avc_cursor_on_s3;

            IF text_in_text_s3 = '1' THEN
              glyph_x_i := to_integer(unsigned(text_glyph_x_s3));
              glyph_y_i := to_integer(unsigned(text_glyph_y_s3));
              char_x_i := to_integer(unsigned(text_char_x_s3));
              char_addr := to_integer(unsigned(text_char_code_s3)) * 16 + glyph_y_i;
              row_bits := CHARROM(char_addr);
              IF row_bits(7 - glyph_x_i) = '1' THEN
                text_pixel_on_s4 <= '1';
              END IF;

              IF text_overlay_enable_s3 = '1' AND text_in_tape_s3 = '0' AND
                text_char_y_s3 = x"0" AND
                char_x_i < 12 AND glyph_y_i < 15 THEN
                logo_addr_i := glyph_y_i * 12 + char_x_i;
                row_bits := NASCOMLOGO(logo_addr_i);
                IF row_bits(7 - glyph_x_i) = '1' THEN
                  text_pixel_on_s4 <= '1';
                END IF;
              END IF;
            END IF;
          END IF;
        END PROCESS DO_TEXT_STAGE4;

        -- stage 5: only color mapping remains combinational
        DO_TEXT_RASTER : PROCESS (
          text_vs_s4, text_hs_s4, text_vblank_s4, text_hblank_s4,
          text_in_text_s4, text_phosphor_amber_s4,
          text_scanlines_s4, text_pixel_on_s4, text_scanline_odd_s4,
          avc_in_graphics_s4, avc_red_on_s4, avc_green_on_s4,
          avc_blue_on_s4, avc_scanline_odd_s4, avc_cursor_on_s4,
          avc_terminal_mode_pix, avc_control_pix
          ) IS
          VARIABLE raster_r_v : STD_LOGIC_VECTOR(7 DOWNTO 0);
          VARIABLE raster_g_v : STD_LOGIC_VECTOR(7 DOWNTO 0);
          VARIABLE raster_b_v : STD_LOGIC_VECTOR(7 DOWNTO 0);
        BEGIN
          raster_vs <= text_vs_s4;
          raster_hs <= text_hs_s4;
          raster_vblank <= text_vblank_s4;
          raster_hblank <= text_hblank_s4;

          raster_r_v := (OTHERS => '0');
          raster_g_v := (OTHERS => '0');
          raster_b_v := (OTHERS => '0');

          IF avc_in_graphics_s4 = '1' THEN
            IF avc_terminal_mode_pix = '1' OR
              (avc_control_pix(3) = '1' AND avc_control_pix(5) = '1' AND
              avc_control_pix(6) = '0') THEN
              -- The 96-column CP/M terminal and the monochrome AVC
              -- double-density mode use the red and green shifters as one
              -- 784-pixel stream presented through the green AVC output.
              -- Colour that stream like the normal NASCOM display.  Keep
              -- double-density modes with blue enabled as real AVC colour.
              IF avc_green_on_s4 = '1' THEN
                IF text_phosphor_amber_s4 = '0' THEN
                  raster_g_v := x"C0";
                ELSE
                  raster_r_v := x"FF";
                  raster_g_v := x"B0";
                END IF;
              END IF;
            ELSE
              IF avc_red_on_s4 = '1' THEN
                raster_r_v := x"FF";
              END IF;
              IF avc_green_on_s4 = '1' THEN
                raster_g_v := x"FF";
              END IF;
              IF avc_blue_on_s4 = '1' THEN
                raster_b_v := x"FF";
              END IF;
            END IF;

            IF avc_cursor_on_s4 = '1' THEN
              raster_r_v := NOT raster_r_v;
              raster_g_v := NOT raster_g_v;
              raster_b_v := NOT raster_b_v;
            END IF;

            IF text_scanlines_s4 = '1' AND avc_scanline_odd_s4 = '1' THEN
              raster_r_v := '0' & raster_r_v(7 DOWNTO 1);
              raster_g_v := '0' & raster_g_v(7 DOWNTO 1);
              raster_b_v := '0' & raster_b_v(7 DOWNTO 1);
            END IF;
          ELSIF text_in_text_s4 = '1' THEN
            IF text_pixel_on_s4 = '1' THEN
              IF text_phosphor_amber_s4 = '0' THEN
                raster_r_v := x"00";
                raster_g_v := x"C0";
                raster_b_v := x"00";
              ELSE
                raster_r_v := x"FF";
                raster_g_v := x"B0";
                raster_b_v := x"00";
              END IF;
            ELSE
              IF text_phosphor_amber_s4 = '0' THEN
                raster_r_v := x"00";
                raster_g_v := x"08";
                raster_b_v := x"00";
              ELSE
                raster_r_v := x"08";
                raster_g_v := x"04";
                raster_b_v := x"00";
              END IF;
            END IF;

            IF text_scanlines_s4 = '1' AND text_scanline_odd_s4 = '1' THEN
              raster_r_v := '0' & raster_r_v(7 DOWNTO 1);
              raster_g_v := '0' & raster_g_v(7 DOWNTO 1);
              raster_b_v := '0' & raster_b_v(7 DOWNTO 1);
            END IF;
          END IF;

          raster_r <= raster_r_v;
          raster_g <= raster_g_v;
          raster_b <= raster_b_v;
        END PROCESS DO_TEXT_RASTER;

        DO_VGA_PIPELINE : PROCESS (pix_rst, pix_clk) IS
        BEGIN
          IF pix_rst = '1' THEN
            vga_vs <= '0';
            vga_hs <= '0';
            vga_vblank <= '1';
            vga_hblank <= '1';
            vga_r <= (OTHERS => '0');
            vga_g <= (OTHERS => '0');
            vga_b <= (OTHERS => '0');
          ELSIF rising_edge(pix_clk) THEN
            vga_vs <= raster_vs;
            vga_hs <= raster_hs;
            vga_vblank <= raster_vblank;
            vga_hblank <= raster_hblank;
            vga_r <= raster_r;
            vga_g <= raster_g;
            vga_b <= raster_b;
          END IF;
        END PROCESS DO_VGA_PIPELINE;

        -- Recover the active-first raster coordinates expected by HDMItest's
        -- packet scheduler from the already-pipelined VGA blanking.  HDMItest
        -- uses one common counter for DE, sync, preambles and guard bands.  Do
        -- the same here: using VGA-derived DE/sync together with separately
        -- reconstructed packet coordinates can lose one announced video line
        -- when their vertical phases differ by a line (reported as 800x599).
        --
        -- Re-lock X at the start of every horizontal active interval and Y at
        -- both vertical active/blank boundaries.  The processes observe the
        -- registered VGA transition one pixel later, hence X is set to 1: the
        -- first active pixel was X=0 and the current pixel is X=1.
        HDMI_RASTER_POSITION : PROCESS (pix_rst, pix_clk) IS
        BEGIN
          IF pix_rst = '1' THEN
            hdmi_x_pos <= (OTHERS => '0');
            hdmi_y_pos <= (OTHERS => '0');
            hdmi_hblank_last <= '1';
            hdmi_vblank_last <= '1';
          ELSIF rising_edge(pix_clk) THEN
            IF vga_hblank = '0' AND hdmi_hblank_last = '1' THEN
              hdmi_x_pos <= to_unsigned(1, hdmi_x_pos'length);
            ELSIF hdmi_x_pos = to_unsigned(1055, hdmi_x_pos'length) THEN
              hdmi_x_pos <= (OTHERS => '0');
            ELSE
              hdmi_x_pos <= hdmi_x_pos + 1;
            END IF;

            IF vga_vblank = '0' AND hdmi_vblank_last = '1' THEN
              hdmi_y_pos <= (OTHERS => '0');
            ELSIF vga_vblank = '1' AND hdmi_vblank_last = '0' THEN
              hdmi_y_pos <= to_unsigned(600, hdmi_y_pos'length);
            ELSIF hdmi_x_pos = to_unsigned(1055, hdmi_x_pos'length) THEN
              IF hdmi_y_pos = to_unsigned(627, hdmi_y_pos'length) THEN
                hdmi_y_pos <= (OTHERS => '0');
              ELSE
                hdmi_y_pos <= hdmi_y_pos + 1;
              END IF;
            END IF;

            hdmi_hblank_last <= vga_hblank;
            hdmi_vblank_last <= vga_vblank;
          END IF;
        END PROCESS HDMI_RASTER_POSITION;

        -- Generate every HDMI timing signal from the same coordinates used by
        -- the packet scheduler.  This exactly matches HDMItest's 800x600p60
        -- raster: 800/40/128/88 by 600/1/4/23, positive sync polarity.
        hdmi_de <= '1' WHEN
          hdmi_x_pos < to_unsigned(800, hdmi_x_pos'length) AND
          hdmi_y_pos < to_unsigned(600, hdmi_y_pos'length)
          ELSE '0';
        hdmi_hs <= '1' WHEN
          hdmi_x_pos >= to_unsigned(840, hdmi_x_pos'length) AND
          hdmi_x_pos < to_unsigned(968, hdmi_x_pos'length)
          ELSE '0';
        hdmi_vs <= '1' WHEN
          hdmi_y_pos >= to_unsigned(601, hdmi_y_pos'length) AND
          hdmi_y_pos < to_unsigned(605, hdmi_y_pos'length)
          ELSE '0';

        -- Capture complete PCM words at 48 kHz in the clk100 domain and move
        -- them coherently into pix_clk. A toggle handshake keeps individual
        -- bus bits from belonging to different samples.
        HDMI_AUDIO_CDC : ENTITY work.audio_pcm_cdc
          GENERIC MAP(
            source_clock_hz => 100000000,
            sample_rate_hz => 48000
          )
          PORT MAP(
            source_clk => clk,
            source_reset => rst,
            source_pcm_l => audio_pcm_l,
            source_pcm_r => audio_pcm_r,
            destination_clk => pix_clk,
            destination_reset => pix_rst,
            destination_pcm_l => audio_pcm_l_sync,
            destination_pcm_r => audio_pcm_r_sync,
            destination_valid => audio_pcm_valid_sync
          );

        -- Complete HDMI protocol path from the known-good HDMItest design:
        -- video/control TMDS, guard bands, data islands, AVI and Audio
        -- InfoFrames, ACR and 48-kHz audio sample packets.  Samples are silent
        -- until the Nascom sound source is connected; the transport is active.
        HDMI_CONVERTER : ENTITY work.hdmi_proven_tx
          PORT MAP(
            PixelClk => pix_clk,
            reset => pix_rst,
            audio_enable => '1',
            pcm_l => audio_pcm_l_sync,
            pcm_r => audio_pcm_r_sync,
            pcm_valid => audio_pcm_valid_sync,
            red => vga_r,
            green => vga_g,
            blue => vga_b,
            hsync => hdmi_hs,
            vsync => hdmi_vs,
            de => hdmi_de,
            x_pos => hdmi_x_pos,
            y_pos => hdmi_y_pos,
            tmds_ch0 => tmds(0),
            tmds_ch1 => tmds(1),
            tmds_ch2 => tmds(2)
          );

          -- serialiser and output buffers: in this design we use TMDS SelectIO outputs

          HDMI_SER : COMPONENT hdmi_tx_selectio
            PORT MAP(
              sclki => pix_clk_x5,
              prsti => pix_rst,
              pclki => pix_clk,
              pi(0) => tmds(0),
              pi(1) => tmds(1),
              pi(2) => tmds(2),
              pclko => hdmi_clk,
              so => hdmi_d
            );

            HDMI_OUT_CLK : COMPONENT obufds
              PORT MAP(
                i => hdmi_clk,
                o => hdmi_clk_p,
                ob => hdmi_clk_n
              );

              GEN_CH : FOR i IN 0 TO 2 GENERATE
                HDMI_OUT_D : COMPONENT obufds
                  PORT MAP(
                    i => hdmi_d(i),
                    o => hdmi_d_p(i),
                    ob => hdmi_d_n(i)
                  );
                END GENERATE GEN_CH;

              END ARCHITECTURE synth;


