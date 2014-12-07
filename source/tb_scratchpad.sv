// $Id: $
// File name:   tb_on_chip_sram_wrapper.sv
// Created:     4/16/2013
// Author:      foo
// Lab Section: 99
// Version:     1.0  Initial Design Entry
// Description: A simple verilog test bench for the VHDL on-chip sram wrapper.

`timescale 1ns / 100ps

module tb_scratchpad ();
	// SRAM configuation parameters (based on values set in wrapper file)
	localparam TB_CLK_PERIOD			= 6.0;	// Read/Write delays are 5ns and need ~1 ns for wire propagation
	localparam TB_ADDR_SIZE_BITS	= 17; 	// 16 => 64K Words in Memory
	localparam TB_DATA_SIZE_WORDS	= 128;		// Single word access (only a demo case, can access arbitraliy many bytes during an access but all accesses must be the number of words wide)
	localparam TB_WORD_SIZE_BYTES	= 1;		// Single byte words (only a demo case, words can be as large as 3 bytes)
	localparam TB_ACCES_SIZE_BITS	= (TB_DATA_SIZE_WORDS * TB_WORD_SIZE_BYTES * 8);
	
	// Useful test bench constants
	localparam TB_CAPACITY_WORDS	= (2 ** TB_ADDR_SIZE_BITS);
	localparam TB_MAX_ADDRESS			= (TB_CAPACITY_WORDS - 1);
	localparam TB_WORD_SIZE_BITS	= (TB_WORD_SIZE_BYTES * 8);
	localparam TB_MAX_WORD_BIT		= (TB_WORD_SIZE_BITS - 1);
	localparam TB_ACC_SIZE_BITS		= (TB_WORD_SIZE_BITS * TB_DATA_SIZE_WORDS);
	localparam TB_MAX_ACC_BIT			= (TB_ACC_SIZE_BITS - 1);
	
	localparam TB_MAX_WORD	= ((2 ** (TB_WORD_SIZE_BYTES * 8)) - 1);
	localparam TB_ZERO_WORD	= 0;
	localparam TB_MAX_ACC		= ((2 ** TB_ACCES_SIZE_BITS) - 1);
	localparam TB_ZERO_ACC	= 0;
	
	// Test bench variables
	integer unsigned tb_init_file_number;	// Can't be larger than a value of (2^31 - 1) due to how VHDL stores unsigned ints/natural data types
	integer unsigned tb_dump_file_number;	// Can't be larger than a value of (2^31 - 1) due to how VHDL stores unsigned ints/natural data types
	integer unsigned tb_start_address;	// The first address to start dumping memory contents from
	integer unsigned tb_last_address;		// The last address to dump memory contents from
	
	reg tb_read_enable;		// Active high read enable for the SRAM
	reg tb_write_enable;	// Active high write enable for the SRAM
	
	reg [(TB_ADDR_SIZE_BITS - 1):0]		tb_address; 		// The address of the first word in the access
	reg [(TB_ACCES_SIZE_BITS - 1):0]	tb_read_data;		// The data read from the SRAM
	reg [(TB_ACCES_SIZE_BITS - 1):0]	tb_write_data;	// The data to be written to the SRAM
	
	// Wrapper portmap
	scratchpad DUT
	(
		// Memory interface signals
		.r_enable(tb_read_enable),
		.w_enable(tb_write_enable),
		.addr(tb_address),
		.r_data(tb_read_data),
		.w_data(tb_write_data)
	);
	
	
	initial
	begin : TEST_BENCH
	
		// Initialization of memory's interface input signals
		tb_read_enable	<= 0;
		tb_write_enable	<= 0;
		tb_address			<= 0;
		tb_write_data		<= TB_ZERO_ACC;
		
		#(TB_CLK_PERIOD * 10);
		
		// Test the write functionality
		tb_address			<= 0;
		tb_write_enable	<= 1;
		tb_write_data		<= TB_MAX_ACC;
		#TB_CLK_PERIOD;
		
		tb_address 			<= 8;
		tb_write_enable	<= 1;
		tb_write_data		<= 5;
		#TB_CLK_PERIOD;
		
		tb_write_enable	<= 0;
		
		// Test the read functionality
		tb_read_enable	<= 1;
		#TB_CLK_PERIOD;
		
		tb_address			<= 1;
		tb_read_enable	<= 1;
		#TB_CLK_PERIOD;
		//$info("done reading");
		
		// Test error detection
		tb_read_enable	<= 1;
		tb_write_enable	<= 1;
		tb_write_data		<= TB_MAX_ACC;
		tb_address			<= 16;
		#TB_CLK_PERIOD;
		
		tb_read_enable	<= 1;
		tb_address			<= 0;
		#TB_CLK_PERIOD;
		
		tb_read_enable	<= 1;
		tb_address			<= 2;
		#TB_CLK_PERIOD;
		
		tb_read_enable	<= 1;
		tb_address			<= 4;
		#TB_CLK_PERIOD;
		
		tb_read_enable	<= 1;
		tb_address			<= 8;
		#TB_CLK_PERIOD;
		
		tb_read_enable	<= 1;
		tb_address			<= 16;
		#TB_CLK_PERIOD;
		
		tb_read_enable	<= 1;
		tb_address			<= 64;
		#TB_CLK_PERIOD;
		
		tb_read_enable	<= 1;
		tb_address			<= 1024;
		#TB_CLK_PERIOD;
		
	end
	
endmodule
