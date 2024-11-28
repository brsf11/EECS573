`timescale 1ns/1ps
`define TEST_CLOCK_PERIOD 3.8
`define SHADOW_SKEW       1.8
module test_KSA();

    logic is_FAIL;

    logic[7:0] A,B;
    logic      Cin;
    logic      in_vld,in_rdy;

    logic      clk,clk_shadow,rst_n;

    logic[7:0] Sum;
    logic      Cout;
    logic      out_vld,out_rdy;
    logic      mismatch;

    KSA_wrapper DUT(
        .*
    );

    int feed_file;
    int compare_file;

    initial begin
        is_FAIL      = 0;
        feed_file    = $fopen("feed.txt");
        compare_file = $fopen("compare.txt");
        out_rdy = 1;
        clk     = 1;
        rst_n   = 0;
        @(posedge clk);
        @(posedge clk);
        #0.1;
        rst_n   = 1;
    end

    always begin
        #(`TEST_CLOCK_PERIOD/2);
        clk = ~clk;
    end

    initial begin
        clk_shadow = 1;
        #(`SHADOW_SKEW);
        while(1)begin
            #(`TEST_CLOCK_PERIOD/2);
            clk_shadow = ~clk_shadow;
        end
    end

    //assign #(`SHADOW_SKEW) clk_shadow = clk;
    //assign out_rdy = 1;

    logic[8:0] result_queue[$];
    logic[8:0] result;

    logic[8:0] Anticipate_result;
    //assign Anticipate_result = {1'b0,A} + {1'b0,B} + {8'b0,Cin};
    assign Anticipate_result = {1'b0,A} + {1'b0,B};  // Cin of KSA is not used

    task feed(input logic[7:0] a,input logic[7:0] b,input logic cin);
        A   = a;
        B   = b;
        Cin = cin;
        in_vld = 1'b1;
        @(posedge clk);
        while(~in_rdy) begin
            @(posedge clk);
        end
        $fdisplay(feed_file,"Time: %t. Data: A=%x B=%x Cin=%x, (aniticipate) Sum=%x, Cout=%x feed into pipe.",$realtime(),a,b,cin,Anticipate_result[7:0],Anticipate_result[8]);
        #1;
        in_vld = 1'b0;
        result_queue.push_back(Anticipate_result);
    endtask

    always @(posedge clk) begin
        // Compare logic
        if(out_vld&out_rdy)begin
            if(result_queue.size() == 0)begin
                $display("Error: result_queue size is zero when out_vld assert!!!");
                is_FAIL = 1;
                #40;
                $fclose(feed_file);
                $fclose(compare_file);
                $finish();
            end
            else begin
                result = result_queue.pop_front();
                $fdisplay(compare_file,"Time: %t. Output=%x, Anticipate output=%x",$realtime(),{Cout,Sum},result);
                if(result != {Cout,Sum})begin
                    $display("Error: result mismatch!!!");
                    is_FAIL = 1;
                    #40;
                    $fclose(feed_file);
                    $fclose(compare_file);
                    $finish();
                end
                //else begin
                //    $display("Success!!");
                //end
            end
        end
        // Downstream random back-pressure
        #0.1;
        out_rdy = $random()&1;
    end

    integer i;
    initial begin
        A = 0;
        B = 0;
        in_vld = 1'b0;
        @(posedge rst_n);
        #0.1;
        for(i=0;i<100000;i=i+1) begin
            feed($random(),$random(),$random());
            if(i%1000 == 999)
                $display("1000 cases Passed");
        end
        // Test random in_vld
        for(i=0;i<100000;i=i+1) begin
            if(($random()&1) == 1)begin
                @(posedge clk);
                #1;
            end
            feed($random(),$random(),$random());
            if(i%1000 == 999)
                $display("1000 cases Passed");
        end
        #40;
        $fclose(feed_file);
        $fclose(compare_file);
        $finish();
    end

    initial begin
        $dumpfile("waveform.fst");
        $dumpvars(0, DUT);
    end

endmodule
