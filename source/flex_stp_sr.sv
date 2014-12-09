// $Id: $
// File name:   flex_stp_sr.sv
// Created:     9/17/2014
// Author:      Eric Schrock
// Lab Section: 337-01
// Version:     1.0  Initial Design Entry
// Description: Serial to Parallel Scalable Shift Register

module flex_stp_sr 
#(
  parameter NUM_BITS = 4,
  parameter SHIFT_MSB = 1
) 
(
  input wire clk,
  input wire n_rst,
  input wire shift_enable,
  input wire serial_in,
  output wire [(NUM_BITS-1):0] parallel_out
);


reg [(NUM_BITS-1):0] d;

always_ff @ (posedge clk, negedge n_rst) begin
  if(1'b0 == n_rst) begin
    d = 0;
  end
  else begin
    if((SHIFT_MSB == 1) && (shift_enable == 1)) begin
      d = {d[(NUM_BITS-2):0], serial_in};
    end
    else if ((SHIFT_MSB == 0) && (shift_enable == 1))begin
      d = {serial_in, d[(NUM_BITS-1):1]};
    end
    else begin
      d = d;
    end
  end
end
    
assign parallel_out = d;

endmodule
   