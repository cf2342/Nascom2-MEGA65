# Create a separate MEGA65 R3/R3A Vivado project.
# The existing Nascom2_mega65 project remains the primary R6 build.

set script_dir [file dirname [file normalize [info script]]]
if {[info exists ::env(NASCOM2_R3_PROJECT_DIR)] && $::env(NASCOM2_R3_PROJECT_DIR) ne ""} {
    set project_dir [file normalize $::env(NASCOM2_R3_PROJECT_DIR)]
} else {
    set project_dir [file join $script_dir Nascom2_mega65_r3]
}
set src_root [file join $script_dir Nascom2.srcs sources_1 new]
set rtl_root [file join $script_dir Nascom2.rtl]
set constr_file [file join $script_dir Nascom2.srcs constrs_1 new mega65_nascom2_r3_constraints.xdc]

set mega65_part xc7a200tfbg484-2

create_project Nascom2_mega65_r3 $project_dir -part $mega65_part -force
set_property target_language VHDL [current_project]
set_property simulator_language Mixed [current_project]

add_files -fileset sources_1 -norecurse [glob -nocomplain [file join $rtl_root *.vhd]]
add_files -fileset sources_1 -norecurse [glob -nocomplain [file join $src_root *.vhd]]
add_files -fileset sources_1 -norecurse [glob -nocomplain [file join $src_root tyto2_hdmi *.vhd]]
set_property file_type {VHDL 2008} [get_files -of_objects [get_filesets sources_1] *.vhd]

add_files -fileset constrs_1 -norecurse $constr_file
set_property top Mega65_Nascom2_R3 [get_filesets sources_1]
update_compile_order -fileset sources_1

# R3 has less routing margin than R6 around the large CPU/ROM data mux.  Keep
# the real 100 MHz paths at 10 ns and use the implementation stages that are
# already proven by the R6 build to recover routing margin.
set_property STEPS.PLACE_DESIGN.ARGS.DIRECTIVE ExtraPostPlacementOpt [get_runs impl_1]
set_property STEPS.PHYS_OPT_DESIGN.IS_ENABLED true [get_runs impl_1]
set_property STEPS.PHYS_OPT_DESIGN.ARGS.DIRECTIVE AggressiveExplore [get_runs impl_1]
set_property STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE AggressiveExplore [get_runs impl_1]
set_property STEPS.POST_ROUTE_PHYS_OPT_DESIGN.IS_ENABLED true [get_runs impl_1]
set_property STEPS.POST_ROUTE_PHYS_OPT_DESIGN.ARGS.DIRECTIVE AggressiveExplore [get_runs impl_1]

puts "Created MEGA65 R3/R3A project: $project_dir/Nascom2_mega65_r3.xpr"
puts "Top: Mega65_Nascom2_R3"
puts "Part: $mega65_part"
puts "Constraint: $constr_file"
