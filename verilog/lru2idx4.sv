module lru2idx4 (
    input  logic [2:0] lru,
    output logic [1:0] idx
);

    assign idx[1] = lru[0];
    assign idx[0] = idx[1] ? lru[2] : lru[1];

endmodule