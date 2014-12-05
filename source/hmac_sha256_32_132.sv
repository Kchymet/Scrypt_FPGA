// $Id: $
// File name:   hmac_sha256_32.sv
// Created:     11/15/2014
// Author:      Kyle Chynoweth
// Lab Section: 01
// Version:     1.0  Initial Design Entry
// Description: Common module for all hmac_sha256_x blocks

module hmac_sha256_32_132(
  input wire clk,
  input wire n_rst,
  input wire[255:0] data, //key
  input wire[1055:0] msg,
  input wire enable,
  output wire[255:0] hash,
  output wire hash_done
  );
  
  typedef enum bit[2:0]{
    IDLE,
    IHASH1,
    IHASH2,
    IHASH3,
    IHASH4,
    OHASH1,
    OHASH2,
    DONE
  } State;
  
  State q, nextq;
  
  reg[255:0] hash_buffer;
  
  //input logic
  wire[511:0] padded_key;
  wire[511:0] o_key_pad, i_key_pad;
  reg[511:0] o_const, i_const;
  
  assign padded_key = {data, 256'b0};
  assign o_key_pad = o_const ^ padded_key;
  assign i_key_pad = i_const ^ padded_key;
  
  //xor const logic
  always_comb begin
    for(integer i=0; i<64; i=i+1) begin
      o_const[i*8 +: 8] = 8'h5c;
      i_const[i*8 +: 8] = 8'h36;
    end
  end
  
  //sha256 connection
  reg[255:0] sha_hash, sha_current_hash;
  reg[511:0] sha_data;
  reg sha_enable;
  wire sha_done;
  sha256 SHA (.clk(clk),.n_rst(n_rst),.enable(sha_enable),.data(sha_data),.current_hash(sha_current_hash),.hash(sha_hash),.hash_done(sha_done));
  
  //next state logic
  always_comb begin
    nextq=q;
    sha_enable=1;
    case(q)
      IDLE: begin sha_enable=0; if(enable) nextq=IHASH1; end
      IHASH1: if(sha_done) nextq=IHASH2;
      IHASH2: if(sha_done) nextq=IHASH3;
      IHASH3: if(sha_done) nextq=IHASH4;
      IHASH4: if(sha_done) nextq=OHASH1;
      OHASH1: if(sha_done) nextq=OHASH2;
      OHASH2: if(sha_done) nextq=DONE;
      DONE: begin sha_enable=0; nextq=IDLE; end
    endcase
  end
  
  //FF
  always_ff @(posedge clk, negedge n_rst) begin
    if(n_rst==0) begin
      q<=IDLE;
    end
    else begin
      q<=nextq;
    end
  end
  
  //sha256 data input mux/padder
  always_comb begin
    sha_data=0;
    case(q)
      IHASH1: begin
        sha_data = i_key_pad; //hash the inner padded key
      end
      IHASH2: begin
        sha_data = msg[1055:544]; //hash first 64 bytes of msg
      end
      IHASH3: begin
        sha_data = msg[543:32]; //hash second 64 bytes of msg
      end
      IHASH4: begin
        sha_data = {msg[31:0],1'b1,479'd1568}; //hash last 4 bytes and the sha padding
      end
      OHASH1: begin
        sha_data = o_key_pad; //hash the outter padded key
      end
      OHASH2: begin
        sha_data = {hash_buffer,1'b1,255'd768}; //hash the result of the ihash with sha padding
      end
    endcase
  end
  
  //sha256 current hash input mux
  always_comb begin
    //default hash value
    sha_current_hash={ 32'h6a09e667,32'hbb67ae85,32'h3c6ef372,32'ha54ff53a,32'h510e527f,32'h9b05688c,32'h1f83d9ab,32'h5be0cd19 };
    case(q)
      IHASH2: sha_current_hash = sha_hash;
      IHASH3: sha_current_hash = sha_hash;
      IHASH4: sha_current_hash = sha_hash;
      OHASH2: sha_current_hash = sha_hash;
    endcase
  end
  
  //output logic
  assign hash = sha_hash;
  assign hash_done = (q==DONE);
  
  //hash buffer
  always_ff @(posedge clk) begin
    hash_buffer <= hash_buffer;
    case(q)
      IHASH4: if(sha_done) hash_buffer <= sha_current_hash;
    endcase
  end
  
endmodule