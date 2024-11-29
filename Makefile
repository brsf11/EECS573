##########################
# ---- Introduction ---- #
##########################

# Welcome to the EECS 470 standard makefile!

# NOTE: you should only need to modify the "Executable Compilation" section
# namely the TESTBENCH, SOURCES, and SYNTH_FILES variables
# look for the 'LAB2 TODO' markers below

# reference table of all make targets:

# make           <- runs the default target, set explicitly below as 'make sim'
.DEFAULT_GOAL = sim
# ^ this overrides using the first listed target as the default

# make sim       <- execute the simulation testbench (simv)
# make simv      <- compiles simv from the testbench and SOURCES

# make syn       <- execute the synthesized module testbench (syn_simv)
# make syn_simv  <- compiles syn_simv from the testbench and *.vg SYNTH_FILES
# make *.vg      <- synthesize the top level module in SOURCES for use in syn_simv
# make slack     <- a phony command to print the slack of any synthesized modules

# make verdi     <- runs the Verdi GUI debugger for simulation
# make syn_verdi <- runs the Verdi GUI debugger for synthesis

# make clean     <- remove files created during compilations (but not synthesis)
# make nuke      <- remove all files created during compilation and synthesis
# make clean_run_files <- remove per-run output files
# make clean_exe       <- remove compiled executable files
# make clean_synth     <- remove generated synthesis files

######################################################
# ---- Compilation Commands and Other Variables ---- #
######################################################

# this is a global clock period variable used in the tcl script and referenced in testbenches
# LAB2 TODO: Finish your 64-bit testbench, then synthesize the design.
#            Change the clock period so that slack isn't violated

# the Verilog Compiler command and arguments
VCS = vcs -sverilog +vc -Mupdate -line -full64 -kdb -lca \
      -debug_access+all+reverse $(VCS_BAD_WARNINGS) +define+CLOCK_PERIOD=$(CLOCK_PERIOD)
# a SYNTH define is added when compiling for synthesis that can be used in testbenches

# remove certain warnings that generate MB of text but can be safely ignored
VCS_BAD_WARNINGS = +warn=noTFIPC +warn=noDEBUG_DEP +warn=noENUMASSIGN

# a reference library of standard structural cells that we link against when synthesizing
LIB = /afs/umich.edu/class/eecs470/lib/verilog/lec25dscc25.v

# the EECS 470 synthesis script
TCL_SCRIPT = synth/470synth.tcl

####################################
# ---- Executable Compilation ---- #
####################################

# You should only need to modify this section, and only the following variables:
TESTBENCH   = test/test_mult.sv
SOURCES     = verilog/mult_stage.sv \
			  verilog/mult.sv \
			  verilog/Razor_pipeline.sv
SYNTH_FILES = synth/mult.vg
export CHILD_MODULES = mult_stage_comb

MULT_STAGE_COMB_SOURCE = verilog/mult_stage_comb.sv


SDF_DEFINE = -sdf typ:test_mult.DUT:synth/mult.sdf

MAX_DELAY         = 5.0
MIN_DELAY         = 2.5
CLOCK_UNCERTAINTY = 0.1
SETUP_TIME        = 0.47

export CLOCK_PERIOD = $(shell echo "$(MAX_DELAY) - $(MIN_DELAY) + 2 * $(CLOCK_UNCERTAINTY) + $(SETUP_TIME)" | bc -l)
SKEW = $(shell echo "$(MIN_DELAY) - $(CLOCK_UNCERTAINTY)" | bc -l)

export DDC_FILES = presynth/mult_$(MAX_DELAY)_$(MIN_DELAY)/mult_stage_comb.ddc

TIMING_DEFINE = +define+TEST_CLOCK_PERIOD=$(CLOCK_PERIOD) +define+SHADOW_SKEW=$(SKEW)

# LAB2 TODO: write the 1bit testbench, then compile and run with `make`
#            once it passes, change the variables and test the 64bit adder
#            (change '1bit' to '64bit', but keep full_adder_1bit.sv in SOURCES)

# the .vg rule is automatically generated below when the name of the file matches its top level module

# the normal simulation executable will run your testbench on the original modules
simv: $(TESTBENCH) $(SOURCES)
	@$(call PRINT_COLOR, 5, compiling the simulation executable $@)
	@$(call PRINT_COLOR, 3, NOTE: if this is slow to startup: run '"module load vcs verdi synopsys-synth"')
	$(VCS) $(TIMING_DEFINE) $^ $(MULT_STAGE_COMB_SOURCE) -o $@
	@$(call PRINT_COLOR, 6, finished compiling $@)
# NOTE: we reference variables with $(VARIABLE), and can make use of the automatic variables: ^, @, <, etc
# see: https://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html for explanations

