module memory(
	input clk,

	input [31:0] instruction,

	input [31:0] address,
	input [31:0] data_in,
	output [31:0] data_out,

	// read address for imem and bios
	input [31:0] pc,
	output [31:0] bios_mem_instruction_out,
	output [31:0] imem_instruction_out
);

	wire [3:0] write_enable_mask;
	wire dmem_write_enable;
	wire imem_write_enable;
	mem_controller mem_controller(
		.instruction(instruction_in),
		.address(address),
		.write_enable_mask(write_enable_mask),
		.dmem_enable(dmem_write_enable),
		.imem_enable(imem_write_enable)
	);

	wire [31:0] dmem_data_out;
	wire [31:0] bios_mem_data_out;



	dmem_blk_ram dmem (
		.clka(clk),
		.ena(1'b1),
		.wea(dmem_write_enable & write_enable_mask),
		.addra(address[15:2]),
		.dina(data_in),
		.douta(dmem_data_out)
	);

	bios_mem bios_mem(
		.clka(clk),
		.clkb(clk),
		.ena(1'b1),
		.enb(1'b1),
		.addra(pc),
		.douta(bios_mem_instruction_out),
		.addrb(address[15:2]),
		.doutb(bios_mem_data_out)
	);

	imem_blk_ram imem( 
		.clka(clk),
		.clkb(clk),
		.ena(1'b1),
		.wea(imem_write_enable & write_enable_mask),
		.addra(address[15:2]),
		.dina(data_in),
		.addrb(pc),
		.doutb(imem_instruction_out)
	);


endmodule