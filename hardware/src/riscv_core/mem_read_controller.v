module mem_read_controller(
	input[31:0] instruction,
	input[31:0] mem_addr,
	input[31:0] dmem_data_in,
	input[31:0] bios_data_in,
	input[31:0] uart_data_0_in,
	input[31:0] uart_data_4_in,
	input io_fifo_empty,
	input [7:0] io_fifo_dout,
	input [7:0] gpio_switches,
	input[31:0] cycle_counter_data_in,
	input ac_fifo_full,
	input mic_fifo_empty,
	input [31:0] mic_fifo_dout,

	input i2c_rdata_valid,
	input i2c_ctrl_ready,
	input [15:0] i2c_rdata,

	output[31:0] data_out
);

	wire [6:0] opcode;
	assign opcode = instruction[6:0];

	wire [2:0] funct3;
	assign funct3 = instruction[14:12];

	wire [6:0] funct7;
	assign funct7 = instruction[31:25];

	reg [31:0] data_out_reg;
	assign data_out = data_out_reg;

	reg [31:0] data;
	always @(*) begin
		casex(mem_addr[31:28])
			4'b00X1: data = dmem_data_in;
			4'b0100: data = bios_data_in;
			4'b1000: begin // IO data
				case(mem_addr[11:0])
					12'h000: data = uart_data_0_in;
					12'h004: data = uart_data_4_in;
					12'h010, 12'h014: data = cycle_counter_data_in;
					12'h020: data = {31'b0, io_fifo_empty};
					12'h024: data = {24'b0, io_fifo_dout};
					12'h028: data = {24'b0, gpio_switches};
					12'h040: data = {31'b0, ac_fifo_full};
					12'h050: data = {31'b0, mic_fifo_empty};
					//12'h054: data = {12'b0, mic_fifo_dout};
					12'h054: data = mic_fifo_dout;
					12'h100: data = {30'b0, i2c_rdata_valid, i2c_ctrl_ready};
					12'h104: data = {24'b0, i2c_rdata[7:0]};
					default: begin
						if(opcode == `OPC_LOAD) begin
							$display("unknown address for io in mem_read_controller (time , %d)!", $time);
						end
						data = 0;
					end
				endcase
			end
			default: begin
				if(opcode == `OPC_LOAD) begin
					$display("Top bits of mem addr not valid (time , %d)! (mem_read_controller)", $time);
				end
				data = 0;
			end
		endcase
	end

	always @(*) begin
		if(opcode == `OPC_LOAD) begin
			case(funct3)
				`FNC_LBU: begin
							case(mem_addr[1:0])
								2'b00:	data_out_reg = {24'b0, data[7:0]};
								2'b01:	data_out_reg = {24'b0, data[15:8]};
								2'b10:	data_out_reg = {24'b0, data[23:16]};
								2'b11:	data_out_reg = {24'b0, data[31:24]};
							endcase
						 end
				`FNC_LHU: begin
							case(mem_addr[1:0])
								2'b00:	data_out_reg = {16'b0, data[15:0]};
								2'b01:	data_out_reg = {16'b0, data[23:8]};
								2'b10:	data_out_reg = {16'b0, data[31:16]};
								// For unaligned memory access zero out byte offset,
								// return lowest halfword
								2'b11:	data_out_reg = {16'b0, data[15:0]};
							endcase
						 end
				`FNC_LB: begin
							case(mem_addr[1:0])
								2'b00:	data_out_reg = {{24{data[7]}}, data[7:0]};
								2'b01:	data_out_reg = {{24{data[15]}}, data[15:8]};
								2'b10:	data_out_reg = {{24{data[23]}}, data[23:16]};
								2'b11:	data_out_reg = {{24{data[31]}}, data[31:24]};
							endcase
						 end
				`FNC_LH: begin
							case(mem_addr[1:0])
								2'b00:	data_out_reg = {{16{data[15]}}, data[15:0]};
								2'b01:	data_out_reg = {{16{data[23]}}, data[23:8]};
								2'b10:	data_out_reg = {{16{data[31]}}, data[31:16]};
								// For unaligned memory access zero out byte offset,
								// return lowest halfword
								2'b11:	data_out_reg = {{16{data[15]}}, data[15:0]};
							endcase
						 end
				`FNC_LW: begin
							data_out_reg = data;
						 end
				default: begin
					data_out_reg = 0;
					$display("Unknown funct3 in mem_read_controller load (%d)" , $time);
				end
			endcase
		end else begin
			data_out_reg = 0;
		end
	end



endmodule