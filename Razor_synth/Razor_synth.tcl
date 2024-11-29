try {
    set clock_period 3.87
    set shadow_skew 1.7
    set sources verilog/Razor_pipeline.sv
    set design_name Razor_pipeline
} 

try { set_host_options -max_cores [getenv DC_SHELL_MULTICORE] } on error {} {}
set target_library lec25dscc25_TT.db
set link_library "* $target_library"
set search_path [list "./" "../" "/afs/umich.edu/class/eecs470/lib/synopsys/"]


set clock_name clk
set reset_name rst_n

# this makes it so you don't need to add
# // synopsys sync_set_reset "reset"
# before every always_ff block
# I'm not updating every source file because of this though
set hdlin_ff_always_sync_set_reset "true"

# Set some flags to suppress warnings that are safe to ignore in 470
suppress_message "VER-130" ;# warns on delays in non-blocking assignment
set suppress_errors "UID-401 OPT-1206 OPT-1207 OPT-12"

if { ![analyze -format sverilog -define SYNTH $sources] } {exit 1}

# elaborate, potentially with parameters
if { [info exists module_parameters] && $module_parameters ne ""} {
  if { ![elaborate $design_name -param "$module_parameters"] } {exit 1}
  set design_name ${design_name}_${param_suffix}
} else {
  if { ![elaborate $design_name] } {exit 1}
}

if { [current_design $design_name] == [list] } {exit 1}

#########################################
# ---- compilation setup functions ---- #
#########################################

# I'm defining functions here to break out and *name* the separate things we do for setup

proc eecs_470_set_compilation_flags {} {
  set_app_var compile_top_all_paths "true"
  set_app_var auto_wire_load_selection "false"
  set_app_var compile_seqmap_synchronous_extraction "true" ;# seems to be unused?
}

proc eecs_470_set_wire_load {design_name} {
  set WIRE_LOAD tsmcwire
  set LOGICLIB lec25dscc25_TT

  set_wire_load_model -name $WIRE_LOAD -lib $LOGICLIB $design_name
  set_wire_load_mode top
  set_fix_multiple_port_nets -outputs -buffer_constants
}

proc eecs_470_generate_clock {clock_name clock_period shadow_skew} {
  set CLK_UNCERTAINTY 0.1 ;# the latency/transition time of the clock

  create_clock -period $clock_period -name $clock_name [find port $clock_name]
  create_generated_clock -source [find port $clock_name] -edges { 1 2 3 } -edge_shift [list $shadow_skew $shadow_skew $shadow_skew ] -name clk_shadow [find port clk_shadow]
  set_clock_uncertainty $CLK_UNCERTAINTY $clock_name
  set_clock_uncertainty $CLK_UNCERTAINTY clk_shadow
  set_fix_hold $clock_name
  set_fix_hold clk_shadow
}

proc eecs_470_setup_paths {clock_name} {
  set DRIVING_CELL dffacs1 ;# the driving cell from the link_library

  # TODO: can we just remove these lines?
  group_path -from [all_inputs] -name input_grp
  group_path -to [all_outputs] -name output_grp

  set_driving_cell  -lib_cell $DRIVING_CELL [all_inputs]
  remove_driving_cell [find port $clock_name]
  remove_driving_cell [find port clk_shadow]
}

proc eecs_470_set_design_constraints {reset_name clock_name clock_period} {
  set AVG_FANOUT_LOAD 10
  set AVG_LOAD 0.1
  set AVG_INPUT_DELAY 0.1   ;# ns
  set AVG_OUTPUT_DELAY 0.1  ;# ns
  set CRIT_RANGE 1.0        ;# ns
  set MAX_FANOUT 32
  set MAX_TRANSITION 1.0    ;# percent

  # these are some unused values that I've commented out, but am leaving for reference
  # set HIGH_LOAD 1.0
  # set MID_FANOUT 8
  # set LOW_FANOUT 1
  # set HIGH_DRIVE 0
  # set FAST_TRANSITION 0.1

  # set some constraints
  set_fanout_load $AVG_FANOUT_LOAD [all_outputs]
  set_load $AVG_LOAD [all_outputs]
  set_input_delay $AVG_INPUT_DELAY -clock $clock_name [all_inputs]
  set_output_delay $AVG_OUTPUT_DELAY -clock $clock_name [all_outputs]

  # set_input_delay $AVG_INPUT_DELAY -clock clk_shadow [all_inputs]
  # set_output_delay $AVG_OUTPUT_DELAY -clock clk_shadow [all_outputs]

  # remove constraints for only the clock and reset
  # I'm not actually sure if we need these after the others or not
  remove_input_delay -clock $clock_name [find port $clock_name]
  remove_input_delay -clock $clock_name [find port clk_shadow]
  set_dont_touch $reset_name
  set_resistance 0 $reset_name
  set_drive 0 $reset_name

  # these define specific limitations on the design and optimizer
  set_critical_range $CRIT_RANGE [current_design]
  set_max_delay $clock_period [all_outputs]
  # these are currently unused for some reason, leaving commented
  # set_max_fanout $MAX_FANOUT [current_design]
  # set_max_transition $MAX_TRANSITION [current_design]
}

####################################
# ---- synthesize the design! ---- #
####################################

eecs_470_set_compilation_flags

# link our current design against the link_library
# exit if there was an error
if { ![link] } {exit 1}

eecs_470_set_wire_load $design_name
eecs_470_generate_clock $clock_name $clock_period $shadow_skew
eecs_470_setup_paths $clock_name
eecs_470_set_design_constraints $reset_name $clock_name $clock_period

# separate the subdesign instances to improve synthesis (excluding set_dont_touch designs)
# do this before writing the check file
uniquify
# ungroup -all -flatten

# write the check file before compiling
set chk_file ./${design_name}.chk
redirect $chk_file { check_design }

set timing_enable_sdf_generation true
# where the magic happens
# map_effort can be changed to high if you're ok with time increasing for better performance
# or you can change from compile to compile_ultra for best performance, but likely increased time
# compile -map_effort medium
compile_ultra

################################
# ---- write output files ---- #
################################

# note the .chk file is written just before the compile command above
set netlist_file ./${design_name}.vg       ;# our .vg file! it's generated here!
set ddc_file     ./${design_name}.ddc      ;# the internal dc_shell design representation (binary data)
set svsim_file   ./${design_name}_svsim.sv ;# a simulation instantiation wrapper
set rep_file     ./${design_name}.rep      ;# area, timing, constraint, resource, and netlist reports
set sdf_file     ./${design_name}.sdf      ;# SDF file
set sdc_file     ./${design_name}.sdc      ;# SDC file


# write the design into both sv and ddc formats, also the svsim wrapper
write_file -hierarchy -format verilog -output $netlist_file $design_name
write_file -hierarchy -format ddc     -output $ddc_file     $design_name
write_file            -format svsim   -output $svsim_file   $design_name

write_sdf -version 2.1 $sdf_file
write_sdc $sdc_file

# the various reports (design, area, timing, constraints, resources)
redirect         $rep_file { report_design -nosplit }
redirect -append $rep_file { report_area }
redirect -append $rep_file { report_timing -max_paths 2 -input_pins -nets -transition_time -nosplit }
redirect -append $rep_file { report_constraint -max_delay -verbose -nosplit }
redirect -append $rep_file { report_resources -hier }

# also report a reference of the used modules from the final netlist
remove_design -all
read_file -format verilog $netlist_file
current_design $design_name
redirect -append $rep_file { report_reference -nosplit }

exit 0 ;# success! (maybe)
