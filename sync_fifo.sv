module sync_fifo#(
  parameter WIDTH = 8,
  parameter DEPTH = 8
)
(
  input logic clk,
  input logic rst_n,
  input logic write,
  input logic read,
  input logic [WIDTH-1:0] data_in,
  output logic [WIDTH-1:0] data_out,
  output logic full,
  output logic empty
);
  //Ensure DEPTH is a power of 2
  initial begin
    if ((DEPTH & DEPTH-1) != 0) begin
        $error("Error: The FIFO depth must be a power of 2");
      end
  end
  
  //creates a 2D array for fifo
  logic [WIDTH-1:0] mem [0:DEPTH-1];
  	
  //Address width is log2(DEPTH) so that if DEPTH is changed in the testbench it will calculate correctly 
  localparam int ADDR_WIDTH = $clog2(DEPTH);
  logic [ADDR_WIDTH:0] wr_ptr; //adds 1 bit to the size of the pointer to handle wrap-around
  logic [ADDR_WIDTH:0] rd_ptr;
  	
  //flags logic
  assign full = (wr_ptr[ADDR_WIDTH] != rd_ptr[ADDR_WIDTH]) && (wr_ptr[ADDR_WIDTH-1:0] == rd_ptr[ADDR_WIDTH-1:0]);
  assign empty = (wr_ptr == rd_ptr);
  	
  //write logic
  always_ff @(posedge clk or negedge rst_n) begin 
      if (rst_n == 0) begin
		wr_ptr <= 0;
      end
      else if (write == 1 && full != 1) begin
        mem[wr_ptr[ADDR_WIDTH-1:0]] <= data_in;
        wr_ptr <= wr_ptr + 1;
      end
   end
    
  //read logic
  always_ff @(posedge clk or negedge rst_n) begin
      if (rst_n == 0) begin
		rd_ptr <= 0;
          data_out <= 0;
      end
      else if (read == 1 && empty != 1) begin
        data_out <= mem[rd_ptr[ADDR_WIDTH-1:0]];
        rd_ptr <= rd_ptr + 1;
      end
  end
  
endmodule
