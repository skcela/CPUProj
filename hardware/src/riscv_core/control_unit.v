`include "mux_selects.vh"
`include "Opcode.vh"

module control_unit(
	input clk,
	input [31:0] instruction_1,

	output [31:0] instruction_2_o,
	output [31:0] instruction_3_o,

	input branch_condition,

	output wb_reg_hazard_rs1,
	output wb_reg_hazard_rs2,

	output [`ALU_IN_MUX_SEL_WIDTH-1:0] alu_in_mux_1_sel,
	output [`ALU_IN_MUX_SEL_WIDTH-1:0] alu_in_mux_2_sel,

	output [`WB_MUX_SEL_WIDTH-1:0] wb_mux_sel,

	output [`PC_MUX_SEL_WIDTH-1:0] pc_mux_sel

);
	

	reg [31:0] instruction_2;
	reg [31:0] instruction_3;
	assign instruction_2_o = instruction_2;
	assign instruction_3_o = instruction_3;


	wire [6:0] opcode_1;
	assign opcode_1 = instruction_1[6:0];

	wire [6:0] opcode_2;
	assign opcode_2 = instruction_2[6:0];

	wire [6:0] opcode_3;
	assign opcode_3 = instruction_3[6:0];


	wire [4:0] inst_1_ra_1;
	wire [4:0] inst_1_ra_2;
	wire [4:0] inst_2_ra_1;
	wire [4:0] inst_2_ra_2;
	wire [4:0] inst_3_rd;
	assign inst_1_ra_1 = instruction_1 [19:15];
	assign inst_1_ra_2 = instruction_1 [24:20];
	assign inst_2_ra_1 = instruction_2 [19:15];
	assign inst_2_ra_2 = instruction_2 [24:20];
	assign inst_3_rd = instruction_3 [11:7];


	// No alu_hazard if instruction is branch, store or load,
	// since these instructions don't write back the alu result
	wire alu_in_hazard_ra_1;
	wire alu_in_hazard_ra_2;
	assign alu_in_hazard_ra_1 = ((inst_2_ra_1 == inst_3_rd) 
								& (opcode_3 != `OPC_BRANCH)
								& (opcode_3 != `OPC_STORE));
	assign alu_in_hazard_ra_2 = ((inst_2_ra_2 == inst_3_rd)
								& (opcode_3 != `OPC_BRANCH)
								& (opcode_3 != `OPC_STORE)
								& (opcode_2 != `OPC_ARI_ITYPE));


	assign wb_reg_hazard_rs1 = ((inst_1_ra_1 == inst_3_rd)
								& (opcode_3 != `OPC_BRANCH)
								& (opcode_3 != `OPC_STORE));
	assign wb_reg_hazard_rs2 = ((inst_1_ra_2 == inst_3_rd)
								& (opcode_3 != `OPC_BRANCH)
								& (opcode_3 != `OPC_STORE)
								& (opcode_2 != `OPC_ARI_ITYPE));



	always @(posedge clk) begin
		instruction_2 <= ((opcode_2 == `OPC_BRANCH & branch_condition)
							| (opcode_2 == `OPC_JALR) 
							| (opcode_2 == `OPC_JAL)) 
							? 32'b0 : instruction_1;
		instruction_3 <= instruction_2;
	end

	

	reg [`PC_MUX_SEL_WIDTH-1:0] pc_mux_sel_reg;
	assign pc_mux_sel = pc_mux_sel_reg;

	always @(*) begin
		case(opcode_2)
			`OPC_BRANCH: pc_mux_sel_reg = branch_condition ? 
							`PC_MUX_BRANCH : `PC_MUX_PLUS_4;
			`OPC_JALR, `OPC_JAL: pc_mux_sel_reg = `PC_MUX_J;
			default: pc_mux_sel_reg = `PC_MUX_PLUS_4;
		endcase
	end


	// Controll signals for alu in muxes in stage 2
	
	
	reg [`ALU_IN_MUX_SEL_WIDTH-1:0] alu_in_mux_1_sel_reg;
	reg [`ALU_IN_MUX_SEL_WIDTH-1:0] alu_in_mux_2_sel_reg;
	assign alu_in_mux_1_sel = alu_in_mux_1_sel_reg;
	assign alu_in_mux_2_sel = alu_in_mux_2_sel_reg;


	always @(*) begin
		if (alu_in_hazard_ra_1) begin
			alu_in_mux_1_sel_reg = `ALU_IN_MUX_FW_WB;
		end else begin
			case(opcode_2)
				`OPC_ARI_RTYPE, `OPC_BRANCH: begin
									alu_in_mux_1_sel_reg = `ALU_IN_MUX_RF;
								end
				`OPC_ARI_ITYPE, `OPC_LOAD, `OPC_JALR: begin
									alu_in_mux_1_sel_reg = `ALU_IN_MUX_RF;
								end
				`OPC_STORE: begin
									alu_in_mux_1_sel_reg = `ALU_IN_MUX_RF;
								end
				`OPC_AUIPC: begin
									alu_in_mux_1_sel_reg = `ALU_IN_MUX_PC;
								end
				`OPC_JAL: begin
									alu_in_mux_1_sel_reg = `ALU_IN_MUX_PC;
						  end
				`OPC_LUI, 7'b0000000:begin
									alu_in_mux_1_sel_reg = `ALU_IN_MUX_NULL;
								end
				default: begin
						alu_in_mux_1_sel_reg = `ALU_IN_MUX_NULL;
					$display("Unknown opcode in controll_unit for alu in mux");
				end
			endcase
		end


		if (alu_in_hazard_ra_2) begin
			alu_in_mux_2_sel_reg = `ALU_IN_MUX_FW_WB;
		end else begin
			case(opcode_2)
				`OPC_ARI_RTYPE, `OPC_BRANCH: begin
									alu_in_mux_2_sel_reg = `ALU_IN_MUX_RF;
								end
				`OPC_ARI_ITYPE, `OPC_LOAD, `OPC_JALR: begin
									alu_in_mux_2_sel_reg = `ALU_IN_MUX_IMM_I;
								end
				`OPC_STORE: begin
									alu_in_mux_2_sel_reg = `ALU_IN_MUX_IMM_S;
								end
				`OPC_AUIPC, `OPC_LUI: begin
									alu_in_mux_2_sel_reg = `ALU_IN_MUX_IMM_U;
								end
				`OPC_JAL: begin
									alu_in_mux_2_sel_reg = `ALU_IN_MUX_IMM_UJ;
						  end
				7'b0000000:begin
									alu_in_mux_2_sel_reg = `ALU_IN_MUX_NULL;
								end
				default: begin
						alu_in_mux_2_sel_reg = `ALU_IN_MUX_NULL;
					$display("Unknown opcode in controll_unit for alu in mux");
				end
			endcase
		end

	end









	// Controll signals for WB Mux in stage 3

	reg [`WB_MUX_SEL_WIDTH-1:0] wb_mux_sel_reg;
	assign wb_mux_sel = wb_mux_sel_reg;

	always @(*) begin
		case(opcode_3)
			`OPC_ARI_RTYPE, `OPC_ARI_ITYPE,`OPC_AUIPC, `OPC_LUI: begin
								wb_mux_sel_reg = `WB_ALU;
							end
			`OPC_LOAD: begin
							wb_mux_sel_reg = `WB_MEM;
					   end
			`OPC_JAL, `OPC_JALR: begin
							wb_mux_sel_reg = `WB_PC;					
						end
			`OPC_STORE, `OPC_BRANCH, 7'b0000000: begin
							wb_mux_sel_reg = `WB_NULL;	
						end
			default: begin
					wb_mux_sel_reg = `WB_NULL;
					$display("Unknown opcode in controll_unit for wb mux");
				end
		endcase
	end

endmodule