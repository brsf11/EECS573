module onehot2bin #(
    parameter WIDTH_INPUT  = 8,
    parameter WIDTH_OUTPUT = 3  // 2**WIDTH_OUTPUT >= WIDTH_INPUT
)(
    input  logic [WIDTH_INPUT-1:0]  onehot,
    output logic [WIDTH_OUTPUT-1:0] bin
);

    always_comb begin
        bin = 'b0;
        for(int i=0;i<WIDTH_INPUT;i++)begin
            if(onehot[i] == 1'b1)begin
                bin = i;
                break;
            end
        end
    end

endmodule