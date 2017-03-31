`include "mux_selects.vh"
module writeback_mux(
	input [31:0] instruction,
	input [`WB_MUX_SEL_WIDTH-1:0] mux_sel,

	input [31:0] pc_plus_4,
	input [31:0] mem_dout,
	input [31:0] alu_out,


	output [31:0] writeback_data,
	output writeback_enable
	);

	reg writeback_enable_reg;
	assign writeback_enable = writeback_enable_reg;

	reg [31:0] writeback_data_reg;
	assign writeback_data = writeback_data_reg;


	always @(*) begin
		case(mux_sel)
			`WB_ALU: begin
						writeback_data_reg = alu_out;
						writeback_enable_reg = 1;
					end
			`WB_MEM: begin
						writeback_enable_reg = 1;
						writeback_data_reg = mem_dout;
					 end
			`WB_PC: begin
						writeback_enable_reg = 1;
						writeback_data_reg = pc_plus_4;				
						end
			`WB_NULL: begin
							writeback_data_reg = 0;
							writeback_enable_reg = 0;
						end
			default: begin
					writeback_enable_reg = 0;
					writeback_data_reg = 0;
					$display("Unknown mux_sel in wb mux");
				end
		endcase
	end

endmodule