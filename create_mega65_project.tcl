# Create a separate Mega65 Vivado project for the Nascom2 first bring-up.

set script_dir [file dirname [file normalize [info script]]]
set project_dir [file join $script_dir Nascom2_mega65]
set src_root [file join $script_dir Nascom2.srcs sources_1 new]
set rtl_root [file join $script_dir Nascom2.rtl]
set constr_file [file join $script_dir Nascom2.srcs constrs_1 new mega65_nascom2_constraints.xdc]

set mega65_part xc7a200tfbg484-2

create_project Nascom2_mega65 $project_dir -part $mega65_part -force
set_property target_language VHDL [current_project]
set_property simulator_language Mixed [current_project]

add_files -fileset sources_1 -norecurse [glob -nocomplain [file join $rtl_root *.vhd]]
add_files -fileset sources_1 -norecurse [glob -nocomplain [file join $src_root *.vhd]]
add_files -fileset sources_1 -norecurse [glob -nocomplain [file join $src_root tyto2_hdmi *.vhd]]
set_property file_type {VHDL 2008} [get_files -of_objects [get_filesets sources_1] *.vhd]

add_files -fileset constrs_1 -norecurse $constr_file
set_property top Mega65_Nascom2 [get_filesets sources_1]
update_compile_order -fileset sources_1

puts "Created Mega65 project: $project_dir/Nascom2_mega65.xpr"
puts "Top: Mega65_Nascom2"
puts "Part: $mega65_part"
puts "Constraint: $constr_file"
