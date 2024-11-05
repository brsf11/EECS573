module unsteer #(
    parameter INDEX = 2,
    parameter WIDTH = 16
)(
    input  logic [2**INDEX-1:0][WIDTH-1:0] data_in,
    input  logic [INDEX-1:0]               order,
    output logic [2**INDEX-1:0][WIDTH-1:0] data_out
);

    genvar i;

    logic [2**INDEX-1:0][INDEX-1:0] idx;
    generate
        for(i=0;i<2**INDEX;i++)begin
            assign idx[i]      = i + order;
            assign data_out[i] = data_in[idx[i]];
        end
    endgenerate

endmodule