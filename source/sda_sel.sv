// $Id: $
// File name:   sda_sel.sv
// Created:     10/6/2014
// Author:      Eric Schrock
// Lab Section: 337-01
// Version:     1.0  Initial Design Entry
// Description: SDA out selector

module sda_sel (
  input wire tx_out,
  input wire [1:0] sda_mode,
  output wire sda_out
);

reg sda_out_reg;
assign sda_out = sda_out_reg;

always_comb begin : MUX_4WAY
  if(2'b11 == sda_mode) begin
    sda_out_reg = tx_out;
  end
  else if(2'b10 == sda_mode) begin
    sda_out_reg = 1'b1;
  end
  else if (2'b01 == sda_mode) begin
    sda_out_reg = 1'b0;
  end
  else begin
    sda_out_reg = 1'b1;
  end     
end


endmodule
