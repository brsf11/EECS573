
// This is one stage of an 8 stage pipelined multiplier that multiplies
// two 64-bit integers and returns the low 64 bits of the result.
// This is not an ideal multiplier but is sufficient to allow a faster clock
// period than straight multiplication.

`include "./verilog/mult_defs.svh" // for `STAGES

module mult_stage (
    input        clk,clk_shadow,rst_n,
    input        in_vld,
    output       in_rdy,
    input [63:0] prev_sum, mplier, mcand,

    output logic [63:0] product_sum, next_mplier, next_mcand,
    output logic        out_vld,
    input  logic        out_rdy
);
    logic [63:0] product_sum_comb, shifted_mplier, shifted_mcand;

    mult_stage_comb mult_stage_comb(
        .prev_sum       (prev_sum         ), 
        .mplier         (mplier           ), 
        .mcand          (mcand            ),
        .product_sum    (product_sum_comb ), 
        .shifted_mplier (shifted_mplier   ), 
        .shifted_mcand  (shifted_mcand    )
    );

    Razor_pipeline #(
        .DATA_WIDTH (192)
    ) razor_pipeline (
        // Global
        .clk        (clk                   ),
        .clk_shadow (clk_shadow            ),
        .rst_n      (rst_n                 ),
        // Upstream
        .in_data    ({product_sum_comb, shifted_mplier, shifted_mcand}), 
        .in_vld     (in_vld                ),
        .in_rdy     (in_rdy                ),
        // Downstream
        .out_data   ({product_sum,      next_mplier,    next_mcand}),
        .out_vld    (out_vld               ),
        .out_rdy    (out_rdy               ),
        // Other
        .mismatch   ()
    );

endmodule