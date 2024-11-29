
// This is a pipelined multiplier that multiplies two 64-bit integers and
// returns the low 64 bits of the result.
// This is not an ideal multiplier but is sufficient to allow a faster clock
// period than straight multiplication.

`include "./verilog/mult_defs.svh" // for `STAGES

module Pipeline #(
    parameter DATA_WIDTH = 1
)(
    // Global
    input  logic                 clk,rst_n,
    // Upstream
    input  logic[DATA_WIDTH-1:0] in_data, 
    input  logic                 in_vld,
    output logic                 in_rdy,
    // Downstream
    output logic[DATA_WIDTH-1:0] out_data,
    output logic                 out_vld,
    input  logic                 out_rdy
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

endmodule

module mult (
    input         clk,clk_shadow,rst_n,
    input         in_vld,
    output        in_rdy,
    input [63:0]  mcand, mplier,

    output [63:0] product,
    output logic  out_vld,
    input  logic  out_rdy
);

    logic [`STAGES-2:0] internal_vld,internal_rdy;
    logic [(64*(`STAGES-1))-1:0] internal_product_sums, internal_mcands, internal_mpliers;
    logic [63:0] mcand_out, mplier_out; // unused, just for wiring

    logic[63:0] pipe_mcand,pipe_mplier;
    logic       pipe_vld,pipe_rdy;

    Pipeline #(
        .DATA_WIDTH (128)
    ) input_pipe (
        // Global
        .clk      (clk                      ),
        .rst_n    (rst_n                    ),
        // Upstream
        .in_data  ({mcand,      mplier     }), 
        .in_vld   (in_vld                   ),
        .in_rdy   (in_rdy                   ),
        // Downstream
        .out_data ({pipe_mcand, pipe_mplier}),
        .out_vld  (pipe_vld                 ),
        .out_rdy  (pipe_rdy                 )
    );

    // instantiate an array of mult_stage modules
    // this uses concatenation syntax for internal wiring, see lab 2 slides
    mult_stage mstage [`STAGES-1:0] (
        .clk         (clk                                           ),
        .clk_shadow  (clk_shadow                                    ),
        .rst_n       (rst_n                                         ),
        .in_vld      ({internal_vld,          pipe_vld             }),
        .in_rdy      ({internal_rdy,          pipe_rdy             }),
        .prev_sum    ({internal_product_sums, 64'h0                }), // start the sum at 0
        .mplier      ({internal_mpliers,      pipe_mplier          }),
        .mcand       ({internal_mcands,       pipe_mcand           }),
        .product_sum ({product,               internal_product_sums}),
        .next_mplier ({mplier_out,            internal_mpliers     }),
        .next_mcand  ({mcand_out,             internal_mcands      }),
        .out_vld     ({out_vld,               internal_vld         }),
        .out_rdy     ({out_rdy,               internal_rdy         })
    );

endmodule