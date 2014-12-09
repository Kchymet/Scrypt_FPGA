// $Id: $
// File name:   flex_counter.sv
// Created:     9/17/2014
// Author:      Eric Schrock
// Lab Section: 337-01
// Version:     1.0  Initial Design Entry
// Description: Scalable rollover counter.

module flex_counter
#(
    parameter NUM_CNT_BITS = 4
  )
  (
    input wire clk,
    input wire n_rst,
    input wire clear,
    input wire count_enable,
    input wire [(NUM_CNT_BITS-1):0] rollover_val,
    output wire [(NUM_CNT_BITS-1):0] count_out,
    output wire rollover_flag
  );

reg [NUM_CNT_BITS:0] d; // one extra flip-flop for the rollover_flag
reg [(NUM_CNT_BITS-1):0] next_count;
reg next_flag;

always_comb begin
  if(clear == 1'b1) begin
    next_count = 0;
  end
  else begin
    if(count_enable == 1'b0) begin
      next_count = count_out;
    end
    else begin
      if(count_out == rollover_val) begin
        next_count = 1;
      end
      else begin
        next_count = count_out + 1;
      end
    end
  end  
end


always_comb begin
  if(next_count == rollover_val) begin
    next_flag = 1'b1;
  end
  else begin
    next_flag = 1'b0;
  end
end   


always_ff @ (posedge clk, negedge n_rst) begin
  if(1'b0 == n_rst) begin
    d <= 0;
  end
  else begin
    d <= {next_count, next_flag};
  end    
end


assign count_out = d[NUM_CNT_BITS:1];
assign rollover_flag = d[0];


endmodule