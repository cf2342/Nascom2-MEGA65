LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
LIBRARY xpm;
USE xpm.vcomponents.ALL;
USE work.sd_file_pkg.ALL;

ENTITY sd_spi_init IS
    GENERIC (
        CLK_HZ : POSITIVE := 100000000;
        SPI_HZ : POSITIVE := 400000
    );
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        sd_cd : IN STD_LOGIC;
        sd_miso : IN STD_LOGIC;
        sd_sclk : OUT STD_LOGIC;
        sd_mosi : OUT STD_LOGIC;
        sd_cs_n : OUT STD_LOGIC;
        sd_reset_n : OUT STD_LOGIC;
        cd_raw : OUT STD_LOGIC;
        init_busy : OUT STD_LOGIC;
        init_done : OUT STD_LOGIC;
        init_error : OUT STD_LOGIC;
        read_busy : OUT STD_LOGIC;
        read_done : OUT STD_LOGIC;
        read_error : OUT STD_LOGIC;
        read_stage : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        read_lba : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        read_token : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        read_count : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        read_first_word : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        read_signature : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        part_type : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        part_lba : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        boot_bps : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        boot_spc : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        boot_reserved : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        boot_num_fats : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        boot_spf : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        boot_root_cluster : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        root_dir_lba : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        root_file_count : OUT INTEGER RANGE 0 TO SD_BROWSER_MAX_FILES;
        root_total_file_count : OUT INTEGER RANGE 0 TO 255;
        browser_dir_found : OUT STD_LOGIC;
        browser_include_dsk : IN STD_LOGIC;
        browser_include_pas : IN STD_LOGIC;
        page_base_index : IN INTEGER RANGE 0 TO SD_BROWSER_LAST_INDEX;
        selected_page_row : IN INTEGER RANGE 0 TO SD_BROWSER_PAGE_LAST;
        browser_has_files : OUT STD_LOGIC;
        page_valid : OUT sd_page_valid_array_t;
        page_name : OUT sd_page_name_array_t;
        page_kind : OUT sd_page_kind_array_t;
        selected_valid : OUT STD_LOGIC;
        selected_name : OUT STD_LOGIC_VECTOR(87 DOWNTO 0);
        selected_cluster : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        selected_size : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        manage_start : IN STD_LOGIC;
        manage_delete : IN STD_LOGIC;
        manage_old_name : IN STD_LOGIC_VECTOR(87 DOWNTO 0);
        manage_new_name : IN STD_LOGIC_VECTOR(87 DOWNTO 0);
        manage_busy : OUT STD_LOGIC;
        manage_done : OUT STD_LOGIC;
        manage_error : OUT STD_LOGIC;
        manage_status : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        save_check_start : IN STD_LOGIC;
        save_name : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
        save_is_pascal : IN STD_LOGIC;
        save_check_busy : OUT STD_LOGIC;
        save_check_done : OUT STD_LOGIC;
        save_check_exists : OUT STD_LOGIC;
        save_check_can_create : OUT STD_LOGIC;
        save_check_can_allocate : OUT STD_LOGIC;
        save_check_requires_dir_growth : OUT STD_LOGIC;
        save_check_dir_full : OUT STD_LOGIC;
        save_debug_free_lba : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        save_debug_free_slot : OUT INTEGER RANGE 0 TO 15;
        save_debug_free_marker : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        save_debug_free_cluster : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        save_done_clear : IN STD_LOGIC;
        save_status_clear : IN STD_LOGIC;
        save_write_start : IN STD_LOGIC;
        save_write_start_addr : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        save_write_end_addr : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        save_write_busy : OUT STD_LOGIC;
        save_write_done : OUT STD_LOGIC;
        save_write_error : OUT STD_LOGIC;
        save_write_status : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        save_mem_addr : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        save_mem_data : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        cfg_load_start : IN STD_LOGIC;
        cfg_load_busy : OUT STD_LOGIC;
        cfg_load_done : OUT STD_LOGIC;
        cfg_load_error : OUT STD_LOGIC;
        cfg_loaded_valid : OUT STD_LOGIC;
        cfg_loaded_speed : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        cfg_loaded_phosphor_amber : OUT STD_LOGIC;
        cfg_loaded_scanlines : OUT STD_LOGIC;
        cfg_loaded_video_zoom : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        cfg_loaded_rs232 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        cfg_loaded_rs232_speed : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        cfg_loaded_rs232_flow : OUT STD_LOGIC;
        cfg_loaded_slot_rom : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        cfg_loaded_fdd : OUT STD_LOGIC;
        cfg_loaded_cpm : OUT STD_LOGIC;
        cfg_loaded_avc : OUT STD_LOGIC;
        cfg_loaded_bls : OUT STD_LOGIC;
        cfg_loaded_network : OUT STD_LOGIC;
        cfg_loaded_network_dhcp : OUT STD_LOGIC;
        cfg_loaded_network_ipv4 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        cfg_loaded_network_netmask : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        cfg_loaded_network_gateway : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        cfg_loaded_network_dns : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        cfg_save_start : IN STD_LOGIC;
        cfg_save_busy : OUT STD_LOGIC;
        cfg_save_done : OUT STD_LOGIC;
        cfg_save_error : OUT STD_LOGIC;
        cfg_save_speed : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        cfg_save_phosphor_amber : IN STD_LOGIC;
        cfg_save_scanlines : IN STD_LOGIC;
        cfg_save_video_zoom : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        cfg_save_rs232 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        cfg_save_rs232_speed : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        cfg_save_rs232_flow : IN STD_LOGIC;
        cfg_save_slot_rom : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        cfg_save_fdd : IN STD_LOGIC;
        cfg_save_cpm : IN STD_LOGIC;
        cfg_save_avc : IN STD_LOGIC;
        cfg_save_bls : IN STD_LOGIC;
        cfg_save_network : IN STD_LOGIC;
        cfg_save_network_dhcp : IN STD_LOGIC;
        cfg_save_network_ipv4 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        cfg_save_network_netmask : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        cfg_save_network_gateway : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        cfg_save_network_dns : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        fdd_read_start : IN STD_LOGIC;
        fdd_read_cluster : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        fdd_read_sd_sector : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        fdd_read_half : IN STD_LOGIC;
        fdd_read_busy : OUT STD_LOGIC;
        fdd_read_done : OUT STD_LOGIC;
        fdd_read_error : OUT STD_LOGIC;
        fdd_buffer_addr : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        fdd_buffer_data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        fdd_buffer_write_enable : IN STD_LOGIC;
        fdd_buffer_write_addr : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        fdd_buffer_write_data : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        fdd_write_start : IN STD_LOGIC;
        fdd_write_cluster : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        fdd_write_sd_sector : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        fdd_write_half : IN STD_LOGIC;
        fdd_write_busy : OUT STD_LOGIC;
        fdd_write_done : OUT STD_LOGIC;
        fdd_write_error : OUT STD_LOGIC;
        fdd_format_start : IN STD_LOGIC;
        fdd_format_name : IN STD_LOGIC_VECTOR(87 DOWNTO 0);
        fdd_format_cluster : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        fdd_format_busy : OUT STD_LOGIC;
        fdd_format_done : OUT STD_LOGIC;
        fdd_format_error : OUT STD_LOGIC;
        fdd_format_new_cluster : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        file_read_start : IN STD_LOGIC;
        file_read_cluster : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        file_read_size : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        file_read_is_cas : IN STD_LOGIC;
        file_load_addr_valid : OUT STD_LOGIC;
        file_load_addr : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        file_mem_wr : OUT STD_LOGIC;
        file_mem_addr : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        file_mem_data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        debug_read_cmd17_r1 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        debug_read_error_code : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        debug_root_current_cluster : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        debug_root_next_cluster : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        debug_root_sectors_left : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        debug_root_scan_phase : OUT STD_LOGIC;
        debug_root_scan_job : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        state_code : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        last_r1 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        card_block_addressing : OUT STD_LOGIC
    );
END sd_spi_init;

