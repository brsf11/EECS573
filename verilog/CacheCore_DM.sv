module CacheCore_DM #(
    parameter RD_PORT_NUM    = 2,               // True read multi-port; No forwarding from Write port
    parameter WR_PORT_NUM    = 2,               // True write multi-port; Write port has priority & forwarding
    parameter ADDR_WIDTH     = 13,              // For Total addr=16; Cache line size= 8 bytes; Unit is Cache line
    parameter DATA_WIDTH     = 64,              // Cache line size
    parameter INDEX_WIDTH    = 5,               // Index width; Default Cache line number = 2 ** INDEX_WIDTH
    parameter CACHE_LINE_NUM = 2 ** INDEX_WIDTH
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
    output logic [CACHE_LINE_NUM-1:0][DATA_WIDTH-1:0] dbg_cache_mem,
    output logic [CACHE_LINE_NUM-1:0][ADDR_WIDTH-1:0] dbg_cache_addr,
    output logic [CACHE_LINE_NUM-1:0]                 dbg_cache_valid,
    output logic [CACHE_LINE_NUM-1:0]                 dbg_cache_dirty
);

    genvar i,j;

    logic                  [CACHE_LINE_NUM-1:0][DATA_WIDTH-1:0]             cache_mem;
    logic                  [CACHE_LINE_NUM-1:0][ADDR_WIDTH-INDEX_WIDTH-1:0] cache_tag;
    logic                  [CACHE_LINE_NUM-1:0]                             cache_valid;
    logic                  [CACHE_LINE_NUM-1:0]                             cache_dirty;
    logic [WR_PORT_NUM-1:0][CACHE_LINE_NUM-1:0][DATA_WIDTH-1:0]             nxt_cache_mem;
    logic [WR_PORT_NUM-1:0][CACHE_LINE_NUM-1:0][ADDR_WIDTH-INDEX_WIDTH-1:0] nxt_cache_tag;
    logic [WR_PORT_NUM-1:0][CACHE_LINE_NUM-1:0]                             nxt_cache_valid;
    logic [WR_PORT_NUM-1:0][CACHE_LINE_NUM-1:0]                             nxt_cache_dirty;

    logic [RD_PORT_NUM-1:0][ADDR_WIDTH-INDEX_WIDTH-1:0] rd_tag;
    logic [RD_PORT_NUM-1:0]           [INDEX_WIDTH-1:0] rd_index;

    logic [WR_PORT_NUM-1:0][ADDR_WIDTH-INDEX_WIDTH-1:0] wr_tag;
    logic [WR_PORT_NUM-1:0]           [INDEX_WIDTH-1:0] wr_index;

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
            assign rd_tag[i]   = rd_addr[i][ADDR_WIDTH-1:INDEX_WIDTH];
            assign rd_index[i] = rd_addr[i][INDEX_WIDTH-1:0];

            assign rd_hit[i]      = cache_valid[rd_index[i]] & (cache_tag[rd_index[i]] == rd_tag[i]);
            assign rd_data_out[i] = cache_mem[rd_index[i]];
        end

        // Write output logic
        for(i=0;i<WR_PORT_NUM;i++)begin
            assign wr_tag[i]   = wr_addr[i][ADDR_WIDTH-1:INDEX_WIDTH];
            assign wr_index[i] = wr_addr[i][INDEX_WIDTH-1:0];
        end
        // First port
        assign wr_hit[0]        = cache_valid[wr_index[0]] & (cache_tag[wr_index[0]] == wr_tag[0]);
        assign evicted_data[0]  = cache_mem[wr_index[0]];
        assign evicted_addr[0]  = {cache_tag[wr_index[0]],wr_index[0]};
        assign evicted_dirty[0] = cache_dirty[wr_index[0]];
        assign evict[0]         = wr_en[0] & cache_valid[wr_index[0]] & (cache_tag[wr_index[0]] != wr_tag[0]);
        for(i=1;i<WR_PORT_NUM;i++)begin
            assign wr_hit[i]        = nxt_cache_valid[i-1][wr_index[i]] & (nxt_cache_tag[i-1][wr_index[i]] == wr_tag[i]);
            assign evicted_data[i]  = nxt_cache_mem[i-1][wr_index[i]];
            assign evicted_addr[i]  = {nxt_cache_tag[i-1][wr_index[i]],wr_index[i]};
            assign evicted_dirty[i] = nxt_cache_dirty[i-1][wr_index[i]];
            assign evict[i]         = wr_en[i] & nxt_cache_valid[i-1][wr_index[i]] & (nxt_cache_tag[i-1][wr_index[i]] != wr_tag[i]);
        end

        // nxt logic
        for(j=0;j<CACHE_LINE_NUM;j++)begin
            assign nxt_cache_mem[0][j]   = ((j == wr_index[0]) & wr_en[0]) ? wr_data_in[0]                : cache_mem[j];
            assign nxt_cache_tag[0][j]   = ((j == wr_index[0]) & wr_en[0]) ? wr_tag[0]                    : cache_tag[j];
            assign nxt_cache_valid[0][j] = ((j == wr_index[0]) & wr_en[0])                                | cache_valid[j];
            assign nxt_cache_dirty[0][j] = ((j == wr_index[0]) & wr_en[0]) ? (wr_hit[0] | wr_dirty_in[0]) : cache_dirty[j];
        end
        for(i=1;i<WR_PORT_NUM;i++)begin
            for(j=0;j<CACHE_LINE_NUM;j++)begin
                assign nxt_cache_mem[i][j]   = ((j == wr_index[i]) & wr_en[i]) ? wr_data_in[i]                : nxt_cache_mem[i-1][j];
                assign nxt_cache_tag[i][j]   = ((j == wr_index[i]) & wr_en[i]) ? wr_tag[i]                    : nxt_cache_tag[i-1][j];
                assign nxt_cache_valid[i][j] = ((j == wr_index[i]) & wr_en[i])                                | nxt_cache_valid[i-1][j];
                assign nxt_cache_dirty[i][j] = ((j == wr_index[i]) & wr_en[i]) ? (wr_hit[i] | wr_dirty_in[i]) : nxt_cache_dirty[i-1][j];
            end
        end
    endgenerate

    // Debug output
    logic [CACHE_LINE_NUM-1:0][INDEX_WIDTH-1:0] dbg_index;
    generate
        for(i=0;i<CACHE_LINE_NUM;i++)begin
            assign dbg_index[i] = i;
            assign dbg_cache_mem[i]   = cache_mem[i];
            assign dbg_cache_addr[i]  = {cache_tag[i],dbg_index[i]};
            assign dbg_cache_valid[i] = cache_valid[i];
            assign dbg_cache_dirty[i] = cache_dirty[i];
        end
    endgenerate
    

endmodule
