`include alu_control.vh

module alu(
	input [31:0] in1, in2,
	input [3:0] control,
	output [31:0] out
	);


always @(*) begin
	case(control)
		ADD: out = in1 + in2;
		SUB: out = in1 - in2;
		AND: out = in1 & in2;
		OR:  out = in1 | in2;
		XOR: out = in1 ^ in2;
		SLL: out = in1 << in2;
		SRL: out = in1 >> in2;
		SRA: out = ($signed in1) >>> in2;
		LT : out = (($signed in1) < ($signed in2)) ? 1'b1 : 1'b0;
		LTU: out = (in1 < in2) ? 1'b1 : 1'b0;
		NOP: out = 0;
		default: begin
			out = 0;
			$display("Undefined control in ALU");
		end
	endcase
end

endmodule