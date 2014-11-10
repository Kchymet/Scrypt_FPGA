// $Id: $
// File name:   sha256_main.sv
// Created:     11/1/2014
// Author:      Kyle Chynoweth
// Lab Section: 01
// Version:     1.0  Initial Design Entry
// Description: SHA256 main compression algorithm

//written according to http://en.wikipedia.org/wiki/SHA-2
module sha256_main(
    input wire[31:0] a,b,c,d,e,f,g,h,
    input wire[31:0] k,w,
    output wire[31:0] a_o,b_o,c_o,d_o,e_o,f_o,g_o,h_o
  );
  wire[31:0] s0,s1,tmp1,tmp2,maj,ch;

  assign s1 = {e[5:0],e[31:6]} ^ {e[10:0],e[31:11]} ^ {e[24:0],e[31:25]};
  assign ch = (e & f) ^ ((~e) & g);
  assign tmp1 = h + s1 + ch + k + w;
  assign s0 = {a[1:0],a[31:2]} ^ {a[12:0],a[31:13]} ^ {a[21:0],a[31:22]};
  assign maj = (a & b) ^ (a & c) ^ (b & c);
  assign tmp2 = s0 + maj;
  
  assign h_o = g;
  assign g_o = f;
  assign f_o = e;
  assign e_o = d + tmp1;
  assign d_o = c;
  assign c_o = b;
  assign b_o = a;
  assign a_o = tmp1 + tmp2;
  
endmodule