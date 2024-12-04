#####################################################
#Read design data & technology
#####################################################

set CURRENT_PATH [pwd]
set TOP_DESIGN mult

# set search_path [list \
# 					"$CURRENT_PATH" \
# 					".."
# 				]

# ## Add libraries below
# ## technology .db file, and memory .db files
# set target_library ""

# set LINK_PATH [concat  "*" $target_library]

set target_library lec25dscc25_TT.db

# link_library is a variable for resolving standard cell references in designs
# the standard cell library we use is in the lec25dscc25_TT.db file
# the * will have dc_shell search its own library first, then the target
set link_library "* $target_library"

# the search path is where dc_shell will search for files to read and load
# lec25dscc25_TT.db is located in the last location
set search_path [list "./" "../" "../../" "/afs/umich.edu/class/eecs470/lib/synopsys/"]

set LINK_PATH [concat  "*" $target_library]

## Replace with your complete file paths
set SDC_FILE      	../synth/$TOP_DESIGN.sdc
set NETLIST_FILE	[list ../synth/$TOP_DESIGN.vg ../verilog/Comparator_synth.vg ../verilog/Comparator.sv]

## Replace with your instance hierarchy
set STRIP_PATH    test_mult/DUT

## Replace with your activity file dumped from vcs simulation
set ACTIVITY_FILE 	../Waveform/waveform.vcd

######## Timing Sections ########
set	START_TIME 0
set	END_TIME 70087360
