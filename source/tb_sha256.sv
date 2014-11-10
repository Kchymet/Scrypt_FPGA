// $Id: $
// File name:   tb_sha256_640.sv
// Created:     11/1/2014
// Author:      Kyle Chynoweth
// Lab Section: 01
// Version:     1.0  Initial Design Entry
// Description: SHA256 80-octet test bench

`timescale 1ns / 10ps
module tb_sha256();
  
  localparam CLK_PERIOD = 10;
  
  reg tb_clk, enable_in, n_rst_in;
  reg[511:0] data_in;
  reg[255:0] hash_in = { 32'h6a09e667,32'hbb67ae85,32'h3c6ef372,32'ha54ff53a,32'h510e527f,32'h9b05688c,32'h1f83d9ab,32'h5be0cd19 };
  reg[255:0] hash_out;
  reg hash_done_out;
  
  sha256 DUT(.clk(tb_clk),.n_rst(n_rst_in),.enable(enable_in),.data(data_in),.current_hash(hash_in),.hash(hash_out),.hash_done(hash_done));
  
  // Clock generation block
	always	begin
		tb_clk = 1'b0;
		#(CLK_PERIOD/2.0);
		tb_clk = 1'b1;
		#(CLK_PERIOD/2.0);
	end
	
	initial begin
	  enable_in=0;
	  n_rst_in=0;
	  data_in=512'b0;
	  data_in[511]=1;
	  @(negedge tb_clk);
	  n_rst_in=1;
	  enable_in=1;
	  #(CLK_PERIOD);
	  enable_in=0;
  end
  
endmodule