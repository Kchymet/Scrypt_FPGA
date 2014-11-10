// $Id: $
// File name:   sha256_extension.sv
// Created:     11/1/2014
// Author:      Kyle Chynoweth
// Lab Section: 01
// Version:     1.0  Initial Design Entry
// Description: SHA256 block extension algorithm

//written according to http://en.wikipedia.org/wiki/SHA-2
module sha256_extension(
    input wire[31:0] w2,w7,w15,w16,
    output wire[31:0] w
  );
  wire[31:0] s0,s1;
  
  assign s0 = {w15[6:0],w15[31:7]} ^ {w15[17:0],w15[31:18]} ^ {3'b000,w15[31:3]};
  assign s1 = {w2[16:0],w2[31:17]} ^ {w2[18:0],w2[31:19]} ^ {10'b0,w2[31:10]};
  assign w = w16 + s0 + w7 + s1;
  
endmodule