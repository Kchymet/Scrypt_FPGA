// $Id: $
// File name:   hmac_sha256_keyhash.sv
// Created:     12/2/2014
// Author:      Kyle Chynoweth
// Lab Section: 01
// Version:     1.0  Initial Design Entry
// Description: common block for hmac key hash portion of hmac

module hmac_sha256_keyhash (
  input wire clk,
  input wire n_rst,
  input wire[639:0] data,
  input wire enable,
  output wire[255:0] hash,
  output reg hash_done
  );
  
  typedef enum bit[1:0]{
    IDLE,
    FIRST,
    SECOND,
    DONE
  } State;

  //sha connection variables
  reg[511:0] sha_data;
  reg sha_enable;
  wire[255:0] sha_hash_out;
  wire sha_hash_done;
  reg[255:0] current_hash;
  assign hash = sha_hash_out;
    
  //state logic
  State q, nextq;
  always_comb begin
    nextq=q;
    hash_done=0;
    case(q)
      IDLE: if(enable) nextq=FIRST;
      FIRST: if(sha_hash_done) nextq=SECOND;
      SECOND: if(sha_hash_done) nextq=DONE;
      DONE: begin nextq=IDLE; hash_done=1; end
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
  
  //sha connection
  sha256 SHA (.clk(clk),.n_rst(n_rst),.data(sha_data),.enable(sha_enable),.current_hash(current_hash),.hash(sha_hash_out),.hash_done(sha_hash_done));

  always_comb begin
    sha_data=0;
    sha_enable=1;
    case(q)
      IDLE: sha_enable=0;
      FIRST: begin
        sha_data = data[639:128]; //hash first 64B of key
        current_hash = { 32'h6a09e667,32'hbb67ae85,32'h3c6ef372,32'ha54ff53a,32'h510e527f,32'h9b05688c,32'h1f83d9ab,32'h5be0cd19 };
      end
      SECOND: begin
        sha_data = {data[127:0],1'b1,383'd640}; //hash 16B of key and sha padding
        current_hash = sha_hash_out;
        if(sha_hash_done) sha_enable=0;
      end
      DONE: sha_enable=0;
    endcase
  end
  
endmodule