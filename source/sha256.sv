// $Id: $
// File name:   80B_sha256.sv
// Created:     11/1/2014
// Author:      Kyle Chynoweth
// Lab Section: 01
// Version:     1.0  Initial Design Entry
// Description: SHA-256 core with 80-byte input

module sha256(
  input wire clk,
  input wire n_rst,
  input wire enable,
  input wire [511:0] data,
  input wire [255:0] current_hash,
  output reg [255:0] hash,
  output reg hash_done
  );
  typedef enum bit[2:0]{
    IDLE,
    INIT, //1 cycle
    COMPRESS, //runs for 16 cycles
    EXT_COMPRESS, //runs for 48 cycles
    POST, //1 cycle
    DONE //1 cycle
  } State;
  
  wire[2047:0] SHA256_K = {
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
  
  reg [6:0] round;
  reg [6:0] next_round;
  
  reg[31:0] w[63:0];
  reg[31:0] w_t, next_w_t;
  reg[31:0] next_w[63:0];
  reg[31:0] w2_i,w7_i,w15_i,w16_i; //extension block variables
  wire[31:0] k_i, w_i; //main block variables
  reg[31:0] a,b,c,d,e,f,g,h; //main block variables
  reg[31:0] a_o,b_o,c_o,d_o,e_o,f_o,g_o,h_o; //main block variables
  reg[31:0] next_a,next_b,next_c,next_d,next_e,next_f,next_g,next_h; //internal next value registers
  
  reg [255:0] next_hash;
  
  assign k_i = SHA256_K[(63-round)*32 +: 32];
  assign w_i = w[round];
  
  //partial next state logic for w
  sha256_extension EXT(.w2(w2_i),.w7(w7_i),.w15(w15_i),.w16(w16_i),.w(next_w_t));
  //next state logic for internal a-h
  sha256_main MAIN(.a(a),.b(b),.c(c),.d(d),.e(e),.f(f),.g(g),.h(h),
                   .a_o(a_o),.b_o(b_o),.c_o(c_o),.d_o(d_o),.e_o(e_o),.f_o(f_o),.g_o(g_o),.h_o(h_o),
                   .k(k_i),.w(w_i));

  //next state logic
  always_comb begin
    //state machine next state logic
    next_sha_state=IDLE;
    case(sha_state)
      IDLE: if(enable) begin next_sha_state=INIT; end
      INIT: next_sha_state=COMPRESS;
      COMPRESS: if(round==14) begin next_sha_state=EXT_COMPRESS; end else begin next_sha_state=COMPRESS; end
      EXT_COMPRESS: if(round==63) begin next_sha_state=POST; end else begin next_sha_state=EXT_COMPRESS; end
      POST: next_sha_state=DONE;
      DONE: if(enable) next_sha_state=INIT;
    endcase
  end
  
  //next_w logic
  always_comb begin
    next_w=w;
    case(sha_state)
      IDLE:
        for(integer i=0; i<64; i=i+1) begin
          next_w[i]=0;
        end
      INIT: begin
        for(integer i=0; i<16; i=i+1) begin
          next_w[15-i]=data[i*32 +: 32];
        end
        for(integer i=16; i<64; i=i+1) begin
          next_w[i]=0;
        end
      end
      EXT_COMPRESS: begin next_w[round+1]=next_w_t; end
    endcase
  end
  
  //next_a..next_h logic
  always_comb begin
    next_a=0; next_b=0; next_c=0; next_d=0; next_e=0; next_f=0; next_g=0; next_h=0;
    case(sha_state)
      INIT: begin
        next_a=current_hash[255:224];
        next_b=current_hash[223:192];
        next_c=current_hash[191:160];
        next_d=current_hash[159:128];
        next_e=current_hash[127:96];
        next_f=current_hash[95:64];
        next_g=current_hash[63:32];
        next_h=current_hash[31:0];
      end
      COMPRESS: begin
        next_a=a_o;
        next_b=b_o;
        next_c=c_o;
        next_d=d_o;
        next_e=e_o;
        next_f=f_o;
        next_g=g_o;
        next_h=h_o;
      end
      EXT_COMPRESS: begin
        next_a=a_o;
        next_b=b_o;
        next_c=c_o;
        next_d=d_o;
        next_e=e_o;
        next_f=f_o;
        next_g=g_o;
        next_h=h_o;
      end
    endcase
  end
  
  //next_hash logic
  always_comb begin
    next_hash=hash;
    case(sha_state)
      INIT: next_hash=current_hash;
      POST: next_hash={hash[255:224]+a, hash[223:192]+b, hash[191:160]+c, hash[159:128]+d, hash[127:96]+e, hash[95:64]+f, hash[63:32]+g, hash[31:0]+h};
    endcase
  end
  
  //next_round logic
  always_comb begin
    next_round=0;
    case(sha_state)
      COMPRESS: next_round=round+1;
      EXT_COMPRESS: begin if(round==63)next_round=1; else next_round=round+1; end
    endcase
  end
  
  //extension block inputs
  always_comb begin
    w15_i = w[round-15+1];
    w2_i = w[round-2+1];
    w7_i = w[round-7+1];
    w16_i = w[round-16+1];
  end
  
  //flip-flops
  always_ff @(posedge clk, negedge n_rst) begin
    if(n_rst==0) begin
      sha_state<=IDLE;
      round<=0;
    end
    else begin
      
      sha_state<=next_sha_state;
      w<=next_w;
      w_t<=next_w_t;
      hash<=next_hash;
      a<=next_a; b<=next_b; c<=next_c; d<=next_d; e<=next_e; f<=next_f; g<=next_g; h<=next_h;
      round<=next_round;
      for(integer i=0;i<64;i=i+1) begin
        w[i]<=next_w[i];
      end
    end
  end
  
  //output logic
  always_comb begin
    hash_done=0;
    case(sha_state)
      DONE: hash_done=1;
    endcase
  end

endmodule
