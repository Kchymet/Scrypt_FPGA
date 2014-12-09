// $Id: $
// File name:   scrypt_hasher.sv
// Created:     12/7/2014
// Author:      Eric Schrock
// Lab Section: 337-01
// Version:     1.0  Initial Design Entry
// Description: Top level block for scrypt hasher

module scrypt_hasher (
  input wire clk,
  input wire n_rst,
  input wire sda_in,
  input wire scl,
  output reg sda_out,
  
  //SRAM outputs
  output reg scratch_read,
  output reg scratch_write,
  output reg[16:0] scratch_addr,
  output reg[1023:0] scratch_in,
  input reg[1023:0] scratch_out
);

reg rx_notify;
reg [7:0] rx_command;
reg nonce_ready;
reg [7:0] rx_out;
reg [6:0] address;
reg load;
reg [31:0] nonce;
reg hash_done;
reg match_found;
reg start_hash;
reg [639:0] hash_data;


i2c_transceiver I2C
(
  .clk(clk),
  .n_rst(n_rst),
  .sda_in(sda_in),
  .sda_out(sda_out),
  .scl_in(scl),
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
  .match_found(match_found),
  .start_hash(start_hash)
);


scrypt_top SCRYPT_TOP
(
  .clk(clk),
  .n_rst(n_rst),
  .enable(start_hash),
  .data(hash_data),
  .nonce(nonce),
  .match_found(match_found),
  .hash_done(hash_done),
  .scratch_read(scratch_read),
  .scratch_write(scratch_write),
  .scratch_addr(scratch_addr),
  .scratch_in(scratch_in),
  .scratch_out(scratch_out)
);





endmodule