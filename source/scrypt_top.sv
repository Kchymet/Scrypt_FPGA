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
  output reg match_found,
  output reg hash_done
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
  wire[255:0] pbsecond_out;
  wire[1023:0] pbfirst_out, main_out;
  wire pbfirst_done, main_done, pbsecond_done;
  
  pbkdf2_80_80_128 PBFIRST (.clk(clk),.n_rst(n_rst),.pass(data),.salt(data),.enable(enable),.hash(pbfirst_out),.hash_done(pbfirst_done));
  scrypt_smix SCRYPT_MAIN (.clk(clk),.n_rst(n_rst),.data(pbfirst_out),.enable(pbfirst_done).hash(main_out),.hash_done(main_done));
  pbkdf2_80_128_32 PBSECOND (.clk(clk),.n_rst(n_rst),.pass(data_copy),.salt(main_out),.enable(main_done),.hash(pbsecond_out),.hash_done(pbsecond_done));
  
  //TODO output logic
  
endmodule