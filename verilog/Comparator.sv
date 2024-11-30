module Comparator #(
    parameter DATA_WIDTH = 192
)(
    input  logic [DATA_WIDTH-1:0] A,B,
    output logic                  out
);

    assign out = ~(A === B);

    // For Power estimation only
    Comparator_synth Comparator_synth(
        .A    (A),
        .B    (B),
        .out  ()
    );

endmodule