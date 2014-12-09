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
  output reg hash_done,
  
  //SRAM connections, not in real design, but can't fabricate SRAM
  output reg scratch_read,
  output reg scratch_write,
  output reg[16:0] scratch_addr,
  output reg[1023:0] scratch_in,
  input reg[1023:0] scratch_out
  );
  
  typedef enum bit[2:0]{
    IDLE,
    FIRST,
    SWITCH,
    SECOND,
    DONE
  } State;

  State q, nextq;
  integer count, nextcount;
  
  reg[1023:0] X, nextX;
  
  //blockmix connections
  reg[1023:0] bmix_data, bmix_out;
  reg bmix_enable, bmix_done;
  scrypt_blockmix BMIX (.clk(clk),.n_rst(n_rst),.data(bmix_data),.enable(bmix_enable),.hash_out(bmix_out),.hash_done(bmix_done));
  
  //connection and next-state logic
  always_comb begin
    hash_done=0;
    hash=X;
    nextX=X;
    nextq=q;
    nextcount=count;
    bmix_enable=1;
    scratch_addr=0;
    scratch_read=0;
    scratch_write=0;
    case(q)
      IDLE: begin nextX=data; bmix_enable=0; nextcount=0; if(enable) nextq=FIRST; end
      FIRST: begin
        scratch_addr=128*count;
        bmix_data=X;
        scratch_in=X;
        scratch_write=1;
        if(bmix_done) begin nextcount=count+1; bmix_enable=0; nextX=bmix_out; scratch_write=0; end
        if(nextcount==1024) begin nextq=SWITCH; nextcount=0; end
      end
      SWITCH: begin
        bmix_enable=0;
        scratch_addr=(X[(31-16)*32 +:32] & 10'd1023)*128; //integrify treats X as a little-endian integer modulus 1024, then x128 for word position
        scratch_read=1;
        bmix_data = X ^ scratch_out;
        nextq=SECOND;
      end
      SECOND: begin
        scratch_addr=(X[(31-16)*32 +:32] & 10'd1023)*128; //integrify treats X as a little-endian integer modulus 1024, then x128 for word position
        scratch_read=1;
        bmix_data = X ^ scratch_out;
        if(bmix_done) begin nextcount=count+1; bmix_enable=0; nextX=bmix_out; end
        if(nextcount==1024) begin nextq=DONE; nextcount=0; end
      end
      DONE: begin
        hash_done=1;
        bmix_enable=0;
        nextcount=0;
        nextq=IDLE;
      end
    endcase
  end
  
  //flipflops
  always_ff @(posedge clk, negedge n_rst) begin
    if(n_rst==0) begin
      q<=IDLE;
      count<=0;
    end
    else begin
      q<=nextq;
      X<=nextX;
      count<=nextcount;
    end
  end
  
endmodule