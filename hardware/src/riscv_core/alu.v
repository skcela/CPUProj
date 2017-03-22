`include "alu_controll.vh"

module alu(
	input [31:0] in1, in2,
	input [3:0] control,
	output [31:0] out
	);

	reg [31:0] out_reg;
	assign out = out_reg;
		
always @(*) begin
	case(control)
		`ADD: out_reg = in1 + in2;
		`SUB: out_reg = in1 - in2;
		`AND: out_reg = in1 & in2;
		`OR:  out_reg = in1 | in2;
		`XOR: out_reg = in1 ^ in2;
		`SLL: out_reg = in1 << in2;
		`SRL: out_reg = in1 >> in2;
		`SRA: out_reg = ($signed (in1)) >>> in2;
		`LT : out_reg = (($signed (in1)) < ($signed (in2))) ? 1'b1 : 1'b0;
		`LTU: out_reg = (in1 < in2) ? 1'b1 : 1'b0;
		`NOP: out_reg = 0;
		default: begin
			out_reg = 0;
			$display("Undefined control in ALU");
		end
	endcase
end

endmodule