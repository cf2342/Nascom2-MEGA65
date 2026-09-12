LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.sd_file_pkg.ALL;

PACKAGE help_overlay_pkg IS

  SUBTYPE text_line_t IS STRING(1 TO 48);
  TYPE help_page_t IS ARRAY (0 TO 15) OF text_line_t;

  FUNCTION overlay_line_text(
    page_sel : STD_LOGIC_VECTOR(3 DOWNTO 0);
    row_i : INTEGER;
    cfg_row_sel : STD_LOGIC_VECTOR(2 DOWNTO 0);
    cfg_speed_sel : STD_LOGIC_VECTOR(1 DOWNTO 0);
    cfg_phosphor_amber : STD_LOGIC;
    cfg_scanlines : STD_LOGIC;
    cfg_video_zoom : STD_LOGIC_VECTOR(1 DOWNTO 0);
    cfg_rs232_sel : STD_LOGIC_VECTOR(2 DOWNTO 0);
    cfg_rs232_speed_sel : STD_LOGIC_VECTOR(3 DOWNTO 0);
    cfg_rs232_flow : STD_LOGIC;
    cfg_slot_rom_sel : STD_LOGIC_VECTOR(3 DOWNTO 0);
    cfg_fdd_enabled : STD_LOGIC;
    cfg_cpm_enabled : STD_LOGIC;
    cfg_avc_enabled : STD_LOGIC;
    cfg_bls_enabled : STD_LOGIC;
    sd_cd_raw : STD_LOGIC;
    sd_init_busy : STD_LOGIC;
    sd_init_done : STD_LOGIC;
    sd_init_error : STD_LOGIC;
    sd_read_busy : STD_LOGIC;
    sd_read_done : STD_LOGIC;
    sd_read_error : STD_LOGIC;
    sd_read_stage : STD_LOGIC_VECTOR(1 DOWNTO 0);
    sd_read_lba : STD_LOGIC_VECTOR(31 DOWNTO 0);
    sd_read_token : STD_LOGIC_VECTOR(7 DOWNTO 0);
    sd_read_count : STD_LOGIC_VECTOR(15 DOWNTO 0);
    sd_read_first_word : STD_LOGIC_VECTOR(31 DOWNTO 0);
    sd_card_block_addressing : STD_LOGIC;
    sd_debug_read_cmd17_r1 : STD_LOGIC_VECTOR(7 DOWNTO 0);
    sd_debug_read_error_code : STD_LOGIC_VECTOR(3 DOWNTO 0);
    sd_debug_root_current_cluster : STD_LOGIC_VECTOR(31 DOWNTO 0);
    sd_debug_root_next_cluster : STD_LOGIC_VECTOR(31 DOWNTO 0);
    sd_debug_root_sectors_left : STD_LOGIC_VECTOR(7 DOWNTO 0);
    sd_debug_root_scan_phase : STD_LOGIC;
    sd_debug_root_scan_job : STD_LOGIC_VECTOR(1 DOWNTO 0);
    sd_part_lba : STD_LOGIC_VECTOR(31 DOWNTO 0);
    sd_boot_spc : STD_LOGIC_VECTOR(7 DOWNTO 0);
    sd_boot_reserved : STD_LOGIC_VECTOR(15 DOWNTO 0);
    sd_boot_num_fats : STD_LOGIC_VECTOR(7 DOWNTO 0);
    sd_boot_spf : STD_LOGIC_VECTOR(31 DOWNTO 0);
    sd_root_dir_lba : STD_LOGIC_VECTOR(31 DOWNTO 0);
    sd_browser_dir_found : STD_LOGIC;
    sd_browser_has_files : STD_LOGIC;
    sd_root_total_file_count : INTEGER RANGE 0 TO 255;
    sd_page_valid : sd_page_valid_array_t;
    sd_page_name : sd_page_name_array_t;
    sd_page_kind : sd_page_kind_array_t;
    fdd_mount_a_valid : STD_LOGIC;
    fdd_mount_a_name : STD_LOGIC_VECTOR(87 DOWNTO 0);
    fdd_mount_b_valid : STD_LOGIC;
    fdd_mount_b_name : STD_LOGIC_VECTOR(87 DOWNTO 0);
    ui_sd_page_base : INTEGER RANGE 0 TO SD_BROWSER_LAST_INDEX;
    ui_sd_page_row : INTEGER RANGE 0 TO SD_BROWSER_PAGE_LAST;
    sd_file_load_addr_valid : STD_LOGIC;
    sd_file_load_addr : STD_LOGIC_VECTOR(15 DOWNTO 0);
    browser_manage_mode : STD_LOGIC_VECTOR(2 DOWNTO 0);
    browser_manage_name : STD_LOGIC_VECTOR(63 DOWNTO 0);
    browser_manage_status : STD_LOGIC_VECTOR(3 DOWNTO 0);
    tape_led_active : STD_LOGIC;
    cfg_dirty : STD_LOGIC;
    cfg_apply_pending : STD_LOGIC;
    cfg_apply_error : STD_LOGIC;
    cfg_load_busy : STD_LOGIC;
    cfg_load_pending : STD_LOGIC;
    cfg_load_seen : STD_LOGIC;
    cfg_load_ok : STD_LOGIC;
    cfg_load_error : STD_LOGIC;
    save_name : STD_LOGIC_VECTOR(63 DOWNTO 0);
    save_row_sel : INTEGER RANGE 0 TO 4;
    save_mode_basic : STD_LOGIC;
    save_mode_bls : STD_LOGIC;
    save_start_addr_digit : INTEGER RANGE 0 TO 3;
    save_end_addr_digit : INTEGER RANGE 0 TO 3;
    save_start_addr_manual : STD_LOGIC_VECTOR(15 DOWNTO 0);
    save_end_addr_manual : STD_LOGIC_VECTOR(15 DOWNTO 0);
    save_basic_available : STD_LOGIC;
    save_basic_ready : STD_LOGIC;
    save_basic_start_addr : STD_LOGIC_VECTOR(15 DOWNTO 0);
    save_basic_end_addr : STD_LOGIC_VECTOR(15 DOWNTO 0);
    save_effective_start_addr : STD_LOGIC_VECTOR(15 DOWNTO 0);
    save_effective_end_addr : STD_LOGIC_VECTOR(15 DOWNTO 0);
    save_effective_len : STD_LOGIC_VECTOR(15 DOWNTO 0);
    save_check_busy : STD_LOGIC;
    save_checked : STD_LOGIC;
    save_name_exists : STD_LOGIC;
    save_check_can_create : STD_LOGIC;
    save_check_can_allocate : STD_LOGIC;
    save_check_requires_dir_growth : STD_LOGIC;
    save_check_dir_full : STD_LOGIC;
    save_overwrite_confirmed : STD_LOGIC;
    save_ready_to_write : STD_LOGIC;
    save_write_after_check : STD_LOGIC;
    save_write_busy : STD_LOGIC;
    save_write_done : STD_LOGIC;
    save_write_error : STD_LOGIC;
    save_write_status : STD_LOGIC_VECTOR(3 DOWNTO 0);
    sd_last_r1 : STD_LOGIC_VECTOR(7 DOWNTO 0);
    sd_state_code : STD_LOGIC_VECTOR(7 DOWNTO 0)
  ) RETURN text_line_t;

  FUNCTION help_char_code(
    page_sel : STD_LOGIC_VECTOR(3 DOWNTO 0);
    row_i : INTEGER;
    col_i : INTEGER;
    cfg_row_sel : STD_LOGIC_VECTOR(2 DOWNTO 0);
    cfg_speed_sel : STD_LOGIC_VECTOR(1 DOWNTO 0);
    cfg_phosphor_amber : STD_LOGIC;
    cfg_scanlines : STD_LOGIC;
    cfg_video_zoom : STD_LOGIC_VECTOR(1 DOWNTO 0);
    cfg_rs232_sel : STD_LOGIC_VECTOR(2 DOWNTO 0);
    cfg_rs232_speed_sel : STD_LOGIC_VECTOR(3 DOWNTO 0);
    cfg_rs232_flow : STD_LOGIC;
    cfg_slot_rom_sel : STD_LOGIC_VECTOR(3 DOWNTO 0);
    cfg_fdd_enabled : STD_LOGIC;
    cfg_cpm_enabled : STD_LOGIC;
    cfg_avc_enabled : STD_LOGIC;
    cfg_bls_enabled : STD_LOGIC;
    sd_cd_raw : STD_LOGIC;
    sd_init_busy : STD_LOGIC;
    sd_init_done : STD_LOGIC;
    sd_init_error : STD_LOGIC;
    sd_read_busy : STD_LOGIC;
    sd_read_done : STD_LOGIC;
    sd_read_error : STD_LOGIC;
    sd_read_stage : STD_LOGIC_VECTOR(1 DOWNTO 0);
    sd_read_lba : STD_LOGIC_VECTOR(31 DOWNTO 0);
    sd_read_token : STD_LOGIC_VECTOR(7 DOWNTO 0);
    sd_read_count : STD_LOGIC_VECTOR(15 DOWNTO 0);
    sd_read_first_word : STD_LOGIC_VECTOR(31 DOWNTO 0);
    sd_card_block_addressing : STD_LOGIC;
    sd_debug_read_cmd17_r1 : STD_LOGIC_VECTOR(7 DOWNTO 0);
    sd_debug_read_error_code : STD_LOGIC_VECTOR(3 DOWNTO 0);
    sd_debug_root_current_cluster : STD_LOGIC_VECTOR(31 DOWNTO 0);
    sd_debug_root_next_cluster : STD_LOGIC_VECTOR(31 DOWNTO 0);
    sd_debug_root_sectors_left : STD_LOGIC_VECTOR(7 DOWNTO 0);
    sd_debug_root_scan_phase : STD_LOGIC;
    sd_debug_root_scan_job : STD_LOGIC_VECTOR(1 DOWNTO 0);
    sd_part_lba : STD_LOGIC_VECTOR(31 DOWNTO 0);
    sd_boot_spc : STD_LOGIC_VECTOR(7 DOWNTO 0);
    sd_boot_reserved : STD_LOGIC_VECTOR(15 DOWNTO 0);
    sd_boot_num_fats : STD_LOGIC_VECTOR(7 DOWNTO 0);
    sd_boot_spf : STD_LOGIC_VECTOR(31 DOWNTO 0);
    sd_root_dir_lba : STD_LOGIC_VECTOR(31 DOWNTO 0);
    sd_browser_dir_found : STD_LOGIC;
    sd_browser_has_files : STD_LOGIC;
    sd_root_total_file_count : INTEGER RANGE 0 TO 255;
    sd_page_valid : sd_page_valid_array_t;
    sd_page_name : sd_page_name_array_t;
    sd_page_kind : sd_page_kind_array_t;
    fdd_mount_a_valid : STD_LOGIC;
    fdd_mount_a_name : STD_LOGIC_VECTOR(87 DOWNTO 0);
    fdd_mount_b_valid : STD_LOGIC;
    fdd_mount_b_name : STD_LOGIC_VECTOR(87 DOWNTO 0);
    ui_sd_page_base : INTEGER RANGE 0 TO SD_BROWSER_LAST_INDEX;
    ui_sd_page_row : INTEGER RANGE 0 TO SD_BROWSER_PAGE_LAST;
    sd_file_load_addr_valid : STD_LOGIC;
    sd_file_load_addr : STD_LOGIC_VECTOR(15 DOWNTO 0);
    browser_manage_mode : STD_LOGIC_VECTOR(2 DOWNTO 0);
    browser_manage_name : STD_LOGIC_VECTOR(63 DOWNTO 0);
    browser_manage_status : STD_LOGIC_VECTOR(3 DOWNTO 0);
    tape_led_active : STD_LOGIC;
    cfg_dirty : STD_LOGIC;
    cfg_apply_pending : STD_LOGIC;
    cfg_apply_error : STD_LOGIC;
    cfg_load_busy : STD_LOGIC;
    cfg_load_pending : STD_LOGIC;
    cfg_load_seen : STD_LOGIC;
    cfg_load_ok : STD_LOGIC;
    cfg_load_error : STD_LOGIC;
    save_name : STD_LOGIC_VECTOR(63 DOWNTO 0);
    save_row_sel : INTEGER RANGE 0 TO 4;
    save_mode_basic : STD_LOGIC;
    save_mode_bls : STD_LOGIC;
    save_start_addr_digit : INTEGER RANGE 0 TO 3;
    save_end_addr_digit : INTEGER RANGE 0 TO 3;
    save_start_addr_manual : STD_LOGIC_VECTOR(15 DOWNTO 0);
    save_end_addr_manual : STD_LOGIC_VECTOR(15 DOWNTO 0);
    save_basic_available : STD_LOGIC;
    save_basic_ready : STD_LOGIC;
    save_basic_start_addr : STD_LOGIC_VECTOR(15 DOWNTO 0);
    save_basic_end_addr : STD_LOGIC_VECTOR(15 DOWNTO 0);
    save_effective_start_addr : STD_LOGIC_VECTOR(15 DOWNTO 0);
    save_effective_end_addr : STD_LOGIC_VECTOR(15 DOWNTO 0);
    save_effective_len : STD_LOGIC_VECTOR(15 DOWNTO 0);
    save_check_busy : STD_LOGIC;
    save_checked : STD_LOGIC;
    save_name_exists : STD_LOGIC;
    save_check_can_create : STD_LOGIC;
    save_check_can_allocate : STD_LOGIC;
    save_check_requires_dir_growth : STD_LOGIC;
    save_check_dir_full : STD_LOGIC;
    save_overwrite_confirmed : STD_LOGIC;
    save_ready_to_write : STD_LOGIC;
    save_write_after_check : STD_LOGIC;
    save_write_busy : STD_LOGIC;
    save_write_done : STD_LOGIC;
    save_write_error : STD_LOGIC;
    save_write_status : STD_LOGIC_VECTOR(3 DOWNTO 0);
    sd_last_r1 : STD_LOGIC_VECTOR(7 DOWNTO 0);
    sd_state_code : STD_LOGIC_VECTOR(7 DOWNTO 0)
  ) RETURN INTEGER;

