module Comparator (A,B,out);
input [191:0] A;
input [191:0] B;
output        out;

    assign out = ~(A === B);

    // For Power estimation only
    Comparator_synth Comparator_synth(
        .A    (A),
        .B    (B),
        .out  ()
    );

endmodule