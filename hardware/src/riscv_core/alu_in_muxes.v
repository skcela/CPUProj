module alu_in_muxes(
	input [31:0] instruction,
	input [31:0] rd1,
	input [31:0] rd2,
	input [31:0] pc,
	input [31:0] writeback,
	input [31:0] fwi,
	
	output [31:0] alu_in_1, 
	output [31:0] alu_in_2
);


	wire [6:0] opcode;
	assign opcode = instruction[6:0];

	wire [2:0] funct3;
	assign funct3 = instruction[14:12];

	wire [6:0] funct7;
	assign funct7 = instruction[31:25];

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

	// UJ-Type: JAL
	wire [31:0] imm_uj;
	assign imm_uj = {{11{instruction[31]}}, instruction[31], 
					  instruction[19:12], instruction[20],
					  instruction[30:21], 1'b0};

    // U-Type: AUIPC and LUI
 	wire [31:0] imm_u;
 	assign imm_u = {instruction[31:12], 12'b0};

	always @(*) begin
		case(opcode)
			`OPC_ARI_RTYPE: begin
								alu_in_1_reg = rd1;
								alu_in_2_reg = rd2;
							end
			`OPC_ARI_ITYPE: begin
								alu_in_1_reg = rd1;
								alu_in_2_reg = imm_i;
							end
			`OPC_STORE: begin
								alu_in_1_reg = rd1;
								alu_in_2_reg = imm_s;
							end
			`OPC_LOAD: begin
								alu_in_1_reg = rd1;
								alu_in_2_reg = imm_i;
							end
			`OPC_BRANCH: begin
								alu_in_1_reg = rd1;
								alu_in_2_reg = rd2;
							end
			`OPC_JALR: begin
								alu_in_1_reg = rd1;
								alu_in_2_reg = imm_i;
							end
			`OPC_JAL: begin
								alu_in_1_reg = 0;
								alu_in_2_reg = 0;
							end
			`OPC_LUI: begin
								alu_in_1_reg = 0;
								alu_in_2_reg = 0;
							end
			`OPC_AUIPC: begin
								alu_in_1_reg = pc;
								alu_in_2_reg = imm_u;
							end
			7'b0000000:begin
								alu_in_1_reg = 0;
								alu_in_2_reg = 0;
							end
			default: begin
				alu_in_1_reg = 0;
				alu_in_2_reg = 0;
				$display("Unknown opcode in alu in mux");
			end
		endcase
	end



endmodule