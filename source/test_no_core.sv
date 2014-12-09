// $Id: $
// File name:   test_no_core.sv
// Created:     12/7/2014
// Author:      Eric Schrock
// Lab Section: 337-01
// Version:     1.0  Initial Design Entry
// Description: Test top level without hashing core

module test_no_core (
  input wire clk,
  input wire n_rst,
  input wire sda_in,
  input wire scl_in,
  input wire hash_done,
  input wire [31:0] nonce,
  output reg sda_out,
  output reg start_hash,
  output reg [639:0] hash_data
);


reg rx_notify;
reg [7:0] rx_command;
reg nonce_ready;
reg [7:0] rx_out;
reg [6:0] address;
reg load;


i2c_transceiver I2C
(
  .clk(clk),
  .n_rst(n_rst),
  .sda_in(sda_in),
  .sda_out(sda_out),
  .scl_in(scl_in),
  .nonce_ready(nonce_ready),
  .notify(rx_notify),
  .nonce(nonce),
  .rx_out(rx_out),
  .command(rx_command)
);

flipflops_80B REG_80B
(
  .clk(clk),
  .load(load),
  .address(address),
  .rx_out(rx_out),
  .hash_data(hash_data)
);

main_controller MAIN_CONTROLLER
(
  .clk(clk),
  .n_rst(n_rst),
  .rx_notify(rx_notify),
  .rx_command(rx_command),
  .address(address),
  .nonce_ready(nonce_ready),
  .load(load),
  .hash_done(hash_done),
  .start_hash(start_hash)
);

endmodule
