`timescale 1ns/100ps

`include "alu_controll.vh"
`include "Opcode.vh"

module alu_testbench();

	reg [31:0] instruction;

	reg [31:0] in1;
	reg [31:0] in2;

	wire [3:0] alu_controll;
	wire [31:0] alu_out;

	alu alu (
		.in1(in1),
		.in2(in2),
		.control(alu_controll),
		.out(alu_out)
		);

	alu_controller alu_controller (
		.instruction(instruction),
		.alu_controll_out(alu_controll)
		);

	initial begin
		instruction = {1'b0, `FNC2_ADD, 5'b0, 10'b0, `FNC_ADD_SUB, 5'b0, `OPC_ARI_RTYPE};
		in1 = 32'd112233;
		in2 = 32'd332211;
		#1;
		$display("Addition 112233+332211 was: %d", alu_out);

		#2;

		instruction = {1'b0, `FNC2_SUB, 5'b0, 10'b0, `FNC_ADD_SUB, 5'b0, `OPC_ARI_RTYPE};
		in1 = 32'd332211;
		in2 = 32'd112233;
		#1;
		$display("Sub 332211-112233 was: %d", alu_out);

		#2;

		instruction = {1'b0, `FNC2_SRA, 5'b0, 10'b0, `FNC_SRL_SRA, 5'b0, `OPC_ARI_RTYPE};
		in1 = $signed(-32'd123);
		in2 = 32'd3;
		#1;
		$display("Addition 112233+332211 was: %d", $signed(alu_out));

		#2;

		instruction = {1'b0, 1'b0, 5'b0, 10'b0, `FNC_SW, 5'b0, `OPC_STORE};
		in1 = 32'd332211;
		in2 = 32'd112233;
		#1;
		$display("Store 112233+332211 was: %d", $signed(alu_out));

		#2;

		instruction = {1'b0, 1'b0, 5'b0, 10'b0, `FNC_OR, 5'b0, `OPC_ARI_ITYPE};
		in1 = 32'd332211;
		in2 = 32'd112233;
		#1;
		$display("OR 112233 | 332211 was: %d", $signed(alu_out));

		#2;

		instruction = {1'b0, 1'b0, 5'b0, 10'b0, `FNC_BEQ, 5'b0, `OPC_BRANCH};
		in1 = 32'd332211;
		in2 = 32'd112233;
		#1;
		$display("Branch 112233 + 332211 was: %d", $signed(alu_out));

		#2;




	end


endmodule