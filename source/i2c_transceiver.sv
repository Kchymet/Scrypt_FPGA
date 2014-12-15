// $Id: $
// File name:   i2c_transceiver.sv
// Created:     12/1/2014
// Author:      Eric Schrock
// Lab Section: 337-01
// Version:     1.0  Initial Design Entry
// Description: Top level block for i2c slave transceiver

module i2c_transceiver (
  input wire clk,
  input wire n_rst,
  input wire scl_in,
  input wire sda_in,
  input wire nonce_ready,
  input wire [0:255] nonce, //port name the same, but now actually contains hash
  output reg sda_out,
  output reg notify,
  output reg [0:7] command,
  output reg [0:7] rx_out
);

reg stop_found;
reg start_found;
reg byte_received;
reg ack_prep;
reg check_ack;
reg ack_done;
reg rw_mode;
reg address_match;
reg rx_enable;
reg tx_enable;
reg inc_data;
reg valid_nonce;
reg [1:0] sda_mode;
reg load_data;
reg rising_edge_found;
reg falling_edge_found;
reg [7:0] read_data;
reg [7:0] rx_data;
reg tx_out;
reg load_rx;




controller CONTROLER
(
  .clk(clk),
  .n_rst(n_rst),
  .stop_found(stop_found),
  .start_found(start_found),
  .byte_received(byte_received),
  .ack_prep(ack_prep),
  .check_ack(check_ack),
  .ack_done(ack_done),
  .rw_mode(rw_mode),
  .address_match(address_match),
  .sda_in(sda_in),
  .valid_nonce(valid_nonce),
  .rx_enable(rx_enable),
  .tx_enable(tx_enable),
  .inc_data(inc_data),
  .sda_mode(sda_mode),
  .load_data(load_data),
  .notify(notify),
  .load_rx(load_rx)
);

next_nonce_byte NEXT_NONCE_BYTE
(
  .clk(clk),
  .n_rst(n_rst),
  .nonce_ready(nonce_ready),
  .inc_data(inc_data),
  .nonce(nonce),
  .valid_nonce(valid_nonce),
  .read_data(read_data)
);

rx_reg RX_DATA_REG
(
  .clk(clk),
  .n_rst(n_rst),
  .load_rx(load_rx),
  .rx_data(rx_data),
  .command(command),
  .rx_out(rx_out)
);

timer TIMER
(
  .clk(clk),
  .n_rst(n_rst),
  .rising_edge_found(rising_edge_found),
  .falling_edge_found(falling_edge_found),
  .stop_found(stop_found),
  .start_found(start_found),
  .byte_received(byte_received),
  .ack_prep(ack_prep),
  .check_ack(check_ack),
  .ack_done(ack_done)
);

decode DECODE
(
  .clk(clk),
  .n_rst(n_rst),
  .scl(scl_in),
  .sda_in(sda_in),
  .starting_byte(rx_data),
  .rw_mode(rw_mode),
  .address_match(address_match),
  .stop_found(stop_found),
  .start_found(start_found)
);

scl_edge SCL_EDGE
(
  .clk(clk),
  .n_rst(n_rst),
  .scl(scl_in),
  .rising_edge_found(rising_edge_found),
  .falling_edge_found(falling_edge_found)
);

sda_sel SDA_SEL
(
  .tx_out(tx_out),
  .sda_mode(sda_mode),
  .sda_out(sda_out) 
);

rx_sr RX_SR
(
  .clk(clk),
  .n_rst(n_rst),
  .sda_in(sda_in),
  .rising_edge_found(rising_edge_found),
  .rx_enable(rx_enable),
  .rx_data(rx_data)
);

tx_sr TX_SR
(
  .clk(clk),
  .n_rst(n_rst),
  .tx_out(tx_out),
  .falling_edge_found(falling_edge_found),
  .tx_enable(tx_enable),
  .tx_data(read_data),
  .load_data(load_data)
);


endmodule


  