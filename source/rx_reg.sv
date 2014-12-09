// $Id: $
// File name:   rx_reg.sv
// Created:     12/3/2014
// Author:      Eric Schrock
// Lab Section: 337-01
// Version:     1.0  Initial Design Entry
// Description: Register to hold and decode bytes received through the I2C Rx

module rx_reg (
  input wire clk,
  input wire n_rst,
  input wire load_rx,
  input wire [7:0] rx_data,
  output reg [7:0] command,
  output reg [7:0] rx_out
);


always_ff @ (posedge clk) begin : RX_DATA_REG
  if(load_rx == 1'b1) begin
    rx_out <= rx_data;
  end
  else begin
    rx_out <= rx_out;
  end
end


always_comb begin : DECODE_COMMAND
  command <= rx_out;
end






endmodule