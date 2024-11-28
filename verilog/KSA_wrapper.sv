module KSA_wrapper(
    // Global
    input  logic                 clk,clk_shadow,rst_n,
    // Upstream
    input  logic[7:0]            A,B,
    input  logic                 Cin,
    input  logic                 in_vld,
    output logic                 in_rdy,
    // Downstream
    output logic[7:0]            Sum,
    output logic                 Cout,
    output logic                 out_vld,
    input  logic                 out_rdy,
    // Other
    output logic                 mismatch
);

logic [7:0] inner_Sum;
logic       inner_Cout;

KSA #(
    .wididx(3)
    ) KSA 
    (
        .A    (A         ),
        .B    (B         ),
        .Cin  (Cin       ),
        .Sum  (inner_Sum ),
        .Cout (inner_Cout)
    );

logic [8:0] out_data;

Razor_pipeline #(
    .DATA_WIDTH (9)
    ) razor_pipeline (
        // Global
        .clk        (clk                   ),
        .clk_shadow (clk_shadow            ),
        .rst_n      (rst_n                 ),
        // Upstream
        .in_data    ({inner_Sum,inner_Cout}), 
        .in_vld     (in_vld                ),
        .in_rdy     (in_rdy                ),
        // Downstream
        .out_data   (out_data              ),
        .out_vld    (out_vld               ),
        .out_rdy    (out_rdy               ),
        // Other
        .mismatch   (mismatch              )
    );

    assign {Sum,Cout} = out_data;

endmodule
