
# EECS 470 Project 3

Welcome to the EECS 470 Project 3 VeriSimpleV Processor!

This is the repository for a 5-stage, pipelined, synthesizable, RISC-V
processor which will be the basis of your final project. VeriSimpleV is
based on the common 5-stage pipeline mentioned in class and the text.

See the [Project Specification](https://drive.google.com/file/d/1XaPiocfSfWfQdJxsrXNeeH1_XXoLH6jF/view?usp=drive_link)
and the [RISC-V Introduction slides](https://drive.google.com/file/d/1xsHJ_FIMXR7fHx27GREDBSqr7L3B3Ql_/view?usp=drive_link)
for more details on the processor and assignment.

## Assignment

The processor is unfinished! The provided implementation
*has no hazard detection logic!* To accommodate this, the provided
processor only allows one instruction in the pipeline at a time, to be
absolutely certain there are no hazards. The provided processor is
correct, and it will produce the correct output for all programs, but
it has a miserable CPI of 5.0.

Your assignment is to modify the VeriSimpleV processor to remove the
stalls and implement hazard and forwarding logic as described in
lecture and the text. See the specification for more details.

### Project Files

For this project, you are provided with most of the code and the entire
build and test system. This is a quick overview of the Makefile and the
verilog files you will be editing. See the lab 4 slides for an extended
discussion.

The \VeriSimpleV{} pipeline is broken up into 9 files in the `verilog/`
folder. There are 2 headers: `sys_defs.svh` defines data structures and
typedefs, and `ISA.svh` define decoding information used by the ID
stage. There are 5 files for the pipeline stages:
`stage_{if,id,ex,mem,wb}.sv`. The register file is in `regfile.sv` and
is instantiated inside the ID stage. Finally, the stages are tied
together by the pipeline module in `pipeline.sv`.

The `sys_defs.svh` file contains all of the `typedef`s and `define`s
that are used in the pipeline and testbench. The testbench and
associated non-synthesizable verilog can be found in the `test/`
folder. Note that the memory module defined in `test/mem.sv` is
not synthesizable.

### Getting Started

Start the project by removing the provided stalling behavior, then
implement the structural hazard logic for the milestone.

The provided stalling behavior is set in the `verilog/pipeline.sv`
file. You should open the file and find the `always_ff` block where the
`next_if_valid` signal is set. This is the start of a `valid` bit
which is passed between the stages along with the instruction, and it
starts at 1 in the IF stage due to `next_if_valid`. The `next_if_valid`
signal is currently set to read the valid bit from the WB stage, so
will insert 4 invalid instructions between every valid one.

## Makefile Target Reference

To run a program on the processor, run `make <my_program>.out`. This
will assemble a RISC-V `*.mem` file which will be loaded into `mem.sv`
by the testbench, and will also compile the processor and run the
program.

All of the "`<my_program>.abc`" targets are linked to do both the
executable compilation step and the `.mem` compilation steps if
necessary, so you can run each without needing to run anything else
first.

`make <my_program>.out` should be your main command for running
programs: it creates the `<my_program>.out`, `<my_program>.wb`, and
`<my_program>.ppln` output, writeback, and pipeline output files in the
`output/` directory. The output file includes the status of memory and
the CPI, the writeback file is the list of writes to registers done by
the program, and the pipeline file is the state of each of the pipeline
stages as the program is run.

The following Makefile rules are available to run programs on the
processor:

```
# ---- Program Execution ---- #
# These are your main commands for running programs and generating output
make <my_program>.out      <- run a program on simv
                              generate *.out, *.wb, and *.ppln files in 'output/'
make <my_program>.syn.out  <- run a program on syn_simv and do the same

# ---- Executable Compilation ---- #
make simv      <- compiles simv from the TESTBENCH and SOURCES
make syn_simv  <- compiles syn_simv from TESTBENCH and SYNTH_FILES
make *.vg      <- synthesize modules in SOURCES for use in syn_simv
make slack     <- grep the slack status of any synthesized modules

# ---- Program Memory Compilation ---- #
# Programs to run are in the programs/ directory
make programs/<my_program>.mem  <- compile a program to a RISC-V memory file
make compile_all                <- compile every program at once (in parallel with -j)

# ---- Dump Files ---- #
make <my_program>.dump  <- disassembles compiled memory into RISC-V assembly dump files
make *.debug.dump       <- for a .c program, creates dump files with a debug flag
make dump_all           <- create all dump files at once (in parallel with -j)

# ---- Verdi ---- #
make <my_program>.verdi     <- run a program in verdi via simv
make <my_program>.syn.verdi <- run a program in verdi via syn_simv

# ---- Visual Debugger ---- #
make <my_program>.vis  <- run a program on the project 3 vtuber visual debugger!
make vis_simv          <- compile the vtuber executable from VTUBER and SOURCES

# ---- Cleanup ---- #
make clean            <- remove per-run files and compiled executable files
make nuke             <- remove all files created from make rules
```
