`include "verilog/sys_defs.svh"
module DcacheCore #(
    parameter RD_PORT_NUM    = 2,               // True read multi-port; No forwarding from Write port
    parameter WR_PORT_NUM    = 2,               // True write multi-port; Write port has priority & forwarding
    parameter ADDR_WIDTH     = 13,              // For Total addr=16; Cache line size= 8 bytes; Unit is Cache line
    parameter DATA_WIDTH     = 64,              // Cache line size
    parameter INDEX_WIDTH    = 5,               // Index width; Default Cache line number = 2 ** INDEX_WIDTH
    parameter CACHE_LINE_NUM = 2 ** INDEX_WIDTH
)(
    input  logic                        clk,
    input  logic                        rst,

    // Read Port
    input  logic [1:0][ADDR_WIDTH-1:0]  rd_addr,
    output logic [1:0]                  rd_hit,
    output logic [1:0][DATA_WIDTH-1:0]  rd_data_out,

    // Write port
    input  logic [1:0][ADDR_WIDTH-1:0]  wr_addr,
    input  logic [1:0][DATA_WIDTH-1:0]  wr_data_in,
    input  logic [1:0]                  wr_dirty_in,
    input  logic [1:0]                  wr_en,
    output logic [1:0]                  wr_hit,
    output logic [1:0][ADDR_WIDTH-1:0]  evicted_addr,
    output logic [1:0][DATA_WIDTH-1:0]  evicted_data,
    output logic [1:0]                  evicted_dirty,
    output logic [1:0]                  evict,

    // Debug output
    output logic [CACHE_LINE_NUM+3:0][DATA_WIDTH-1:0] dbg_cache_mem,
    output logic [CACHE_LINE_NUM+3:0][ADDR_WIDTH-1:0] dbg_cache_addr,
    output logic [CACHE_LINE_NUM+3:0]                 dbg_cache_valid,
    output logic [CACHE_LINE_NUM+3:0]                 dbg_cache_dirty
);

    genvar i;

    // Sub cache core ports
    // Read Port
    logic [1:0][1:0][ADDR_WIDTH-1:0]  sub_rd_addr;
    logic [1:0][1:0]                  sub_rd_hit;
    logic [1:0][1:0][DATA_WIDTH-1:0]  sub_rd_data_out;

    // Write port
    logic [1:0][1:0][ADDR_WIDTH-1:0]  sub_wr_addr;
    logic [1:0][1:0][DATA_WIDTH-1:0]  sub_wr_data_in;
    logic [1:0][1:0]                  sub_wr_dirty_in;
    logic [1:0][1:0]                  sub_wr_en;
    logic [1:0][1:0]                  sub_wr_hit;
    logic [1:0][1:0][ADDR_WIDTH-1:0]  sub_evicted_addr;
    logic [1:0][1:0][DATA_WIDTH-1:0]  sub_evicted_data;
    logic [1:0][1:0]                  sub_evicted_dirty;
    logic [1:0][1:0]                  sub_evict;

    logic [CACHE_LINE_NUM-1:0][DATA_WIDTH-1:0] core_dbg_cache_mem;
    logic [CACHE_LINE_NUM-1:0][ADDR_WIDTH-1:0] core_dbg_cache_addr;
    logic [CACHE_LINE_NUM-1:0]                 core_dbg_cache_valid;
    logic [CACHE_LINE_NUM-1:0]                 core_dbg_cache_dirty;

    logic [3:0][DATA_WIDTH-1:0]                victim_dbg_cache_mem;
    logic [3:0][ADDR_WIDTH-1:0]                victim_dbg_cache_addr;
    logic [3:0]                                victim_dbg_cache_valid;
    logic [3:0]                                victim_dbg_cache_dirty;

    // Sub cache core instantiation
    `DCACHE_CORE #(
        .RD_PORT_NUM    (2          ),      // True read multi-port; No forwarding from Write port
        .WR_PORT_NUM    (2          ),      // True write multi-port; Write port has priority & forwarding
        .ADDR_WIDTH     (ADDR_WIDTH ),      // For Total addr=16; Cache line size= 8 bytes; Unit is Cache line
        .DATA_WIDTH     (DATA_WIDTH ),      // Cache line size
        .INDEX_WIDTH    (INDEX_WIDTH)
    ) CacheCore (
        .clk            (clk                 ),
        .rst            (rst                 ),
        .rd_addr        (sub_rd_addr      [0]),
        .rd_hit         (sub_rd_hit       [0]),
        .rd_data_out    (sub_rd_data_out  [0]),
        .wr_addr        (sub_wr_addr      [0]),
        .wr_data_in     (sub_wr_data_in   [0]),
        .wr_dirty_in    (sub_wr_dirty_in  [0]),
        .wr_en          (sub_wr_en        [0]),
        .wr_hit         (sub_wr_hit       [0]),
        .evicted_addr   (sub_evicted_addr [0]),
        .evicted_data   (sub_evicted_data [0]),
        .evicted_dirty  (sub_evicted_dirty[0]),
        .evict          (sub_evict        [0]),
        .dbg_cache_mem   (core_dbg_cache_mem  ),
        .dbg_cache_addr  (core_dbg_cache_addr ),
        .dbg_cache_valid (core_dbg_cache_valid),
        .dbg_cache_dirty (core_dbg_cache_dirty)
    );

    VictimCache #(
        .RD_PORT_NUM    (2 ),              // True read multi-port; No forwarding from Write port
        .WR_PORT_NUM    (2 ),              // True write multi-port; Write port has priority & forwarding
        .ADDR_WIDTH     (13),              // For Total addr=16; Cache line size=8 bytes; Unit is Cache line
        .DATA_WIDTH     (64)               // Cache line size
    ) VictimCache (
        .clk            (clk                 ),
        .rst            (rst                 ),
        .rd_addr        (sub_rd_addr      [1]),
        .rd_hit         (sub_rd_hit       [1]),
        .rd_data_out    (sub_rd_data_out  [1]),
        .wr_addr        (sub_wr_addr      [1]),
        .wr_data_in     (sub_wr_data_in   [1]),
        .wr_dirty_in    (sub_wr_dirty_in  [1]),
        .wr_en          (sub_wr_en        [1]),
        .wr_hit         (sub_wr_hit       [1]),
        .evicted_addr   (sub_evicted_addr [1]),
        .evicted_data   (sub_evicted_data [1]),
        .evicted_dirty  (sub_evicted_dirty[1]),
        .evict          (sub_evict        [1]),
        .dbg_cache_mem   (victim_dbg_cache_mem  ),
        .dbg_cache_addr  (victim_dbg_cache_addr ),
        .dbg_cache_valid (victim_dbg_cache_valid),
        .dbg_cache_dirty (victim_dbg_cache_dirty)
    );

    // Sub cache core ports
    // Read port logic
    assign sub_rd_addr[0] = rd_addr;
    assign sub_rd_addr[1] = rd_addr;
    assign rd_hit      = sub_rd_hit[0] | sub_rd_hit[1];
    generate
        for(i=0;i<2;i++)begin
            assign rd_data_out[i] = sub_rd_hit[0][i] ? sub_rd_data_out[0][i] : sub_rd_data_out[1][i];
        end
    endgenerate

    // Write port logic
    assign sub_wr_addr[0]        = wr_addr;
    assign sub_wr_addr[1][0]     = wr_addr[0];
    assign sub_wr_addr[1][1]     = sub_evicted_addr[0][1];
    assign sub_wr_data_in[0]     = wr_data_in;
    assign sub_wr_data_in[1][0]  = wr_data_in[0];
    assign sub_wr_data_in[1][1]  = sub_evicted_data[0][1];
    assign sub_wr_dirty_in[0]    = wr_dirty_in;
    assign sub_wr_dirty_in[1][0] = wr_dirty_in[0];
    assign sub_wr_dirty_in[1][1] = sub_evicted_dirty[0][1];

    assign sub_wr_en[0][0] = wr_en[0] & sub_rd_hit[0][0];
    assign sub_wr_en[1][0] = wr_en[0] & sub_rd_hit[1][0];

    assign sub_wr_en[0][1] = wr_en[1];
    assign sub_wr_en[1][1] = sub_evict[0][1];

    assign wr_hit[0]        = sub_wr_hit[0][0] | sub_wr_hit[1][0];
    assign wr_hit[1]        = sub_wr_hit[0][0] | sub_wr_hit[1][0];

    assign evicted_addr[0]  = '0;
    assign evicted_data[0]  = '0;
    assign evicted_dirty[0] = '0;
    assign evict[0]         = 1'b0;
    
    assign evicted_addr[1]  = sub_evicted_addr[1][1];
    assign evicted_data[1]  = sub_evicted_data[1][1];
    assign evicted_dirty[1] = sub_evicted_dirty[1][1];
    assign evict[1]         = sub_evict[1][1];

    // Debug output
    generate
        for(i=0;i<CACHE_LINE_NUM;i++)begin
            assign dbg_cache_mem  [i] = core_dbg_cache_mem  [i];
            assign dbg_cache_addr [i] = core_dbg_cache_addr [i];
            assign dbg_cache_valid[i] = core_dbg_cache_valid[i];
            assign dbg_cache_dirty[i] = core_dbg_cache_dirty[i];
        end
        for(i=CACHE_LINE_NUM;i<CACHE_LINE_NUM+4;i++)begin
            assign dbg_cache_mem  [i] = victim_dbg_cache_mem  [i-CACHE_LINE_NUM];
            assign dbg_cache_addr [i] = victim_dbg_cache_addr [i-CACHE_LINE_NUM];
            assign dbg_cache_valid[i] = victim_dbg_cache_valid[i-CACHE_LINE_NUM];
            assign dbg_cache_dirty[i] = victim_dbg_cache_dirty[i-CACHE_LINE_NUM];
        end
    endgenerate
    
endmodule
