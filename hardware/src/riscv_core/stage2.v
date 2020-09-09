module stage2(
	input [31:0] instruction_in,

	input [31:0] alu_in_1,
	input [31:0] alu_in_2,
	output [31:0] alu_out,


	// pc for calculation of branch address
	input [31:0] pc,
	output [31:0] branch_address
);

	// calculate branch address
	wire [31:0] imm_sb;
	assign imm_sb = {{19{instruction_in[31]}}, instruction_in[31], 
					  instruction_in[7], instruction_in[30:25], 
					  instruction_in[11:8], 1'b0};

	assign branch_address = pc + imm_sb;


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