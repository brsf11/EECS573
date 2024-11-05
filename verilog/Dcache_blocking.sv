`include "verilog/sys_defs.svh"

module Dcache_blocking(
    input  logic        clk,
    input  logic        rst,

    // Load ports
    output logic [3:0]  load_cache2proc_response_o,
    output logic [31:0] load_cache2proc_data_o,
    output logic [3:0]  load_cache2proc_tag_o,
    input  logic        load_proc2cache_load_i,
    input  logic [31:0] load_proc2cache_addr_i,

    // Store ports
    output logic        store_cache2proc_response_o,
    input  logic        store_proc2cache_store_i,
    input  logic [31:0] store_proc2cache_addr_i,
    input  logic [31:0] store_proc2cache_data_i,
    input  MEM_SIZE     store_proc2cache_size_i,

    // Memory port
    input  logic [3:0]  mem2cache_response_i,
    input  logic [63:0] mem2cache_data_i,
    input  logic [3:0]  mem2cache_tag_i,
    output logic [1:0]  cache2mem_command_o,
    output logic [31:0] cache2mem_addr_o,
    output logic [63:0] cache2mem_data_o,

    // Debug output
    output logic [32+3:0][64-1:0] dbg_cache_mem,
    output logic [32+3:0][13-1:0] dbg_cache_addr,
    output logic [32+3:0]         dbg_cache_valid,
    output logic [32+3:0]         dbg_cache_dirty
);

    // Cache core ports
    // Read Port
    logic [1:0][12:0] cache_core_rd_addr;
    logic [1:0]       cache_core_rd_hit;
    logic [1:0][63:0] cache_core_rd_data_out;

    // Write port
    logic [1:0][12:0] cache_core_wr_addr;
    logic [1:0][63:0] cache_core_wr_data_in;
    logic [1:0]       cache_core_wr_en;
    logic [1:0]       cache_core_wr_hit;
    logic [1:0][12:0] cache_core_evicted_addr;
    logic [1:0][63:0] cache_core_evicted_data;
    logic [1:0]       cache_core_evicted_dirty;
    logic [1:0]       cache_core_evict;

    // Miss status
    logic        outstanding_miss;
    logic [12:0] outstanding_miss_addr;
    logic [3:0]  outstanding_miss_tag;
    logic [1:0]  real_miss;
    logic        curr_miss;
    logic [12:0] curr_miss_addr;
    logic        data_back;
    logic        store_evicted;
    logic [63:0] reg_evicted_data;
    logic [12:0] reg_evicted_addr;
    logic        load_miss;

    // Cache core instantiation
    `ifndef NO_VICTIM
    `DCACHE #(
        .RD_PORT_NUM    (2                       ),      // True read multi-port; No forwarding from Write port
        .WR_PORT_NUM    (2                       ),      // True write multi-port; Write port has priority & forwarding
        .ADDR_WIDTH     (13                      ),      // For Total addr=16; Cache line size= 8 bytes; Unit is Cache line
        .DATA_WIDTH     (64                      ),      // Cache line size
        .INDEX_WIDTH    (5                       )
    ) CacheCore (
        .clk            (clk                     ),
        .rst            (rst                     ),
        .rd_addr        (cache_core_rd_addr      ),
        .rd_hit         (cache_core_rd_hit       ),
        .rd_data_out    (cache_core_rd_data_out  ),
        .wr_addr        (cache_core_wr_addr      ),
        .wr_data_in     (cache_core_wr_data_in   ),
        .wr_dirty_in    ('0                      ),
        .wr_en          (cache_core_wr_en        ),
        .wr_hit         (cache_core_wr_hit       ),
        .evicted_addr   (cache_core_evicted_addr ),
        .evicted_data   (cache_core_evicted_data ),
        .evicted_dirty  (cache_core_evicted_dirty),
        .evict          (cache_core_evict        ),
        .dbg_cache_mem   (dbg_cache_mem  ),
        .dbg_cache_addr  (dbg_cache_addr ),
        .dbg_cache_valid (dbg_cache_valid),
        .dbg_cache_dirty (dbg_cache_dirty)
    );
    `endif

    `ifdef NO_VICTIM
    logic [31:0][64-1:0] cache_dbg_cache_mem;
    logic [31:0][13-1:0] cache_dbg_cache_addr;
    logic [31:0]         cache_dbg_cache_valid;
    logic [31:0]         cache_dbg_cache_dirty;
    `DCACHE #(
        .RD_PORT_NUM    (2                       ),      // True read multi-port; No forwarding from Write port
        .WR_PORT_NUM    (2                       ),      // True write multi-port; Write port has priority & forwarding
        .ADDR_WIDTH     (13                      ),      // For Total addr=16; Cache line size= 8 bytes; Unit is Cache line
        .DATA_WIDTH     (64                      ),      // Cache line size
        .INDEX_WIDTH    (5                       )
    ) CacheCore (
        .clk            (clk                     ),
        .rst            (rst                     ),
        .rd_addr        (cache_core_rd_addr      ),
        .rd_hit         (cache_core_rd_hit       ),
        .rd_data_out    (cache_core_rd_data_out  ),
        .wr_addr        (cache_core_wr_addr      ),
        .wr_data_in     (cache_core_wr_data_in   ),
        .wr_dirty_in    ('0                      ),
        .wr_en          (cache_core_wr_en        ),
        .wr_hit         (cache_core_wr_hit       ),
        .evicted_addr   (cache_core_evicted_addr ),
        .evicted_data   (cache_core_evicted_data ),
        .evicted_dirty  (cache_core_evicted_dirty),
        .evict          (cache_core_evict        ),
        .dbg_cache_mem   (cache_dbg_cache_mem  ),
        .dbg_cache_addr  (cache_dbg_cache_addr ),
        .dbg_cache_valid (cache_dbg_cache_valid),
        .dbg_cache_dirty (cache_dbg_cache_dirty)
    );
        genvar i;
        generate
            for(i=0;i<32;i++)begin
                assign dbg_cache_mem  [i] = cache_dbg_cache_mem  [i];
                assign dbg_cache_addr [i] = cache_dbg_cache_addr [i];
                assign dbg_cache_valid[i] = cache_dbg_cache_valid[i];
                assign dbg_cache_dirty[i] = cache_dbg_cache_dirty[i];
            end
            for(i=32;i<32+4;i++)begin
                assign dbg_cache_mem  [i] = '0;
                assign dbg_cache_addr [i] = '0;
                assign dbg_cache_valid[i] = '0;
                assign dbg_cache_dirty[i] = '0;
            end
        endgenerate
    `endif

    // Cahce core input logic
    // Read port
    assign cache_core_rd_addr[0] = store_proc2cache_addr_i[15:3];
    assign cache_core_rd_addr[1] = load_proc2cache_addr_i[15:3];
    // Write port
    // First port for store
    assign cache_core_wr_addr[0]    = store_proc2cache_addr_i[15:3];
    always_comb begin
        cache_core_wr_data_in[0] = cache_core_rd_data_out[0];
        if(store_proc2cache_addr_i[2] == 1'b0)begin
            case(store_proc2cache_size_i)
                BYTE:begin
                    case(store_proc2cache_addr_i[1:0])
                        2'b00:begin
                            cache_core_wr_data_in[0][7:0]   = store_proc2cache_data_i[7:0];
                        end
                        2'b01:begin
                            cache_core_wr_data_in[0][15:8]  = store_proc2cache_data_i[7:0];
                        end
                        2'b10:begin
                            cache_core_wr_data_in[0][23:16] = store_proc2cache_data_i[7:0];
                        end
                        2'b11:begin
                            cache_core_wr_data_in[0][31:24] = store_proc2cache_data_i[7:0];
                        end
                        default:begin
                            cache_core_wr_data_in[0][7:0]   = store_proc2cache_data_i[7:0];
                        end
                    endcase
                end
                HALF:begin
                    if(store_proc2cache_addr_i[1] == 1'b0)begin
                        cache_core_wr_data_in[0][15:0]  = store_proc2cache_data_i[15:0];
                    end
                    else begin
                        cache_core_wr_data_in[0][31:16] = store_proc2cache_data_i[15:0];
                    end
                end
                WORD:begin
                    cache_core_wr_data_in[0][31:0]  = store_proc2cache_data_i;
                end
                default:begin
                    cache_core_wr_data_in[0][31:0]  = store_proc2cache_data_i;
                end
            endcase
        end
        else begin
            case(store_proc2cache_size_i)
                BYTE:begin
                    case(store_proc2cache_addr_i[1:0])
                        2'b00:begin
                            cache_core_wr_data_in[0][7+32:0+32]   = store_proc2cache_data_i[7:0];
                        end
                        2'b01:begin
                            cache_core_wr_data_in[0][15+32:8+32]  = store_proc2cache_data_i[7:0];
                        end
                        2'b10:begin
                            cache_core_wr_data_in[0][23+32:16+32] = store_proc2cache_data_i[7:0];
                        end
                        2'b11:begin
                            cache_core_wr_data_in[0][31+32:24+32] = store_proc2cache_data_i[7:0];
                        end
                        default:begin
                            cache_core_wr_data_in[0][7+32:0+32]   = store_proc2cache_data_i[7:0];
                        end
                    endcase
                end
                HALF:begin
                    if(store_proc2cache_addr_i[1] == 1'b0)begin
                        cache_core_wr_data_in[0][15+32:0+32]  = store_proc2cache_data_i[15:0];
                    end
                    else begin
                        cache_core_wr_data_in[0][31+32:16+32] = store_proc2cache_data_i[15:0];
                    end
                end
                WORD:begin
                    cache_core_wr_data_in[0][31+32:0+32]  = store_proc2cache_data_i;
                end
                default:begin
                    cache_core_wr_data_in[0][31+32:0+32]  = store_proc2cache_data_i;
                end
            endcase
        end
    end
    assign cache_core_wr_en[0]      = store_proc2cache_store_i & cache_core_rd_hit[0];
    // Second port for mem back
    assign cache_core_wr_addr[1]    = outstanding_miss_addr;
    assign cache_core_wr_data_in[1] = mem2cache_data_i;
    assign cache_core_wr_en[1]      = data_back;

    // Curr miss logic
    assign real_miss      = {load_proc2cache_load_i & (~cache_core_rd_hit[1]),store_proc2cache_store_i & (~cache_core_rd_hit[0])};
    assign curr_miss      = |real_miss;
    assign curr_miss_addr = real_miss[0] ? store_proc2cache_addr_i[15:3] : load_proc2cache_addr_i[15:3];
    
    // Data back logic
    assign data_back = outstanding_miss & (mem2cache_tag_i == outstanding_miss_tag);
    
    // Evict logic
    always_ff @(posedge clk)begin
        if(rst)begin
            store_evicted    <= 1'b0;
            reg_evicted_addr <= '0;
            reg_evicted_data <= '0;
        end
        else begin
            store_evicted    <= cache_core_evict[1] & cache_core_evicted_dirty[1];
            reg_evicted_addr <= cache_core_evicted_addr[1];
            reg_evicted_data <= cache_core_evicted_data[1];
        end
    end
    assign load_miss     = (~store_evicted) & curr_miss & (~outstanding_miss);

    // Outstanding miss logic
    always_ff @(posedge clk) begin
        if(rst)begin
            outstanding_miss      <= 1'b0;
            outstanding_miss_addr <= '0;
            outstanding_miss_tag  <= '0;
        end
        else begin
            if(outstanding_miss)begin
                if(data_back)begin
                    // if(load_miss)begin
                    //     outstanding_miss      <= 1'b1;
                    //     outstanding_miss_addr <= curr_miss_addr;
                    //     outstanding_miss_tag  <= mem2cache_response_i;
                    // end
                    // else begin
                        outstanding_miss <= 1'b0;
                    // end
                end
                // else if(load_miss)begin
                //     outstanding_miss      <= 1'b1;
                //     outstanding_miss_addr <= curr_miss_addr;
                //     outstanding_miss_tag  <= mem2cache_response_i;
                // end
            end
            else begin
                if(load_miss & (mem2cache_response_i != 0))begin
                    outstanding_miss      <= 1'b1;
                    outstanding_miss_addr <= curr_miss_addr;
                    outstanding_miss_tag  <= mem2cache_response_i;
                end
            end
        end
    end

    // Output logic
    // Load port
    assign load_cache2proc_response_o  = real_miss[1] ? 4'b0 : 4'b1111; // Arbitrary value for tag
    assign load_cache2proc_data_o      = load_proc2cache_addr_i[2] ? cache_core_rd_data_out[1][63:32] : cache_core_rd_data_out[1][31:0];
    assign load_cache2proc_tag_o       = load_cache2proc_response_o;
    // Store port
    assign store_cache2proc_response_o = ~real_miss[0];
    // Mem port
    assign cache2mem_command_o = store_evicted ? BUS_STORE : (load_miss ? BUS_LOAD : BUS_NONE);
    assign cache2mem_addr_o    = store_evicted ? {16'b0,reg_evicted_addr,3'b0} : {16'b0,curr_miss_addr,3'b0};
    assign cache2mem_data_o    = reg_evicted_data;


endmodule
