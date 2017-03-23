module stage3(
	input clk,
	input reset,

	input [31:0] instruction_in,

	input [31:0] alu_out,

	input [31:0] pc_plus_4,
 
 	input [31:0] data_in,

 	// PC +4 and immediate to forward for writeback
	input [31:0] pc_plus_4,
 	input [31:0] immediate,

 	// connection to memory
 	input [31:0] mem_data,
 	output [31:0] mem_addr,

 	// Writeback to reg file
 	output [31:0] writeback_data,
 	output [4:0] writeback_adr,
 	output writeback_enable
);


	// Pipeline registers
	reg [31:0] instruction;
	reg [31:0] alu_out_reg;
	reg [31:0] immediate_reg;
	reg [31:0] pc_plus_4_reg;

	always @(posedge clk) begin
		if (rst) begin
			// reset
			instruction <= 0;
			alu_out_reg <= 0;
			immediate_reg <= 0;
			pc_plus_4_reg <= 0;
		end
		else begin
			instruction <= instruction_in;
			alu_out_reg <= alu_out;
			immediate_reg <= immediate;
			pc_plus_4_reg <= pc_plus_4;
		end
	end

	writeback_mux writeback_mux(
		.instruction(instruction),
		.pc_plus_4(pc_plus_4_reg),
		.mem_dout(mem_data),
		.alu_out(alu_out_reg),
		.immediate(immediate_reg),
		.writeback_data(writeback_data),
		.writeback_enable(writeback_enable)
	)
	assign writeback_adr = instruction[11:7];

endmodule