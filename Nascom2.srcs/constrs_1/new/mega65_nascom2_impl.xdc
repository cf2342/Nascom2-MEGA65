# The old 8.3 name is compared only while the SD directory scanner is active.
# The patch RAM writer runs in mutually exclusive FSM states and receives the
# three extension bytes through manage_lfn_extension_reg. Without this
# exception Vivado builds a false 88-bit equality path into every patch byte.
#
# This constraint is implementation-only because the final FD register cells
# do not exist yet while synthesis reads its constraints.
set manage_old_name_cells [get_cells -hier -filter {REF_NAME =~ FD* && NAME =~ *u_sd_spi_init/manage_old_name_reg_reg*}]
set save_patch_data_cells [get_cells -hier -filter {REF_NAME =~ FD* && NAME =~ *u_sd_spi_init/save_patch_wr_data_reg_reg*}]
set_false_path -from $manage_old_name_cells -to $save_patch_data_cells
