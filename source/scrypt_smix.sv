// $Id: $
// File name:   scrypt_smix.sv
// Created:     12/2/2014
// Author:      Kyle Chynoweth
// Lab Section: 01
// Version:     1.0  Initial Design Entry
// Description: SMIX block for the scrypt algorithm

module scrypt_smix (
  input wire clk,
  input wire n_rst,
  input wire[1023:0] data,
  input wire enable,
  output reg[1023:0] hash,
  output reg hash_done
  );
  
endmodule