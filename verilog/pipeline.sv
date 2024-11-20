/////////////////////////////////////////////////////////////////////////
//                                                                     //
//   Modulename :  pipeline.sv                                         //
//                                                                     //
//  Description :  Top-level module of the verisimple pipeline;        //
//                 This instantiates and connects the 5 stages of the  //
//                 Verisimple pipeline together.                       //
//                                                                     //
/////////////////////////////////////////////////////////////////////////

`include "verilog/sys_defs.svh"

module pipeline (
    input        clock,             // System clock
    //Cassie input        clock_shadow,      // System shadow clock
    input        reset,             // System reset
    input [3:0]  mem2proc_response, // Tag from memory about current request
    input [63:0] mem2proc_data,     // Data coming back from memory
    input [3:0]  mem2proc_tag,      // Tag from memory about current reply

    output logic [1:0]       proc2mem_command, // Command sent to memory
    output logic [`XLEN-1:0] proc2mem_addr,    // Address sent to memory
    output logic [63:0]      proc2mem_data,    // Data sent to memory
    output MEM_SIZE          proc2mem_size,    // Data size sent to memory

    // Note: these are assigned at the very bottom of the module
    output logic [3:0]       pipeline_completed_insts,
    output EXCEPTION_CODE    pipeline_error_status,
    output logic [4:0]       pipeline_commit_wr_idx,
    output logic [`XLEN-1:0] pipeline_commit_wr_data,
    output logic             pipeline_commit_wr_en,
    output logic [`XLEN-1:0] pipeline_commit_NPC,

    // Debug outputs: these signals are solely used for debugging in testbenches
    // Do not change for project 3
    // You should definitely change these for project 4
    output logic [`XLEN-1:0] if_NPC_dbg,
    output logic [31:0]      if_inst_dbg,
    output logic             if_valid_dbg,
    output logic [`XLEN-1:0] if_id_NPC_dbg,
    output logic [31:0]      if_id_inst_dbg,
    output logic             if_id_valid_dbg,
    output logic [`XLEN-1:0] id_ex_NPC_dbg,
    output logic [31:0]      id_ex_inst_dbg,
    output logic             id_ex_valid_dbg,
    output logic [`XLEN-1:0] ex_mem_NPC_dbg,
    output logic [31:0]      ex_mem_inst_dbg,
    output logic             ex_mem_valid_dbg,
    output logic [`XLEN-1:0] mem_wb_NPC_dbg,
    output logic [31:0]      mem_wb_inst_dbg,
    output logic             mem_wb_valid_dbg,
    //Dcache dbg
    output logic [32+3:0][64-1:0]                                          dbg_cache_mem,
    output logic [32+3:0][13-1:0]                                          dbg_cache_addr,
    output logic [32+3:0]                                                  dbg_cache_valid,
    output logic [32+3:0]                                                  dbg_cache_dirty
);

    logic [3:0]  MEM_DCACHE_response;
    logic [1:0]  DCACHE_MEM_command;
    logic [31:0] DCACHE_MEM_addr;
    logic [63:0] DCACHE_MEM_data;
    
    logic                           [`XLEN-1:0]   FETCH_ICACHE_instr_fetch_pc;
    logic                           [`FETCH_WIDTH-1:0][`XLEN-1:0]   ICACHE_FETCH_instr;
    logic                                         ICACHE_FETCH_instr_vld;
    //ICACHE <-> MEM
    logic [3:0]  MEM_ICACHE_response;
    logic [63:0] MEM_ICACHE_data;
    logic [3:0]  MEM_ICACHE_tag;
    logic [1:0]  ICACHE_MEM_command;
    logic [31:0] ICACHE_MEM_addr;

    //load <-> D$                      
    logic [3:0]                                                 DCACHE_LOAD_load_cache2proc_response;
    logic [31:0]                                                DCACHE_LOAD_load_cache2proc_data;
    logic [3:0]                                                 DCACHE_LOAD_load_cache2proc_tag; //unused
    logic                                                       LOAD_DCACHE_load_proc2cache_load;
    logic [31:0]                                                LOAD_DCACHE_load_proc2cache_addr;  
    MEM_SIZE                                                    LOAD_DCACHE_load_proc2cache_size; 
    //store <-> D$ store ports
    logic                                                       DCACHE_STORE_store_cache2proc_response;
    logic                                                       STORE_DCACHE_store_proc2cache_store;
    logic [31:0]                                                STORE_DCACHE_store_proc2cache_addr;
    logic [31:0]                                                STORE_DCACHE_store_proc2cache_data;
    MEM_SIZE                                                    STORE_DCACHE_store_proc2cache_size;

    logic          stall;
    //Cassie logic          razor_in_rdy, razor_out_vld, razor_mismatch;
    
    //////////////////////////////////////////////////
    //                                              //
    //                Pipeline Wires                //
    //                                              //
    //////////////////////////////////////////////////

    // Pipeline register enables
    logic if_id_enable, id_ex_enable, ex_mem_enable, mem_wb_enable;

    // Outputs from IF-Stage and IF/ID Pipeline Register
    logic [`XLEN-1:0] proc2Imem_addr;
    IF_ID_PACKET if_packet, if_packet_nop, if_id_reg;

    // Outputs from ID stage and ID/EX Pipeline Register
    ID_EX_PACKET id_packet, id_packet_nop, id_ex_reg,id_ex_reg_fwd;

    // Outputs from EX-Stage and EX/MEM Pipeline Register
    EX_MEM_PACKET ex_packet, ex_packet_nop, ex_mem_reg;

    // Outputs from MEM-Stage and MEM/WB Pipeline Register
    MEM_WB_PACKET mem_packet, mem_wb_reg, mem_packet_nop;

    // Outputs from MEM-Stage to memory
    logic [`XLEN-1:0] proc2Dmem_addr;
    logic [`XLEN-1:0] proc2Dmem_data;
    logic [1:0]       proc2Dmem_command; //This is replace with DCACHE_MEM_command
    MEM_SIZE          proc2Dmem_size;

    // Outputs from WB-Stage (These loop back to the register file in ID)
    logic             wb_regfile_en;
    logic [4:0]       wb_regfile_idx;
    logic [`XLEN-1:0] wb_regfile_data;

   
    logic             wx_fwd_rs1;
    logic	      wx_fwd_rs2;

    logic   	      mx_fwd_rs1;
    logic   	      mx_fwd_rs2;
    logic             wb_regfile_en_mem; //wb_regfile_en at mem stage
    logic [`XLEN-1:0] wb_regfile_data_mem; //wb_regfile_data at mem stage
    logic             wb_regfile_en_ex;
    logic             if_id_reg_rs1_valid;
    logic   	      if_id_reg_rs2_valid;
    logic             id_ex_reg_rs1_valid;
    logic   	      id_ex_reg_rs2_valid;

    // decode stage
    // rs1 is not used in U/J Type instruction
    assign if_id_reg_rs1_valid =  ~((if_id_reg.inst.r.opcode == 7'b0110111) || (if_id_reg.inst.r.opcode == 7'b0010111) || (if_id_reg.inst.r.opcode == 7'b1101111));
    // rs2 is only used in R/S/B Type instruction
    assign if_id_reg_rs2_valid = (if_id_reg.inst.r.opcode == 7'b0110011) || (if_id_reg.inst.r.opcode == 7'b0100011) || (if_id_reg.inst.r.opcode == 7'b1100011);

    // ex stage
    // rs1 is not used in U/J Type instruction
    assign id_ex_reg_rs1_valid =  ~((id_ex_reg.inst.r.opcode == 7'b0110111) || (id_ex_reg.inst.r.opcode == 7'b0010111) || (id_ex_reg.inst.r.opcode == 7'b1101111));
    // rs2 is only used in R/S/B Type instruction
    assign id_ex_reg_rs2_valid = (id_ex_reg.inst.r.opcode == 7'b0110011) || (id_ex_reg.inst.r.opcode == 7'b0100011) || (id_ex_reg.inst.r.opcode == 7'b1100011);

    assign wb_regfile_en_mem = ex_mem_reg.valid && (ex_mem_reg.dest_reg_idx != `ZERO_REG);
    assign wb_regfile_data_mem = ex_mem_reg.take_branch ? ex_mem_reg.NPC : (ex_mem_reg.alu_result); // only valid when !ex_mem_reg.rd_mem

    assign wb_regfile_en_ex = id_ex_reg_fwd.valid && (id_ex_reg_fwd.dest_reg_idx != `ZERO_REG);
    //assign ld_to_use_stall = (wb_regfile_en_mem && ((ex_mem_reg.dest_reg_idx==id_ex_reg.inst.r.rs1)||(ex_mem_reg.dest_reg_idx==id_ex_reg.inst.r.rs2))) && (ex_mem_reg.rd_mem);
    assign ld_to_use_stall = (wb_regfile_en_ex  && (((id_ex_reg_fwd.dest_reg_idx==if_id_reg.inst.r.rs1)&&if_id_reg_rs1_valid)||((id_ex_reg_fwd.dest_reg_idx==if_id_reg.inst.r.rs2)&&if_id_reg_rs2_valid))) && (id_ex_reg_fwd.rd_mem);


    //////////////////////////////////////////////////
    //                                              //
    //                Memory Outputs                //
    //                                              //
    //////////////////////////////////////////////////

    // these signals go to and from the processor and memory
    // we give precedence to the mem stage over instruction fetch
    // note that there is no latency in project 3
    // but there will be a 100ns latency in project 4

    always_comb begin
        MEM_ICACHE_response        = 'b0;
        MEM_DCACHE_response        = 'b0;

        if (DCACHE_MEM_command != BUS_NONE) begin // read or write DATA from memory
            proc2mem_command = DCACHE_MEM_command;
            proc2mem_addr    = DCACHE_MEM_addr;
            //proc2mem_size    = proc2Dmem_size;  //Cassie: size is not sent to mem in P4?
            MEM_DCACHE_response           = mem2proc_response;  
        end else begin                          // read an INSTRUCTION from memory
            proc2mem_command = ICACHE_MEM_command;
            proc2mem_addr    = ICACHE_MEM_addr;
            //proc2mem_size    = DOUBLE;          // instructions load a full memory line (64 bits)
            MEM_ICACHE_response           = mem2proc_response;            
        end
        proc2mem_data = {32'b0, DCACHE_MEM_data};
    end

    assign stall = (LOAD_DCACHE_load_proc2cache_load && DCACHE_LOAD_load_cache2proc_response==0) || (STORE_DCACHE_store_proc2cache_store && DCACHE_STORE_store_cache2proc_response==0); 

    //////////////////////////////////////////////////
    //                                              //
    //                  Valid Bit                   //
    //                                              //
    //////////////////////////////////////////////////

    // This state controls the stall signal that artificially forces IF
    // to stall until the previous instruction has completed.
    // For project 3, start by setting this to always be 1

    logic next_if_valid;

    // synopsys sync_set_reset "reset"
    always_ff @(posedge clock) begin
        /*
        if(ex_packet.ex_memory_access) begin
	    next_if_valid <= 0;
	end else begin
            next_if_valid <= 1;
 	end
 	*/
        if (reset) begin
            // start valid, other stages (ID,EX,MEM,WB) start as invalid
            next_if_valid <= 1;
        end else begin
            // valid bit will cycle through the pipeline and come back from the wb stage
            next_if_valid <= mem_wb_reg.valid;
        end
	
    end

    //////////////////////////////////////////////////
    //                                              //
    //            Hazard Detection Unit             //
    //                                              //
   /////////////////////////////////////////////////
    //logic wb_d_fwd;
    // WB -> D forwarding
    //assign wb_d_fwd = (wb_regfile_en) 





    //////////////////////////////////////////////////
    //                                              //
    //                  IF-Stage                    //
    //                                              //
   /////////////////////////////////////////////////
   

    stage_if stage_if_0 (
        // Inputs
        .clock (clock),
        .reset (reset),
        //.if_valid       (next_if_valid),
        .if_valid       ((ICACHE_FETCH_instr_vld)&&(!ld_to_use_stall)&&(!stall)),
        .take_branch    (ex_mem_reg.take_branch),
        .branch_target  (ex_mem_reg.alu_result),
        .Imem2proc_data ({ICACHE_FETCH_instr[1],ICACHE_FETCH_instr[0]}),

        // Outputs
        .if_packet      (if_packet),
        .proc2Imem_addr (FETCH_ICACHE_instr_fetch_pc)
    );

    // debug outputs
    assign if_NPC_dbg   = if_packet.NPC;
    assign if_inst_dbg  = if_packet.inst;
    assign if_valid_dbg = if_packet.valid;

    //Cassie
    icache_old icache(
        .clock                                (clock),
        .reset                                (reset),

        .Imem2proc_response                 (MEM_ICACHE_response), 
        .Imem2proc_data                     (mem2proc_data),
        .Imem2proc_tag                      (mem2proc_tag),
        .proc2Icache_addr                   (FETCH_ICACHE_instr_fetch_pc),
        .proc2Imem_command                  (ICACHE_MEM_command),
        .proc2Imem_addr                     (ICACHE_MEM_addr),              
        .Icache_data_out                    (ICACHE_FETCH_instr), 
        .Icache_valid_out                   (ICACHE_FETCH_instr_vld)  
    );

    //////////////////////////////////////////////////
    //                                              //
    //            IF/ID Pipeline Register           //
    //                                              //
    //////////////////////////////////////////////////

    assign if_id_enable = !stall;
    // synopsys sync_set_reset "reset"

    always_comb begin
       if_packet_nop = 'b0;
       if_packet_nop.inst = `NOP; 
       if_packet_nop.valid = 0;
      
       /*
       if_packet_nop = if_packet;
       if_packet_nop.inst  = `NOP;
       if_packet_nop.valid = 0;
       */
    end

    always_ff @(posedge clock) begin
        if (reset) begin
            if_id_reg.inst  <= `NOP;
            if_id_reg.valid <= `FALSE;
            if_id_reg.NPC   <= 0;
            if_id_reg.PC    <= 0;
        end else if (if_id_enable) begin
            if_id_reg <= (ex_mem_reg.take_branch || !ICACHE_FETCH_instr_vld) ? if_packet_nop : (ld_to_use_stall ? if_id_reg : if_packet);
            //if_id_reg <= if_packet;
        end
    end

    // debug outputs
    assign if_id_NPC_dbg   = if_id_reg.NPC;
    assign if_id_inst_dbg  = if_id_reg.inst;
    assign if_id_valid_dbg = if_id_reg.valid;

    //////////////////////////////////////////////////
    //                                              //
    //                  ID-Stage                    //
    //                                              //
    //////////////////////////////////////////////////
 
    stage_id stage_id_0 (
        // Inputs
        .clock (clock),
        .reset (reset),
        .if_id_reg        (if_id_reg),
        .wb_regfile_en    (wb_regfile_en),
        .wb_regfile_idx   (wb_regfile_idx),
        .wb_regfile_data  (wb_regfile_data),

        // Output
        .id_packet (id_packet)
    );

    //////////////////////////////////////////////////
    //                                              //
    //            ID/EX Pipeline Register           //
    //                                              //
    //////////////////////////////////////////////////

   
    always_comb begin
       id_packet_nop = 'b0;
       id_packet_nop.inst = `NOP;
       id_packet_nop.valid = 0;
       /*
       id_packet_nop       = id_packet;
       id_packet_nop.inst  = `NOP;
       id_packet_nop.valid = 0;
       */
    end

    assign id_ex_enable = !stall;
    // synopsys sync_set_reset "reset"
    always_ff @(posedge clock) begin
        if (reset) begin
            id_ex_reg <= '{
                `NOP, // we can't simply assign 0 because NOP is non-zero
                {`XLEN{1'b0}}, // PC
                {`XLEN{1'b0}}, // NPC
                {`XLEN{1'b0}}, // rs1 select
                {`XLEN{1'b0}}, // rs2 select
                OPA_IS_RS1,
                OPB_IS_RS2,
                `ZERO_REG,
                ALU_ADD,
                1'b0, // rd_mem
                1'b0, // wr_mem
                1'b0, // cond
                1'b0, // uncond
                1'b0, // halt
                1'b0, // illegal
                1'b0, // csr_op
                1'b0  // valid
            };
        end else if (id_ex_enable) begin
            id_ex_reg <= ((ex_mem_reg.take_branch || ld_to_use_stall) ? id_packet_nop : (id_packet));
            //Cassie id_ex_reg <= ~razor_in_rdy ? id_ex_reg : ((ex_mem_reg.take_branch || ld_to_use_stall) ? id_packet_nop : (id_packet));
        end
    end

    // debug outputs
    assign id_ex_NPC_dbg   = id_ex_reg.NPC;
    assign id_ex_inst_dbg  = id_ex_reg.inst;
    assign id_ex_valid_dbg = id_ex_reg.valid;

    //////////////////////////////////////////////////
    //                                              //
    //                  EX-Stage                    //
    //                                              //
    //////////////////////////////////////////////////
    
    always_comb begin
        // wb to ex forwarding
        // ld to use have to stall - won't even happen here, since we resolve
        // ld_to_use case by stalling the later instruction at decode stage
        wx_fwd_rs1 = (wb_regfile_en && (wb_regfile_idx==id_ex_reg.inst.r.rs1) && id_ex_reg_rs1_valid);
        wx_fwd_rs2 = (wb_regfile_en && (wb_regfile_idx==id_ex_reg.inst.r.rs2) && id_ex_reg_rs2_valid);
 
        // mem to ex forwarding
        // ld to use have to stall - won't even happen here
        mx_fwd_rs1 = (wb_regfile_en_mem && (ex_mem_reg.dest_reg_idx==id_ex_reg.inst.r.rs1) && id_ex_reg_rs1_valid);
        mx_fwd_rs2 = (wb_regfile_en_mem && (ex_mem_reg.dest_reg_idx==id_ex_reg.inst.r.rs2) && id_ex_reg_rs2_valid);

	id_ex_reg_fwd = id_ex_reg;
        //mem->ex fwd has higher priority than wb->ex fwd
        id_ex_reg_fwd.rs1_value = mx_fwd_rs1 ? wb_regfile_data_mem : (wx_fwd_rs1 ? wb_regfile_data : id_ex_reg.rs1_value);
        id_ex_reg_fwd.rs2_value = mx_fwd_rs2 ? wb_regfile_data_mem : (wx_fwd_rs2 ? wb_regfile_data : id_ex_reg.rs2_value);
    end
 
    stage_ex stage_ex_0 (
        // Input
        //.id_ex_reg (id_ex_reg),
        .id_ex_reg (id_ex_reg_fwd),

        // Output
        .ex_packet (ex_packet)
    );

    //////////////////////////////////////////////////
    //                                              //
    //           EX/MEM Pipeline Register           //
    //                                              //
    //////////////////////////////////////////////////
    //Cassie
    always_comb begin
       ex_packet_nop = 'b0;
       ex_packet_nop.valid = 0;
    end
    
    assign ex_mem_enable = !stall;
    // synopsys sync_set_reset "reset"
    always_ff @(posedge clock) begin
        if (reset) begin
            ex_mem_inst_dbg <= `NOP; // debug output
            ex_mem_reg      <= 0;    // the defaults can all be zero!
        end else if (ex_mem_enable) begin
            ex_mem_inst_dbg <= id_ex_inst_dbg; // debug output, just forwarded from ID
            ex_mem_reg      <= (ex_mem_reg.take_branch) ? ex_packet_nop : ex_packet;
            //ex_mem_reg      <= ex_packet;
        end
    end
    
    // debug outputs
    assign ex_mem_NPC_dbg   = ex_mem_reg.NPC;
    assign ex_mem_valid_dbg = ex_mem_reg.valid;
    
    /*Cassie
    // razor
    razor_wrapper #(.DATA_WIDTH($bits(EX_MEM_PACKET))) razor (
    .clk(clock),
    .clk_shadow(clock_shadow),
    .rst_n(~reset),
    // Upstream
    .in_data(ex_packet), 
    .in_vld(!ex_mem_reg.take_branch & ex_mem_reg.valid),
    .in_rdy(razor_in_rdy),
    // Downstream
    .out_data(ex_mem_reg),
    .out_vld(razor_out_vld),
    .out_rdy(!stall),
    // Other
    .mismatch(razor_mismatch)
    );
    */

    //////////////////////////////////////////////////
    //                                              //
    //                 MEM-Stage                    //
    //                                              //
    //////////////////////////////////////////////////

    always_comb begin
       mem_packet_nop = 'b0;
       mem_packet_nop.valid = 0;
    end

    stage_mem stage_mem_0 (
        // Inputs
        .ex_mem_reg     (ex_mem_reg),
        .Dmem2proc_data (DCACHE_LOAD_load_cache2proc_data[`XLEN-1:0]), // for p3, we throw away the top 32 bits

        // Outputs
        .mem_packet        (mem_packet),
        .proc2Dmem_command (),//Cassie: not needed for now
        .proc2Dmem_size    (LOAD_DCACHE_load_proc2cache_size),
        .proc2Dmem_addr    (LOAD_DCACHE_load_proc2cache_addr),
        .proc2Dmem_data    (STORE_DCACHE_store_proc2cache_data)
    );

    assign LOAD_DCACHE_load_proc2cache_load = ex_mem_reg.valid && ex_mem_reg.rd_mem;

    assign STORE_DCACHE_store_proc2cache_store = ex_mem_reg.valid && ex_mem_reg.wr_mem;
    assign STORE_DCACHE_store_proc2cache_addr = LOAD_DCACHE_load_proc2cache_addr;
    assign STORE_DCACHE_store_proc2cache_size = LOAD_DCACHE_load_proc2cache_size;
    

    Dcache_blocking Dcache(
        .clk                            (clock),
        .rst                            (reset),
        .load_cache2proc_response_o     (DCACHE_LOAD_load_cache2proc_response), // Cassie:this need to be added to stage_mem. if cache do not have the data, need to stall the processor to wait for fetching from memory. stall can be release when DCACHE_LOAD_load_cache2proc_response != 0 ??
        .load_cache2proc_data_o         (DCACHE_LOAD_load_cache2proc_data),
        .load_cache2proc_tag_o          (DCACHE_LOAD_load_cache2proc_tag ),
        .load_proc2cache_load_i         (LOAD_DCACHE_load_proc2cache_load),
        .load_proc2cache_addr_i         (LOAD_DCACHE_load_proc2cache_addr),
        .store_cache2proc_response_o    (DCACHE_STORE_store_cache2proc_response),
        .store_proc2cache_store_i       (STORE_DCACHE_store_proc2cache_store),
        .store_proc2cache_addr_i        (STORE_DCACHE_store_proc2cache_addr),
        .store_proc2cache_data_i        (STORE_DCACHE_store_proc2cache_data),
        .store_proc2cache_size_i        (STORE_DCACHE_store_proc2cache_size),
        .mem2cache_response_i           (MEM_DCACHE_response),
        .mem2cache_data_i               (mem2proc_data),
        .mem2cache_tag_i                (mem2proc_tag),
        .cache2mem_command_o            (DCACHE_MEM_command ),
        .cache2mem_addr_o               (DCACHE_MEM_addr    ),
        .cache2mem_data_o               (DCACHE_MEM_data    ),
        .dbg_cache_mem                  (dbg_cache_mem      ),
        .dbg_cache_addr                 (dbg_cache_addr     ),
        .dbg_cache_valid                (dbg_cache_valid    ),
        .dbg_cache_dirty                (dbg_cache_dirty    )
    );

    //////////////////////////////////////////////////
    //                                              //
    //           MEM/WB Pipeline Register           //
    //                                              //
    //////////////////////////////////////////////////

    assign mem_wb_enable = 1'b1; // always enabled
    // synopsys sync_set_reset "reset"
    always_ff @(posedge clock) begin
        if (reset) begin
            mem_wb_inst_dbg <= `NOP; // debug output
            mem_wb_reg      <= 0;    // the defaults can all be zero!
        end else if (mem_wb_enable) begin
            //mem_wb_inst_dbg <= ex_mem_inst_dbg; // debug output, just forwarded from EX
            //mem_wb_reg      <= mem_packet;
            mem_wb_reg      <= stall ? mem_packet_nop : mem_packet;
        end
    end

    // debug outputs
    assign mem_wb_NPC_dbg   = mem_wb_reg.NPC;
    assign mem_wb_valid_dbg = mem_wb_reg.valid;

    //////////////////////////////////////////////////
    //                                              //
    //                  WB-Stage                    //
    //                                              //
    //////////////////////////////////////////////////

    stage_wb stage_wb_0 (
        // Input
        .mem_wb_reg (mem_wb_reg), // doesn't use all of these

        // Outputs
        .wb_regfile_en   (wb_regfile_en),
        .wb_regfile_idx  (wb_regfile_idx),
        .wb_regfile_data (wb_regfile_data)
    );

    //////////////////////////////////////////////////
    //                                              //
    //               Pipeline Outputs               //
    //                                              //
    //////////////////////////////////////////////////

    assign pipeline_completed_insts = {3'b0, mem_wb_reg.valid}; // commit one valid instruction
    /*assign pipeline_error_status = mem_wb_reg.illegal        ? ILLEGAL_INST :
                                   mem_wb_reg.halt           ? HALTED_ON_WFI :
                                   (mem2proc_response==4'h0) ? LOAD_ACCESS_FAULT : NO_ERROR;
    */
    assign pipeline_error_status = mem_wb_reg.illegal        ? ILLEGAL_INST :
                                   mem_wb_reg.halt           ? HALTED_ON_WFI : NO_ERROR;

    assign pipeline_commit_wr_en   = wb_regfile_en;
    assign pipeline_commit_wr_idx  = wb_regfile_idx;
    assign pipeline_commit_wr_data = wb_regfile_data;
    assign pipeline_commit_NPC     = mem_wb_reg.NPC;

endmodule // pipeline
