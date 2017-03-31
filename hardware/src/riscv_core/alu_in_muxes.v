`include "mux_selects.vh"

module alu_in_muxes(
	input [31:0] instruction,

	input [`ALU_IN_MUX_SEL_WIDTH-1:0] mux_1_sel,
	input [`ALU_IN_MUX_SEL_WIDTH-1:0] mux_2_sel,

	input [31:0] rd1,
	input [31:0] rd2,
	input [31:0] pc,
	input [31:0] fw_writeback,
	
	output [31:0] alu_in_1, 
	output [31:0] alu_in_2
);



	reg [31:0] alu_in_1_reg;
	reg [31:0] alu_in_2_reg;
	assign alu_in_1 = alu_in_1_reg;
	assign alu_in_2 = alu_in_2_reg;

	wire [4:0] shamt;
	assign shamt = instruction [24:20];

	wire [31:0] imm_i;
	assign imm_i = {{20{instruction[31]}}, instruction[31:20]};

	wire [31:0] imm_s;
	assign imm_s = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};

    // U-Type: AUIPC and LUI
 	wire [31:0] imm_u;
 	assign imm_u = {instruction[31:12], 12'b0};
    // Immediate for UJ-Type: JAL
    wire [31:0] imm_uj;
    assign imm_uj = {{11{instruction[31]}}, instruction[31], 
                      instruction[19:12], instruction[20],
                      instruction[30:21], 1'b0};

	always @(*) begin
		case(mux_1_sel)
			`ALU_IN_MUX_RF:     alu_in_1_reg = rd1;
			`ALU_IN_MUX_PC:     alu_in_1_reg = pc;
			`ALU_IN_MUX_NULL:   alu_in_1_reg = 0;
			`ALU_IN_MUX_FW_WB: 	alu_in_1_reg = fw_writeback;
			default: begin
				alu_in_1_reg = 0;
				$display("Unknown mux_1_sel in alu in mux");
			end
		endcase

		case(mux_2_sel)
			`ALU_IN_MUX_RF:   	 alu_in_2_reg = rd2;
			`ALU_IN_MUX_IMM_I:   alu_in_2_reg = imm_i;
			`ALU_IN_MUX_IMM_S:   alu_in_2_reg = imm_s;
			`ALU_IN_MUX_IMM_U:   alu_in_2_reg = imm_u;
			`ALU_IN_MUX_IMM_UJ:  alu_in_2_reg = imm_uj;
			`ALU_IN_MUX_NULL:    alu_in_2_reg = 0;
			`ALU_IN_MUX_FW_WB: 	 alu_in_2_reg = fw_writeback;
			default: begin
				alu_in_2_reg = 0;
				$display("Unknown mux_2_sel in alu in mux");
			end

		endcase
	end



endmodule