module binToGray#(
    parameter addr_width = 5
	)(
		input [addr_width-1:0] bin,

		output [addr_width-1:0] gray
	);

	assign gray = bin ^ (bin >> 1);

endmodule