// $Id: $
// File name:   decode.sv
// Created:     10/6/2014
// Author:      Eric Schrock
// Lab Section: 337-01
// Version:     1.0  Initial Design Entry
// Description: I2C start/stop bit detector and address/mode decoder

module decode (
  input wire clk,
  input wire n_rst,
  input wire scl,
  input wire sda_in,
  input wire [7:0] starting_byte,
  output wire rw_mode,
  output wire address_match,
  output wire stop_found,
  output wire start_found
);

reg d1;
reg d2;
reg d3;
reg d4;
//reg d5;
//reg d6;

reg rw_mode_reg;
reg address_match_reg;
reg stop_found_reg;
reg start_found_reg;

assign rw_mode = rw_mode_reg;
assign address_match = address_match_reg;
assign stop_found = stop_found_reg;
assign start_found = start_found_reg;


always_comb begin : MATCH_MODE
  rw_mode_reg = starting_byte[0];
  if(7'b1111000 == starting_byte[7:1]) begin
    address_match_reg = 1'b1;
  end
  else begin
    address_match_reg = 1'b0;
  end
end


always_comb begin : START_STOP
  stop_found_reg = 1'b0;
  start_found_reg = 1'b0;
  if((d1 == 1'b0) && (d2 == 1'b1)) begin // start
    if((d3 == 1'b1) && (d4 == 1'b1)) begin
      start_found_reg = 1'b1;
    end
  end
  if((d1 == 1'b1) && (d2 == 1'b0)) begin // stop
    if((d3 == 1'b1) && (d4 == 1'b1)) begin // should be 1'b1
      stop_found_reg = 1'b1;
    end
  end
end


always_ff @ (posedge clk, negedge n_rst) begin : EDGE_DETECTOR // try either only four flip-flops or sample 2nd and 3rd instead of 1st and 3rd
  if(1'b0 == n_rst) begin
    d1 <= 1'b1; // SDA idle value is 1
    d2 <= 1'b1; // so these should reset to 1?
    d3 <= 1'b1;
    d4 <= 1'b1;
    //d5 <= 1'b1;
    //d6 <= 1'b1;
  end
  else begin
    d1 <= sda_in;
    d2 <= d1;
    d3 <= scl;
    d4 <= d3;
    //d5 <= d4;
    //d6 <= d5;
  end
end




endmodule