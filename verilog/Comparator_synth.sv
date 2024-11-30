module Comparator (
    input  logic [191:0] A,B,
    output logic         out
);

    assign out = ~(A == B);

endmodule