module IcacheCore#(
    parameter INT_IDX    = 2 // Interleavin Index
)(
    input  logic                                     clk,
    input  logic                                     rst,

    // Read Port
    input  logic [(2**INT_IDX)-1:0][12-INT_IDX:0]      rd_addr,
    output logic [(2**INT_IDX)-1:0]                    rd_hit,
    output logic [(2**INT_IDX)-1:0][63:0]              rd_data_out,

    // Write port
    input  logic [(2**INT_IDX)-1:0][1:0][12-INT_IDX:0] wr_addr,
    input  logic [(2**INT_IDX)-1:0][1:0][63:0]         wr_data_in,
    input  logic [(2**INT_IDX)-1:0][1:0]               wr_en
);

    genvar i;

    generate
        for(i=0;i<(2**INT_IDX);i++)begin
            CacheCore_DM #(
                .RD_PORT_NUM    (1         ), // True read multi-port; No forwarding from Write port
                .WR_PORT_NUM    (2         ), // True write multi-port; Write port has priority & forwarding
                .ADDR_WIDTH     (13-INT_IDX), // For Total addr=16; Cache line size= 8 bytes; Unit is Cache line
                .DATA_WIDTH     (64        ), // Cache line size
                .INDEX_WIDTH    (5-INT_IDX )  // Index width; Default Cache line number = 2 ** INDEX_WIDTH
            ) sub_cache_core (
                .clk            (clk),
                .rst            (rst),
                .rd_addr        (rd_addr    [i]),
                .rd_hit         (rd_hit     [i]),
                .rd_data_out    (rd_data_out[i]),
                .wr_addr        (wr_addr    [i]),
                .wr_data_in     (wr_data_in [i]),
                .wr_dirty_in    ('0            ),
                .wr_en          (wr_en      [i])
            );
        end
    endgenerate


endmodule