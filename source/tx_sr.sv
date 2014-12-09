// $Id: $
// File name:   tx_sr.sv
// Created:     10/18/2014
// Author:      Eric Schrock
// Lab Section: 337-01
// Version:     1.0  Initial Design Entry
// Description: TX shift register

module tx_sr (
  input wire clk,
  input wire n_rst,
  output wire tx_out,
  input wire falling_edge_found,
  input wire tx_enable,
  input wire [7:0] tx_data,
  input wire load_data
);

wire shift_enable;

assign shift_enable = falling_edge_found & tx_enable;

flex_pts_sr #(.NUM_BITS(8), .SHIFT_MSB(1)) TX_SHIFT_REG
(
  .clk(clk),
  .n_rst(n_rst),
  .shift_enable(shift_enable),
  .load_enable(load_data),
  .parallel_in(tx_data),
  .serial_out(tx_out)
);


endmodule
