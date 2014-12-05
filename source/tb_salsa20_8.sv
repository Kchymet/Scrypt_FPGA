// $Id: $
// File name:   tb_salsa20_8.sv
// Created:     12/3/2014
// Author:      Kyle Chynoweth
// Lab Section: 01
// Version:     1.0  Initial Design Entry
// Description: test bench for salsa20_8

`timescale 1ns / 10ps
module tb_salsa20_8 ();
  
  localparam CLK_PERIOD = 10;
  
  reg tb_clk, enable_in, n_rst_in;
  reg[511:0] data_in;
  reg[511:0] data_out;
  reg hash_done;  
  
  salsa20_8 DUT(.clk(tb_clk),.n_rst(n_rst_in),.enable(enable_in),.data(data_in),.data_out(data_out),.hash_done(hash_done));
  
  // Clock generation block
	always	begin
		tb_clk = 1'b0;
		#(CLK_PERIOD/2.0);
		tb_clk = 1'b1;
		#(CLK_PERIOD/2.0);
	end
	
	initial begin
    for(integer i=15;i>=0;i=i-1) begin
      data_in[32*i +: 32] = i;
    end
	  enable_in = 0;
	  
	  //reset
	  n_rst_in = 0;
	  #(1.5*CLK_PERIOD);
	  n_rst_in = 1;
	  
	  //enable
	  enable_in = 1;
	  #(CLK_PERIOD);
	  enable_in=0;
  end
endmodule