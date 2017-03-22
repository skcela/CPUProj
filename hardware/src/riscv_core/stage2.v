module stage2(
	input [31:0] instruction_in,
	output [31:0] instruction_out,

	input [31:0] alu_in_1,
	input [31:0] alu_in_2,
	output [31:0] alu_out,

	output [31:0] mem_data_out,

	// pc for calculation of branch address
	input [31:0] pc,
	output [31:0] branch_address,
	
	// immediate for LUI to forward
	input [31:0] immediate_in,
	output [31:0] immediate_out,

	// pc + 4 to worward to writeback stage
	input [31:0] pc_plus_4_in,
	output [31:0] pc_plus_4_out,
	
);

	// Forward signals to next stage
	assign instruction_out = instruction_in;
	assign pc_plus_4_out = pc_plus_4_in;
	assign mem_data_out = alu_in_2;
	assign immediate_out = immediate_in

	// calculate branch address
	assign branch_address = pc + alu_in_2;


	wire [3:0] alu_controll;
	alu alu (
		.in1(alu_in_1),
		.in2(alu_in_2),
		.control(alu_controll),
		.out(alu_out)
		);

	alu_controller alu_controller (
		.instruction(instruction_in),
		.alu_controll_out(alu_controll)
		);

endmodule