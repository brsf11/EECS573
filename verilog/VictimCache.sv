module VictimCache #(
    parameter RD_PORT_NUM    = 2,               // True read multi-port; No forwarding from Write port
    parameter WR_PORT_NUM    = 2,               // True write multi-port; Write port has priority & forwarding
    parameter ADDR_WIDTH     = 13,              // For Total addr=16; Cache line size=8 bytes; Unit is Cache line
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
    output logic [3:0][DATA_WIDTH-1:0]              dbg_cache_mem,
    output logic [3:0][ADDR_WIDTH-1:0]              dbg_cache_addr,
    output logic [3:0]                              dbg_cache_valid,
    output logic [3:0]                              dbg_cache_dirty
);

    genvar i;

    // Sub cache core ports
    // Read Port
    logic [3:0][RD_PORT_NUM-1:0][ADDR_WIDTH-1:0]  sub_rd_addr;
    logic [3:0][RD_PORT_NUM-1:0]                  sub_rd_hit;
    logic [3:0][RD_PORT_NUM-1:0][DATA_WIDTH-1:0]  sub_rd_data_out;

    // Write port
    logic [3:0][WR_PORT_NUM-1:0][ADDR_WIDTH-1:0]  sub_wr_addr;
    logic [3:0][WR_PORT_NUM-1:0][DATA_WIDTH-1:0]  sub_wr_data_in;
    logic [3:0][WR_PORT_NUM-1:0]                  sub_wr_dirty_in;
    logic [3:0][WR_PORT_NUM-1:0]                  sub_wr_en;
    logic [3:0][WR_PORT_NUM-1:0]                  sub_wr_hit;
    logic [3:0][WR_PORT_NUM-1:0][ADDR_WIDTH-1:0]  sub_evicted_addr;
    logic [3:0][WR_PORT_NUM-1:0][DATA_WIDTH-1:0]  sub_evicted_data;
    logic [3:0][WR_PORT_NUM-1:0]                  sub_evicted_dirty;
    logic [3:0][WR_PORT_NUM-1:0]                  sub_evict;

    logic [3:0][DATA_WIDTH-1:0] sub_dbg_cache_mem;
    logic [3:0][ADDR_WIDTH-1:0] sub_dbg_cache_addr;
    logic [3:0]                 sub_dbg_cache_valid;
    logic [3:0]                 sub_dbg_cache_dirty;

    // Sub cache core instantiation
    FACacheline #(
        .RD_PORT_NUM    (RD_PORT_NUM    ),      // True read multi-port; No forwarding from Write port
        .WR_PORT_NUM    (WR_PORT_NUM    ),      // True write multi-port; Write port has priority & forwarding
        .ADDR_WIDTH     (ADDR_WIDTH     ),      // For Total addr=16; Cache line size= 8 bytes; Unit is Cache line
        .DATA_WIDTH     (DATA_WIDTH     )       // Cache line size
    ) Cacheline_0 (
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
        .dbg_cache_mem   (sub_dbg_cache_mem  [0]),
        .dbg_cache_addr  (sub_dbg_cache_addr [0]),
        .dbg_cache_valid (sub_dbg_cache_valid[0]),
        .dbg_cache_dirty (sub_dbg_cache_dirty[0])
    );

    FACacheline #(
        .RD_PORT_NUM    (RD_PORT_NUM    ),      // True read multi-port; No forwarding from Write port
        .WR_PORT_NUM    (WR_PORT_NUM    ),      // True write multi-port; Write port has priority & forwarding
        .ADDR_WIDTH     (ADDR_WIDTH     ),      // For Total addr=16; Cache line size= 8 bytes; Unit is Cache line
        .DATA_WIDTH     (DATA_WIDTH     )       // Cache line size
    ) Cacheline_1 (
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
        .dbg_cache_mem   (sub_dbg_cache_mem  [1]),
        .dbg_cache_addr  (sub_dbg_cache_addr [1]),
        .dbg_cache_valid (sub_dbg_cache_valid[1]),
        .dbg_cache_dirty (sub_dbg_cache_dirty[1])
    );

    FACacheline #(
        .RD_PORT_NUM    (RD_PORT_NUM    ),      // True read multi-port; No forwarding from Write port
        .WR_PORT_NUM    (WR_PORT_NUM    ),      // True write multi-port; Write port has priority & forwarding
        .ADDR_WIDTH     (ADDR_WIDTH     ),      // For Total addr=16; Cache line size= 8 bytes; Unit is Cache line
        .DATA_WIDTH     (DATA_WIDTH     )       // Cache line size
    ) Cacheline_2 (
        .clk            (clk                 ),
        .rst            (rst                 ),
        .rd_addr        (sub_rd_addr      [2]),
        .rd_hit         (sub_rd_hit       [2]),
        .rd_data_out    (sub_rd_data_out  [2]),
        .wr_addr        (sub_wr_addr      [2]),
        .wr_data_in     (sub_wr_data_in   [2]),
        .wr_dirty_in    (sub_wr_dirty_in  [2]),
        .wr_en          (sub_wr_en        [2]),
        .wr_hit         (sub_wr_hit       [2]),
        .evicted_addr   (sub_evicted_addr [2]),
        .evicted_data   (sub_evicted_data [2]),
        .evicted_dirty  (sub_evicted_dirty[2]),
        .evict          (sub_evict        [2]),
        .dbg_cache_mem   (sub_dbg_cache_mem  [2]),
        .dbg_cache_addr  (sub_dbg_cache_addr [2]),
        .dbg_cache_valid (sub_dbg_cache_valid[2]),
        .dbg_cache_dirty (sub_dbg_cache_dirty[2])
    );

    FACacheline #(
        .RD_PORT_NUM    (RD_PORT_NUM    ),      // True read multi-port; No forwarding from Write port
        .WR_PORT_NUM    (WR_PORT_NUM    ),      // True write multi-port; Write port has priority & forwarding
        .ADDR_WIDTH     (ADDR_WIDTH     ),      // For Total addr=16; Cache line size= 8 bytes; Unit is Cache line
        .DATA_WIDTH     (DATA_WIDTH     )       // Cache line size
    ) Cacheline_3 (
        .clk            (clk                 ),
        .rst            (rst                 ),
        .rd_addr        (sub_rd_addr      [3]),
        .rd_hit         (sub_rd_hit       [3]),
        .rd_data_out    (sub_rd_data_out  [3]),
        .wr_addr        (sub_wr_addr      [3]),
        .wr_data_in     (sub_wr_data_in   [3]),
        .wr_dirty_in    (sub_wr_dirty_in  [3]),
        .wr_en          (sub_wr_en        [3]),
        .wr_hit         (sub_wr_hit       [3]),
        .evicted_addr   (sub_evicted_addr [3]),
        .evicted_data   (sub_evicted_data [3]),
        .evicted_dirty  (sub_evicted_dirty[3]),
        .evict          (sub_evict        [3]),
        .dbg_cache_mem   (sub_dbg_cache_mem  [3]),
        .dbg_cache_addr  (sub_dbg_cache_addr [3]),
        .dbg_cache_valid (sub_dbg_cache_valid[3]),
        .dbg_cache_dirty (sub_dbg_cache_dirty[3])
    );

    // Read port logic
    assign rd_hit = sub_rd_hit[0] | sub_rd_hit[1] | sub_rd_hit[2] | sub_rd_hit[3];
    generate
        for(i=0;i<4;i++)begin
            assign sub_rd_addr[i] = rd_addr;
        end
        for(i=0;i<RD_PORT_NUM;i++)begin
            assign rd_data_out[i] = (sub_rd_hit[0][i] ? sub_rd_data_out[0][i] : '0) |
                                    (sub_rd_hit[1][i] ? sub_rd_data_out[1][i] : '0) |
                                    (sub_rd_hit[2][i] ? sub_rd_data_out[2][i] : '0) |
                                    (sub_rd_hit[3][i] ? sub_rd_data_out[3][i] : '0);
        end
    endgenerate

    // LRU logic
    logic                  [2:0] lru;
    logic [RD_PORT_NUM-1:0][2:0] nxt_rd_lru;
    logic [WR_PORT_NUM-1:0][2:0] nxt_wr_lru;
    logic [WR_PORT_NUM-1:0][1:0] wr_lru_idx;
    logic [RD_PORT_NUM-1:0][1:0] rd_line_hit;
    logic [WR_PORT_NUM-1:0][1:0] hit_wr_line_hit;
    logic [WR_PORT_NUM-1:0][1:0] wr_line_hit;
    logic [WR_PORT_NUM-1:0][1:0] wr_idx;

    always_ff @(posedge clk)begin
        if(rst)begin
            lru <= '0;
        end
        else begin
            lru <= nxt_wr_lru[WR_PORT_NUM-1];
        end
    end

    // lru logic generate block
    generate
        // rd_line_hit logic
        for(i=0;i<RD_PORT_NUM;i++)begin
            onehot2bin #(
                .WIDTH_INPUT  (4),
                .WIDTH_OUTPUT (2)  // 2**WIDTH_OUTPUT >= WIDTH_INPUT
            ) rd_line_hit_o2b (
                .onehot       ({sub_rd_hit[3][i],sub_rd_hit[2][i],sub_rd_hit[1][i],sub_rd_hit[0][i]}),
                .bin          (rd_line_hit[i])
            );
        end

        // wr_line_hit logic
        for(i=0;i<WR_PORT_NUM;i++)begin
            onehot2bin #(
                .WIDTH_INPUT  (4),
                .WIDTH_OUTPUT (2)  // 2**WIDTH_OUTPUT >= WIDTH_INPUT
            ) rd_line_hit_o2b (
                .onehot       ({sub_wr_hit[3][i],sub_wr_hit[2][i],sub_wr_hit[1][i],sub_wr_hit[0][i]}),
                .bin          (hit_wr_line_hit[i])
            );
        end

        for(i=0;i<WR_PORT_NUM;i++)begin
            assign wr_line_hit[i] = wr_hit[i] ? hit_wr_line_hit[i] : wr_lru_idx[i];
        end

        for(i=0;i<WR_PORT_NUM;i++)begin
            assign wr_idx[i] = wr_en[i] ? wr_line_hit[i] : 0;
        end
        
        // nxt_rd_lru update logic
        PLRU4 rd_lru_0(
            .input_lru  (lru),
            .line_hit   (rd_line_hit[0]),
            .hit        (rd_hit[0]),
            .output_lru (nxt_rd_lru[0])
        );
        for(i=1;i<RD_PORT_NUM;i++)begin
            PLRU4 rd_lru_1(
                .input_lru  (nxt_rd_lru[i-1]),
                .line_hit   (rd_line_hit[i]),
                .hit        (rd_hit[i]),
                .output_lru (nxt_rd_lru[i])
            );
        end

        // nxt_wr_lru update logic
        PLRU4 wr_lru_0(
            .input_lru  (nxt_rd_lru[RD_PORT_NUM-1]),
            .line_hit   (wr_line_hit[0]),
            .hit        (wr_en[0]),
            .output_lru (nxt_wr_lru[0])
        );
        for(i=1;i<WR_PORT_NUM;i++)begin
            PLRU4 wr_lru_0(
                .input_lru  (nxt_wr_lru[i-1]),
                .line_hit   (wr_line_hit[i]),
                .hit        (wr_en[i]),
                .output_lru (nxt_wr_lru[i])
            );
        end

        // lru 2 idx
        lru2idx4 lru2idx_0(
            .lru (nxt_rd_lru[RD_PORT_NUM-1]),
            .idx (wr_lru_idx[0])
        );
        for(i=1;i<WR_PORT_NUM;i++)begin
            lru2idx4 lru2idx_0(
                .lru (nxt_wr_lru[i-1]),
                .idx (wr_lru_idx[i])
            );
        end
    endgenerate

    // Write port logic
    generate
        for(i=0;i<4;i++)begin
            assign sub_wr_addr[i]     = wr_addr;
            assign sub_wr_data_in[i]  = wr_data_in;
            assign sub_wr_dirty_in[i] = wr_dirty_in;
        end

        for(i=0;i<WR_PORT_NUM;i++)begin
            assign sub_wr_en[0][i] = (wr_idx[i] == 2'b00) ? wr_en[i] : 1'b0;
            assign sub_wr_en[1][i] = (wr_idx[i] == 2'b01) ? wr_en[i] : 1'b0;
            assign sub_wr_en[2][i] = (wr_idx[i] == 2'b10) ? wr_en[i] : 1'b0;
            assign sub_wr_en[3][i] = (wr_idx[i] == 2'b11) ? wr_en[i] : 1'b0;

            assign wr_hit[i]        = sub_wr_hit[0][i] | sub_wr_hit[1][i] | sub_wr_hit[2][i] | sub_wr_hit[3][i];
            assign evicted_addr[i]  = sub_evicted_addr[wr_idx[i]][i];
            assign evicted_data[i]  = sub_evicted_data[wr_idx[i]][i];
            assign evicted_dirty[i] = sub_evicted_dirty[wr_idx[i]][i];
            assign evict[i]         = sub_evict[wr_idx[i]][i];
        end
    endgenerate

    assign dbg_cache_mem  [0] =  sub_dbg_cache_mem  [0];
    assign dbg_cache_addr [0] =  sub_dbg_cache_addr [0];
    assign dbg_cache_valid[0] =  sub_dbg_cache_valid[0];
    assign dbg_cache_dirty[0] =  sub_dbg_cache_dirty[0];
    assign dbg_cache_mem  [1] =  sub_dbg_cache_mem  [1];
    assign dbg_cache_addr [1] =  sub_dbg_cache_addr [1];
    assign dbg_cache_valid[1] =  sub_dbg_cache_valid[1];
    assign dbg_cache_dirty[1] =  sub_dbg_cache_dirty[1];
    assign dbg_cache_mem  [2] =  sub_dbg_cache_mem  [2];
    assign dbg_cache_addr [2] =  sub_dbg_cache_addr [2];
    assign dbg_cache_valid[2] =  sub_dbg_cache_valid[2];
    assign dbg_cache_dirty[2] =  sub_dbg_cache_dirty[2];
    assign dbg_cache_mem  [3] =  sub_dbg_cache_mem  [3];
    assign dbg_cache_addr [3] =  sub_dbg_cache_addr [3];
    assign dbg_cache_valid[3] =  sub_dbg_cache_valid[3];
    assign dbg_cache_dirty[3] =  sub_dbg_cache_dirty[3];

endmodule
