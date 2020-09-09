module cycle_counter(
	input clk,
	input rst,
	input [31:0] instruction_3,
	input [31:0] address,
	input write_enable,
	input [31:0] d_in,
	output [31:0] d_out

	);


	reg [31:0] cycle_count;
	reg [31:0] instruction_count;

	always @(posedge clk) begin
		if (rst | (write_enable & (address == 32'h80000018))) begin
			// reset
			cycle_count <= 0;
			instruction_count <= 0;
		end
		else begin
			cycle_count <= cycle_count + 1;
			if (instruction_3 != 32'b0) begin
				instruction_count <= instruction_count + 1;
			end
		end
	end

	reg [31:0] d_out_reg;
	assign d_out = d_out_reg;

	always @(posedge clk) begin
		case(address)
			32'h80000010: d_out_reg <= cycle_count;
			32'h80000014: d_out_reg <= instruction_count;
			default: d_out_reg <= 0;
		endcase
	end


endmodule