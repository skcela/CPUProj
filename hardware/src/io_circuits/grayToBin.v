module grayToBin#(
    parameter addr_width = 5
	)(
		input [addr_width-1:0] gray,

		output [addr_width-1:0] bin
	);

	reg [addr_width-1:0] bin_reg;

	always @(*) begin
	    bin_reg = gray ^ (gray >> 16);
	    bin_reg = bin_reg ^ (bin_reg >> 8);
	    bin_reg = bin_reg ^ (bin_reg >> 4);
	    bin_reg = bin_reg ^ (bin_reg >> 2);
	    bin_reg = bin_reg ^ (bin_reg >> 1);
	end

	assign bin = bin_reg;

endmodule