// Fully associative cache line
module FACacheline #(
    parameter RD_PORT_NUM    = 2,               // True read multi-port; No forwarding from Write port
    parameter WR_PORT_NUM    = 2,               // True write multi-port; Write port has priority & forwarding
    parameter ADDR_WIDTH     = 13,              // For Total addr=16; Cache line size= 8 bytes; Unit is Cache line
    parameter DATA_WIDTH     = 64               // Cache line size
)(
    input  logic                                    clk,
    input  logic                                    rst,

    // Read Port
    input  logic [RD_PORT_NUM-1:0][ADDR_WIDTH-1:0]  rd_addr,
    output logic [RD_PORT_NUM-1:0]                  rd_hit,
    output logic [RD_PORT_NUM-1:0][DATA_WIDTH-1:0]  rd_data_out,

    // Write port
    input  logic [WR_PORT_NUM-1:0][ADDR_WIDTH-1:0]  wr_addr,
    input  logic [WR_PORT_NUM-1:0][DATA_WIDTH-1:0]  wr_data_in,
    input  logic [WR_PORT_NUM-1:0]                  wr_dirty_in,
    input  logic [WR_PORT_NUM-1:0]                  wr_en,
    output logic [WR_PORT_NUM-1:0]                  wr_hit,
    output logic [WR_PORT_NUM-1:0][ADDR_WIDTH-1:0]  evicted_addr,
    output logic [WR_PORT_NUM-1:0][DATA_WIDTH-1:0]  evicted_data,
    output logic [WR_PORT_NUM-1:0]                  evicted_dirty,
    output logic [WR_PORT_NUM-1:0]                  evict,

    // Debug output
    output logic [DATA_WIDTH-1:0]                   dbg_cache_mem,
    output logic [ADDR_WIDTH-1:0]                   dbg_cache_addr,
    output logic                                    dbg_cache_valid,
    output logic                                    dbg_cache_dirty
);

    genvar i;

    logic                  [DATA_WIDTH-1:0] cache_mem;
    logic                  [ADDR_WIDTH-1:0] cache_tag;
    logic                                   cache_valid;
    logic                                   cache_dirty;
    logic [WR_PORT_NUM-1:0][DATA_WIDTH-1:0] nxt_cache_mem;
    logic [WR_PORT_NUM-1:0][ADDR_WIDTH-1:0] nxt_cache_tag;
    logic [WR_PORT_NUM-1:0]                 nxt_cache_valid;
    logic [WR_PORT_NUM-1:0]                 nxt_cache_dirty;

    always_ff @(posedge clk)begin
        if(rst)begin
            cache_mem   <= '0;
            cache_tag   <= '0;
            cache_valid <= '0;
            cache_dirty <= '0;
        end
        else begin
            cache_mem   <= nxt_cache_mem[WR_PORT_NUM-1];
            cache_tag   <= nxt_cache_tag[WR_PORT_NUM-1];
            cache_valid <= nxt_cache_valid[WR_PORT_NUM-1];
            cache_dirty <= nxt_cache_dirty[WR_PORT_NUM-1];
        end
    end

    generate
        // Read output logic
        for(i=0;i<RD_PORT_NUM;i++)begin
            assign rd_hit[i]      = cache_valid & (cache_tag == rd_addr[i]);
            assign rd_data_out[i] = cache_mem;
        end

        // Write output logic
        // First port
        assign wr_hit[0]        = cache_valid & (cache_tag == wr_addr[0]);
        assign evicted_data[0]  = cache_mem;
        assign evicted_addr[0]  = cache_tag;
        assign evicted_dirty[0] = cache_dirty;
        assign evict[0]         = wr_en[0] & cache_valid & (cache_tag != wr_addr[0]);
        for(i=1;i<WR_PORT_NUM;i++)begin
            assign wr_hit[i]        = nxt_cache_valid[i-1] & (nxt_cache_tag[i-1] == wr_addr[i]);
            assign evicted_data[i]  = nxt_cache_mem[i-1];
            assign evicted_addr[i]  = nxt_cache_tag[i-1];
            assign evicted_dirty[i] = nxt_cache_dirty[i-1];
            assign evict[i]         = wr_en[i] & nxt_cache_valid[i-1] & (nxt_cache_tag[i-1] != wr_addr[i]);
        end

        // nxt logic
        assign nxt_cache_mem[0]   = wr_en[0] ? wr_data_in[0]                : cache_mem;
        assign nxt_cache_tag[0]   = wr_en[0] ? wr_addr[0]                   : cache_tag;
        assign nxt_cache_valid[0] = wr_en[0]                                | cache_valid;
        assign nxt_cache_dirty[0] = wr_en[0] ? (wr_hit[0] | wr_dirty_in[0]) : cache_dirty;
        for(i=1;i<WR_PORT_NUM;i++)begin
            assign nxt_cache_mem[i]   = wr_en[i] ? wr_data_in[i]                : nxt_cache_mem[i-1];
            assign nxt_cache_tag[i]   = wr_en[i] ? wr_addr[i]                   : nxt_cache_tag[i-1];
            assign nxt_cache_valid[i] = wr_en[i]                                | nxt_cache_valid[i-1];
            assign nxt_cache_dirty[i] = wr_en[i] ? (wr_hit[i] | wr_dirty_in[i]) : nxt_cache_dirty[i-1];
        end
    endgenerate

    // Debug output
    assign dbg_cache_mem   = cache_mem;
    assign dbg_cache_addr  = cache_tag;
    assign dbg_cache_valid = cache_valid;
    assign dbg_cache_dirty = cache_dirty;

endmodule