END PACKAGE help_overlay_pkg;

PACKAGE BODY help_overlay_pkg IS

  FUNCTION pad48(s : STRING) RETURN text_line_t IS
    VARIABLE r : text_line_t := (OTHERS => ' ');
    VARIABLE dst_i : INTEGER := 1;
  BEGIN
    FOR src_i IN s'RANGE LOOP
      EXIT WHEN dst_i > 48;
      r(dst_i) := s(src_i);
      dst_i := dst_i + 1;
    END LOOP;
    RETURN r;
  END FUNCTION;

  FUNCTION hex_char(nibble : STD_LOGIC_VECTOR(3 DOWNTO 0)) RETURN CHARACTER IS
  BEGIN
    CASE nibble IS
      WHEN "0000" => RETURN '0';
      WHEN "0001" => RETURN '1';
      WHEN "0010" => RETURN '2';
      WHEN "0011" => RETURN '3';
      WHEN "0100" => RETURN '4';
      WHEN "0101" => RETURN '5';
      WHEN "0110" => RETURN '6';
      WHEN "0111" => RETURN '7';
      WHEN "1000" => RETURN '8';
      WHEN "1001" => RETURN '9';
      WHEN "1010" => RETURN 'A';
      WHEN "1011" => RETURN 'B';
      WHEN "1100" => RETURN 'C';
      WHEN "1101" => RETURN 'D';
      WHEN "1110" => RETURN 'E';
      WHEN OTHERS => RETURN 'F';
    END CASE;
  END FUNCTION;

  FUNCTION byte_char(byte_v : STD_LOGIC_VECTOR(7 DOWNTO 0)) RETURN CHARACTER IS
    VARIABLE code_i : INTEGER;
  BEGIN
    code_i := to_integer(unsigned(byte_v));
    IF code_i < 16#20# OR code_i > 16#7E# THEN
      RETURN ' ';
    END IF;
    RETURN CHARACTER'val(code_i);
  END FUNCTION;

  FUNCTION hex8(byte_v : STD_LOGIC_VECTOR(7 DOWNTO 0)) RETURN STRING IS
    VARIABLE s : STRING(1 TO 2);
  BEGIN
    s(1) := hex_char(byte_v(7 DOWNTO 4));
    s(2) := hex_char(byte_v(3 DOWNTO 0));
    RETURN s;
  END FUNCTION;

  FUNCTION hex16(word_v : STD_LOGIC_VECTOR(15 DOWNTO 0)) RETURN STRING IS
    VARIABLE s : STRING(1 TO 4);
  BEGIN
    s(1) := hex_char(word_v(15 DOWNTO 12));
    s(2) := hex_char(word_v(11 DOWNTO 8));
    s(3) := hex_char(word_v(7 DOWNTO 4));
    s(4) := hex_char(word_v(3 DOWNTO 0));
    RETURN s;
  END FUNCTION;

  FUNCTION dec2(value_i : INTEGER RANGE 0 TO 99) RETURN STRING IS
    VARIABLE s : STRING(1 TO 2);
  BEGIN
    s(1) := CHARACTER'VAL(CHARACTER'POS('0') + (value_i / 10));
    s(2) := CHARACTER'VAL(CHARACTER'POS('0') + (value_i MOD 10));
    RETURN s;
  END FUNCTION;

  FUNCTION dec3(value_i : INTEGER RANGE 0 TO 255) RETURN STRING IS
    VARIABLE s : STRING(1 TO 3);
  BEGIN
    s(1) := CHARACTER'VAL(CHARACTER'POS('0') + ((value_i / 100) MOD 10));
    s(2) := CHARACTER'VAL(CHARACTER'POS('0') + ((value_i / 10) MOD 10));
    s(3) := CHARACTER'VAL(CHARACTER'POS('0') + (value_i MOD 10));
    RETURN s;
  END FUNCTION;

  FUNCTION browser_range_text(
    page_base_i : INTEGER RANGE 0 TO SD_BROWSER_LAST_INDEX;
    total_count_i : INTEGER RANGE 0 TO 255
  ) RETURN STRING IS
    VARIABLE first_i : INTEGER RANGE 0 TO 255 := 0;
    VARIABLE last_i : INTEGER RANGE 0 TO 255 := 0;
  BEGIN
    IF total_count_i = 0 THEN
      RETURN "-------";
    END IF;

    first_i := page_base_i;
    IF page_base_i + SD_BROWSER_PAGE_SIZE - 1 < total_count_i THEN
      last_i := page_base_i + SD_BROWSER_PAGE_SIZE - 1;
    ELSE
      last_i := total_count_i - 1;
    END IF;

    RETURN dec3(first_i + 1) & "-" & dec3(last_i + 1);
  END FUNCTION;

  FUNCTION hex32(dword_v : STD_LOGIC_VECTOR(31 DOWNTO 0)) RETURN STRING IS
    VARIABLE s : STRING(1 TO 8);
  BEGIN
    s(1) := hex_char(dword_v(31 DOWNTO 28));
    s(2) := hex_char(dword_v(27 DOWNTO 24));
    s(3) := hex_char(dword_v(23 DOWNTO 20));
    s(4) := hex_char(dword_v(19 DOWNTO 16));
    s(5) := hex_char(dword_v(15 DOWNTO 12));
    s(6) := hex_char(dword_v(11 DOWNTO 8));
    s(7) := hex_char(dword_v(7 DOWNTO 4));
    s(8) := hex_char(dword_v(3 DOWNTO 0));
    RETURN s;
  END FUNCTION;

  -- derzeit nicht benutz, SD-Karten Status
  FUNCTION stage_text(
    sd_read_done : STD_LOGIC;
    sd_read_error : STD_LOGIC;
    sd_read_stage : STD_LOGIC_VECTOR(1 DOWNTO 0)
  ) RETURN STRING IS
  BEGIN
    IF sd_read_error = '1' THEN
      RETURN "ERROR";
    ELSIF sd_read_done = '1' THEN
      RETURN "READY";
    ELSIF sd_read_stage = "11" THEN
      RETURN "FILE ";
    ELSIF sd_read_stage = "10" THEN
      RETURN "ROOT ";
    ELSIF sd_read_stage = "01" THEN
      RETURN "BOOT ";
    ELSE
      RETURN "MBR  ";
    END IF;
  END FUNCTION;

  FUNCTION short_name_83(name_v : STD_LOGIC_VECTOR(87 DOWNTO 0)) RETURN STRING IS
    VARIABLE s : STRING(1 TO 12);
  BEGIN
    s(1) := byte_char(name_v(87 DOWNTO 80));
    s(2) := byte_char(name_v(79 DOWNTO 72));
    s(3) := byte_char(name_v(71 DOWNTO 64));
    s(4) := byte_char(name_v(63 DOWNTO 56));
    s(5) := byte_char(name_v(55 DOWNTO 48));
    s(6) := byte_char(name_v(47 DOWNTO 40));
    s(7) := byte_char(name_v(39 DOWNTO 32));
    s(8) := byte_char(name_v(31 DOWNTO 24));
    s(9) := '.';
    s(10) := byte_char(name_v(23 DOWNTO 16));
    s(11) := byte_char(name_v(15 DOWNTO 8));
    s(12) := byte_char(name_v(7 DOWNTO 0));
    RETURN s;
  END FUNCTION;

  FUNCTION is_dsk_name(name_v : STD_LOGIC_VECTOR(87 DOWNTO 0)) RETURN BOOLEAN IS
  BEGIN
    RETURN name_v(23 DOWNTO 0) = x"44534B";
  END FUNCTION;

  FUNCTION dsk_kind_tag(kind_v : STD_LOGIC_VECTOR(1 DOWNTO 0)) RETURN STRING IS
  BEGIN
    CASE kind_v IS
      WHEN SD_DSK_KIND_CPM    => RETURN "[CP/M]  ";
      WHEN SD_DSK_KIND_NASSYS => RETURN "[NASSYS]";
      WHEN OTHERS             => RETURN "[?]     ";
    END CASE;
  END FUNCTION;

  FUNCTION save_name_8(name_v : STD_LOGIC_VECTOR(63 DOWNTO 0)) RETURN STRING IS
    VARIABLE s : STRING(1 TO 8);
  BEGIN
    s(1) := byte_char(name_v(63 DOWNTO 56));
    s(2) := byte_char(name_v(55 DOWNTO 48));
    s(3) := byte_char(name_v(47 DOWNTO 40));
    s(4) := byte_char(name_v(39 DOWNTO 32));
    s(5) := byte_char(name_v(31 DOWNTO 24));
    s(6) := byte_char(name_v(23 DOWNTO 16));
    s(7) := byte_char(name_v(15 DOWNTO 8));
    s(8) := byte_char(name_v(7 DOWNTO 0));
    RETURN s;
  END FUNCTION;

  FUNCTION hex16_cursor(
    word_v : STD_LOGIC_VECTOR(15 DOWNTO 0);
    digit_i : INTEGER RANGE 0 TO 3
  ) RETURN STRING IS
    VARIABLE s : STRING(1 TO 6);
    VARIABLE raw_v : STRING(1 TO 4);
  BEGIN
    raw_v := hex16(word_v);
    CASE digit_i IS
      WHEN 0 =>
        s := "[" & raw_v(1) & "]" & raw_v(2 TO 4);
      WHEN 1 =>
        s := raw_v(1 TO 1) & "[" & raw_v(2) & "]" & raw_v(3 TO 4);
      WHEN 2 =>
        s := raw_v(1 TO 2) & "[" & raw_v(3) & "]" & raw_v(4 TO 4);
      WHEN OTHERS =>
        s := raw_v(1 TO 3) & "[" & raw_v(4) & "]";
    END CASE;
    RETURN s;
  END FUNCTION;

  FUNCTION sd_page_line(
    row_i : INTEGER;
    cfg_fdd_enabled : STD_LOGIC;
    sd_cd_raw : STD_LOGIC;
    sd_init_busy : STD_LOGIC;
    sd_init_done : STD_LOGIC;
    sd_init_error : STD_LOGIC;
    sd_read_busy : STD_LOGIC;
    sd_read_done : STD_LOGIC;
    sd_read_error : STD_LOGIC;
    sd_read_stage : STD_LOGIC_VECTOR(1 DOWNTO 0);
    sd_read_lba : STD_LOGIC_VECTOR(31 DOWNTO 0);
    sd_read_token : STD_LOGIC_VECTOR(7 DOWNTO 0);
    sd_read_count : STD_LOGIC_VECTOR(15 DOWNTO 0);
    sd_read_first_word : STD_LOGIC_VECTOR(31 DOWNTO 0);
    sd_card_block_addressing : STD_LOGIC;
    sd_debug_read_cmd17_r1 : STD_LOGIC_VECTOR(7 DOWNTO 0);
    sd_debug_read_error_code : STD_LOGIC_VECTOR(3 DOWNTO 0);
    sd_debug_root_current_cluster : STD_LOGIC_VECTOR(31 DOWNTO 0);
    sd_debug_root_next_cluster : STD_LOGIC_VECTOR(31 DOWNTO 0);
    sd_debug_root_sectors_left : STD_LOGIC_VECTOR(7 DOWNTO 0);
    sd_debug_root_scan_phase : STD_LOGIC;
    sd_debug_root_scan_job : STD_LOGIC_VECTOR(1 DOWNTO 0);
    sd_part_lba : STD_LOGIC_VECTOR(31 DOWNTO 0);
    sd_boot_spc : STD_LOGIC_VECTOR(7 DOWNTO 0);
    sd_boot_reserved : STD_LOGIC_VECTOR(15 DOWNTO 0);
    sd_boot_num_fats : STD_LOGIC_VECTOR(7 DOWNTO 0);
    sd_boot_spf : STD_LOGIC_VECTOR(31 DOWNTO 0);
    sd_root_dir_lba : STD_LOGIC_VECTOR(31 DOWNTO 0);
    sd_browser_dir_found : STD_LOGIC;
    sd_browser_has_files : STD_LOGIC;
    sd_root_total_file_count : INTEGER RANGE 0 TO 255;
    sd_page_valid : sd_page_valid_array_t;
    sd_page_name : sd_page_name_array_t;
    sd_page_kind : sd_page_kind_array_t;
    fdd_mount_a_valid : STD_LOGIC;
    fdd_mount_a_name : STD_LOGIC_VECTOR(87 DOWNTO 0);
    fdd_mount_b_valid : STD_LOGIC;
    fdd_mount_b_name : STD_LOGIC_VECTOR(87 DOWNTO 0);
    ui_sd_page_base : INTEGER RANGE 0 TO SD_BROWSER_LAST_INDEX;
    ui_sd_page_row : INTEGER RANGE 0 TO SD_BROWSER_PAGE_LAST;
    sd_file_load_addr_valid : STD_LOGIC;
    sd_file_load_addr : STD_LOGIC_VECTOR(15 DOWNTO 0);
    browser_manage_mode : STD_LOGIC_VECTOR(2 DOWNTO 0);
    browser_manage_name : STD_LOGIC_VECTOR(63 DOWNTO 0);
    browser_manage_status : STD_LOGIC_VECTOR(3 DOWNTO 0)
  ) RETURN text_line_t IS
    VARIABLE line : text_line_t := pad48("");
    VARIABLE list_index_i : INTEGER RANGE 0 TO SD_BROWSER_PAGE_LAST := 0;
  BEGIN
    CASE row_i IS
      WHEN 0 =>
        line := pad48("             FILE BROWSER");
      WHEN 1 =>
        line := pad48("             CARD PRESENT/INIT IDLE ");
        IF sd_cd_raw = '1' THEN
          line := pad48("             CARD OUT    /INIT IDLE ");
        ELSIF sd_init_done = '1' THEN
          line := pad48("             CARD PRESENT/INIT READY");
        ELSIF sd_init_error = '1' THEN
          line := pad48("             CARD PRESENT/INIT ERROR");
        ELSIF sd_init_busy = '1' THEN
          line := pad48("             CARD PRESENT/INIT BUSY ");
        END IF;
      WHEN 2 =>
        line := pad48("SCANNING /NASCOM2...");
        IF sd_browser_has_files = '1' THEN
          line := pad48("SHOWING " & browser_range_text(ui_sd_page_base, sd_root_total_file_count) & " OF " & dec3(sd_root_total_file_count));
        ELSIF sd_browser_dir_found = '0' AND sd_read_done = '1' THEN
          line := pad48("NASCOM2 DIRECTORY NOT FOUND");
        ELSIF sd_browser_dir_found = '1' AND sd_read_done = '1' THEN
          line := pad48("NASCOM2 DIRECTORY IS EMPTY");
        ELSIF sd_read_error = '1' THEN
          line := pad48("SD READ ERROR WHILE SCANNING /NASCOM2");
        END IF;
      WHEN 3 =>
        line := pad48("  FILE NAME");
        IF cfg_fdd_enabled = '1' THEN
          line := pad48("  FILE NAME     TYPE     MOUNT");
        END IF;
        IF sd_read_error = '1' THEN
          line := pad48("ERR S" & hex8("000000" & sd_read_stage) & " L" & hex32(sd_read_lba) &
            " T" & hex8(sd_read_token) & " C" & hex16(sd_read_count) & " BA=");
          IF sd_card_block_addressing = '1' THEN
            line(32) := 'Y';
          ELSE
            line(32) := 'N';
          END IF;
        END IF;
      WHEN 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 =>
        line := pad48("  <none>");
        IF sd_read_error = '1' AND row_i = 4 THEN
          line := pad48("RC" & hex32(sd_debug_root_current_cluster) &
            " RN" & hex32(sd_debug_root_next_cluster));
        ELSIF sd_read_error = '1' AND row_i = 5 THEN
          line := pad48("SL" & hex8(sd_debug_root_sectors_left) &
            " PH" & hex8("0000000" & sd_debug_root_scan_phase) &
            " RJ" & hex8("000000" & sd_debug_root_scan_job));
        ELSIF sd_read_error = '1' AND row_i = 6 THEN
          line := pad48("R1" & hex8(sd_debug_read_cmd17_r1) &
            " EC" & hex8("0000" & sd_debug_read_error_code));
        ELSIF sd_read_error = '1' AND row_i = 7 THEN
          line := pad48("PL" & hex32(sd_part_lba) &
            " RL" & hex32(sd_root_dir_lba));
        ELSIF sd_read_error = '1' AND row_i = 8 THEN
          line := pad48("RS" & hex16(sd_boot_reserved) &
            " NF" & hex8(sd_boot_num_fats) &
            " SP" & hex8(sd_boot_spc));
        ELSIF sd_read_error = '1' AND row_i = 9 THEN
          line := pad48("FS" & hex32(sd_boot_spf));
        ELSE
          list_index_i := row_i - 4;
          IF sd_page_valid(list_index_i) = '1' THEN
            line := pad48("  " & short_name_83(sd_page_name(list_index_i)));
            IF cfg_fdd_enabled = '1' AND is_dsk_name(sd_page_name(list_index_i)) THEN
              IF fdd_mount_a_valid = '1' AND fdd_mount_a_name = sd_page_name(list_index_i) AND
                  fdd_mount_b_valid = '1' AND fdd_mount_b_name = sd_page_name(list_index_i) THEN
                line := pad48("  " & short_name_83(sd_page_name(list_index_i)) & "  " &
                  dsk_kind_tag(sd_page_kind(list_index_i)) & " 0/1+2/3");
              ELSIF fdd_mount_a_valid = '1' AND fdd_mount_a_name = sd_page_name(list_index_i) THEN
                line := pad48("  " & short_name_83(sd_page_name(list_index_i)) & "  " &
                  dsk_kind_tag(sd_page_kind(list_index_i)) & " 0/1");
              ELSIF fdd_mount_b_valid = '1' AND fdd_mount_b_name = sd_page_name(list_index_i) THEN
                line := pad48("  " & short_name_83(sd_page_name(list_index_i)) & "  " &
                  dsk_kind_tag(sd_page_kind(list_index_i)) & " 2/3");
              ELSE
                line := pad48("  " & short_name_83(sd_page_name(list_index_i)) & "  " &
                  dsk_kind_tag(sd_page_kind(list_index_i)) & " ---");
              END IF;
            END IF;
            IF ui_sd_page_row = list_index_i THEN
              line(1) := '>';
            END IF;
          END IF;
        END IF;
      WHEN 14 =>
        CASE browser_manage_mode IS
          WHEN "001" => line := pad48("RENAME: " & save_name_8(browser_manage_name));
          WHEN "010" => line := pad48("RENAME TO " & save_name_8(browser_manage_name) & " ?  Y/N");
          WHEN "011" => line := pad48("DELETE SELECTED FILE?  Y/N");
          WHEN "100" => line := pad48("FILE OPERATION IN PROGRESS...");
          WHEN "101" => line := pad48("FILE OPERATION FAILED - ENTER/ESC");
          WHEN OTHERS => line := pad48("ENTER LOAD/MOUNT  R RENAME  DEL DELETE");
        END CASE;
      WHEN 15 =>
        line := pad48("STATUS: WAIT NASCOM2");
        IF browser_manage_mode = "001" THEN
          line := pad48("TYPE 1-8 CHARS  ENTER ACCEPTS  ESC CANCELS");
        ELSIF browser_manage_mode = "010" OR browser_manage_mode = "011" THEN
          line := pad48("Y CONFIRMS  N/ESC CANCELS");
        ELSIF browser_manage_mode = "100" THEN
          line := pad48("STATUS: BUSY - DO NOT REMOVE SD CARD");
        ELSIF browser_manage_mode = "101" THEN
          CASE browser_manage_status IS
            WHEN x"0" => line := pad48("STATUS: DONE                 ENTER RETURNS");
            WHEN x"1" => line := pad48("STATUS: FILE NOT FOUND       ENTER RETURNS");
            WHEN x"2" => line := pad48("STATUS: NAME EXISTS          ENTER RETURNS");
            WHEN x"3" => line := pad48("STATUS: LONG NAME PROTECTED  ENTER RETURNS");
            WHEN x"4" => line := pad48("STATUS: READ ONLY            ENTER RETURNS");
            WHEN x"5" => line := pad48("STATUS: SD I/O ERROR         ENTER RETURNS");
            WHEN x"6" => line := pad48("STATUS: BAD FAT CHAIN        ENTER RETURNS");
            WHEN OTHERS => line := pad48("STATUS: ERROR                ENTER RETURNS");
          END CASE;
        ELSIF sd_read_stage = "11" THEN
          IF sd_read_error = '1' THEN
            line := pad48("STATUS: ERROR         ENTER LOADS, F11 RETURNS");
          ELSIF sd_read_done = '1' THEN
            IF sd_file_load_addr_valid = '1' THEN
              line := pad48("STATUS: DONE A" & hex16(sd_file_load_addr) & "    ENTER LOADS, F11 RETURNS");
            ELSE
              line := pad48("STATUS: DONE          ENTER LOADS, F11 RETURNS");
            END IF;
          ELSIF sd_read_busy = '1' THEN
            line := pad48("STATUS: BUSY          ENTER LOADS, F11 RETURNS");
          ELSE
            line := pad48("STATUS: READY         ENTER LOADS, F11 RETURNS");
          END IF;
        ELSIF sd_browser_dir_found = '0' AND sd_read_done = '1' THEN
          line := pad48("STATUS: NASCOM2 MISS  ENTER LOADS, F11 RETURNS");
        ELSIF sd_browser_has_files = '1' THEN
          line := pad48("STATUS: READY         ENTER LOADS, F11 RETURNS");
        ELSIF sd_browser_dir_found = '1' AND sd_read_done = '1' THEN
          line := pad48("STATUS: DIR EMPTY     ENTER LOADS, F11 RETURNS");
        ELSE
          line := pad48("STATUS: WAIT NASCOM2  ENTER LOADS, F11 RETURNS");
        END IF;
      WHEN OTHERS =>
        line := pad48("");
    END CASE;

    RETURN line;
  END FUNCTION;

  CONSTANT HELP_PAGE_KEYBOARD : help_page_t := (
    0 => pad48("             HELP F1 KEYBOARD F3 NAS-SYS3 CMDS"),
    1 => pad48("             F1/F3 TOGGLE OVERLAY."),
    2 => pad48(""),
    3 => pad48("MEGA65 KEYBOARD TO NASCOM:"),
    4 => pad48("A-Z, 0-9, SPC, BS, SHIFT, '@:;,.-'  DIRECT"),
    5 => pad48("SHIFT ; -> +   * -> [   = -> ]"),
    6 => pad48("SHIFT : -> *   RESTORE -> LF/CH"),
    7 => pad48("TAB->GRAPH  CTRL->CTRL   ENTER->NEW LINE"),
    8 => pad48(""),
    9 => pad48("SHIFT+CLR/HOME -> NMI  (CTRL ALSO WORKS)"),
    10 => pad48(""),
    11 => pad48("F9 SAVE, F11 LOAD, F13 CONFIGURATION"),
    12 => pad48("F5 DEBUG MODE, F7 CP/M FDD DIAGNOSTICS"),
    13 => pad48(""),
    14 => pad48("ON NEXYS VIDEO BOARD: F3=F2, F11=F10, F13=F12"),
    15 => pad48("PRESS F1 AGAIN TO RETURN")
  );

  CONSTANT HELP_PAGE_NASSYS : help_page_t := (
    0 => pad48("             HELP F3 NAS-SYS3 CMDS F1 KEYBOARD"),
    1 => pad48("             COMMON MONITOR COMMANDS:"),
    2 => pad48("A ARITHMETIC         B BREAKPOINT"),
    3 => pad48("C COPY               D ZEAP/NAS-DOS"),
    4 => pad48("E EXECUTE            G GENERATE TAPE BLOCK"),
    5 => pad48("I INTELLIGENTCOPY    K KEYBOARD OPTION"),
    6 => pad48("M MODIFY MEMORY      N NORMAL I/O"),
    7 => pad48("O OUTPUT DATA2PORT   P DISPLAY REGISTERS"),
    8 => pad48("Q QUERY PORT DATA    R READ FROM TAPE/SERIAL"),
    9 => pad48("S SINGLE STEP        T TABULATE MEMORY"),
    10 => pad48("U USER I/O           W WRITE TO TAPE/SERIAL"),
    11 => pad48("X EXTERNAL I/O       Y TOOLKIT"),
    12 => pad48("Z BASIC WARM START   J BASIC COLD START"),
    13 => pad48(""),
    14 => pad48("ASK YOUR NASCOM-DEALER FOR FULL DETAILS"),
    15 => pad48("PRESS F3 AGAIN TO RETURN")
  );

  FUNCTION dec3(value_i : STD_LOGIC_VECTOR(7 DOWNTO 0)) RETURN STRING IS
    VARIABLE value_v : INTEGER := to_integer(UNSIGNED(value_i));
    VARIABLE result_v : STRING(1 TO 3) := "000";
  BEGIN
    result_v(1) := CHARACTER'VAL(CHARACTER'POS('0') + (value_v / 100));
    result_v(2) := CHARACTER'VAL(CHARACTER'POS('0') + ((value_v / 10) MOD 10));
    result_v(3) := CHARACTER'VAL(CHARACTER'POS('0') + (value_v MOD 10));
    RETURN result_v;
  END FUNCTION;

  FUNCTION ipv4_text(value_i : STD_LOGIC_VECTOR(31 DOWNTO 0)) RETURN STRING IS
  BEGIN
    RETURN dec3(value_i(31 DOWNTO 24)) & "." & dec3(value_i(23 DOWNTO 16)) & "." &
           dec3(value_i(15 DOWNTO 8)) & "." & dec3(value_i(7 DOWNTO 0));
  END FUNCTION;

  FUNCTION cfg_page_line(
    page_sel : STD_LOGIC_VECTOR(3 DOWNTO 0);
    row_i : INTEGER;
    cfg_row_sel : STD_LOGIC_VECTOR(2 DOWNTO 0);
    cfg_speed_sel : STD_LOGIC_VECTOR(1 DOWNTO 0);
    cfg_phosphor_amber : STD_LOGIC;
    cfg_scanlines : STD_LOGIC;
    cfg_video_zoom : STD_LOGIC_VECTOR(1 DOWNTO 0);
    cfg_rs232_sel : STD_LOGIC_VECTOR(2 DOWNTO 0);
    cfg_rs232_speed_sel : STD_LOGIC_VECTOR(3 DOWNTO 0);
    cfg_rs232_flow : STD_LOGIC;
    cfg_slot_rom_sel : STD_LOGIC_VECTOR(3 DOWNTO 0);
    cfg_fdd_enabled : STD_LOGIC;
    cfg_cpm_enabled : STD_LOGIC;
    cfg_avc_enabled : STD_LOGIC;
    cfg_bls_enabled : STD_LOGIC;
    cfg_dirty : STD_LOGIC;
    cfg_apply_pending : STD_LOGIC;
    cfg_apply_error : STD_LOGIC;
    cfg_load_busy : STD_LOGIC;
    cfg_load_pending : STD_LOGIC;
    cfg_load_seen : STD_LOGIC;
    cfg_load_ok : STD_LOGIC;
    cfg_load_error : STD_LOGIC;
    cfg_debug_read_lba : STD_LOGIC_VECTOR(31 DOWNTO 0);
    cfg_debug_first_word : STD_LOGIC_VECTOR(31 DOWNTO 0);
    cfg_debug_root_current : STD_LOGIC_VECTOR(31 DOWNTO 0);
    cfg_debug_root_next : STD_LOGIC_VECTOR(31 DOWNTO 0);
    cfg_debug_rx_frames : STD_LOGIC_VECTOR(7 DOWNTO 0);
    cfg_debug_destination_frames : STD_LOGIC_VECTOR(7 DOWNTO 0);
    cfg_debug_arp_type_frames : STD_LOGIC_VECTOR(7 DOWNTO 0);
    cfg_debug_arp_match_frames : STD_LOGIC_VECTOR(7 DOWNTO 0);
    cfg_debug_read_error_code : STD_LOGIC_VECTOR(3 DOWNTO 0)
  ) RETURN text_line_t IS
    VARIABLE line : text_line_t := pad48("");
  BEGIN
    IF page_sel = "0010" THEN
      CASE row_i IS
        WHEN 0 => 
          line := pad48("             CONFIG  1/2  F13=NEXT, ENTER=SAVE");
          IF cfg_debug_read_error_code(0) = '1' THEN
            line(24) := '3';
          END IF;
        WHEN 2 =>
          line := pad48("UP/DOWN SELECTS. LEFT/RIGHT CHANGES VALUE.");
        WHEN 4 =>
          line := pad48("  RESET MACHINE             PRESS ENTER");
          IF cfg_row_sel = "000" THEN
            line(1) := '>';
          END IF;
        WHEN 6 =>
          line := pad48("  CPU SPEED                 1 MHZ");
          CASE cfg_speed_sel IS
            WHEN "00" =>
              line(29 TO 33) := "1 MHZ";
            WHEN "01" =>
              line(29 TO 33) := "2 MHZ";
            WHEN OTHERS =>
              line(29 TO 33) := "4 MHZ";
          END CASE;
          IF cfg_avc_enabled = '1' THEN
            line(37 TO 43) := "AVC MIN";
          END IF;
          IF cfg_row_sel = "001" THEN
            line(1) := '>';
          END IF;
        WHEN 7 =>
          line := pad48("  SCREEN STYLE              GREEN      ");
          IF cfg_phosphor_amber = '1' THEN
            IF cfg_scanlines = '1' THEN
              line(29 TO 39) := "AMBER+SCAN ";
            ELSE
              line(29 TO 39) := "AMBER      ";
            END IF;
          ELSE
            IF cfg_scanlines = '1' THEN
              line(29 TO 39) := "GREEN+SCAN ";
            ELSE
              line(29 TO 39) := "GREEN      ";
            END IF;
          END IF;
          IF cfg_row_sel = "010" THEN
            line(1) := '>';
          END IF;
        WHEN 8 =>
          line := pad48("  VIDEO SIZE                ORIGINAL");
          IF cfg_video_zoom(1) = '1' THEN
            line(29 TO 39) := "ZOOM 200%  ";
          ELSIF cfg_video_zoom(0) = '1' THEN
            line(29 TO 39) := "ZOOM 150%  ";
          ELSE
            line(29 TO 39) := "ORIGINAL   ";
          END IF;
          IF cfg_row_sel = "011" THEN
            line(1) := '>';
          END IF;
        WHEN 10 =>
          line := pad48("  RS232                     JTAG");
          CASE cfg_rs232_sel IS
            WHEN "000" =>
              line(29 TO 39) := "JTAG       ";
            WHEN "001" =>
              line(29 TO 39) := "PMOD 1 High";
            WHEN "010" =>
              line(29 TO 39) := "PMOD 1 Low ";
            WHEN "011" =>
              line(29 TO 39) := "PMOD 2 High";
            WHEN OTHERS =>
              line(29 TO 39) := "PMOD 2 Low ";
          END CASE;
          IF cfg_row_sel = "100" THEN
            line(1) := '>';
          END IF;
        WHEN 11 =>
          line := pad48("  BAUD-RATE                 FIXED 115200");
          IF cfg_rs232_sel /= "000" THEN
            CASE cfg_rs232_speed_sel IS
              WHEN "0000" =>
                line(29 TO 40) := "300         ";
              WHEN "0001" =>
                line(29 TO 40) := "1200        ";
              WHEN "0010" =>
                line(29 TO 40) := "2400        ";
              WHEN "0011" =>
                line(29 TO 40) := "4800        ";
              WHEN "0100" =>
                line(29 TO 40) := "9600        ";
              WHEN "0101" =>
                line(29 TO 40) := "14400       ";
              WHEN "0110" =>
                line(29 TO 40) := "19200       ";
              WHEN "0111" =>
                line(29 TO 40) := "38400       ";
              WHEN "1000" =>
                line(29 TO 40) := "57600       ";
              WHEN OTHERS =>
                line(29 TO 40) := "115200      ";
            END CASE;
          END IF;
          IF cfg_row_sel = "101" THEN
            line(1) := '>';
          END IF;
        WHEN 12 =>
          line := pad48("  RTS/CTS                   JTAG ONLY");
          IF cfg_rs232_sel /= "000" THEN
            line(29 TO 39) := "OFF        ";
            IF cfg_rs232_flow = '1' THEN
              line(29 TO 39) := "ON         ";
            END IF;
          END IF;
          IF cfg_row_sel = "110" THEN
            line(1) := '>';
          END IF;
        WHEN 13 =>
          IF cfg_apply_pending = '1' THEN
            line := pad48("STATUS: SAVING N2CONF.CFG...");
          ELSIF cfg_apply_error = '1' THEN
            line := pad48("STATUS: WRITE ERROR, CONFIG NOT SAVED");
          ELSE
            line := pad48("");
          END IF;
        WHEN 15 =>
          IF cfg_dirty = '1' THEN
            line := pad48("STATUS: PENDING CHANGES NOT YET APPLIED");
          ELSE
            line := pad48("STATUS: PAGE MATCHES LIVE SYSTEM          ");
          END IF;
        WHEN OTHERS =>
          line := pad48("");
      END CASE;
    ELSIF page_sel = "0011" THEN
      CASE row_i IS
        WHEN 0 =>
          line := pad48("             RAM/ROM 2/2  F13=NEXT, ENTER=SAVE");
          IF cfg_debug_read_error_code(0) = '1' THEN
            line(24) := '3';
          END IF;
        WHEN 1 =>
          line := pad48("             UP/DN SELECTS, L/R CHANGES VALUE.");
        WHEN 2 =>
          line := pad48("RAM $0000-$AFFF, BASIC $E000 STAY FIXED.");
          IF cfg_bls_enabled = '1' THEN
            line := pad48("BLS: ROM $A000-$CFFF, RAM $E000-$FFFF.");
          ELSIF cfg_cpm_enabled = '1' THEN
            line := pad48("CP/M AND AVC CARD NEEDS 48K RAM.         ");
          END IF;
        WHEN 4 =>
          line := pad48("  B000-B7FF                    RAM");
          IF cfg_bls_enabled = '1' THEN
            line := pad48("  A000-CFFF BLS PASCAL V1.3    ROM");
          ELSIF cfg_slot_rom_sel(0) = '1' THEN
            line := pad48("  B000-B7FF TOOLKIT            ROM");
          END IF;
          IF cfg_row_sel = "000" THEN
            line(1) := '>';
          END IF;
        WHEN 5 =>
          line := pad48("  B800-BFFF                    RAM");
          IF cfg_bls_enabled = '1' THEN
            line := pad48("  B000-BFFF BLS PASCAL         ROM");
          ELSIF cfg_slot_rom_sel(1) = '1' THEN
            line := pad48("  B800-BFFF NASPEN             ROM");
          END IF;
          IF cfg_row_sel = "001" THEN
            line(1) := '>';
          END IF;
        WHEN 6 =>
          line := pad48("  C000-CFFF                    RAM");
          IF cfg_bls_enabled = '1' THEN
            line := pad48("  C000-CFFF BLS PASCAL         ROM");
          ELSIF cfg_slot_rom_sel(2) = '1' THEN
            line := pad48("  C000-CFFF NASDIS/SUPERDEBUG  ROM");
          END IF;
          IF cfg_row_sel = "010" THEN
            line(1) := '>';
          END IF;
        WHEN 7 =>
          line := pad48("  D000-DFFF                    RAM");
          IF cfg_cpm_enabled = '1' THEN
            line := pad48("  D000-DFFF (CP/M)             RAM");
          ELSIF cfg_fdd_enabled = '1' THEN
            line := pad48("  D000-DFFF NAS-DOS            ROM");
          ELSIF cfg_bls_enabled = '1' THEN
            line := pad48("  D000-DFFF                    RAM");
          ELSIF cfg_slot_rom_sel(3) = '1' THEN
            line := pad48("  D000-DFFF ZEAP ASM 2.1       ROM");
          END IF;
          IF cfg_row_sel = "011" THEN
            line(1) := '>';
          END IF;
        WHEN 9 =>
          line := pad48("  FDD / NAS-DOS                OFF");
          IF cfg_fdd_enabled = '1' THEN
            line := pad48("  FDD / NAS-DOS                ON");
          END IF;
          IF cfg_row_sel = "100" THEN
            line(1) := '>';
          END IF;
        WHEN 10 =>
          line := pad48("  CP/M-MODUS                   OFF");
          IF cfg_cpm_enabled = '1' THEN
            line := pad48("  CP/M-MODUS                   ON");
          END IF;
          IF cfg_row_sel = "101" THEN
            line(1) := '>';
          END IF;
        WHEN 11 =>
          line := pad48("  AVC GRAPHIC CARD             OFF");
          IF cfg_avc_enabled = '1' THEN
            line := pad48("  AVC GRAPHIC CARD             ON");
          END IF;
          IF cfg_row_sel = "110" THEN
            line(1) := '>';
          END IF;
        WHEN 12 =>
          line := pad48("  BLS PASCAL V1.3              OFF");
          IF cfg_bls_enabled = '1' THEN
            line := pad48("  BLS PASCAL V1.3              ON");
          END IF;
          IF cfg_row_sel = "111" THEN
            line(1) := '>';
          END IF;
        WHEN 14 =>
          IF cfg_apply_pending = '1' THEN
            line := pad48("STATUS: SAVING N2CONF.CFG...");
          ELSIF cfg_apply_error = '1' THEN
            line := pad48("STATUS: WRITE ERROR, CONFIG NOT SAVED");
          ELSIF cfg_dirty = '1' THEN
            line := pad48("STATUS: PENDING CHANGES NOT YET APPLIED");
          ELSE
            line := pad48("STATUS: PAGE MATCHES LIVE SYSTEM          ");
          END IF;
        WHEN 15 =>
          IF cfg_debug_read_error_code(0) = '1' THEN
            line := pad48("ENTER APPLIES. F13 OPENS NETWORK SETTINGS.");
          ELSE
            line := pad48("ENTER APPLIES. F13 CLOSES THE CONFIG PAGES.");
          END IF;
          -- line := pad48("DBG L" & hex32(cfg_debug_read_lba) & " FW" & hex32(cfg_debug_first_word) &
          --   " DST" & hex8(cfg_debug_destination_frames) & " EC" & hex8("0000" & cfg_debug_read_error_code));
        WHEN OTHERS =>
          line := pad48("");
      END CASE;
    ELSE
      ------------------------------------------------------------------------
      -- NETWORK OVERLAY TRANSPORT NOTE
      --
      -- Page 3 currently reuses existing cfg_page_line display arguments to
      -- avoid widening the HDMI overlay interface during the first Ethernet
      -- bring-up.  On this page only:
      --   cfg_phosphor_amber = pending NETWORK enable
      --   cfg_scanlines      = PHY LINK status
      --   cfg_speed_sel      = selected IPv4 octet
      --   cfg_debug_*        = IPv4 fields and Ethernet diagnostic counters
      -- These are display aliases.  They do not modify the real phosphor,
      -- scanline, CPU-speed, or SD-debug state.
      ------------------------------------------------------------------------
      CASE row_i IS
        WHEN 0 =>
          line := pad48("             NETWORK 3/3  F13=NEXT, ENTER=SAVE");
        WHEN 2 =>
          line := pad48("UP/DOWN ROW, TAB OCTET, LEFT/RIGHT VALUE.");
        WHEN 4 =>
          line := pad48("  NETWORK             OFF     LINK DOWN");
          IF cfg_phosphor_amber = '1' THEN line(23 TO 25) := "ON "; END IF;
          IF cfg_scanlines = '1' THEN line(36 TO 39) := "UP  "; END IF;
          IF cfg_row_sel = "000" THEN line(1) := '>'; END IF;
        WHEN 6 =>
          line := pad48("  ADDRESS MODE        STATIC");
          IF cfg_debug_read_error_code(1) = '1' THEN
            line(23 TO 28) := "DHCP  ";
            IF cfg_debug_read_error_code(2) = '1' THEN
              line(31 TO 37) := "BOUND  ";
            ELSE
              line(31 TO 37) := "WAITING";
            END IF;
          END IF;
          IF cfg_row_sel = "001" THEN line(1) := '>'; END IF;
        WHEN 7 =>
          line := pad48("  IP ADDRESS          000.000.000.000");
          line(23 TO 37) := ipv4_text(cfg_debug_read_lba);
          IF cfg_row_sel = "010" THEN line(1) := '>'; END IF;
        WHEN 8 =>
          line := pad48("  NETMASK             000.000.000.000");
          line(23 TO 37) := ipv4_text(cfg_debug_first_word);
          IF cfg_row_sel = "011" THEN line(1) := '>'; END IF;
        WHEN 9 =>
          line := pad48("  GATEWAY             000.000.000.000");
          line(23 TO 37) := ipv4_text(cfg_debug_root_current);
          IF cfg_row_sel = "100" THEN line(1) := '>'; END IF;
        WHEN 10 =>
          line := pad48("  DNS SERVER          000.000.000.000");
          line(23 TO 37) := ipv4_text(cfg_debug_root_next);
          IF cfg_row_sel = "101" THEN line(1) := '>'; END IF;
        WHEN 12 =>
          IF cfg_debug_read_error_code(1) = '1' THEN
            line := pad48("DHCP VALUES ARE READ-ONLY AND NOT SAVED.");
          ELSE
            line := pad48("TAB SELECTS OCTET. CURRENT OCTET: 1");
            line(35) := CHARACTER'VAL(CHARACTER'POS('1') + to_integer(UNSIGNED(cfg_speed_sel)));
          END IF;
        WHEN 13 =>
          IF cfg_apply_pending = '1' THEN
            line := pad48("STATUS: SAVING N2CONF.CFG...");
          ELSIF cfg_apply_error = '1' THEN
            line := pad48("STATUS: WRITE ERROR, CONFIG NOT SAVED");
          ELSE
            line := pad48("");
          END IF;
        WHEN 14 =>
          IF cfg_dirty = '1' THEN
            line := pad48("STATUS: PENDING CHANGES NOT YET APPLIED");
          ELSE
            line := pad48("STATUS: PAGE MATCHES LIVE SYSTEM");
          END IF;
        WHEN 15 =>
          line := pad48("ENTER APPLIES. F13 CLOSES THE CONFIG PAGES.");
        WHEN OTHERS =>
          line := pad48("");
      END CASE;
    END IF;

    RETURN line;
  END FUNCTION;
  FUNCTION save_page_line(
    row_i : INTEGER;
    sd_cd_raw : STD_LOGIC;
    sd_init_busy : STD_LOGIC;
    sd_init_done : STD_LOGIC;
    sd_init_error : STD_LOGIC;
    save_name : STD_LOGIC_VECTOR(63 DOWNTO 0);
    save_row_sel : INTEGER RANGE 0 TO 4;
    save_mode_basic : STD_LOGIC;
    save_mode_bls : STD_LOGIC;
    save_start_addr_digit : INTEGER RANGE 0 TO 3;
    save_end_addr_digit : INTEGER RANGE 0 TO 3;
    save_start_addr_manual : STD_LOGIC_VECTOR(15 DOWNTO 0);
    save_end_addr_manual : STD_LOGIC_VECTOR(15 DOWNTO 0);
    save_basic_available : STD_LOGIC;
    save_basic_ready : STD_LOGIC;
    save_basic_start_addr : STD_LOGIC_VECTOR(15 DOWNTO 0);
    save_basic_end_addr : STD_LOGIC_VECTOR(15 DOWNTO 0);
    save_effective_start_addr : STD_LOGIC_VECTOR(15 DOWNTO 0);
    save_effective_end_addr : STD_LOGIC_VECTOR(15 DOWNTO 0);
    save_effective_len : STD_LOGIC_VECTOR(15 DOWNTO 0);
    save_check_busy : STD_LOGIC;
    save_checked : STD_LOGIC;
    save_name_exists : STD_LOGIC;
    save_check_can_create : STD_LOGIC;
    save_check_can_allocate : STD_LOGIC;
    save_check_requires_dir_growth : STD_LOGIC;
    save_check_dir_full : STD_LOGIC;
    save_overwrite_confirmed : STD_LOGIC;
    save_ready_to_write : STD_LOGIC;
    save_write_after_check : STD_LOGIC;
    save_write_busy : STD_LOGIC;
    save_write_done : STD_LOGIC;
    save_write_error : STD_LOGIC;
    save_write_status : STD_LOGIC_VECTOR(3 DOWNTO 0);
    sd_last_r1 : STD_LOGIC_VECTOR(7 DOWNTO 0);
    sd_state_code : STD_LOGIC_VECTOR(7 DOWNTO 0);
    sd_read_lba : STD_LOGIC_VECTOR(31 DOWNTO 0)
  ) RETURN text_line_t IS
    VARIABLE line : text_line_t := pad48("");
  BEGIN
    CASE row_i IS
      WHEN 0 =>
        line := pad48("             SAVE TO SD-CARD");
      WHEN 1 =>
        line := pad48("             CHOOSE NAME, MODE, RANGE & SAVE");
      WHEN 3 =>
        IF save_mode_bls = '1' THEN
          line := pad48("  NAME : " & save_name_8(save_name) & ".PAS");
        ELSE
          line := pad48("  NAME : " & save_name_8(save_name) & ".NAS");
        END IF;
        IF save_row_sel = 0 THEN
          line(1) := '>';
        END IF;
      WHEN 5 =>
        line := pad48("  MODE : ADDRESS RANGE");
        IF save_mode_bls = '1' THEN
          line := pad48("  MODE : BLS PASCAL SOURCE");
        ELSIF save_mode_basic = '1' THEN
          line := pad48("  MODE : BASIC PROGRAM");
        ELSIF save_basic_available = '0' THEN
          line := pad48("  MODE : ADDRESS RANGE (BASIC NOT INIT)");
        ELSIF save_basic_ready = '0' THEN
          line := pad48("  MODE : ADDRESS RANGE (NO BASIC PROG)");
        END IF;
        IF save_row_sel = 1 THEN
          line(1) := '>';
        END IF;
      WHEN 7 =>
        IF save_mode_bls = '1' THEN
          line := pad48("  START: AUTO " & hex16(save_effective_start_addr));
        ELSIF save_mode_basic = '1' AND save_basic_ready = '1' THEN
          line := pad48("  START: AUTO " & hex16(save_effective_start_addr));
        ELSE
          line := pad48("  START: " & hex16_cursor(save_start_addr_manual, save_start_addr_digit));
        END IF;
        IF save_row_sel = 2 THEN
          line(1) := '>';
        END IF;
      WHEN 8 =>
        IF save_mode_bls = '1' THEN
          line := pad48("  END  : AUTO " & hex16(save_effective_end_addr));
        ELSIF save_mode_basic = '1' AND save_basic_ready = '1' THEN
          line := pad48("  END  : AUTO " & hex16(save_effective_end_addr));
        ELSE
          line := pad48("  END  : " & hex16_cursor(save_end_addr_manual, save_end_addr_digit));
        END IF;
        IF save_row_sel = 3 THEN
          line(1) := '>';
        END IF;
      WHEN 10 =>
        line := pad48("SD-CARD PRESENT/INIT IDLE ");
        IF sd_cd_raw = '1' THEN
          line := pad48("SD-CARD OUT    /INIT IDLE ");
        ELSIF sd_init_done = '1' THEN
          line := pad48("SD-CARD PRESENT/INIT READY");
        ELSIF sd_init_error = '1' THEN
          line := pad48("SD-CARD PRESENT/INIT ERROR");
        ELSIF sd_init_busy = '1' THEN
          line := pad48("SD-CARD PRESENT/INIT BUSY ");
        END IF;
      WHEN 11 =>
        IF save_mode_bls = '1' THEN
          line := pad48("PASCAL : " & hex16(save_effective_start_addr) & "-" & hex16(save_effective_end_addr));
        ELSIF save_basic_available = '0' THEN
          line := pad48("BASIC  : NOT INITIALISED");
        ELSIF save_basic_ready = '0' THEN
          line := pad48("BASIC  : INITIALISED, BUT NO PROGRAM FOUND");
        ELSE
          line := pad48("BASIC  : " & hex16(save_basic_start_addr) & "-" & hex16(save_basic_end_addr));
        END IF;
      WHEN 12 =>
        line := pad48("RANGE  : " & hex16(save_effective_start_addr) & "-" & hex16(save_effective_end_addr) &
          " LENGTH : " & hex16(save_effective_len));
      WHEN 13 =>
        IF save_mode_bls = '1' THEN
          line := pad48("TARGET : /NASCOM2/" & save_name_8(save_name) & ".PAS");
        ELSE
          line := pad48("TARGET : /NASCOM2/" & save_name_8(save_name) & ".NAS");
        END IF;
      WHEN 14 =>
        IF sd_init_done = '1' THEN
          IF save_write_busy = '1' THEN
            IF save_name_exists = '1' THEN
              IF save_mode_bls = '1' THEN
                line := pad48("  SAVE : OVERWRITING EXISTING .PAS FILE");
              ELSE
                line := pad48("  SAVE : OVERWRITING EXISTING .NAS FILE");
              END IF;
            ELSE
              IF save_mode_bls = '1' THEN
                line := pad48("  SAVE : WRITING NEW .PAS FILE...");
              ELSE
                line := pad48("  SAVE : WRITING NEW .NAS FILE...");
              END IF;
            END IF;
          ELSIF save_write_done = '1' THEN
            line := pad48("  SAVE : WRITE DONE");
          ELSIF save_write_error = '1' AND save_write_status = "0001" THEN
            line := pad48("  SAVE : NAME FREE, CREATE STILL PENDING");
          ELSIF save_write_error = '1' AND save_write_status = "0010" THEN
            line := pad48("  SAVE : DATA LONGER THAN TARGET FILE");
          ELSIF save_write_error = '1' AND save_write_status = "0011" THEN
            line := pad48("  SAVE : /NASCOM2 DIRECTORY MISSING");
          ELSIF save_write_error = '1' AND save_write_status = "0110" THEN
            line := pad48("  SAVE : CREATE FITS ONE CLUSTER, WRITE NEXT");
          ELSIF save_write_error = '1' AND save_write_status = "0111" THEN
            line := pad48("  SAVE : CREATE NEEDS MULTI-CLUSTER PATH");
          ELSIF save_write_error = '1' AND save_write_status = "1000" THEN
            line := pad48("  SAVE : CREATE NEEDS DIRECTORY GROWTH");
          ELSIF save_write_error = '1' AND save_write_status = "1001" THEN
            line := pad48("  SAVE : CMD24 REJECTED BY CARD");
          ELSIF save_write_error = '1' AND save_write_status = "1010" THEN
            line := pad48("  SAVE : CMD24 RESPONSE TIMEOUT");
          ELSIF save_write_error = '1' AND save_write_status = "1011" THEN
            line := pad48("  SAVE : DATA RESPONSE TOKEN ERROR");
          ELSIF save_write_error = '1' AND save_write_status = "1100" THEN
            line := pad48("  SAVE : CARD STAYED BUSY TOO LONG");
          ELSIF save_write_error = '1' AND save_write_status = "1101" THEN
            line := pad48("  SAVE : CREATE PHASE STATE ERROR");
          ELSIF save_write_error = '1' AND save_write_status = "1110" THEN
            line := pad48("  SAVE : VERIFY AFTER WRITE FAILED");
          ELSIF save_write_error = '1' AND save_write_status = "1111" THEN
            line := pad48("  SAVE : FAT RUN SEARCH FAILED");
          ELSIF save_write_error = '1' THEN
            line := pad48("  SAVE : WRITE ERROR");
          ELSIF save_write_after_check = '1' OR save_ready_to_write = '1' OR save_check_busy = '1' OR
            (save_checked = '1' AND save_name_exists = '1') OR
            (save_checked = '1' AND save_check_can_create = '1' AND save_check_can_allocate = '1' AND save_check_requires_dir_growth = '0') THEN
            IF save_name_exists = '1' THEN
              IF save_mode_bls = '1' THEN
                line := pad48("  SAVE : SAVING EXISTING .PAS FILE");
              ELSE
                line := pad48("  SAVE : SAVING EXISTING .NAS FILE");
              END IF;
            ELSE
              IF save_mode_bls = '1' THEN
                line := pad48("  SAVE : SAVING .PAS FILE...");
              ELSE
                line := pad48("  SAVE : SAVING .NAS FILE...");
              END IF;
            END IF;
          ELSIF save_name = x"2020202020202020" THEN
            line := pad48("  SAVE : ENTER A NAME FIRST");
          ELSIF save_mode_basic = '0' AND save_mode_bls = '0' AND
            unsigned(save_end_addr_manual) < unsigned(save_start_addr_manual) THEN
            line := pad48("  SAVE : END ADDRESS IS BEFORE START");
          ELSIF save_mode_basic = '1' AND save_basic_ready = '0' THEN
            line := pad48("  SAVE : BASIC PROGRAM NOT AVAILABLE");
          ELSIF save_checked = '1' AND save_name_exists = '1' AND save_overwrite_confirmed = '0' THEN
            line := pad48("  SAVE : FILE EXISTS, ENTER SAVES   ");
          ELSIF save_ready_to_write = '1' THEN
            line := pad48("  SAVE : SAVE STARTING...");
          ELSIF save_checked = '1' AND save_check_dir_full = '1' THEN
            line := pad48("  SAVE : NAME FREE, BUT /NASCOM2 IS FULL");
          ELSIF save_checked = '1' AND save_check_requires_dir_growth = '1' THEN
            line := pad48("  SAVE : CREATE NEEDS DIRECTORY GROWTH");
          ELSIF save_checked = '1' AND save_check_can_create = '1' THEN
            line := pad48("  SAVE : NAME FREE, SLOT READY, NO CLUSTER");
          ELSIF save_checked = '1' THEN
            line := pad48("  SAVE : NAME FREE, CREATE PREP PENDING");
          ELSE
            line := pad48("  SAVE : ENTER SAVES CURRENT FILE  ");
          END IF;
        ELSE
          line := pad48("  SAVE : SD-CARD NOT READY TO WRITE");
        END IF;
        IF save_row_sel = 4 THEN
          line(1) := '>';
        END IF;
      WHEN 15 =>
        line := pad48("                 ENTER ON SAVE STARTS AUTO-SAVE");
        -- The shared save flag can be released by a later SD operation.
        -- Keep showing any retained non-success status so FDD format
        -- failures do not disappear merely by opening the F9 page.
        IF save_write_status /= "0000" AND save_write_status /= "0101" THEN
          line := pad48("DBG WS" & hex8("0000" & save_write_status) & " ST" & hex8(sd_state_code) & " R1" & hex8(sd_last_r1) & " L" & hex32(sd_read_lba));
        END IF;
      WHEN OTHERS =>
        line := pad48("");
    END CASE;

    RETURN line;
  END FUNCTION;

  FUNCTION overlay_line_text(
    page_sel : STD_LOGIC_VECTOR(3 DOWNTO 0);
    row_i : INTEGER;
    cfg_row_sel : STD_LOGIC_VECTOR(2 DOWNTO 0);
    cfg_speed_sel : STD_LOGIC_VECTOR(1 DOWNTO 0);
    cfg_phosphor_amber : STD_LOGIC;
    cfg_scanlines : STD_LOGIC;
    cfg_video_zoom : STD_LOGIC_VECTOR(1 DOWNTO 0);
    cfg_rs232_sel : STD_LOGIC_VECTOR(2 DOWNTO 0);
    cfg_rs232_speed_sel : STD_LOGIC_VECTOR(3 DOWNTO 0);
    cfg_rs232_flow : STD_LOGIC;
    cfg_slot_rom_sel : STD_LOGIC_VECTOR(3 DOWNTO 0);
    cfg_fdd_enabled : STD_LOGIC;
    cfg_cpm_enabled : STD_LOGIC;
    cfg_avc_enabled : STD_LOGIC;
    cfg_bls_enabled : STD_LOGIC;
    sd_cd_raw : STD_LOGIC;
    sd_init_busy : STD_LOGIC;
    sd_init_done : STD_LOGIC;
    sd_init_error : STD_LOGIC;
    sd_read_busy : STD_LOGIC;
    sd_read_done : STD_LOGIC;
    sd_read_error : STD_LOGIC;
    sd_read_stage : STD_LOGIC_VECTOR(1 DOWNTO 0);
    sd_read_lba : STD_LOGIC_VECTOR(31 DOWNTO 0);
    sd_read_token : STD_LOGIC_VECTOR(7 DOWNTO 0);
    sd_read_count : STD_LOGIC_VECTOR(15 DOWNTO 0);
    sd_read_first_word : STD_LOGIC_VECTOR(31 DOWNTO 0);
    sd_card_block_addressing : STD_LOGIC;
    sd_debug_read_cmd17_r1 : STD_LOGIC_VECTOR(7 DOWNTO 0);
    sd_debug_read_error_code : STD_LOGIC_VECTOR(3 DOWNTO 0);
    sd_debug_root_current_cluster : STD_LOGIC_VECTOR(31 DOWNTO 0);
    sd_debug_root_next_cluster : STD_LOGIC_VECTOR(31 DOWNTO 0);
    sd_debug_root_sectors_left : STD_LOGIC_VECTOR(7 DOWNTO 0);
    sd_debug_root_scan_phase : STD_LOGIC;
    sd_debug_root_scan_job : STD_LOGIC_VECTOR(1 DOWNTO 0);
    sd_part_lba : STD_LOGIC_VECTOR(31 DOWNTO 0);
    sd_boot_spc : STD_LOGIC_VECTOR(7 DOWNTO 0);
    sd_boot_reserved : STD_LOGIC_VECTOR(15 DOWNTO 0);
    sd_boot_num_fats : STD_LOGIC_VECTOR(7 DOWNTO 0);
    sd_boot_spf : STD_LOGIC_VECTOR(31 DOWNTO 0);
    sd_root_dir_lba : STD_LOGIC_VECTOR(31 DOWNTO 0);
    sd_browser_dir_found : STD_LOGIC;
    sd_browser_has_files : STD_LOGIC;
    sd_root_total_file_count : INTEGER RANGE 0 TO 255;
    sd_page_valid : sd_page_valid_array_t;
    sd_page_name : sd_page_name_array_t;
    sd_page_kind : sd_page_kind_array_t;
    fdd_mount_a_valid : STD_LOGIC;
    fdd_mount_a_name : STD_LOGIC_VECTOR(87 DOWNTO 0);
    fdd_mount_b_valid : STD_LOGIC;
    fdd_mount_b_name : STD_LOGIC_VECTOR(87 DOWNTO 0);
    ui_sd_page_base : INTEGER RANGE 0 TO SD_BROWSER_LAST_INDEX;
    ui_sd_page_row : INTEGER RANGE 0 TO SD_BROWSER_PAGE_LAST;
    sd_file_load_addr_valid : STD_LOGIC;
    sd_file_load_addr : STD_LOGIC_VECTOR(15 DOWNTO 0);
    browser_manage_mode : STD_LOGIC_VECTOR(2 DOWNTO 0);
    browser_manage_name : STD_LOGIC_VECTOR(63 DOWNTO 0);
    browser_manage_status : STD_LOGIC_VECTOR(3 DOWNTO 0);
    tape_led_active : STD_LOGIC;
    cfg_dirty : STD_LOGIC;
    cfg_apply_pending : STD_LOGIC;
    cfg_apply_error : STD_LOGIC;
    cfg_load_busy : STD_LOGIC;
    cfg_load_pending : STD_LOGIC;
    cfg_load_seen : STD_LOGIC;
    cfg_load_ok : STD_LOGIC;
    cfg_load_error : STD_LOGIC;
    save_name : STD_LOGIC_VECTOR(63 DOWNTO 0);
    save_row_sel : INTEGER RANGE 0 TO 4;
    save_mode_basic : STD_LOGIC;
    save_mode_bls : STD_LOGIC;
    save_start_addr_digit : INTEGER RANGE 0 TO 3;
    save_end_addr_digit : INTEGER RANGE 0 TO 3;
    save_start_addr_manual : STD_LOGIC_VECTOR(15 DOWNTO 0);
    save_end_addr_manual : STD_LOGIC_VECTOR(15 DOWNTO 0);
    save_basic_available : STD_LOGIC;
    save_basic_ready : STD_LOGIC;
    save_basic_start_addr : STD_LOGIC_VECTOR(15 DOWNTO 0);
    save_basic_end_addr : STD_LOGIC_VECTOR(15 DOWNTO 0);
    save_effective_start_addr : STD_LOGIC_VECTOR(15 DOWNTO 0);
    save_effective_end_addr : STD_LOGIC_VECTOR(15 DOWNTO 0);
    save_effective_len : STD_LOGIC_VECTOR(15 DOWNTO 0);
    save_check_busy : STD_LOGIC;
    save_checked : STD_LOGIC;
    save_name_exists : STD_LOGIC;
    save_check_can_create : STD_LOGIC;
    save_check_can_allocate : STD_LOGIC;
    save_check_requires_dir_growth : STD_LOGIC;
    save_check_dir_full : STD_LOGIC;
    save_overwrite_confirmed : STD_LOGIC;
    save_ready_to_write : STD_LOGIC;
    save_write_after_check : STD_LOGIC;
    save_write_busy : STD_LOGIC;
    save_write_done : STD_LOGIC;
    save_write_error : STD_LOGIC;
    save_write_status : STD_LOGIC_VECTOR(3 DOWNTO 0);
    sd_last_r1 : STD_LOGIC_VECTOR(7 DOWNTO 0);
    sd_state_code : STD_LOGIC_VECTOR(7 DOWNTO 0)
  ) RETURN text_line_t IS
    VARIABLE line : text_line_t := pad48("");
  BEGIN
    CASE page_sel IS
      WHEN "0000" =>
        line := HELP_PAGE_KEYBOARD(row_i);

      WHEN "0001" =>
        line := HELP_PAGE_NASSYS(row_i);

      WHEN "0010" | "0011" | "1000" =>
        line := cfg_page_line(
          page_sel,
          row_i,
          cfg_row_sel,
          cfg_speed_sel,
          cfg_phosphor_amber,
          cfg_scanlines,
          cfg_video_zoom,
          cfg_rs232_sel,
          cfg_rs232_speed_sel,
          cfg_rs232_flow,
          cfg_slot_rom_sel,
          cfg_fdd_enabled,
          cfg_cpm_enabled,
          cfg_avc_enabled,
          cfg_bls_enabled,
          cfg_dirty,
          cfg_apply_pending,
          cfg_apply_error,
          cfg_load_busy,
          cfg_load_pending,
          cfg_load_seen,
          cfg_load_ok,
          cfg_load_error,
          sd_read_lba,
          sd_read_first_word,
          sd_debug_root_current_cluster,
          sd_debug_root_next_cluster,
          sd_read_token,
          sd_debug_read_cmd17_r1,
          sd_last_r1,
          sd_debug_root_sectors_left,
          sd_debug_read_error_code
          );

      WHEN "0100" =>
        line := sd_page_line(
          row_i,
          cfg_fdd_enabled,
          sd_cd_raw,
          sd_init_busy,
          sd_init_done,
          sd_init_error,
          sd_read_busy,
          sd_read_done,
          sd_read_error,
          sd_read_stage,
          sd_read_lba,
          sd_read_token,
          sd_read_count,
          sd_read_first_word,
          sd_card_block_addressing,
          sd_debug_read_cmd17_r1,
          sd_debug_read_error_code,
          sd_debug_root_current_cluster,
          sd_debug_root_next_cluster,
          sd_debug_root_sectors_left,
          sd_debug_root_scan_phase,
          sd_debug_root_scan_job,
          sd_part_lba,
          sd_boot_spc,
          sd_boot_reserved,
          sd_boot_num_fats,
          sd_boot_spf,
          sd_root_dir_lba,
          sd_browser_dir_found,
          sd_browser_has_files,
          sd_root_total_file_count,
          sd_page_valid,
          sd_page_name,
          sd_page_kind,
          fdd_mount_a_valid,
          fdd_mount_a_name,
          fdd_mount_b_valid,
          fdd_mount_b_name,
          ui_sd_page_base,
          ui_sd_page_row,
          sd_file_load_addr_valid,
          sd_file_load_addr,
          browser_manage_mode,
          browser_manage_name,
          browser_manage_status
          );

      WHEN "0101" =>
        line := save_page_line(
          row_i,
          sd_cd_raw,
          sd_init_busy,
          sd_init_done,
          sd_init_error,
          save_name,
          save_row_sel,
          save_mode_basic,
          save_mode_bls,
          save_start_addr_digit,
          save_end_addr_digit,
          save_start_addr_manual,
          save_end_addr_manual,
          save_basic_available,
          save_basic_ready,
          save_basic_start_addr,
          save_basic_end_addr,
          save_effective_start_addr,
          save_effective_end_addr,
          save_effective_len,
          save_check_busy,
          save_checked,
          save_name_exists,
          save_check_can_create,
          save_check_can_allocate,
          save_check_requires_dir_growth,
          save_check_dir_full,
          save_overwrite_confirmed,
          save_ready_to_write,
          save_write_after_check,
          save_write_busy,
          save_write_done,
          save_write_error,
          save_write_status,
          sd_last_r1,
          sd_state_code,
          sd_read_lba
          );

      WHEN OTHERS =>
        line := pad48("");
    END CASE;

    RETURN line;
  END FUNCTION;

  FUNCTION help_char_code(
    page_sel : STD_LOGIC_VECTOR(3 DOWNTO 0);
    row_i : INTEGER;
    col_i : INTEGER;
    cfg_row_sel : STD_LOGIC_VECTOR(2 DOWNTO 0);
    cfg_speed_sel : STD_LOGIC_VECTOR(1 DOWNTO 0);
    cfg_phosphor_amber : STD_LOGIC;
    cfg_scanlines : STD_LOGIC;
    cfg_video_zoom : STD_LOGIC_VECTOR(1 DOWNTO 0);
    cfg_rs232_sel : STD_LOGIC_VECTOR(2 DOWNTO 0);
    cfg_rs232_speed_sel : STD_LOGIC_VECTOR(3 DOWNTO 0);
    cfg_rs232_flow : STD_LOGIC;
    cfg_slot_rom_sel : STD_LOGIC_VECTOR(3 DOWNTO 0);
    cfg_fdd_enabled : STD_LOGIC;
    cfg_cpm_enabled : STD_LOGIC;
    cfg_avc_enabled : STD_LOGIC;
    cfg_bls_enabled : STD_LOGIC;
    sd_cd_raw : STD_LOGIC;
    sd_init_busy : STD_LOGIC;
    sd_init_done : STD_LOGIC;
    sd_init_error : STD_LOGIC;
    sd_read_busy : STD_LOGIC;
    sd_read_done : STD_LOGIC;
    sd_read_error : STD_LOGIC;
    sd_read_stage : STD_LOGIC_VECTOR(1 DOWNTO 0);
    sd_read_lba : STD_LOGIC_VECTOR(31 DOWNTO 0);
    sd_read_token : STD_LOGIC_VECTOR(7 DOWNTO 0);
    sd_read_count : STD_LOGIC_VECTOR(15 DOWNTO 0);
    sd_read_first_word : STD_LOGIC_VECTOR(31 DOWNTO 0);
    sd_card_block_addressing : STD_LOGIC;
    sd_debug_read_cmd17_r1 : STD_LOGIC_VECTOR(7 DOWNTO 0);
    sd_debug_read_error_code : STD_LOGIC_VECTOR(3 DOWNTO 0);
    sd_debug_root_current_cluster : STD_LOGIC_VECTOR(31 DOWNTO 0);
    sd_debug_root_next_cluster : STD_LOGIC_VECTOR(31 DOWNTO 0);
    sd_debug_root_sectors_left : STD_LOGIC_VECTOR(7 DOWNTO 0);
    sd_debug_root_scan_phase : STD_LOGIC;
    sd_debug_root_scan_job : STD_LOGIC_VECTOR(1 DOWNTO 0);
    sd_part_lba : STD_LOGIC_VECTOR(31 DOWNTO 0);
    sd_boot_spc : STD_LOGIC_VECTOR(7 DOWNTO 0);
    sd_boot_reserved : STD_LOGIC_VECTOR(15 DOWNTO 0);
    sd_boot_num_fats : STD_LOGIC_VECTOR(7 DOWNTO 0);
    sd_boot_spf : STD_LOGIC_VECTOR(31 DOWNTO 0);
    sd_root_dir_lba : STD_LOGIC_VECTOR(31 DOWNTO 0);
    sd_browser_dir_found : STD_LOGIC;
    sd_browser_has_files : STD_LOGIC;
    sd_root_total_file_count : INTEGER RANGE 0 TO 255;
    sd_page_valid : sd_page_valid_array_t;
    sd_page_name : sd_page_name_array_t;
    sd_page_kind : sd_page_kind_array_t;
    fdd_mount_a_valid : STD_LOGIC;
    fdd_mount_a_name : STD_LOGIC_VECTOR(87 DOWNTO 0);
    fdd_mount_b_valid : STD_LOGIC;
    fdd_mount_b_name : STD_LOGIC_VECTOR(87 DOWNTO 0);
    ui_sd_page_base : INTEGER RANGE 0 TO SD_BROWSER_LAST_INDEX;
    ui_sd_page_row : INTEGER RANGE 0 TO SD_BROWSER_PAGE_LAST;
    sd_file_load_addr_valid : STD_LOGIC;
    sd_file_load_addr : STD_LOGIC_VECTOR(15 DOWNTO 0);
    browser_manage_mode : STD_LOGIC_VECTOR(2 DOWNTO 0);
    browser_manage_name : STD_LOGIC_VECTOR(63 DOWNTO 0);
    browser_manage_status : STD_LOGIC_VECTOR(3 DOWNTO 0);
    tape_led_active : STD_LOGIC;
    cfg_dirty : STD_LOGIC;
    cfg_apply_pending : STD_LOGIC;
    cfg_apply_error : STD_LOGIC;
    cfg_load_busy : STD_LOGIC;
    cfg_load_pending : STD_LOGIC;
    cfg_load_seen : STD_LOGIC;
    cfg_load_ok : STD_LOGIC;
    cfg_load_error : STD_LOGIC;
    save_name : STD_LOGIC_VECTOR(63 DOWNTO 0);
    save_row_sel : INTEGER RANGE 0 TO 4;
    save_mode_basic : STD_LOGIC;
    save_mode_bls : STD_LOGIC;
    save_start_addr_digit : INTEGER RANGE 0 TO 3;
    save_end_addr_digit : INTEGER RANGE 0 TO 3;
    save_start_addr_manual : STD_LOGIC_VECTOR(15 DOWNTO 0);
    save_end_addr_manual : STD_LOGIC_VECTOR(15 DOWNTO 0);
    save_basic_available : STD_LOGIC;
    save_basic_ready : STD_LOGIC;
    save_basic_start_addr : STD_LOGIC_VECTOR(15 DOWNTO 0);
    save_basic_end_addr : STD_LOGIC_VECTOR(15 DOWNTO 0);
    save_effective_start_addr : STD_LOGIC_VECTOR(15 DOWNTO 0);
    save_effective_end_addr : STD_LOGIC_VECTOR(15 DOWNTO 0);
    save_effective_len : STD_LOGIC_VECTOR(15 DOWNTO 0);
    save_check_busy : STD_LOGIC;
    save_checked : STD_LOGIC;
    save_name_exists : STD_LOGIC;
    save_check_can_create : STD_LOGIC;
    save_check_can_allocate : STD_LOGIC;
    save_check_requires_dir_growth : STD_LOGIC;
    save_check_dir_full : STD_LOGIC;
    save_overwrite_confirmed : STD_LOGIC;
    save_ready_to_write : STD_LOGIC;
    save_write_after_check : STD_LOGIC;
    save_write_busy : STD_LOGIC;
    save_write_done : STD_LOGIC;
    save_write_error : STD_LOGIC;
    save_write_status : STD_LOGIC_VECTOR(3 DOWNTO 0);
    sd_last_r1 : STD_LOGIC_VECTOR(7 DOWNTO 0);
    sd_state_code : STD_LOGIC_VECTOR(7 DOWNTO 0)
  ) RETURN INTEGER IS
    VARIABLE c : CHARACTER := ' ';
    VARIABLE line : text_line_t := pad48("");
  BEGIN
    IF row_i < 0 OR row_i > 15 OR col_i < 0 OR col_i > 47 THEN
      RETURN 16#20#;
    END IF;
    line := overlay_line_text(
      page_sel,
      row_i,
      cfg_row_sel,
      cfg_speed_sel,
      cfg_phosphor_amber,
      cfg_scanlines,
      cfg_video_zoom,
      cfg_rs232_sel,
      cfg_rs232_speed_sel,
      cfg_rs232_flow,
      cfg_slot_rom_sel,
      cfg_fdd_enabled,
      cfg_cpm_enabled,
      cfg_avc_enabled,
      cfg_bls_enabled,
      sd_cd_raw,
      sd_init_busy,
      sd_init_done,
      sd_init_error,
      sd_read_busy,
      sd_read_done,
      sd_read_error,
      sd_read_stage,
      sd_read_lba,
      sd_read_token,
      sd_read_count,
      sd_read_first_word,
      sd_card_block_addressing,
      sd_debug_read_cmd17_r1,
      sd_debug_read_error_code,
      sd_debug_root_current_cluster,
      sd_debug_root_next_cluster,
      sd_debug_root_sectors_left,
      sd_debug_root_scan_phase,
      sd_debug_root_scan_job,
      sd_part_lba,
      sd_boot_spc,
      sd_boot_reserved,
      sd_boot_num_fats,
      sd_boot_spf,
      sd_root_dir_lba,
      sd_browser_dir_found,
      sd_browser_has_files,
      sd_root_total_file_count,
      sd_page_valid,
      sd_page_name,
      sd_page_kind,
      fdd_mount_a_valid,
      fdd_mount_a_name,
      fdd_mount_b_valid,
      fdd_mount_b_name,
      ui_sd_page_base,
      ui_sd_page_row,
      sd_file_load_addr_valid,
      sd_file_load_addr,
      browser_manage_mode,
      browser_manage_name,
      browser_manage_status,
      tape_led_active,
      cfg_dirty,
      cfg_apply_pending,
      cfg_apply_error,
      cfg_load_busy,
      cfg_load_pending,
      cfg_load_seen,
      cfg_load_ok,
      cfg_load_error,
      save_name,
      save_row_sel,
      save_mode_basic,
      save_mode_bls,
      save_start_addr_digit,
      save_end_addr_digit,
      save_start_addr_manual,
      save_end_addr_manual,
      save_basic_available,
      save_basic_ready,
      save_basic_start_addr,
      save_basic_end_addr,
      save_effective_start_addr,
      save_effective_end_addr,
      save_effective_len,
      save_check_busy,
      save_checked,
      save_name_exists,
      save_check_can_create,
      save_check_can_allocate,
      save_check_requires_dir_growth,
      save_check_dir_full,
      save_overwrite_confirmed,
      save_ready_to_write,
      save_write_after_check,
      save_write_busy,
      save_write_done,
      save_write_error,
      save_write_status,
      sd_last_r1,
      sd_state_code
      );
    c := line(col_i + 1);

    RETURN CHARACTER'POS(c);
  END FUNCTION;

END PACKAGE BODY help_overlay_pkg;

