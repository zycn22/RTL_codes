//----------------------------
// Module name: sync_fifo 
// Author: Yechengnuo Zhang 
// Date: 15 Aug 2022
// Description: Syncronize FIFO 
// Revision: v1.0
//----------------------------
`timescale 1ns/1ps 

module sync_fifo
    #(parameter DATA_WIDTH = 8,
      parameter FIFO_DEPTH = 8) 
    (//system signal
     input    clk, 
     input    rst_n, 
     //write signal
     input [DATA_WIDTH-1:0]    wr_data,
     input    wr_en,    //write enable 
    //read signal
     input    rd_en,    //read enable 
     output reg [DATA_WIDTH-1:0] rd_data,
    //flags 
     output   full, 
     output   empty 
    );


  localparam ADDR_WIDTH = $clog2(FIF0_DEPTH); 
  reg [ DATA_WIDTH - 1 : 0 ] mem [FIFO_DEPTH-1:0]; 
  reg [ ADDR_WIDTH: 0 ] wr_ptr; 
  reg [ ADDR WIDTH: 0] rd_ptr; 
  integer i;

  // write and read pointer
  always @(posedge clk or negedge rst_n) begin
      if(~rst_n) 
      	  wr_ptr <= {(ADDR_WIDTH+1){1'b0}}; 
      else if( wr_en && (~full)) 
      	  wr_ptr <= wr_ptr + 1'b1; 
      else 
      	  wr_ptr <= wr_ptr; 
  end

  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) 
        rd_ptr <= {(ADDR_WIDTH+1){1'b0}}; 
    else if(rd_en && (~empty)) 
    	rd_ptr <= rd_ptr + 1'b1; 
    else 
    	rd_ptr <= rd_ptr; 
  end


  //write and read fifo
  always @(posedge clk or negedge rst_n) begin
    if(~rst_n) 
    	for (i=0;i< ADDR_WIDTH ; 
    		i = i+1'b1 ) mem[i] <= {DATA_WIDTH{1'b0}}; 

    else if(wr_en && (~full)) 
    	mem[wr_ptr[ADDR_WIDTH-1:0]] <= wr_data; 
    else 
    	mem[wr_ptr[ADDR_WIDTH-1:0]] <= mem[wr_ptr[ADDR_WIDTH-1:0]]; 
  end

  always @(posedge clk or negedge rst_n) begin
  if(~rst_n)
  	rd_data = {DATA_WIDTH{1'b0}}; 
  else if(rd_en && (~empty))
  	rd_data <= mem[rd_ptr[ADDR_WIDTH-1:0]]; 
  else
  	rd_data <= rd_data; 
  end


  // full & empty logic
  assign full = ((wr_ptr[ADDR_WIDTH-1:0] == rd_ptr[ADDR_WIDTH-1:0]) & (wr_ptr[ADDR_WIDTH]!=rd_ptr[ADDR_WIDTH])); 
  assign empty = (wr_ptr == rd_ptr);

endmodule 
