`include "Opcode.vh"


module mem_write_controller(
	input [31:0] instruction,
	input [31:0] address,
	input [31:0] data_in,
	output [31:0] data_out,
	output [3:0] write_enable_mask,
	output dmem_write_enable,
	output imem_write_enable
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
				`FNC_SB: begin
							write_enable_mask_reg = 4'b0001 << address[1:0];
							case(address[1:0])
								2'b00:	data_out = {24'b0, data_in[7:0]};
								2'b01:	data_out = {16'b0, data_in[7:0], 8'b0};
								2'b10:	data_out = {8'b0, data_in[7:0], 16'b0};
								2'b11:	data_out = {data_in[7:0], 24'b0};
							endcase
						 end
				`FNC_SH: begin
							write_enable_mask_reg = 4'b0011 << address[1:0];
							case(address[1:0])
								2'b00:	data_out = {16'b0, data_in[15:0]};
								2'b01:	data_out = {8'b0, data_in[15:0], 8'b0};
								2'b10:	data_out = {data_in[15:0], 16'b0};
								2'b11:	begin
											data_out = {16'b0, data_in[15:0]};
											// Ignore unaligned Memory access
											write_enable_mask = 4'b0000;
										end
							endcase
						 end
				`FNC_SW: begin
							write_enable_mask_reg = 4'b1111;
							data_out = data_in;
						 end
				default: begin
					write_enable_mask_reg = 4'b0000;
					$display("Unknown funct3 in mem_controller store");
				end
			endcase
		end else begin
			write_enable_mask_reg = 4'b0000;
		end
	end

	assign dmem_write_enable = address[28];
	assign imem_write_enable = address[29];


endmodule