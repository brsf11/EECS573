
`include "verilog/sys_defs.svh"
module icache (
    input logic                           clk,
    input logic                           rst,

    input  logic                   [31:0] instr_fetch_pc_i,
    output logic [`FETCH_WIDTH-1:0][31:0] instr_o,
    output logic [`FETCH_WIDTH-1:0]       instr_vld_o,

    // Mem bus
    input  logic                   [3:0]  mem2cache_response,
    input  logic                   [63:0] mem2cache_data,
    input  logic                   [3:0]  mem2cache_tag,
    output logic                   [1:0]  cache2mem_command,
    output logic                   [31:0] cache2mem_addr
);

    localparam INDEX = $clog2(`FETCH_WIDTH >> 1);

    genvar i;

    // Submodule ports
    // Cache Core
    // Read Port
    logic [(2**INDEX)-1:0][12-INDEX:0]      cache_core_rd_addr;
    logic [(2**INDEX)-1:0]                  cache_core_rd_hit;
    logic [(2**INDEX)-1:0][63:0]            cache_core_rd_data_out;

    // Write port
    logic [(2**INDEX)-1:0][1:0][12-INDEX:0] cache_core_wr_addr;
    logic [(2**INDEX)-1:0][1:0][63:0]       cache_core_wr_data_in;
    logic [(2**INDEX)-1:0][1:0]             cache_core_wr_en;

    // Stream Buffer
    // Load ports
    logic                 [15:0] prefetch_load_addr; // ignore [2:0]
    logic                        prefetch_load;
    logic [(2**INDEX)-1:0]       prefetch_load_vld;
    logic [(2**INDEX)-1:0][63:0] prefetch_load_data;
    // Allocate ports
    logic                 [15:0] prefetch_allocate_addr; // ignore [2:0]
    logic                        prefetch_allocate;
    // MEM ports
    logic [3:0]                  prefetch_mem2buf_response;
    logic [63:0]                 prefetch_mem2buf_data;
    logic [3:0]                  prefetch_mem2buf_tag;
    logic [1:0]                  prefetch_buf2mem_command;
    logic [31:0]                 prefetch_buf2mem_addr;

    IcacheCore #(
        .INT_IDX     (INDEX) // Interleavin Index
    )cacheCore(
        .clk         (clk                   ),
        .rst         (rst                   ),
        .rd_addr     (cache_core_rd_addr    ),
        .rd_hit      (cache_core_rd_hit     ),
        .rd_data_out (cache_core_rd_data_out),
        .wr_addr     (cache_core_wr_addr    ),
        .wr_data_in  (cache_core_wr_data_in ),
        .wr_en       (cache_core_wr_en      )
    );

    StreamBuf #(
        .DEPTH              (`PREFETCH_DEPTH),
        .WIDTH              (2**INDEX       )
    )prefetch(
        .clk                (clk                        ),
        .rst                (rst                        ),
        .load_addr          (prefetch_load_addr         ), // ignore [2:0]
        .load               (prefetch_load              ),
        .load_vld           (prefetch_load_vld          ),
        .load_data          (prefetch_load_data         ),
        .allocate_addr      (prefetch_allocate_addr     ), // ignore [2:0]
        .allocate           (prefetch_allocate          ),
        .mem2buf_response_i (prefetch_mem2buf_response  ),
        .mem2buf_data_i     (prefetch_mem2buf_data      ),
        .mem2buf_tag_i      (prefetch_mem2buf_tag       ),
        .buf2mem_command_o  (prefetch_buf2mem_command   ),
        .buf2mem_addr_o     (prefetch_buf2mem_addr      )
    );

    // Internal signal
    logic [(2**INDEX)-1:0][15:0]       aligned_addr;
    logic [(2**INDEX)-1:0][12-INDEX:0] aligned_cache_core_addr;
    logic [(2**INDEX)-1:0]             aligned_hit;
    logic [(2**INDEX)-1:0]             cache_core_aligned_hit;

    logic                        prefetch_sel;
    logic                        all_miss;

    // Input request signal
    logic [15:0]                 prev_addr;
    logic                        addr_change;
    logic                        unanswered_miss;
    logic                        read_req;

    // Data back signal
    logic [3:0]                  outstanding_tag;
    logic [15:0]                 outstanding_addr;
    logic                        outstanding_miss;
    logic                        data_back;
    logic                        load_miss_rdy;
    logic                        load_miss_vld;
    logic                        load_miss;

    // Prefetch to cache core signal
    logic [(2**INDEX)-1:0][63:0] steer_prefetch_load_data;
    logic [(2**INDEX)-1:0]       steer_prefetch_load_vld;

    // Cache Core MEM bus
    logic [3:0]  core_mem2cache_response;
    logic [63:0] core_mem2cache_data;
    logic [3:0]  core_mem2cache_tag;
    logic [1:0]  core_cache2mem_command;
    logic [31:0] core_cache2mem_addr;

    // For output
    logic [(2**INDEX)-1:0][63:0]   unsteer_cache_core_data;
    logic [`FETCH_WIDTH-1:0][31:0] split_load_data;
    logic [(2**INDEX)-1:0]         combined_hit;
    logic [`FETCH_WIDTH-1:0]       split_combined_hit;

    // Submodule input logic
    // Cache Core
    // Read Port
    steer #(
        .INDEX (INDEX),
        .WIDTH (13-INDEX)
    )cache_core_addr_steer(
        .data_in   (aligned_cache_core_addr),
        .order     (instr_fetch_pc_i[2+INDEX:3]),
        .data_out  (cache_core_rd_addr)
    );

    // Write port
    generate
        for(i=0;i<2**INDEX;i++)begin
            assign cache_core_wr_addr[i][0] = cache_core_rd_addr[i];
            assign cache_core_wr_addr[i][1] = outstanding_addr[15:3+INDEX];

            assign cache_core_wr_data_in[i][0] = steer_prefetch_load_data[i];
            assign cache_core_wr_data_in[i][1] = core_mem2cache_data;

            assign cache_core_wr_en[i][0] = steer_prefetch_load_vld[i] & prefetch_load & prefetch_sel;
            assign cache_core_wr_en[i][1] = data_back & (i == outstanding_addr[2+INDEX:3]);
        end
    endgenerate

    // Stream Buffer
    // Load ports
    assign prefetch_load_addr = aligned_addr[0];
    assign prefetch_load      = prefetch_sel & read_req;
    // Allocate ports
    assign prefetch_allocate_addr = aligned_addr[0] + 4'b1000;
    assign prefetch_allocate      = all_miss & addr_change;
    // MEM ports
    assign prefetch_mem2buf_response = (core_cache2mem_command == BUS_NONE) ? mem2cache_response : '0;
    assign prefetch_mem2buf_data     = mem2cache_data;
    assign prefetch_mem2buf_tag      = mem2cache_tag;

    // Internal logic
    generate
        assign aligned_addr[0] = {instr_fetch_pc_i[15:3],3'b0};
        for(i=1;i<2**INDEX;i++)begin
            assign aligned_addr[i]            = aligned_addr[i-1] + 4'b1000;
        end

        for(i=0;i<2**INDEX;i++)begin
            assign aligned_cache_core_addr[i] = aligned_addr[i][15:3+INDEX];
        end

        assign aligned_hit[0] = cache_core_aligned_hit[0];
        for(i=1;i<2**INDEX;i++)begin
            assign aligned_hit[i] = aligned_hit[i-1] & cache_core_aligned_hit[i];
        end

        unsteer #(
            .INDEX (INDEX),
            .WIDTH (1)
        )hit_unsteer(
            .data_in  (cache_core_rd_hit),
            .order    (instr_fetch_pc_i[2+INDEX:3]),
            .data_out (cache_core_aligned_hit)
        );
    endgenerate

    assign prefetch_sel = |((~(prefetch_load_vld & aligned_hit)) & prefetch_load_vld);

    assign all_miss = ~(|(prefetch_load_vld | aligned_hit));

    // Input request signal
    always_ff @(posedge clk)begin
        if(rst)begin
            prev_addr <= -1;
        end
        else begin
            prev_addr <= instr_fetch_pc_i;
        end
    end

    assign addr_change = prev_addr != instr_fetch_pc_i;

    always_ff @(posedge clk)begin
        if(rst)begin
            unanswered_miss <= 1'b0;
        end
        else begin
            unanswered_miss <= read_req & (~(|instr_vld_o));
        end
    end

    assign read_req = unanswered_miss | addr_change;

    // Data back signal
    always_ff @(posedge clk)begin
        if(rst)begin
            outstanding_tag  <= '0;
            outstanding_addr <= '0;
            outstanding_miss <= 1'b0;
        end
        else begin
            if(load_miss)begin
                outstanding_tag  <= core_mem2cache_response;
                outstanding_addr <= aligned_addr[0];
                outstanding_miss <= 1'b1;
            end
            else if(data_back) begin
                outstanding_miss <= 1'b0;
            end
        end
    end
    assign data_back     = outstanding_miss & (core_mem2cache_tag == outstanding_tag);
    assign load_miss_rdy = |core_mem2cache_response;
    assign load_miss_vld = read_req & all_miss & (addr_change | (~outstanding_miss));
    assign load_miss     = load_miss_rdy & load_miss_vld;

    // Prefetch to cache core signal

    steer #(
        .INDEX (INDEX),
        .WIDTH (64)
    )prefetch_load_data_steer(
        .data_in  (prefetch_load_data),
        .order    (instr_fetch_pc_i[2+INDEX:3]),
        .data_out (steer_prefetch_load_data)
    );

    steer #(
        .INDEX (INDEX),
        .WIDTH (1)
    )prefetch_load_vld_steer(
        .data_in  (prefetch_load_vld),
        .order    (instr_fetch_pc_i[2+INDEX:3]),
        .data_out (steer_prefetch_load_vld)
    );


    // Cache Core MEM bus
    assign core_mem2cache_response = mem2cache_response;
    assign core_mem2cache_data     = mem2cache_data;
    assign core_mem2cache_tag      = mem2cache_tag;
    assign core_cache2mem_command  = load_miss_vld ? BUS_LOAD : BUS_NONE;
    assign core_cache2mem_addr     = {16'b0,aligned_addr[0]};

    // For output
    unsteer #(
        .INDEX (INDEX),
        .WIDTH (64)
    )cache_core_data_unsteer(
        .data_in  (cache_core_rd_data_out),
        .order    (instr_fetch_pc_i[2+INDEX:3]),
        .data_out (unsteer_cache_core_data)
    );

    assign split_load_data = prefetch_sel ? prefetch_load_data : unsteer_cache_core_data;
    assign combined_hit    = prefetch_load_vld | aligned_hit;
    generate
        for(i=0;i<2**INDEX;i++)begin
            assign split_combined_hit[ 2*i     ] = combined_hit[i];
            assign split_combined_hit[(2*i) + 1] = combined_hit[i];
        end
    endgenerate

    // Output logic
    always_comb begin
        if(instr_fetch_pc_i[2])begin
            instr_o = {split_load_data[0],split_load_data[`FETCH_WIDTH-1:1]};
        end
        else begin
            instr_o = split_load_data;
        end
    end
    generate
        always_comb begin
            if(instr_fetch_pc_i[2])begin
                instr_vld_o = {1'b0,split_combined_hit[`FETCH_WIDTH-1:1]};
            end
            else begin
                instr_vld_o = split_combined_hit;
            end
        end
    endgenerate

    assign cache2mem_command = (core_cache2mem_command == BUS_NONE) ? prefetch_buf2mem_command : core_cache2mem_command;
    assign cache2mem_addr    = (core_cache2mem_command == BUS_NONE) ? prefetch_buf2mem_addr    : core_cache2mem_addr;

endmodule