ARCHITECTURE rtl OF sd_spi_init IS

    CONSTANT HALF_DIVIDER : NATURAL := CLK_HZ / (SPI_HZ * 2);
    CONSTANT ACMD41_RETRY_MAX : NATURAL := 4095;
    CONSTANT READ_TOKEN_TIMEOUT_MAX : NATURAL := 16383;

    TYPE state_t IS (
        ST_WAIT_CARD,
        ST_DUMMY_CLOCKS,
        ST_PREP_CMD0,
        ST_PREP_CMD8,
        ST_PREP_CMD55,
        ST_PREP_ACMD41,
        ST_PREP_CMD58,
        ST_SEND_CMD,
        ST_WAIT_CMD0_R1,
        ST_WAIT_CMD8_R1,
        ST_WAIT_CMD55_R1,
        ST_WAIT_ACMD41_R1,
        ST_WAIT_CMD58_R1,
        ST_READ_CMD8_TAIL,
        ST_READ_CMD58_TAIL,
        ST_PREP_CMD17,
        ST_PREP_CMD24,
        ST_WAIT_CMD17_R1,
        ST_WAIT_CMD24_R1,
        ST_WAIT_DATA_TOKEN,
        ST_READ_DATA,
        ST_READ_CRC1,
        ST_READ_CRC2,
        ST_FINISH_ROOT_SCAN,
        ST_SAVE_BUILD_SECTOR,
        ST_WRITE_DATA_TOKEN,
        ST_WRITE_DATA,
        ST_WRITE_CRC1,
        ST_WRITE_CRC2,
        ST_WAIT_DATA_RESP,
        ST_WAIT_WRITE_BUSY,
        ST_SAVE_PREP_REQUEST,
        ST_SAVE_PREP_CALC,
        ST_SAVE_PREP_SECTORS,
        ST_SAVE_PREP_CLUSTERS,
        ST_SAVE_PREP_DECIDE,
        ST_SAVE_PREP_ALLOC_SETUP,
        ST_SAVE_PREP_CREATE_SETUP,
        ST_SAVE_PREP_COMMIT,
        ST_SAVE_PATCH_SECTOR,
        ST_FDD_PATCH_SECTOR,
        ST_CALC_LBA_BASE,
        ST_CALC_LBA_OFFSET,
        ST_CALC_LBA_APPLY,
        ST_GAP,
        ST_READ_READY,
        ST_READY,
        ST_CARD_SETTLE,
        ST_ERROR,
        ST_CAS_COMMIT
    );

    TYPE cmd_packet_t IS ARRAY (0 TO 5) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    TYPE read_job_t IS (JOB_MBR, JOB_BOOT, JOB_ROOT, JOB_ROOT_FAT, JOB_FAT, JOB_FILE, JOB_FDD, JOB_FDD_WRITE, JOB_PATCH, JOB_MANAGE_FAT, JOB_CFG, JOB_DSK_PROBE);
    TYPE lba_target_t IS (LBA_TARGET_ROOT, LBA_TARGET_FILE);
    TYPE root_scan_phase_t IS (ROOT_SCAN_FIND_DIR, ROOT_SCAN_LIST_FILES);
    TYPE root_scan_job_t IS (ROOT_SCAN_DISCOVER, ROOT_SCAN_PAGE_RELOAD, ROOT_SCAN_SAVE_CHECK, ROOT_SCAN_MANAGE);
    TYPE sd_page_cluster_array_t IS ARRAY (0 TO SD_BROWSER_PAGE_LAST) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
    TYPE sd_page_size_array_t IS ARRAY (0 TO SD_BROWSER_PAGE_LAST) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
    TYPE cas_parse_state_t IS (
        CAS_SYNC_00,
        CAS_SYNC_FF1,
        CAS_SYNC_FF2,
        CAS_SYNC_FF3,
        CAS_SYNC_FF4,
        CAS_ADDR_LO,
        CAS_ADDR_HI,
        CAS_LEN,
        CAS_BLOCK,
        CAS_HDR_CSUM,
        CAS_DATA,
        CAS_DATA_CSUM
    );
    TYPE save_fmt_state_t IS (
        SAVE_FMT_IDLE,
        SAVE_FMT_LINE_ADDR3,
        SAVE_FMT_LINE_ADDR2,
        SAVE_FMT_LINE_ADDR1,
        SAVE_FMT_LINE_ADDR0,
        SAVE_FMT_BYTE_SPACE,
        SAVE_FMT_BYTE_HI,
        SAVE_FMT_BYTE_LO,
        SAVE_FMT_LINE_CR,
        SAVE_FMT_LINE_LF,
        SAVE_FMT_PAD,
        SAVE_FMT_DONE
    );
    TYPE save_sector_source_t IS (SAVE_SECTOR_NAS, SAVE_SECTOR_PATCH, SAVE_SECTOR_CFG);
    TYPE save_create_phase_t IS (
        SAVE_CREATE_IDLE,
        SAVE_CREATE_LOAD_FAT,
        SAVE_CREATE_WRITE_FAT,
        SAVE_CREATE_LOAD_DIR,
        SAVE_CREATE_WRITE_DIR,
        SAVE_CREATE_LOAD_DIR_NEXT,
        SAVE_CREATE_WRITE_DIR_NEXT,
        SAVE_CREATE_PATCH_EXISTING_DIR,
        SAVE_CREATE_RENAME_DSK,
        SAVE_CREATE_WRITE_RENAME,
        SAVE_MANAGE_RENAME_DIR,
        SAVE_MANAGE_WRITE_RENAME,
        SAVE_MANAGE_DELETE_DIR,
        SAVE_MANAGE_WRITE_DELETE_DIR,
        SAVE_MANAGE_DELETE_FAT,
        SAVE_MANAGE_WRITE_DELETE_FAT
    );
    TYPE fdd_format_phase_t IS (
        FDD_FORMAT_IDLE,
        FDD_FORMAT_CHECK_BAK,
        FDD_FORMAT_FIND_DSK,
        FDD_FORMAT_RENAME,
        FDD_FORMAT_FIND_FREE,
        FDD_FORMAT_CREATE
    );
    TYPE cfg_request_t IS (CFG_REQ_NONE, CFG_REQ_LOAD, CFG_REQ_SAVE);
    CONSTANT SAVE_STATUS_NONE : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
    CONSTANT SAVE_STATUS_NEEDS_CREATE : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0001";
    CONSTANT SAVE_STATUS_TOO_LARGE : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0010";
    CONSTANT SAVE_STATUS_DIR_MISSING : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0011";
    CONSTANT SAVE_STATUS_IO_ERROR : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0100";
    CONSTANT SAVE_STATUS_DONE : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0101";
    CONSTANT SAVE_STATUS_CREATE_MULTICLUSTER : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0111";
    CONSTANT SAVE_STATUS_CREATE_DIR_GROWTH : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1000";
    CONSTANT SAVE_STATUS_ERR_CMD24_R1 : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1001";
    CONSTANT SAVE_STATUS_ERR_CMD24_TIMEOUT : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1010";
    CONSTANT SAVE_STATUS_ERR_DATA_RESP : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1011";
    CONSTANT SAVE_STATUS_ERR_BUSY_TIMEOUT : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1100";
    CONSTANT SAVE_STATUS_ERR_CREATE_PHASE : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1101";
    CONSTANT SAVE_STATUS_ERR_VERIFY : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1110";
    CONSTANT SAVE_STATUS_ERR_FAT_SCAN : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1111";
    -- Reuse the persistent save-status/debug channel for failures in the
    -- copy-on-format transaction before the normal file writer takes over.
    CONSTANT FDD_FORMAT_STATUS_BAK_EXISTS : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0001";
    CONSTANT FDD_FORMAT_STATUS_NO_DIR_SLOT : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0010";
    CONSTANT FDD_FORMAT_STATUS_DIR_GROWTH : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0011";
    CONSTANT FDD_FORMAT_STATUS_DSK_MISSING : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0100";
    CONSTANT FDD_FORMAT_STATUS_CLUSTER_MISMATCH : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0101";
    CONSTANT FDD_FORMAT_STATUS_SIZE_MISMATCH : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0110";
    CONSTANT MANAGE_STATUS_NONE : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
    CONSTANT MANAGE_STATUS_NOT_FOUND : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0001";
    CONSTANT MANAGE_STATUS_NAME_EXISTS : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0010";
    CONSTANT MANAGE_STATUS_LFN : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0011";
    CONSTANT MANAGE_STATUS_READ_ONLY : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0100";
    CONSTANT MANAGE_STATUS_IO_ERROR : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0101";
    CONSTANT MANAGE_STATUS_BAD_CHAIN : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0110";
    CONSTANT CONFIG_SHORT_NAME : STD_LOGIC_VECTOR(87 DOWNTO 0) := x"4E32434F4E462020434647";
    CONSTANT CONFIG_STREAM_LEN_OLD : UNSIGNED(31 DOWNTO 0) := to_unsigned(8, 32);
    CONSTANT CONFIG_STREAM_LEN_RS232 : UNSIGNED(31 DOWNTO 0) := to_unsigned(9, 32);
    CONSTANT CONFIG_STREAM_LEN_V3 : UNSIGNED(31 DOWNTO 0) := to_unsigned(16, 32);
    CONSTANT CONFIG_STREAM_LEN : UNSIGNED(31 DOWNTO 0) := to_unsigned(32, 32);
    CONSTANT CONFIG_VERSION_V2 : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"02";
    CONSTANT CONFIG_VERSION_V3 : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"03";
    CONSTANT CONFIG_VERSION_V4 : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"04";

    FUNCTION xor_network_payload(payload_i : STD_LOGIC_VECTOR(135 DOWNTO 0))
        RETURN STD_LOGIC_VECTOR IS
        VARIABLE result_v : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    BEGIN
        FOR i IN 0 TO 16 LOOP
            result_v := result_v XOR payload_i(135 - i * 8 DOWNTO 128 - i * 8);
        END LOOP;
        RETURN result_v;
    END FUNCTION;

    --------------------------------------------------------------------
    -- SPI-Byteengine und globaler FSM-Zustand
    --------------------------------------------------------------------
    SIGNAL state : state_t := ST_WAIT_CARD;
    SIGNAL send_after_state : state_t := ST_WAIT_CARD;
    SIGNAL gap_after_state : state_t := ST_WAIT_CARD;

    SIGNAL div_count : NATURAL RANGE 0 TO HALF_DIVIDER := 0;
    SIGNAL spi_tick_reg : STD_LOGIC := '0';
    SIGNAL byte_busy : STD_LOGIC := '0';
    SIGNAL sclk_reg : STD_LOGIC := '0';
    SIGNAL mosi_reg : STD_LOGIC := '1';
    SIGNAL cs_n_reg : STD_LOGIC := '1';
    SIGNAL tx_shift : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"FF";
    SIGNAL rx_shift : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"FF";
    SIGNAL bit_idx : INTEGER RANGE 0 TO 7 := 7;

    --------------------------------------------------------------------
    -- SD-Init-, Kommando- und laufende Sektorlese-Buchhaltung
    --------------------------------------------------------------------
    SIGNAL cmd_packet : cmd_packet_t := (OTHERS => x"FF");
    SIGNAL cmd_index : INTEGER RANGE 0 TO 5 := 0;
    CONSTANT RESPONSE_TIMEOUT_MAX : NATURAL := 255;
    CONSTANT CARD_SETTLE_CYCLES : NATURAL := CLK_HZ / 4; -- 250 ms
    SIGNAL response_timeout : INTEGER RANGE 0 TO RESPONSE_TIMEOUT_MAX := 0;
    SIGNAL fdd_format_read_retry_reg : INTEGER RANGE 0 TO 3 := 0;
    SIGNAL card_settle_count : NATURAL RANGE 0 TO CARD_SETTLE_CYCLES := 0;
    SIGNAL tail_bytes_left : INTEGER RANGE 0 TO 4 := 0;
    SIGNAL dummy_bytes_left : INTEGER RANGE 0 TO 20 := 0;
    SIGNAL cmd0_retries : INTEGER RANGE 0 TO 15 := 0;
    SIGNAL acmd41_retries : INTEGER RANGE 0 TO ACMD41_RETRY_MAX := 0;
    SIGNAL read_token_timeout : INTEGER RANGE 0 TO READ_TOKEN_TIMEOUT_MAX := 0;
    SIGNAL data_bytes_left : INTEGER RANGE 0 TO 512 := 0;
    SIGNAL data_index : INTEGER RANGE 0 TO 511 := 0;
    SIGNAL last_r1_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"FF";
    SIGNAL init_complete_reg : STD_LOGIC := '0';
    SIGNAL card_block_addressing_reg : STD_LOGIC := '0';
    SIGNAL current_lba_reg : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL read_job_reg : read_job_t := JOB_MBR;
    SIGNAL read_done_reg : STD_LOGIC := '0';
    SIGNAL read_error_reg : STD_LOGIC := '0';
    SIGNAL read_token_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"FF";
    SIGNAL read_byte_count_reg : UNSIGNED(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL read_cmd17_r1_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"FF";
    SIGNAL read_error_code_reg : STD_LOGIC_VECTOR(3 DOWNTO 0) := x"0";
    SIGNAL read_first_word_reg : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"00000000";
    SIGNAL read_signature_reg : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0000";
    SIGNAL part_type_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL part_lba_reg : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL boot_bps_reg : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0000";
    SIGNAL boot_spc_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL boot_reserved_reg : UNSIGNED(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL boot_num_fats_reg : UNSIGNED(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL boot_spf_reg : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL boot_root_cluster_reg : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"00000000";
    SIGNAL root_dir_lba_reg : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL root_current_cluster_reg : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL root_next_cluster_reg : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL root_fat_byte_offset_reg : INTEGER RANGE 0 TO 508 := 0;
    SIGNAL root_chain_advance_reg : STD_LOGIC := '0';
    SIGNAL root_sectors_left_reg : INTEGER RANGE 0 TO 255 := 0;
    SIGNAL root_end_seen_reg : STD_LOGIC := '0';
    SIGNAL browser_dir_found_reg : STD_LOGIC := '0';
    SIGNAL browser_dir_cluster_reg : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL root_scan_phase_reg : root_scan_phase_t := ROOT_SCAN_FIND_DIR;
    SIGNAL root_scan_job_reg : root_scan_job_t := ROOT_SCAN_DISCOVER;
    SIGNAL dir_entry_name_tmp_reg : STD_LOGIC_VECTOR(87 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dir_entry_attr_tmp_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL dir_entry_cluster_tmp_reg : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dir_entry_size_tmp_reg : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL root_file_count_reg : INTEGER RANGE 0 TO SD_BROWSER_MAX_FILES := 0;
    SIGNAL root_total_file_count_reg : INTEGER RANGE 0 TO 255 := 0;
    SIGNAL file_name_reg : sd_name_array_t := (OTHERS => (OTHERS => '0'));
    SIGNAL file_cluster_reg : sd_cluster_array_t := (OTHERS => (OTHERS => '0'));
    SIGNAL file_size_reg : sd_size_array_t := (OTHERS => (OTHERS => '0'));
    SIGNAL file_kind_reg : sd_kind_array_t := (OTHERS => SD_DSK_KIND_UNKNOWN);
    ATTRIBUTE ram_style : STRING;
    ATTRIBUTE ram_style OF file_name_reg : SIGNAL IS "block";
    ATTRIBUTE ram_style OF file_cluster_reg : SIGNAL IS "block";
    ATTRIBUTE ram_style OF file_size_reg : SIGNAL IS "block";
    SIGNAL browser_cache_valid_reg : STD_LOGIC := '0';
    SIGNAL browser_include_pas_reg : STD_LOGIC := '0';
    SIGNAL cached_free_valid_reg : STD_LOGIC := '0';
    SIGNAL cached_free_lba_reg : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL cached_free_slot_reg : INTEGER RANGE 0 TO 15 := 0;
    SIGNAL cached_free_marker_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL cached_free_sector_first_byte_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL cached_free_requires_dir_growth_reg : STD_LOGIC := '0';
    SIGNAL browser_has_files_reg : STD_LOGIC := '0';
    SIGNAL browser_page_reload_reg : STD_LOGIC := '0';
    SIGNAL browser_page_dirty_reg : STD_LOGIC := '0';
    SIGNAL browser_rescan_pending_reg : STD_LOGIC := '0';
    SIGNAL reload_match_index_reg : INTEGER RANGE 0 TO SD_BROWSER_MAX_FILES := 0;
    SIGNAL page_valid_reg : sd_page_valid_array_t := (OTHERS => '0');
    SIGNAL page_name_reg : sd_page_name_array_t := (OTHERS => (OTHERS => '0'));
    SIGNAL page_cluster_reg : sd_page_cluster_array_t := (OTHERS => (OTHERS => '0'));
    SIGNAL page_size_reg : sd_page_size_array_t := (OTHERS => (OTHERS => '0'));
    SIGNAL page_kind_reg : sd_page_kind_array_t := (OTHERS => SD_DSK_KIND_UNKNOWN);
    SIGNAL dsk_probe_active_reg : STD_LOGIC := '0';
    SIGNAL dsk_probe_index_reg : INTEGER RANGE 0 TO SD_BROWSER_MAX_FILES := 0;
    SIGNAL browser_page_fill_active_reg : STD_LOGIC := '0';
    SIGNAL browser_page_fill_index_reg : INTEGER RANGE 0 TO SD_BROWSER_PAGE_SIZE := 0;
    SIGNAL browser_page_fill_base_reg : INTEGER RANGE 0 TO SD_BROWSER_LAST_INDEX := 0;
    SIGNAL page_loaded_base_reg : INTEGER RANGE 0 TO SD_BROWSER_LAST_INDEX := 0;
    SIGNAL selected_valid_reg : STD_LOGIC := '0';
    SIGNAL selected_name_reg : STD_LOGIC_VECTOR(87 DOWNTO 0) := (OTHERS => '0');
    SIGNAL selected_cluster_reg : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL selected_size_reg : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');

    --------------------------------------------------------------------
    -- Browser file management: in-place 8.3 rename and FAT32 delete
    --------------------------------------------------------------------
    SIGNAL manage_busy_reg : STD_LOGIC := '0';
    SIGNAL manage_done_reg : STD_LOGIC := '0';
    SIGNAL manage_error_reg : STD_LOGIC := '0';
    SIGNAL manage_status_reg : STD_LOGIC_VECTOR(3 DOWNTO 0) := MANAGE_STATUS_NONE;
    SIGNAL manage_delete_reg : STD_LOGIC := '0';
    SIGNAL manage_old_name_reg : STD_LOGIC_VECTOR(87 DOWNTO 0) := (OTHERS => '0');
    SIGNAL manage_new_name_reg : STD_LOGIC_VECTOR(87 DOWNTO 0) := (OTHERS => '0');
    SIGNAL manage_found_reg : STD_LOGIC := '0';
    SIGNAL manage_duplicate_reg : STD_LOGIC := '0';
    SIGNAL manage_lfn_reg : STD_LOGIC := '0';
    SIGNAL manage_read_only_reg : STD_LOGIC := '0';
    SIGNAL manage_prev_lfn_reg : STD_LOGIC := '0';
    SIGNAL manage_match_lba_reg : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL manage_match_slot_reg : INTEGER RANGE 0 TO 15 := 0;
    SIGNAL manage_match_first_byte_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL manage_cluster_reg : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL manage_next_cluster_reg : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL manage_fat_offset_reg : INTEGER RANGE 0 TO 508 := 0;
    SIGNAL manage_chain_guard_reg : UNSIGNED(15 DOWNTO 0) := (OTHERS => '0');

    --------------------------------------------------------------------
    -- F9-Checks fuer vorhandene Datei, freien Directory-Slot und Cluster
    --------------------------------------------------------------------
    SIGNAL save_check_name_reg : STD_LOGIC_VECTOR(87 DOWNTO 0) := x"20202020202020204E4153";
    SIGNAL save_cache_lookup_active_reg : STD_LOGIC := '0';
    SIGNAL save_cache_lookup_index_reg : INTEGER RANGE 0 TO SD_BROWSER_MAX_FILES := 0;
    SIGNAL save_check_busy_reg : STD_LOGIC := '0';
    SIGNAL save_check_done_reg : STD_LOGIC := '0';
    SIGNAL save_check_exists_reg : STD_LOGIC := '0';
    SIGNAL save_check_can_create_reg : STD_LOGIC := '0';
    SIGNAL save_check_can_allocate_reg : STD_LOGIC := '0';
    SIGNAL save_check_requires_dir_growth_reg : STD_LOGIC := '0';
    SIGNAL save_check_dir_full_reg : STD_LOGIC := '0';
    SIGNAL save_check_cluster_reg : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL save_check_size_reg : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL save_check_free_lba_reg : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL save_check_free_slot_reg : INTEGER RANGE 0 TO 15 := 0;
    SIGNAL save_check_free_marker_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL save_check_free_cluster_reg : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL save_check_free_sector_first_byte_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL save_check_match_lba_reg : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL save_check_match_slot_reg : INTEGER RANGE 0 TO 15 := 0;
    SIGNAL save_check_match_sector_first_byte_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL fat_scan_sectors_left_reg : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL fat_scan_cluster_reg : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL fat_scan_min_cluster_reg : UNSIGNED(31 DOWNTO 0) := to_unsigned(2, 32);
    SIGNAL fat_scan_wrap_reg : STD_LOGIC := '0';
    SIGNAL save_cluster_hint_reg : UNSIGNED(31 DOWNTO 0) := to_unsigned(2, 32);
    SIGNAL save_clusters_needed_reg : UNSIGNED(15 DOWNTO 0) := to_unsigned(1, 16);
    SIGNAL save_alloc_search_need_reg : UNSIGNED(15 DOWNTO 0) := to_unsigned(1, 16);
    SIGNAL fat_scan_run_start_reg : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL fat_scan_run_len_reg : UNSIGNED(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL fat_entry_tmp_reg : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL save_verify_pending_reg : STD_LOGIC := '0';
    SIGNAL save_verify_expected_cluster_reg : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL save_verify_expected_size_reg : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL root_sector_first_byte_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL cfg_request_reg : cfg_request_t := CFG_REQ_NONE;
    SIGNAL cfg_load_busy_reg : STD_LOGIC := '0';
    SIGNAL cfg_load_done_reg : STD_LOGIC := '0';
    SIGNAL cfg_load_error_reg : STD_LOGIC := '0';
    SIGNAL cfg_loaded_valid_reg : STD_LOGIC := '0';
    SIGNAL cfg_loaded_speed_reg : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL cfg_loaded_phosphor_amber_reg : STD_LOGIC := '0';
    SIGNAL cfg_loaded_scanlines_reg : STD_LOGIC := '0';
    SIGNAL cfg_loaded_video_zoom_reg : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL cfg_loaded_rs232_reg : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
    SIGNAL cfg_loaded_rs232_speed_reg : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1001";
    SIGNAL cfg_loaded_rs232_flow_reg : STD_LOGIC := '0';
    SIGNAL cfg_loaded_slot_rom_reg : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1111";
    SIGNAL cfg_loaded_fdd_reg : STD_LOGIC := '0';
    SIGNAL cfg_loaded_cpm_reg : STD_LOGIC := '0';
    SIGNAL cfg_loaded_avc_reg : STD_LOGIC := '0';
    SIGNAL cfg_loaded_bls_reg : STD_LOGIC := '0';
    SIGNAL cfg_loaded_network_reg : STD_LOGIC := '0';
    SIGNAL cfg_loaded_network_dhcp_reg : STD_LOGIC := '0';
    SIGNAL cfg_loaded_network_ipv4_reg : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"C0A80141";
    SIGNAL cfg_loaded_network_netmask_reg : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"FFFFFF00";
    SIGNAL cfg_loaded_network_gateway_reg : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"C0A80101";
    SIGNAL cfg_loaded_network_dns_reg : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"C0A80101";
    SIGNAL cfg_save_busy_reg : STD_LOGIC := '0';
    SIGNAL cfg_save_done_reg : STD_LOGIC := '0';
    SIGNAL cfg_save_error_reg : STD_LOGIC := '0';
    -- A missing N2CONF.CFG is confirmed by two complete directory scans
    -- before a new entry is allocated.  This prevents a transient lookup
    -- immediately after reset from creating a duplicate.
    SIGNAL cfg_save_recheck_reg : STD_LOGIC := '0';
    SIGNAL cfg_byte4_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL cfg_byte5_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"0F";
    SIGNAL cfg_byte6_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00"; -- rs232 select + flow
    SIGNAL cfg_byte7_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"AA"; -- checksum
    SIGNAL cfg_byte8_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"09"; -- baud selection payload
    SIGNAL cfg_parse_byte4_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL cfg_parse_byte5_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL cfg_parse_byte6_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00"; -- payload / legacy checksum
    SIGNAL cfg_parse_byte7_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00"; -- payload / legacy slot
    SIGNAL cfg_parse_byte8_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00"; -- payload / legacy rs232
    SIGNAL cfg_parse_byte9_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00"; -- baud selection payload
    SIGNAL cfg_parse_byte14_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL cfg_network_payload_reg : STD_LOGIC_VECTOR(135 DOWNTO 0) :=
        x"00" & x"C0A80141" & x"FFFFFF00" & x"C0A80101" & x"C0A80101";
    SIGNAL cfg_parse_network_payload_reg : STD_LOGIC_VECTOR(135 DOWNTO 0) := (OTHERS => '0');
    SIGNAL cfg_parse_byte30_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL save_backend_is_cfg_reg : STD_LOGIC := '0';

    --------------------------------------------------------------------
    -- Save-Formatter, Sektorstream und Create-/Patch-Status
    --------------------------------------------------------------------
    SIGNAL save_write_busy_reg : STD_LOGIC := '0';
    SIGNAL save_write_done_reg : STD_LOGIC := '0';
    SIGNAL save_write_error_reg : STD_LOGIC := '0';
    SIGNAL save_write_status_reg : STD_LOGIC_VECTOR(3 DOWNTO 0) := SAVE_STATUS_NONE;
    SIGNAL save_req_start_addr_reg : UNSIGNED(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL save_req_end_addr_reg : UNSIGNED(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL save_byte_count_reg : UNSIGNED(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL save_stream_len_reg : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL save_sector_total_reg : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL save_mem_addr_reg : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0000";
    -- This address fans out into all program ROM/RAM banks in Nascom2.
    -- Keep each physical copy local so the registered save readback path
    -- remains comfortably inside the 100 MHz period.
    ATTRIBUTE max_fanout : INTEGER;
    ATTRIBUTE max_fanout OF save_mem_addr_reg : SIGNAL IS 32;
    SIGNAL save_lba_pending_reg : STD_LOGIC := '0';
    SIGNAL save_cmd24_pending_reg : STD_LOGIC := '0';
    SIGNAL save_sectors_left_reg : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL save_pad_bytes_left_reg : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL save_prog_bytes_left_reg : UNSIGNED(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL save_line_addr_reg : UNSIGNED(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL save_current_mem_addr_reg : UNSIGNED(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL save_line_data_left_reg : INTEGER RANGE 0 TO 8 := 0;
    SIGNAL save_mem_byte_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL save_fmt_state_reg : save_fmt_state_t := SAVE_FMT_IDLE;
    SIGNAL save_sector_tx_index_reg : INTEGER RANGE 0 TO 511 := 0;
    SIGNAL save_tx_byte_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"20";
    SIGNAL write_busy_timeout_reg : INTEGER RANGE 0 TO 65535 := 0;
    SIGNAL save_sector_source_reg : save_sector_source_t := SAVE_SECTOR_NAS;
    SIGNAL save_create_phase_reg : save_create_phase_t := SAVE_CREATE_IDLE;
    SIGNAL save_create_extend_dir_reg : STD_LOGIC := '0';
    SIGNAL save_fat_byte_offset_reg : INTEGER RANGE 0 TO 508 := 0;
    SIGNAL save_fat_copy_index_reg : INTEGER RANGE 0 TO 15 := 0;
    SIGNAL save_create_current_cluster_reg : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL save_create_clusters_left_reg : UNSIGNED(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL save_patch_step_reg : INTEGER RANGE 0 TO 32 := 0;
    SIGNAL save_patch_wr_en_reg : STD_LOGIC := '0';
    SIGNAL save_patch_wr_addr_reg : STD_LOGIC_VECTOR(8 DOWNTO 0) := (OTHERS => '0');
    SIGNAL save_patch_wr_data_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL save_patch_rd_addr_reg : STD_LOGIC_VECTOR(8 DOWNTO 0) := (OTHERS => '0');
    SIGNAL save_patch_rd_data_reg : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL save_patch_first_byte_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL save_verify_dir_lba_reg : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL save_verify_dir_first_byte_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL save_verify_dir_byte_ok_reg : STD_LOGIC := '1';

    --------------------------------------------------------------------
    -- Dateiimport (.NAS/.CAS) und Adress-/Parserzustand
    --------------------------------------------------------------------
    SIGNAL file_read_is_cas_reg : STD_LOGIC := '0';
    SIGNAL file_load_addr_valid_reg : STD_LOGIC := '0';
    SIGNAL file_load_addr_reg : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0000";
    SIGNAL file_mem_wr_reg : STD_LOGIC := '0';
    SIGNAL file_mem_addr_reg : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0000";
    SIGNAL file_mem_data_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL file_bytes_left_reg : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');
    TYPE fdd_sector_buffer_t IS ARRAY (0 TO 255) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL fdd_sector_buffer_reg : fdd_sector_buffer_t := (OTHERS => x"FF");
    SIGNAL fdd_sector_offset_reg : UNSIGNED(10 DOWNTO 0) := (OTHERS => '0');
    SIGNAL fdd_chain_active_reg : STD_LOGIC := '0';
    SIGNAL fdd_chain_write_reg : STD_LOGIC := '0';
    SIGNAL fdd_chain_remaining_reg : UNSIGNED(10 DOWNTO 0) := (OTHERS => '0');
    SIGNAL fdd_chain_sector_base_reg : UNSIGNED(10 DOWNTO 0) := (OTHERS => '0');
    SIGNAL fdd_chain_file_cluster_reg : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL fdd_read_cache_valid_reg : STD_LOGIC := '0';
    SIGNAL fdd_read_cache_file_cluster_reg : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL fdd_read_cache_cluster_reg : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL fdd_read_cache_sector_base_reg : UNSIGNED(10 DOWNTO 0) := (OTHERS => '0');
    SIGNAL fdd_write_cache_valid_reg : STD_LOGIC := '0';
    SIGNAL fdd_write_cache_file_cluster_reg : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL fdd_write_cache_cluster_reg : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL fdd_write_cache_sector_base_reg : UNSIGNED(10 DOWNTO 0) := (OTHERS => '0');
    SIGNAL fdd_read_half_reg : STD_LOGIC := '0';
    SIGNAL fdd_read_busy_reg : STD_LOGIC := '0';
    SIGNAL fdd_read_done_reg : STD_LOGIC := '0';
    SIGNAL fdd_read_error_reg : STD_LOGIC := '0';
    SIGNAL fdd_write_half_reg : STD_LOGIC := '0';
    SIGNAL fdd_write_busy_reg : STD_LOGIC := '0';
    SIGNAL fdd_write_done_reg : STD_LOGIC := '0';
    SIGNAL fdd_write_error_reg : STD_LOGIC := '0';
    SIGNAL fdd_write_patch_index_reg : INTEGER RANGE 0 TO 256 := 0;
    SIGNAL fdd_write_pending_reg : STD_LOGIC := '0';
    SIGNAL fdd_write_pending_cluster_reg : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL fdd_write_pending_sector_reg : UNSIGNED(10 DOWNTO 0) := (OTHERS => '0');
    SIGNAL fdd_write_pending_half_reg : STD_LOGIC := '0';
    SIGNAL fdd_write_complete_pending_reg : STD_LOGIC := '0';
    SIGNAL save_backend_is_fdd_reg : STD_LOGIC := '0';
    SIGNAL fdd_format_phase_reg : fdd_format_phase_t := FDD_FORMAT_IDLE;
    SIGNAL fdd_format_busy_reg : STD_LOGIC := '0';
    SIGNAL fdd_format_done_reg : STD_LOGIC := '0';
    SIGNAL fdd_format_error_reg : STD_LOGIC := '0';
    SIGNAL fdd_format_name_reg : STD_LOGIC_VECTOR(87 DOWNTO 0) := (OTHERS => '0');
    SIGNAL fdd_format_bak_name_reg : STD_LOGIC_VECTOR(87 DOWNTO 0) := (OTHERS => '0');
    SIGNAL fdd_format_old_cluster_reg : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL fdd_format_new_cluster_reg : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL file_cas_error_reg : STD_LOGIC := '0';
    SIGNAL cas_block_buffer : fdd_sector_buffer_t;
    SIGNAL cas_buffer_index : INTEGER RANGE 0 TO 255 := 0;
    SIGNAL cas_resume_state : state_t := ST_READ_DATA;
    SIGNAL cas_parse_state_reg : cas_parse_state_t := CAS_SYNC_00;
    SIGNAL cas_block_addr_reg : UNSIGNED(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL cas_block_len_reg : UNSIGNED(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL cas_header_sum_reg : UNSIGNED(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL cas_data_sum_reg : UNSIGNED(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL cas_data_left_reg : INTEGER RANGE 0 TO 256 := 0;
    SIGNAL cas_data_addr_reg : UNSIGNED(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL nas_addr_reg : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0000";
    SIGNAL nas_addr_digits_reg : INTEGER RANGE 0 TO 4 := 0;
    SIGNAL nas_token_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"00";
    SIGNAL nas_token_digits_reg : INTEGER RANGE 0 TO 2 := 0;
    SIGNAL nas_data_index_reg : INTEGER RANGE 0 TO 8 := 0;
    SIGNAL nas_in_line_reg : STD_LOGIC := '0';
    SIGNAL nas_ignore_line_reg : STD_LOGIC := '0';
    SIGNAL lba_target_reg : lba_target_t := LBA_TARGET_ROOT;
    SIGNAL lba_cluster_reg : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL lba_data_start_reg : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL lba_cluster_offset_reg : UNSIGNED(31 DOWNTO 0) := (OTHERS => '0');

    FUNCTION is_ascii_hex(byte_v : STD_LOGIC_VECTOR(7 DOWNTO 0)) RETURN BOOLEAN IS
        VARIABLE byte_u : UNSIGNED(7 DOWNTO 0);
    BEGIN
        byte_u := UNSIGNED(byte_v);
        RETURN ((byte_u >= to_unsigned(16#30#, 8) AND byte_u <= to_unsigned(16#39#, 8)) OR
        (byte_u >= to_unsigned(16#41#, 8) AND byte_u <= to_unsigned(16#46#, 8)) OR
        (byte_u >= to_unsigned(16#61#, 8) AND byte_u <= to_unsigned(16#66#, 8)));
    END FUNCTION;

    FUNCTION ascii_hex_nibble(byte_v : STD_LOGIC_VECTOR(7 DOWNTO 0)) RETURN STD_LOGIC_VECTOR IS
        VARIABLE byte_u : UNSIGNED(7 DOWNTO 0);
        VARIABLE nibble_v : UNSIGNED(3 DOWNTO 0);
    BEGIN
        byte_u := UNSIGNED(byte_v);
        IF byte_u >= to_unsigned(16#30#, 8) AND byte_u <= to_unsigned(16#39#, 8) THEN
            nibble_v := unsigned(byte_v(3 DOWNTO 0));
        ELSIF byte_u >= to_unsigned(16#41#, 8) AND byte_u <= to_unsigned(16#46#, 8) THEN
            nibble_v := to_unsigned(10 + to_integer(unsigned(byte_v(3 DOWNTO 0))) - 1, 4);
        ELSE
            nibble_v := to_unsigned(10 + to_integer(unsigned(byte_v(3 DOWNTO 0))) - 1, 4);
        END IF;
        RETURN STD_LOGIC_VECTOR(nibble_v);
    END FUNCTION;

    FUNCTION build_save_short_name(
        name_v : STD_LOGIC_VECTOR(63 DOWNTO 0);
        is_pascal_v : STD_LOGIC
    ) RETURN STD_LOGIC_VECTOR IS
        VARIABLE short_name_v : STD_LOGIC_VECTOR(87 DOWNTO 0) := (OTHERS => '0');
    BEGIN
        short_name_v(87 DOWNTO 24) := name_v;
        IF is_pascal_v = '1' THEN
            short_name_v(23 DOWNTO 0) := x"504153";
        ELSE
            short_name_v(23 DOWNTO 0) := x"4E4153";
        END IF;
        RETURN short_name_v;
    END FUNCTION;

    FUNCTION hex_nibble_to_ascii(nibble_v : STD_LOGIC_VECTOR(3 DOWNTO 0)) RETURN STD_LOGIC_VECTOR IS
        VARIABLE nibble_u : UNSIGNED(3 DOWNTO 0);
    BEGIN
        nibble_u := UNSIGNED(nibble_v);
        IF nibble_u < 10 THEN
            RETURN STD_LOGIC_VECTOR(to_unsigned(16#30#, 8) + resize(nibble_u, 8));
        ELSE
            RETURN STD_LOGIC_VECTOR(to_unsigned(16#41#, 8) + resize(nibble_u - 10, 8));
        END IF;
    END FUNCTION;

    FUNCTION calc_nas_stream_len(byte_count_v : UNSIGNED(15 DOWNTO 0)) RETURN UNSIGNED IS
        VARIABLE byte_count_u : UNSIGNED(31 DOWNTO 0);
        VARIABLE full_lines_u : UNSIGNED(31 DOWNTO 0);
        VARIABLE total_len_u : UNSIGNED(31 DOWNTO 0);
    BEGIN
        IF byte_count_v = to_unsigned(0, 16) THEN
            RETURN to_unsigned(0, 32);
        END IF;

        byte_count_u := resize(byte_count_v, 32);
        full_lines_u := shift_right(byte_count_u, 3);
        total_len_u :=
            shift_left(full_lines_u, 4) +
            shift_left(full_lines_u, 3) +
            shift_left(full_lines_u, 2) +
            shift_left(full_lines_u, 1);

        CASE byte_count_v(2 DOWNTO 0) IS
            WHEN "000" =>
                NULL;
            WHEN "001" =>
                total_len_u := total_len_u + to_unsigned(9, 32);
            WHEN "010" =>
                total_len_u := total_len_u + to_unsigned(12, 32);
            WHEN "011" =>
                total_len_u := total_len_u + to_unsigned(15, 32);
            WHEN "100" =>
                total_len_u := total_len_u + to_unsigned(18, 32);
            WHEN "101" =>
                total_len_u := total_len_u + to_unsigned(21, 32);
            WHEN "110" =>
                total_len_u := total_len_u + to_unsigned(24, 32);
            WHEN OTHERS =>
                total_len_u := total_len_u + to_unsigned(27, 32);
        END CASE;

        RETURN total_len_u;
    END FUNCTION;

    FUNCTION round_up_sector_bytes(size_v : UNSIGNED(31 DOWNTO 0)) RETURN UNSIGNED IS
    BEGIN
        IF size_v = to_unsigned(0, 32) THEN
            RETURN to_unsigned(0, 32);
        ELSIF size_v(8 DOWNTO 0) = to_unsigned(0, 9) THEN
            RETURN size_v;
        ELSE
            RETURN resize(shift_left(shift_right(size_v, 9) + 1, 9), 32);
        END IF;
    END FUNCTION;

    FUNCTION legacy_rs232_speed_sel(sel_v : STD_LOGIC_VECTOR(2 DOWNTO 0)) RETURN STD_LOGIC_VECTOR IS
    BEGIN
        CASE sel_v IS
            WHEN "000" => RETURN "1001";
            WHEN "001" => RETURN "0000";
            WHEN "010" => RETURN "0010";
            WHEN "011" => RETURN "0100";
            WHEN OTHERS => RETURN "1000";
        END CASE;
    END FUNCTION;

BEGIN

    cd_raw <= sd_cd;
    init_busy <= '1' WHEN (sd_cd = '0' AND init_complete_reg = '0' AND state /= ST_ERROR) ELSE
        '0';
    init_done <= init_complete_reg;
    init_error <= '1' WHEN (state = ST_ERROR AND init_complete_reg = '0') ELSE
        '0';
    read_busy <= '1' WHEN (
        sd_cd = '0' AND init_complete_reg = '1' AND read_done_reg = '0' AND read_error_reg = '0' AND
        state /= ST_READ_READY
        ) ELSE
        '0';
    read_done <= read_done_reg;
    read_error <= read_error_reg;
    read_stage <= "11" WHEN read_job_reg = JOB_FILE ELSE
        "10" WHEN (read_job_reg = JOB_ROOT OR read_job_reg = JOB_ROOT_FAT) ELSE
        "01" WHEN read_job_reg = JOB_BOOT ELSE
        "00";
    read_lba <= STD_LOGIC_VECTOR(current_lba_reg);
    read_token <= read_token_reg;
    read_count <= STD_LOGIC_VECTOR(read_byte_count_reg);
    read_first_word <= read_first_word_reg;
    read_signature <= read_signature_reg;
    part_type <= part_type_reg;
    part_lba <= STD_LOGIC_VECTOR(part_lba_reg);
    boot_bps <= boot_bps_reg;
    boot_spc <= boot_spc_reg;
    boot_reserved <= STD_LOGIC_VECTOR(boot_reserved_reg);
    boot_num_fats <= STD_LOGIC_VECTOR(boot_num_fats_reg);
    boot_spf <= STD_LOGIC_VECTOR(boot_spf_reg);
    boot_root_cluster <= boot_root_cluster_reg;
    root_dir_lba <= STD_LOGIC_VECTOR(root_dir_lba_reg);
    root_file_count <= root_file_count_reg;
    root_total_file_count <= root_total_file_count_reg;
    browser_dir_found <= browser_dir_found_reg;
    browser_has_files <= browser_has_files_reg;
    page_valid <= page_valid_reg;
    page_name <= page_name_reg;
    page_kind <= page_kind_reg;
    selected_valid <= selected_valid_reg;
    selected_name <= selected_name_reg;
    selected_cluster <= selected_cluster_reg;
    selected_size <= selected_size_reg;
    manage_busy <= manage_busy_reg;
    manage_done <= manage_done_reg;
    manage_error <= manage_error_reg;
    manage_status <= manage_status_reg;
    save_check_busy <= save_check_busy_reg;
    save_check_done <= save_check_done_reg;
    save_check_exists <= save_check_exists_reg;
    save_check_can_create <= save_check_can_create_reg;
    save_check_can_allocate <= save_check_can_allocate_reg;
    save_check_requires_dir_growth <= save_check_requires_dir_growth_reg;
    save_check_dir_full <= save_check_dir_full_reg;
    save_debug_free_lba <= STD_LOGIC_VECTOR(save_check_free_lba_reg);
    save_debug_free_slot <= save_check_free_slot_reg;
    save_debug_free_marker <= save_check_free_marker_reg;
    save_debug_free_cluster <= STD_LOGIC_VECTOR(save_check_free_cluster_reg);
    save_write_busy <= save_write_busy_reg;
    save_write_done <= save_write_done_reg;
    save_write_error <= save_write_error_reg;
    save_write_status <= save_write_status_reg;
    save_mem_addr <= save_mem_addr_reg;
    cfg_load_busy <= cfg_load_busy_reg;
    cfg_load_done <= cfg_load_done_reg;
    cfg_load_error <= cfg_load_error_reg;
    cfg_loaded_valid <= cfg_loaded_valid_reg;
    cfg_loaded_speed <= cfg_loaded_speed_reg;
    cfg_loaded_phosphor_amber <= cfg_loaded_phosphor_amber_reg;
    cfg_loaded_scanlines <= cfg_loaded_scanlines_reg;
    cfg_loaded_video_zoom <= cfg_loaded_video_zoom_reg;
    cfg_loaded_rs232 <= cfg_loaded_rs232_reg;
    cfg_loaded_rs232_speed <= cfg_loaded_rs232_speed_reg;
    cfg_loaded_rs232_flow <= cfg_loaded_rs232_flow_reg;
    cfg_loaded_slot_rom <= cfg_loaded_slot_rom_reg;
    cfg_loaded_fdd <= cfg_loaded_fdd_reg;
    cfg_loaded_cpm <= cfg_loaded_cpm_reg;
    cfg_loaded_avc <= cfg_loaded_avc_reg;
    cfg_loaded_bls <= cfg_loaded_bls_reg;
    cfg_loaded_network <= cfg_loaded_network_reg;
    cfg_loaded_network_dhcp <= cfg_loaded_network_dhcp_reg;
    cfg_loaded_network_ipv4 <= cfg_loaded_network_ipv4_reg;
    cfg_loaded_network_netmask <= cfg_loaded_network_netmask_reg;
    cfg_loaded_network_gateway <= cfg_loaded_network_gateway_reg;
    cfg_loaded_network_dns <= cfg_loaded_network_dns_reg;
    cfg_save_busy <= cfg_save_busy_reg;
    cfg_save_done <= cfg_save_done_reg;
    cfg_save_error <= cfg_save_error_reg;
    fdd_read_busy <= fdd_read_busy_reg AND NOT read_error_reg;
    fdd_read_done <= fdd_read_done_reg;
    fdd_read_error <= '1' WHEN
        (read_job_reg = JOB_FDD OR
        (read_job_reg = JOB_ROOT_FAT AND fdd_chain_active_reg = '1' AND fdd_chain_write_reg = '0')) AND
        read_error_reg = '1' ELSE
        fdd_read_error_reg;
    fdd_buffer_data <= fdd_sector_buffer_reg(to_integer(unsigned(fdd_buffer_addr)));
    fdd_write_busy <= fdd_write_busy_reg;
    fdd_write_done <= fdd_write_done_reg;
    fdd_write_error <= fdd_write_error_reg;
    fdd_format_busy <= fdd_format_busy_reg;
    fdd_format_done <= fdd_format_done_reg;
    fdd_format_error <= fdd_format_error_reg;
    fdd_format_new_cluster <= STD_LOGIC_VECTOR(fdd_format_new_cluster_reg);
    file_load_addr_valid <= file_load_addr_valid_reg;
    file_load_addr <= file_load_addr_reg;
    file_mem_wr <= file_mem_wr_reg;
    file_mem_addr <= file_mem_addr_reg;
    file_mem_data <= file_mem_data_reg;
    state_code <= STD_LOGIC_VECTOR(to_unsigned(state_t'POS(state), 8));
    last_r1 <= last_r1_reg;
    card_block_addressing <= card_block_addressing_reg;
    debug_read_cmd17_r1 <= read_cmd17_r1_reg;
    debug_read_error_code <= read_error_code_reg;
    debug_root_current_cluster <= STD_LOGIC_VECTOR(root_current_cluster_reg);
    debug_root_next_cluster <= STD_LOGIC_VECTOR(root_next_cluster_reg);
    debug_root_sectors_left <= STD_LOGIC_VECTOR(to_unsigned(root_sectors_left_reg, 8));
    debug_root_scan_phase <= '1' WHEN root_scan_phase_reg = ROOT_SCAN_LIST_FILES ELSE
        '0';
    WITH root_scan_job_reg SELECT debug_root_scan_job <=
        "00" WHEN ROOT_SCAN_DISCOVER,
        "01" WHEN ROOT_SCAN_PAGE_RELOAD,
        "10" WHEN ROOT_SCAN_SAVE_CHECK,
        "11" WHEN ROOT_SCAN_MANAGE;

    sd_sclk <= sclk_reg;
    sd_mosi <= mosi_reg;
    sd_cs_n <= cs_n_reg;
    sd_reset_n <= '1';

    SAVE_PATCH_RAM : xpm_memory_sdpram
    GENERIC MAP(
        MEMORY_SIZE => 4096,
        MEMORY_PRIMITIVE => "block",
        CLOCKING_MODE => "common_clock",
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
        ADDR_WIDTH_A => 9,
        RST_MODE_A => "SYNC",
        READ_DATA_WIDTH_B => 8,
        ADDR_WIDTH_B => 9,
        READ_RESET_VALUE_B => "0",
        READ_LATENCY_B => 1,
        WRITE_MODE_B => "no_change",
        RST_MODE_B => "SYNC"
    )
    PORT MAP(
        sleep => '0',
        clka => clk,
        ena => '1',
        wea(0) => save_patch_wr_en_reg,
        addra => save_patch_wr_addr_reg,
        dina => save_patch_wr_data_reg,
        injectsbiterra => '0',
        injectdbiterra => '0',
        clkb => clk,
        rstb => reset,
        enb => '1',
        regceb => '1',
        addrb => save_patch_rd_addr_reg,
        doutb => save_patch_rd_data_reg,
        sbiterrb => OPEN,
        dbiterrb => OPEN
    );

    --------------------------------------------------------------------
    -- Ableitung eines registrierten SPI-Ticks aus clk
    --------------------------------------------------------------------
    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF reset = '1' OR sd_cd = '1' THEN
                div_count <= 0;
                spi_tick_reg <= '0';
            ELSIF div_count = HALF_DIVIDER - 1 THEN
                div_count <= 0;
                spi_tick_reg <= '1';
            ELSE
                div_count <= div_count + 1;
                spi_tick_reg <= '0';
            END IF;
        END IF;
    END PROCESS;

    --------------------------------------------------------------------
    -- Sichtbare Browser-Auswahl aus dem geladenen 10er-Fenster ableiten
    --------------------------------------------------------------------
    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            selected_valid_reg <= '0';

            IF reset = '1' OR sd_cd = '1' OR root_file_count_reg = 0 THEN
                browser_has_files_reg <= '0';
            ELSE
                browser_has_files_reg <= '1';

                CASE selected_page_row IS
                    WHEN 0 =>
                        IF page_valid_reg(0) = '1' THEN
                            selected_valid_reg <= '1';
                            selected_name_reg <= page_name_reg(0);
                            selected_cluster_reg <= page_cluster_reg(0);
                            selected_size_reg <= page_size_reg(0);
                        END IF;
                    WHEN 1 =>
                        IF page_valid_reg(1) = '1' THEN
                            selected_valid_reg <= '1';
                            selected_name_reg <= page_name_reg(1);
                            selected_cluster_reg <= page_cluster_reg(1);
                            selected_size_reg <= page_size_reg(1);
                        END IF;
                    WHEN 2 =>
                        IF page_valid_reg(2) = '1' THEN
                            selected_valid_reg <= '1';
                            selected_name_reg <= page_name_reg(2);
                            selected_cluster_reg <= page_cluster_reg(2);
                            selected_size_reg <= page_size_reg(2);
                        END IF;
                    WHEN 3 =>
                        IF page_valid_reg(3) = '1' THEN
                            selected_valid_reg <= '1';
                            selected_name_reg <= page_name_reg(3);
                            selected_cluster_reg <= page_cluster_reg(3);
                            selected_size_reg <= page_size_reg(3);
                        END IF;
                    WHEN 4 =>
                        IF page_valid_reg(4) = '1' THEN
                            selected_valid_reg <= '1';
                            selected_name_reg <= page_name_reg(4);
                            selected_cluster_reg <= page_cluster_reg(4);
                            selected_size_reg <= page_size_reg(4);
                        END IF;
                    WHEN 5 =>
                        IF page_valid_reg(5) = '1' THEN
                            selected_valid_reg <= '1';
                            selected_name_reg <= page_name_reg(5);
                            selected_cluster_reg <= page_cluster_reg(5);
                            selected_size_reg <= page_size_reg(5);
                        END IF;
                    WHEN 6 =>
                        IF page_valid_reg(6) = '1' THEN
                            selected_valid_reg <= '1';
                            selected_name_reg <= page_name_reg(6);
                            selected_cluster_reg <= page_cluster_reg(6);
                            selected_size_reg <= page_size_reg(6);
                        END IF;
                    WHEN 7 =>
                        IF page_valid_reg(7) = '1' THEN
                            selected_valid_reg <= '1';
                            selected_name_reg <= page_name_reg(7);
                            selected_cluster_reg <= page_cluster_reg(7);
                            selected_size_reg <= page_size_reg(7);
                        END IF;
                    WHEN 8 =>
                        IF page_valid_reg(8) = '1' THEN
                            selected_valid_reg <= '1';
                            selected_name_reg <= page_name_reg(8);
                            selected_cluster_reg <= page_cluster_reg(8);
                            selected_size_reg <= page_size_reg(8);
                        END IF;
                    WHEN OTHERS =>
                        IF page_valid_reg(9) = '1' THEN
                            selected_valid_reg <= '1';
                            selected_name_reg <= page_name_reg(9);
                            selected_cluster_reg <= page_cluster_reg(9);
                            selected_size_reg <= page_size_reg(9);
                        END IF;
                END CASE;
            END IF;
        END IF;
    END PROCESS;

    --------------------------------------------------------------------
    -- Haupt-FSM fuer SD-Karte, Browser, Loader und Save-Backend
    --------------------------------------------------------------------
    PROCESS (clk)
        VARIABLE tick_v : BOOLEAN;
        VARIABLE byte_done_v : BOOLEAN;
        VARIABLE rx_byte_v : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE queue_byte_v : BOOLEAN;
        VARIABLE cas_commit_v : BOOLEAN;
        VARIABLE queue_data_v : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE cmd17_arg_v : UNSIGNED(31 DOWNTO 0);
        VARIABLE lba_result_v : UNSIGNED(31 DOWNTO 0);
        VARIABLE root_next_cluster_v : UNSIGNED(31 DOWNTO 0);
        VARIABLE file_write_addr_v : UNSIGNED(15 DOWNTO 0);
        VARIABLE file_write_data_v : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE save_byte_count_v : UNSIGNED(15 DOWNTO 0);
        VARIABLE save_stream_len_v : UNSIGNED(31 DOWNTO 0);
        VARIABLE save_sector_total_v : UNSIGNED(31 DOWNTO 0);
        VARIABLE save_sector_count_v : UNSIGNED(31 DOWNTO 0);
        VARIABLE save_cluster_capacity_v : UNSIGNED(31 DOWNTO 0);
        VARIABLE save_create_next_cluster_v : UNSIGNED(31 DOWNTO 0);
        VARIABLE save_clusters_needed_v : UNSIGNED(15 DOWNTO 0);
        VARIABLE save_clusters_needed_i : INTEGER RANGE 0 TO 65535;
        VARIABLE save_out_byte_v : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE save_line_len_v : INTEGER RANGE 0 TO 8;
        VARIABLE cfg_byte4_v : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE cfg_byte5_v : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE save_check_name_v : STD_LOGIC_VECTOR(87 DOWNTO 0);
        VARIABLE cfg_byte6_v : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE cfg_byte8_v : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE cfg_network_v : STD_LOGIC_VECTOR(135 DOWNTO 0);
        VARIABLE save_extend_dir_v : BOOLEAN;
    BEGIN
        IF rising_edge(clk) THEN
            tick_v := (spi_tick_reg = '1');
            byte_done_v := FALSE;
            rx_byte_v := x"FF";
            queue_byte_v := FALSE;
            cas_commit_v := FALSE;
            queue_data_v := x"FF";
            save_check_done_reg <= '0';
            file_mem_wr_reg <= '0';
            file_mem_addr_reg <= x"0000";
            file_mem_data_reg <= x"00";
            save_patch_wr_en_reg <= '0';
            cfg_load_done_reg <= '0';
            cfg_load_error_reg <= '0';
            cfg_loaded_valid_reg <= '0';
            cfg_save_done_reg <= '0';
            cfg_save_error_reg <= '0';
            fdd_write_done_reg <= '0';
            fdd_write_error_reg <= '0';
            fdd_format_done_reg <= '0';
            fdd_format_error_reg <= '0';
            manage_done_reg <= '0';

            IF fdd_buffer_write_enable = '1' THEN
                fdd_sector_buffer_reg(to_integer(unsigned(fdd_buffer_write_addr))) <= fdd_buffer_write_data;
            END IF;

            IF save_done_clear = '1' AND save_write_busy_reg = '0' THEN
                save_write_done_reg <= '0';
                IF save_write_error_reg = '0' THEN
                    save_write_status_reg <= SAVE_STATUS_NONE;
                END IF;
            END IF;

            IF save_status_clear = '1' AND save_write_busy_reg = '0' THEN
                save_write_done_reg <= '0';
                save_write_error_reg <= '0';
                save_write_status_reg <= SAVE_STATUS_NONE;
            END IF;

            IF reset = '1' OR sd_cd = '1' THEN
                state <= ST_WAIT_CARD;
                send_after_state <= ST_WAIT_CARD;
                gap_after_state <= ST_WAIT_CARD;
                byte_busy <= '0';
                sclk_reg <= '0';
                mosi_reg <= '1';
                cs_n_reg <= '1';
                tx_shift <= x"FF";
                rx_shift <= x"FF";
                bit_idx <= 7;
                cmd_packet <= (OTHERS => x"FF");
                cmd_index <= 0;
                response_timeout <= 0;
                fdd_format_read_retry_reg <= 0;
                tail_bytes_left <= 0;
                dummy_bytes_left <= 0;
                card_settle_count <= 0;
                cmd0_retries <= 0;
                acmd41_retries <= 0;
                read_token_timeout <= 0;
                data_bytes_left <= 0;
                data_index <= 0;
                last_r1_reg <= x"FF";
                init_complete_reg <= '0';
                card_block_addressing_reg <= '0';
                current_lba_reg <= (OTHERS => '0');
                read_job_reg <= JOB_MBR;
                read_done_reg <= '0';
                read_error_reg <= '0';
                read_token_reg <= x"FF";
                read_byte_count_reg <= (OTHERS => '0');
                read_cmd17_r1_reg <= x"FF";
                read_error_code_reg <= x"0";
                read_first_word_reg <= x"00000000";
                read_signature_reg <= x"0000";
                part_type_reg <= x"00";
                part_lba_reg <= (OTHERS => '0');
                boot_bps_reg <= x"0000";
                boot_spc_reg <= x"00";
                boot_reserved_reg <= (OTHERS => '0');
                boot_num_fats_reg <= (OTHERS => '0');
                boot_spf_reg <= (OTHERS => '0');
                boot_root_cluster_reg <= x"00000000";
                root_dir_lba_reg <= (OTHERS => '0');
                root_current_cluster_reg <= (OTHERS => '0');
                root_next_cluster_reg <= (OTHERS => '0');
                root_fat_byte_offset_reg <= 0;
                root_chain_advance_reg <= '0';
                root_sectors_left_reg <= 0;
                root_end_seen_reg <= '0';
                browser_dir_found_reg <= '0';
                browser_dir_cluster_reg <= (OTHERS => '0');
                root_scan_phase_reg <= ROOT_SCAN_FIND_DIR;
                root_scan_job_reg <= ROOT_SCAN_DISCOVER;
                dir_entry_name_tmp_reg <= (OTHERS => '0');
                dir_entry_attr_tmp_reg <= x"00";
                dir_entry_cluster_tmp_reg <= (OTHERS => '0');
                dir_entry_size_tmp_reg <= (OTHERS => '0');
                root_file_count_reg <= 0;
                root_total_file_count_reg <= 0;
                browser_cache_valid_reg <= '0';
                browser_include_pas_reg <= browser_include_pas;
                cached_free_valid_reg <= '0';
                cached_free_lba_reg <= (OTHERS => '0');
                cached_free_slot_reg <= 0;
                cached_free_marker_reg <= x"00";
                cached_free_sector_first_byte_reg <= x"00";
                cached_free_requires_dir_growth_reg <= '0';
                page_valid_reg <= (OTHERS => '0');
                page_name_reg <= (OTHERS => (OTHERS => '0'));
                page_cluster_reg <= (OTHERS => (OTHERS => '0'));
                page_size_reg <= (OTHERS => (OTHERS => '0'));
                page_kind_reg <= (OTHERS => SD_DSK_KIND_UNKNOWN);
                dsk_probe_active_reg <= '0';
                dsk_probe_index_reg <= 0;
                browser_page_reload_reg <= '0';
                browser_page_dirty_reg <= '0';
                browser_rescan_pending_reg <= '0';
                browser_page_fill_active_reg <= '0';
                browser_page_fill_index_reg <= 0;
                browser_page_fill_base_reg <= 0;
                reload_match_index_reg <= 0;
                page_loaded_base_reg <= 0;
                manage_busy_reg <= '0';
                manage_done_reg <= '0';
                manage_error_reg <= '0';
                manage_status_reg <= MANAGE_STATUS_NONE;
                manage_delete_reg <= '0';
                manage_old_name_reg <= (OTHERS => '0');
                manage_new_name_reg <= (OTHERS => '0');
                manage_found_reg <= '0';
                manage_duplicate_reg <= '0';
                manage_lfn_reg <= '0';
                manage_read_only_reg <= '0';
                manage_prev_lfn_reg <= '0';
                manage_match_lba_reg <= (OTHERS => '0');
                manage_match_slot_reg <= 0;
                manage_match_first_byte_reg <= x"00";
                manage_cluster_reg <= (OTHERS => '0');
                manage_next_cluster_reg <= (OTHERS => '0');
                manage_fat_offset_reg <= 0;
                manage_chain_guard_reg <= (OTHERS => '0');
                save_check_name_reg <= x"20202020202020204E4153";
                save_cache_lookup_active_reg <= '0';
                save_cache_lookup_index_reg <= 0;
                save_check_busy_reg <= '0';
                save_check_done_reg <= '0';
                save_check_exists_reg <= '0';
                save_check_can_create_reg <= '0';
                save_check_can_allocate_reg <= '0';
                save_check_requires_dir_growth_reg <= '0';
                save_check_dir_full_reg <= '0';
                save_check_cluster_reg <= (OTHERS => '0');
                save_check_size_reg <= (OTHERS => '0');
                save_check_free_lba_reg <= (OTHERS => '0');
                save_check_free_slot_reg <= 0;
                save_check_free_marker_reg <= x"00";
                save_check_free_cluster_reg <= (OTHERS => '0');
                save_check_free_sector_first_byte_reg <= x"00";
                fat_scan_sectors_left_reg <= (OTHERS => '0');
                fat_scan_cluster_reg <= (OTHERS => '0');
                fat_scan_run_start_reg <= (OTHERS => '0');
                fat_scan_run_len_reg <= (OTHERS => '0');
                fat_entry_tmp_reg <= (OTHERS => '0');
                save_verify_pending_reg <= '0';
                save_verify_expected_cluster_reg <= (OTHERS => '0');
                save_verify_expected_size_reg <= (OTHERS => '0');
                root_sector_first_byte_reg <= x"00";
                cfg_request_reg <= CFG_REQ_NONE;
                cfg_load_busy_reg <= '0';
                cfg_load_done_reg <= '0';
                cfg_load_error_reg <= '0';
                cfg_loaded_valid_reg <= '0';
                cfg_loaded_speed_reg <= "00";
                cfg_loaded_phosphor_amber_reg <= '0';
                cfg_loaded_scanlines_reg <= '0';
                cfg_loaded_video_zoom_reg <= "00";
                cfg_loaded_rs232_reg <= "000";
                cfg_loaded_rs232_speed_reg <= "1001";
                cfg_loaded_rs232_flow_reg <= '0';
                cfg_loaded_slot_rom_reg <= "1111";
                cfg_loaded_fdd_reg <= '0';
                cfg_loaded_cpm_reg <= '0';
                cfg_loaded_avc_reg <= '0';
                cfg_loaded_bls_reg <= '0';
                cfg_loaded_network_reg <= '0';
                cfg_loaded_network_dhcp_reg <= '0';
                cfg_loaded_network_ipv4_reg <= x"C0A80141";
                cfg_loaded_network_netmask_reg <= x"FFFFFF00";
                cfg_loaded_network_gateway_reg <= x"C0A80101";
                cfg_loaded_network_dns_reg <= x"C0A80101";
                cfg_save_busy_reg <= '0';
                cfg_save_done_reg <= '0';
                cfg_save_error_reg <= '0';
                cfg_save_recheck_reg <= '0';
                cfg_byte4_reg <= x"00";
                cfg_byte5_reg <= x"0F";
                cfg_byte6_reg <= x"00";
                cfg_byte7_reg <= x"AA";
                cfg_byte8_reg <= x"09";
                cfg_parse_byte4_reg <= x"00";
                cfg_parse_byte5_reg <= x"00";
                cfg_parse_byte6_reg <= x"00";
                cfg_parse_byte7_reg <= x"00";
                cfg_parse_byte8_reg <= x"00";
                cfg_parse_byte9_reg <= x"00";
                cfg_parse_byte14_reg <= x"00";
                cfg_network_payload_reg <= x"00" & x"C0A80141" & x"FFFFFF00" & x"C0A80101" & x"C0A80101";
                cfg_parse_network_payload_reg <= (OTHERS => '0');
                cfg_parse_byte30_reg <= x"00";
                fdd_sector_offset_reg <= (OTHERS => '0');
                fdd_chain_active_reg <= '0';
                fdd_chain_write_reg <= '0';
                fdd_chain_remaining_reg <= (OTHERS => '0');
                fdd_chain_sector_base_reg <= (OTHERS => '0');
                fdd_chain_file_cluster_reg <= (OTHERS => '0');
                fdd_read_cache_valid_reg <= '0';
                fdd_read_cache_file_cluster_reg <= (OTHERS => '0');
                fdd_read_cache_cluster_reg <= (OTHERS => '0');
                fdd_read_cache_sector_base_reg <= (OTHERS => '0');
                fdd_write_cache_valid_reg <= '0';
                fdd_write_cache_file_cluster_reg <= (OTHERS => '0');
                fdd_write_cache_cluster_reg <= (OTHERS => '0');
                fdd_write_cache_sector_base_reg <= (OTHERS => '0');
                fdd_read_half_reg <= '0';
                fdd_read_busy_reg <= '0';
                fdd_read_done_reg <= '0';
                fdd_read_error_reg <= '0';
                fdd_write_half_reg <= '0';
                fdd_write_busy_reg <= '0';
                fdd_write_done_reg <= '0';
                fdd_write_error_reg <= '0';
                fdd_write_patch_index_reg <= 0;
                fdd_write_pending_reg <= '0';
                fdd_write_pending_cluster_reg <= (OTHERS => '0');
                fdd_write_pending_sector_reg <= (OTHERS => '0');
                fdd_write_pending_half_reg <= '0';
                fdd_write_complete_pending_reg <= '0';
                fdd_format_phase_reg <= FDD_FORMAT_IDLE;
                fdd_format_busy_reg <= '0';
                fdd_format_done_reg <= '0';
                fdd_format_error_reg <= '0';
                fdd_format_name_reg <= (OTHERS => '0');
                fdd_format_bak_name_reg <= (OTHERS => '0');
                fdd_format_old_cluster_reg <= (OTHERS => '0');
                fdd_format_new_cluster_reg <= (OTHERS => '0');
                save_write_busy_reg <= '0';
                save_write_done_reg <= '0';
                save_write_error_reg <= '0';
                save_write_status_reg <= SAVE_STATUS_NONE;
                save_req_start_addr_reg <= (OTHERS => '0');
                save_req_end_addr_reg <= (OTHERS => '0');
                save_byte_count_reg <= (OTHERS => '0');
                save_stream_len_reg <= (OTHERS => '0');
                save_sector_total_reg <= (OTHERS => '0');
                save_clusters_needed_reg <= to_unsigned(1, 16);
                save_alloc_search_need_reg <= to_unsigned(1, 16);
                save_mem_addr_reg <= x"0000";
                save_lba_pending_reg <= '0';
                save_cmd24_pending_reg <= '0';
                save_sectors_left_reg <= (OTHERS => '0');
                save_pad_bytes_left_reg <= (OTHERS => '0');
                save_prog_bytes_left_reg <= (OTHERS => '0');
                save_line_addr_reg <= (OTHERS => '0');
                save_current_mem_addr_reg <= (OTHERS => '0');
                save_line_data_left_reg <= 0;
                save_mem_byte_reg <= x"00";
                save_fmt_state_reg <= SAVE_FMT_IDLE;
                save_sector_tx_index_reg <= 0;
                save_tx_byte_reg <= x"20";
                write_busy_timeout_reg <= 0;
                save_sector_source_reg <= SAVE_SECTOR_NAS;
                save_create_phase_reg <= SAVE_CREATE_IDLE;
                save_create_extend_dir_reg <= '0';
                save_fat_byte_offset_reg <= 0;
                save_fat_copy_index_reg <= 0;
                save_create_current_cluster_reg <= (OTHERS => '0');
                save_create_clusters_left_reg <= (OTHERS => '0');
                save_patch_step_reg <= 0;
                save_patch_wr_en_reg <= '0';
                save_patch_wr_addr_reg <= (OTHERS => '0');
                save_patch_wr_data_reg <= x"00";
                save_patch_rd_addr_reg <= (OTHERS => '0');
                save_patch_first_byte_reg <= x"00";
                save_verify_dir_lba_reg <= (OTHERS => '0');
                save_verify_dir_first_byte_reg <= x"00";
                save_verify_dir_byte_ok_reg <= '1';
                save_backend_is_cfg_reg <= '0';
                save_backend_is_fdd_reg <= '0';
                file_read_is_cas_reg <= '0';
                file_load_addr_valid_reg <= '0';
                file_load_addr_reg <= x"0000";
                file_mem_wr_reg <= '0';
                file_mem_addr_reg <= x"0000";
                file_mem_data_reg <= x"00";
                file_bytes_left_reg <= (OTHERS => '0');
                file_cas_error_reg <= '0';
                cas_parse_state_reg <= CAS_SYNC_00;
                cas_block_addr_reg <= (OTHERS => '0');
                cas_block_len_reg <= (OTHERS => '0');
                cas_header_sum_reg <= (OTHERS => '0');
                cas_data_sum_reg <= (OTHERS => '0');
                cas_data_left_reg <= 0;
                cas_data_addr_reg <= (OTHERS => '0');
                nas_addr_reg <= x"0000";
                nas_addr_digits_reg <= 0;
                nas_token_reg <= x"00";
                nas_token_digits_reg <= 0;
                nas_data_index_reg <= 0;
                nas_in_line_reg <= '0';
                nas_ignore_line_reg <= '0';
                lba_target_reg <= LBA_TARGET_ROOT;
                lba_cluster_reg <= (OTHERS => '0');
                lba_data_start_reg <= (OTHERS => '0');
                lba_cluster_offset_reg <= (OTHERS => '0');
            ELSE
                IF browser_include_pas_reg /= browser_include_pas THEN
                    browser_include_pas_reg <= browser_include_pas;
                    browser_cache_valid_reg <= '0';
                    browser_rescan_pending_reg <= '1';
                    browser_page_dirty_reg <= '1';
                    page_valid_reg <= (OTHERS => '0');
                END IF;

                -- Accept each request exactly once.  The Nascom top keeps
                -- fdd_write_start asserted until it observes BUSY, so treating
                -- it as a pulse can queue the same sector again on the cycle
                -- after the pending request is consumed.  That duplicate
                -- completion also advances a WD1793 multi-sector command twice.
                IF fdd_write_start = '1' AND
                    fdd_write_pending_reg = '0' AND
                    fdd_write_busy_reg = '0' AND
                    save_backend_is_fdd_reg = '0' THEN
                    fdd_write_pending_reg <= '1';
                    fdd_write_pending_cluster_reg <= UNSIGNED(fdd_write_cluster);
                    fdd_write_pending_sector_reg <= UNSIGNED(fdd_write_sd_sector);
                    fdd_write_pending_half_reg <= fdd_write_half;
                END IF;

                IF byte_busy = '1' AND tick_v THEN
                    IF sclk_reg = '0' THEN
                        sclk_reg <= '1';
                    ELSE
                        sclk_reg <= '0';
                        rx_shift <= rx_shift(6 DOWNTO 0) & sd_miso;

                        IF bit_idx = 0 THEN
                            byte_busy <= '0';
                            mosi_reg <= '1';
                            rx_byte_v := rx_shift(6 DOWNTO 0) & sd_miso;
                            byte_done_v := TRUE;
                        ELSE
                            bit_idx <= bit_idx - 1;
                            tx_shift <= tx_shift(6 DOWNTO 0) & '1';
                            mosi_reg <= tx_shift(6);
                        END IF;
                    END IF;
                END IF;

                CASE state IS
                    WHEN ST_WAIT_CARD =>
                        cs_n_reg <= '1';
                        sclk_reg <= '0';
                        mosi_reg <= '1';
                        byte_busy <= '0';

                        IF sd_cd = '0' THEN
                            card_settle_count <= CARD_SETTLE_CYCLES;
                            cmd0_retries <= 0;
                            acmd41_retries <= 0;
                            response_timeout <= 0;
                            state <= ST_CARD_SETTLE;
                        END IF;

                    WHEN ST_CARD_SETTLE =>
                        cs_n_reg <= '1';
                        sclk_reg <= '0';
                        mosi_reg <= '1';
                        byte_busy <= '0';
                        tx_shift <= x"FF";
                        rx_shift <= x"FF";
                        bit_idx <= 7;

                        IF sd_cd = '1' THEN
                            state <= ST_WAIT_CARD;
                        ELSIF card_settle_count = 0 THEN
                            dummy_bytes_left <= 20;
                            cmd0_retries <= 0;
                            acmd41_retries <= 0;
                            response_timeout <= 0;
                            state <= ST_DUMMY_CLOCKS;
                        ELSE
                            card_settle_count <= card_settle_count - 1;
                        END IF;

                    WHEN ST_DUMMY_CLOCKS =>
                        cs_n_reg <= '1';
                        IF byte_done_v THEN
                            IF dummy_bytes_left = 1 THEN
                                state <= ST_PREP_CMD0;
                            ELSE
                                dummy_bytes_left <= dummy_bytes_left - 1;
                            END IF;
                        ELSIF byte_busy = '0' THEN
                            queue_byte_v := TRUE;
                            queue_data_v := x"FF";
                        END IF;

                    WHEN ST_PREP_CMD0 =>
                        cmd_packet(0) <= x"40";
                        cmd_packet(1) <= x"00";
                        cmd_packet(2) <= x"00";
                        cmd_packet(3) <= x"00";
                        cmd_packet(4) <= x"00";
                        cmd_packet(5) <= x"95";
                        cmd_index <= 0;
                        send_after_state <= ST_WAIT_CMD0_R1;
                        cs_n_reg <= '0';
                        state <= ST_SEND_CMD;

                    WHEN ST_PREP_CMD8 =>
                        cmd_packet(0) <= x"48";
                        cmd_packet(1) <= x"00";
                        cmd_packet(2) <= x"00";
                        cmd_packet(3) <= x"01";
                        cmd_packet(4) <= x"AA";
                        cmd_packet(5) <= x"87";
                        cmd_index <= 0;
                        send_after_state <= ST_WAIT_CMD8_R1;
                        cs_n_reg <= '0';
                        state <= ST_SEND_CMD;

                    WHEN ST_PREP_CMD55 =>
                        cmd_packet(0) <= x"77";
                        cmd_packet(1) <= x"00";
                        cmd_packet(2) <= x"00";
                        cmd_packet(3) <= x"00";
                        cmd_packet(4) <= x"00";
                        cmd_packet(5) <= x"65";
                        cmd_index <= 0;
                        send_after_state <= ST_WAIT_CMD55_R1;
                        cs_n_reg <= '0';
                        state <= ST_SEND_CMD;

                    WHEN ST_PREP_ACMD41 =>
                        cmd_packet(0) <= x"69";
                        cmd_packet(1) <= x"40";
                        cmd_packet(2) <= x"00";
                        cmd_packet(3) <= x"00";
                        cmd_packet(4) <= x"00";
                        cmd_packet(5) <= x"77";
                        cmd_index <= 0;
                        send_after_state <= ST_WAIT_ACMD41_R1;
                        cs_n_reg <= '0';
                        state <= ST_SEND_CMD;

                    WHEN ST_PREP_CMD58 =>
                        cmd_packet(0) <= x"7A";
                        cmd_packet(1) <= x"00";
                        cmd_packet(2) <= x"00";
                        cmd_packet(3) <= x"00";
                        cmd_packet(4) <= x"00";
                        cmd_packet(5) <= x"FD";
                        cmd_index <= 0;
                        send_after_state <= ST_WAIT_CMD58_R1;
                        cs_n_reg <= '0';
                        state <= ST_SEND_CMD;

                    WHEN ST_PREP_CMD17 =>
                        IF card_block_addressing_reg = '1' THEN
                            cmd17_arg_v := current_lba_reg;
                        ELSE
                            cmd17_arg_v := shift_left(current_lba_reg, 9);
                        END IF;

                        cmd_packet(0) <= x"51";
                        cmd_packet(1) <= STD_LOGIC_VECTOR(cmd17_arg_v(31 DOWNTO 24));
                        cmd_packet(2) <= STD_LOGIC_VECTOR(cmd17_arg_v(23 DOWNTO 16));
                        cmd_packet(3) <= STD_LOGIC_VECTOR(cmd17_arg_v(15 DOWNTO 8));
                        cmd_packet(4) <= STD_LOGIC_VECTOR(cmd17_arg_v(7 DOWNTO 0));
                        cmd_packet(5) <= x"FF";
                        cmd_index <= 0;
                        read_done_reg <= '0';
                        read_error_reg <= '0';
                        read_token_reg <= x"FF";
                        read_byte_count_reg <= (OTHERS => '0');
                        read_cmd17_r1_reg <= x"FF";
                        read_error_code_reg <= x"0";
                        read_first_word_reg <= x"00000000";
                        read_signature_reg <= x"0000";
                        IF read_job_reg = JOB_ROOT THEN
                            root_end_seen_reg <= '0';
                            dir_entry_name_tmp_reg <= (OTHERS => '0');
                            dir_entry_attr_tmp_reg <= x"00";
                            dir_entry_cluster_tmp_reg <= (OTHERS => '0');
                            dir_entry_size_tmp_reg <= (OTHERS => '0');
                        END IF;
                        send_after_state <= ST_WAIT_CMD17_R1;
                        cs_n_reg <= '0';
                        state <= ST_SEND_CMD;

                    WHEN ST_PREP_CMD24 =>
                        IF card_block_addressing_reg = '1' THEN
                            cmd17_arg_v := current_lba_reg;
                        ELSE
                            cmd17_arg_v := shift_left(current_lba_reg, 9);
                        END IF;

                        cmd_packet(0) <= x"58";
                        cmd_packet(1) <= STD_LOGIC_VECTOR(cmd17_arg_v(31 DOWNTO 24));
                        cmd_packet(2) <= STD_LOGIC_VECTOR(cmd17_arg_v(23 DOWNTO 16));
                        cmd_packet(3) <= STD_LOGIC_VECTOR(cmd17_arg_v(15 DOWNTO 8));
                        cmd_packet(4) <= STD_LOGIC_VECTOR(cmd17_arg_v(7 DOWNTO 0));
                        cmd_packet(5) <= x"FF";
                        cmd_index <= 0;
                        send_after_state <= ST_WAIT_CMD24_R1;
                        cs_n_reg <= '0';
                        state <= ST_SEND_CMD;

                    WHEN ST_SEND_CMD =>
                        cs_n_reg <= '0';
                        IF byte_done_v THEN
                            IF cmd_index = 5 THEN
                                response_timeout <= RESPONSE_TIMEOUT_MAX;
                                state <= send_after_state;
                            ELSE
                                cmd_index <= cmd_index + 1;
                            END IF;
                        ELSIF byte_busy = '0' THEN
                            queue_byte_v := TRUE;
                            queue_data_v := cmd_packet(cmd_index);
                        END IF;

                    WHEN ST_WAIT_CMD0_R1 =>
                        cs_n_reg <= '0';
                        IF byte_done_v THEN
                            IF rx_byte_v(7) = '0' THEN
                                last_r1_reg <= rx_byte_v;
                                IF rx_byte_v = x"01" THEN
                                    gap_after_state <= ST_PREP_CMD8;
                                    state <= ST_GAP;
                                ELSIF cmd0_retries < 15 THEN
                                    cmd0_retries <= cmd0_retries + 1;
                                    gap_after_state <= ST_PREP_CMD0;
                                    state <= ST_GAP;
                                ELSE
                                    state <= ST_ERROR;
                                END IF;
                            ELSIF response_timeout = 0 THEN
                                state <= ST_ERROR;
                            ELSE
                                response_timeout <= response_timeout - 1;
                            END IF;
                        ELSIF byte_busy = '0' THEN
                            queue_byte_v := TRUE;
                            queue_data_v := x"FF";
                        END IF;

                    WHEN ST_WAIT_CMD8_R1 =>
                        cs_n_reg <= '0';
                        IF byte_done_v THEN
                            IF rx_byte_v(7) = '0' THEN
                                last_r1_reg <= rx_byte_v;
                                IF rx_byte_v = x"01" THEN
                                    tail_bytes_left <= 4;
                                    state <= ST_READ_CMD8_TAIL;
                                ELSE
                                    state <= ST_ERROR;
                                END IF;
                            ELSIF response_timeout = 0 THEN
                                state <= ST_ERROR;
                            ELSE
                                response_timeout <= response_timeout - 1;
                            END IF;
                        ELSIF byte_busy = '0' THEN
                            queue_byte_v := TRUE;
                            queue_data_v := x"FF";
                        END IF;

                    WHEN ST_READ_CMD8_TAIL =>
                        cs_n_reg <= '0';
                        IF byte_done_v THEN
                            IF tail_bytes_left = 1 THEN
                                gap_after_state <= ST_PREP_CMD55;
                                state <= ST_GAP;
                            ELSE
                                tail_bytes_left <= tail_bytes_left - 1;
                            END IF;
                        ELSIF byte_busy = '0' THEN
                            queue_byte_v := TRUE;
                            queue_data_v := x"FF";
                        END IF;

                    WHEN ST_WAIT_CMD55_R1 =>
                        cs_n_reg <= '0';
                        IF byte_done_v THEN
                            IF rx_byte_v(7) = '0' THEN
                                last_r1_reg <= rx_byte_v;
                                IF rx_byte_v = x"01" OR rx_byte_v = x"00" THEN
                                    gap_after_state <= ST_PREP_ACMD41;
                                    state <= ST_GAP;
                                ELSE
                                    state <= ST_ERROR;
                                END IF;
                            ELSIF response_timeout = 0 THEN
                                state <= ST_ERROR;
                            ELSE
                                response_timeout <= response_timeout - 1;
                            END IF;
                        ELSIF byte_busy = '0' THEN
                            queue_byte_v := TRUE;
                            queue_data_v := x"FF";
                        END IF;

                    WHEN ST_WAIT_ACMD41_R1 =>
                        cs_n_reg <= '0';
                        IF byte_done_v THEN
                            IF rx_byte_v(7) = '0' THEN
                                last_r1_reg <= rx_byte_v;
                                IF rx_byte_v = x"00" THEN
                                    gap_after_state <= ST_PREP_CMD58;
                                    state <= ST_GAP;
                                ELSIF rx_byte_v = x"01" AND acmd41_retries < ACMD41_RETRY_MAX THEN
                                    acmd41_retries <= acmd41_retries + 1;
                                    gap_after_state <= ST_PREP_CMD55;
                                    state <= ST_GAP;
                                ELSE
                                    state <= ST_ERROR;
                                END IF;
                            ELSIF response_timeout = 0 THEN
                                state <= ST_ERROR;
                            ELSE
                                response_timeout <= response_timeout - 1;
                            END IF;
                        ELSIF byte_busy = '0' THEN
                            queue_byte_v := TRUE;
                            queue_data_v := x"FF";
                        END IF;

                    WHEN ST_WAIT_CMD58_R1 =>
                        cs_n_reg <= '0';
                        IF byte_done_v THEN
                            IF rx_byte_v(7) = '0' THEN
                                last_r1_reg <= rx_byte_v;
                                IF rx_byte_v = x"00" THEN
                                    tail_bytes_left <= 4;
                                    state <= ST_READ_CMD58_TAIL;
                                ELSE
                                    state <= ST_ERROR;
                                END IF;
                            ELSIF response_timeout = 0 THEN
                                state <= ST_ERROR;
                            ELSE
                                response_timeout <= response_timeout - 1;
                            END IF;
                        ELSIF byte_busy = '0' THEN
                            queue_byte_v := TRUE;
                            queue_data_v := x"FF";
                        END IF;

                    WHEN ST_READ_CMD58_TAIL =>
                        cs_n_reg <= '0';
                        IF byte_done_v THEN
                            IF tail_bytes_left = 4 THEN
                                card_block_addressing_reg <= rx_byte_v(6);
                            END IF;

                            IF tail_bytes_left = 1 THEN
                                init_complete_reg <= '1';
                                current_lba_reg <= (OTHERS => '0');
                                read_job_reg <= JOB_MBR;
                                gap_after_state <= ST_PREP_CMD17;
                                state <= ST_GAP;
                            ELSE
                                tail_bytes_left <= tail_bytes_left - 1;
                            END IF;
                        ELSIF byte_busy = '0' THEN
                            queue_byte_v := TRUE;
                            queue_data_v := x"FF";
                        END IF;

                    WHEN ST_WAIT_CMD17_R1 =>
                        cs_n_reg <= '0';
                        IF byte_done_v THEN
                            -- Eine gueltige R1-Antwort hat Bit 7 immer 0.
                            -- Bytes wie C1 duerfen nicht als R1 gewertet werden.
                            IF rx_byte_v(7) = '0' THEN
                                last_r1_reg <= rx_byte_v;
                                read_cmd17_r1_reg <= rx_byte_v;
                                IF rx_byte_v = x"00" THEN
                                    read_token_timeout <= READ_TOKEN_TIMEOUT_MAX;
                                    state <= ST_WAIT_DATA_TOKEN;
                                ELSE
                                    IF (fdd_format_phase_reg /= FDD_FORMAT_IDLE OR
                                        read_job_reg = JOB_FDD_WRITE OR
                                        read_job_reg = JOB_MBR) AND
                                        fdd_format_read_retry_reg < 3 THEN
                                        fdd_format_read_retry_reg <= fdd_format_read_retry_reg + 1;
                                        read_error_code_reg <= x"1";
                                        gap_after_state <= ST_PREP_CMD17;
                                        state <= ST_GAP;
                                    ELSIF cfg_request_reg = CFG_REQ_LOAD THEN
                                        save_check_busy_reg <= '0';
                                        save_cache_lookup_active_reg <= '0';
                                        save_verify_pending_reg <= '0';
                                        root_scan_job_reg <= ROOT_SCAN_DISCOVER;
                                        cfg_load_busy_reg <= '0';
                                        cfg_load_error_reg <= '1';
                                        cfg_request_reg <= CFG_REQ_NONE;
                                        read_done_reg <= '1';
                                    ELSIF cfg_request_reg = CFG_REQ_SAVE OR save_backend_is_cfg_reg = '1' THEN
                                        save_check_busy_reg <= '0';
                                        save_cache_lookup_active_reg <= '0';
                                        save_verify_pending_reg <= '0';
                                        root_scan_job_reg <= ROOT_SCAN_DISCOVER;
                                        save_write_busy_reg <= '0';
                                        save_write_error_reg <= '1';
                                        save_write_status_reg <= SAVE_STATUS_IO_ERROR;
                                        cfg_save_busy_reg <= '0';
                                        cfg_save_error_reg <= '1';
                                        cfg_request_reg <= CFG_REQ_NONE;
                                        save_backend_is_cfg_reg <= '0';
                                        read_done_reg <= '1';
                                    ELSE
                                        read_error_reg <= '1';
                                    END IF;
                                    IF NOT ((fdd_format_phase_reg /= FDD_FORMAT_IDLE OR
                                        read_job_reg = JOB_FDD_WRITE OR
                                        read_job_reg = JOB_MBR) AND
                                        fdd_format_read_retry_reg < 3) THEN
                                        read_error_code_reg <= x"1";
                                        gap_after_state <= ST_READ_READY;
                                        state <= ST_GAP;
                                    END IF;
                                END IF;
                            ELSIF response_timeout = 0 THEN
                                IF (fdd_format_phase_reg /= FDD_FORMAT_IDLE OR
                                    read_job_reg = JOB_FDD_WRITE OR
                                    read_job_reg = JOB_MBR) AND
                                    fdd_format_read_retry_reg < 3 THEN
                                    fdd_format_read_retry_reg <= fdd_format_read_retry_reg + 1;
                                    read_error_code_reg <= x"2";
                                    gap_after_state <= ST_PREP_CMD17;
                                    state <= ST_GAP;
                                ELSIF cfg_request_reg = CFG_REQ_LOAD THEN
                                    save_check_busy_reg <= '0';
                                    save_cache_lookup_active_reg <= '0';
                                    save_verify_pending_reg <= '0';
                                    root_scan_job_reg <= ROOT_SCAN_DISCOVER;
                                    cfg_load_busy_reg <= '0';
                                    cfg_load_error_reg <= '1';
                                    cfg_request_reg <= CFG_REQ_NONE;
                                    read_done_reg <= '1';
                                ELSIF cfg_request_reg = CFG_REQ_SAVE OR save_backend_is_cfg_reg = '1' THEN
                                    save_check_busy_reg <= '0';
                                    save_cache_lookup_active_reg <= '0';
                                    save_verify_pending_reg <= '0';
                                    root_scan_job_reg <= ROOT_SCAN_DISCOVER;
                                    save_write_busy_reg <= '0';
                                    save_write_error_reg <= '1';
                                    save_write_status_reg <= SAVE_STATUS_IO_ERROR;
                                    cfg_save_busy_reg <= '0';
                                    cfg_save_error_reg <= '1';
                                    cfg_request_reg <= CFG_REQ_NONE;
                                    save_backend_is_cfg_reg <= '0';
                                    read_done_reg <= '1';
                                ELSE
                                    read_error_reg <= '1';
                                END IF;
                                IF NOT ((fdd_format_phase_reg /= FDD_FORMAT_IDLE OR
                                    read_job_reg = JOB_FDD_WRITE OR
                                    read_job_reg = JOB_MBR) AND
                                    fdd_format_read_retry_reg < 3) THEN
                                    read_error_code_reg <= x"2";
                                    gap_after_state <= ST_READ_READY;
                                    state <= ST_GAP;
                                END IF;
                            ELSE
                                response_timeout <= response_timeout - 1;
                            END IF;
                        ELSIF byte_busy = '0' THEN
                            queue_byte_v := TRUE;
                            queue_data_v := x"FF";
                        END IF;
                    WHEN ST_WAIT_CMD24_R1 =>
                        cs_n_reg <= '0';
                        IF byte_done_v THEN
                            IF rx_byte_v(7) = '0' THEN
                                last_r1_reg <= rx_byte_v;
                                IF rx_byte_v = x"00" THEN
                                    IF save_sector_source_reg = SAVE_SECTOR_PATCH THEN
                                        -- Patch sectors use a registered BRAM read port.
                                        -- The very first sector byte is held separately so it
                                        -- cannot be lost to BRAM address/latency corner cases.
                                        save_tx_byte_reg <= save_patch_first_byte_reg;
                                        save_patch_rd_addr_reg <= STD_LOGIC_VECTOR(to_unsigned(1, 9));
                                    END IF;
                                    state <= ST_WRITE_DATA_TOKEN;
                                ELSE
                                    save_write_busy_reg <= '0';
                                    save_write_error_reg <= '1';
                                    save_write_status_reg <= SAVE_STATUS_ERR_CMD24_R1;
                                    IF save_backend_is_cfg_reg = '1' THEN
                                        cfg_save_busy_reg <= '0';
                                        cfg_save_error_reg <= '1';
                                        cfg_request_reg <= CFG_REQ_NONE;
                                        save_backend_is_cfg_reg <= '0';
                                    END IF;
                                    gap_after_state <= ST_READ_READY;
                                    state <= ST_GAP;
                                END IF;
                            ELSIF response_timeout = 0 THEN
                                save_write_busy_reg <= '0';
                                save_write_error_reg <= '1';
                                save_write_status_reg <= SAVE_STATUS_ERR_CMD24_TIMEOUT;
                                IF save_backend_is_cfg_reg = '1' THEN
                                    cfg_save_busy_reg <= '0';
                                    cfg_save_error_reg <= '1';
                                    cfg_request_reg <= CFG_REQ_NONE;
                                    save_backend_is_cfg_reg <= '0';
                                END IF;
                                gap_after_state <= ST_READ_READY;
                                state <= ST_GAP;
                            ELSE
                                response_timeout <= response_timeout - 1;
                            END IF;
                        ELSIF byte_busy = '0' THEN
                            queue_byte_v := TRUE;
                            queue_data_v := x"FF";
                        END IF;

                    WHEN ST_WAIT_DATA_TOKEN =>
                        cs_n_reg <= '0';
                        IF byte_done_v THEN
                            IF rx_byte_v = x"FE" THEN
                                read_token_reg <= rx_byte_v;
                                data_bytes_left <= 512;
                                data_index <= 0;
                                state <= ST_READ_DATA;
                            ELSIF rx_byte_v = x"00" THEN
                                IF read_token_timeout = 0 THEN
                                    IF (fdd_format_phase_reg /= FDD_FORMAT_IDLE OR
                                        read_job_reg = JOB_FDD_WRITE OR
                                        read_job_reg = JOB_MBR) AND
                                        fdd_format_read_retry_reg < 3 THEN
                                        fdd_format_read_retry_reg <= fdd_format_read_retry_reg + 1;
                                        read_error_code_reg <= x"4";
                                        gap_after_state <= ST_PREP_CMD17;
                                        state <= ST_GAP;
                                    ELSIF cfg_request_reg = CFG_REQ_LOAD THEN
                                        save_check_busy_reg <= '0';
                                        save_cache_lookup_active_reg <= '0';
                                        save_verify_pending_reg <= '0';
                                        root_scan_job_reg <= ROOT_SCAN_DISCOVER;
                                        cfg_load_busy_reg <= '0';
                                        cfg_load_error_reg <= '1';
                                        cfg_request_reg <= CFG_REQ_NONE;
                                        read_done_reg <= '1';
                                    ELSIF cfg_request_reg = CFG_REQ_SAVE OR save_backend_is_cfg_reg = '1' THEN
                                        save_check_busy_reg <= '0';
                                        save_cache_lookup_active_reg <= '0';
                                        save_verify_pending_reg <= '0';
                                        root_scan_job_reg <= ROOT_SCAN_DISCOVER;
                                        save_write_busy_reg <= '0';
                                        save_write_error_reg <= '1';
                                        save_write_status_reg <= SAVE_STATUS_IO_ERROR;
                                        cfg_save_busy_reg <= '0';
                                        cfg_save_error_reg <= '1';
                                        cfg_request_reg <= CFG_REQ_NONE;
                                        save_backend_is_cfg_reg <= '0';
                                        read_done_reg <= '1';
                                    ELSE
                                        read_error_reg <= '1';
                                    END IF;
                                    IF NOT ((fdd_format_phase_reg /= FDD_FORMAT_IDLE OR
                                        read_job_reg = JOB_FDD_WRITE OR
                                        read_job_reg = JOB_MBR) AND
                                        fdd_format_read_retry_reg < 3) THEN
                                        read_error_code_reg <= x"4";
                                        gap_after_state <= ST_READ_READY;
                                        state <= ST_GAP;
                                    END IF;
                                ELSE
                                    read_token_timeout <= read_token_timeout - 1;
                                END IF;
                            ELSIF rx_byte_v /= x"FF" THEN
                                read_token_reg <= rx_byte_v;
                                IF (fdd_format_phase_reg /= FDD_FORMAT_IDLE OR
                                    read_job_reg = JOB_FDD_WRITE OR
                                    read_job_reg = JOB_MBR) AND
                                    fdd_format_read_retry_reg < 3 THEN
                                    fdd_format_read_retry_reg <= fdd_format_read_retry_reg + 1;
                                    read_error_code_reg <= x"3";
                                    gap_after_state <= ST_PREP_CMD17;
                                    state <= ST_GAP;
                                ELSIF cfg_request_reg = CFG_REQ_LOAD THEN
                                    save_check_busy_reg <= '0';
                                    save_cache_lookup_active_reg <= '0';
                                    save_verify_pending_reg <= '0';
                                    root_scan_job_reg <= ROOT_SCAN_DISCOVER;
                                    cfg_load_busy_reg <= '0';
                                    cfg_load_error_reg <= '1';
                                    cfg_request_reg <= CFG_REQ_NONE;
                                    read_done_reg <= '1';
                                ELSIF cfg_request_reg = CFG_REQ_SAVE OR save_backend_is_cfg_reg = '1' THEN
                                    save_check_busy_reg <= '0';
                                    save_cache_lookup_active_reg <= '0';
                                    save_verify_pending_reg <= '0';
                                    root_scan_job_reg <= ROOT_SCAN_DISCOVER;
                                    save_write_busy_reg <= '0';
                                    save_write_error_reg <= '1';
                                    save_write_status_reg <= SAVE_STATUS_IO_ERROR;
                                    cfg_save_busy_reg <= '0';
                                    cfg_save_error_reg <= '1';
                                    cfg_request_reg <= CFG_REQ_NONE;
                                    save_backend_is_cfg_reg <= '0';
                                    read_done_reg <= '1';
                                ELSE
                                    read_error_reg <= '1';
                                END IF;
                                IF NOT ((fdd_format_phase_reg /= FDD_FORMAT_IDLE OR
                                    read_job_reg = JOB_FDD_WRITE OR
                                    read_job_reg = JOB_MBR) AND
                                    fdd_format_read_retry_reg < 3) THEN
                                    read_error_code_reg <= x"3";
                                    gap_after_state <= ST_READ_READY;
                                    state <= ST_GAP;
                                END IF;
                            ELSIF read_token_timeout = 0 THEN
                                IF (fdd_format_phase_reg /= FDD_FORMAT_IDLE OR
                                    read_job_reg = JOB_FDD_WRITE OR
                                    read_job_reg = JOB_MBR) AND
                                    fdd_format_read_retry_reg < 3 THEN
                                    fdd_format_read_retry_reg <= fdd_format_read_retry_reg + 1;
                                    read_error_code_reg <= x"4";
                                    gap_after_state <= ST_PREP_CMD17;
                                    state <= ST_GAP;
                                ELSIF cfg_request_reg = CFG_REQ_LOAD THEN
                                    save_check_busy_reg <= '0';
                                    save_cache_lookup_active_reg <= '0';
                                    save_verify_pending_reg <= '0';
                                    root_scan_job_reg <= ROOT_SCAN_DISCOVER;
                                    cfg_load_busy_reg <= '0';
                                    cfg_load_error_reg <= '1';
                                    cfg_request_reg <= CFG_REQ_NONE;
                                    read_done_reg <= '1';
                                ELSIF cfg_request_reg = CFG_REQ_SAVE OR save_backend_is_cfg_reg = '1' THEN
                                    save_check_busy_reg <= '0';
                                    save_cache_lookup_active_reg <= '0';
                                    save_verify_pending_reg <= '0';
                                    root_scan_job_reg <= ROOT_SCAN_DISCOVER;
                                    save_write_busy_reg <= '0';
                                    save_write_error_reg <= '1';
                                    save_write_status_reg <= SAVE_STATUS_IO_ERROR;
                                    cfg_save_busy_reg <= '0';
                                    cfg_save_error_reg <= '1';
                                    cfg_request_reg <= CFG_REQ_NONE;
                                    save_backend_is_cfg_reg <= '0';
                                    read_done_reg <= '1';
                                ELSE
                                    read_error_reg <= '1';
                                END IF;
                                IF NOT ((fdd_format_phase_reg /= FDD_FORMAT_IDLE OR
                                    read_job_reg = JOB_FDD_WRITE OR
                                    read_job_reg = JOB_MBR) AND
                                    fdd_format_read_retry_reg < 3) THEN
                                    read_error_code_reg <= x"4";
                                    gap_after_state <= ST_READ_READY;
                                    state <= ST_GAP;
                                END IF;
                            ELSE
                                read_token_timeout <= read_token_timeout - 1;
                            END IF;
                        ELSIF byte_busy = '0' THEN
                            queue_byte_v := TRUE;
                            queue_data_v := x"FF";
                        END IF;

                    WHEN ST_READ_DATA =>
                        cs_n_reg <= '0';
                        IF byte_done_v THEN
                            IF read_job_reg = JOB_MBR THEN
                                CASE data_index IS
                                    WHEN 450 =>
                                        part_type_reg <= rx_byte_v;
                                    WHEN 454 =>
                                        part_lba_reg(7 DOWNTO 0) <= UNSIGNED(rx_byte_v);
                                    WHEN 455 =>
                                        part_lba_reg(15 DOWNTO 8) <= UNSIGNED(rx_byte_v);
                                    WHEN 456 =>
                                        part_lba_reg(23 DOWNTO 16) <= UNSIGNED(rx_byte_v);
                                    WHEN 457 =>
                                        part_lba_reg(31 DOWNTO 24) <= UNSIGNED(rx_byte_v);
                                    WHEN OTHERS =>
                                        NULL;
                                END CASE;
                            ELSIF read_job_reg = JOB_BOOT THEN
                                CASE data_index IS
                                    WHEN 11 =>
                                        boot_bps_reg(7 DOWNTO 0) <= rx_byte_v;
                                    WHEN 12 =>
                                        boot_bps_reg(15 DOWNTO 8) <= rx_byte_v;
                                    WHEN 13 =>
                                        boot_spc_reg <= rx_byte_v;
                                    WHEN 14 =>
                                        boot_reserved_reg(7 DOWNTO 0) <= UNSIGNED(rx_byte_v);
                                    WHEN 15 =>
                                        boot_reserved_reg(15 DOWNTO 8) <= UNSIGNED(rx_byte_v);
                                    WHEN 16 =>
                                        boot_num_fats_reg <= UNSIGNED(rx_byte_v);
                                    WHEN 36 =>
                                        boot_spf_reg(7 DOWNTO 0) <= UNSIGNED(rx_byte_v);
                                    WHEN 37 =>
                                        boot_spf_reg(15 DOWNTO 8) <= UNSIGNED(rx_byte_v);
                                    WHEN 38 =>
                                        boot_spf_reg(23 DOWNTO 16) <= UNSIGNED(rx_byte_v);
                                    WHEN 39 =>
                                        boot_spf_reg(31 DOWNTO 24) <= UNSIGNED(rx_byte_v);
                                    WHEN 44 =>
                                        boot_root_cluster_reg(7 DOWNTO 0) <= rx_byte_v;
                                    WHEN 45 =>
                                        boot_root_cluster_reg(15 DOWNTO 8) <= rx_byte_v;
                                    WHEN 46 =>
                                        boot_root_cluster_reg(23 DOWNTO 16) <= rx_byte_v;
                                    WHEN 47 =>
                                        boot_root_cluster_reg(31 DOWNTO 24) <= rx_byte_v;
                                    WHEN OTHERS =>
                                        NULL;
                                END CASE;
                            ELSIF read_job_reg = JOB_FDD THEN
                                IF (fdd_read_half_reg = '0' AND data_index < 256) OR
                                    (fdd_read_half_reg = '1' AND data_index >= 256) THEN
                                    fdd_sector_buffer_reg(data_index MOD 256) <= rx_byte_v;
                                END IF;
                            ELSIF read_job_reg = JOB_FILE THEN
                                IF file_read_is_cas_reg = '1' THEN
                                    IF file_bytes_left_reg /= 0 THEN
                                        file_bytes_left_reg <= file_bytes_left_reg - 1;

                                        IF file_cas_error_reg = '0' THEN
                                            CASE cas_parse_state_reg IS
                                                WHEN CAS_SYNC_00 =>
                                                    IF rx_byte_v = x"00" THEN
                                                        cas_parse_state_reg <= CAS_SYNC_FF1;
                                                    END IF;

                                                WHEN CAS_SYNC_FF1 =>
                                                    IF rx_byte_v = x"FF" THEN
                                                        cas_parse_state_reg <= CAS_SYNC_FF2;
                                                    ELSIF rx_byte_v /= x"00" THEN
                                                        cas_parse_state_reg <= CAS_SYNC_00;
                                                    END IF;

                                                WHEN CAS_SYNC_FF2 =>
                                                    IF rx_byte_v = x"FF" THEN
                                                        cas_parse_state_reg <= CAS_SYNC_FF3;
                                                    ELSIF rx_byte_v = x"00" THEN
                                                        cas_parse_state_reg <= CAS_SYNC_FF1;
                                                    ELSE
                                                        cas_parse_state_reg <= CAS_SYNC_00;
                                                    END IF;

                                                WHEN CAS_SYNC_FF3 =>
                                                    IF rx_byte_v = x"FF" THEN
                                                        cas_parse_state_reg <= CAS_SYNC_FF4;
                                                    ELSIF rx_byte_v = x"00" THEN
                                                        cas_parse_state_reg <= CAS_SYNC_FF1;
                                                    ELSE
                                                        cas_parse_state_reg <= CAS_SYNC_00;
                                                    END IF;

                                                WHEN CAS_SYNC_FF4 =>
                                                    IF rx_byte_v = x"FF" THEN
                                                        cas_parse_state_reg <= CAS_ADDR_LO;
                                                        cas_header_sum_reg <= (OTHERS => '0');
                                                    ELSIF rx_byte_v = x"00" THEN
                                                        cas_parse_state_reg <= CAS_SYNC_FF1;
                                                    ELSE
                                                        cas_parse_state_reg <= CAS_SYNC_00;
                                                    END IF;

                                                WHEN CAS_ADDR_LO =>
                                                    cas_block_addr_reg(7 DOWNTO 0) <= UNSIGNED(rx_byte_v);
                                                    cas_header_sum_reg <= UNSIGNED(rx_byte_v);
                                                    cas_parse_state_reg <= CAS_ADDR_HI;

                                                WHEN CAS_ADDR_HI =>
                                                    cas_block_addr_reg(15 DOWNTO 8) <= UNSIGNED(rx_byte_v);
                                                    cas_header_sum_reg <= cas_header_sum_reg + UNSIGNED(rx_byte_v);
                                                    cas_parse_state_reg <= CAS_LEN;

                                                WHEN CAS_LEN =>
                                                    cas_block_len_reg <= UNSIGNED(rx_byte_v);
                                                    cas_header_sum_reg <= cas_header_sum_reg + UNSIGNED(rx_byte_v);
                                                    cas_parse_state_reg <= CAS_BLOCK;

                                                WHEN CAS_BLOCK =>
                                                    cas_header_sum_reg <= cas_header_sum_reg + UNSIGNED(rx_byte_v);
                                                    cas_parse_state_reg <= CAS_HDR_CSUM;

                                                WHEN CAS_HDR_CSUM =>
                                                    IF STD_LOGIC_VECTOR(cas_header_sum_reg) = rx_byte_v THEN
                                                        IF cas_block_len_reg = x"00" THEN
                                                            cas_data_left_reg <= 256;
                                                        ELSE
                                                            cas_data_left_reg <= to_integer(cas_block_len_reg);
                                                        END IF;
                                                        cas_buffer_index <= 0;
                                                        cas_data_sum_reg <= (OTHERS => '0');
                                                        cas_parse_state_reg <= CAS_DATA;
                                                    ELSE
                                                        file_cas_error_reg <= '1';
                                                    END IF;

                                                WHEN CAS_DATA =>
                                                    -- Do not modify RAM until the entire block is valid.
                                                    cas_block_buffer(cas_buffer_index) <= rx_byte_v;
                                                    cas_data_sum_reg <= cas_data_sum_reg + UNSIGNED(rx_byte_v);
                                                    IF cas_data_left_reg <= 1 THEN
                                                        cas_data_left_reg <= 0;
                                                        cas_parse_state_reg <= CAS_DATA_CSUM;
                                                    ELSE
                                                        cas_buffer_index <= cas_buffer_index + 1;
                                                        cas_data_left_reg <= cas_data_left_reg - 1;
                                                    END IF;

                                                WHEN CAS_DATA_CSUM =>
                                                    IF STD_LOGIC_VECTOR(cas_data_sum_reg) /= rx_byte_v THEN
                                                        file_cas_error_reg <= '1';
                                                    ELSE
                                                        cas_buffer_index <= 0;
                                                        cas_data_addr_reg <= cas_block_addr_reg;
                                                        IF cas_block_len_reg = x"00" THEN
                                                            cas_data_left_reg <= 256;
                                                        ELSE
                                                            cas_data_left_reg <= to_integer(cas_block_len_reg);
                                                        END IF;
                                                        cas_commit_v := TRUE;
                                                    END IF;
                                                    cas_parse_state_reg <= CAS_SYNC_00;
                                            END CASE;
                                        END IF;
                                    END IF;
                                ELSE
                                    IF file_bytes_left_reg /= 0 THEN
                                        file_bytes_left_reg <= file_bytes_left_reg - 1;

                                        IF rx_byte_v = x"0D" OR rx_byte_v = x"0A" THEN
                                            nas_addr_digits_reg <= 0;
                                            nas_token_digits_reg <= 0;
                                            nas_data_index_reg <= 0;
                                            nas_in_line_reg <= '0';
                                            nas_ignore_line_reg <= '0';
                                        ELSIF nas_ignore_line_reg = '1' THEN
                                            NULL;
                                        ELSIF nas_in_line_reg = '0' THEN
                                            IF is_ascii_hex(rx_byte_v) THEN
                                                nas_in_line_reg <= '1';
                                                nas_addr_digits_reg <= 1;
                                                nas_addr_reg(15 DOWNTO 12) <= ascii_hex_nibble(rx_byte_v);
                                            END IF;
                                        ELSIF nas_addr_digits_reg < 4 THEN
                                            IF is_ascii_hex(rx_byte_v) THEN
                                                CASE nas_addr_digits_reg IS
                                                    WHEN 1 =>
                                                        nas_addr_reg(11 DOWNTO 8) <= ascii_hex_nibble(rx_byte_v);
                                                        nas_addr_digits_reg <= 2;
                                                    WHEN 2 =>
                                                        nas_addr_reg(7 DOWNTO 4) <= ascii_hex_nibble(rx_byte_v);
                                                        nas_addr_digits_reg <= 3;
                                                    WHEN OTHERS =>
                                                        nas_addr_reg(3 DOWNTO 0) <= ascii_hex_nibble(rx_byte_v);
                                                        nas_addr_digits_reg <= 4;
                                                        IF file_load_addr_valid_reg = '0' THEN
                                                            file_load_addr_reg <= nas_addr_reg(15 DOWNTO 4) & ascii_hex_nibble(rx_byte_v);
                                                            file_load_addr_valid_reg <= '1';
                                                        END IF;
                                                END CASE;
                                            ELSE
                                                nas_ignore_line_reg <= '1';
                                            END IF;
                                        ELSIF rx_byte_v = x"20" THEN
                                            IF nas_token_digits_reg = 1 THEN
                                                nas_ignore_line_reg <= '1';
                                            END IF;
                                        ELSIF is_ascii_hex(rx_byte_v) THEN
                                            IF nas_data_index_reg < 8 THEN
                                                IF nas_token_digits_reg = 0 THEN
                                                    nas_token_reg(7 DOWNTO 4) <= ascii_hex_nibble(rx_byte_v);
                                                    nas_token_digits_reg <= 1;
                                                ELSE
                                                    file_write_data_v := nas_token_reg(7 DOWNTO 4) & ascii_hex_nibble(rx_byte_v);
                                                    file_write_addr_v := unsigned(nas_addr_reg) + to_unsigned(nas_data_index_reg, 16);
                                                    file_mem_wr_reg <= '1';
                                                    file_mem_addr_reg <= STD_LOGIC_VECTOR(file_write_addr_v);
                                                    file_mem_data_reg <= file_write_data_v;
                                                    nas_token_reg(3 DOWNTO 0) <= ascii_hex_nibble(rx_byte_v);
                                                    nas_token_digits_reg <= 0;
                                                    IF nas_data_index_reg = 7 THEN
                                                        nas_ignore_line_reg <= '1';
                                                    ELSE
                                                        nas_data_index_reg <= nas_data_index_reg + 1;
                                                    END IF;
                                                END IF;
                                            ELSE
                                                nas_ignore_line_reg <= '1';
                                            END IF;
                                        ELSE
                                            nas_ignore_line_reg <= '1';
                                        END IF;
                                    END IF;
                                END IF;
                            ELSE
                                NULL;
                            END IF;

                            IF read_job_reg = JOB_PATCH OR read_job_reg = JOB_MANAGE_FAT OR
                                read_job_reg = JOB_FDD_WRITE THEN
                                save_patch_wr_en_reg <= '1';
                                save_patch_wr_addr_reg <= STD_LOGIC_VECTOR(to_unsigned(data_index, 9));
                                save_patch_wr_data_reg <= rx_byte_v;
                                IF data_index = 0 THEN
                                    save_patch_first_byte_reg <= rx_byte_v;
                                END IF;
                            END IF;

                            IF read_job_reg = JOB_MANAGE_FAT THEN
                                IF data_index = manage_fat_offset_reg THEN
                                    manage_next_cluster_reg(7 DOWNTO 0) <= UNSIGNED(rx_byte_v);
                                ELSIF data_index = manage_fat_offset_reg + 1 THEN
                                    manage_next_cluster_reg(15 DOWNTO 8) <= UNSIGNED(rx_byte_v);
                                ELSIF data_index = manage_fat_offset_reg + 2 THEN
                                    manage_next_cluster_reg(23 DOWNTO 16) <= UNSIGNED(rx_byte_v);
                                ELSIF data_index = manage_fat_offset_reg + 3 THEN
                                    manage_next_cluster_reg(31 DOWNTO 28) <= (OTHERS => '0');
                                    manage_next_cluster_reg(27 DOWNTO 24) <= UNSIGNED(rx_byte_v(3 DOWNTO 0));
                                END IF;
                            END IF;

                            IF read_job_reg = JOB_CFG THEN
                                CASE data_index IS
                                    WHEN 4 =>
                                        cfg_parse_byte4_reg <= rx_byte_v;
                                    WHEN 5 =>
                                        cfg_parse_byte5_reg <= rx_byte_v;
                                    WHEN 6 =>
                                        cfg_parse_byte6_reg <= rx_byte_v;
                                    WHEN 7 =>
                                        cfg_parse_byte7_reg <= rx_byte_v;
                                    WHEN 8 =>
                                        cfg_parse_byte8_reg <= rx_byte_v;
                                    WHEN 9 =>
                                        cfg_parse_byte9_reg <= rx_byte_v;
                                    WHEN 10 =>
                                        cfg_parse_network_payload_reg(135 DOWNTO 128) <= rx_byte_v;
                                    WHEN 11 => cfg_parse_network_payload_reg(127 DOWNTO 120) <= rx_byte_v;
                                    WHEN 12 => cfg_parse_network_payload_reg(119 DOWNTO 112) <= rx_byte_v;
                                    WHEN 13 => cfg_parse_network_payload_reg(111 DOWNTO 104) <= rx_byte_v;
                                    WHEN 14 =>
                                        cfg_parse_byte14_reg <= rx_byte_v;
                                        cfg_parse_network_payload_reg(103 DOWNTO 96) <= rx_byte_v;
                                    WHEN 15 => cfg_parse_network_payload_reg(95 DOWNTO 88) <= rx_byte_v;
                                    WHEN 16 => cfg_parse_network_payload_reg(87 DOWNTO 80) <= rx_byte_v;
                                    WHEN 17 => cfg_parse_network_payload_reg(79 DOWNTO 72) <= rx_byte_v;
                                    WHEN 18 => cfg_parse_network_payload_reg(71 DOWNTO 64) <= rx_byte_v;
                                    WHEN 19 => cfg_parse_network_payload_reg(63 DOWNTO 56) <= rx_byte_v;
                                    WHEN 20 => cfg_parse_network_payload_reg(55 DOWNTO 48) <= rx_byte_v;
                                    WHEN 21 => cfg_parse_network_payload_reg(47 DOWNTO 40) <= rx_byte_v;
                                    WHEN 22 => cfg_parse_network_payload_reg(39 DOWNTO 32) <= rx_byte_v;
                                    WHEN 23 => cfg_parse_network_payload_reg(31 DOWNTO 24) <= rx_byte_v;
                                    WHEN 24 => cfg_parse_network_payload_reg(23 DOWNTO 16) <= rx_byte_v;
                                    WHEN 25 => cfg_parse_network_payload_reg(15 DOWNTO 8) <= rx_byte_v;
                                    WHEN 26 => cfg_parse_network_payload_reg(7 DOWNTO 0) <= rx_byte_v;
                                    WHEN 30 => cfg_parse_byte30_reg <= rx_byte_v;
                                    WHEN OTHERS =>
                                        NULL;
                                END CASE;
                            END IF;

                            IF read_job_reg = JOB_ROOT_FAT THEN
                                IF data_index = root_fat_byte_offset_reg THEN
                                    root_next_cluster_reg(7 DOWNTO 0) <= UNSIGNED(rx_byte_v);
                                ELSIF data_index = root_fat_byte_offset_reg + 1 THEN
                                    root_next_cluster_reg(15 DOWNTO 8) <= UNSIGNED(rx_byte_v);
                                ELSIF data_index = root_fat_byte_offset_reg + 2 THEN
                                    root_next_cluster_reg(23 DOWNTO 16) <= UNSIGNED(rx_byte_v);
                                ELSIF data_index = root_fat_byte_offset_reg + 3 THEN
                                    root_next_cluster_reg(31 DOWNTO 24) <= UNSIGNED(rx_byte_v);
                                END IF;
                            END IF;

                            IF read_job_reg = JOB_FAT THEN
                                CASE data_index MOD 4 IS
                                    WHEN 0 =>
                                        fat_entry_tmp_reg(7 DOWNTO 0) <= rx_byte_v;
                                    WHEN 1 =>
                                        fat_entry_tmp_reg(15 DOWNTO 8) <= rx_byte_v;
                                    WHEN 2 =>
                                        fat_entry_tmp_reg(23 DOWNTO 16) <= rx_byte_v;
                                    WHEN OTHERS =>
                                        fat_entry_tmp_reg(31 DOWNTO 24) <= rx_byte_v;
                                        IF save_check_can_allocate_reg = '0' AND
                                            fat_scan_cluster_reg >= fat_scan_min_cluster_reg THEN
                                            IF UNSIGNED(rx_byte_v) = to_unsigned(0, 8) AND
                                                UNSIGNED(fat_entry_tmp_reg(23 DOWNTO 0)) = to_unsigned(0, 24) THEN
                                                IF fat_scan_run_len_reg = to_unsigned(0, 16) THEN
                                                    fat_scan_run_start_reg <= fat_scan_cluster_reg;
                                                    fat_scan_run_len_reg <= to_unsigned(1, 16);
                                                    IF save_alloc_search_need_reg = to_unsigned(1, 16) THEN
                                                        save_check_can_allocate_reg <= '1';
                                                        save_check_free_cluster_reg <= fat_scan_cluster_reg;
                                                    END IF;
                                                ELSE
                                                    fat_scan_run_len_reg <= fat_scan_run_len_reg + 1;
                                                    IF fat_scan_run_len_reg + 1 >= save_alloc_search_need_reg THEN
                                                        save_check_can_allocate_reg <= '1';
                                                        save_check_free_cluster_reg <= fat_scan_run_start_reg;
                                                    END IF;
                                                END IF;
                                            ELSE
                                                fat_scan_run_len_reg <= (OTHERS => '0');
                                            END IF;
                                        END IF;
                                        fat_scan_cluster_reg <= fat_scan_cluster_reg + 1;
                                END CASE;
                            END IF;

                            -- Hier wird das ROOT-Directory gelesen
                            IF read_job_reg = JOB_ROOT THEN
                                IF data_index = 0 THEN
                                    root_sector_first_byte_reg <= rx_byte_v;
                                END IF;
                                IF save_verify_pending_reg = '1' AND
                                    current_lba_reg = save_verify_dir_lba_reg AND
                                    data_index = 0 AND
                                    rx_byte_v /= save_verify_dir_first_byte_reg THEN
                                    save_verify_dir_byte_ok_reg <= '0';
                                END IF;
                                CASE data_index MOD 32 IS
                                    WHEN 0 =>
                                        dir_entry_name_tmp_reg(87 DOWNTO 80) <= rx_byte_v;
                                        dir_entry_attr_tmp_reg <= x"00";
                                        dir_entry_cluster_tmp_reg <= (OTHERS => '0');
                                        dir_entry_size_tmp_reg <= (OTHERS => '0');
                                        IF rx_byte_v = x"00" THEN
                                            root_end_seen_reg <= '1';
                                        END IF;
                                    WHEN 1 =>
                                        dir_entry_name_tmp_reg(79 DOWNTO 72) <= rx_byte_v;
                                    WHEN 2 =>
                                        dir_entry_name_tmp_reg(71 DOWNTO 64) <= rx_byte_v;
                                    WHEN 3 =>
                                        dir_entry_name_tmp_reg(63 DOWNTO 56) <= rx_byte_v;
                                    WHEN 4 =>
                                        dir_entry_name_tmp_reg(55 DOWNTO 48) <= rx_byte_v;
                                    WHEN 5 =>
                                        dir_entry_name_tmp_reg(47 DOWNTO 40) <= rx_byte_v;
                                    WHEN 6 =>
                                        dir_entry_name_tmp_reg(39 DOWNTO 32) <= rx_byte_v;
                                    WHEN 7 =>
                                        dir_entry_name_tmp_reg(31 DOWNTO 24) <= rx_byte_v;
                                    WHEN 8 =>
                                        dir_entry_name_tmp_reg(23 DOWNTO 16) <= rx_byte_v;
                                    WHEN 9 =>
                                        dir_entry_name_tmp_reg(15 DOWNTO 8) <= rx_byte_v;
                                    WHEN 10 =>
                                        dir_entry_name_tmp_reg(7 DOWNTO 0) <= rx_byte_v;
                                    WHEN 11 =>
                                        dir_entry_attr_tmp_reg <= rx_byte_v;
                                    WHEN 20 =>
                                        dir_entry_cluster_tmp_reg(23 DOWNTO 16) <= UNSIGNED(rx_byte_v);
                                    WHEN 21 =>
                                        dir_entry_cluster_tmp_reg(31 DOWNTO 28) <= (OTHERS => '0');
                                        dir_entry_cluster_tmp_reg(27 DOWNTO 24) <= UNSIGNED(rx_byte_v(3 DOWNTO 0));
                                    WHEN 26 =>
                                        dir_entry_cluster_tmp_reg(7 DOWNTO 0) <= UNSIGNED(rx_byte_v);
                                    WHEN 27 =>
                                        dir_entry_cluster_tmp_reg(15 DOWNTO 8) <= UNSIGNED(rx_byte_v);
                                    WHEN 28 =>
                                        dir_entry_size_tmp_reg(7 DOWNTO 0) <= UNSIGNED(rx_byte_v);
                                    WHEN 29 =>
                                        dir_entry_size_tmp_reg(15 DOWNTO 8) <= UNSIGNED(rx_byte_v);
                                    WHEN 30 =>
                                        dir_entry_size_tmp_reg(23 DOWNTO 16) <= UNSIGNED(rx_byte_v);
                                    WHEN 31 =>
                                        dir_entry_size_tmp_reg(31 DOWNTO 24) <= UNSIGNED(rx_byte_v);
                                        IF root_scan_phase_reg = ROOT_SCAN_FIND_DIR THEN
                                            IF dir_entry_name_tmp_reg(87 DOWNTO 80) /= x"00" AND
                                                dir_entry_name_tmp_reg(87 DOWNTO 80) /= x"E5" AND
                                                dir_entry_attr_tmp_reg /= x"0F" AND
                                                dir_entry_attr_tmp_reg(4) = '1' AND
                                                dir_entry_attr_tmp_reg(3) = '0' AND
                                                dir_entry_name_tmp_reg = x"4E4153434F4D3220202020" THEN
                                                browser_dir_found_reg <= '1';
                                                browser_dir_cluster_reg <= dir_entry_cluster_tmp_reg;
                                            END IF;
                                        ELSE
                                            IF root_scan_job_reg = ROOT_SCAN_MANAGE THEN
                                                IF dir_entry_name_tmp_reg(87 DOWNTO 80) /= x"00" AND
                                                    dir_entry_name_tmp_reg(87 DOWNTO 80) /= x"E5" AND
                                                    dir_entry_attr_tmp_reg = x"0F" THEN
                                                    manage_prev_lfn_reg <= '1';
                                                ELSE
                                                    IF dir_entry_name_tmp_reg(87 DOWNTO 80) /= x"00" AND
                                                        dir_entry_name_tmp_reg(87 DOWNTO 80) /= x"E5" AND
                                                        dir_entry_attr_tmp_reg /= x"0F" AND
                                                        dir_entry_attr_tmp_reg(4) = '0' AND
                                                        dir_entry_attr_tmp_reg(3) = '0' THEN
                                                        IF dir_entry_name_tmp_reg = manage_old_name_reg THEN
                                                            manage_found_reg <= '1';
                                                            manage_lfn_reg <= manage_prev_lfn_reg;
                                                            manage_read_only_reg <= dir_entry_attr_tmp_reg(0);
                                                            manage_match_lba_reg <= current_lba_reg;
                                                            manage_match_slot_reg <= data_index / 32;
                                                            manage_cluster_reg <= dir_entry_cluster_tmp_reg;
                                                            IF data_index / 32 = 0 THEN
                                                                manage_match_first_byte_reg <= dir_entry_name_tmp_reg(87 DOWNTO 80);
                                                            ELSE
                                                                manage_match_first_byte_reg <= root_sector_first_byte_reg;
                                                            END IF;
                                                        END IF;
                                                        IF manage_delete_reg = '0' AND
                                                            manage_new_name_reg /= manage_old_name_reg AND
                                                            dir_entry_name_tmp_reg = manage_new_name_reg THEN
                                                            manage_duplicate_reg <= '1';
                                                        END IF;
                                                    END IF;
                                                    manage_prev_lfn_reg <= '0';
                                                END IF;
                                            END IF;

                                            IF root_scan_job_reg = ROOT_SCAN_SAVE_CHECK AND
                                                save_check_can_create_reg = '0' AND
                                                save_check_exists_reg = '0' AND
                                                (dir_entry_name_tmp_reg(87 DOWNTO 80) = x"E5" OR dir_entry_name_tmp_reg(87 DOWNTO 80) = x"00") THEN
                                                save_check_can_create_reg <= '1';
                                                save_check_dir_full_reg <= '0';
                                                save_check_free_lba_reg <= current_lba_reg;
                                                save_check_free_slot_reg <= data_index / 32;
                                                save_check_free_marker_reg <= dir_entry_name_tmp_reg(87 DOWNTO 80);
                                                save_check_free_sector_first_byte_reg <= root_sector_first_byte_reg;
                                                -- Consuming the final $00 entry
                                                -- does not require extending the
                                                -- FAT directory chain.  A full
                                                -- directory cluster without a
                                                -- following $00 end marker is a
                                                -- valid FAT directory.
                                                save_check_requires_dir_growth_reg <= '0';
                                            END IF;

                                            IF root_scan_job_reg = ROOT_SCAN_DISCOVER AND
                                                cached_free_valid_reg = '0' AND
                                                (dir_entry_name_tmp_reg(87 DOWNTO 80) = x"E5" OR dir_entry_name_tmp_reg(87 DOWNTO 80) = x"00") THEN
                                                cached_free_valid_reg <= '1';
                                                cached_free_lba_reg <= current_lba_reg;
                                                cached_free_slot_reg <= data_index / 32;
                                                cached_free_marker_reg <= dir_entry_name_tmp_reg(87 DOWNTO 80);
                                                cached_free_sector_first_byte_reg <= root_sector_first_byte_reg;
                                                cached_free_requires_dir_growth_reg <= '0';
                                            END IF;

                                            IF dir_entry_name_tmp_reg(87 DOWNTO 80) /= x"00" AND
                                                dir_entry_name_tmp_reg(87 DOWNTO 80) /= x"E5" AND
                                                dir_entry_attr_tmp_reg /= x"0F" AND
                                                dir_entry_attr_tmp_reg(4) = '0' AND
                                                dir_entry_attr_tmp_reg(3) = '0' THEN
                                                IF root_scan_job_reg = ROOT_SCAN_SAVE_CHECK THEN
                                                    IF dir_entry_name_tmp_reg = save_check_name_reg THEN
                                                        IF cfg_request_reg /= CFG_REQ_NONE AND save_check_name_reg = CONFIG_SHORT_NAME THEN
                                                            IF save_check_exists_reg = '0' OR
                                                                (save_check_size_reg < CONFIG_STREAM_LEN AND
                                                                (UNSIGNED(rx_byte_v) & dir_entry_size_tmp_reg(23 DOWNTO 0)) >= CONFIG_STREAM_LEN) OR
                                                                (save_check_size_reg < CONFIG_STREAM_LEN_RS232 AND
                                                                save_check_size_reg < CONFIG_STREAM_LEN AND
                                                                (UNSIGNED(rx_byte_v) & dir_entry_size_tmp_reg(23 DOWNTO 0)) >= CONFIG_STREAM_LEN_RS232 AND
                                                                (UNSIGNED(rx_byte_v) & dir_entry_size_tmp_reg(23 DOWNTO 0)) < CONFIG_STREAM_LEN) OR
                                                                (save_check_size_reg < CONFIG_STREAM_LEN_OLD AND
                                                                save_check_size_reg < CONFIG_STREAM_LEN_RS232 AND
                                                                (UNSIGNED(rx_byte_v) & dir_entry_size_tmp_reg(23 DOWNTO 0)) >= CONFIG_STREAM_LEN_OLD AND
                                                                (UNSIGNED(rx_byte_v) & dir_entry_size_tmp_reg(23 DOWNTO 0)) < CONFIG_STREAM_LEN_RS232) THEN
                                                                save_check_exists_reg <= '1';
                                                                save_check_can_create_reg <= '0';
                                                                save_check_dir_full_reg <= '0';
                                                                save_check_requires_dir_growth_reg <= '0';
                                                                save_check_cluster_reg <= dir_entry_cluster_tmp_reg;
                                                                save_check_size_reg <= UNSIGNED(rx_byte_v) & dir_entry_size_tmp_reg(23 DOWNTO 0);
                                                                save_check_match_lba_reg <= current_lba_reg;
                                                                save_check_match_slot_reg <= data_index / 32;
                                                                IF data_index / 32 = 0 THEN
                                                                    save_check_match_sector_first_byte_reg <= dir_entry_name_tmp_reg(87 DOWNTO 80);
                                                                ELSE
                                                                    save_check_match_sector_first_byte_reg <= root_sector_first_byte_reg;
                                                                END IF;
                                                            END IF;
                                                        ELSE
                                                            save_check_exists_reg <= '1';
                                                            save_check_can_create_reg <= '0';
                                                            save_check_dir_full_reg <= '0';
                                                            save_check_requires_dir_growth_reg <= '0';
                                                            save_check_cluster_reg <= dir_entry_cluster_tmp_reg;
                                                            save_check_size_reg <= UNSIGNED(rx_byte_v) & dir_entry_size_tmp_reg(23 DOWNTO 0);
                                                            save_check_match_lba_reg <= current_lba_reg;
                                                            save_check_match_slot_reg <= data_index / 32;
                                                            IF data_index / 32 = 0 THEN
                                                                save_check_match_sector_first_byte_reg <= dir_entry_name_tmp_reg(87 DOWNTO 80);
                                                            ELSE
                                                                save_check_match_sector_first_byte_reg <= root_sector_first_byte_reg;
                                                            END IF;
                                                        END IF;
                                                    END IF;
                                                ELSIF (root_scan_job_reg = ROOT_SCAN_DISCOVER OR
                                                    root_scan_job_reg = ROOT_SCAN_PAGE_RELOAD) AND
                                                    (dir_entry_name_tmp_reg(23 DOWNTO 0) = x"4E4153" OR
                                                     dir_entry_name_tmp_reg(23 DOWNTO 0) = x"434153" OR
                                                     (browser_include_pas = '1' AND
                                                      dir_entry_name_tmp_reg(23 DOWNTO 0) = x"504153") OR
                                                     (browser_include_dsk = '1' AND
                                                      dir_entry_name_tmp_reg(23 DOWNTO 0) = x"44534B")) THEN
                                                    IF browser_page_reload_reg = '1' THEN
                                                        IF reload_match_index_reg >= page_loaded_base_reg AND
                                                            reload_match_index_reg < page_loaded_base_reg + SD_BROWSER_PAGE_SIZE THEN
                                                            CASE reload_match_index_reg - page_loaded_base_reg IS
                                                                WHEN 0 =>
                                                                    page_valid_reg(0) <= '1';
                                                                    page_name_reg(0) <= dir_entry_name_tmp_reg;
                                                                    page_cluster_reg(0) <= STD_LOGIC_VECTOR(dir_entry_cluster_tmp_reg);
                                                                    page_size_reg(0) <= STD_LOGIC_VECTOR(UNSIGNED(rx_byte_v) & dir_entry_size_tmp_reg(23 DOWNTO 0));
                                                                WHEN 1 =>
                                                                    page_valid_reg(1) <= '1';
                                                                    page_name_reg(1) <= dir_entry_name_tmp_reg;
                                                                    page_cluster_reg(1) <= STD_LOGIC_VECTOR(dir_entry_cluster_tmp_reg);
                                                                    page_size_reg(1) <= STD_LOGIC_VECTOR(UNSIGNED(rx_byte_v) & dir_entry_size_tmp_reg(23 DOWNTO 0));
                                                                WHEN 2 =>
                                                                    page_valid_reg(2) <= '1';
                                                                    page_name_reg(2) <= dir_entry_name_tmp_reg;
                                                                    page_cluster_reg(2) <= STD_LOGIC_VECTOR(dir_entry_cluster_tmp_reg);
                                                                    page_size_reg(2) <= STD_LOGIC_VECTOR(UNSIGNED(rx_byte_v) & dir_entry_size_tmp_reg(23 DOWNTO 0));
                                                                WHEN 3 =>
                                                                    page_valid_reg(3) <= '1';
                                                                    page_name_reg(3) <= dir_entry_name_tmp_reg;
                                                                    page_cluster_reg(3) <= STD_LOGIC_VECTOR(dir_entry_cluster_tmp_reg);
                                                                    page_size_reg(3) <= STD_LOGIC_VECTOR(UNSIGNED(rx_byte_v) & dir_entry_size_tmp_reg(23 DOWNTO 0));
                                                                WHEN 4 =>
                                                                    page_valid_reg(4) <= '1';
                                                                    page_name_reg(4) <= dir_entry_name_tmp_reg;
                                                                    page_cluster_reg(4) <= STD_LOGIC_VECTOR(dir_entry_cluster_tmp_reg);
                                                                    page_size_reg(4) <= STD_LOGIC_VECTOR(UNSIGNED(rx_byte_v) & dir_entry_size_tmp_reg(23 DOWNTO 0));
                                                                WHEN 5 =>
                                                                    page_valid_reg(5) <= '1';
                                                                    page_name_reg(5) <= dir_entry_name_tmp_reg;
                                                                    page_cluster_reg(5) <= STD_LOGIC_VECTOR(dir_entry_cluster_tmp_reg);
                                                                    page_size_reg(5) <= STD_LOGIC_VECTOR(UNSIGNED(rx_byte_v) & dir_entry_size_tmp_reg(23 DOWNTO 0));
                                                                WHEN 6 =>
                                                                    page_valid_reg(6) <= '1';
                                                                    page_name_reg(6) <= dir_entry_name_tmp_reg;
                                                                    page_cluster_reg(6) <= STD_LOGIC_VECTOR(dir_entry_cluster_tmp_reg);
                                                                    page_size_reg(6) <= STD_LOGIC_VECTOR(UNSIGNED(rx_byte_v) & dir_entry_size_tmp_reg(23 DOWNTO 0));
                                                                WHEN 7 =>
                                                                    page_valid_reg(7) <= '1';
                                                                    page_name_reg(7) <= dir_entry_name_tmp_reg;
                                                                    page_cluster_reg(7) <= STD_LOGIC_VECTOR(dir_entry_cluster_tmp_reg);
                                                                    page_size_reg(7) <= STD_LOGIC_VECTOR(UNSIGNED(rx_byte_v) & dir_entry_size_tmp_reg(23 DOWNTO 0));
                                                                WHEN 8 =>
                                                                    page_valid_reg(8) <= '1';
                                                                    page_name_reg(8) <= dir_entry_name_tmp_reg;
                                                                    page_cluster_reg(8) <= STD_LOGIC_VECTOR(dir_entry_cluster_tmp_reg);
                                                                    page_size_reg(8) <= STD_LOGIC_VECTOR(UNSIGNED(rx_byte_v) & dir_entry_size_tmp_reg(23 DOWNTO 0));
                                                                WHEN 9 =>
                                                                    page_valid_reg(9) <= '1';
                                                                    page_name_reg(9) <= dir_entry_name_tmp_reg;
                                                                    page_cluster_reg(9) <= STD_LOGIC_VECTOR(dir_entry_cluster_tmp_reg);
                                                                    page_size_reg(9) <= STD_LOGIC_VECTOR(UNSIGNED(rx_byte_v) & dir_entry_size_tmp_reg(23 DOWNTO 0));
                                                                WHEN OTHERS =>
                                                                    NULL;
                                                            END CASE;
                                                        END IF;

                                                        IF reload_match_index_reg < SD_BROWSER_MAX_FILES THEN
                                                            reload_match_index_reg <= reload_match_index_reg + 1;
                                                        END IF;
                                                    ELSE
                                                        IF root_total_file_count_reg < 255 THEN
                                                            file_name_reg(root_total_file_count_reg) <= dir_entry_name_tmp_reg;
                                                            file_cluster_reg(root_total_file_count_reg) <= STD_LOGIC_VECTOR(dir_entry_cluster_tmp_reg);
                                                            file_size_reg(root_total_file_count_reg) <= STD_LOGIC_VECTOR(UNSIGNED(rx_byte_v) & dir_entry_size_tmp_reg(23 DOWNTO 0));
                                                            file_kind_reg(root_total_file_count_reg) <= SD_DSK_KIND_UNKNOWN;
                                                            root_total_file_count_reg <= root_total_file_count_reg + 1;
                                                            root_file_count_reg <= root_file_count_reg + 1;
                                                        END IF;
                                                    END IF;
                                                END IF;
                                            END IF;
                                        END IF;
                                    WHEN OTHERS =>
                                        NULL;
                                END CASE;
                            END IF;

                            CASE data_index IS
                                WHEN 0 =>
                                    read_first_word_reg(31 DOWNTO 24) <= rx_byte_v;
                                WHEN 1 =>
                                    read_first_word_reg(23 DOWNTO 16) <= rx_byte_v;
                                WHEN 2 =>
                                    read_first_word_reg(15 DOWNTO 8) <= rx_byte_v;
                                WHEN 3 =>
                                    read_first_word_reg(7 DOWNTO 0) <= rx_byte_v;
                                WHEN 510 =>
                                    read_signature_reg(15 DOWNTO 8) <= rx_byte_v;
                                WHEN 511 =>
                                    read_signature_reg(7 DOWNTO 0) <= rx_byte_v;
                                WHEN OTHERS =>
                                    NULL;
                            END CASE;

                            read_byte_count_reg <= read_byte_count_reg + 1;

                            IF data_bytes_left = 1 THEN
                                state <= ST_READ_CRC1;
                            ELSE
                                data_bytes_left <= data_bytes_left - 1;
                                data_index <= data_index + 1;
                            END IF;
                            IF cas_commit_v THEN
                                IF data_bytes_left = 1 THEN
                                    cas_resume_state <= ST_READ_CRC1;
                                ELSE
                                    cas_resume_state <= ST_READ_DATA;
                                END IF;
                                state <= ST_CAS_COMMIT;
                            END IF;
                        ELSIF byte_busy = '0' THEN
                            queue_byte_v := TRUE;
                            queue_data_v := x"FF";
                        END IF;

                    WHEN ST_CAS_COMMIT =>
                        -- Pause SPI with CS asserted while committing a checked block.
                        cs_n_reg <= '0';
                        file_mem_wr_reg <= '1';
                        file_mem_addr_reg <= STD_LOGIC_VECTOR(cas_data_addr_reg);
                        file_mem_data_reg <= cas_block_buffer(cas_buffer_index);
                        IF file_load_addr_valid_reg = '0' THEN
                            file_load_addr_reg <= STD_LOGIC_VECTOR(cas_block_addr_reg);
                            file_load_addr_valid_reg <= '1';
                        END IF;
                        cas_data_addr_reg <= cas_data_addr_reg + 1;
                        IF cas_data_left_reg = 1 THEN
                            cas_data_left_reg <= 0;
                            state <= cas_resume_state;
                        ELSE
                            cas_data_left_reg <= cas_data_left_reg - 1;
                            cas_buffer_index <= cas_buffer_index + 1;
                        END IF;

                    WHEN ST_READ_CRC1 =>
                        cs_n_reg <= '0';
                        IF byte_done_v THEN
                            state <= ST_READ_CRC2;
                        ELSIF byte_busy = '0' THEN
                            queue_byte_v := TRUE;
                            queue_data_v := x"FF";
                        END IF;

                    WHEN ST_READ_CRC2 =>
                        cs_n_reg <= '0';
                        IF byte_done_v THEN
                            fdd_format_read_retry_reg <= 0;
                            IF read_job_reg = JOB_FDD THEN
                                fdd_read_busy_reg <= '0';
                                fdd_read_done_reg <= '1';
                                read_done_reg <= '1';
                                gap_after_state <= ST_READ_READY;
                                state <= ST_GAP;
                            ELSIF read_job_reg = JOB_FDD_WRITE THEN
                                fdd_write_patch_index_reg <= 0;
                                gap_after_state <= ST_FDD_PATCH_SECTOR;
                                state <= ST_GAP;
                            ELSIF read_job_reg = JOB_PATCH THEN
                                save_patch_step_reg <= 0;
                                gap_after_state <= ST_SAVE_PATCH_SECTOR;
                                state <= ST_GAP;
                            ELSIF read_job_reg = JOB_MANAGE_FAT THEN
                                save_patch_step_reg <= 0;
                                gap_after_state <= ST_SAVE_PATCH_SECTOR;
                                state <= ST_GAP;
                            ELSIF read_job_reg = JOB_DSK_PROBE THEN
                                IF read_first_word_reg(31 DOWNTO 8) = x"4E4342" THEN
                                    file_kind_reg(dsk_probe_index_reg) <= SD_DSK_KIND_CPM;
                                ELSE
                                    file_kind_reg(dsk_probe_index_reg) <= SD_DSK_KIND_NASSYS;
                                END IF;
                                IF dsk_probe_index_reg < SD_BROWSER_MAX_FILES THEN
                                    dsk_probe_index_reg <= dsk_probe_index_reg + 1;
                                END IF;
                                gap_after_state <= ST_READ_READY;
                                state <= ST_GAP;
                            ELSIF read_job_reg = JOB_MBR THEN
                                IF read_signature_reg = x"55AA" AND part_lba_reg /= to_unsigned(0, part_lba_reg'LENGTH) THEN
                                    current_lba_reg <= part_lba_reg;
                                    read_job_reg <= JOB_BOOT;
                                    gap_after_state <= ST_PREP_CMD17;
                                    state <= ST_GAP;
                                ELSE
                                    read_error_reg <= '1';
                                    read_error_code_reg <= x"5";
                                    gap_after_state <= ST_READ_READY;
                                    state <= ST_GAP;
                                END IF;

                            ELSIF read_job_reg = JOB_BOOT THEN
                                IF read_signature_reg = x"55AA" AND
                                    boot_bps_reg = x"0200" AND
                                    boot_spc_reg /= x"00" AND
                                    boot_num_fats_reg /= to_unsigned(0, 8) AND
                                    boot_reserved_reg /= to_unsigned(0, 16) AND
                                    boot_spf_reg /= to_unsigned(0, 32) AND
                                    UNSIGNED(boot_root_cluster_reg) >= to_unsigned(2, 32) THEN

                                    lba_target_reg <= LBA_TARGET_ROOT;
                                    lba_cluster_reg <= UNSIGNED(boot_root_cluster_reg);
                                    root_current_cluster_reg <= UNSIGNED(boot_root_cluster_reg);
                                    root_chain_advance_reg <= '0';
                                    browser_dir_found_reg <= '0';
                                    browser_dir_cluster_reg <= (OTHERS => '0');
                                    browser_page_reload_reg <= '0';
                                    reload_match_index_reg <= 0;
                                    root_scan_phase_reg <= ROOT_SCAN_FIND_DIR;
                                    root_scan_job_reg <= ROOT_SCAN_DISCOVER;

                                    gap_after_state <= ST_CALC_LBA_BASE;
                                    state <= ST_GAP;
                                ELSE
                                    read_error_reg <= '1';
                                    read_error_code_reg <= x"5";
                                    gap_after_state <= ST_READ_READY;
                                    state <= ST_GAP;
                                END IF;

                            ELSIF read_job_reg = JOB_ROOT THEN
                                IF root_scan_phase_reg = ROOT_SCAN_FIND_DIR THEN
                                    IF browser_dir_found_reg = '1' THEN
                                        lba_target_reg <= LBA_TARGET_ROOT;
                                        lba_cluster_reg <= browser_dir_cluster_reg;
                                        root_current_cluster_reg <= browser_dir_cluster_reg;
                                        root_chain_advance_reg <= '0';
                                        root_scan_phase_reg <= ROOT_SCAN_LIST_FILES;
                                        gap_after_state <= ST_CALC_LBA_BASE;
                                        state <= ST_GAP;
                                    ELSIF root_end_seen_reg = '1' THEN
                                        browser_page_reload_reg <= '0';
                                        browser_page_dirty_reg <= '0';
                                        read_done_reg <= '1';
                                        gap_after_state <= ST_READ_READY;
                                        state <= ST_GAP;
                                    ELSIF root_sectors_left_reg = 1 THEN
                                        read_job_reg <= JOB_ROOT_FAT;
                                        root_next_cluster_reg <= (OTHERS => '0');
                                        root_fat_byte_offset_reg <= to_integer(root_current_cluster_reg(6 DOWNTO 0)) * 4;
                                        current_lba_reg <= part_lba_reg + resize(boot_reserved_reg, 32) + resize(shift_right(root_current_cluster_reg, 7), 32);
                                        gap_after_state <= ST_PREP_CMD17;
                                        state <= ST_GAP;
                                    ELSE
                                        IF root_sectors_left_reg > 1 THEN
                                            current_lba_reg <= current_lba_reg + 1;
                                            root_sectors_left_reg <= root_sectors_left_reg - 1;
                                            gap_after_state <= ST_PREP_CMD17;
                                            state <= ST_GAP;
                                        ELSE
                                            state <= ST_FINISH_ROOT_SCAN;
                                        END IF;
                                    END IF;
                                ELSIF root_end_seen_reg = '1' THEN
                                    state <= ST_FINISH_ROOT_SCAN;
                                ELSIF root_sectors_left_reg = 1 THEN
                                    read_job_reg <= JOB_ROOT_FAT;
                                    root_next_cluster_reg <= (OTHERS => '0');
                                    root_fat_byte_offset_reg <= to_integer(root_current_cluster_reg(6 DOWNTO 0)) * 4;
                                    current_lba_reg <=
                                        part_lba_reg +
                                        resize(boot_reserved_reg, 32) +
                                        resize(shift_right(root_current_cluster_reg, 7), 32);
                                    gap_after_state <= ST_PREP_CMD17;
                                    state <= ST_GAP;
                                ELSE
                                    IF root_sectors_left_reg > 1 THEN
                                        current_lba_reg <= current_lba_reg + 1;
                                        root_sectors_left_reg <= root_sectors_left_reg - 1;
                                        gap_after_state <= ST_PREP_CMD17;
                                        state <= ST_GAP;
                                    ELSE
                                        state <= ST_FINISH_ROOT_SCAN;
                                    END IF;
                                END IF;
                            ELSIF read_job_reg = JOB_ROOT_FAT THEN
                                root_next_cluster_v := root_next_cluster_reg;
                                root_next_cluster_v(31 DOWNTO 28) := (OTHERS => '0');

                                IF fdd_chain_active_reg = '1' THEN
                                    IF root_next_cluster_v >= to_unsigned(2, 32) AND
                                        root_next_cluster_v < to_unsigned(16#0FFFFFF7#, 32) THEN
                                        lba_cluster_reg <= root_next_cluster_v;
                                        IF fdd_chain_remaining_reg <
                                            resize(UNSIGNED(boot_spc_reg), fdd_chain_remaining_reg'LENGTH) THEN
                                            fdd_sector_offset_reg <= fdd_chain_remaining_reg;
                                            fdd_chain_active_reg <= '0';
                                            lba_target_reg <= LBA_TARGET_FILE;
                                            IF fdd_chain_write_reg = '1' THEN
                                                fdd_write_cache_valid_reg <= '1';
                                                fdd_write_cache_file_cluster_reg <= fdd_chain_file_cluster_reg;
                                                fdd_write_cache_cluster_reg <= root_next_cluster_v;
                                                fdd_write_cache_sector_base_reg <= fdd_chain_sector_base_reg;
                                                read_job_reg <= JOB_FDD_WRITE;
                                            ELSE
                                                fdd_read_cache_valid_reg <= '1';
                                                fdd_read_cache_file_cluster_reg <= fdd_chain_file_cluster_reg;
                                                fdd_read_cache_cluster_reg <= root_next_cluster_v;
                                                fdd_read_cache_sector_base_reg <= fdd_chain_sector_base_reg;
                                                read_job_reg <= JOB_FDD;
                                            END IF;
                                            gap_after_state <= ST_CALC_LBA_BASE;
                                            state <= ST_GAP;
                                        ELSE
                                            fdd_chain_remaining_reg <=
                                                fdd_chain_remaining_reg -
                                                resize(UNSIGNED(boot_spc_reg), fdd_chain_remaining_reg'LENGTH);
                                            fdd_chain_sector_base_reg <=
                                                fdd_chain_sector_base_reg +
                                                resize(UNSIGNED(boot_spc_reg), fdd_chain_sector_base_reg'LENGTH);
                                            root_next_cluster_reg <= (OTHERS => '0');
                                            root_fat_byte_offset_reg <=
                                                to_integer(root_next_cluster_v(6 DOWNTO 0)) * 4;
                                            current_lba_reg <=
                                                part_lba_reg +
                                                resize(boot_reserved_reg, 32) +
                                                resize(shift_right(root_next_cluster_v, 7), 32);
                                            gap_after_state <= ST_PREP_CMD17;
                                            state <= ST_GAP;
                                        END IF;
                                    ELSE
                                        read_error_reg <= '1';
                                        read_error_code_reg <= x"5";
                                        gap_after_state <= ST_READ_READY;
                                        state <= ST_GAP;
                                    END IF;
                                ELSE
                                    IF root_next_cluster_v >= to_unsigned(2, 32) AND
                                        root_next_cluster_v < to_unsigned(16#0FFFFFF7#, 32) THEN
                                        lba_target_reg <= LBA_TARGET_ROOT;
                                        lba_cluster_reg <= root_next_cluster_v;
                                        root_current_cluster_reg <= root_next_cluster_v;
                                        root_chain_advance_reg <= '1';
                                        gap_after_state <= ST_CALC_LBA_BASE;
                                        state <= ST_GAP;
                                    ELSE
                                        state <= ST_FINISH_ROOT_SCAN;
                                    END IF;
                                END IF;
                            ELSIF read_job_reg = JOB_FAT THEN
                                IF save_check_can_allocate_reg = '1' THEN
                                    save_check_busy_reg <= '0';
                                    IF cfg_request_reg = CFG_REQ_SAVE THEN
                                        save_req_start_addr_reg <= (OTHERS => '0');
                                        save_req_end_addr_reg <= (OTHERS => '0');
                                        save_backend_is_cfg_reg <= '1';
                                        root_scan_job_reg <= ROOT_SCAN_DISCOVER;
                                        state <= ST_SAVE_PREP_REQUEST;
                                    ELSIF save_write_busy_reg = '1' THEN
                                        state <= ST_SAVE_PREP_REQUEST;
                                    ELSE
                                        save_check_done_reg <= '1';
                                        root_scan_job_reg <= ROOT_SCAN_DISCOVER;
                                        read_done_reg <= '1';
                                        gap_after_state <= ST_READ_READY;
                                        state <= ST_GAP;
                                    END IF;
                                ELSIF fat_scan_sectors_left_reg > to_unsigned(1, 32) THEN
                                    current_lba_reg <= current_lba_reg + 1;
                                    fat_scan_sectors_left_reg <= fat_scan_sectors_left_reg - 1;
                                    gap_after_state <= ST_PREP_CMD17;
                                    state <= ST_GAP;
                                ELSE
                                    IF save_check_can_allocate_reg = '0' AND fat_scan_wrap_reg = '0' AND
                                        fat_scan_min_cluster_reg > to_unsigned(2, 32) THEN
                                        current_lba_reg <= part_lba_reg + resize(boot_reserved_reg, 32);
                                        fat_scan_sectors_left_reg <= resize(shift_right(fat_scan_min_cluster_reg, 7), 32) + 1;
                                        fat_scan_cluster_reg <= (OTHERS => '0');
                                        fat_scan_min_cluster_reg <= to_unsigned(2, 32);
                                        fat_scan_wrap_reg <= '1';
                                        fat_entry_tmp_reg <= (OTHERS => '0');
                                        gap_after_state <= ST_PREP_CMD17;
                                        state <= ST_GAP;
                                    ELSE
                                        save_check_busy_reg <= '0';
                                        IF cfg_request_reg = CFG_REQ_SAVE THEN
                                            cfg_save_busy_reg <= '0';
                                            cfg_save_error_reg <= '1';
                                            cfg_request_reg <= CFG_REQ_NONE;
                                            root_scan_job_reg <= ROOT_SCAN_DISCOVER;
                                            read_done_reg <= '1';
                                            gap_after_state <= ST_READ_READY;
                                            state <= ST_GAP;
                                        ELSIF save_write_busy_reg = '1' THEN
                                            save_write_busy_reg <= '0';
                                            save_write_error_reg <= '1';
                                            save_write_status_reg <= SAVE_STATUS_ERR_FAT_SCAN;
                                            root_scan_job_reg <= ROOT_SCAN_DISCOVER;
                                            read_done_reg <= '1';
                                            gap_after_state <= ST_READ_READY;
                                            state <= ST_GAP;
                                        ELSE
                                            save_check_done_reg <= '1';
                                            root_scan_job_reg <= ROOT_SCAN_DISCOVER;
                                            read_done_reg <= '1';
                                            gap_after_state <= ST_READ_READY;
                                            state <= ST_GAP;
                                        END IF;
                                    END IF;
                                END IF;
                            ELSIF read_job_reg = JOB_CFG THEN
                                cfg_load_busy_reg <= '0';
                                cfg_request_reg <= CFG_REQ_NONE;
                                cfg_byte4_v := cfg_parse_byte4_reg;
                                cfg_byte5_v := cfg_parse_byte5_reg;
                                cfg_byte6_v := cfg_parse_byte6_reg;
                                cfg_loaded_scanlines_reg <= '0';
                                cfg_loaded_video_zoom_reg <= "00";
                                cfg_loaded_rs232_flow_reg <= '0';
                                cfg_loaded_network_reg <= '0';
                                cfg_loaded_network_dhcp_reg <= '0';
                                cfg_loaded_network_ipv4_reg <= x"C0A80141";
                                cfg_loaded_network_netmask_reg <= x"FFFFFF00";
                                cfg_loaded_network_gateway_reg <= x"C0A80101";
                                cfg_loaded_network_dns_reg <= x"C0A80101";
                                cfg_loaded_bls_reg <= '0';

                                IF read_first_word_reg = x"4E324346" THEN
                                    IF save_check_size_reg >= CONFIG_STREAM_LEN AND
                                        cfg_parse_byte4_reg = CONFIG_VERSION_V4 AND
                                        cfg_parse_byte5_reg = x"20" AND
                                        cfg_parse_byte30_reg = (cfg_parse_byte4_reg XOR cfg_parse_byte5_reg XOR
                                            cfg_parse_byte6_reg XOR cfg_parse_byte7_reg XOR cfg_parse_byte8_reg XOR
                                            cfg_parse_byte9_reg XOR xor_network_payload(cfg_parse_network_payload_reg) XOR x"A5") THEN
                                        cfg_loaded_speed_reg <= cfg_parse_byte6_reg(1 DOWNTO 0);
                                        cfg_loaded_phosphor_amber_reg <= cfg_parse_byte6_reg(2);
                                        cfg_loaded_scanlines_reg <= cfg_parse_byte6_reg(3);
                                        cfg_loaded_video_zoom_reg <= cfg_parse_byte6_reg(5 DOWNTO 4);
                                        cfg_loaded_rs232_reg <= cfg_parse_byte8_reg(2 DOWNTO 0);
                                        cfg_loaded_rs232_speed_reg <= cfg_parse_byte9_reg(3 DOWNTO 0);
                                        cfg_loaded_rs232_flow_reg <= cfg_parse_byte8_reg(6);
                                        cfg_loaded_slot_rom_reg <= cfg_parse_byte7_reg(3 DOWNTO 0);
                                        cfg_loaded_fdd_reg <= cfg_parse_byte7_reg(4);
                                        cfg_loaded_cpm_reg <= cfg_parse_byte7_reg(5);
                                        cfg_loaded_avc_reg <= cfg_parse_byte7_reg(6);
                                        cfg_loaded_bls_reg <= cfg_parse_byte7_reg(7);
                                        cfg_loaded_network_reg <= cfg_parse_network_payload_reg(128);
                                        cfg_loaded_network_dhcp_reg <= cfg_parse_network_payload_reg(129);
                                        cfg_loaded_network_ipv4_reg <= cfg_parse_network_payload_reg(127 DOWNTO 96);
                                        cfg_loaded_network_netmask_reg <= cfg_parse_network_payload_reg(95 DOWNTO 64);
                                        cfg_loaded_network_gateway_reg <= cfg_parse_network_payload_reg(63 DOWNTO 32);
                                        cfg_loaded_network_dns_reg <= cfg_parse_network_payload_reg(31 DOWNTO 0);
                                        cfg_loaded_valid_reg <= '1';
                                        cfg_load_done_reg <= '1';
                                    ELSIF save_check_size_reg >= CONFIG_STREAM_LEN_V3 AND
                                        cfg_parse_byte4_reg = CONFIG_VERSION_V3 AND
                                        cfg_parse_byte5_reg = x"10" AND
                                        cfg_parse_byte14_reg = (cfg_parse_byte4_reg XOR cfg_parse_byte5_reg XOR cfg_parse_byte6_reg XOR cfg_parse_byte7_reg XOR cfg_parse_byte8_reg XOR cfg_parse_byte9_reg XOR x"A5") THEN
                                        cfg_loaded_speed_reg <= cfg_parse_byte6_reg(1 DOWNTO 0);
                                        cfg_loaded_phosphor_amber_reg <= cfg_parse_byte6_reg(2);
                                        cfg_loaded_scanlines_reg <= cfg_parse_byte6_reg(3);
                                        cfg_loaded_video_zoom_reg <= cfg_parse_byte6_reg(5 DOWNTO 4);
                                        cfg_loaded_rs232_reg <= cfg_parse_byte8_reg(2 DOWNTO 0);
                                        cfg_loaded_rs232_speed_reg <= cfg_parse_byte9_reg(3 DOWNTO 0);
                                        cfg_loaded_rs232_flow_reg <= cfg_parse_byte8_reg(6);
                                        cfg_loaded_slot_rom_reg <= cfg_parse_byte7_reg(3 DOWNTO 0);
                                        cfg_loaded_fdd_reg <= cfg_parse_byte7_reg(4);
                                        cfg_loaded_cpm_reg <= cfg_parse_byte7_reg(5);
                                        cfg_loaded_avc_reg <= cfg_parse_byte7_reg(6);
                                        cfg_loaded_bls_reg <= '0';
                                        cfg_loaded_valid_reg <= '1';
                                        cfg_load_done_reg <= '1';
                                    ELSIF save_check_size_reg >= CONFIG_STREAM_LEN_V3 AND
                                        cfg_parse_byte4_reg = CONFIG_VERSION_V2 AND
                                        cfg_parse_byte5_reg = x"10" AND
                                        cfg_parse_byte14_reg = (cfg_parse_byte4_reg XOR cfg_parse_byte5_reg XOR cfg_parse_byte6_reg XOR cfg_parse_byte7_reg XOR cfg_parse_byte8_reg XOR x"A5") THEN
                                        cfg_loaded_speed_reg <= cfg_parse_byte6_reg(1 DOWNTO 0);
                                        cfg_loaded_phosphor_amber_reg <= cfg_parse_byte6_reg(2);
                                        cfg_loaded_scanlines_reg <= cfg_parse_byte6_reg(3);
                                        cfg_loaded_rs232_reg <= cfg_parse_byte8_reg(2 DOWNTO 0);
                                        cfg_loaded_rs232_speed_reg <= legacy_rs232_speed_sel(cfg_parse_byte8_reg(5 DOWNTO 3));
                                        cfg_loaded_slot_rom_reg <= cfg_parse_byte7_reg(3 DOWNTO 0);
                                        cfg_loaded_fdd_reg <= '0';
                                        cfg_loaded_cpm_reg <= '0';
                                        cfg_loaded_avc_reg <= '0';
                                        cfg_loaded_bls_reg <= '0';
                                        cfg_loaded_valid_reg <= '1';
                                        cfg_load_done_reg <= '1';
                                    ELSIF save_check_size_reg >= CONFIG_STREAM_LEN_RS232 AND
                                        cfg_parse_byte7_reg = (cfg_byte4_v XOR cfg_byte5_v XOR cfg_byte6_v XOR x"A5") THEN
                                        cfg_loaded_speed_reg <= cfg_parse_byte4_reg(1 DOWNTO 0);
                                        cfg_loaded_phosphor_amber_reg <= cfg_parse_byte4_reg(2);
                                        cfg_loaded_rs232_reg <= cfg_parse_byte6_reg(2 DOWNTO 0);
                                        cfg_loaded_rs232_speed_reg <= legacy_rs232_speed_sel(cfg_parse_byte6_reg(5 DOWNTO 3));
                                        cfg_loaded_slot_rom_reg <= cfg_parse_byte5_reg(3 DOWNTO 0);
                                        cfg_loaded_fdd_reg <= '0';
                                        cfg_loaded_cpm_reg <= '0';
                                        cfg_loaded_avc_reg <= '0';
                                        cfg_loaded_bls_reg <= '0';
                                        cfg_loaded_valid_reg <= '1';
                                        cfg_load_done_reg <= '1';
                                    ELSIF save_check_size_reg >= CONFIG_STREAM_LEN_OLD AND
                                        cfg_parse_byte6_reg = (cfg_byte4_v XOR cfg_byte5_v XOR x"A5") THEN
                                        cfg_loaded_speed_reg <= cfg_parse_byte4_reg(1 DOWNTO 0);
                                        cfg_loaded_phosphor_amber_reg <= cfg_parse_byte4_reg(2);
                                        cfg_loaded_rs232_reg <= "000";
                                        cfg_loaded_rs232_speed_reg <= "1001";
                                        cfg_loaded_slot_rom_reg <= cfg_parse_byte5_reg(3 DOWNTO 0);
                                        cfg_loaded_fdd_reg <= '0';
                                        cfg_loaded_cpm_reg <= '0';
                                        cfg_loaded_avc_reg <= '0';
                                        cfg_loaded_bls_reg <= '0';
                                        cfg_loaded_valid_reg <= '1';
                                        cfg_load_done_reg <= '1';
                                    ELSE
                                        cfg_load_error_reg <= '1';
                                    END IF;
                                ELSE
                                    cfg_load_error_reg <= '1';
                                END IF;
                                browser_cache_valid_reg <= '0';
                                browser_rescan_pending_reg <= '1';
                                read_done_reg <= '1';
                                gap_after_state <= ST_READ_READY;
                                state <= ST_GAP;
                            ELSE
                                IF file_bytes_left_reg = 0 OR
                                    (file_read_is_cas_reg = '1' AND file_cas_error_reg = '1') THEN
                                    -- A trailing zero leader is legal. A partial header/data/checksum
                                    -- is not; a good earlier block must not hide a later failure.
                                    IF file_read_is_cas_reg = '1' AND
                                        (file_cas_error_reg = '1' OR file_load_addr_valid_reg = '0' OR
                                         (cas_parse_state_reg /= CAS_SYNC_00 AND
                                          cas_parse_state_reg /= CAS_SYNC_FF1)) THEN
                                        read_error_reg <= '1';
                                        read_error_code_reg <= x"6"; -- invalid CAS block/file
                                        file_load_addr_valid_reg <= '0';
                                        gap_after_state <= ST_READ_READY;
                                        state <= ST_GAP;
                                    ELSE
                                        read_done_reg <= '1';
                                        gap_after_state <= ST_READ_READY;
                                        state <= ST_GAP;
                                    END IF;
                                ELSE
                                    current_lba_reg <= current_lba_reg + 1;
                                    gap_after_state <= ST_PREP_CMD17;
                                    state <= ST_GAP;
                                END IF;
                            END IF;
                        ELSIF byte_busy = '0' THEN
                            queue_byte_v := TRUE;
                            queue_data_v := x"FF";
                        END IF;

                    WHEN ST_CALC_LBA_BASE =>
                        cs_n_reg <= '1';
                        sclk_reg <= '0';
                        mosi_reg <= '1';
                        lba_data_start_reg <= resize(
                            part_lba_reg +
                            resize(boot_reserved_reg, 32) +
                            resize((boot_spf_reg * to_integer(boot_num_fats_reg)), 32),
                            32
                            );
                        state <= ST_CALC_LBA_OFFSET;

                    WHEN ST_CALC_LBA_OFFSET =>
                        cs_n_reg <= '1';
                        sclk_reg <= '0';
                        mosi_reg <= '1';
                        lba_cluster_offset_reg <= resize(
                            ((lba_cluster_reg - to_unsigned(2, 32)) * to_integer(unsigned(boot_spc_reg))),
                            32
                            );
                        state <= ST_CALC_LBA_APPLY;

                    WHEN ST_CALC_LBA_APPLY =>
                        cs_n_reg <= '1';
                        sclk_reg <= '0';
                        mosi_reg <= '1';
                        lba_result_v := resize(lba_data_start_reg + lba_cluster_offset_reg, 32);
                        IF read_job_reg = JOB_FDD OR read_job_reg = JOB_FDD_WRITE THEN
                            lba_result_v := lba_result_v + resize(fdd_sector_offset_reg, 32);
                        END IF;
                        current_lba_reg <= lba_result_v;
                        IF lba_target_reg = LBA_TARGET_ROOT THEN
                            root_dir_lba_reg <= lba_result_v;
                            root_current_cluster_reg <= lba_cluster_reg;
                            IF boot_spc_reg = x"00" THEN
                                root_sectors_left_reg <= 0;
                            ELSE
                                root_sectors_left_reg <= to_integer(unsigned(boot_spc_reg));
                            END IF;
                            root_end_seen_reg <= '0';
                            IF root_chain_advance_reg = '0' AND
                                (root_scan_job_reg = ROOT_SCAN_DISCOVER OR
                                 root_scan_job_reg = ROOT_SCAN_PAGE_RELOAD) THEN
                                page_valid_reg <= (OTHERS => '0');
                                page_name_reg <= (OTHERS => (OTHERS => '0'));
                                page_cluster_reg <= (OTHERS => (OTHERS => '0'));
                                page_size_reg <= (OTHERS => (OTHERS => '0'));
                                page_kind_reg <= (OTHERS => SD_DSK_KIND_UNKNOWN);
                                browser_page_fill_active_reg <= '0';
                                browser_page_fill_index_reg <= 0;
                                browser_page_fill_base_reg <= page_base_index;
                                page_loaded_base_reg <= page_base_index;
                                reload_match_index_reg <= 0;
                            END IF;
                            IF root_chain_advance_reg = '0' AND root_scan_job_reg = ROOT_SCAN_DISCOVER THEN
                                root_file_count_reg <= 0;
                                root_total_file_count_reg <= 0;
                                browser_cache_valid_reg <= '0';
                                cached_free_valid_reg <= '0';
                                cached_free_lba_reg <= (OTHERS => '0');
                                cached_free_slot_reg <= 0;
                                cached_free_marker_reg <= x"00";
                                cached_free_sector_first_byte_reg <= x"00";
                                cached_free_requires_dir_growth_reg <= '0';
                            END IF;
                            root_chain_advance_reg <= '0';
                            read_job_reg <= JOB_ROOT;
                            state <= ST_PREP_CMD17;
                        ELSIF save_lba_pending_reg = '1' THEN
                            save_lba_pending_reg <= '0';
                            save_sector_tx_index_reg <= 0;
                            save_cmd24_pending_reg <= '1';
                            state <= ST_SAVE_BUILD_SECTOR;
                        ELSE
                            state <= ST_PREP_CMD17;
                        END IF;

                    WHEN ST_SAVE_BUILD_SECTOR =>
                        cs_n_reg <= '1';
                        sclk_reg <= '0';
                        mosi_reg <= '1';

                        IF save_sector_source_reg = SAVE_SECTOR_PATCH THEN
                            IF save_sector_tx_index_reg = 0 THEN
                                save_out_byte_v := save_patch_first_byte_reg;
                            ELSE
                                save_out_byte_v := save_patch_rd_data_reg;
                            END IF;
                        ELSIF save_sector_source_reg = SAVE_SECTOR_CFG THEN
                            CASE save_sector_tx_index_reg IS
                                WHEN 0 =>
                                    save_out_byte_v := x"4E"; -- N
                                WHEN 1 =>
                                    save_out_byte_v := x"32"; -- 2
                                WHEN 2 =>
                                    save_out_byte_v := x"43"; -- C
                                WHEN 3 =>
                                    save_out_byte_v := x"46"; -- F
                                WHEN 4 =>
                                    save_out_byte_v := CONFIG_VERSION_V4;
                                WHEN 5 =>
                                    save_out_byte_v := x"20";
                                WHEN 6 =>
                                    save_out_byte_v := cfg_byte4_reg;
                                WHEN 7 =>
                                    save_out_byte_v := cfg_byte5_reg;
                                WHEN 8 =>
                                    save_out_byte_v := cfg_byte6_reg;
                                WHEN 9 =>
                                    save_out_byte_v := cfg_byte8_reg;
                                WHEN 10 TO 26 =>
                                    save_out_byte_v := cfg_network_payload_reg(
                                        135 - (save_sector_tx_index_reg - 10) * 8 DOWNTO
                                        128 - (save_sector_tx_index_reg - 10) * 8);
                                WHEN 30 =>
                                    save_out_byte_v := cfg_byte7_reg;
                                WHEN 31 =>
                                    save_out_byte_v := x"0A";
                                WHEN OTHERS =>
                                    save_out_byte_v := x"00";
                            END CASE;
                        ELSE
                            save_out_byte_v := x"20";
                            CASE save_fmt_state_reg IS
                                WHEN SAVE_FMT_LINE_ADDR3 =>
                                    save_out_byte_v := hex_nibble_to_ascii(STD_LOGIC_VECTOR(save_line_addr_reg(15 DOWNTO 12)));
                                    save_fmt_state_reg <= SAVE_FMT_LINE_ADDR2;

                                WHEN SAVE_FMT_LINE_ADDR2 =>
                                    save_out_byte_v := hex_nibble_to_ascii(STD_LOGIC_VECTOR(save_line_addr_reg(11 DOWNTO 8)));
                                    save_fmt_state_reg <= SAVE_FMT_LINE_ADDR1;

                                WHEN SAVE_FMT_LINE_ADDR1 =>
                                    save_out_byte_v := hex_nibble_to_ascii(STD_LOGIC_VECTOR(save_line_addr_reg(7 DOWNTO 4)));
                                    save_fmt_state_reg <= SAVE_FMT_LINE_ADDR0;

                                WHEN SAVE_FMT_LINE_ADDR0 =>
                                    save_out_byte_v := hex_nibble_to_ascii(STD_LOGIC_VECTOR(save_line_addr_reg(3 DOWNTO 0)));
                                    IF save_line_data_left_reg > 0 THEN
                                        save_fmt_state_reg <= SAVE_FMT_BYTE_SPACE;
                                    ELSIF save_pad_bytes_left_reg /= 0 THEN
                                        save_fmt_state_reg <= SAVE_FMT_PAD;
                                    ELSE
                                        save_fmt_state_reg <= SAVE_FMT_DONE;
                                    END IF;

                                WHEN SAVE_FMT_BYTE_SPACE =>
                                    save_out_byte_v := x"20";
                                    save_mem_addr_reg <= STD_LOGIC_VECTOR(save_current_mem_addr_reg);
                                    save_fmt_state_reg <= SAVE_FMT_BYTE_HI;

                                WHEN SAVE_FMT_BYTE_HI =>
                                    save_mem_byte_reg <= save_mem_data;
                                    save_out_byte_v := hex_nibble_to_ascii(save_mem_data(7 DOWNTO 4));
                                    save_fmt_state_reg <= SAVE_FMT_BYTE_LO;

                                WHEN SAVE_FMT_BYTE_LO =>
                                    save_out_byte_v := hex_nibble_to_ascii(save_mem_byte_reg(3 DOWNTO 0));
                                    save_current_mem_addr_reg <= save_current_mem_addr_reg + 1;
                                    save_prog_bytes_left_reg <= save_prog_bytes_left_reg - 1;
                                    IF save_line_data_left_reg > 1 THEN
                                        save_line_data_left_reg <= save_line_data_left_reg - 1;
                                        save_fmt_state_reg <= SAVE_FMT_BYTE_SPACE;
                                    ELSE
                                        save_line_data_left_reg <= 0;
                                        save_fmt_state_reg <= SAVE_FMT_LINE_CR;
                                    END IF;

                                WHEN SAVE_FMT_LINE_CR =>
                                    save_out_byte_v := x"0D";
                                    save_fmt_state_reg <= SAVE_FMT_LINE_LF;

                                WHEN SAVE_FMT_LINE_LF =>
                                    save_out_byte_v := x"0A";
                                    IF save_prog_bytes_left_reg = to_unsigned(0, 16) THEN
                                        IF save_pad_bytes_left_reg /= to_unsigned(0, 32) THEN
                                            save_fmt_state_reg <= SAVE_FMT_PAD;
                                        ELSE
                                            save_fmt_state_reg <= SAVE_FMT_DONE;
                                        END IF;
                                    ELSE
                                        save_line_addr_reg <= save_current_mem_addr_reg;
                                        IF save_prog_bytes_left_reg > to_unsigned(8, 16) THEN
                                            save_line_len_v := 8;
                                        ELSE
                                            save_line_len_v := to_integer(save_prog_bytes_left_reg);
                                        END IF;
                                        save_line_data_left_reg <= save_line_len_v;
                                        save_fmt_state_reg <= SAVE_FMT_LINE_ADDR3;
                                    END IF;

                                WHEN SAVE_FMT_PAD =>
                                    save_out_byte_v := x"20";
                                    IF save_pad_bytes_left_reg <= to_unsigned(1, 32) THEN
                                        save_pad_bytes_left_reg <= (OTHERS => '0');
                                        save_fmt_state_reg <= SAVE_FMT_DONE;
                                    ELSE
                                        save_pad_bytes_left_reg <= save_pad_bytes_left_reg - 1;
                                    END IF;

                                WHEN OTHERS =>
                                    save_out_byte_v := x"20";
                            END CASE;
                        END IF;

                        save_tx_byte_reg <= save_out_byte_v;
                        IF save_cmd24_pending_reg = '1' THEN
                            save_cmd24_pending_reg <= '0';
                            state <= ST_PREP_CMD24;
                        ELSE
                            state <= ST_WRITE_DATA;
                        END IF;

                    WHEN ST_WRITE_DATA_TOKEN =>
                        cs_n_reg <= '0';
                        IF byte_done_v THEN
                            save_sector_tx_index_reg <= 0;
                            state <= ST_WRITE_DATA;
                        ELSIF byte_busy = '0' THEN
                            queue_byte_v := TRUE;
                            queue_data_v := x"FE";
                        END IF;

                    WHEN ST_WRITE_DATA =>
                        cs_n_reg <= '0';
                        IF byte_done_v THEN
                            IF save_sector_tx_index_reg = 511 THEN
                                state <= ST_WRITE_CRC1;
                            ELSE
                                save_sector_tx_index_reg <= save_sector_tx_index_reg + 1;
                                state <= ST_SAVE_BUILD_SECTOR;
                            END IF;
                        ELSIF byte_busy = '0' THEN
                            queue_byte_v := TRUE;
                            queue_data_v := save_tx_byte_reg;
                            IF save_sector_source_reg = SAVE_SECTOR_PATCH AND save_sector_tx_index_reg < 511 THEN
                                -- Present the next patch byte early while the current byte is
                                -- still shifting out, so the registered BRAM output is valid
                                -- when ST_SAVE_BUILD_SECTOR prepares the following byte.
                                save_patch_rd_addr_reg <= STD_LOGIC_VECTOR(to_unsigned(save_sector_tx_index_reg + 1, 9));
                            END IF;
                        END IF;

                    WHEN ST_WRITE_CRC1 =>
                        cs_n_reg <= '0';
                        IF byte_done_v THEN
                            state <= ST_WRITE_CRC2;
                        ELSIF byte_busy = '0' THEN
                            queue_byte_v := TRUE;
                            queue_data_v := x"FF";
                        END IF;

                    WHEN ST_WRITE_CRC2 =>
                        cs_n_reg <= '0';
                        IF byte_done_v THEN
                            -- A card may keep MISO high for several clocks
                            -- before presenting its data-response token.
                            -- Poll in the following state instead of treating
                            -- the first $FF byte as an immediate write error.
                            response_timeout <= RESPONSE_TIMEOUT_MAX;
                            state <= ST_WAIT_DATA_RESP;
                        ELSIF byte_busy = '0' THEN
                            queue_byte_v := TRUE;
                            queue_data_v := x"FF";
                        END IF;

                    WHEN ST_WAIT_DATA_RESP =>
                        cs_n_reg <= '0';
                        IF byte_done_v THEN
                            IF rx_byte_v(4 DOWNTO 0) = "00101" THEN
                                write_busy_timeout_reg <= 65535;
                                state <= ST_WAIT_WRITE_BUSY;
                            ELSIF rx_byte_v = x"FF" AND response_timeout > 0 THEN
                                response_timeout <= response_timeout - 1;
                            ELSE
                                save_write_busy_reg <= '0';
                                save_write_error_reg <= '1';
                                IF rx_byte_v = x"FF" THEN
                                    save_write_status_reg <= SAVE_STATUS_ERR_CMD24_TIMEOUT;
                                ELSE
                                    save_write_status_reg <= SAVE_STATUS_ERR_DATA_RESP;
                                END IF;
                                IF save_backend_is_cfg_reg = '1' THEN
                                    cfg_save_busy_reg <= '0';
                                    cfg_save_error_reg <= '1';
                                    cfg_request_reg <= CFG_REQ_NONE;
                                    save_backend_is_cfg_reg <= '0';
                                END IF;
                                gap_after_state <= ST_READ_READY;
                                state <= ST_GAP;
                            END IF;
                        ELSIF byte_busy = '0' THEN
                            queue_byte_v := TRUE;
                            queue_data_v := x"FF";
                        END IF;

                    WHEN ST_WAIT_WRITE_BUSY =>
                        cs_n_reg <= '0';
                        IF byte_done_v THEN
                            IF rx_byte_v = x"FF" THEN
                                IF save_backend_is_fdd_reg = '1' THEN
                                    -- Keep the external operation busy until
                                    -- the mandatory CS-high gap has completed.
                                    -- Reporting done here lets a real WD1793
                                    -- client start its next sector while the
                                    -- SD card is not ready for another command.
                                    fdd_write_complete_pending_reg <= '1';
                                    fdd_write_error_reg <= '0';
                                    save_backend_is_fdd_reg <= '0';
                                    save_write_busy_reg <= '0';
                                    save_write_done_reg <= '0';
                                    save_write_error_reg <= '0';
                                    save_write_status_reg <= SAVE_STATUS_NONE;
                                    read_done_reg <= '1';
                                    gap_after_state <= ST_READ_READY;
                                    state <= ST_GAP;
                                ELSIF save_sector_source_reg = SAVE_SECTOR_PATCH AND
                                    save_create_phase_reg = SAVE_MANAGE_WRITE_RENAME THEN
                                    save_create_phase_reg <= SAVE_CREATE_IDLE;
                                    manage_busy_reg <= '0';
                                    manage_done_reg <= '1';
                                    manage_error_reg <= '0';
                                    manage_status_reg <= MANAGE_STATUS_NONE;
                                    browser_cache_valid_reg <= '0';
                                    browser_page_dirty_reg <= '1';
                                    browser_rescan_pending_reg <= '1';
                                    read_done_reg <= '1';
                                    gap_after_state <= ST_READ_READY;
                                    state <= ST_GAP;

                                ELSIF save_sector_source_reg = SAVE_SECTOR_PATCH AND
                                    save_create_phase_reg = SAVE_MANAGE_WRITE_DELETE_DIR THEN
                                    IF manage_cluster_reg >= to_unsigned(2, 32) THEN
                                        save_create_phase_reg <= SAVE_MANAGE_DELETE_FAT;
                                        save_fat_copy_index_reg <= 0;
                                        manage_fat_offset_reg <= to_integer(manage_cluster_reg(6 DOWNTO 0)) * 4;
                                        manage_next_cluster_reg <= (OTHERS => '0');
                                        manage_chain_guard_reg <= (OTHERS => '0');
                                        current_lba_reg <= part_lba_reg +
                                            resize(boot_reserved_reg, 32) +
                                            shift_right(manage_cluster_reg, 7);
                                        read_job_reg <= JOB_MANAGE_FAT;
                                        gap_after_state <= ST_PREP_CMD17;
                                        state <= ST_GAP;
                                    ELSE
                                        save_create_phase_reg <= SAVE_CREATE_IDLE;
                                        manage_busy_reg <= '0';
                                        manage_done_reg <= '1';
                                        manage_error_reg <= '0';
                                        manage_status_reg <= MANAGE_STATUS_NONE;
                                        browser_cache_valid_reg <= '0';
                                        browser_page_dirty_reg <= '1';
                                        browser_rescan_pending_reg <= '1';
                                        read_done_reg <= '1';
                                        gap_after_state <= ST_READ_READY;
                                        state <= ST_GAP;
                                    END IF;

                                ELSIF save_sector_source_reg = SAVE_SECTOR_PATCH AND
                                    save_create_phase_reg = SAVE_MANAGE_WRITE_DELETE_FAT THEN
                                    IF save_fat_copy_index_reg + 1 < to_integer(boot_num_fats_reg) THEN
                                        save_fat_copy_index_reg <= save_fat_copy_index_reg + 1;
                                        current_lba_reg <= current_lba_reg + boot_spf_reg;
                                        save_sector_tx_index_reg <= 0;
                                        save_patch_rd_addr_reg <= (OTHERS => '0');
                                        save_cmd24_pending_reg <= '1';
                                        gap_after_state <= ST_SAVE_BUILD_SECTOR;
                                        state <= ST_GAP;
                                    ELSIF manage_next_cluster_reg >= to_unsigned(2, 32) AND
                                        manage_next_cluster_reg < to_unsigned(16#0FFFFFF0#, 32) AND
                                        manage_chain_guard_reg /= x"FFFF" THEN
                                        manage_cluster_reg <= manage_next_cluster_reg;
                                        manage_chain_guard_reg <= manage_chain_guard_reg + 1;
                                        save_create_phase_reg <= SAVE_MANAGE_DELETE_FAT;
                                        save_fat_copy_index_reg <= 0;
                                        manage_fat_offset_reg <= to_integer(manage_next_cluster_reg(6 DOWNTO 0)) * 4;
                                        current_lba_reg <= part_lba_reg +
                                            resize(boot_reserved_reg, 32) +
                                            shift_right(manage_next_cluster_reg, 7);
                                        manage_next_cluster_reg <= (OTHERS => '0');
                                        read_job_reg <= JOB_MANAGE_FAT;
                                        gap_after_state <= ST_PREP_CMD17;
                                        state <= ST_GAP;
                                    ELSIF manage_next_cluster_reg >= to_unsigned(16#0FFFFFF8#, 32) THEN
                                        save_create_phase_reg <= SAVE_CREATE_IDLE;
                                        manage_busy_reg <= '0';
                                        manage_done_reg <= '1';
                                        manage_error_reg <= '0';
                                        manage_status_reg <= MANAGE_STATUS_NONE;
                                        browser_cache_valid_reg <= '0';
                                        browser_page_dirty_reg <= '1';
                                        browser_rescan_pending_reg <= '1';
                                        read_done_reg <= '1';
                                        gap_after_state <= ST_READ_READY;
                                        state <= ST_GAP;
                                    ELSE
                                        save_create_phase_reg <= SAVE_CREATE_IDLE;
                                        manage_busy_reg <= '0';
                                        manage_done_reg <= '0';
                                        manage_error_reg <= '1';
                                        manage_status_reg <= MANAGE_STATUS_BAD_CHAIN;
                                        browser_cache_valid_reg <= '0';
                                        browser_page_dirty_reg <= '1';
                                        browser_rescan_pending_reg <= '1';
                                        read_done_reg <= '1';
                                        gap_after_state <= ST_READ_READY;
                                        state <= ST_GAP;
                                    END IF;

                                ELSIF save_sector_source_reg = SAVE_SECTOR_PATCH AND
                                    save_create_phase_reg = SAVE_CREATE_WRITE_FAT THEN
                                    IF save_fat_copy_index_reg + 1 < to_integer(boot_num_fats_reg) THEN
                                        save_fat_copy_index_reg <= save_fat_copy_index_reg + 1;
                                        current_lba_reg <= current_lba_reg + boot_spf_reg;
                                        save_sector_tx_index_reg <= 0;
                                        save_patch_rd_addr_reg <= (OTHERS => '0');
                                        save_cmd24_pending_reg <= '1';
                                        gap_after_state <= ST_SAVE_BUILD_SECTOR;
                                        state <= ST_GAP;
                                    ELSIF save_create_clusters_left_reg /= to_unsigned(0, 16) THEN
                                        save_create_phase_reg <= SAVE_CREATE_LOAD_FAT;
                                        save_fat_copy_index_reg <= 0;
                                        save_fat_byte_offset_reg <= to_integer(save_create_current_cluster_reg(6 DOWNTO 0)) * 4;
                                        current_lba_reg <= part_lba_reg +
                                            resize(boot_reserved_reg, 32) +
                                            shift_right(save_create_current_cluster_reg, 7);
                                        read_job_reg <= JOB_PATCH;
                                        gap_after_state <= ST_PREP_CMD17;
                                        state <= ST_GAP;
                                    ELSE
                                        save_create_phase_reg <= SAVE_CREATE_LOAD_DIR;
                                        current_lba_reg <= save_check_free_lba_reg;
                                        read_job_reg <= JOB_PATCH;
                                        gap_after_state <= ST_PREP_CMD17;
                                        state <= ST_GAP;
                                    END IF;
                                ELSIF save_sector_source_reg = SAVE_SECTOR_PATCH AND
                                    save_create_phase_reg = SAVE_CREATE_WRITE_RENAME THEN
                                    -- The original now safely exists as .BAK.
                                    -- Rescan the physical directory before
                                    -- creating the replacement DSK.  Reusing a
                                    -- cached free slot can place the new entry
                                    -- behind an earlier $00 end marker after
                                    -- the in-place rename, making it invisible
                                    -- to FAT32 hosts.
                                    fdd_format_phase_reg <= FDD_FORMAT_FIND_FREE;
                                    save_create_phase_reg <= SAVE_CREATE_IDLE;
                                    save_check_name_reg <= fdd_format_name_reg;
                                    save_check_exists_reg <= '0';
                                    save_check_can_create_reg <= '0';
                                    save_check_can_allocate_reg <= '0';
                                    save_check_requires_dir_growth_reg <= '0';
                                    save_check_dir_full_reg <= '0';
                                    save_check_cluster_reg <= (OTHERS => '0');
                                    save_check_size_reg <= (OTHERS => '0');
                                    save_check_free_lba_reg <= (OTHERS => '0');
                                    save_check_free_slot_reg <= 0;
                                    save_check_free_marker_reg <= x"00";
                                    save_check_free_sector_first_byte_reg <= x"00";
                                    save_check_free_cluster_reg <= (OTHERS => '0');
                                    save_check_match_lba_reg <= (OTHERS => '0');
                                    save_check_match_slot_reg <= 0;
                                    save_check_match_sector_first_byte_reg <= x"00";
                                    save_check_busy_reg <= '1';
                                    save_write_busy_reg <= '1';
                                    save_write_done_reg <= '0';
                                    save_write_error_reg <= '0';
                                    lba_target_reg <= LBA_TARGET_ROOT;
                                    lba_cluster_reg <= browser_dir_cluster_reg;
                                    root_current_cluster_reg <= browser_dir_cluster_reg;
                                    root_chain_advance_reg <= '0';
                                    browser_page_reload_reg <= '0';
                                    root_scan_phase_reg <= ROOT_SCAN_LIST_FILES;
                                    root_scan_job_reg <= ROOT_SCAN_SAVE_CHECK;
                                    gap_after_state <= ST_CALC_LBA_BASE;
                                    state <= ST_GAP;
                                ELSIF save_sector_source_reg = SAVE_SECTOR_PATCH AND
                                    save_create_phase_reg = SAVE_CREATE_WRITE_DIR THEN
                                    IF save_create_extend_dir_reg = '1' THEN
                                        save_create_phase_reg <= SAVE_CREATE_LOAD_DIR_NEXT;
                                        current_lba_reg <= save_check_free_lba_reg + 1;
                                        read_job_reg <= JOB_PATCH;
                                        gap_after_state <= ST_PREP_CMD17;
                                        state <= ST_GAP;
                                    ELSE
                                        save_create_phase_reg <= SAVE_CREATE_IDLE;
                                        save_create_extend_dir_reg <= '0';
                                        IF fdd_format_phase_reg = FDD_FORMAT_CREATE THEN
                                            fdd_format_new_cluster_reg <= save_check_free_cluster_reg;
                                            fdd_format_busy_reg <= '0';
                                            fdd_format_done_reg <= '1';
                                            fdd_format_phase_reg <= FDD_FORMAT_IDLE;
                                            save_write_busy_reg <= '0';
                                            save_write_done_reg <= '0';
                                            save_write_error_reg <= '0';
                                            browser_cache_valid_reg <= '0';
                                            browser_page_dirty_reg <= '1';
                                            browser_rescan_pending_reg <= '1';
                                            read_done_reg <= '1';
                                            gap_after_state <= ST_READ_READY;
                                            state <= ST_GAP;
                                        ELSE
                                            IF save_backend_is_cfg_reg = '1' THEN
                                                save_sector_source_reg <= SAVE_SECTOR_CFG;
                                                save_fmt_state_reg <= SAVE_FMT_DONE;
                                            ELSE
                                                save_sector_source_reg <= SAVE_SECTOR_NAS;
                                                save_fmt_state_reg <= SAVE_FMT_LINE_ADDR3;
                                            END IF;
                                            save_lba_pending_reg <= '1';
                                            save_sectors_left_reg <= shift_right(save_sector_total_reg, 9);
                                            save_pad_bytes_left_reg <= save_sector_total_reg - save_stream_len_reg;
                                            save_prog_bytes_left_reg <= save_byte_count_reg;
                                            save_line_addr_reg <= save_req_start_addr_reg;
                                            save_current_mem_addr_reg <= save_req_start_addr_reg;
                                            IF save_byte_count_reg > to_unsigned(8, 16) THEN
                                                save_line_len_v := 8;
                                            ELSE
                                                save_line_len_v := to_integer(save_byte_count_reg);
                                            END IF;
                                            save_line_data_left_reg <= save_line_len_v;
                                            save_mem_addr_reg <= STD_LOGIC_VECTOR(save_req_start_addr_reg);
                                            save_mem_byte_reg <= x"00";
                                            save_sector_tx_index_reg <= 0;
                                            save_tx_byte_reg <= x"20";
                                            lba_target_reg <= LBA_TARGET_FILE;
                                            lba_cluster_reg <= save_check_free_cluster_reg;
                                            state <= ST_CALC_LBA_BASE;
                                        END IF;
                                    END IF;
                                ELSIF save_sector_source_reg = SAVE_SECTOR_PATCH AND
                                    save_create_phase_reg = SAVE_CREATE_WRITE_DIR_NEXT THEN
                                    save_create_phase_reg <= SAVE_CREATE_IDLE;
                                    save_create_extend_dir_reg <= '0';
                                    IF save_backend_is_cfg_reg = '1' THEN
                                        save_sector_source_reg <= SAVE_SECTOR_CFG;
                                        save_fmt_state_reg <= SAVE_FMT_DONE;
                                    ELSE
                                        save_sector_source_reg <= SAVE_SECTOR_NAS;
                                        save_fmt_state_reg <= SAVE_FMT_LINE_ADDR3;
                                    END IF;
                                    save_lba_pending_reg <= '1';
                                    save_sectors_left_reg <= shift_right(save_sector_total_reg, 9);
                                    save_pad_bytes_left_reg <= save_sector_total_reg - save_stream_len_reg;
                                    save_prog_bytes_left_reg <= save_byte_count_reg;
                                    save_line_addr_reg <= save_req_start_addr_reg;
                                    save_current_mem_addr_reg <= save_req_start_addr_reg;
                                    IF save_byte_count_reg > to_unsigned(8, 16) THEN
                                        save_line_len_v := 8;
                                    ELSE
                                        save_line_len_v := to_integer(save_byte_count_reg);
                                    END IF;
                                    save_line_data_left_reg <= save_line_len_v;
                                    save_mem_addr_reg <= STD_LOGIC_VECTOR(save_req_start_addr_reg);
                                    save_mem_byte_reg <= x"00";
                                    save_sector_tx_index_reg <= 0;
                                    save_tx_byte_reg <= x"20";
                                    lba_target_reg <= LBA_TARGET_FILE;
                                    lba_cluster_reg <= save_check_free_cluster_reg;
                                    state <= ST_CALC_LBA_BASE;
                                ELSIF save_sector_source_reg = SAVE_SECTOR_PATCH AND
                                    save_create_phase_reg = SAVE_CREATE_PATCH_EXISTING_DIR THEN
                                    save_create_phase_reg <= SAVE_CREATE_IDLE;
                                    save_create_extend_dir_reg <= '0';
                                    save_sector_source_reg <= SAVE_SECTOR_CFG;
                                    save_fmt_state_reg <= SAVE_FMT_DONE;
                                    save_lba_pending_reg <= '1';
                                    save_sectors_left_reg <= shift_right(save_sector_total_reg, 9);
                                    save_pad_bytes_left_reg <= save_sector_total_reg - save_stream_len_reg;
                                    save_prog_bytes_left_reg <= save_byte_count_reg;
                                    save_verify_expected_cluster_reg <= save_check_cluster_reg;
                                    save_verify_expected_size_reg <= save_stream_len_reg;
                                    save_check_size_reg <= CONFIG_STREAM_LEN;
                                    save_line_addr_reg <= save_req_start_addr_reg;
                                    save_current_mem_addr_reg <= save_req_start_addr_reg;
                                    IF save_byte_count_reg > to_unsigned(8, 16) THEN
                                        save_line_len_v := 8;
                                    ELSE
                                        save_line_len_v := to_integer(save_byte_count_reg);
                                    END IF;
                                    save_line_data_left_reg <= save_line_len_v;
                                    save_mem_addr_reg <= STD_LOGIC_VECTOR(save_req_start_addr_reg);
                                    save_mem_byte_reg <= x"00";
                                    save_sector_tx_index_reg <= 0;
                                    save_tx_byte_reg <= x"20";
                                    lba_target_reg <= LBA_TARGET_FILE;
                                    lba_cluster_reg <= save_check_cluster_reg;
                                    state <= ST_CALC_LBA_BASE;
                                ELSIF save_sectors_left_reg > to_unsigned(1, 32) THEN
                                    save_sectors_left_reg <= save_sectors_left_reg - 1;
                                    current_lba_reg <= current_lba_reg + 1;
                                    save_sector_tx_index_reg <= 0;
                                    save_cmd24_pending_reg <= '1';
                                    gap_after_state <= ST_SAVE_BUILD_SECTOR;
                                    state <= ST_GAP;
                                ELSE
                                    save_check_busy_reg <= '1';
                                    save_check_done_reg <= '0';
                                    save_check_exists_reg <= '0';
                                    save_check_can_create_reg <= '0';
                                    save_check_can_allocate_reg <= '0';
                                    save_check_requires_dir_growth_reg <= '0';
                                    save_check_dir_full_reg <= '0';
                                    save_check_cluster_reg <= (OTHERS => '0');
                                    save_check_size_reg <= (OTHERS => '0');
                                    save_check_free_lba_reg <= (OTHERS => '0');
                                    save_check_free_slot_reg <= 0;
                                    save_check_free_marker_reg <= x"00";
                                    save_check_free_cluster_reg <= (OTHERS => '0');
                                    save_check_free_sector_first_byte_reg <= x"00";
                                    save_check_match_lba_reg <= (OTHERS => '0');
                                    save_check_match_slot_reg <= 0;
                                    save_check_match_sector_first_byte_reg <= x"00";
                                    fat_scan_sectors_left_reg <= (OTHERS => '0');
                                    fat_scan_cluster_reg <= (OTHERS => '0');
                                    fat_entry_tmp_reg <= (OTHERS => '0');
                                    save_verify_pending_reg <= '1';
                                    save_verify_dir_byte_ok_reg <= '1';
                                    lba_target_reg <= LBA_TARGET_ROOT;
                                    lba_cluster_reg <= browser_dir_cluster_reg;
                                    root_current_cluster_reg <= browser_dir_cluster_reg;
                                    root_chain_advance_reg <= '0';
                                    browser_page_reload_reg <= '0';
                                    root_scan_phase_reg <= ROOT_SCAN_LIST_FILES;
                                    root_scan_job_reg <= ROOT_SCAN_SAVE_CHECK;
                                    state <= ST_CALC_LBA_BASE;
                                END IF;
                            ELSIF write_busy_timeout_reg = 0 THEN
                                save_write_busy_reg <= '0';
                                save_write_error_reg <= '1';
                                save_write_status_reg <= SAVE_STATUS_ERR_BUSY_TIMEOUT;
                                IF save_backend_is_cfg_reg = '1' THEN
                                    cfg_save_busy_reg <= '0';
                                    cfg_save_error_reg <= '1';
                                    cfg_request_reg <= CFG_REQ_NONE;
                                    save_backend_is_cfg_reg <= '0';
                                END IF;
                                gap_after_state <= ST_READ_READY;
                                state <= ST_GAP;
                            ELSE
                                write_busy_timeout_reg <= write_busy_timeout_reg - 1;
                            END IF;
                        ELSIF byte_busy = '0' THEN
                            queue_byte_v := TRUE;
                            queue_data_v := x"FF";
                        END IF;

                    WHEN ST_SAVE_PREP_REQUEST =>
                        cs_n_reg <= '1';
                        sclk_reg <= '0';
                        mosi_reg <= '1';

                        IF browser_dir_found_reg = '0' OR boot_spc_reg = x"00" THEN
                            save_write_error_reg <= '1';
                            save_write_status_reg <= SAVE_STATUS_DIR_MISSING;
                            IF save_backend_is_cfg_reg = '1' THEN
                                cfg_save_busy_reg <= '0';
                                cfg_save_error_reg <= '1';
                                cfg_request_reg <= CFG_REQ_NONE;
                                save_backend_is_cfg_reg <= '0';
                            END IF;
                            state <= ST_READ_READY;
                        ELSIF save_check_exists_reg = '0' AND save_check_requires_dir_growth_reg = '1' THEN
                            save_write_error_reg <= '1';
                            save_write_status_reg <= SAVE_STATUS_CREATE_DIR_GROWTH;
                            IF save_backend_is_cfg_reg = '1' THEN
                                cfg_save_busy_reg <= '0';
                                cfg_save_error_reg <= '1';
                                cfg_request_reg <= CFG_REQ_NONE;
                                save_backend_is_cfg_reg <= '0';
                            END IF;
                            state <= ST_READ_READY;
                        ELSIF save_check_exists_reg = '0' AND
                            save_check_can_create_reg = '1' AND
                            save_check_free_cluster_reg = to_unsigned(0, 32) THEN
                            save_check_can_allocate_reg <= '0';
                            save_check_free_cluster_reg <= to_unsigned(1, 32);
                            save_alloc_search_need_reg <= to_unsigned(1, 16);
                            read_job_reg <= JOB_FAT;
                            IF save_cluster_hint_reg > to_unsigned(2, 32) THEN
                                current_lba_reg <= part_lba_reg + resize(boot_reserved_reg, 32) + shift_right(save_cluster_hint_reg, 7);
                                fat_scan_sectors_left_reg <= boot_spf_reg - shift_right(save_cluster_hint_reg, 7);
                                fat_scan_cluster_reg <= shift_left(shift_right(save_cluster_hint_reg, 7), 7);
                                fat_scan_min_cluster_reg <= save_cluster_hint_reg;
                            ELSE
                                current_lba_reg <= part_lba_reg + resize(boot_reserved_reg, 32);
                                fat_scan_sectors_left_reg <= boot_spf_reg;
                                fat_scan_cluster_reg <= (OTHERS => '0');
                                fat_scan_min_cluster_reg <= to_unsigned(2, 32);
                            END IF;
                            fat_scan_wrap_reg <= '0';
                            fat_scan_run_start_reg <= (OTHERS => '0');
                            fat_scan_run_len_reg <= (OTHERS => '0');
                            save_clusters_needed_reg <= to_unsigned(1, 16);
                            fat_entry_tmp_reg <= (OTHERS => '0');
                            save_write_busy_reg <= '1';
                            save_write_done_reg <= '0';
                            save_write_error_reg <= '0';
                            save_write_status_reg <= SAVE_STATUS_NONE;
                            gap_after_state <= ST_PREP_CMD17;
                            state <= ST_GAP;
                        ELSIF save_check_exists_reg = '0' AND
                            NOT (save_check_can_create_reg = '1' AND save_check_can_allocate_reg = '1') THEN
                            save_write_error_reg <= '1';
                            save_write_status_reg <= SAVE_STATUS_NEEDS_CREATE;
                            IF save_backend_is_cfg_reg = '1' THEN
                                cfg_save_busy_reg <= '0';
                                cfg_save_error_reg <= '1';
                                cfg_request_reg <= CFG_REQ_NONE;
                                save_backend_is_cfg_reg <= '0';
                            END IF;
                            state <= ST_READ_READY;
                        ELSIF save_check_exists_reg = '1' AND
                            (save_check_cluster_reg < to_unsigned(2, 32) OR
                            save_check_size_reg = to_unsigned(0, 32)) THEN
                            save_write_error_reg <= '1';
                            save_write_status_reg <= SAVE_STATUS_NEEDS_CREATE;
                            IF save_backend_is_cfg_reg = '1' THEN
                                cfg_save_busy_reg <= '0';
                                cfg_save_error_reg <= '1';
                                cfg_request_reg <= CFG_REQ_NONE;
                                save_backend_is_cfg_reg <= '0';
                            END IF;
                            state <= ST_READ_READY;
                        ELSE
                            IF save_backend_is_cfg_reg = '1' THEN
                                save_byte_count_reg <= (OTHERS => '0');
                            ELSE
                                save_byte_count_reg <= save_req_end_addr_reg - save_req_start_addr_reg + 1;
                            END IF;
                            state <= ST_SAVE_PREP_CALC;
                        END IF;

                    WHEN ST_SAVE_PREP_CALC =>
                        cs_n_reg <= '1';
                        sclk_reg <= '0';
                        mosi_reg <= '1';

                        IF fdd_format_phase_reg = FDD_FORMAT_CREATE THEN
                            save_stream_len_v := to_unsigned(655360, 32);
                        ELSIF save_backend_is_cfg_reg = '1' THEN
                            save_stream_len_v := CONFIG_STREAM_LEN;
                            cfg_byte7_reg <= CONFIG_VERSION_V4 XOR x"20" XOR cfg_byte4_reg XOR cfg_byte5_reg XOR
                                cfg_byte6_reg XOR cfg_byte8_reg XOR xor_network_payload(cfg_network_payload_reg) XOR x"A5";
                        ELSE
                            save_stream_len_v := calc_nas_stream_len(save_byte_count_reg);
                        END IF;
                        save_stream_len_reg <= save_stream_len_v;
                        state <= ST_SAVE_PREP_SECTORS;

                    WHEN ST_SAVE_PREP_SECTORS =>
                        cs_n_reg <= '1';
                        sclk_reg <= '0';
                        mosi_reg <= '1';

                        save_sector_total_v := round_up_sector_bytes(save_stream_len_reg);
                        save_sector_total_reg <= save_sector_total_v;
                        state <= ST_SAVE_PREP_CLUSTERS;

                    WHEN ST_SAVE_PREP_CLUSTERS =>
                        cs_n_reg <= '1';
                        sclk_reg <= '0';
                        mosi_reg <= '1';

                        save_sector_count_v := shift_right(save_sector_total_reg, 9);
                        IF save_stream_len_reg = to_unsigned(0, 32) OR unsigned(boot_spc_reg) = to_unsigned(0, 8) THEN
                            save_clusters_needed_reg <= to_unsigned(0, 16);
                        ELSE
                            CASE boot_spc_reg IS
                                WHEN x"01" => save_clusters_needed_v := resize(save_sector_count_v(15 DOWNTO 0), 16);
                                WHEN x"02" => save_clusters_needed_v := resize(shift_right(save_sector_count_v + 1, 1)(15 DOWNTO 0), 16);
                                WHEN x"04" => save_clusters_needed_v := resize(shift_right(save_sector_count_v + 3, 2)(15 DOWNTO 0), 16);
                                WHEN x"08" => save_clusters_needed_v := resize(shift_right(save_sector_count_v + 7, 3)(15 DOWNTO 0), 16);
                                WHEN x"10" => save_clusters_needed_v := resize(shift_right(save_sector_count_v + 15, 4)(15 DOWNTO 0), 16);
                                WHEN x"20" => save_clusters_needed_v := resize(shift_right(save_sector_count_v + 31, 5)(15 DOWNTO 0), 16);
                                WHEN x"40" => save_clusters_needed_v := resize(shift_right(save_sector_count_v + 63, 6)(15 DOWNTO 0), 16);
                                WHEN x"80" => save_clusters_needed_v := resize(shift_right(save_sector_count_v + 127, 7)(15 DOWNTO 0), 16);
                                WHEN OTHERS => save_clusters_needed_v := to_unsigned(0, 16);
                            END CASE;
                            save_clusters_needed_reg <= save_clusters_needed_v;
                        END IF;
                        state <= ST_SAVE_PREP_DECIDE;
                    WHEN ST_SAVE_PREP_DECIDE =>
                        cs_n_reg <= '1';
                        sclk_reg <= '0';
                        mosi_reg <= '1';

                        IF save_check_exists_reg = '0' THEN
                            IF save_stream_len_reg = to_unsigned(0, 32) OR save_clusters_needed_reg = to_unsigned(0, 16) THEN
                                save_write_error_reg <= '1';
                                save_write_status_reg <= SAVE_STATUS_CREATE_MULTICLUSTER;
                                state <= ST_READ_READY;
                            ELSIF save_clusters_needed_reg > to_unsigned(1, 16) AND
                                (save_check_can_allocate_reg = '0' OR save_alloc_search_need_reg /= save_clusters_needed_reg) THEN
                                state <= ST_SAVE_PREP_ALLOC_SETUP;
                            ELSIF save_check_can_allocate_reg = '1' THEN
                                state <= ST_SAVE_PREP_CREATE_SETUP;
                            ELSE
                                save_write_error_reg <= '1';
                                save_write_status_reg <= SAVE_STATUS_NEEDS_CREATE;
                                state <= ST_READ_READY;
                            END IF;
                        ELSE
                            save_sector_total_reg <= round_up_sector_bytes(save_check_size_reg);
                            state <= ST_SAVE_PREP_COMMIT;
                        END IF;

                    WHEN ST_SAVE_PREP_ALLOC_SETUP =>
                        cs_n_reg <= '1';
                        sclk_reg <= '0';
                        mosi_reg <= '1';

                        save_check_can_allocate_reg <= '0';
                        save_check_free_cluster_reg <= to_unsigned(1, 32);
                        save_alloc_search_need_reg <= save_clusters_needed_reg;
                        fat_scan_run_start_reg <= (OTHERS => '0');
                        fat_scan_run_len_reg <= (OTHERS => '0');
                        read_job_reg <= JOB_FAT;
                        IF save_cluster_hint_reg > to_unsigned(2, 32) THEN
                            current_lba_reg <= part_lba_reg + resize(boot_reserved_reg, 32) + shift_right(save_cluster_hint_reg, 7);
                            fat_scan_sectors_left_reg <= boot_spf_reg - shift_right(save_cluster_hint_reg, 7);
                            fat_scan_cluster_reg <= shift_left(shift_right(save_cluster_hint_reg, 7), 7);
                            fat_scan_min_cluster_reg <= save_cluster_hint_reg;
                        ELSE
                            current_lba_reg <= part_lba_reg + resize(boot_reserved_reg, 32);
                            fat_scan_sectors_left_reg <= boot_spf_reg;
                            fat_scan_cluster_reg <= (OTHERS => '0');
                            fat_scan_min_cluster_reg <= to_unsigned(2, 32);
                        END IF;
                        fat_scan_wrap_reg <= '0';
                        fat_entry_tmp_reg <= (OTHERS => '0');
                        save_write_busy_reg <= '1';
                        save_write_done_reg <= '0';
                        save_write_error_reg <= '0';
                        save_write_status_reg <= SAVE_STATUS_NONE;
                        gap_after_state <= ST_PREP_CMD17;
                        state <= ST_GAP;

                    WHEN ST_SAVE_PREP_CREATE_SETUP =>
                        cs_n_reg <= '1';
                        sclk_reg <= '0';
                        mosi_reg <= '1';

                        -- Preserve an end marker in the next sector when that
                        -- sector is still part of the current directory
                        -- cluster.  At the cluster boundary the new entry may
                        -- simply become the last occupied directory entry.
                        save_extend_dir_v :=
                            save_check_free_marker_reg = x"00" AND
                            save_check_free_slot_reg = 15 AND
                            save_check_free_lba_reg + 1 <
                                root_dir_lba_reg + resize(unsigned(boot_spc_reg), 32);
                        save_create_extend_dir_reg <= '0';
                        IF save_extend_dir_v THEN
                            save_create_extend_dir_reg <= '1';
                        END IF;
                        save_write_busy_reg <= '1';
                        save_write_done_reg <= '0';
                        save_write_error_reg <= '0';
                        save_write_status_reg <= SAVE_STATUS_NONE;
                        save_verify_expected_cluster_reg <= save_check_free_cluster_reg;
                        save_verify_expected_size_reg <= save_stream_len_reg;
                        save_create_current_cluster_reg <= save_check_free_cluster_reg;
                        save_create_clusters_left_reg <= save_clusters_needed_reg;
                        IF save_backend_is_cfg_reg = '1' THEN
                            save_sector_source_reg <= SAVE_SECTOR_CFG;
                        ELSE
                            save_sector_source_reg <= SAVE_SECTOR_PATCH;
                        END IF;
                        save_create_phase_reg <= SAVE_CREATE_LOAD_FAT;
                        save_fat_copy_index_reg <= 0;
                        save_fat_byte_offset_reg <= to_integer(save_check_free_cluster_reg(6 DOWNTO 0)) * 4;
                        current_lba_reg <= part_lba_reg +
                            resize(boot_reserved_reg, 32) +
                            shift_right(save_check_free_cluster_reg, 7);
                        read_job_reg <= JOB_PATCH;
                        gap_after_state <= ST_PREP_CMD17;
                        state <= ST_GAP;

                    WHEN ST_SAVE_PREP_COMMIT =>
                        cs_n_reg <= '1';
                        sclk_reg <= '0';
                        mosi_reg <= '1';

                        IF save_stream_len_reg = to_unsigned(0, 32) OR
                            (save_backend_is_cfg_reg = '0' AND save_stream_len_reg > save_check_size_reg) THEN
                            save_write_error_reg <= '1';
                            save_write_status_reg <= SAVE_STATUS_TOO_LARGE;
                            IF save_backend_is_cfg_reg = '1' THEN
                                cfg_save_busy_reg <= '0';
                                cfg_save_error_reg <= '1';
                                cfg_request_reg <= CFG_REQ_NONE;
                                save_backend_is_cfg_reg <= '0';
                            END IF;
                            state <= ST_READ_READY;
                        ELSIF save_backend_is_cfg_reg = '1' THEN
                            save_write_busy_reg <= '1';
                            save_write_done_reg <= '0';
                            save_write_error_reg <= '0';
                            save_write_status_reg <= SAVE_STATUS_NONE;
                            save_create_phase_reg <= SAVE_CREATE_PATCH_EXISTING_DIR;
                            save_patch_step_reg <= 0;
                            current_lba_reg <= save_check_match_lba_reg;
                            read_job_reg <= JOB_PATCH;
                            gap_after_state <= ST_PREP_CMD17;
                            state <= ST_GAP;
                        ELSE
                            save_write_busy_reg <= '1';
                            save_lba_pending_reg <= '1';
                            save_sectors_left_reg <= shift_right(save_sector_total_reg, 9);
                            save_pad_bytes_left_reg <= save_sector_total_reg - save_stream_len_reg;
                            save_prog_bytes_left_reg <= save_byte_count_reg;
                            save_verify_expected_cluster_reg <= save_check_cluster_reg;
                            save_verify_expected_size_reg <= save_stream_len_reg;
                            save_line_addr_reg <= save_req_start_addr_reg;
                            save_current_mem_addr_reg <= save_req_start_addr_reg;
                            IF save_byte_count_reg > to_unsigned(8, 16) THEN
                                save_line_len_v := 8;
                            ELSE
                                save_line_len_v := to_integer(save_byte_count_reg);
                            END IF;
                            save_line_data_left_reg <= save_line_len_v;
                            save_mem_addr_reg <= STD_LOGIC_VECTOR(save_req_start_addr_reg);
                            save_mem_byte_reg <= x"00";
                            IF save_backend_is_cfg_reg = '1' THEN
                                save_fmt_state_reg <= SAVE_FMT_DONE;
                                save_sector_source_reg <= SAVE_SECTOR_CFG;
                            ELSE
                                save_fmt_state_reg <= SAVE_FMT_LINE_ADDR3;
                                save_sector_source_reg <= SAVE_SECTOR_NAS;
                            END IF;
                            save_sector_tx_index_reg <= 0;
                            save_tx_byte_reg <= x"20";
                            lba_target_reg <= LBA_TARGET_FILE;
                            lba_cluster_reg <= save_check_cluster_reg;
                            state <= ST_CALC_LBA_BASE;
                        END IF;


                    WHEN ST_FDD_PATCH_SECTOR =>
                        cs_n_reg <= '1';
                        sclk_reg <= '0';
                        mosi_reg <= '1';

                        IF fdd_write_patch_index_reg < 256 THEN
                            save_patch_wr_en_reg <= '1';
                            IF fdd_write_half_reg = '0' THEN
                                save_patch_wr_addr_reg <= STD_LOGIC_VECTOR(
                                    to_unsigned(fdd_write_patch_index_reg, 9));
                            ELSE
                                save_patch_wr_addr_reg <= STD_LOGIC_VECTOR(
                                    to_unsigned(256 + fdd_write_patch_index_reg, 9));
                            END IF;
                            save_patch_wr_data_reg <=
                                fdd_sector_buffer_reg(fdd_write_patch_index_reg);
                            IF fdd_write_half_reg = '0' AND fdd_write_patch_index_reg = 0 THEN
                                save_patch_first_byte_reg <= fdd_sector_buffer_reg(0);
                            END IF;
                            fdd_write_patch_index_reg <= fdd_write_patch_index_reg + 1;
                        ELSE
                            save_sector_source_reg <= SAVE_SECTOR_PATCH;
                            save_create_phase_reg <= SAVE_CREATE_IDLE;
                            save_sector_tx_index_reg <= 0;
                            save_patch_rd_addr_reg <= (OTHERS => '0');
                            save_cmd24_pending_reg <= '1';
                            gap_after_state <= ST_SAVE_BUILD_SECTOR;
                            state <= ST_GAP;
                        END IF;

                    WHEN ST_SAVE_PATCH_SECTOR =>
                        cs_n_reg <= '1';
                        sclk_reg <= '0';
                        mosi_reg <= '1';

                        IF save_create_phase_reg = SAVE_MANAGE_RENAME_DIR THEN
                            save_patch_wr_en_reg <= '1';
                            save_patch_wr_addr_reg <= STD_LOGIC_VECTOR(
                                to_unsigned((manage_match_slot_reg * 32) + save_patch_step_reg, 9));
                            CASE save_patch_step_reg IS
                                WHEN 0 => save_patch_wr_data_reg <= manage_new_name_reg(87 DOWNTO 80);
                                WHEN 1 => save_patch_wr_data_reg <= manage_new_name_reg(79 DOWNTO 72);
                                WHEN 2 => save_patch_wr_data_reg <= manage_new_name_reg(71 DOWNTO 64);
                                WHEN 3 => save_patch_wr_data_reg <= manage_new_name_reg(63 DOWNTO 56);
                                WHEN 4 => save_patch_wr_data_reg <= manage_new_name_reg(55 DOWNTO 48);
                                WHEN 5 => save_patch_wr_data_reg <= manage_new_name_reg(47 DOWNTO 40);
                                WHEN 6 => save_patch_wr_data_reg <= manage_new_name_reg(39 DOWNTO 32);
                                WHEN 7 => save_patch_wr_data_reg <= manage_new_name_reg(31 DOWNTO 24);
                                WHEN 8 => save_patch_wr_data_reg <= manage_new_name_reg(23 DOWNTO 16);
                                WHEN 9 => save_patch_wr_data_reg <= manage_new_name_reg(15 DOWNTO 8);
                                WHEN OTHERS => save_patch_wr_data_reg <= manage_new_name_reg(7 DOWNTO 0);
                            END CASE;
                            IF save_patch_step_reg = 10 THEN
                                save_create_phase_reg <= SAVE_MANAGE_WRITE_RENAME;
                                save_sector_source_reg <= SAVE_SECTOR_PATCH;
                                save_sector_tx_index_reg <= 0;
                                IF manage_match_slot_reg = 0 THEN
                                    save_patch_first_byte_reg <= manage_new_name_reg(87 DOWNTO 80);
                                ELSE
                                    save_patch_first_byte_reg <= manage_match_first_byte_reg;
                                END IF;
                                save_patch_rd_addr_reg <= (OTHERS => '0');
                                save_cmd24_pending_reg <= '1';
                                state <= ST_SAVE_BUILD_SECTOR;
                            ELSE
                                save_patch_step_reg <= save_patch_step_reg + 1;
                            END IF;

                        ELSIF save_create_phase_reg = SAVE_MANAGE_DELETE_DIR THEN
                            save_patch_wr_en_reg <= '1';
                            save_patch_wr_addr_reg <= STD_LOGIC_VECTOR(
                                to_unsigned(manage_match_slot_reg * 32, 9));
                            save_patch_wr_data_reg <= x"E5";
                            save_create_phase_reg <= SAVE_MANAGE_WRITE_DELETE_DIR;
                            save_sector_source_reg <= SAVE_SECTOR_PATCH;
                            save_sector_tx_index_reg <= 0;
                            IF manage_match_slot_reg = 0 THEN
                                save_patch_first_byte_reg <= x"E5";
                            ELSE
                                save_patch_first_byte_reg <= manage_match_first_byte_reg;
                            END IF;
                            save_patch_rd_addr_reg <= (OTHERS => '0');
                            save_cmd24_pending_reg <= '1';
                            state <= ST_SAVE_BUILD_SECTOR;

                        ELSIF save_create_phase_reg = SAVE_MANAGE_DELETE_FAT THEN
                            save_patch_wr_en_reg <= '1';
                            save_patch_wr_addr_reg <= STD_LOGIC_VECTOR(
                                to_unsigned(manage_fat_offset_reg + save_patch_step_reg, 9));
                            save_patch_wr_data_reg <= x"00";
                            IF manage_fat_offset_reg = 0 AND save_patch_step_reg = 0 THEN
                                save_patch_first_byte_reg <= x"00";
                            END IF;
                            IF save_patch_step_reg = 3 THEN
                                save_create_phase_reg <= SAVE_MANAGE_WRITE_DELETE_FAT;
                                save_sector_source_reg <= SAVE_SECTOR_PATCH;
                                save_sector_tx_index_reg <= 0;
                                save_patch_rd_addr_reg <= (OTHERS => '0');
                                save_cmd24_pending_reg <= '1';
                                state <= ST_SAVE_BUILD_SECTOR;
                            ELSE
                                save_patch_step_reg <= save_patch_step_reg + 1;
                            END IF;

                        ELSIF save_create_phase_reg = SAVE_CREATE_LOAD_FAT THEN
                            save_patch_wr_en_reg <= '1';
                            save_patch_wr_addr_reg <= STD_LOGIC_VECTOR(to_unsigned(save_fat_byte_offset_reg + save_patch_step_reg, 9));
                            save_create_next_cluster_v := resize(save_create_current_cluster_reg + 1, 32);
                            CASE save_patch_step_reg IS
                                WHEN 0 =>
                                    IF save_create_clusters_left_reg > to_unsigned(1, 16) THEN
                                        save_patch_wr_data_reg <= STD_LOGIC_VECTOR(save_create_next_cluster_v(7 DOWNTO 0));
                                        IF save_fat_byte_offset_reg = 0 THEN
                                            -- Patch sectors have a dedicated copy of byte
                                            -- zero to hide the registered BRAM read latency.
                                            -- Keep that copy coherent when a FAT chain
                                            -- crosses into the first entry of a new sector.
                                            save_patch_first_byte_reg <=
                                                STD_LOGIC_VECTOR(save_create_next_cluster_v(7 DOWNTO 0));
                                        END IF;
                                    ELSE
                                        save_patch_wr_data_reg <= x"FF";
                                        IF save_fat_byte_offset_reg = 0 THEN
                                            save_patch_first_byte_reg <= x"FF";
                                        END IF;
                                    END IF;
                                WHEN 1 =>
                                    IF save_create_clusters_left_reg > to_unsigned(1, 16) THEN
                                        save_patch_wr_data_reg <= STD_LOGIC_VECTOR(save_create_next_cluster_v(15 DOWNTO 8));
                                    ELSE
                                        save_patch_wr_data_reg <= x"FF";
                                    END IF;
                                WHEN 2 =>
                                    IF save_create_clusters_left_reg > to_unsigned(1, 16) THEN
                                        save_patch_wr_data_reg <= STD_LOGIC_VECTOR(save_create_next_cluster_v(23 DOWNTO 16));
                                    ELSE
                                        save_patch_wr_data_reg <= x"FF";
                                    END IF;
                                WHEN OTHERS =>
                                    IF save_create_clusters_left_reg > to_unsigned(1, 16) THEN
                                        save_patch_wr_data_reg <= STD_LOGIC_VECTOR(save_create_next_cluster_v(31 DOWNTO 24));
                                    ELSE
                                        save_patch_wr_data_reg <= x"0F";
                                    END IF;
                            END CASE;

                            IF save_patch_step_reg = 3 THEN
                                IF save_create_clusters_left_reg > to_unsigned(1, 16) AND save_fat_byte_offset_reg < 508 THEN
                                    save_create_current_cluster_reg <= save_create_current_cluster_reg + 1;
                                    save_create_clusters_left_reg <= save_create_clusters_left_reg - 1;
                                    save_fat_byte_offset_reg <= save_fat_byte_offset_reg + 4;
                                    save_patch_step_reg <= 0;
                                ELSE
                                    IF save_create_clusters_left_reg > to_unsigned(1, 16) THEN
                                        save_create_current_cluster_reg <= save_create_current_cluster_reg + 1;
                                        save_create_clusters_left_reg <= save_create_clusters_left_reg - 1;
                                    ELSE
                                        save_create_clusters_left_reg <= (OTHERS => '0');
                                    END IF;
                                    save_create_phase_reg <= SAVE_CREATE_WRITE_FAT;
                                    save_sector_source_reg <= SAVE_SECTOR_PATCH;
                                    save_sector_tx_index_reg <= 0;
                                    save_patch_rd_addr_reg <= (OTHERS => '0');
                                    save_cmd24_pending_reg <= '1';
                                    state <= ST_SAVE_BUILD_SECTOR;
                                END IF;
                            ELSE
                                save_patch_step_reg <= save_patch_step_reg + 1;
                            END IF;

                        ELSIF save_create_phase_reg = SAVE_CREATE_LOAD_DIR THEN
                            save_patch_wr_en_reg <= '1';
                            IF save_patch_step_reg = 32 THEN
                                save_patch_wr_addr_reg <= STD_LOGIC_VECTOR(to_unsigned((save_check_free_slot_reg * 32) + 32, 9));
                                save_patch_wr_data_reg <= x"00";
                            ELSE
                                save_patch_wr_addr_reg <= STD_LOGIC_VECTOR(to_unsigned((save_check_free_slot_reg * 32) + save_patch_step_reg, 9));
                                CASE save_patch_step_reg IS
                                    WHEN 0 =>
                                        save_patch_wr_data_reg <= save_check_name_reg(87 DOWNTO 80);
                                    WHEN 1 =>
                                        save_patch_wr_data_reg <= save_check_name_reg(79 DOWNTO 72);
                                    WHEN 2 =>
                                        save_patch_wr_data_reg <= save_check_name_reg(71 DOWNTO 64);
                                    WHEN 3 =>
                                        save_patch_wr_data_reg <= save_check_name_reg(63 DOWNTO 56);
                                    WHEN 4 =>
                                        save_patch_wr_data_reg <= save_check_name_reg(55 DOWNTO 48);
                                    WHEN 5 =>
                                        save_patch_wr_data_reg <= save_check_name_reg(47 DOWNTO 40);
                                    WHEN 6 =>
                                        save_patch_wr_data_reg <= save_check_name_reg(39 DOWNTO 32);
                                    WHEN 7 =>
                                        save_patch_wr_data_reg <= save_check_name_reg(31 DOWNTO 24);
                                    WHEN 8 =>
                                        save_patch_wr_data_reg <= save_check_name_reg(23 DOWNTO 16);
                                    WHEN 9 =>
                                        save_patch_wr_data_reg <= save_check_name_reg(15 DOWNTO 8);
                                    WHEN 10 =>
                                        save_patch_wr_data_reg <= save_check_name_reg(7 DOWNTO 0);
                                    WHEN 11 =>
                                        IF save_backend_is_cfg_reg = '1' THEN
                                            save_patch_wr_data_reg <= x"22";
                                        ELSE
                                            save_patch_wr_data_reg <= x"20";
                                        END IF;
                                    WHEN 20 =>
                                        save_patch_wr_data_reg <= STD_LOGIC_VECTOR(save_check_free_cluster_reg(23 DOWNTO 16));
                                    WHEN 21 =>
                                        save_patch_wr_data_reg <= STD_LOGIC_VECTOR(save_check_free_cluster_reg(31 DOWNTO 24));
                                    WHEN 26 =>
                                        save_patch_wr_data_reg <= STD_LOGIC_VECTOR(save_check_free_cluster_reg(7 DOWNTO 0));
                                    WHEN 27 =>
                                        save_patch_wr_data_reg <= STD_LOGIC_VECTOR(save_check_free_cluster_reg(15 DOWNTO 8));
                                    WHEN 28 =>
                                        save_patch_wr_data_reg <= STD_LOGIC_VECTOR(save_stream_len_reg(7 DOWNTO 0));
                                    WHEN 29 =>
                                        save_patch_wr_data_reg <= STD_LOGIC_VECTOR(save_stream_len_reg(15 DOWNTO 8));
                                    WHEN 30 =>
                                        save_patch_wr_data_reg <= STD_LOGIC_VECTOR(save_stream_len_reg(23 DOWNTO 16));
                                    WHEN 31 =>
                                        save_patch_wr_data_reg <= STD_LOGIC_VECTOR(save_stream_len_reg(31 DOWNTO 24));
                                    WHEN OTHERS =>
                                        save_patch_wr_data_reg <= x"00";
                                END CASE;
                            END IF;

                            IF save_patch_step_reg = 31 AND
                                NOT (save_check_free_marker_reg = x"00" AND save_check_free_slot_reg < 15) THEN
                                save_create_phase_reg <= SAVE_CREATE_WRITE_DIR;
                                save_sector_source_reg <= SAVE_SECTOR_PATCH;
                                save_sector_tx_index_reg <= 0;
                                IF save_check_free_slot_reg = 0 THEN
                                    save_patch_first_byte_reg <= save_check_name_reg(87 DOWNTO 80);
                                    save_verify_dir_first_byte_reg <= save_check_name_reg(87 DOWNTO 80);
                                ELSE
                                    save_patch_first_byte_reg <= save_check_free_sector_first_byte_reg;
                                    save_verify_dir_first_byte_reg <= save_check_free_sector_first_byte_reg;
                                END IF;
                                save_verify_dir_lba_reg <= save_check_free_lba_reg;
                                save_patch_rd_addr_reg <= (OTHERS => '0');
                                save_cmd24_pending_reg <= '1';
                                state <= ST_SAVE_BUILD_SECTOR;
                            ELSIF save_patch_step_reg = 32 AND
                                save_check_free_marker_reg = x"00" AND save_check_free_slot_reg < 15 THEN
                                save_create_phase_reg <= SAVE_CREATE_WRITE_DIR;
                                save_sector_source_reg <= SAVE_SECTOR_PATCH;
                                save_sector_tx_index_reg <= 0;
                                IF save_check_free_slot_reg = 0 THEN
                                    save_patch_first_byte_reg <= save_check_name_reg(87 DOWNTO 80);
                                    save_verify_dir_first_byte_reg <= save_check_name_reg(87 DOWNTO 80);
                                ELSE
                                    save_patch_first_byte_reg <= save_check_free_sector_first_byte_reg;
                                    save_verify_dir_first_byte_reg <= save_check_free_sector_first_byte_reg;
                                END IF;
                                save_verify_dir_lba_reg <= save_check_free_lba_reg;
                                save_patch_rd_addr_reg <= (OTHERS => '0');
                                save_cmd24_pending_reg <= '1';
                                state <= ST_SAVE_BUILD_SECTOR;
                            ELSE
                                save_patch_step_reg <= save_patch_step_reg + 1;
                            END IF;
                        ELSIF save_create_phase_reg = SAVE_CREATE_LOAD_DIR_NEXT THEN
                            save_patch_wr_en_reg <= '1';
                            save_patch_wr_addr_reg <= (OTHERS => '0');
                            save_patch_wr_data_reg <= x"00";
                            save_create_phase_reg <= SAVE_CREATE_WRITE_DIR_NEXT;
                            save_sector_source_reg <= SAVE_SECTOR_PATCH;
                            save_sector_tx_index_reg <= 0;
                            save_patch_rd_addr_reg <= (OTHERS => '0');
                            save_cmd24_pending_reg <= '1';
                            state <= ST_SAVE_BUILD_SECTOR;
                        ELSIF save_create_phase_reg = SAVE_CREATE_RENAME_DSK THEN
                            save_patch_wr_en_reg <= '1';
                            save_patch_wr_addr_reg <= STD_LOGIC_VECTOR(
                                to_unsigned((save_check_match_slot_reg * 32) + save_patch_step_reg, 9));
                            CASE save_patch_step_reg IS
                                WHEN 0 => save_patch_wr_data_reg <= fdd_format_bak_name_reg(87 DOWNTO 80);
                                WHEN 1 => save_patch_wr_data_reg <= fdd_format_bak_name_reg(79 DOWNTO 72);
                                WHEN 2 => save_patch_wr_data_reg <= fdd_format_bak_name_reg(71 DOWNTO 64);
                                WHEN 3 => save_patch_wr_data_reg <= fdd_format_bak_name_reg(63 DOWNTO 56);
                                WHEN 4 => save_patch_wr_data_reg <= fdd_format_bak_name_reg(55 DOWNTO 48);
                                WHEN 5 => save_patch_wr_data_reg <= fdd_format_bak_name_reg(47 DOWNTO 40);
                                WHEN 6 => save_patch_wr_data_reg <= fdd_format_bak_name_reg(39 DOWNTO 32);
                                WHEN 7 => save_patch_wr_data_reg <= fdd_format_bak_name_reg(31 DOWNTO 24);
                                WHEN 8 => save_patch_wr_data_reg <= fdd_format_bak_name_reg(23 DOWNTO 16);
                                WHEN 9 => save_patch_wr_data_reg <= fdd_format_bak_name_reg(15 DOWNTO 8);
                                WHEN OTHERS => save_patch_wr_data_reg <= fdd_format_bak_name_reg(7 DOWNTO 0);
                            END CASE;

                            IF save_patch_step_reg = 10 THEN
                                save_create_phase_reg <= SAVE_CREATE_WRITE_RENAME;
                                save_sector_source_reg <= SAVE_SECTOR_PATCH;
                                save_sector_tx_index_reg <= 0;
                                IF save_check_match_slot_reg = 0 THEN
                                    save_patch_first_byte_reg <= fdd_format_bak_name_reg(87 DOWNTO 80);
                                ELSE
                                    save_patch_first_byte_reg <= save_check_match_sector_first_byte_reg;
                                END IF;
                                save_patch_rd_addr_reg <= (OTHERS => '0');
                                save_cmd24_pending_reg <= '1';
                                state <= ST_SAVE_BUILD_SECTOR;
                            ELSE
                                save_patch_step_reg <= save_patch_step_reg + 1;
                            END IF;
                        ELSIF save_create_phase_reg = SAVE_CREATE_PATCH_EXISTING_DIR THEN
                            save_patch_wr_en_reg <= '1';
                            save_patch_wr_addr_reg <= STD_LOGIC_VECTOR(to_unsigned((save_check_match_slot_reg * 32) + 28 + save_patch_step_reg, 9));
                            CASE save_patch_step_reg IS
                                WHEN 0 =>
                                    save_patch_wr_data_reg <= STD_LOGIC_VECTOR(CONFIG_STREAM_LEN(7 DOWNTO 0));
                                WHEN 1 =>
                                    save_patch_wr_data_reg <= STD_LOGIC_VECTOR(CONFIG_STREAM_LEN(15 DOWNTO 8));
                                WHEN 2 =>
                                    save_patch_wr_data_reg <= STD_LOGIC_VECTOR(CONFIG_STREAM_LEN(23 DOWNTO 16));
                                WHEN OTHERS =>
                                    save_patch_wr_data_reg <= STD_LOGIC_VECTOR(CONFIG_STREAM_LEN(31 DOWNTO 24));
                            END CASE;

                            IF save_patch_step_reg = 3 THEN
                                save_sector_source_reg <= SAVE_SECTOR_PATCH;
                                save_sector_tx_index_reg <= 0;
                                save_patch_first_byte_reg <= save_check_match_sector_first_byte_reg;
                                save_verify_dir_first_byte_reg <= save_check_match_sector_first_byte_reg;
                                save_verify_dir_lba_reg <= save_check_match_lba_reg;
                                save_patch_rd_addr_reg <= (OTHERS => '0');
                                save_cmd24_pending_reg <= '1';
                                state <= ST_SAVE_BUILD_SECTOR;
                            ELSE
                                save_patch_step_reg <= save_patch_step_reg + 1;
                            END IF;
                        ELSE
                            save_write_busy_reg <= '0';
                            save_write_error_reg <= '1';
                            save_write_status_reg <= SAVE_STATUS_ERR_CREATE_PHASE;
                            IF save_backend_is_cfg_reg = '1' THEN
                                cfg_save_busy_reg <= '0';
                                cfg_save_error_reg <= '1';
                                cfg_request_reg <= CFG_REQ_NONE;
                                save_backend_is_cfg_reg <= '0';
                            END IF;
                            state <= ST_READ_READY;
                        END IF;
                    WHEN ST_FINISH_ROOT_SCAN =>
                        cs_n_reg <= '1';
                        sclk_reg <= '0';
                        mosi_reg <= '1';

                        browser_page_reload_reg <= '0';

                        IF root_scan_job_reg = ROOT_SCAN_MANAGE THEN
                            root_scan_job_reg <= ROOT_SCAN_DISCOVER;
                            IF manage_found_reg = '0' THEN
                                manage_busy_reg <= '0';
                                manage_error_reg <= '1';
                                manage_status_reg <= MANAGE_STATUS_NOT_FOUND;
                                read_done_reg <= '1';
                                gap_after_state <= ST_READ_READY;
                                state <= ST_GAP;
                            ELSIF manage_lfn_reg = '1' THEN
                                -- Leave long-name groups untouched.  The compact
                                -- browser manager deliberately handles plain 8.3
                                -- entries only, avoiding orphaned or stale LFNs.
                                manage_busy_reg <= '0';
                                manage_error_reg <= '1';
                                manage_status_reg <= MANAGE_STATUS_LFN;
                                read_done_reg <= '1';
                                gap_after_state <= ST_READ_READY;
                                state <= ST_GAP;
                            ELSIF manage_read_only_reg = '1' THEN
                                manage_busy_reg <= '0';
                                manage_error_reg <= '1';
                                manage_status_reg <= MANAGE_STATUS_READ_ONLY;
                                read_done_reg <= '1';
                                gap_after_state <= ST_READ_READY;
                                state <= ST_GAP;
                            ELSIF manage_delete_reg = '0' AND manage_duplicate_reg = '1' THEN
                                manage_busy_reg <= '0';
                                manage_error_reg <= '1';
                                manage_status_reg <= MANAGE_STATUS_NAME_EXISTS;
                                read_done_reg <= '1';
                                gap_after_state <= ST_READ_READY;
                                state <= ST_GAP;
                            ELSE
                                IF manage_delete_reg = '1' THEN
                                    save_create_phase_reg <= SAVE_MANAGE_DELETE_DIR;
                                ELSE
                                    save_create_phase_reg <= SAVE_MANAGE_RENAME_DIR;
                                END IF;
                                current_lba_reg <= manage_match_lba_reg;
                                read_job_reg <= JOB_PATCH;
                                gap_after_state <= ST_PREP_CMD17;
                                state <= ST_GAP;
                            END IF;

                        ELSIF root_scan_job_reg = ROOT_SCAN_SAVE_CHECK THEN
                            IF fdd_format_phase_reg = FDD_FORMAT_CHECK_BAK THEN
                                save_check_busy_reg <= '0';
                                IF save_check_exists_reg = '1' THEN
                                    -- Never overwrite an existing backup.
                                    fdd_format_busy_reg <= '0';
                                    fdd_format_error_reg <= '1';
                                    fdd_format_phase_reg <= FDD_FORMAT_IDLE;
                                    save_write_busy_reg <= '0';
                                    save_write_error_reg <= '1';
                                    save_write_status_reg <= FDD_FORMAT_STATUS_BAK_EXISTS;
                                    root_scan_job_reg <= ROOT_SCAN_DISCOVER;
                                    read_done_reg <= '1';
                                    gap_after_state <= ST_READ_READY;
                                    state <= ST_GAP;
                                ELSIF save_check_can_create_reg = '0' THEN
                                    fdd_format_busy_reg <= '0';
                                    fdd_format_error_reg <= '1';
                                    fdd_format_phase_reg <= FDD_FORMAT_IDLE;
                                    save_write_busy_reg <= '0';
                                    save_write_error_reg <= '1';
                                    save_write_status_reg <= FDD_FORMAT_STATUS_NO_DIR_SLOT;
                                    root_scan_job_reg <= ROOT_SCAN_DISCOVER;
                                    read_done_reg <= '1';
                                    gap_after_state <= ST_READ_READY;
                                    state <= ST_GAP;
                                ELSIF save_check_requires_dir_growth_reg = '1' THEN
                                    fdd_format_busy_reg <= '0';
                                    fdd_format_error_reg <= '1';
                                    fdd_format_phase_reg <= FDD_FORMAT_IDLE;
                                    save_write_busy_reg <= '0';
                                    save_write_error_reg <= '1';
                                    save_write_status_reg <= FDD_FORMAT_STATUS_DIR_GROWTH;
                                    root_scan_job_reg <= ROOT_SCAN_DISCOVER;
                                    read_done_reg <= '1';
                                    gap_after_state <= ST_READ_READY;
                                    state <= ST_GAP;
                                ELSE
                                    fdd_format_phase_reg <= FDD_FORMAT_FIND_DSK;
                                    save_check_name_reg <= fdd_format_name_reg;
                                    save_check_busy_reg <= '1';
                                    save_check_exists_reg <= '0';
                                    save_check_can_create_reg <= '0';
                                    save_check_requires_dir_growth_reg <= '0';
                                    save_check_dir_full_reg <= '0';
                                    save_check_cluster_reg <= (OTHERS => '0');
                                    save_check_size_reg <= (OTHERS => '0');
                                    save_check_match_lba_reg <= (OTHERS => '0');
                                    save_check_match_slot_reg <= 0;
                                    save_check_match_sector_first_byte_reg <= x"00";
                                    lba_target_reg <= LBA_TARGET_ROOT;
                                    lba_cluster_reg <= browser_dir_cluster_reg;
                                    root_current_cluster_reg <= browser_dir_cluster_reg;
                                    root_chain_advance_reg <= '0';
                                    root_scan_phase_reg <= ROOT_SCAN_LIST_FILES;
                                    state <= ST_CALC_LBA_BASE;
                                END IF;

                            ELSIF fdd_format_phase_reg = FDD_FORMAT_FIND_DSK THEN
                                save_check_busy_reg <= '0';
                                IF save_check_exists_reg = '0' THEN
                                    fdd_format_busy_reg <= '0';
                                    fdd_format_error_reg <= '1';
                                    fdd_format_phase_reg <= FDD_FORMAT_IDLE;
                                    save_write_busy_reg <= '0';
                                    save_write_error_reg <= '1';
                                    save_write_status_reg <= FDD_FORMAT_STATUS_DSK_MISSING;
                                    root_scan_job_reg <= ROOT_SCAN_DISCOVER;
                                    read_done_reg <= '1';
                                    gap_after_state <= ST_READ_READY;
                                    state <= ST_GAP;
                                ELSIF save_check_cluster_reg /= fdd_format_old_cluster_reg THEN
                                    fdd_format_busy_reg <= '0';
                                    fdd_format_error_reg <= '1';
                                    fdd_format_phase_reg <= FDD_FORMAT_IDLE;
                                    save_write_busy_reg <= '0';
                                    save_write_error_reg <= '1';
                                    save_write_status_reg <= FDD_FORMAT_STATUS_CLUSTER_MISMATCH;
                                    root_scan_job_reg <= ROOT_SCAN_DISCOVER;
                                    read_done_reg <= '1';
                                    gap_after_state <= ST_READ_READY;
                                    state <= ST_GAP;
                                ELSIF save_check_size_reg /= to_unsigned(655360, 32) THEN
                                    fdd_format_busy_reg <= '0';
                                    fdd_format_error_reg <= '1';
                                    fdd_format_phase_reg <= FDD_FORMAT_IDLE;
                                    save_write_busy_reg <= '0';
                                    save_write_error_reg <= '1';
                                    save_write_status_reg <= FDD_FORMAT_STATUS_SIZE_MISMATCH;
                                    root_scan_job_reg <= ROOT_SCAN_DISCOVER;
                                    read_done_reg <= '1';
                                    gap_after_state <= ST_READ_READY;
                                    state <= ST_GAP;
                                ELSE
                                    fdd_format_phase_reg <= FDD_FORMAT_RENAME;
                                    save_create_phase_reg <= SAVE_CREATE_RENAME_DSK;
                                    save_patch_step_reg <= 0;
                                    current_lba_reg <= save_check_match_lba_reg;
                                    read_job_reg <= JOB_PATCH;
                                    gap_after_state <= ST_PREP_CMD17;
                                    state <= ST_GAP;
                                END IF;

                            ELSIF fdd_format_phase_reg = FDD_FORMAT_FIND_FREE THEN
                                save_check_busy_reg <= '0';
                                IF save_check_exists_reg = '1' OR
                                    save_check_can_create_reg = '0' THEN
                                    fdd_format_busy_reg <= '0';
                                    fdd_format_error_reg <= '1';
                                    fdd_format_phase_reg <= FDD_FORMAT_IDLE;
                                    save_write_busy_reg <= '0';
                                    save_write_error_reg <= '1';
                                    save_write_status_reg <= FDD_FORMAT_STATUS_NO_DIR_SLOT;
                                    root_scan_job_reg <= ROOT_SCAN_DISCOVER;
                                    read_done_reg <= '1';
                                    gap_after_state <= ST_READ_READY;
                                    state <= ST_GAP;
                                ELSIF save_check_requires_dir_growth_reg = '1' THEN
                                    fdd_format_busy_reg <= '0';
                                    fdd_format_error_reg <= '1';
                                    fdd_format_phase_reg <= FDD_FORMAT_IDLE;
                                    save_write_busy_reg <= '0';
                                    save_write_error_reg <= '1';
                                    save_write_status_reg <= FDD_FORMAT_STATUS_DIR_GROWTH;
                                    root_scan_job_reg <= ROOT_SCAN_DISCOVER;
                                    read_done_reg <= '1';
                                    gap_after_state <= ST_READ_READY;
                                    state <= ST_GAP;
                                ELSE
                                    fdd_format_phase_reg <= FDD_FORMAT_CREATE;
                                    save_check_can_allocate_reg <= '0';
                                    save_check_free_cluster_reg <= (OTHERS => '0');
                                    save_alloc_search_need_reg <= to_unsigned(1, 16);
                                    state <= ST_SAVE_PREP_CALC;
                                END IF;

                            ELSIF save_verify_pending_reg = '1' THEN
                                save_check_busy_reg <= '0';
                                save_verify_pending_reg <= '0';

                                IF save_check_exists_reg = '1' AND
                                    save_verify_dir_byte_ok_reg = '1' AND
                                    save_check_cluster_reg = save_verify_expected_cluster_reg AND
                                    ((save_backend_is_cfg_reg = '1' AND
                                    save_check_size_reg >= CONFIG_STREAM_LEN) OR
                                    (save_backend_is_cfg_reg = '0' AND
                                    save_check_size_reg = save_verify_expected_size_reg)) THEN

                                    save_write_busy_reg <= '0';
                                    save_write_done_reg <= '1';
                                    save_write_error_reg <= '0';
                                    save_write_status_reg <= SAVE_STATUS_DONE;

                                    IF save_backend_is_cfg_reg = '1' THEN
                                        cfg_save_recheck_reg <= '0';
                                        cfg_save_busy_reg <= '0';
                                        cfg_save_done_reg <= '1';
                                        cfg_save_error_reg <= '0';
                                        cfg_request_reg <= CFG_REQ_NONE;
                                        save_backend_is_cfg_reg <= '0';
                                    END IF;

                                    browser_page_dirty_reg <= '1';
                                    save_cluster_hint_reg <= save_verify_expected_cluster_reg + 1;
                                    browser_rescan_pending_reg <= '1';
                                ELSE
                                    save_write_busy_reg <= '0';
                                    save_write_done_reg <= '0';
                                    save_write_error_reg <= '1';
                                    save_write_status_reg <= SAVE_STATUS_ERR_VERIFY;

                                    IF save_backend_is_cfg_reg = '1' THEN
                                        cfg_save_busy_reg <= '0';
                                        cfg_save_done_reg <= '0';
                                        cfg_save_error_reg <= '1';
                                        cfg_request_reg <= CFG_REQ_NONE;
                                        save_backend_is_cfg_reg <= '0';
                                    END IF;
                                END IF;

                                root_scan_job_reg <= ROOT_SCAN_DISCOVER;
                                read_done_reg <= '1';
                                gap_after_state <= ST_READ_READY;
                                state <= ST_GAP;

                            ELSIF cfg_request_reg = CFG_REQ_LOAD THEN
                                save_check_busy_reg <= '0';
                                cfg_load_busy_reg <= '0';

                                IF save_check_exists_reg = '1' AND
                                    save_check_cluster_reg >= to_unsigned(2, 32) AND
                                    save_check_size_reg >= CONFIG_STREAM_LEN_OLD THEN

                                    read_job_reg <= JOB_CFG;
                                    read_done_reg <= '0';
                                    read_error_reg <= '0';
                                    read_token_reg <= x"FF";
                                    read_byte_count_reg <= (OTHERS => '0');
                                    read_first_word_reg <= x"00000000";
                                    read_signature_reg <= x"0000";
                                    cfg_parse_byte4_reg <= x"00";
                                    cfg_parse_byte5_reg <= x"00";
                                    cfg_parse_byte6_reg <= x"00";
                                    cfg_parse_byte7_reg <= x"00";
                                    cfg_parse_byte8_reg <= x"00";
                                    cfg_parse_byte9_reg <= x"00";
                                    cfg_parse_byte14_reg <= x"00";
                                    cfg_parse_network_payload_reg <= (OTHERS => '0');
                                    cfg_parse_byte30_reg <= x"00";
                                    file_bytes_left_reg <= save_check_size_reg;
                                    lba_target_reg <= LBA_TARGET_FILE;
                                    lba_cluster_reg <= save_check_cluster_reg;
                                    root_scan_job_reg <= ROOT_SCAN_DISCOVER;
                                    gap_after_state <= ST_CALC_LBA_BASE;
                                    state <= ST_GAP;
                                ELSE
                                    cfg_load_done_reg <= '1';
                                    cfg_request_reg <= CFG_REQ_NONE;
                                    root_scan_job_reg <= ROOT_SCAN_DISCOVER;
                                    browser_cache_valid_reg <= '0';
                                    browser_rescan_pending_reg <= '1';
                                    read_done_reg <= '1';
                                    gap_after_state <= ST_READ_READY;
                                    state <= ST_GAP;
                                END IF;

                            ELSIF cfg_request_reg = CFG_REQ_SAVE THEN
                                save_check_busy_reg <= '0';
                                IF save_check_exists_reg = '0' AND cfg_save_recheck_reg = '0' THEN
                                    -- Never allocate after just one negative
                                    -- lookup. Repeat the scan from the first
                                    -- directory cluster; this also covers a
                                    -- save requested immediately after reset.
                                    -- Keep the free directory slot established
                                    -- by the complete first scan. The second
                                    -- scan may still replace it by finding the
                                    -- existing config entry, but must not turn
                                    -- a valid create request into DIR_FULL.
                                    cfg_save_recheck_reg <= '1';
                                    save_check_busy_reg <= '1';
                                    save_check_exists_reg <= '0';
                                    save_check_can_allocate_reg <= '0';
                                    save_check_cluster_reg <= (OTHERS => '0');
                                    save_check_size_reg <= (OTHERS => '0');
                                    save_check_free_cluster_reg <= (OTHERS => '0');
                                    save_check_match_lba_reg <= (OTHERS => '0');
                                    save_check_match_slot_reg <= 0;
                                    save_check_match_sector_first_byte_reg <= x"00";
                                    lba_target_reg <= LBA_TARGET_ROOT;
                                    lba_cluster_reg <= browser_dir_cluster_reg;
                                    root_current_cluster_reg <= browser_dir_cluster_reg;
                                    root_chain_advance_reg <= '0';
                                    browser_page_reload_reg <= '0';
                                    root_scan_phase_reg <= ROOT_SCAN_LIST_FILES;
                                    root_scan_job_reg <= ROOT_SCAN_SAVE_CHECK;
                                    -- The preceding directory read has only
                                    -- just released CS. Clock a complete
                                    -- $FF byte with CS high before issuing
                                    -- the first CMD17 of the confirmation
                                    -- scan; otherwise some cards interpret
                                    -- the following command out of phase.
                                    gap_after_state <= ST_CALC_LBA_BASE;
                                    state <= ST_GAP;
                                ELSE
                                    cfg_save_recheck_reg <= '0';
                                    save_req_start_addr_reg <= (OTHERS => '0');
                                    save_req_end_addr_reg <= (OTHERS => '0');
                                    save_backend_is_cfg_reg <= '1';
                                    root_scan_job_reg <= ROOT_SCAN_DISCOVER;
                                    state <= ST_SAVE_PREP_REQUEST;
                                END IF;

                            ELSE
                                IF save_check_exists_reg = '0' AND
                                    save_check_can_create_reg = '1' AND
                                    save_check_requires_dir_growth_reg = '0' AND
                                    save_check_free_cluster_reg = to_unsigned(0, 32) THEN
                                    save_check_can_allocate_reg <= '0';
                                    save_check_free_cluster_reg <= to_unsigned(1, 32);
                            save_alloc_search_need_reg <= to_unsigned(1, 16);
                                    read_job_reg <= JOB_FAT;
                                    IF save_cluster_hint_reg > to_unsigned(2, 32) THEN
                                        current_lba_reg <= part_lba_reg + resize(boot_reserved_reg, 32) + shift_right(save_cluster_hint_reg, 7);
                                        fat_scan_sectors_left_reg <= boot_spf_reg - shift_right(save_cluster_hint_reg, 7);
                                        fat_scan_cluster_reg <= shift_left(shift_right(save_cluster_hint_reg, 7), 7);
                                        fat_scan_min_cluster_reg <= save_cluster_hint_reg;
                                    ELSE
                                        current_lba_reg <= part_lba_reg + resize(boot_reserved_reg, 32);
                                        fat_scan_sectors_left_reg <= boot_spf_reg;
                                        fat_scan_cluster_reg <= (OTHERS => '0');
                                        fat_scan_min_cluster_reg <= to_unsigned(2, 32);
                                    END IF;
                                    fat_scan_wrap_reg <= '0';
                                    fat_scan_run_start_reg <= (OTHERS => '0');
                                    fat_scan_run_len_reg <= (OTHERS => '0');
                                    save_clusters_needed_reg <= to_unsigned(1, 16);
                                    fat_entry_tmp_reg <= (OTHERS => '0');
                                    root_scan_job_reg <= ROOT_SCAN_DISCOVER;
                                    gap_after_state <= ST_PREP_CMD17;
                                    state <= ST_GAP;
                                ELSE
                                    save_check_busy_reg <= '0';

                                    IF save_check_exists_reg = '0' AND save_check_can_create_reg = '0' THEN
                                        save_check_dir_full_reg <= '1';
                                    END IF;

                                    save_check_done_reg <= '1';
                                    root_scan_job_reg <= ROOT_SCAN_DISCOVER;
                                    read_done_reg <= '1';
                                    gap_after_state <= ST_READ_READY;
                                    state <= ST_GAP;
                                END IF;
                            END IF;

                        ELSE
                            IF root_scan_job_reg = ROOT_SCAN_DISCOVER THEN
                                browser_cache_valid_reg <= '1';
                                dsk_probe_active_reg <= '1';
                                dsk_probe_index_reg <= 0;
                                read_done_reg <= '0';
                            ELSE
                                read_done_reg <= '1';
                            END IF;
                            gap_after_state <= ST_READ_READY;
                            state <= ST_GAP;
                        END IF;
                    WHEN ST_GAP =>
                        cs_n_reg <= '1';
                        IF byte_done_v THEN
                            state <= gap_after_state;
                        ELSIF byte_busy = '0' THEN
                            queue_byte_v := TRUE;
                            queue_data_v := x"FF";
                        END IF;

                    WHEN ST_READ_READY =>
                        cs_n_reg <= '1';
                        sclk_reg <= '0';
                        mosi_reg <= '1';
                        IF read_job_reg = JOB_ROOT AND read_done_reg = '0' AND read_error_reg = '0' THEN
                            read_done_reg <= '1';
                        END IF;
                        IF fdd_write_complete_pending_reg = '1' THEN
                            fdd_write_complete_pending_reg <= '0';
                            fdd_write_busy_reg <= '0';
                            fdd_write_done_reg <= '1';
                            fdd_write_error_reg <= '0';
                        ELSIF dsk_probe_active_reg = '1' THEN
                            IF read_error_reg = '1' THEN
                                file_kind_reg(dsk_probe_index_reg) <= SD_DSK_KIND_UNKNOWN;
                                read_error_reg <= '0';
                                IF dsk_probe_index_reg < SD_BROWSER_MAX_FILES THEN
                                    dsk_probe_index_reg <= dsk_probe_index_reg + 1;
                                END IF;
                            ELSIF dsk_probe_index_reg < root_file_count_reg THEN
                                IF file_name_reg(dsk_probe_index_reg)(23 DOWNTO 0) = x"44534B" AND
                                    UNSIGNED(file_cluster_reg(dsk_probe_index_reg)) >= to_unsigned(2, 32) THEN
                                    lba_target_reg <= LBA_TARGET_FILE;
                                    lba_cluster_reg <= UNSIGNED(file_cluster_reg(dsk_probe_index_reg));
                                    read_job_reg <= JOB_DSK_PROBE;
                                    read_first_word_reg <= x"00000000";
                                    read_signature_reg <= x"0000";
                                    read_done_reg <= '0';
                                    read_error_reg <= '0';
                                    state <= ST_CALC_LBA_BASE;
                                ELSIF dsk_probe_index_reg < SD_BROWSER_MAX_FILES THEN
                                    dsk_probe_index_reg <= dsk_probe_index_reg + 1;
                                END IF;
                            ELSE
                                dsk_probe_active_reg <= '0';
                                browser_page_dirty_reg <= '1';
                                read_done_reg <= '1';
                                read_job_reg <= JOB_ROOT;
                            END IF;
                        ELSIF browser_page_fill_active_reg = '1' THEN
                            IF browser_page_fill_index_reg < SD_BROWSER_PAGE_SIZE THEN
                                IF browser_page_fill_base_reg + browser_page_fill_index_reg < root_file_count_reg THEN
                                    page_valid_reg(browser_page_fill_index_reg) <= '1';
                                    page_name_reg(browser_page_fill_index_reg) <= file_name_reg(browser_page_fill_base_reg + browser_page_fill_index_reg);
                                    page_cluster_reg(browser_page_fill_index_reg) <= file_cluster_reg(browser_page_fill_base_reg + browser_page_fill_index_reg);
                                    page_size_reg(browser_page_fill_index_reg) <= file_size_reg(browser_page_fill_base_reg + browser_page_fill_index_reg);
                                    page_kind_reg(browser_page_fill_index_reg) <= file_kind_reg(browser_page_fill_base_reg + browser_page_fill_index_reg);
                                ELSE
                                    page_valid_reg(browser_page_fill_index_reg) <= '0';
                                    page_name_reg(browser_page_fill_index_reg) <= (OTHERS => '0');
                                    page_cluster_reg(browser_page_fill_index_reg) <= (OTHERS => '0');
                                    page_size_reg(browser_page_fill_index_reg) <= (OTHERS => '0');
                                    page_kind_reg(browser_page_fill_index_reg) <= SD_DSK_KIND_UNKNOWN;
                                END IF;

                                IF browser_page_fill_index_reg + 1 < SD_BROWSER_PAGE_SIZE THEN
                                    browser_page_fill_index_reg <= browser_page_fill_index_reg + 1;
                                ELSE
                                    browser_page_fill_active_reg <= '0';
                                    page_loaded_base_reg <= browser_page_fill_base_reg;
                                END IF;
                            ELSE
                                browser_page_fill_active_reg <= '0';
                                page_loaded_base_reg <= browser_page_fill_base_reg;
                            END IF;
                        ELSIF save_cache_lookup_active_reg = '1' THEN
                            IF save_cache_lookup_index_reg < root_file_count_reg AND
                                file_name_reg(save_cache_lookup_index_reg) = save_check_name_reg THEN
                                save_check_exists_reg <= '1';
                                save_check_can_create_reg <= '0';
                                save_check_dir_full_reg <= '0';
                                save_check_requires_dir_growth_reg <= '0';
                                save_check_cluster_reg <= UNSIGNED(file_cluster_reg(save_cache_lookup_index_reg));
                                save_check_size_reg <= UNSIGNED(file_size_reg(save_cache_lookup_index_reg));
                                save_check_busy_reg <= '0';
                                save_cache_lookup_active_reg <= '0';

                                IF cfg_request_reg = CFG_REQ_LOAD THEN
                                    cfg_load_busy_reg <= '0';
                                    IF UNSIGNED(file_cluster_reg(save_cache_lookup_index_reg)) >= to_unsigned(2, 32) AND
                                        UNSIGNED(file_size_reg(save_cache_lookup_index_reg)) >= CONFIG_STREAM_LEN_OLD THEN
                                        read_job_reg <= JOB_CFG;
                                        read_done_reg <= '0';
                                        read_error_reg <= '0';
                                        read_token_reg <= x"FF";
                                        read_byte_count_reg <= (OTHERS => '0');
                                        read_first_word_reg <= x"00000000";
                                        read_signature_reg <= x"0000";
                                        cfg_parse_byte4_reg <= x"00";
                                        cfg_parse_byte5_reg <= x"00";
                                        cfg_parse_byte6_reg <= x"00";
                                        cfg_parse_byte7_reg <= x"00";
                                        cfg_parse_byte8_reg <= x"00";
                                        cfg_parse_byte9_reg <= x"00";
                                        cfg_parse_byte14_reg <= x"00";
                                        cfg_parse_network_payload_reg <= (OTHERS => '0');
                                        cfg_parse_byte30_reg <= x"00";
                                        file_bytes_left_reg <= UNSIGNED(file_size_reg(save_cache_lookup_index_reg));
                                        lba_target_reg <= LBA_TARGET_FILE;
                                        lba_cluster_reg <= UNSIGNED(file_cluster_reg(save_cache_lookup_index_reg));
                                        cfg_request_reg <= CFG_REQ_NONE;
                                        gap_after_state <= ST_CALC_LBA_BASE;
                                        state <= ST_GAP;
                                    ELSE
                                        cfg_load_done_reg <= '1';
                                        cfg_request_reg <= CFG_REQ_NONE;
                                    END IF;
                                ELSIF cfg_request_reg = CFG_REQ_SAVE THEN
                                    save_req_start_addr_reg <= (OTHERS => '0');
                                    save_req_end_addr_reg <= (OTHERS => '0');
                                    save_backend_is_cfg_reg <= '1';
                                    state <= ST_SAVE_PREP_REQUEST;
                                ELSE
                                    save_check_done_reg <= '1';
                                END IF;
                            ELSIF save_cache_lookup_index_reg + 1 < root_file_count_reg THEN
                                save_cache_lookup_index_reg <= save_cache_lookup_index_reg + 1;
                            ELSE
                                IF cached_free_valid_reg = '1' THEN
                                    save_check_can_create_reg <= '1';
                                    save_check_dir_full_reg <= '0';
                                    save_check_free_lba_reg <= cached_free_lba_reg;
                                    save_check_free_slot_reg <= cached_free_slot_reg;
                                    save_check_free_marker_reg <= cached_free_marker_reg;
                                    save_check_free_sector_first_byte_reg <= cached_free_sector_first_byte_reg;
                                    save_check_requires_dir_growth_reg <= cached_free_requires_dir_growth_reg;
                                ELSE
                                    save_check_can_create_reg <= '0';
                                    save_check_dir_full_reg <= '1';
                                END IF;
                                save_check_busy_reg <= '0';
                                save_cache_lookup_active_reg <= '0';

                                IF cfg_request_reg = CFG_REQ_LOAD THEN
                                    save_check_busy_reg <= '0';
                                    cfg_load_busy_reg <= '0';
                                    cfg_load_done_reg <= '1';
                                    cfg_request_reg <= CFG_REQ_NONE;
                                ELSIF cfg_request_reg = CFG_REQ_SAVE THEN
                                    save_check_busy_reg <= '0';
                                    save_req_start_addr_reg <= (OTHERS => '0');
                                    save_req_end_addr_reg <= (OTHERS => '0');
                                    save_backend_is_cfg_reg <= '1';
                                    state <= ST_SAVE_PREP_REQUEST;
                                ELSIF cached_free_valid_reg = '1' AND
                                    cached_free_requires_dir_growth_reg = '0' THEN
                                    save_check_can_allocate_reg <= '0';
                                    save_check_free_cluster_reg <= to_unsigned(1, 32);
                            save_alloc_search_need_reg <= to_unsigned(1, 16);
                                    read_job_reg <= JOB_FAT;
                                    IF save_cluster_hint_reg > to_unsigned(2, 32) THEN
                                        current_lba_reg <= part_lba_reg + resize(boot_reserved_reg, 32) + shift_right(save_cluster_hint_reg, 7);
                                        fat_scan_sectors_left_reg <= boot_spf_reg - shift_right(save_cluster_hint_reg, 7);
                                        fat_scan_cluster_reg <= shift_left(shift_right(save_cluster_hint_reg, 7), 7);
                                        fat_scan_min_cluster_reg <= save_cluster_hint_reg;
                                    ELSE
                                        current_lba_reg <= part_lba_reg + resize(boot_reserved_reg, 32);
                                        fat_scan_sectors_left_reg <= boot_spf_reg;
                                        fat_scan_cluster_reg <= (OTHERS => '0');
                                        fat_scan_min_cluster_reg <= to_unsigned(2, 32);
                                    END IF;
                                    fat_scan_wrap_reg <= '0';
                                    fat_scan_run_start_reg <= (OTHERS => '0');
                                    fat_scan_run_len_reg <= (OTHERS => '0');
                                    save_clusters_needed_reg <= to_unsigned(1, 16);
                                    fat_entry_tmp_reg <= (OTHERS => '0');
                                    gap_after_state <= ST_PREP_CMD17;
                                    state <= ST_GAP;
                                ELSE
                                    save_check_busy_reg <= '0';
                                    save_check_done_reg <= '1';
                                END IF;
                            END IF;
                        ELSIF manage_start = '1' AND manage_busy_reg = '0' AND
                            browser_dir_found_reg = '1' AND boot_spc_reg /= x"00" AND
                            manage_old_name(87 DOWNTO 80) /= x"00" AND
                            manage_old_name(87 DOWNTO 80) /= x"20" AND
                            (manage_delete = '1' OR
                             (manage_new_name(87 DOWNTO 80) /= x"00" AND
                              manage_new_name(87 DOWNTO 80) /= x"20")) THEN
                            manage_busy_reg <= '1';
                            manage_done_reg <= '0';
                            manage_error_reg <= '0';
                            manage_status_reg <= MANAGE_STATUS_NONE;
                            manage_delete_reg <= manage_delete;
                            manage_old_name_reg <= manage_old_name;
                            manage_new_name_reg <= manage_new_name;
                            manage_found_reg <= '0';
                            manage_duplicate_reg <= '0';
                            manage_lfn_reg <= '0';
                            manage_read_only_reg <= '0';
                            manage_prev_lfn_reg <= '0';
                            manage_match_lba_reg <= (OTHERS => '0');
                            manage_match_slot_reg <= 0;
                            manage_match_first_byte_reg <= x"00";
                            manage_cluster_reg <= (OTHERS => '0');
                            manage_next_cluster_reg <= (OTHERS => '0');
                            manage_chain_guard_reg <= (OTHERS => '0');
                            read_done_reg <= '0';
                            read_error_reg <= '0';
                            read_token_reg <= x"FF";
                            lba_target_reg <= LBA_TARGET_ROOT;
                            lba_cluster_reg <= browser_dir_cluster_reg;
                            root_current_cluster_reg <= browser_dir_cluster_reg;
                            root_chain_advance_reg <= '0';
                            browser_page_reload_reg <= '0';
                            root_scan_phase_reg <= ROOT_SCAN_LIST_FILES;
                            root_scan_job_reg <= ROOT_SCAN_MANAGE;
                            state <= ST_CALC_LBA_BASE;

                        ELSIF fdd_format_start = '1' AND
                            fdd_format_phase_reg = FDD_FORMAT_IDLE AND
                            UNSIGNED(fdd_format_cluster) >= to_unsigned(2, 32) AND
                            fdd_format_name(23 DOWNTO 0) = x"44534B" AND
                            browser_dir_found_reg = '1' AND boot_spc_reg /= x"00" THEN
                            -- Formatting is copy-on-format: first make sure that
                            -- NAME.BAK does not exist, then rename the mounted
                            -- NAME.DSK in place and allocate a fresh 640 KiB DSK.
                            fdd_format_busy_reg <= '1';
                            fdd_format_done_reg <= '0';
                            fdd_format_error_reg <= '0';
                            fdd_format_name_reg <= fdd_format_name;
                            fdd_format_bak_name_reg <=
                                fdd_format_name(87 DOWNTO 24) & x"42414B";
                            fdd_format_old_cluster_reg <= UNSIGNED(fdd_format_cluster);
                            fdd_format_new_cluster_reg <= (OTHERS => '0');
                            fdd_format_phase_reg <= FDD_FORMAT_CHECK_BAK;
                            fdd_format_read_retry_reg <= 0;
                            read_done_reg <= '0';
                            read_error_reg <= '0';
                            read_token_reg <= x"FF";
                            save_write_done_reg <= '0';
                            save_write_error_reg <= '0';
                            save_write_status_reg <= SAVE_STATUS_NONE;
                            save_check_name_reg <=
                                fdd_format_name(87 DOWNTO 24) & x"42414B";
                            save_check_busy_reg <= '1';
                            save_check_done_reg <= '0';
                            save_check_exists_reg <= '0';
                            save_check_can_create_reg <= '0';
                            save_check_can_allocate_reg <= '0';
                            save_check_requires_dir_growth_reg <= '0';
                            save_check_dir_full_reg <= '0';
                            save_check_cluster_reg <= (OTHERS => '0');
                            save_check_size_reg <= (OTHERS => '0');
                            save_check_free_lba_reg <= (OTHERS => '0');
                            save_check_free_slot_reg <= 0;
                            save_check_free_marker_reg <= x"00";
                            save_check_free_cluster_reg <= (OTHERS => '0');
                            save_check_free_sector_first_byte_reg <= x"00";
                            save_check_match_lba_reg <= (OTHERS => '0');
                            save_check_match_slot_reg <= 0;
                            save_check_match_sector_first_byte_reg <= x"00";
                            save_verify_pending_reg <= '0';
                            lba_target_reg <= LBA_TARGET_ROOT;
                            lba_cluster_reg <= browser_dir_cluster_reg;
                            root_current_cluster_reg <= browser_dir_cluster_reg;
                            root_chain_advance_reg <= '0';
                            browser_page_reload_reg <= '0';
                            root_scan_phase_reg <= ROOT_SCAN_LIST_FILES;
                            root_scan_job_reg <= ROOT_SCAN_SAVE_CHECK;
                            state <= ST_CALC_LBA_BASE;
                        ELSIF fdd_format_start = '1' AND
                            fdd_format_phase_reg = FDD_FORMAT_IDLE THEN
                            -- Do not leave the WD1793 busy forever when a
                            -- malformed/stale mount request reaches the SD
                            -- backend.  Return a deterministic format error.
                            fdd_format_busy_reg <= '0';
                            fdd_format_done_reg <= '0';
                            fdd_format_error_reg <= '1';
                            save_write_busy_reg <= '0';
                            save_write_error_reg <= '1';
                            IF browser_dir_found_reg = '0' OR boot_spc_reg = x"00" THEN
                                save_write_status_reg <= SAVE_STATUS_DIR_MISSING;
                            ELSIF UNSIGNED(fdd_format_cluster) < to_unsigned(2, 32) THEN
                                save_write_status_reg <= FDD_FORMAT_STATUS_CLUSTER_MISMATCH;
                            ELSE
                                save_write_status_reg <= FDD_FORMAT_STATUS_DSK_MISSING;
                            END IF;
                        ELSIF fdd_write_pending_reg = '1' AND
                            fdd_write_pending_cluster_reg >= to_unsigned(2, 32) AND
                            boot_spc_reg /= x"00" THEN
                            lba_target_reg <= LBA_TARGET_FILE;
                            lba_cluster_reg <= fdd_write_pending_cluster_reg;
                            fdd_write_half_reg <= fdd_write_pending_half_reg;
                            fdd_write_busy_reg <= '1';
                            fdd_write_done_reg <= '0';
                            fdd_write_error_reg <= '0';
                            fdd_write_pending_reg <= '0';
                            save_backend_is_fdd_reg <= '1';
                            save_write_busy_reg <= '1';
                            save_write_done_reg <= '0';
                            save_write_error_reg <= '0';
                            save_write_status_reg <= SAVE_STATUS_NONE;
                            read_done_reg <= '0';
                            read_error_reg <= '0';
                            read_token_reg <= x"FF";
                            read_byte_count_reg <= (OTHERS => '0');
                            read_first_word_reg <= x"00000000";
                            read_signature_reg <= x"0000";
                            fdd_format_read_retry_reg <= 0;
                            IF fdd_write_pending_sector_reg <
                                resize(UNSIGNED(boot_spc_reg), fdd_write_pending_sector_reg'LENGTH) THEN
                                fdd_chain_active_reg <= '0';
                                fdd_sector_offset_reg <= fdd_write_pending_sector_reg;
                                fdd_write_cache_valid_reg <= '1';
                                fdd_write_cache_file_cluster_reg <= fdd_write_pending_cluster_reg;
                                fdd_write_cache_cluster_reg <= fdd_write_pending_cluster_reg;
                                fdd_write_cache_sector_base_reg <= (OTHERS => '0');
                                read_job_reg <= JOB_FDD_WRITE;
                                state <= ST_CALC_LBA_BASE;
                            ELSIF fdd_write_cache_valid_reg = '1' AND
                                fdd_write_cache_file_cluster_reg = fdd_write_pending_cluster_reg AND
                                fdd_write_pending_sector_reg >= fdd_write_cache_sector_base_reg AND
                                fdd_write_pending_sector_reg <
                                    fdd_write_cache_sector_base_reg +
                                    resize(UNSIGNED(boot_spc_reg), fdd_write_pending_sector_reg'LENGTH) THEN
                                fdd_chain_active_reg <= '0';
                                lba_cluster_reg <= fdd_write_cache_cluster_reg;
                                fdd_sector_offset_reg <=
                                    fdd_write_pending_sector_reg - fdd_write_cache_sector_base_reg;
                                read_job_reg <= JOB_FDD_WRITE;
                                state <= ST_CALC_LBA_BASE;
                            ELSE
                                fdd_chain_active_reg <= '1';
                                fdd_chain_write_reg <= '1';
                                fdd_chain_file_cluster_reg <= fdd_write_pending_cluster_reg;
                                root_next_cluster_reg <= (OTHERS => '0');
                                IF fdd_write_cache_valid_reg = '1' AND
                                    fdd_write_cache_file_cluster_reg = fdd_write_pending_cluster_reg AND
                                    fdd_write_pending_sector_reg >=
                                        fdd_write_cache_sector_base_reg +
                                        resize(UNSIGNED(boot_spc_reg), fdd_write_pending_sector_reg'LENGTH) THEN
                                    fdd_chain_remaining_reg <=
                                        fdd_write_pending_sector_reg -
                                        fdd_write_cache_sector_base_reg -
                                        resize(UNSIGNED(boot_spc_reg), fdd_write_pending_sector_reg'LENGTH);
                                    fdd_chain_sector_base_reg <=
                                        fdd_write_cache_sector_base_reg +
                                        resize(UNSIGNED(boot_spc_reg), fdd_chain_sector_base_reg'LENGTH);
                                    root_fat_byte_offset_reg <=
                                        to_integer(fdd_write_cache_cluster_reg(6 DOWNTO 0)) * 4;
                                    current_lba_reg <=
                                        part_lba_reg +
                                        resize(boot_reserved_reg, 32) +
                                        resize(shift_right(fdd_write_cache_cluster_reg, 7), 32);
                                ELSE
                                    fdd_chain_remaining_reg <=
                                        fdd_write_pending_sector_reg -
                                        resize(UNSIGNED(boot_spc_reg), fdd_write_pending_sector_reg'LENGTH);
                                    fdd_chain_sector_base_reg <=
                                        resize(UNSIGNED(boot_spc_reg), fdd_chain_sector_base_reg'LENGTH);
                                    root_fat_byte_offset_reg <=
                                        to_integer(fdd_write_pending_cluster_reg(6 DOWNTO 0)) * 4;
                                    current_lba_reg <=
                                        part_lba_reg +
                                        resize(boot_reserved_reg, 32) +
                                        resize(shift_right(fdd_write_pending_cluster_reg, 7), 32);
                                END IF;
                                read_job_reg <= JOB_ROOT_FAT;
                                state <= ST_PREP_CMD17;
                            END IF;
                        ELSIF fdd_write_pending_reg = '1' THEN
                            fdd_write_pending_reg <= '0';
                            fdd_write_busy_reg <= '0';
                            fdd_write_done_reg <= '0';
                            fdd_write_error_reg <= '1';
                            save_write_busy_reg <= '0';
                            save_write_error_reg <= '1';
                            save_write_status_reg <= SAVE_STATUS_IO_ERROR;
                        ELSIF fdd_read_start = '1' AND
                            UNSIGNED(fdd_read_cluster) >= to_unsigned(2, 32) AND
                            boot_spc_reg /= x"00" THEN
                            lba_target_reg <= LBA_TARGET_FILE;
                            lba_cluster_reg <= UNSIGNED(fdd_read_cluster);
                            fdd_read_half_reg <= fdd_read_half;
                            fdd_read_busy_reg <= '1';
                            fdd_read_done_reg <= '0';
                            fdd_read_error_reg <= '0';
                            read_done_reg <= '0';
                            read_error_reg <= '0';
                            read_token_reg <= x"FF";
                            read_byte_count_reg <= (OTHERS => '0');
                            read_first_word_reg <= x"00000000";
                            read_signature_reg <= x"0000";
                            IF UNSIGNED(fdd_read_sd_sector) <
                                resize(UNSIGNED(boot_spc_reg), fdd_read_sd_sector'LENGTH) THEN
                                fdd_chain_active_reg <= '0';
                                fdd_sector_offset_reg <= UNSIGNED(fdd_read_sd_sector);
                                fdd_read_cache_valid_reg <= '1';
                                fdd_read_cache_file_cluster_reg <= UNSIGNED(fdd_read_cluster);
                                fdd_read_cache_cluster_reg <= UNSIGNED(fdd_read_cluster);
                                fdd_read_cache_sector_base_reg <= (OTHERS => '0');
                                read_job_reg <= JOB_FDD;
                                state <= ST_CALC_LBA_BASE;
                            ELSIF fdd_read_cache_valid_reg = '1' AND
                                fdd_read_cache_file_cluster_reg = UNSIGNED(fdd_read_cluster) AND
                                UNSIGNED(fdd_read_sd_sector) >= fdd_read_cache_sector_base_reg AND
                                UNSIGNED(fdd_read_sd_sector) <
                                    fdd_read_cache_sector_base_reg +
                                    resize(UNSIGNED(boot_spc_reg), fdd_read_sd_sector'LENGTH) THEN
                                fdd_chain_active_reg <= '0';
                                lba_cluster_reg <= fdd_read_cache_cluster_reg;
                                fdd_sector_offset_reg <=
                                    UNSIGNED(fdd_read_sd_sector) - fdd_read_cache_sector_base_reg;
                                read_job_reg <= JOB_FDD;
                                state <= ST_CALC_LBA_BASE;
                            ELSE
                                fdd_chain_active_reg <= '1';
                                fdd_chain_write_reg <= '0';
                                fdd_chain_file_cluster_reg <= UNSIGNED(fdd_read_cluster);
                                root_next_cluster_reg <= (OTHERS => '0');
                                IF fdd_read_cache_valid_reg = '1' AND
                                    fdd_read_cache_file_cluster_reg = UNSIGNED(fdd_read_cluster) AND
                                    UNSIGNED(fdd_read_sd_sector) >=
                                        fdd_read_cache_sector_base_reg +
                                        resize(UNSIGNED(boot_spc_reg), fdd_read_sd_sector'LENGTH) THEN
                                    fdd_chain_remaining_reg <=
                                        UNSIGNED(fdd_read_sd_sector) -
                                        fdd_read_cache_sector_base_reg -
                                        resize(UNSIGNED(boot_spc_reg), fdd_read_sd_sector'LENGTH);
                                    fdd_chain_sector_base_reg <=
                                        fdd_read_cache_sector_base_reg +
                                        resize(UNSIGNED(boot_spc_reg), fdd_chain_sector_base_reg'LENGTH);
                                    root_fat_byte_offset_reg <=
                                        to_integer(fdd_read_cache_cluster_reg(6 DOWNTO 0)) * 4;
                                    current_lba_reg <=
                                        part_lba_reg +
                                        resize(boot_reserved_reg, 32) +
                                        resize(shift_right(fdd_read_cache_cluster_reg, 7), 32);
                                ELSE
                                    fdd_chain_remaining_reg <=
                                        UNSIGNED(fdd_read_sd_sector) -
                                        resize(UNSIGNED(boot_spc_reg), fdd_read_sd_sector'LENGTH);
                                    fdd_chain_sector_base_reg <=
                                        resize(UNSIGNED(boot_spc_reg), fdd_chain_sector_base_reg'LENGTH);
                                    root_fat_byte_offset_reg <=
                                        to_integer(UNSIGNED(fdd_read_cluster(6 DOWNTO 0))) * 4;
                                    current_lba_reg <=
                                        part_lba_reg +
                                        resize(boot_reserved_reg, 32) +
                                        resize(shift_right(UNSIGNED(fdd_read_cluster), 7), 32);
                                END IF;
                                read_job_reg <= JOB_ROOT_FAT;
                                state <= ST_PREP_CMD17;
                            END IF;
                        ELSIF browser_dir_found_reg = '1' AND
                            browser_rescan_pending_reg = '1' AND
                            boot_spc_reg /= x"00" THEN
                            lba_target_reg <= LBA_TARGET_ROOT;
                            lba_cluster_reg <= browser_dir_cluster_reg;
                            root_current_cluster_reg <= browser_dir_cluster_reg;
                            root_chain_advance_reg <= '0';
                            browser_page_reload_reg <= '0';
                            browser_page_dirty_reg <= '0';
                            browser_rescan_pending_reg <= '0';
                            root_scan_phase_reg <= ROOT_SCAN_LIST_FILES;
                            root_scan_job_reg <= ROOT_SCAN_DISCOVER;
                            state <= ST_CALC_LBA_BASE;
                        ELSIF browser_dir_found_reg = '1' AND
                            (page_loaded_base_reg /= page_base_index OR browser_page_dirty_reg = '1') AND
                            boot_spc_reg /= x"00" THEN
                            IF browser_cache_valid_reg = '1' THEN
                                page_valid_reg <= (OTHERS => '0');
                                page_name_reg <= (OTHERS => (OTHERS => '0'));
                                page_cluster_reg <= (OTHERS => (OTHERS => '0'));
                                page_size_reg <= (OTHERS => (OTHERS => '0'));
                                page_kind_reg <= (OTHERS => SD_DSK_KIND_UNKNOWN);
                                browser_page_fill_active_reg <= '1';
                                browser_page_fill_index_reg <= 0;
                                browser_page_fill_base_reg <= page_base_index;
                                browser_page_dirty_reg <= '0';
                            ELSE
                                lba_target_reg <= LBA_TARGET_ROOT;
                                lba_cluster_reg <= browser_dir_cluster_reg;
                                root_current_cluster_reg <= browser_dir_cluster_reg;
                                root_chain_advance_reg <= '0';
                                browser_page_reload_reg <= '1';
                                browser_page_dirty_reg <= '0';
                                root_scan_phase_reg <= ROOT_SCAN_LIST_FILES;
                                root_scan_job_reg <= ROOT_SCAN_PAGE_RELOAD;
                                state <= ST_CALC_LBA_BASE;
                            END IF;
                        ELSIF cfg_load_start = '1' THEN
                            cfg_save_recheck_reg <= '0';
                            save_check_name_reg <= CONFIG_SHORT_NAME;
                            save_check_busy_reg <= '0';
                            save_check_done_reg <= '0';
                            save_check_exists_reg <= '0';
                            save_check_can_create_reg <= '0';
                            save_check_can_allocate_reg <= '0';
                            save_check_requires_dir_growth_reg <= '0';
                            save_check_dir_full_reg <= '0';
                            save_check_cluster_reg <= (OTHERS => '0');
                            save_check_size_reg <= (OTHERS => '0');
                            save_check_free_lba_reg <= (OTHERS => '0');
                            save_check_free_slot_reg <= 0;
                            save_check_free_marker_reg <= x"00";
                            save_check_free_cluster_reg <= (OTHERS => '0');
                            save_check_free_sector_first_byte_reg <= x"00";
                            save_check_match_lba_reg <= (OTHERS => '0');
                            save_check_match_slot_reg <= 0;
                            save_check_match_sector_first_byte_reg <= x"00";
                            fat_scan_sectors_left_reg <= (OTHERS => '0');
                            fat_scan_cluster_reg <= (OTHERS => '0');
                            fat_entry_tmp_reg <= (OTHERS => '0');
                            save_verify_pending_reg <= '0';
                            cfg_request_reg <= CFG_REQ_LOAD;
                            cfg_load_busy_reg <= '0';
                            cfg_save_busy_reg <= '0';
                            IF browser_dir_found_reg = '1' AND boot_spc_reg /= x"00" THEN
                                -- The browser cache only tracks NAS/CAS/DSK files.
                                -- Config save/load must always rescan the directory so N2CONF.CFG is found.
                                cfg_load_busy_reg <= '1';
                                lba_target_reg <= LBA_TARGET_ROOT;
                                lba_cluster_reg <= browser_dir_cluster_reg;
                                root_current_cluster_reg <= browser_dir_cluster_reg;
                                root_chain_advance_reg <= '0';
                                browser_page_reload_reg <= '0';
                                root_scan_phase_reg <= ROOT_SCAN_LIST_FILES;
                                root_scan_job_reg <= ROOT_SCAN_SAVE_CHECK;
                                save_check_busy_reg <= '1';
                                state <= ST_CALC_LBA_BASE;
                            ELSE
                                cfg_load_done_reg <= '1';
                                cfg_request_reg <= CFG_REQ_NONE;
                            END IF;
                        ELSIF cfg_save_start = '1' THEN
                            cfg_save_recheck_reg <= '0';
                            save_check_name_reg <= CONFIG_SHORT_NAME;
                            save_check_busy_reg <= '0';
                            save_check_done_reg <= '0';
                            save_check_exists_reg <= '0';
                            save_check_can_create_reg <= '0';
                            save_check_can_allocate_reg <= '0';
                            save_check_requires_dir_growth_reg <= '0';
                            save_check_dir_full_reg <= '0';
                            save_check_cluster_reg <= (OTHERS => '0');
                            save_check_size_reg <= (OTHERS => '0');
                            save_check_free_lba_reg <= (OTHERS => '0');
                            save_check_free_slot_reg <= 0;
                            save_check_free_marker_reg <= x"00";
                            save_check_free_cluster_reg <= (OTHERS => '0');
                            save_check_free_sector_first_byte_reg <= x"00";
                            save_check_match_lba_reg <= (OTHERS => '0');
                            save_check_match_slot_reg <= 0;
                            save_check_match_sector_first_byte_reg <= x"00";
                            fat_scan_sectors_left_reg <= (OTHERS => '0');
                            fat_scan_cluster_reg <= (OTHERS => '0');
                            fat_entry_tmp_reg <= (OTHERS => '0');
                            save_verify_pending_reg <= '0';
                            cfg_byte4_v := (OTHERS => '0');
                            cfg_byte5_v := (OTHERS => '0');
                            cfg_byte6_v := (OTHERS => '0');
                            cfg_byte8_v := (OTHERS => '0');
                            cfg_network_v := (OTHERS => '0');
                            cfg_byte4_v(3) := cfg_save_scanlines;
                            cfg_byte4_v(5 DOWNTO 4) := cfg_save_video_zoom;
                            cfg_byte4_v(2) := cfg_save_phosphor_amber;
                            cfg_byte4_v(1 DOWNTO 0) := cfg_save_speed;
                            cfg_byte5_v(3 DOWNTO 0) := cfg_save_slot_rom;
                            cfg_byte5_v(4) := cfg_save_fdd;
                            cfg_byte5_v(5) := cfg_save_cpm;
                            cfg_byte5_v(6) := cfg_save_avc;
                            cfg_byte5_v(7) := cfg_save_bls;
                            cfg_byte6_v(2 DOWNTO 0) := cfg_save_rs232;
                            cfg_byte6_v(6) := cfg_save_rs232_flow;
                            cfg_byte8_v(3 DOWNTO 0) := cfg_save_rs232_speed;
                            cfg_network_v(128) := cfg_save_network;
                            cfg_network_v(129) := cfg_save_network_dhcp;
                            cfg_network_v(127 DOWNTO 96) := cfg_save_network_ipv4;
                            cfg_network_v(95 DOWNTO 64) := cfg_save_network_netmask;
                            cfg_network_v(63 DOWNTO 32) := cfg_save_network_gateway;
                            cfg_network_v(31 DOWNTO 0) := cfg_save_network_dns;
                            cfg_request_reg <= CFG_REQ_SAVE;
                            cfg_byte4_reg <= cfg_byte4_v;
                            cfg_byte5_reg <= cfg_byte5_v;
                            cfg_byte6_reg <= cfg_byte6_v;
                            cfg_byte8_reg <= cfg_byte8_v;
                            cfg_network_payload_reg <= cfg_network_v;
                            cfg_byte7_reg <= CONFIG_VERSION_V4 XOR x"20" XOR cfg_byte4_v XOR cfg_byte5_v XOR
                                cfg_byte6_v XOR cfg_byte8_v XOR xor_network_payload(cfg_network_v) XOR x"A5";
                            cfg_save_busy_reg <= '0';
                            cfg_load_busy_reg <= '0';
                            IF browser_dir_found_reg = '1' AND boot_spc_reg /= x"00" THEN
                                -- The browser cache only tracks NAS/CAS/DSK files.
                                -- Config save/load must always rescan the directory so N2CONF.CFG is found.
                                cfg_save_busy_reg <= '1';
                                lba_target_reg <= LBA_TARGET_ROOT;
                                lba_cluster_reg <= browser_dir_cluster_reg;
                                root_current_cluster_reg <= browser_dir_cluster_reg;
                                root_chain_advance_reg <= '0';
                                browser_page_reload_reg <= '0';
                                root_scan_phase_reg <= ROOT_SCAN_LIST_FILES;
                                root_scan_job_reg <= ROOT_SCAN_SAVE_CHECK;
                                save_check_busy_reg <= '1';
                                state <= ST_CALC_LBA_BASE;
                            ELSE
                                cfg_save_error_reg <= '1';
                                cfg_request_reg <= CFG_REQ_NONE;
                            END IF;
                        ELSIF save_check_start = '1' THEN
                            save_check_name_v := build_save_short_name(save_name, save_is_pascal);
                            save_check_name_reg <= save_check_name_v;
                            save_check_busy_reg <= '0';
                            save_check_done_reg <= '0';
                            save_check_exists_reg <= '0';
                            save_check_can_create_reg <= '0';
                            save_check_can_allocate_reg <= '0';
                            save_check_requires_dir_growth_reg <= '0';
                            save_check_dir_full_reg <= '0';
                            save_check_cluster_reg <= (OTHERS => '0');
                            save_check_size_reg <= (OTHERS => '0');
                            save_check_free_lba_reg <= (OTHERS => '0');
                            save_check_free_slot_reg <= 0;
                            save_check_free_marker_reg <= x"00";
                            save_check_free_cluster_reg <= (OTHERS => '0');
                            save_check_free_sector_first_byte_reg <= x"00";
                            fat_scan_sectors_left_reg <= (OTHERS => '0');
                            fat_scan_cluster_reg <= (OTHERS => '0');
                            fat_entry_tmp_reg <= (OTHERS => '0');
                            save_verify_pending_reg <= '0';
                            IF browser_dir_found_reg = '1' AND boot_spc_reg /= x"00" THEN
                                IF browser_cache_valid_reg = '1' THEN
                                    save_check_busy_reg <= '1';
                                    save_cache_lookup_active_reg <= '1';
                                    save_cache_lookup_index_reg <= 0;
                                ELSE
                                    lba_target_reg <= LBA_TARGET_ROOT;
                                    lba_cluster_reg <= browser_dir_cluster_reg;
                                    root_current_cluster_reg <= browser_dir_cluster_reg;
                                    root_chain_advance_reg <= '0';
                                    browser_page_reload_reg <= '0';
                                    root_scan_phase_reg <= ROOT_SCAN_LIST_FILES;
                                    root_scan_job_reg <= ROOT_SCAN_SAVE_CHECK;
                                    save_check_busy_reg <= '1';
                                    state <= ST_CALC_LBA_BASE;
                                END IF;
                            ELSE
                                save_check_done_reg <= '1';
                            END IF;
                        ELSIF save_write_start = '1' THEN
                            save_write_done_reg <= '0';
                            save_write_error_reg <= '0';
                            save_write_status_reg <= SAVE_STATUS_NONE;
                            save_backend_is_cfg_reg <= '0';
                            save_req_start_addr_reg <= unsigned(save_write_start_addr);
                            save_req_end_addr_reg <= unsigned(save_write_end_addr);
                            state <= ST_SAVE_PREP_REQUEST;

                        ELSIF file_read_start = '1' AND
                            UNSIGNED(file_read_cluster) >= to_unsigned(2, 32) AND
                            boot_spc_reg /= x"00" THEN
                            lba_target_reg <= LBA_TARGET_FILE;
                            lba_cluster_reg <= UNSIGNED(file_read_cluster);
                            read_job_reg <= JOB_FILE;
                            read_done_reg <= '0';
                            read_error_reg <= '0';
                            read_token_reg <= x"FF";
                            read_byte_count_reg <= (OTHERS => '0');
                            read_first_word_reg <= x"00000000";
                            read_signature_reg <= x"0000";
                            file_read_is_cas_reg <= file_read_is_cas;
                            file_load_addr_valid_reg <= '0';
                            file_load_addr_reg <= x"0000";
                            file_mem_addr_reg <= x"0000";
                            file_mem_data_reg <= x"00";
                            file_bytes_left_reg <= UNSIGNED(file_read_size);
                            file_cas_error_reg <= '0';
                            cas_parse_state_reg <= CAS_SYNC_00;
                            cas_block_addr_reg <= (OTHERS => '0');
                            cas_block_len_reg <= (OTHERS => '0');
                            cas_header_sum_reg <= (OTHERS => '0');
                            cas_data_sum_reg <= (OTHERS => '0');
                            cas_data_left_reg <= 0;
                            cas_data_addr_reg <= (OTHERS => '0');
                            nas_addr_reg <= x"0000";
                            nas_addr_digits_reg <= 0;
                            nas_token_reg <= x"00";
                            nas_token_digits_reg <= 0;
                            nas_data_index_reg <= 0;
                            nas_in_line_reg <= '0';
                            nas_ignore_line_reg <= '0';
                            state <= ST_CALC_LBA_BASE;
                        END IF;

                    WHEN ST_READY =>
                        cs_n_reg <= '1';
                        sclk_reg <= '0';
                        mosi_reg <= '1';

                    WHEN ST_ERROR =>
                        cs_n_reg <= '1';
                        sclk_reg <= '0';
                        mosi_reg <= '1';
                        byte_busy <= '0';

                        -- Nur Init-Fehler automatisch neu versuchen.
                        -- Nach init_complete_reg='1' sollen normale Read-Errors nicht
                        -- heimlich die Karte neu initialisieren.
                        IF sd_cd = '0' AND init_complete_reg = '0' THEN
                            card_settle_count <= CARD_SETTLE_CYCLES;
                            cmd0_retries <= 0;
                            acmd41_retries <= 0;
                            response_timeout <= 0;
                            state <= ST_CARD_SETTLE;
                        END IF;

                    WHEN OTHERS =>
                        cs_n_reg <= '1';
                        sclk_reg <= '0';
                        mosi_reg <= '1';
                        state <= ST_ERROR;
                END CASE;

                IF save_backend_is_fdd_reg = '1' AND
                    (read_error_reg = '1' OR save_write_error_reg = '1') THEN
                    fdd_write_busy_reg <= '0';
                    fdd_write_done_reg <= '0';
                    fdd_write_error_reg <= '1';
                    save_backend_is_fdd_reg <= '0';
                    save_write_busy_reg <= '0';
                END IF;

                IF fdd_format_phase_reg /= FDD_FORMAT_IDLE AND
                    (read_error_reg = '1' OR save_write_error_reg = '1') THEN
                    fdd_format_busy_reg <= '0';
                    fdd_format_done_reg <= '0';
                    fdd_format_error_reg <= '1';
                    fdd_format_phase_reg <= FDD_FORMAT_IDLE;
                    save_write_busy_reg <= '0';
                    save_write_error_reg <= '1';
                    IF read_error_reg = '1' AND
                        save_write_status_reg = SAVE_STATUS_NONE THEN
                        save_write_status_reg <= SAVE_STATUS_IO_ERROR;
                    END IF;
                END IF;

                IF manage_busy_reg = '1' AND
                    (read_error_reg = '1' OR save_write_error_reg = '1') THEN
                    manage_busy_reg <= '0';
                    manage_done_reg <= '0';
                    manage_error_reg <= '1';
                    manage_status_reg <= MANAGE_STATUS_IO_ERROR;
                    save_create_phase_reg <= SAVE_CREATE_IDLE;
                    root_scan_job_reg <= ROOT_SCAN_DISCOVER;
                END IF;

                IF queue_byte_v AND byte_busy = '0' THEN
                    byte_busy <= '1';
                    sclk_reg <= '0';
                    bit_idx <= 7;
                    tx_shift <= queue_data_v;
                    rx_shift <= x"FF";
                    mosi_reg <= queue_data_v(7);
                END IF;
            END IF;
        END IF;
    END PROCESS;

END rtl;










