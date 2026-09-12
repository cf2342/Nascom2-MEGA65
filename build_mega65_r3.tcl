# Build the separate MEGA65 R3/R3A target through bitstream generation.

set script_dir [file dirname [file normalize [info script]]]
set create_script [file join $script_dir create_mega65_r3_project.tcl]

# Recreate the project so R3 wrapper/protocol changes and newly added sources
# cannot be hidden by a stale checked-in XPR.
source $create_script
reset_run synth_1

# Optional checkpoints speed up a rebuild after a small R3-wrapper change.
# A normal build without arguments remains a clean build.
set synth_incremental [lindex $argv 0]
set impl_incremental [lindex $argv 1]
if {$synth_incremental ne "" && [file exists $synth_incremental]} {
    puts "R3 incremental synthesis checkpoint: $synth_incremental"
    set_property incremental_checkpoint $synth_incremental [get_runs synth_1]
}
launch_runs synth_1 -jobs 12
wait_on_run synth_1

set synth_status [get_property STATUS [get_runs synth_1]]
puts "R3 synthesis status: $synth_status"
if {![string match "*Complete*" $synth_status]} {
    error "MEGA65 R3/R3A synthesis failed: $synth_status"
}

if {$impl_incremental ne "" && [file exists $impl_incremental]} {
    puts "R3 incremental implementation checkpoint: $impl_incremental"
    set_property incremental_checkpoint $impl_incremental [get_runs impl_1]
}
launch_runs impl_1 -to_step write_bitstream -jobs 12
wait_on_run impl_1

set impl_status [get_property STATUS [get_runs impl_1]]
puts "R3 implementation status: $impl_status"
if {![string match "*Complete*" $impl_status]} {
    error "MEGA65 R3/R3A implementation failed: $impl_status"
}

# Vivado can report the implementation run as Complete and still write a
# bitstream with negative setup or hold slack.  Treat that as a failed build.
open_run impl_1
set worst_setup_path [get_timing_paths -quiet -delay_type max -max_paths 1]
set worst_hold_path [get_timing_paths -quiet -delay_type min -max_paths 1]
if {[llength $worst_setup_path] == 0 || [llength $worst_hold_path] == 0} {
    error "MEGA65 R3/R3A timing check returned no setup or hold paths"
}
set r3_wns [get_property SLACK [lindex $worst_setup_path 0]]
set r3_whs [get_property SLACK [lindex $worst_hold_path 0]]
puts "R3 post-route WNS: $r3_wns ns"
puts "R3 post-route WHS: $r3_whs ns"
if {$r3_wns < 0.0} {
    report_timing -delay_type max -max_paths 10
    error "MEGA65 R3/R3A timing failed: WNS=$r3_wns ns"
}
if {$r3_whs < 0.0} {
    report_timing -delay_type min -max_paths 10
    error "MEGA65 R3/R3A timing failed: WHS=$r3_whs ns"
}

set bit_file [file join $project_dir Nascom2_mega65_r3.runs impl_1 Mega65_Nascom2_R3.bit]
if {![file exists $bit_file]} {
    error "R3 bitstream was not generated: $bit_file"
}
puts "R3 bitstream: $bit_file"
