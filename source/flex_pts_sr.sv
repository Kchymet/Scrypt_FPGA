// $Id: $
// File name:   flex_pts_sr.sv
// Created:     9/17/2014
// Author:      Eric Schrock
// Lab Section: 337-01
// Version:     1.0  Initial Design Entry
// Description: Parallel to serial scalable shift register.

module flex_pts_sr 
#(
  parameter NUM_BITS = 4,
  parameter SHIFT_MSB = 1
) 
(
  input wire clk,
  input wire n_rst,
  input wire shift_enable,
  input wire load_enable,
  input wire [(NUM_BITS-1):0] parallel_in,
  output wire serial_out
);
 
reg [(NUM_BITS-1):0] d;

always_ff @ (posedge clk, negedge n_rst) begin
  if(1'b0 == n_rst) begin
    d <= 0;
  end 
  else begin
    if(load_enable == 1) begin
      d <= parallel_in;
    end
    else if((shift_enable == 1) && (SHIFT_MSB == 1)) begin
      d <= {d[(NUM_BITS-2):0], 1'b1};      
    end
    else if((shift_enable == 1) && (SHIFT_MSB == 0)) begin
      d <= {1'b1, d[(NUM_BITS-1):1]};     
    end
    else begin
      d <= d;
    end
  end
end

assign serial_out = SHIFT_MSB ? d[(NUM_BITS-1)] : d[0]; 

endmodule 