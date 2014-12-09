// $Id: $
// File name:   flipflops_80B.sv
// Created:     12/7/2014
// Author:      Eric Schrock
// Lab Section: 337-01
// Version:     1.0  Initial Design Entry
// Description: 80B flip-flop array to hold hash data

module flipflops_80B (
  input wire clk,
  input wire [7:0] rx_out,
  input wire [6:0] address,
  input wire load,
  output reg [639:0] hash_data
  );
  
/* // won't compile
always_ff @ (posedge clk) begin : REG
  if(load == 1'b1) begin
    hash_data[address*8+7:address*8] <= rx_out;
  end
  else begin
    hash_data <= hash_data;
  end
end 
*/
  
genvar i; 
  
generate
  for(i = 0;i < 80; i = i + 1) begin 
    always_ff @ (posedge clk) begin
      if((load == 1'b1) && (i == address)) begin
        hash_data[8*i+7:8*i] <= rx_out;
      end
      else begin
        hash_data[8*i+7:8*i] <= hash_data[8*i+7:8*i];
      end    
    end
  end
endgenerate
  
  
endmodule