// Pseudo LRU 4 logic
module PLRU4 (
    input  logic[2:0] input_lru,
    input  logic[1:0] line_hit,
    input             hit,
    output logic[2:0] output_lru
);

    logic[2:0] update_lru;

    assign update_lru[0] = ~line_hit[1];
    assign update_lru[1] = line_hit[1] ? input_lru[1] : ~line_hit[0];
    assign update_lru[2] = line_hit[1] ? ~line_hit[0] : input_lru[2];

    assign output_lru = hit ? update_lru : input_lru;

endmodule