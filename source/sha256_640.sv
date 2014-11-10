// $Id: $
// File name:   80B_sha256.sv
// Created:     11/1/2014
// Author:      Kyle Chynoweth
// Lab Section: 01
// Version:     1.0  Initial Design Entry
// Description: SHA-256 core with 80-byte input

module sha256_640(
  input wire clk,
  input wire n_rst,
  input wire enable,
  input wire[639:0] data,
  output wire[255:0] hash,
  output reg hash_done
  );
  typedef enum bit[2:0]{
    IDLE,
    BLOCK1_INIT,
    BLOCK1,
    BLOCK2_INIT,
    BLOCK2,
    DONE
  } State;
  
  localparam SHA256_H = {
   32'h6a09e667,32'hbb67ae85,32'h3c6ef372,32'ha54ff53a,32'h510e527f,32'h9b05688c,32'h1f83d9ab,32'h5be0cd19
  };
  localparam SHA256_K = {
   32'h428a2f98, 32'h71374491, 32'hb5c0fbcf, 32'he9b5dba5, 32'h3956c25b, 32'h59f111f1, 32'h923f82a4, 32'hab1c5ed5,
   32'hd807aa98, 32'h12835b01, 32'h243185be, 32'h550c7dc3, 32'h72be5d74, 32'h80deb1fe, 32'h9bdc06a7, 32'hc19bf174,
   32'he49b69c1, 32'hefbe4786, 32'h0fc19dc6, 32'h240ca1cc, 32'h2de92c6f, 32'h4a7484aa, 32'h5cb0a9dc, 32'h76f988da,
   32'h983e5152, 32'ha831c66d, 32'hb00327c8, 32'hbf597fc7, 32'hc6e00bf3, 32'hd5a79147, 32'h06ca6351, 32'h14292967,
   32'h27b70a85, 32'h2e1b2138, 32'h4d2c6dfc, 32'h53380d13, 32'h650a7354, 32'h766a0abb, 32'h81c2c92e, 32'h92722c85,
   32'ha2bfe8a1, 32'ha81a664b, 32'hc24b8b70, 32'hc76c51a3, 32'hd192e819, 32'hd6990624, 32'hf40e3585, 32'h106aa070,
   32'h19a4c116, 32'h1e376c08, 32'h2748774c, 32'h34b0bcb5, 32'h391c0cb3, 32'h4ed8aa4a, 32'h5b9cca4f, 32'h682e6ff3,
   32'h748f82ee, 32'h78a5636f, 32'h84c87814, 32'h8cc70208, 32'h90befffa, 32'ha4506ceb, 32'hbef9a3f7, 32'hc67178f2
  };
  
  State sha_state, next_sha_state;
  
  reg [511:0] message1, next_message1;
  reg [127:0] message2, next_message2;
  
  reg [6:0] round;
  reg [6:0] next_round;
  
  reg[31:0] w[63:0];
  reg [31:0] h0,h1,h2,h3,h4,h5,h6,h7;
  reg [31:0] next_h0,next_h1,next_h2,next_h3,next_h4,next_h5,next_h6,next_h7;
  reg [31:0] w2_i,w7_i,w15_i,w16_i,w_o; //extension block variables
  wire [31:0] k_i, w_i; //main block variables
  reg [31:0] a_i,b_i,c_i,d_i,e_i,f_i,g_i,h_i; //main block variables
  reg [31:0] a_o,b_o,c_o,d_o,e_o,f_o,g_o,h_o; //main block variables
  reg [31:0] next_a,next_b,next_c,next_d,next_e,next_f,next_g,next_h; //internal next value registers
  
  assign k_i = SHA256_K[round];
  assign w_i = w[round];
  
  //partial next state logic for w
  sha256_extension EXT(.w2(w2_i),.w7(w7_i),.w15(w15_i),.w16(w16_i),.w(w_o));
  //next state logic for internal a-h
  sha256_main MAIN(.a(a_i),.b(b_i),.c(c_i),.d(d_i),.e(e_i),.f(f_i),.g(g_i),.h(h_i),
                   .a_o(a_o),.b_o(b_o),.c_o(c_o),.d_o(d_o),.e_o(e_o),.f_o(f_o),.g_o(g_o),.h_o(h_o),
                   .k(k_i),.w(w_i));
  
  //other next state logic
  always_comb begin
    //next sha_state
    next_sha_state = sha_state;
    case(sha_state)
      IDLE: if(enable) next_sha_state = BLOCK1_INIT;
      BLOCK1_INIT: begin
        next_sha_state = BLOCK1;
        //copy message into w[0:16]
        for(integer i=0; i<16; i=i+1) begin
          w[i]=message1[i*32 +: 32]; //TODO check this
        end
      end
      BLOCK1: if(round==63) next_sha_state = BLOCK2_INIT;
      BLOCK2_INIT: begin
        next_sha_state = BLOCK2;
        for(integer i=0; i<4; i=i+1) begin
          w[i]=message2[i*32 +: 32]; //TODO check this
        end
        w[4]=32'h8000; //1 and padding 0s
        for(integer i=0; i<14; i=i+1) begin
          w[i]=0;
        end
        //constants for message length (640 bits, 80 bytes)
        w[14]=32'h02;
        w[15]=32'h80;
      end
      BLOCK2: if(round==63) next_sha_state = DONE;
      DONE: begin
        next_sha_state = IDLE;        
      end
    endcase
    
    //next hash and round value
    if(sha_state == BLOCK1 || sha_state == BLOCK2) begin
      next_round = round+1; //increment round if currently hashing a block
      if(round==63) begin //if we finished the last round, update the hash value
        next_round = 0;
        next_h0=h0+a_o;
        next_h1=h1+b_o;
        next_h2=h2+c_o;
        next_h3=h3+d_o;
        next_h4=h4+e_o;
        next_h5=h5+f_o;
        next_h6=h6+g_o;
        next_h7=h7+h_o;
      end
    end
    else if(sha_state == BLOCK1_INIT) begin
      next_h0=SHA256_H[0];
      next_h1=SHA256_H[1];
      next_h2=SHA256_H[2];
      next_h3=SHA256_H[3];
      next_h4=SHA256_H[4];
      next_h5=SHA256_H[5];
      next_h6=SHA256_H[6];
      next_h7=SHA256_H[7];
    end
    
    next_a=a_o;
    next_b=b_o;
    next_c=c_o;
    next_d=d_o;
    next_e=e_o;
    next_f=f_o;
    next_g=g_o;
    next_h=h_o;
    if(sha_state == BLOCK1_INIT || sha_state == BLOCK2_INIT) begin
      next_a=h0;
      next_b=h1;
      next_c=h2;
      next_d=h3;
      next_e=h4;
      next_f=h5;
      next_g=h6;
      next_h=h7;
    end
  end
  
  always_ff @(posedge clk, negedge n_rst) begin
    if(n_rst==0) begin
      sha_state <= IDLE;
      round <= 0;
      h0<=0;h1<=0;h2<=0;h3<=0;h4<=0;h5<=0;h6<=0;h7<=0;
      a_i<=0;b_i<=0;c_i<=0;d_i<=0;e_i<=0;f_i<=0;g_i<=0;h_i<=0;
    end
    else begin
      sha_state <= next_sha_state;
      round <= next_round;
      h0<=next_h0;
      h1<=next_h1;
      h2<=next_h2;
      h3<=next_h3;
      h4<=next_h4;
      h5<=next_h5;
      h6<=next_h6;
      h7<=next_h7;
    end
  end
  
  //output logic
  always_comb begin
    hash_done=0;
    case(sha_state)
      BLOCK1: begin end
      BLOCK2: begin end
      DONE: hash_done=1;
    endcase
  end
  
  //final output
  assign hash={h0,h1,h2,h3,h4,h5,h6,h7};
endmodule
