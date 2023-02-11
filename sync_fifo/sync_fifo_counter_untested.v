//------------------------------
//
// Module Name: sync_fifo
// File Name: sync_fifo_counter_untested.v
// Description: synchronize FIFO with a counter
// Author: Yechengnuo Zhang
// Date: 15 Aug 2022
// 
//------------------------------

module sync_fifo 
	#(parameter WIDTH = 8,
	  parameter DEPTH = 16)
    (input                        clk,
     input                        rst_n,
     //write signals
     input                        wr_en,
     input [WIDTH-1:0]            wr_data,
     output reg                   full,
     //read signals
     input                        rd_en,
     output reg [WIDTH-1:0]       rd_data,
     output reg                   empty,
     output reg [$clog2(DEPTH):0] cnt  //$clog2 is a synthesizable system function
    );

  reg [WIDTH-1:0] mem [0:DEPTH-1];
  reg [$clog2(DEPTH)-1:0] wr_ptr;
  reg [$clog2(DEPTH)-1:0] rd_ptr;

  integer i;

//---------------- write logic -----------------

  // write data into memory
  always @(posedge clk, negedge rst_n) begin
  	if (!rst_n) begin
  		for (i=0; i<DEPTH; i=i+1) begin
  			mem[i] <= {WIDTH{1'b0}}
  		end
  	end
  	else begin
  		if (wr_en && !full) begin
  			mem[wr_ptr] <= wr_data;
  		end
  	end
  end

  //increase pointer
  always @(posedge clk or negedge rst_n) begin
  	if(!rst_n) begin
  	  wr_ptr <= {($clog2(DEPTH)){1'b0}};    //  wr_ptr <= '0
  	end
  	else begin
  		if (wr_en && !full) begin
  			wr_ptr <= wr_ptr + {($clog2(DEPTH)-1){1'b0},1'b1};  //  wr_ptr <= wr_ptr +1
  		end
  	end
  end

//---------------- read logic -----------------

  // read data from memory
  always @(posedge clk, negedge rst_n) begin
  	if (!rst_n) begin
  		rd_data <= {(WIDTH){1'b0}};    //  rd_data <= '0;
  	end
  	else begin
  		if (rd_en && !empty) begin
  			rd_data <= mem[rd_ptr];
  		end
  	end
  end

  //  increase read pointer
  always @(posedge clk, negedge rst_n) begin
  	if (!rst_n) begin
  		rd_ptr <= {($clog2(DEPTH)){1'b0}};
  	end
  	else begin
  		if (rd_en && !empty) begin
  			rd_ptr <= rd_ptr + {($clog2(DEPTH)-1){1'b0},1'b1};  //  rd_ptr <= rd_ptr +1
  		end
  	end
  end

//---------------- counter logic -----------------
  always @(posedge clk, negedge rst_n) begin
  	if (!rst_n) begin
  		cnt <= {($clog2(DEPTH)+1){1'b0}};
  	end
  	else begin
  		if ((wr_en && !full) && (rd_en && !empty)) cnt <= cnt;
  		else if ((wr_en && !full) && (!rd_en)) cnt <= cnt + {($clog2(DEPTH)){1'b0},1'b1}; 
  		else if ((rd_en && !empty)&& (!wr_en)) cnt <= cnt - {($clog2(DEPTH)){1'b0},1'b1}; 
  	end
  end

  //  full logic
  assign full = (cnt == DEPTH);
  //  empty logic
  assign empty = (cnt == 0);
endmodule