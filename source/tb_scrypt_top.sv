// $Id: $
// File name:   tb_hmac_sha256_32_84.sv
// Created:     12/4/2014
// Author:      Kyle Chynoweth
// Lab Section: 01
// Version:     1.0  Initial Design Entry
// Description: test bench for 32-bit key, 84-bit message block of hmac

`timescale 1ns / 10ps
module tb_scrypt_top ();
  
  localparam CLK_PERIOD = 10;
  
  reg tb_clk, enable_in, n_rst_in;
  reg[639:0] data_in;
  reg[255:0] data_out;
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
  scrypt_top DUT(.clk(tb_clk),.n_rst(n_rst_in),.enable(enable_in),.data(data_in),.hash(data_out),.hash_done(hash_done),
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
	  /*for(integer i=0;i<80;i=i+1) begin
	    data_in[8*(79-i) +: 8]=i;
    end*/
    data_in =    
    {//litecoin block #100000
      32'h01000000,
      256'hae178934851bfa0e83ccb6a3fc4bfddff3641e104b6c4680c31509074e699be2,
      256'hbd672d8d2199ef37a59678f92443083e3b85edef8b45c71759371f823bab59a9,
      32'h7126614f,
      32'h44d5001d,
      32'h45920180
    }; //output: 01796dae1f78a72dfb09356db6f027cd884ba0201e6365b72aa54b3b00000000
    
    
	  n_rst_in=0;
	  #(CLK_PERIOD*1.5);
	  n_rst_in=1;
	  enable_in=1;
	  #(CLK_PERIOD);
	  enable_in=0;
	  #(CLK_PERIOD*200000);
	  
    data_in =    
    {//dogecoin block #
      32'h02016200,//
      256'h241105e57493b4d0eebf072c5210728342e6b083a2f97f81464bd779b0a95a51,//
      256'h13d21756b72457c81da1356e9f34b3a58b5db2fd2d507e5ace9212020503e7f6,//
      32'h1ceb8c54,//
      32'h67d1041b,//
      32'h00000000 //
    }; //output: 9a9c5b425d1e387406c55ac6da0c73465c042afcc0d95a79af89cdf7b3ede3b0
    
    
	  n_rst_in=0;
	  #(CLK_PERIOD*1.5);
	  n_rst_in=1;
	  enable_in=1;
	  #(CLK_PERIOD);
	  enable_in=0;
  end
endmodule