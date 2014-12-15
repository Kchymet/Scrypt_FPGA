// $Id: $
// File name:   next_nonce_byte.sv
// Created:     12/2/2014
// Author:      Eric Schrock
// Lab Section: 337-01
// Version:     1.0  Initial Design Entry
// Description: Provides the next byte of the nonce to the Tx_SR

module next_nonce_byte (
  input wire clk,
  input wire n_rst,
  input wire nonce_ready,
  input wire inc_data,
  input wire [255:0] nonce, //port still named nonce, but actually contains the hash to output
  output reg valid_nonce,
  output reg [7:0] read_data
);

/*

Outputs one byte of hash at a time starting with the most significant byte.
Output freezes at last byte until nonce_ready is toggled (also causing the new nonce to be loaded)
valid_nonce goes high when nonce_ready goes high and remains high until the nonce is sent

*/


reg [255:0] nonce_reg;
reg [4:0] data_state;


always_ff @ (posedge clk) begin : NONCE_REG
  if(1'b1 == nonce_ready) begin
    nonce_reg <= nonce;
  end
  else begin
    nonce_reg <= nonce_reg;
  end  
end


always_comb begin : NONCE_MUX //this got a bit messy, but copypasta is easy
  if(data_state == 5'd0) begin
    read_data <= nonce_reg[7:0];
  end
  else if(data_state == 5'd1) begin
    read_data <= nonce_reg[15:8];
  end
  else if(data_state == 5'd2) begin
    read_data <= nonce_reg[23:16];
  end
  else if(data_state == 5'd3) begin
    read_data <= nonce_reg[31:24];
  end
  else if(data_state == 5'd4) begin
    read_data <= nonce_reg[39:32];
  end
  else if(data_state == 5'd5) begin
    read_data <= nonce_reg[47:40];
  end
  else if(data_state == 5'd6) begin
    read_data <= nonce_reg[55:48];
  end
  else if(data_state == 5'd7) begin
    read_data <= nonce_reg[63:56];
  end
  else if(data_state == 5'd8) begin
    read_data <= nonce_reg[71:64];
  end
  else if(data_state == 5'd9) begin
    read_data <= nonce_reg[79:72];
  end
  else if(data_state == 5'd10) begin
    read_data <= nonce_reg[87:80];
  end
  else if(data_state == 5'd11) begin
    read_data <= nonce_reg[95:88];
  end
  else if(data_state == 5'd12) begin
    read_data <= nonce_reg[103:96];
  end
  else if(data_state == 5'd13) begin
    read_data <= nonce_reg[111:104];
  end
  else if(data_state == 5'd14) begin
    read_data <= nonce_reg[119:112];
  end
  else if(data_state == 5'd15) begin
    read_data <= nonce_reg[127:120];
  end
  else if(data_state == 5'd16) begin
    read_data <= nonce_reg[135:128];
  end
  else if(data_state == 5'd17) begin
    read_data <= nonce_reg[143:136];
  end
  else if(data_state == 5'd18) begin
    read_data <= nonce_reg[151:144];
  end
  else if(data_state == 5'd19) begin
    read_data <= nonce_reg[159:152];
  end
  else if(data_state == 5'd20) begin
    read_data <= nonce_reg[167:160];
  end
  else if(data_state == 5'd21) begin
    read_data <= nonce_reg[175:168];
  end
  else if(data_state == 5'd22) begin
    read_data <= nonce_reg[183:176];
  end
  else if(data_state == 5'd23) begin
    read_data <= nonce_reg[191:184];
  end
  else if(data_state == 5'd24) begin
    read_data <= nonce_reg[199:192];
  end
  else if(data_state == 5'd25) begin
    read_data <= nonce_reg[207:200];
  end
  else if(data_state == 5'd26) begin
    read_data <= nonce_reg[215:208];
  end
  else if(data_state == 5'd27) begin
    read_data <= nonce_reg[223:216];
  end
  else if(data_state == 5'd28) begin
    read_data <= nonce_reg[231:224];
  end
  else if(data_state == 5'd29) begin
    read_data <= nonce_reg[239:232];
  end
  else if(data_state == 5'd30) begin
    read_data <= nonce_reg[247:240];
  end
  else if(data_state == 5'd31) begin
    read_data <= nonce_reg[255:248];
  end
end


always_ff @ (posedge clk, negedge n_rst) begin : VALID_NONCE
  if(1'b0 == n_rst) begin
    valid_nonce <= 1'b0;
  end
  else if(nonce_ready == 1'b1) begin
    valid_nonce <= 1'b1;
  end
  else if(data_state == 5'b11111) begin//is this correct? the last state sets valid_nonce to 0
    valid_nonce <= 1'b0;
  end
  else begin
    valid_nonce <= valid_nonce;
  end
end


always_ff @ (posedge clk, negedge n_rst) begin : DATA_STATE
  if(1'b0 == n_rst) begin
    data_state <= 0;
  end
  else if(nonce_ready == 1'b1) begin
    data_state <= 0;
  end
  else if((inc_data == 1'b1) && (valid_nonce == 1'b1)) begin    
    data_state <= data_state+1; //increment state counter
    /*if(data_state == 2'b00 ) begin
      data_state <= 2'b01;
    end
    else if(data_state == 2'b01) begin
      data_state <= 2'b10;
    end
    else if(data_state == 2'b10) begin
      data_state <= 2'b11;
    end
    else begin
      data_state <= 2'b00;
    end*/
  end
  else begin
    data_state <= data_state;
  end 
end


endmodule