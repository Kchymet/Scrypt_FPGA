// $Id: $
// File name:   pbkdf2_80_80_128.sv
// Created:     12/2/2014
// Author:      Kyle Chynoweth
// Lab Section: 01
// Version:     1.0  Initial Design Entry
// Description: First iteration of PBKDF2 in the scrypt algorithm

module pbkdf2_80_80_128 (
  input wire clk,
  input wire n_rst,
  input wire[639:0] pass,
  input wire[639:0] salt,
  input wire enable,
  output reg[1023:0] hash,
  output reg hash_done
  );
  
  //hmac connections for i=1..4 (1-indexed)
  hmac_sha256_164 HMAC0 (.data({pass,salt,32'b1}),.enable(enable),.hash(hash),.hash_done(hash_done));
  hmac_sha256_164 HMAC1 (.data({pass,salt,32'b2}),.enable(enable),.hash(hash),.hash_done(hash_done));
  hmac_sha256_164 HMAC2 (.data({pass,salt,32'b3}),.enable(enable),.hash(hash),.hash_done(hash_done));
  hmac_sha256_164 HMAC3 (.data({pass,salt,32'b4}),.enable(enable),.hash(hash),.hash_done(hash_done));
  
endmodule