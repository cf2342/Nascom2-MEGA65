# Build the primary MEGA65 R6 target through bitstream generation.

set script_dir [file dirname [file normalize [info script]]]
set create_script [file join $script_dir create_mega65_project.tcl]

# Recreate the project so newly added VHDL sources cannot be omitted by a stale
# checked-in XPR.  create_mega65_project.tcl leaves the new project open.
source $create_script
reset_run synth_1

set synth_incremental [lindex $argv 0]
set impl_incremental [lindex $argv 1]
if {$synth_incremental ne "" && [file exists $synth_incremental]} {
    puts "R6 incremental synthesis checkpoint: $synth_incremental"
    set_property incremental_checkpoint $synth_incremental [get_runs synth_1]
}
launch_runs synth_1 -jobs 12
wait_on_run synth_1

set synth_status [get_property STATUS [get_runs synth_1]]
puts "R6 synthesis status: $synth_status"
if {![string match "*Complete*" $synth_status]} {
    error "MEGA65 R6 synthesis failed: $synth_status"
}

if {$impl_incremental ne "" && [file exists $impl_incremental]} {
    puts "R6 incremental implementation checkpoint: $impl_incremental"
    set_property incremental_checkpoint $impl_incremental [get_runs impl_1]
}

# The R6 design is dense enough that the default implementation strategy can
# route successfully while narrowly missing setup timing. Enable both physical
# optimization stages so the normal build produces the timing-clean image that
# is suitable for hardware testing.
set_property STEPS.PLACE_DESIGN.ARGS.DIRECTIVE Explore [get_runs impl_1]
set_property STEPS.PHYS_OPT_DESIGN.IS_ENABLED true [get_runs impl_1]
set_property STEPS.PHYS_OPT_DESIGN.ARGS.DIRECTIVE AggressiveExplore [get_runs impl_1]
set_property STEPS.ROUTE_DESIGN.ARGS.DIRECTIVE AggressiveExplore [get_runs impl_1]
set_property STEPS.POST_ROUTE_PHYS_OPT_DESIGN.IS_ENABLED true [get_runs impl_1]
set_property STEPS.POST_ROUTE_PHYS_OPT_DESIGN.ARGS.DIRECTIVE AggressiveExplore [get_runs impl_1]

launch_runs impl_1 -to_step write_bitstream -jobs 12
wait_on_run impl_1

set impl_status [get_property STATUS [get_runs impl_1]]
puts "R6 implementation status: $impl_status"
if {![string match "*Complete*" $impl_status]} {
    error "MEGA65 R6 implementation failed: $impl_status"
}

set bit_file [file join $script_dir Nascom2_mega65 Nascom2_mega65.runs impl_1 Mega65_Nascom2.bit]
if {![file exists $bit_file]} {
    error "R6 bitstream was not generated: $bit_file"
}

open_run impl_1
set setup_path [get_timing_paths -delay_type max -max_paths 1]
set hold_path [get_timing_paths -delay_type min -max_paths 1]
set setup_slack [get_property SLACK $setup_path]
set hold_slack [get_property SLACK $hold_path]
puts "R6 final setup slack: $setup_slack ns"
puts "R6 final hold slack: $hold_slack ns"
if {$setup_slack < 0.0 || $hold_slack < 0.0} {
    error "R6 bitstream was generated but timing was not met"
}
puts "R6 bitstream: $bit_file"
