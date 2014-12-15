// $Id: $
// File name:   main_controller.sv
// Created:     12/7/2014
// Author:      Eric Schrock
// Lab Section: 337-01
// Version:     1.0  Initial Design Entry
// Description: Scrypt hasher main controller

module main_controller (
  input wire clk,
  input wire n_rst,
  input wire rx_notify,
  input wire [7:0] rx_command,
  input wire hash_done,
  output reg nonce_ready,
  output reg [6:0] address,
  output reg load,
  output reg start_hash
);

reg trigger_hash;
reg hash_flag;
reg reset_flag;
reg [6:0] next_address;
reg [6:0] final_address;
reg [6:0] next_final_address;
reg valid_command;

always_comb begin : VALID_COMMAND
  if(rx_command == 8'b00000001 || rx_command == 8'b00000010 || rx_command == 8'b00000100 || rx_command == 8'b00001000 || rx_command == 8'b00010000 || rx_command == 8'b00100000 || rx_command == 8'b01000000) begin
    valid_command <= 1'b1;
  end
  else begin
    valid_command <= 1'b0;
  end
end

always_ff @ (posedge clk) begin : ADDRESS_REG
  address <= next_address;
  final_address <= next_final_address;
end


always_ff @ (posedge clk, negedge n_rst) begin : HASH_FLAG
  if(n_rst == 1'b0) begin
    hash_flag <= 1'b0;
  end
  else if(trigger_hash == 1'b1) begin
    hash_flag <= 1'b1;
  end
  else if(reset_flag == 1'b1) begin
    hash_flag <= 1'b0;
  end
  else begin
    hash_flag <= hash_flag;
  end 
end


typedef enum bit [1:0] {
  TRIGGER_HASH,
  HASHING,
  SEND_NONCE,
  HASH_IDLE
} hashStateType;

hashStateType hashState;
hashStateType hashNextState;

typedef enum bit [2:0] {
  DECODE,
  LOAD,
  WAIT,
  INCREMENT_ADDRESS,
  CHECK_ADDRESS,
  HASH,
  DATA_IDLE
} dataStateType;

dataStateType dataState;
dataStateType dataNextState;



/* HASH CONTROLLER */

always_comb begin : HASH_NEXT_STATE
  hashNextState = HASH_IDLE;
  case(hashState)
    HASH_IDLE: begin if(hash_flag == 1'b1) begin hashNextState = TRIGGER_HASH; end else begin hashNextState = HASH_IDLE; end end
    TRIGGER_HASH: begin hashNextState = HASHING; end
    HASHING: begin if((hash_done == 1'b1)) begin hashNextState = SEND_NONCE; end else begin hashNextState = HASHING; end end
    SEND_NONCE: begin hashNextState = HASH_IDLE; end
  endcase 
end

always_ff @ (posedge clk, negedge n_rst) begin : HASH_STATE_REG
  if(n_rst == 1'b0) begin
    hashState <= HASH_IDLE;
  end
  else begin
    hashState <= hashNextState;
  end
end

always_comb begin : HASH_OUTPUT_LOGIC
  nonce_ready = 1'b0;
  start_hash = 1'b0;
  reset_flag = 1'b0;
  case(hashState)
    HASH_IDLE: begin  end
    TRIGGER_HASH: begin start_hash = 1'b1; reset_flag = 1'b1; end
    HASHING: begin end
    SEND_NONCE: begin nonce_ready = 1'b1; end
    default: begin  end
  endcase 
end



/* DATA CONTROLLER */

always_comb begin : DATA_NEXT_STATE
  dataNextState = DATA_IDLE;
  case(dataState)
    DATA_IDLE: begin if(rx_notify == 1'b1) begin dataNextState = DECODE; end else begin dataNextState = DATA_IDLE; end end
    DECODE: begin if(valid_command == 1'b1) begin dataNextState = WAIT; end else begin dataNextState = DATA_IDLE; end end
    WAIT: begin if(rx_notify == 1'b1) begin dataNextState = LOAD; end else begin dataNextState = WAIT; end end
    LOAD: begin dataNextState = CHECK_ADDRESS; end
    CHECK_ADDRESS: begin if(address == final_address) begin dataNextState = HASH; end else begin dataNextState = INCREMENT_ADDRESS; end end
    INCREMENT_ADDRESS: begin dataNextState = WAIT; end    
    HASH: begin dataNextState = DATA_IDLE; end
  endcase 
end

always_ff @ (posedge clk, negedge n_rst) begin : DATA_STATE_REG
  if(n_rst == 1'b0) begin
    dataState <= DATA_IDLE;
  end
  else begin
    dataState <= dataNextState;
  end
end

always_comb begin : DATA_OUTPUT_LOGIC
  trigger_hash = 1'b0;
  load = 1'b0;
  case(dataState)
    DATA_IDLE: begin next_address = address; next_final_address = final_address; end
    DECODE: 
      begin 
        if(rx_command == 8'b00000001) begin next_address = 8'd0; next_final_address = 8'd79; end
        else if(rx_command == 8'b00000010) begin next_address = 8'd0; next_final_address = 8'd3; end
        else if(rx_command == 8'b00000100) begin next_address = 8'd4; next_final_address = 8'd7; end
        else if(rx_command == 8'b00001000) begin next_address = 8'd8; next_final_address = 8'd11; end
        else if(rx_command == 8'b00010000) begin next_address = 8'd12; next_final_address = 8'd43; end
        else if(rx_command == 8'b00100000) begin next_address = 8'd44; next_final_address = 8'd75; end
        else if(rx_command == 8'b01000000) begin next_address = 8'd76; next_final_address = 8'd79; end
        else begin next_address = address + 1; next_final_address = final_address; end
      end
    WAIT: begin next_address = address; next_final_address = final_address; end
    CHECK_ADDRESS: begin next_address = address; next_final_address = final_address; end
    LOAD: begin load = 1'b1; next_address = address; next_final_address = final_address; end
    INCREMENT_ADDRESS: begin next_address = address + 1; next_final_address = final_address; end
    HASH: begin trigger_hash = 1'b1; next_address = address; next_final_address = final_address; end
    default: begin next_address = address; next_final_address = final_address; end
  endcase 
end



endmodule