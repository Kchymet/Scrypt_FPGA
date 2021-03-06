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
  reg[255:0] hash_in;
  reg[255:0] hash_out;
  reg hash_done_out;
  
  sha256 DUT(.clk(tb_clk),.n_rst(n_rst_in),.enable(enable_in),.data(data_in),.current_hash(hash_in),.hash(hash_out),.hash_done(hash_done_out));
  
  // Clock generation block
	always	begin
		tb_clk = 1'b0;
		#(CLK_PERIOD/2.0);
		tb_clk = 1'b1;
		#(CLK_PERIOD/2.0);
	end
	
	initial begin
	  hash_in = { 32'h6a09e667,32'hbb67ae85,32'h3c6ef372,32'ha54ff53a,32'h510e527f,32'h9b05688c,32'h1f83d9ab,32'h5be0cd19 };
	  enable_in=0;
	  n_rst_in=0;
	  
	  data_in=512'b0;
	  data_in[511]=1;
	  @(negedge tb_clk);
	  n_rst_in=1;
	  enable_in=1;
	  #(CLK_PERIOD);
	  enable_in=0;
	  #(CLK_PERIOD*66);
	  @(negedge tb_clk);
	  $info("expected: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855");
	  $info("hash_blank_string: %h",hash_out);
	  
	  #(CLK_PERIOD*5); //wait a bit before next test
	  
	  data_in=512'b0;
	  data_in[511:488]=24'h414243;
	  data_in[487]=1'b1;
	  data_in[63:0]=64'd24;
 	  @(negedge tb_clk);
 	  n_rst_in=1;
	  enable_in=1;
	  #(CLK_PERIOD);
	  enable_in=0;
	  #(CLK_PERIOD*66);
	  @(negedge tb_clk);
	  $info("expected: b5d4045c3f466fa91fe2cc6abe79232a1a57cdf104f7a26e716e0a1e2789df78");
	  $info("hash_ABC: %h",hash_out);
	  
 	  #(CLK_PERIOD*5); //wait a bit before next test
	  
	  data_in=512'b0;
	  data_in[511:488]=24'h616263;
	  data_in[487]=1'b1;
	  data_in[63:0]=64'd24;
 	  @(negedge tb_clk);
 	  n_rst_in=1;
	  enable_in=1;
	  #(CLK_PERIOD);
	  enable_in=0;
	  #(CLK_PERIOD*66);
	  @(negedge tb_clk);
	  $info("expected: ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad");
	  $info("hash_abc: %h",hash_out);
	  
 	  #(CLK_PERIOD*5); //wait a bit before next test
	  
	  for(integer i=0;i<64;i=i+1) begin
	    data_in[8*i +: 8] = 8'h41;
    end
 	  @(negedge tb_clk);
 	  n_rst_in=1;
	  enable_in=1;
	  #(CLK_PERIOD);
	  enable_in=0;
	  #(CLK_PERIOD*66);
 	  enable_in=1;
	  hash_in=hash_out;
	  data_in=512'b0;
	  data_in[511]=1;
	  data_in[63:0]=64'd512;
	  $info("hash_2block_first: %h",hash_out);
	  #(CLK_PERIOD);
	  enable_in=0;
	  #(CLK_PERIOD);
	  hash_in = { 32'h6a09e667,32'hbb67ae85,32'h3c6ef372,32'ha54ff53a,32'h510e527f,32'h9b05688c,32'h1f83d9ab,32'h5be0cd19 };
 	  #(CLK_PERIOD*65);
	  @(negedge tb_clk);
	  $info("expected: d53eda7a637c99cc7fb566d96e9fa109bf15c478410a3f5eb4d4c4e26cd081f6");
	  $info("hash_2block_second: %h",hash_out);
  end
  
endmodule