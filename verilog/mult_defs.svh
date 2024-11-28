
`ifndef MULT_DEFS_SVH
`define MULT_DEFS_SVH

// Define the number of stages in a header for easy editing

// P2 TODO: Run: `make -B mult.vg CLOCK_PERIOD=9.0; make slack`
//          and find the minimum clock period at which slack is met for 8 stages,
//          then change STAGES and find the minimum for 4 stages, and again for 2 stages.
//          Set this back to 8 for programming the ISR module.

// STAGES can be 2, 4, or 8
`define STAGES 8


`endif // MULT_DEFS_SVH