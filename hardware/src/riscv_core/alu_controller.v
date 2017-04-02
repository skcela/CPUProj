`include "alu_control.vh"
`include "Opcode.vh"

module alu_controller(
	input [31:0] instruction,
	output [3:0] alu_controll_out
	);

reg [3:0] alu_controll;
assign alu_controll_out = alu_controll;


wire [6:0] opcode;
assign opcode = instruction[6:0];

wire [2:0] funct3;
assign funct3 = instruction[14:12];

wire [6:0] funct7;
assign funct7 = instruction[31:25];


always @(*) begin
	case(opcode)
		`OPC_ARI_RTYPE: begin
							case(funct3)
								3'b000: begin
									case(funct7)
										7'b0000000: alu_controll = `ADD;
										7'b0100000: alu_controll = `SUB;
										default: begin
											alu_controll = `NOP;
											$display("Undefined instruction in alu_controller");
										end
									endcase
								end
								3'b001: alu_controll = `SLL;
								3'b010: alu_controll = `LT;
								3'b011: alu_controll = `LTU;
								3'b100: alu_controll = `XOR;
								3'b101: begin
									case(funct7)
										7'b0000000: alu_controll = `SRL;
										7'b0100000: alu_controll = `SRA;
										default: begin
											alu_controll = `NOP;
											$display("Undefined instruction in alu_controller");
										end
									endcase
								end
								3'b110: alu_controll = `OR;
								3'b111: alu_controll = `AND;
							endcase
					   end
		`OPC_ARI_ITYPE: begin
							case(funct3)
								3'b000: alu_controll = `ADD;
								3'b001: alu_controll = `SLL;
								3'b010: alu_controll = `LT;
								3'b011: alu_controll = `LTU;
								3'b100: alu_controll = `XOR;
								3'b101: begin
									case(funct7)
										7'b0000000: alu_controll = `SRL;
										7'b0100000: alu_controll = `SRA;
										default: begin
											alu_controll = `NOP;
											$display("Undefined instruction in alu_controller");
										end
									endcase
								end
								3'b110: alu_controll = `OR;
								3'b111: alu_controll = `AND;
							endcase
					   end
		`OPC_LOAD:  alu_controll = `ADD;
		`OPC_STORE: alu_controll = `ADD;
		`OPC_JALR:  alu_controll = `ADD;
		`OPC_JAL:   alu_controll = `ADD;
		`OPC_BRANCH: begin
					case(funct3)
						`FNC_BEQ: alu_controll = `EQ;
						`FNC_BNE: alu_controll = `EQ;
						`FNC_BLT: alu_controll = `LT;
						`FNC_BGE: alu_controll = `GTE;
						`FNC_BLTU:alu_controll = `LTU;
						`FNC_BGEU:alu_controll = `GTEU;
						default: begin
							alu_controll = `NOP;
							$display("Unknown funct3 in alu_controller branch");
						end
					endcase
				end
		`OPC_AUIPC:  alu_controll = `ADD;
		`OPC_LUI:	alu_controll = `ADD; // No ALU operation needed
		7'b0000000: alu_controll = `NOP;
		default:begin
			alu_controll = `NOP;
			$display("Unknown opcode in alu_controller (%d)" , $time);
		 end
	endcase
end


endmodule