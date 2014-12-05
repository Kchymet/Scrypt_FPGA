// $Id: $
// File name:   hmac_sha256_164.sv
// Created:     12/2/2014
// Author:      Kyle Chynoweth
// Lab Section: 01
// Version:     1.0  Initial Design Entry
// Description: Block for the 164B input version of HMAC

module hmac_sha256_164 (
  input wire clk,
  input wire n_rst,
  input wire[1311:0] data,
  input wire enable,
  output reg[255:0] hash,
  output reg hash_done
  );
  
  wire[255:0] hash1_out;
  wire key_done;
  hmac_sha256_keyhash KEYSHA (.clk(clk),.n_rst(n_rst),.data(data[1311:672]),.enable(enable),.hash(hash1_out),.hash_done(key_done));
  hmac_sha256_32_84 MAINSHA (.clk(clk),.n_rst(n_rst),.data(data[671:0]),.enable(enable),.hash(hash),.hash_done(hash_done));
  
endmodule