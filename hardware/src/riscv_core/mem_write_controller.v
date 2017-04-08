`include "Opcode.vh"


module mem_write_controller(
	input [31:0] instruction,
	input [31:0] address,
	input [31:0] data_in,
	output [31:0] data_out,
	output [3:0] write_enable_mask,
	output [3:0] dmem_write_enable,
	output [3:0] imem_write_enable,
	output led_write_enable,
	output cycle_counter_write_enable,
	output uart_write_enable
	);

	wire [6:0] opcode;
	assign opcode = instruction[6:0];

	wire [2:0] funct3;
	assign funct3 = instruction[14:12];

	wire [6:0] funct7;
	assign funct7 = instruction[31:25];

	reg [31:0] data_out_reg;
	assign data_out = data_out_reg;

	reg [3:0] write_enable_mask_reg;
	assign write_enable_mask = write_enable_mask_reg;

	always @(*) begin
		if(opcode == `OPC_STORE) begin
			case(funct3)
				`FNC_SB: begin
							write_enable_mask_reg = 4'b0001 << address[1:0];
							case(address[1:0])
								2'b00:	data_out_reg = {24'b0, data_in[7:0]};
								2'b01:	data_out_reg = {16'b0, data_in[7:0], 8'b0};
								2'b10:	data_out_reg = {8'b0, data_in[7:0], 16'b0};
								2'b11:	data_out_reg = {data_in[7:0], 24'b0};
							endcase
						 end
				`FNC_SH: begin
							write_enable_mask_reg = 4'b0011 << address[1:0];
							case(address[1:0])
								2'b00:	data_out_reg = {16'b0, data_in[15:0]};
								2'b01:	data_out_reg = {8'b0, data_in[15:0], 8'b0};
								2'b10:	data_out_reg = {data_in[15:0], 16'b0};
								2'b11:	begin
											data_out_reg = {16'b0, data_in[15:0]};
											// Ignore unaligned Memory access
											write_enable_mask_reg = 4'b0000;
										end
							endcase
						 end
				`FNC_SW: begin
							write_enable_mask_reg = 4'b1111;
							data_out_reg = data_in;
						 end
				default: begin
					write_enable_mask_reg = 4'b0000;
					data_out_reg = 0;
					$display("Unknown funct3 in mem_controller store");
				end
			endcase
		end else begin
			write_enable_mask_reg = 4'b0000;
			data_out_reg = 0;
		end
	end

	assign dmem_write_enable = {4{address[28]}};
	assign imem_write_enable = {4{address[29]}};
	assign cycle_counter_write_enable = (address== 32'h80000018) & (opcode == `OPC_STORE);
	assign uart_write_enable = (address== 32'h80000008) & (opcode == `OPC_STORE);
	assign led_write_enable = (address== 32'h80000030) & (opcode == `OPC_STORE);


endmodule