
// This is one stage of an 8 stage pipelined multiplier that multiplies
// two 64-bit integers and returns the low 64 bits of the result.
// This is not an ideal multiplier but is sufficient to allow a faster clock
// period than straight multiplication.

`include "./verilog/mult_defs.svh" // for `STAGES

module mult_stage_comb (
    input  logic [63:0] prev_sum, mplier, mcand,
    output logic [63:0] product_sum, shifted_mplier, shifted_mcand
);

    parameter SHIFT = 64/`STAGES;

    logic [63:0] partial_product;

    assign partial_product = mplier[SHIFT-1:0] * mcand;
    assign shifted_mplier  = {SHIFT'('b0), mplier[63:SHIFT]};
    assign shifted_mcand   = {mcand[63-SHIFT:0], SHIFT'('b0)};
    assign product_sum     = prev_sum + partial_product;

endmodule