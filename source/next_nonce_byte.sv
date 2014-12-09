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
  input wire [31:0] nonce,
  output reg valid_nonce,
  output reg [7:0] read_data
);

/*

Outputs one byte of nonce at a time starting with the most significant byte.
Output freezes at last byte until nonce_ready is toggled (also causing the new nonce to be loaded)
valid_nonce goes high when nonce_ready goes high and remains high until the nonce is sent

*/


reg [31:0] nonce_reg;
reg [1:0] data_state;


always_ff @ (posedge clk) begin : NONCE_REG
  if(1'b1 == nonce_ready) begin
    nonce_reg <= nonce;
  end
  else begin
    nonce_reg <= nonce_reg;
  end  
end


always_comb begin : NONCE_MUX
  if(data_state == 2'b00) begin
    read_data <= nonce_reg[7:0];
  end
  else if(data_state == 2'b01) begin
    read_data <= nonce_reg[15:8];
  end
  else if(data_state == 2'b10) begin
    read_data <= nonce_reg[23:16];
  end
  else begin
    read_data <= nonce_reg[31:24];
  end
end


always_ff @ (posedge clk, negedge n_rst) begin : VALID_NONCE
  if(1'b0 == n_rst) begin
    valid_nonce <= 1'b0;
  end
  else if(nonce_ready == 1'b1) begin
    valid_nonce <= 1'b1;
  end
  else if(data_state == 2'b11) begin
    valid_nonce <= 1'b0;
  end
  else begin
    valid_nonce <= valid_nonce;
  end
end


always_ff @ (posedge clk, negedge n_rst) begin : DATA_STATE
  if(1'b0 == n_rst) begin
    data_state <= 2'b00;
  end
  else if(nonce_ready == 1'b1) begin
    data_state <= 2'b00;
  end
  else if((inc_data == 1'b1) && (valid_nonce == 1'b1)) begin    
    if(data_state == 2'b00 ) begin
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
    end
  end
  else begin
    data_state <= data_state;
  end 
end


endmodule