# a make pattern rule to generate the .vg synthesis files
# pattern rules use the % as a wildcard to match multiple possible targets
synth/%.vg: $(SOURCES) $(TCL_SCRIPT) $(HEADERS)
	@$(call PRINT_COLOR, 5, synthesizing the $* module)
	@$(call PRINT_COLOR, 3, this might take a while...)
	@$(call PRINT_COLOR, 3, NOTE: if this is slow to startup: run '"module load vcs verdi synopsys-synth"')
	# pipefail causes the command to exit on failure even though it's piping to tee
	set -o pipefail; cd synth && MODULE=$* SOURCES="$(SOURCES)" dc_shell-t -f $(notdir $(TCL_SCRIPT)) | tee $*_synth.out
	@$(call PRINT_COLOR, 6, finished synthesizing $@)
# this also generates many other files, see the tcl script's introduction for info on each of them

# add all sources as extra dependencies for each SYNTH_FILES target
# this is used when SOURCES="$^" uses the automatic variable $^ to reference all dependencies
# $(SYNTH_FILES): $(SOURCES)

# the synthesis executable runs your testbench on the synthesized versions of your modules
syn_simv: $(TESTBENCH) $(SYNTH_FILES)
	@$(call PRINT_COLOR, 5, compiling the synthesis executable $@)
	$(VCS) $(SDF_DEFINE) $(TIMING_DEFINE) +define+SYNTH $^ $(LIB) -o $@
	@$(call PRINT_COLOR, 6, finished compiling $@)
# we need to link the synthesized modules against LIB, so this differs slightly from simv above
# but we still compile with the same non-synthesizable testbench

# a phony target to view the slack in the *.rep synthesis report file
slack:
	grep --color=auto "slack" *.rep
.PHONY: slack

#####################################
# ---- Running the Executables ---- #
#####################################

# these targets run the compiled executable and save the output to a .out file
# their respective files are program.out or program.syn.out

sim: simv
	@$(call PRINT_COLOR, 5, running $<)
	./simv | tee program.out
	@$(call PRINT_COLOR, 2, output saved to program.out)

syn: syn_simv
	@$(call PRINT_COLOR, 5, running $<)
	./syn_simv > tee program.syn.out
	@$(call PRINT_COLOR, 2, output saved to program.syn.out)

# NOTE: phony targets don't create files matching their name, and make will always run their commands
# make doesn't know how files get created, so we tell it about these explicitly:
.PHONY: sim syn

###################
# ---- Verdi ---- #
###################

# verdi is the synopsys debug system, and an essential tool in EECS 470

# these targets run the executables using verdi
verdi: simv novas.rc verdi_dir
	./simv -gui=verdi

syn_verdi: syn_simv novas.rc verdi_dir
	./syn_simv -gui=verdi

.PHONY: verdi syn_verdi

# this creates a directory verdi will use if it doesn't exist yet
verdi_dir:
	mkdir -p /tmp/$${USER}470
.PHONY: verdi_dir

novas.rc: initialnovas.rc
	sed s/UNIQNAME/$$USER/ initialnovas.rc > novas.rc

#####################
# ---- Cleanup ---- #
#####################

# You should only clean your directory if you think something has built incorrectly
# or you want to prepare a clean directory for e.g. git (first check your .gitignore).
# Please avoid cleaning before every build. The point of a makefile is to
# automatically determine which targets have dependencies that are modified,
# and to re-build only those as needed; avoiding re-building everything everytime.

# 'make clean' removes build/output files, 'make nuke' removes all generated files
# clean_* commands clean certain groups of files

clean: clean_exe clean_run_files
	@$(call PRINT_COLOR, 6, note: clean is split into multiple commands that you can call separately: clean_exe and clean_run_files)

# use cautiously, this can cause hours of recompiling in later projects
nuke: clean clean_synth
	@$(call PRINT_COLOR, 6, note: nuke is split into multiple commands that you can call separately: clean_synth)

clean_exe:
	@$(call PRINT_COLOR, 3, removing compiled executable files)
	rm -rf *simv *.daidir csrc *.key vcdplus.vpd vc_hdrs.h
	rm -rf verdi* novas* *fsdb*

clean_run_files:
	@$(call PRINT_COLOR, 3, removing per-run outputs)
	rm -rf *.out *.dump

clean_synth:
	@$(call PRINT_COLOR, 1, removing synthesis files)
	cd synth && rm -rf *.vg *_svsim.sv *.res *.rep *.ddc *.chk *.syn *.out *.db *.svf *.mr *.pvl command.log

.PHONY: clean nuke clean_%

######################
# ---- Printing ---- #
######################

# this is a GNU Make function with two arguments: PRINT_COLOR(color: number, msg: string)
# it does all the color printing throughout the makefile
PRINT_COLOR = if [ -t 0 ]; then tput setaf $(1) ; fi; echo $(2); if [ -t 0 ]; then tput sgr0; fi
# colors: 0:black, 1:red, 2:green, 3:yellow, 4:blue, 5:magenta, 6:cyan, 7:white
# other numbers are valid, but aren't specified in the tput man page

# Make functions are called like this:
# $(call PRINT_COLOR,3,Hello World!)
# NOTE: adding '@' to the start of a line avoids printing the command itself, only the output
