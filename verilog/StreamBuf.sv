`include "verilog/sys_defs.svh"

module StreamBuf #(
    parameter DEPTH = 8,
    parameter WIDTH = 2
)(
    input  logic                   clk,
    input  logic                   rst,
    // Load ports
    input  logic            [15:0] load_addr, // ignore [2:0]
    input  logic                   load,
    output logic [WIDTH-1:0]       load_vld,
    output logic [WIDTH-1:0][63:0] load_data,
    // Allocate ports
    input  logic            [15:0] allocate_addr, // ignore [2:0]
    input  logic                   allocate,
    // MEM ports
    input  logic [3:0]             mem2buf_response_i,
    input  logic [63:0]            mem2buf_data_i,
    input  logic [3:0]             mem2buf_tag_i,
    output logic [1:0]             buf2mem_command_o,
    output logic [31:0]            buf2mem_addr_o
);

    genvar i;

    logic [DEPTH-1:0][63:0]       StreamBufData;
    logic [DEPTH-1:0][15:0]       StreamBufAddr;
    logic [DEPTH-1:0][63:0]       nxt_StreamBufData;
    logic [DEPTH-1:0][15:0]       nxt_StreamBufAddr;
    logic [DEPTH-1:0]             valid_mask;
    logic [DEPTH-1:0]             match_mask;

    logic            [$clog2(DEPTH):0]   wr_ptr_all;
    logic            [$clog2(DEPTH):0]   nxt_wr_ptr_all;
    logic            [$clog2(DEPTH):0]   rd_ptr_all;
    logic            [$clog2(DEPTH):0]   nxt_rd_ptr_all;
    logic            [$clog2(DEPTH):0]   load_ptr_all;
    logic            [$clog2(WIDTH):0]   load_num;
    
    logic            [$clog2(DEPTH)-1:0] wr_ptr;
    logic            [$clog2(DEPTH)-1:0] rd_ptr;
    logic            [$clog2(DEPTH)-1:0] load_ptr;
    logic [WIDTH-1:0][$clog2(DEPTH)-1:0] all_load_ptr;
    logic [WIDTH-1:0][15:0]              all_load_addr;
    logic [WIDTH-1:0]                    temp_vld;

    logic                         activate;
    logic [15:0]                  access_addr;
    logic [15:0]                  nxt_access_addr;
    logic                         is_vacant;
    logic                         expected_vacant;
    logic [$clog2(DEPTH):0]       outstanding_load_num;
    logic [$clog2(DEPTH):0]       expected_wr_ptr_all;


    logic [`NUM_MEM_TAGS:1][15:0] load_table_addr;
    logic [`NUM_MEM_TAGS:1]       load_table_vld;
    logic [`NUM_MEM_TAGS:1][15:0] nxt_load_table_addr;
    logic [`NUM_MEM_TAGS:1]       nxt_load_table_vld;
    logic                         load_sent_rdy;
    logic                         load_sent_vld;
    logic                         load_sent;
    logic                         load_back;

    // StreamBuf content update logic
    always_ff @(posedge clk)begin
        if(rst)begin
            StreamBufData <= '0;
            StreamBufAddr <= '0;
        end
        else begin
            StreamBufData <= nxt_StreamBufData;
            StreamBufAddr <= nxt_StreamBufAddr;
        end
    end

    always_comb begin
        nxt_StreamBufAddr = StreamBufAddr;
        nxt_StreamBufData = StreamBufData;

        if(load_back)begin
            nxt_StreamBufAddr[wr_ptr] = load_table_addr[mem2buf_tag_i];
            nxt_StreamBufData[wr_ptr] = mem2buf_data_i;
        end
    end

    generate
        for(i=0;i<DEPTH;i++)begin
            always_comb begin
                if(wr_ptr_all[$clog2(DEPTH)] ^ rd_ptr_all[$clog2(DEPTH)])begin
                    valid_mask[i] = (i >= rd_ptr) | (i < wr_ptr);
                end
                else begin
                    valid_mask[i] = (i >= rd_ptr) & (i < wr_ptr);
                end
            end

            assign match_mask[i] = valid_mask[i] & (load_addr[15:3] == StreamBufAddr[i][15:3]);
        end
    endgenerate

    // Pointer logic
    always_ff @(posedge clk)begin
        if(rst)begin
            wr_ptr_all <= '0;
            rd_ptr_all <= '0;
        end
        else begin
            if(allocate)begin
                wr_ptr_all <= '0;
                rd_ptr_all <= '0;
            end
            else begin
                wr_ptr_all <= nxt_wr_ptr_all;
                rd_ptr_all <= nxt_rd_ptr_all;
            end
        end   
    end

    assign nxt_wr_ptr_all = wr_ptr_all + ((load_back & is_vacant) ? 1'b1 : 1'b0);
    assign nxt_rd_ptr_all = (load & (|load_vld)) ? (load_ptr_all + load_num) : rd_ptr_all;

    always_comb begin
        load_num = 0;
        for(int j=0;j<WIDTH;j++)begin
            load_num = load_num + ((load & load_vld[j]) ? 1'b1 : 1'b0);
        end
    end

    assign load_ptr_all[$clog2(DEPTH)-1:0] = load_ptr;
    assign load_ptr_all[$clog2(DEPTH)]     = (load_ptr < rd_ptr) ^ rd_ptr_all[$clog2(DEPTH)];

    // ptr logic
    assign wr_ptr = wr_ptr_all[$clog2(DEPTH)-1:0];
    assign rd_ptr = rd_ptr_all[$clog2(DEPTH)-1:0];
    
    onehot2bin #(
        .WIDTH_INPUT  (DEPTH),
        .WIDTH_OUTPUT ($clog2(DEPTH))  // 2**WIDTH_OUTPUT >= WIDTH_INPUT
    )load_ptr_o2b(
        .onehot  (match_mask),
        .bin     (load_ptr)
    );

    generate
        for(i=0;i<WIDTH;i++)begin
            assign all_load_ptr[i]  = load_ptr + i;
            assign all_load_addr[i] = {load_addr[15:3],3'b0} + 8*i;
        end
    endgenerate

    // Aloocate & addr cnt logic
    assign nxt_access_addr = access_addr + (load_sent ? 4'b1000 : 4'b0);
    assign is_vacant       =          ~((wr_ptr_all[$clog2(DEPTH)] ^ rd_ptr_all[$clog2(DEPTH)]) &          (wr_ptr_all[$clog2(DEPTH)-1:0] == rd_ptr_all[$clog2(DEPTH)-1:0]));
    assign expected_vacant = ~((expected_wr_ptr_all[$clog2(DEPTH)] ^ rd_ptr_all[$clog2(DEPTH)]) & (expected_wr_ptr_all[$clog2(DEPTH)-1:0] == rd_ptr_all[$clog2(DEPTH)-1:0]));

    always_comb begin
        outstanding_load_num = 0;
        for(int j=1;j<=`NUM_MEM_TAGS;j++)begin
            outstanding_load_num = outstanding_load_num + (load_table_vld[j] ? 1'b1 : 1'b0);
        end
    end

    assign expected_wr_ptr_all = wr_ptr_all + outstanding_load_num;

    always_ff @(posedge clk)begin
        if(rst)begin
            activate    <= 1'b0;
            access_addr <= '0;
        end
        else begin
            if(allocate)begin
                activate    <= 1'b1;
                access_addr <= {allocate_addr[15:3],3'b0};
            end
            else begin
                access_addr <= nxt_access_addr;
            end
        end
    end

    // Load table logic
    always_ff @(posedge clk)begin
        if(rst)begin
            load_table_addr <= '0;
            load_table_vld  <= '0;
        end
        else begin
            if(allocate)begin
                load_table_addr <= '0;
                load_table_vld  <= '0;
            end
            else begin
                load_table_addr <= nxt_load_table_addr;
                load_table_vld  <= nxt_load_table_vld ;
            end
        end
    end

   // nxt_load_table logic
    generate
        for(i=1;i<=`NUM_MEM_TAGS;i++)begin
            always_comb begin
                nxt_load_table_addr[i] = load_table_addr[i];
                nxt_load_table_vld[i]  = load_table_vld[i];
                if((load_sent == 1'b1) && (i == mem2buf_response_i))begin
                    nxt_load_table_addr[i] = access_addr;
                    nxt_load_table_vld[i]  = 1'b1;
                end
                else if((load_back == 1'b1) && (i == mem2buf_tag_i))begin
                    nxt_load_table_vld[i]  = 1'b0;
                end
            end
        end
    endgenerate

    assign load_sent_rdy = |mem2buf_response_i;
    assign load_sent_vld = activate & expected_vacant;
    assign load_sent     = load_sent_rdy & load_sent_vld;
    assign load_back     = (|mem2buf_tag_i) & load_table_vld[mem2buf_tag_i];

    // Output logic
    // Load ports
    generate
        for(i=0;i<WIDTH;i++)begin
            assign temp_vld[i] = (|match_mask) & (all_load_addr[i] == StreamBufAddr[all_load_ptr[i]]) & valid_mask[all_load_ptr[i]];
            assign load_data[i] = StreamBufData[all_load_ptr[i]];
        end
        assign load_vld[0] = temp_vld[0];
        for(i=1;i<WIDTH;i++)begin
            assign load_vld[i] = load_vld[i-1] & temp_vld[i];
        end
    endgenerate

    // MEM ports
    assign buf2mem_command_o = load_sent_vld ? BUS_LOAD : BUS_NONE;
    assign buf2mem_addr_o    = {16'b0,access_addr};

endmodule
