// $Id: $
// File name:   scrypt_blockmix.sv
// Created:     12/2/2014
// Author:      Kyle Chynoweth
// Lab Section: 01
// Version:     1.0  Initial Design Entry
// Description: Blockmix block for the scrypt algorithm

module scrypt_blockmix (
  input wire clk,
  input wire n_rst,
  input wire[1023:0] data,
  input wire enable,
  output reg[1023:0] hash_out,
  output reg hash_done
  );
  
typedef enum bit[2:0]{
    IDLE,
    INIT,
    H_TOP,
    H_BOT,
    DONE
} State;

//internal variables and state
State q, nextq;

//internal register for the block
reg[1023:0] next_hash_out;
reg[1023:0] B, nextB;
reg[511:0] X, nextX;

//connection to salsa
reg[511:0] salsa_data_in;
wire[511:0] salsa_data_out;
reg salsa_enable,salsa_done;
salsa20_8 SALSA (.clk(clk),.n_rst(n_rst),.data(salsa_data_in),.enable(salsa_enable),.data_out(salsa_data_out),.hash_done(salsa_done));

//next state logic
always_comb begin
  nextq=IDLE;
  nextB=B;
  nextX=X;
  salsa_data_in=0; //default to make simulator happy
  salsa_enable=0;
  next_hash_out=hash_out;
  case(q)
    IDLE: begin
      nextB=data;
      if(enable) begin nextq=INIT; end
    end
    INIT: begin
      nextq=H_TOP;
      nextX=B[511:0];
    end
    H_TOP: begin
      salsa_data_in = B[1023:512] ^ X;
      salsa_enable=1;
      if(salsa_done) begin
        nextX=salsa_data_out;
        next_hash_out[1023:512]=salsa_data_out;
        nextq=H_BOT;
      end
    end
    H_BOT: begin
      salsa_data_in = B[511:0];
      salsa_enable=1;
      if(salsa_done) begin
        nextX=salsa_data_out;
        next_hash_out[511:0]=salsa_data_out;
        nextq=DONE;
      end
    end
    DONE: begin nextq=IDLE; end
  endcase
end

//ffs
always_ff @(posedge clk, negedge n_rst) begin
  if(n_rst==0) begin
    q<=IDLE;
  end
  else begin
    X <= nextX;
    q <= nextq;
    B <= nextB;
    hash_out <= next_hash_out;
  end
end

//output logic
always_comb begin
  hash_done=0;
  case(q)
    DONE: hash_done=1;
  endcase
end
  
endmodule