// $Id: $
// File name:   pbkdf2_80_128_32.sv
// Created:     12/2/2014
// Author:      Kyle Chynoweth
// Lab Section: 01
// Version:     1.0  Initial Design Entry
// Description: Second iteration of PBKDF2 for the scrypt algorithm

module pbkdf2_80_128_32 (
  input wire clk,
  input wire n_rst,
  input wire[639:0] pass,
  input wire[1023:0] salt,
  input wire enable,
  output reg[1023:0] hash,
  output reg hash_done
  );
  
  hmac_sha256_212 HMAC0 (.data({pass,salt,32'b1}),.enable(enable),.hash(hash),.hash_done(hash_done));
  
endmodule