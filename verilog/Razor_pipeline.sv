module Razor_pipeline #(
    parameter DATA_WIDTH = 192
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

    logic[DATA_WIDTH-1:0] out_data_shadow;
    logic                 is_speculative;
    logic                 data_valid;
    logic                 nxt_data_valid;

    // out_data  -> clk domain
    // is_speculative -> clk domain
    logic[DATA_WIDTH-1:0] nxt_out_data;
    logic                 nxt_is_speculative;

    always_ff @(posedge clk) begin
        if(!rst_n) begin
            out_data       <= 0;
            is_speculative <= 0;
        end
        else begin
            out_data       <= nxt_out_data;
            is_speculative <= nxt_is_speculative;
        end
    end

    always_comb begin
        if(is_speculative | data_valid) begin
            if(mismatch) begin
                nxt_out_data       = out_data_shadow;
                nxt_is_speculative = 1'b0;
            end
            else if(in_vld & in_rdy) begin
                nxt_out_data       = in_data;
                nxt_is_speculative = 1'b1;
            end
            else begin
                nxt_out_data       = out_data;
                nxt_is_speculative = 1'b0;
            end
        end
        else begin
            nxt_out_data       = in_data;
            nxt_is_speculative = in_vld & in_rdy;
        end
    end

    always_ff @(posedge clk) begin
        if(!rst_n) begin
            data_valid <= 1'b0;
        end
        else begin
            data_valid <= nxt_data_valid;
        end
    end

    always_comb begin
        if(data_valid) begin
            nxt_data_valid = ~out_rdy;
        end
        else begin
            nxt_data_valid = mismatch | (is_speculative & (~out_rdy));
        end
    end

    // out_data_shaow -> clk_shadow domain
    // mismatch       -> clk_shadow domain
    always_ff @(posedge clk_shadow) begin
        if(!rst_n) begin
            out_data_shadow <= 0;
            // mismatch        <= 0;
        end
        else begin
            out_data_shadow <= in_data;
            // `ifdef SYNTH
            // mismatch        <= is_speculative & (|(in_data ^ out_data));
            // `else
            // mismatch        <= 0;
            // `endif
        end
    end

    `ifdef SYNTH
    assign mismatch = is_speculative & (|(out_data_shadow ^ out_data));
    `else
    assign mismatch = 0;
    `endif

    // Other logic
    assign in_rdy  = ((~(is_speculative | data_valid)) | out_rdy) & (~mismatch);
    assign out_vld = (is_speculative & (~mismatch)) | data_valid;

endmodule
