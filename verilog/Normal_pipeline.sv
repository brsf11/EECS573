module Razor_pipeline #(
    parameter DATA_WIDTH = 1
)(
    // Global
    input  logic                 clk,clk_shadow,rst_n,
    // Upstream
    input  logic[DATA_WIDTH-1:0] in_data, 
    input  logic                 in_vld,
    output logic                 in_rdy,
    // Downstream
    output logic[DATA_WIDTH-1:0] out_data,
    output logic                 out_vld,
    input  logic                 out_rdy,
    // Other
    output logic                 mismatch
);

    assign in_rdy = (~out_vld) | out_rdy;

    always_ff @(posedge clk)begin
        if(~rst_n)begin
            out_data <= 0;
        end
        else begin
            if(in_vld & in_rdy)
                out_data <= in_data;
        end
    end

    always_ff @(posedge clk)begin
        if(~rst_n)begin
            out_vld <= 0;
        end
        else begin
            if(in_vld & in_rdy)
                out_vld <= 1'b1;
            else if(out_rdy)
                out_vld <= 1'b0;
        end
    end

    assign mismatch = 0;

endmodule
