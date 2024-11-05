
module decoder (
    input      CLK,
    input      RSTn,
    input      [15:0] inst,
    output     [15:0] PC,
    output     [15:0] Rsrc,
    output     [15:0] Rdest,
    output     ALU_A_SEL, //0:QB 1:0
    output     ALU_B_SEL, //0:QA 1:imm
    output     Write_en,  //has_dest
    output     [15:0] Write_Addr,
    output     [7:0] imm,
    output     [1:0] ALU_SEL, // 00:AND 01:OR 10:ADD 11:XOR
    output     ALU_SUB,
    //output     //rd_mem, 
    output     Write_mem, // add branch later
    output     Extend_SEL, // 0:zero-extendsion 1:sign-extendsion
    output     [1:0] shifter_SEL, //0:QA 1:imm 2:8
    output     shifter_A_SEL, // 0:QB 1:imm
    output     RF_D_SEL, //0:D 1:PC
    output     [1:0] OUTPUT_SEL //0:DMEM 1:ALU 2:shifter
);
    reg [3:0] opcode, rdest, extend_op, rsrc;

    always @(*) begin
        Rdest        = 'b0;
        Rdest[rdest] = 1'b1;
        Rsrc         = 'b0;
        Rsrc[rsrc]   = 1'b1;
    end

    
    always @(posedge CLK) begin
        if(RSTn) begin
            PC <= 'b0;
        end else begin
            PC <= PC + 1; 
        end
    end

    always @(negedge CLK) begin
        if(RSTn) begin
            Write_Addr <= 'b0;
        end else begin
            Write_Addr <= Rdest; 
        end
    end
    
    always @(*) begin
        //init all signals to zero
        {opcode, rdest, extend_op, rsrc} = inst;
        //Write_Addr = Rdest;
        imm = {extend_op, rsrc};
        ALU_A_SEL     = 'b0;  
        ALU_B_SEL     = 'b0; 
        Write_en      = 'b0;
        ALU_SEL       = 'b0; 
        ALU_SUB       = 'b0;
        //rd_mem        = 'b0; 
        Write_mem     = 'b0;   
        Extend_SEL    = 'b0; 
        shifter_SEL   = 'b0; 
        shifter_A_SEL = 'b0;  
        RF_D_SEL      = 'b0;  
        OUTPUT_SEL    = 'b0;  
        
        case(opcode)
            4'b0000: begin
              if(extend_op!=4'b1101) begin
                ALU_A_SEL = 1'b0;
                ALU_B_SEL = 1'b0;
              end else begin
                ALU_A_SEL = 1'b1;
                ALU_B_SEL = 1'b0;
              end
              Write_en = 1'b1;
              if((extend_op==4'b0101)||(extend_op==4'b0110)||(extend_op==4'b0111)) begin //ADD
                  ALU_SEL = 2'b10;
              end else if ((extend_op==4'b1001)||(extend_op==4'b1010)||(extend_op==4'b1011)) begin //SUB/CMP
                  ALU_SEL = 2'b10;
                  ALU_SUB = 1'b1;
              end else if (extend_op==4'b0010) begin //OR 
                  ALU_SEL = 2'b01;
              end else if (extend_op==4'b0011) begin //XOR
                  ALU_SEL = 2'b11;
              end else if (extend_op==4'b0001) begin //AND
                  ALU_SEL = 2'b00;
              end
              OUTPUT_SEL = 2'b01;
            end
            4'b0001: begin //ANDI
              ALU_A_SEL  = 1'b0;
              ALU_B_SEL  = 1'b1;
              Write_en   = 1'b1;
              OUTPUT_SEL = 1'b1;
            end
            4'b0010: begin //ORI
              ALU_A_SEL  = 1'b0;
              ALU_B_SEL  = 1'b1;
              ALU_SEL    = 2'b01;
              Write_en   = 1'b1;
              OUTPUT_SEL = 1'b1;
            end
            4'b0011: begin //XORI
              ALU_A_SEL  = 1'b0;
              ALU_B_SEL  = 1'b1;
              ALU_SEL    = 2'b11;
              Write_en   = 1'b1;
              OUTPUT_SEL = 1'b1;
            end
            4'b0100: begin 
              if((extend_op==4'b0000)) begin//load
                Write_en  = 1'b1;
              end else if(extend_op==4'b0100) begin //store
                Write_mem = 1'b1;
              end
            
            end
            4'b0101: begin //ADDI
              ALU_A_SEL  = 1'b0;
              ALU_B_SEL  = 1'b1;
              ALU_SEL    = 2'b10;
              Extend_SEL = 1'b1;
              Write_en   = 1'b1;
              OUTPUT_SEL = 1'b1;
            end
            /*
            4'b0110: begin //ADDUI 
              ALU_A_SEL  = 1'b0;
              ALU_B_SEL  = 1'b1;
              ALU_SEL    = 2'b10;
              Extend_SEL = 1'b1;
              Write_en   = 1'b1;
              OUTPUT_SEL = 2'b1;
            end
            4'b0111: begin //ADDCI
              ALU_A_SEL  = 1'b0;
              ALU_B_SEL  = 1'b1;
              ALU_SEL    = 2'b10;
              Extend_SEL = 1'b1;
              Write_en   = 1'b1;
              OUTPUT_SEL = 2'b1;
            end*/
            4'b1000: begin // Shifter
              shifter_A_SEL   = 1'b0; // Rdest
              shifter_SEL = extend_op[2]? 2'b00: 2'b01; 
              Write_en   = 1'b1;
              OUTPUT_SEL = 2'b10;
            end
            4'b1001: begin //SUBI
              ALU_A_SEL  = 1'b0;
              ALU_B_SEL  = 1'b1;
              ALU_SEL    = 2'b10;
              ALU_SUB    = 1'b1;
              Extend_SEL = 1'b1;
              Write_en   = 1'b1;
              OUTPUT_SEL = 2'b1;
            end
            /*
            4'b1010: begin //SUBCI 
              ALU_A_SEL  = 1'b0;
              ALU_B_SEL  = 1'b1;
              ALU_SEL    = 2'b10;
              ALU_SUB    = 1'b1;
              Extend_SEL = 1'b1;
              Write_en   = 1'b1;
              OUTPUT_SEL = 2'b1;
            end*/
            4'b1011: begin //CMPI
              ALU_A_SEL  = 1'b0;
              ALU_B_SEL  = 1'b1;
              ALU_SEL    = 2'b10;
              ALU_SUB    = 1'b1;
              Extend_SEL = 1'b1;
              Write_en   = 1'b1;
              OUTPUT_SEL = 2'b1;
            end
            /*
            4'b1100: begin //add Bcond,Jcond,JAL inst later
              
            end*/
            4'b1101: begin //MOVI
              ALU_A_SEL  = 1'b1;
              ALU_B_SEL  = 1'b1;
              ALU_SEL    = 2'b10;
              Extend_SEL = 1'b1;
              Write_en   = 1'b1;
              OUTPUT_SEL = 1'b1;
            end/*
            4'b1110: begin //MULI 
             
            end*/
            4'b1111: begin //LUI
              shifter_A_SEL = 1'b1;
              shifter_SEL = 2'b10; 
              Write_en   = 1'b1;
              OUTPUT_SEL = 2'b10;
            end
            default: begin
              //Write_Addr    = 'b0;
              imm           = 'b0;
              ALU_A_SEL     = 'b0;  
              ALU_B_SEL     = 'b0; 
              Write_en      = 'b0;
              ALU_SEL       = 'b0; 
              ALU_SUB       = 'b0;
              //rd_mem        = 'b0; 
              Write_mem     = 'b0;   
              Extend_SEL    = 'b0; 
              shifter_SEL   = 'b0; 
              shifter_A_SEL = 'b0;  
              RF_D_SEL      = 'b0;  
              OUTPUT_SEL    = 'b0; 
            end

        endcase
        
    end
endmodule