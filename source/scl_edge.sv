// $Id: $
// File name:   scl_edge.sv
// Created:     10/6/2014
// Author:      Eric Schrock
// Lab Section: 337-01
// Version:     1.0  Initial Design Entry
// Description: SCL edge detector

module scl_edge (
  input wire clk,
  input wire n_rst,
  input wire scl,
  output wire rising_edge_found,
  output wire falling_edge_found
);

reg d1;
reg d2;

assign rising_edge_found = d1 & ~d2;
assign falling_edge_found = ~d1 & d2;

always_ff @ (posedge clk, negedge n_rst) begin
  if(1'b0 == n_rst) begin
    d1 <= 1'b1; // SCL idle value is 1
    d2 <= 1'b1; // so these should reset to 1?
  end
  else begin
    d1 <= scl;
    d2 <= d1;
  end
end
    
  
endmodule