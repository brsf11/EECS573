set design_name mult_stage_comb

try { set_host_options -max_cores [getenv DC_SHELL_MULTICORE] } on error {} {}
set hdlin_ff_always_sync_set_reset "true"

set target_library lec25dscc25_TT.db
set link_library "* $target_library"
set search_path [list "./" "../" "/afs/umich.edu/class/eecs470/lib/synopsys/"]

proc eecs_470_set_compilation_flags {} {
  set_app_var compile_top_all_paths "true"
  set_app_var auto_wire_load_selection "false"
}

proc eecs_470_set_wire_load {design_name} {
  set WIRE_LOAD tsmcwire
  set LOGICLIB lec25dscc25_TT

  set_wire_load_model -name $WIRE_LOAD -lib $LOGICLIB $design_name
  set_wire_load_mode top
  set_fix_multiple_port_nets -outputs -buffer_constants
}

set timing_enable_sdf_generation true

source read_design.tcl

eecs_470_set_compilation_flags
eecs_470_set_wire_load $design_name 

set max_dalay [getenv MAX_DELAY]
set min_dalay [getenv MIN_DELAY]

set_max_delay $max_dalay -from [all_inputs] -to [all_outputs]
compile_ultra

if {$min_dalay != "0.0"} {
    set_min_delay $min_dalay -from [all_inputs] -to [all_outputs]
    set_cost_priority -min_delay
    compile -incremental_mapping
}

set netlist_file ./mult_${max_dalay}_${min_dalay}/${design_name}.vg       ;# our .vg file! it's generated here!
set ddc_file     ./mult_${max_dalay}_${min_dalay}/${design_name}.ddc      ;# the internal dc_shell design representation (binary data)
set rep_file     ./mult_${max_dalay}_${min_dalay}/${design_name}.rep      ;# area, timing, constraint, resource, and netlist reports
set sdf_file     ./mult_${max_dalay}_${min_dalay}/${design_name}.sdf      ;# SDF file
set sdc_file     ./mult_${max_dalay}_${min_dalay}/${design_name}.sdc      ;# SDC file

# write the design into both sv and ddc formats, also the svsim wrapper
write_file -hierarchy -format verilog -output $netlist_file $design_name
write_file -hierarchy -format ddc     -output $ddc_file     $design_name

write_sdf -version 2.1 $sdf_file
write_sdc $sdc_file
# the various reports (design, area, timing, constraints, resources)
redirect         $rep_file { report_design -nosplit }
redirect -append $rep_file { report_area }
redirect -append $rep_file { report_timing -input_pins -nets -transition_time -nosplit }
redirect -append $rep_file { report_constraint -max_delay -verbose -nosplit }
redirect -append $rep_file { report_resources -hier }

# also report a reference of the used modules from the final netlist
#remove_design -all
#read_file -format verilog $netlist_file
#current_design $design_name
#redirect -append $rep_file { report_reference -nosplit }
exit 0 ;# success! (maybe)
