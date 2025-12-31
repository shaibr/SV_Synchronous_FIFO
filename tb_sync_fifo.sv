`timescale 1ns / 1ps

module tb_sync_fifo;
  	
  	initial begin
    	$dumpfile("dump.vcd");
      	$dumpvars(0, tb_sync_fifo);
	end
  	
  	localparam WIDTH = 8;
  	localparam DEPTH = 8;	
  	
  	logic clk;
    logic rst_n;
    logic write;
    logic read;
  	logic [WIDTH-1:0] data_in;
  	logic [WIDTH-1:0] data_out;
    logic full;
    logic empty;
  
  	//Reference model
  	logic [WIDTH-1:0] ref_q[$];
  	logic [WIDTH-1:0] expected_data;

  	sync_fifo#(
    	.WIDTH(WIDTH),
      	.DEPTH(DEPTH)
  	) dut (
      	.clk(clk),
      	.rst_n(rst_n),
      	.write(write),
      	.read(read),
      	.data_in(data_in),
      	.data_out(data_out),
      	.full(full),
      	.empty(empty)
    );
  	
    initial begin
    	clk = 0;
      	forever #5 clk = ~clk;
    end
    
    task automatic apply_reset();
    	begin
    		rst_n <= 0;
      		write <= 0;
      		read <= 0;
      		data_in <= 0;
			ref_q.delete();
      		repeat(2) @(posedge clk);
      		#1
      		rst_n <= 1;
      		@(posedge clk);
          	
          	if(empty == 0) begin
              $error("Error: FIFO not empty after Reset!");
            end
    	end	
    endtask
    
      task automatic write_data(input [WIDTH-1:0] value);
  		begin
          	if (full == 0) begin
            	ref_q.push_back(value);
            end
          
      		@(posedge clk);
      		write <= 1;
      		data_in <= value;
      		@(posedge clk);
      		write <= 0;
    	end
    endtask
      
     task automatic read_data();
  		begin
          	@(posedge clk);
      		read <= 1;
      		@(posedge clk);
      		read <= 0;
          	
          	@(posedge clk);
          	if (ref_q.size() > 0) begin
            	expected_data = ref_q.pop_front();
              	if (data_out !== expected_data) begin
                  	$error("Time %0t; Mismatch! Expected %h, Got %h", $time, expected_data, data_out);
                end
              	else begin
                  	$display("Time %0t; Read Success! Data: %h", $time, data_out);
                end
            end
    	end
    endtask
      
    initial begin
      	$display("Starting Fifo Test");
      	apply_reset();
      	
      	//Test 1: simple write and read
      	$display("\nTest 1: Simple Write/Read");
      	write_data(8'hA1);
      	write_data(8'hB2);
     	read_data();
      	read_data();
      	if (ref_q.size() == 0) begin
    		$display("Test 1 Passed: Simple Write/Read");
		end else begin
    		$error("Test 1 Failed: Reference queue not empty (Size: %0d)", ref_q.size());
		end
      
      
      	//Test 2: Full check and overflow
      	apply_reset();
      	$display("\nTest 2: Overflow Protection");
      	for (int i=0; i<DEPTH; i++) begin
          	write_data(i);
        end
      	
      	//Verify FIFO is full
      	@(posedge clk);
      	if (full == 0) begin
 	       $error("Error: FIFO should be full");
        end
     	
      	//Attempt Overflow
      	write_data(8'hFF);
      	
      	//Check data
      	for (int i=0; i<DEPTH; i++) begin
          	read_data();
        end
      	
      	if (ref_q.size() == 0) begin
        	$display("Overflow test passed");
        end
     	else
          	$error("Overflow test failed");
      	
      
      	//Test 3: Empty check and underflow
      	apply_reset();
      	$display("\nTest 3: Empty Condition");
      	if (empty == 0) begin
        	$error("Error: FIFO should be empty");
        end
      
      	read_data();
      	if (empty == 1) begin
          	$display("Underflow test passed");
        end
      	else
          	$error("Underflow test failed");
      
      	
      	//Test 4: Wrap around
      	apply_reset();
      	$display("\nTest 4: Wrap Around Logic");
      	
      	//fill out most of the FIFO
      	for (int i = 0; i < (DEPTH - 2); i++) begin
            write_data(i);
        end
     
      	//read half the items to free up space at the bottom
      	for (int i = 0; i < (DEPTH - 2); i++) begin
          	read_data();
        end
      	
      	//write new items to force the pointer to wrap around
      	for (int i = (DEPTH - 2); i < (DEPTH - 2) + (DEPTH / 2); i++) begin
    		write_data(i);
		end
      
      	//read all the elements
      	while (empty==0) begin
            read_data();
        end
      
      	//compare q_ref with the fifo to ensure no data was lost
      	if (ref_q.size() == 0) begin
          	$display("Wrap around test Passed");
        end
      	else begin
          	$error("Wrap around test Failed");
          	$display("Debug Info: DUT Empty Flag = %b, Ref Queue Size = %0d", empty, ref_q.size());
        end
      	
      	
      	//Test 5: Simultaneous write and read
      	apply_reset();
     	$display("\nTest 5: Simultaneous Read and Write");
      
      	for (int i=0; i < DEPTH/2; i++) begin
    		write_data(i);
		end
     	
      	@(posedge clk);
		write <= 1;
      	data_in <= 8'hA;
      	read <= 1;
      	ref_q.push_back(8'hA);
      	
      	@(posedge clk);
		write <= 0;
      	read <= 0;
      
      	expected_data = ref_q.pop_front();
      	#1;
      	if (data_out !== expected_data) begin
          	$error("Simul-Test: Read Mismatch! Expected %h, Got %h", expected_data, data_out);
        end 
      	else
          	$display("Simul-Test: Read Correct (%h)", data_out);
      
      	while (empty == 0) begin
    		read_data();
		end

      	if (ref_q.size() == 0) begin
    		$display("Simultaneous R/W Test Passed");
        end
        else 
    		$error("Simultaneous R/W Test Failed (Ref Q not empty)");
      	
          
      	$display("\nAll Tests Complete.");
      
      	#200;
        $finish;
    end

endmodule
