// $Id: $
// File name:   scratchpad.sv
// Created:     12/6/2014
// Author:      Kyle Chynoweth
// Lab Section: 01
// Version:     1.0  Initial Design Entry
// Description: SRAM module wrapper for the SMIX scratchpad

module scratchpad (
  input wire r_enable,
  input wire w_enable,
  input wire[16:0] addr,
  input wire[1023:0] w_data,
  output wire[1023:0] r_data
);
on_chip_sram_wrapper #(
    .W_ADDR_SIZE_BITS(17),
    .W_WORD_SIZE_BYTES(1),
    .W_DATA_SIZE_WORDS(128)
    )
    SRAM (
    .read_enable(r_enable),
    .write_enable(w_enable),
    .address(addr),
    .write_data(w_data),
    .read_data(r_data)
    );
    
endmodule