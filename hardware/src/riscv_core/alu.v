`include "alu_control.vh"

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
		`SLL: out_reg = in1 << in2[4:0];
		`SRL: out_reg = in1 >> in2[4:0];
		`SRA: out_reg = ($signed (in1)) >>> in2[4:0];
		`LT : out_reg = (($signed (in1)) < ($signed (in2))) ? 1'b1 : 1'b0;
		`LTU: out_reg = (in1 < in2) ? 1'b1 : 1'b0;
		`GTE: out_reg = (($signed (in1)) >= ($signed (in2))) ? 1'b1 : 1'b0;
		`GTEU:out_reg = (in1 >= in2) ? 1'b1 : 1'b0;
		`EQ:  out_reg = (in1 == in2);
		`NOP: out_reg = 0;
		default: begin
			out_reg = 0;
			$display("Undefined control in ALU (%d)" , $time);
		end
	endcase
end

endmodule