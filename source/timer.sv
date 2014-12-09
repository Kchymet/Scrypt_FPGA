// $Id: $
// File name:   timer.sv
// Created:     10/18/2014
// Author:      Eric Schrock
// Lab Section: 337-01
// Version:     1.0  Initial Design Entry
// Description: Timer for I2C Transmitter

module timer (
  input wire clk,
  input wire n_rst,
  input wire rising_edge_found,
  input wire falling_edge_found,
  input wire stop_found,
  input wire start_found,
  output wire byte_received,
  output wire ack_prep,
  output wire check_ack,
  output wire ack_done
);

typedef enum bit [2:0] {
  RECEIVING,
  ACK_PREP,
  ACK_CHECK,
  ACK_DONE,
  IDLE
} stateType;

stateType state;
stateType next_state;

reg rollover_flag;
reg [3:0] count_out;

reg byte_received_reg;
reg ack_prep_reg;
reg check_ack_reg;
reg ack_done_reg;

assign byte_received = byte_received_reg;
assign ack_prep = ack_prep_reg & falling_edge_found; // added falling edge
assign check_ack = check_ack_reg;
assign ack_done = ack_done_reg;


always_comb begin : NEXT_STATE
  next_state = IDLE;
  case(state)
    IDLE: begin if(start_found == 1'b1) begin next_state = RECEIVING; end else begin next_state = IDLE; end end
    RECEIVING: begin if(stop_found == 1'b1) begin next_state = IDLE; end else if(rollover_flag == 1'b1) begin next_state = ACK_PREP; end else begin next_state = RECEIVING; end end
    ACK_PREP: begin if(stop_found == 1'b1) begin next_state = IDLE; end else if(rising_edge_found == 1'b1) begin next_state = ACK_CHECK; end else begin next_state = ACK_PREP; end end
    ACK_CHECK: begin if(stop_found == 1'b1) begin next_state = IDLE; end else if(falling_edge_found == 1'b1) begin next_state = ACK_DONE; end else begin next_state = ACK_CHECK; end end
    ACK_DONE: begin if(stop_found == 1'b1) begin next_state = IDLE; end else begin next_state = RECEIVING; end end
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
  byte_received_reg = 1'b0;
  ack_prep_reg = 1'b0;
  check_ack_reg = 1'b0;
  ack_done_reg = 1'b0;
  case(state)
    IDLE: begin  end
    RECEIVING: begin  end
    ACK_PREP: begin byte_received_reg = 1'b1; ack_prep_reg = 1'b1; end
    ACK_CHECK: begin check_ack_reg = 1'b1; end
    ACK_DONE: begin ack_done_reg = 1'b1; end
    default: begin  end
  endcase
end


flex_counter #(.NUM_CNT_BITS(4)) COUNTER_8 
(
  .clk(clk),
  .n_rst(n_rst),
  .clear((rollover_flag & rising_edge_found) | start_found | ack_done_reg), //.clear(start_found), // could this cause probems? yes
  .count_enable(rising_edge_found),
  .rollover_val(4'b1000),
  .count_out(count_out),
  .rollover_flag(rollover_flag)
); 



endmodule
  