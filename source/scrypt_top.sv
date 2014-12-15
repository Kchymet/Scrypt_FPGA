// $Id: $
// File name:   scrypt_top.sv
// Created:     12/2/2014
// Author:      Kyle Chynoweth
// Lab Section: 01
// Version:     1.0  Initial Design Entry
// Description: Top-level block for the scrypt algorithm

module scrypt_top (
  input wire clk,
  input wire n_rst,
  input wire[639:0] data,
  input wire enable,
  output reg[31:0] nonce,
  output reg[255:0] hash,
  output reg hash_done,
  
  //SRAM connections, not in real design, but can't fabricate SRAM
  output reg scratch_read,
  output reg scratch_write,
  output reg[16:0] scratch_addr,
  output reg[1023:0] scratch_in,
  input reg[1023:0] scratch_out
  );
  
  //data copy
  reg[639:0] data_copy;
  
  always_ff @(posedge clk, negedge n_rst) begin
    if(n_rst==0) begin end
    else begin
      if(enable) begin data_copy<=data; end
    end
  end
  
  //internal variables  
  //wire[255:0] pbsecond_out;
  wire[1023:0] pbfirst_out, main_out;
  reg[1023:0] main_in, pbsecond_in;
  wire pbfirst_done, main_done, pbsecond_done;
  
  pbkdf2_80_80_128 PBFIRST (.clk(clk),.n_rst(n_rst),.pass(data),.salt(data),.enable(enable),.hash(pbfirst_out),.hash_done(pbfirst_done));
  scrypt_smix SCRYPT_MAIN (.clk(clk),.n_rst(n_rst),.data(main_in),.enable(pbfirst_done),.hash(main_out),.hash_done(main_done),
    //SRAM connections
    .scratch_read(scratch_read),.scratch_write(scratch_write),.scratch_addr(scratch_addr),.scratch_in(scratch_in),.scratch_out(scratch_out));
  pbkdf2_80_128_32 PBSECOND (.clk(clk),.n_rst(n_rst),.pass(data_copy),.salt(pbsecond_in),.enable(main_done),.hash(hash),.hash_done(pbsecond_done));

  //assign match_found = hash_done & (pbsecond_out < data_copy[63:32]); //todo treat data as little-endian?
  assign hash_done = pbsecond_done;

  always_comb begin //convert endianness for smix
    for(integer i=0;i<32; i=i+1) begin
      main_in[32*(31-i) +: 32] = {pbfirst_out[32*(31-i) +: 8],pbfirst_out[32*(31-i)+8 +: 8],pbfirst_out[32*(31-i)+16 +: 8],pbfirst_out[32*(31-i)+24 +: 8]};
      pbsecond_in[32*(31-i) +: 32] = {main_out[32*(31-i) +: 8],main_out[32*(31-i)+8 +: 8],main_out[32*(31-i)+16 +: 8],main_out[32*(31-i)+24 +: 8]};
    end
  end
  
endmodule