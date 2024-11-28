
// This is a pipelined multiplier that multiplies two 64-bit integers and
// returns the low 64 bits of the result.
// This is not an ideal multiplier but is sufficient to allow a faster clock
// period than straight multiplication.

`include "./verilog/mult_defs.svh" // for `STAGES

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

    // instantiate an array of mult_stage modules
    // this uses concatenation syntax for internal wiring, see lab 2 slides
    mult_stage mstage [`STAGES-1:0] (
        .clk         (clk                                           ),
        .clk_shadow  (clk_shadow                                    ),
        .rst_n       (rst_n                                         ),
        .in_vld      ({internal_vld,          in_vld               }),
        .in_rdy      ({internal_rdy,          in_rdy               }),
        .prev_sum    ({internal_product_sums, 64'h0                }), // start the sum at 0
        .mplier      ({internal_mpliers,      mplier               }),
        .mcand       ({internal_mcands,       mcand                }),
        .product_sum ({product,               internal_product_sums}),
        .next_mplier ({mplier_out,            internal_mpliers     }),
        .next_mcand  ({mcand_out,             internal_mcands      }),
        .out_vld     ({out_vld,               internal_vld         }),
        .out_rdy     ({out_rdy,               internal_rdy         })
    );

endmodule