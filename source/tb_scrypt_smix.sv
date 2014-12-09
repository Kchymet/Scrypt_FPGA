// $Id: $
// File name:   tb_hmac_sha256_32_84.sv
// Created:     12/4/2014
// Author:      Kyle Chynoweth
// Lab Section: 01
// Version:     1.0  Initial Design Entry
// Description: test bench for 32-bit key, 84-bit message block of hmac

`timescale 1ns / 10ps
module tb_scrypt_smix ();
  
  localparam CLK_PERIOD = 10;
  
  reg tb_clk, enable_in, n_rst_in;
  reg[1023:0] data_in, data_out;
  reg hash_done;

  reg r_enable, w_enable;
  reg[16:0] sram_addr;
  reg[1023:0] r_data, w_data;  
  on_chip_sram_wrapper #(.W_ADDR_SIZE_BITS(17),.W_WORD_SIZE_BYTES(1),.W_DATA_SIZE_WORDS(128)) SRAM (
    .read_enable(r_enable),
    .write_enable(w_enable),
    .address(sram_addr),
    .read_data(r_data),
    .write_data(w_data)
  );
  scrypt_smix DUT(.clk(tb_clk),.n_rst(n_rst_in),.enable(enable_in),.data(data_in),.hash(data_out),.hash_done(hash_done),
    //SRAM connections
    .scratch_read(r_enable),
    .scratch_write(w_enable),
    .scratch_addr(sram_addr),
    .scratch_in(w_data),
    .scratch_out(r_data));
  
  // Clock generation block
	always	begin
		tb_clk = 1'b0;
		#(CLK_PERIOD/2.0);
		tb_clk = 1'b1;
		#(CLK_PERIOD/2.0);
	end
	
	initial begin
	  enable_in=0;
	  for(integer i=0;i<32;i=i+1) begin
	    data_in[32*(31-i) +: 32]=i;
	  end
	  n_rst_in=0;
	  #(CLK_PERIOD*1.5);
	  n_rst_in=1;
	  enable_in=1;
	  #(CLK_PERIOD);
	  enable_in=0;
  end
endmodule