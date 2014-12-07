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
  
  typedef enum bit[1:0]{
    IDLE,
    FIRST,
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
  
  //scratchpad connections
  reg scratch_read, scratch_write;
  reg[16:0] scratch_addr;
  reg[1023:0] scratch_in, scratch_out;
  scratchpad MEM (.r_enable(scratch_read),.w_enable(scratch_write),.addr(scratch_addr),.r_data(scratch_out),.w_data(scratch_in));
  
  //connection and next-state logic
  always_comb begin
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
        if(count==1024) begin nextq=SECOND; nextcount=0; end
      end
      SECOND: begin
        scratch_addr=(X[(31-16)*32 +:32] & 10'd1023)*128; //integrify treats X as a little-endian integer modulus 1024, then x128 for word position
        $info("X[16]=%h, and: %h, mul: %h",X[(31-16)*32 +:32],X[(31-16)*32 +:32]&1023,(X[(31-16)*32 +:32]&1023)*128);
        $info("X = %h",X);
        scratch_read=1;
        bmix_data = X ^ scratch_out;
        if(bmix_done) begin nextcount=count+1; bmix_enable=0; nextX=bmix_out; end
        if(count==1023) begin nextq=DONE; nextcount=0; end
      end
      DONE: begin
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