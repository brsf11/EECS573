`timescale 1ns/1ps
`ifndef TEST_CLOCK_PERIOD
    `define TEST_CLOCK_PERIOD 3.8
`endif 
`ifndef SHADOW_SKEW
    `define SHADOW_SKEW       1.8
`endif
class GaussianNum;

  int seed = 1;
  int mean = 256;
  int std_deviation = 65536;
  rand bit[31:0] rand_value;

  function int gaussian_dist (int seed);
    return $dist_normal (seed, mean, std_deviation);
  endfunction

  constraint c_value { rand_value == gaussian_dist (seed); }

endclass

module test_mult();

    logic is_FAIL;

    logic[63:0] mcand,mplier;
    logic       in_vld,in_rdy;

    logic       clk,clk_shadow,rst_n;

    logic[63:0] product;
    logic       out_vld,out_rdy;

    mult DUT(
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
        #(`TEST_CLOCK_PERIOD / 2);
        clk = ~clk;
    end

    initial begin
        clk_shadow = 1;
        #(`SHADOW_SKEW);
        while(1)begin
            #(`TEST_CLOCK_PERIOD / 2);
            clk_shadow = ~clk_shadow;
        end
    end

    //assign #(`SHADOW_SKEW) clk_shadow = clk;
    //assign out_rdy = 1;

    logic[63:0] result_queue[$];
    logic[63:0] result;

    logic[63:0] Anticipate_result;
    assign Anticipate_result = mcand * mplier;  

    task feed(input logic[63:0] a,input logic[63:0] b);
        mcand  = a;
        mplier = b;
        in_vld = 1'b1;
        @(posedge clk);
        while(~in_rdy) begin
            @(posedge clk);
        end
        $fdisplay(feed_file,"Time: %t. Data: mcand=%x mplier=%x, (aniticipate) product=%x feed into pipe.",$realtime(),a,b,Anticipate_result);
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
                $fdisplay(compare_file,"Time: %t. Output=%x, Anticipate output=%x",$realtime(),product,result);
                if(result != product)begin
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
        // #0.1;
        // out_rdy = $random()&1;
    end

    integer i;
    logic [63:0] test_in_A;
    logic [63:0] test_in_B;
    int mean_index = 16;
/*
    int seed = 1;
    int mean = 1 << 16;
    int std_deviation = 65536;
    int rand_num;
*/
    int file_A;
    int file_B;
    longint read_A;
    longint read_B;
    initial begin
    	//GaussianNum gaussian_gen = new();
	//gaussian_gen.rand_value.rand_mode(1);
        mcand  = 0;
        mplier = 0;
        in_vld = 1'b0;
        @(posedge rst_n);
        #0.1;
        file_A = $fopen("/home/cassiesu/Razor_mult/test/ran_A_chi.txt", "r");
        if (file_A == 0) begin
            $display("Error: Unable to open file.");
            $finish;
        end
        file_B = $fopen("/home/cassiesu/Razor_mult/test/ran_B_chi.txt", "r");
        if (file_B == 0) begin
            $display("Error: Unable to open file.");
            $finish;
        end
        for(i=0;i<10000;i=i+1) begin
            /*
            rand_num  = $dist_normal($random(), mean, std_deviation);
            rand_num  = (rand_num >= 0) ? rand_num : 0;
            test_in_A = {32'b0,rand_num};
            rand_num  = $dist_normal($random(), mean, std_deviation);
            rand_num  = (rand_num >= 0) ? rand_num : 0;
            test_in_B = {32'b0,rand_num};
            if(mean_index >= 16)begin
                test_in_A = test_in_A << (mean_index - 16);
                test_in_B = test_in_B << (mean_index - 16);
            end
            else begin
                test_in_A = test_in_A >> (16 - mean_index);
                test_in_B = test_in_B >> (16 - mean_index);
            end
            test_in_A = (test_in_A >= 1) ? test_in_A : 1;
            test_in_B = {32'b0,$random()};
            */
            if (!$feof(file_A)) begin
                if ($fscanf(file_A, "%u\n", read_A) == 1) begin
      	            test_in_A = read_A;
	        end
            end else
                $display("Error: can't read test_in_A.");
            if (!$feof(file_B)) begin
                if ($fscanf(file_B, "%u\n", read_B) == 1) begin
      	            test_in_B = read_B;
	        end
            end else
                $display("Error: can't read test_in_B.");
            feed(test_in_A,test_in_B);
            if(i%1000 == 999)
                $display("1000 cases Passed");
        end
        // // Test random in_vld
        // for(i=0;i<10000;i=i+1) begin
        //     if(($random()&1) == 1)begin
        //         @(posedge clk);
        //         #1;
        //     end
        //     feed({$random(),$random()},{$random(),$random()});
        //     if(i%1000 == 999)
        //         $display("1000 cases Passed");
        // end
        #40;
        $fclose(file_A);
        $fclose(file_B);
        $fclose(feed_file);
        $fclose(compare_file);
        $finish();
    end

    initial begin
        $dumpfile("Waveform/waveform.vcd");
        $dumpvars(0, DUT);
    end

endmodule
