`include "Opcode.vh"

module writeback_mux(
	input [31:0] instruction,

	input [31:0] pc_plus_4,
	input [31:0] mem_dout,
	input [31:0] alu_out,

	output [31:0] writeback_data,
	output writeback_enable
	);

	wire [6:0] opcode;
	assign opcode = instruction[6:0];

	wire [2:0] funct3;
	assign funct3 = instruction[14:12];

	wire [6:0] funct7;
	assign funct7 = instruction[31:25];

	reg writeback_enable_reg;
	assign writeback_enable = writeback_enable_reg;

	reg [31:0] writeback_data_reg;
	assign writeback_data = writeback_data_reg;

    // U-Type: AUIPC and LUI
 	wire [31:0] imm_u;
 	assign imm_u = {instruction[31:12], 12'b0};

	always @(*) begin
		case(opcode)
			`OPC_ARI_RTYPE, `OPC_ARI_ITYPE,`OPC_AUIPC: begin
								writeback_data_reg = alu_out;
								writeback_enable_reg = 1;
							end
			`OPC_LOAD: begin
						writeback_data_reg = 1;
						// slice data for word, half or byte
						case(funct3)
							`FNC_LW: writeback_enable_reg = mem_dout;
							`FNC_LH: writeback_enable_reg = {{16{mem_dout[15]}}, mem_dout[15:0]};
							`FNC_LB: writeback_enable_reg = {{24{mem_dout[7]}}, mem_dout[7:0]};
							`FNC_LHU: writeback_enable_reg = mem_dout[15:0];
							`FNC_LBU: writeback_enable_reg = mem_dout[7:0];
							default: begin
								writeback_enable_reg = 0;
								$display("Unknown funct3 in wb mux load");
							end
						endcase
						end
			`OPC_LUI: begin
						writeback_data_reg = 1;
						writeback_enable_reg = imm_u;				
						end
			`OPC_JAL, `OPC_JALR: begin
						writeback_data_reg = 1;
						writeback_enable_reg = pc_plus_4;				
						end
			`OPC_STORE, `OPC_BRANCH: begin
							writeback_data_reg = 0;
							writeback_enable_reg = 0;
						end
			7'b0000000:begin
							writeback_data_reg = 0;
							writeback_enable_reg = 0;
						end
			default: begin
					writeback_enable_reg = 0;
					writeback_data_reg = 0;
					$display("Unknown opcode in wb mux");
				end
		endcase
	end

endmodule