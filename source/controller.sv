// $Id: $
// File name:   controller.sv
// Created:     10/18/2014
// Author:      Eric Schrock
// Lab Section: 337-01
// Version:     1.0  Initial Design Entry
// Description: I2C controller block

module controller (
  input wire clk,
  input wire n_rst,
  input wire stop_found,
  input wire start_found,
  input wire byte_received,
  input wire ack_prep,
  input wire check_ack,
  input wire ack_done,
  input wire rw_mode,
  input wire address_match,
  input wire sda_in,
  input wire valid_nonce,
  output reg rx_enable,
  output reg tx_enable,
  output reg inc_data,
  output reg [1:0] sda_mode,
  output reg load_data,
  output reg notify,
  output reg load_rx
);

reg d1;
reg d2;
reg byte_received_edge;

always_ff @ (posedge clk, negedge n_rst) begin : BYTE_RECEIVED_EDGE_DETECTOR
  if(n_rst == 1'b0) begin
    d1 <= 1'b0;
    d2 <= 1'b0;
  end
  else begin
    d1 <= byte_received;
    d2 <= d1;
  end  
end

always_comb begin : EDGE
  byte_received_edge <= d1 & !d2;
end




typedef enum bit [3:0] {
  READ,
  MATCH,
  NACK,
  TX_ACK,
  LOAD_TX,
  ENABLE_TX,
  LISTEN,
  CHECK_ACK,
  ACK_RECEIVED,
  INC_DATA,
  RX_ACK,
  RX_WAIT,
  LOAD_RX,
  NOTIFY,
  IDLE
} stateType;


stateType state;
stateType next_state;


always_comb begin : NEXT_STATE
  next_state = IDLE;
  case(state)
    IDLE: begin if(start_found == 1'b1) begin next_state = READ; end else begin next_state = IDLE; end end
    READ: begin if((byte_received == 1'b1) || (ack_prep == 1'b1)) begin next_state = MATCH; end else begin next_state = READ; end end
    MATCH: begin if((address_match == 1'b1) && (rw_mode == 1'b1) && (valid_nonce == 1'b1)) begin next_state = TX_ACK; end else if((address_match == 1'b1) && (rw_mode == 1'b0)) begin next_state = RX_ACK; end else begin next_state = NACK; end end
    NACK: begin if(ack_done == 1'b1) begin next_state = IDLE; end else begin next_state = NACK; end end
    TX_ACK: begin if(ack_done == 1'b1) begin next_state = LOAD_TX; end else begin next_state = TX_ACK; end end
    LOAD_TX: begin next_state = ENABLE_TX; end
    ENABLE_TX: begin if(ack_prep == 1'b1) begin next_state = LISTEN; end else begin next_state = ENABLE_TX; end end
    LISTEN: begin if(check_ack == 1'b1) begin next_state = CHECK_ACK; end else begin next_state = LISTEN; end end
    CHECK_ACK: begin if(sda_in == 1'b0) begin next_state = ACK_RECEIVED; end else begin next_state = IDLE; end end
    ACK_RECEIVED: begin if(ack_done == 1'b1) begin next_state = INC_DATA; end else begin next_state = ACK_RECEIVED; end end
    INC_DATA: begin next_state = LOAD_TX; end
    RX_ACK: begin if(stop_found == 1'b1) begin next_state = IDLE; end else if(ack_done == 1'b1) begin next_state = RX_WAIT; end else begin next_state = RX_ACK; end end
    RX_WAIT: begin if(byte_received_edge == 1'b1) begin next_state = LOAD_RX; end else if(stop_found == 1'b1) begin next_state = IDLE; end else begin next_state = RX_WAIT; end end
    LOAD_RX: begin next_state = NOTIFY; end
    NOTIFY: begin if(stop_found == 1'b1) begin next_state = IDLE; end else begin next_state = RX_ACK; end end 
    default: begin next_state = IDLE; end
  endcase
end


always_ff @ (posedge clk, negedge n_rst) begin : STATE_REG
  if(1'b0 == n_rst) begin
    state <= IDLE;
  end
  else begin
    state <= next_state;
  end  
end


always_comb begin : OUTPUT_LOGIC
  rx_enable = 1'b0;
  tx_enable = 1'b0;
  inc_data = 1'b0;
  sda_mode = 2'b00;
  load_data = 1'b0;
  notify = 1'b0;
  load_rx = 1'b0;
  case(state)
    IDLE: begin  end
    READ: begin rx_enable = 1'b1; end
    MATCH: begin  end
    NACK: begin sda_mode = 2'b10; end
    TX_ACK: begin sda_mode = 2'b01; end
    LOAD_TX: begin load_data = 1'b1; end
    ENABLE_TX: begin tx_enable = 1'b1; sda_mode = 2'b11; end
    LISTEN: begin  end
    CHECK_ACK: begin  end
    ACK_RECEIVED: begin  end 
    INC_DATA: begin inc_data = 1'b1; end
    RX_ACK: begin sda_mode = 2'b01; end
    RX_WAIT: begin rx_enable = 1'b1; end
    LOAD_RX: begin load_rx = 1'b1; end
    NOTIFY: begin notify = 1'b1; end
    default: begin  end
  endcase
end


endmodule
