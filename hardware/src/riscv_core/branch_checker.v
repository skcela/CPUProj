`include "Opcode.vh"

module branch_checker(
	input [31:0] instruction_2,
	input [31:0] alu_output,
	output branch_condition
);


	wire [6:0] opcode;
	assign opcode = instruction_2[6:0];

	wire [2:0] funct3;
	assign funct3 = instruction_2[14:12];

	reg branch_condition_reg;
	assign branch_condition = branch_condition_reg;

	always @(*) begin
		if(opcode == `OPC_BRANCH) begin
			case(funct3)
				`FNC_BNE: branch_condition_reg = ~alu_output[0];
				default: branch_condition_reg = alu_output[0];
			endcase
		end else begin
			branch_condition_reg = 0;
		end
	end



endmodule