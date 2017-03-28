module mem_read_controller(
	input[31:0] instruction,
	input[31:0] mem_addr,
	input[31:0] dmem_data_in,
	input[31:0] bios_data_in,
	input[31:0] io_data_in,
	output[31:0] data_out
);

	wire [6:0] opcode;
	assign opcode = instruction[6:0];

	wire [2:0] funct3;
	assign funct3 = instruction[14:12];

	wire [6:0] funct7;
	assign funct7 = instruction[31:25];

	wire [31:0] data;
	always @(*) begin
		casex(mem_addr[31:28])
			4'b00X1: data = dmem_data_in;
			4'b0100: data = bios_data_in;
			4'b1000: data = io_data_in;
			default: begin
				$display("Top bits of mem addr not valid!");
				data = 0;
			end
		endcase
	end

	always @(*) begin
		if(opcode == `OPC_LOAD) begin
			case(funct3)
				`FNC_LB: begin
							case(mem_addr[1:0])
								2'b00:	data_out = {24'b0, data[7:0]};
								2'b01:	data_out = {24'b0, data[15:8]};
								2'b10:	data_out = {24'b0, data[23:16]};
								2'b11:	data_out = {24'b0, data[31:24]};
							endcase
						 end
				`FNC_LH: begin
							case(mem_addr[1:0])
								2'b00:	data_out = {16'b0, data[15:0]};
								2'b01:	data_out = {16'b0, data[23:8]};
								2'b10:	data_out = {16'b0, data[31:16]};
								// For unaligned memory access zero out byte offset,
								// return lowest halfword
								2'b11:	data_out = {16'b0, data[15:0]};
							endcase
						 end
				`FNC_LW: begin
							data_out = data;
						 end
				default: begin
					$display("Unknown funct3 in mem_controller load");
				end
			endcase
		end
	end



endmodule