`include "Opcode.vh"


module mem_controller(
	input [31:0] instruction,
	input [31:0] address,
	output [3:0] write_enable_mask,
	output dmem_enable,
	output imem_enable
	);

	wire [6:0] opcode;
	assign opcode = instruction[6:0];

	wire [2:0] funct3;
	assign funct3 = instruction[14:12];

	wire [6:0] funct7;
	assign funct7 = instruction[31:25];


	reg [3:0] write_enable_mask_reg;
	assign write_enable_mask = write_enable_mask_reg;

	always @(*) begin
		if(opcode == `OPC_STORE) begin
			case(funct3)
				`FNC_SB: write_enable_mask_reg = 4'b0001;
				`FNC_SH: write_enable_mask_reg = 4'b0011;
				`FNC_SW: write_enable_mask_reg = 4'b1111;
				default: begin
					write_enable_mask_reg = 4'b0000;
					$display("Unknown funct3 in dmem_controller store")
				end
			endcase
		end else begin
			write_enable_mask_reg = 4'b0000;
		end
	end


endmodule