// -------------------------------------------
//
//Module name: tb_sync_fifo
//Author: Yechengnuo Zhang
//Date: 16 Aug 2022
//Description: Testbench for Syncronize FIFO 
//Revision: v1.0
//
// -------------------------------------------

'timescale lns/lps

'define DATA_WIDTH 8 
'define FIFO DEPTH 8

module tb_sync_fifo();

  //declare the variables 
  reg clk, rst_n;
  reg wr_en, rd_en; 
  reg [7:0] wr_data; 
  wire [7:0] rd_data; 
  wire empty, full; 
  reg [7:0] tempdata;

  //instantiate the test block 
  sync_fifo sync_fifo_test(
    .clk(clk),
    .rst_n(rst_n), 
    .wr_data(wr_data),
    .wr_en(wr_en), 
    .rd_en(rd_en), 
    .rd_data(rd_data),
    .full(full), 
    .empty(empty) 
    );

  //create clock signal 
  always #10 clk = —clk;

  initial begin
  //initialize the input signals
    clk = 0;
    rst_n = 0; 
    wr_en = 0; 
    rd_en = 0; 
    wr_data = 0; 
    tempdata = 0;
    #15;
    rst_n = 1;

//test the fifo
  push(1);

  fork
    push(2);
    pop(tempdata);
  join

  push(10);
  push(20);
  push(30);
  push(40);
  push(50);
  push(60);
  push(70);
  push(80);
  push(90);
  push(100);
  push(110);
  push(120);
  push(130);
  pop(tempdata); 
  pop(tempdata); 
  pop(tempdata); 
  pop(tempdata); 
  pop(tempdata); 
  pop(tempdata); 
  push(140);
  pop(tempdata); 
  push(tempdata); 
  pop(tempdata); 
  pop(tempdata); 
  pop(tempdata); 
  pop(tempdata); 
  pop(tempdata); 
  pop(tempdata); 
  pop(tempdata); 
  pop(tempdata); 
  pop(tempdata); 
  pop(tempdata); 
  pop(tempdata); 
  push(5);
  pop(tempdata);
  $finish();
end

//output the wave file 
initial
begin
  $fsdbDumpfile("sync_fifo.fsdb"); 
  $fsdbDumpvars;
end

  //output the wave file
  initial
  begin
     $fsdbDumpfile("sync_fifo.fsdb"); 
     $fsdbDumpvars;
  end

  //define push and pop task 
  task push(input [7:0] data);
     if (full)
       $display("---Cannot push %d: Buffer full---",data); 
     else begin
       $display("Push"„data);
       wr_data = data; 
       wr_en = 1;
       @(posedge clk); 
       #5 wr_en = 0;
     end
  endtask

  task pop(output[7:0] data); 
     if (empty)
       $display("---Cannot pop: Buffer empty---");
     else begin
       rd_en = 1;
       @(posedge clk); 
       #3 rd_en = 0; 
       data = rd_data;
       $display(" Data Poped:"„data);
     end
  endtask

endmodule