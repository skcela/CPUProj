//  Module: reg_file
//  Desc: An array of 32 32-bit registers
//  Inputs Interface:
//    clk: Clock signal
//    ra1: first read address (asynchronous)
//    ra2: second read address (asynchronous)
//    wa: write address (synchronous)
//    we: write enable (synchronous)
//    wd: data to write (synchronous)
//  Output Interface:
//    rd1: data stored at address ra1
//    rd2: data stored at address ra2
//-----------------------------------------------------------------------------

module reg_file (
    input clk,
    input rst,
    input we,
    input [4:0] ra1, ra2, wa,
    input [31:0] wd,
    output [31:0] rd1, rd2
);

    (* ram_style = "distributed" *) reg [31:0] reg_file [31:0];
    integer i;
    always @(posedge clk) begin
        if (rst) begin
            for (i=0; i<31; i=i+1) reg_file[i] <= 31'b0;
        end else begin
        	if (we & (wa != 0)) begin
        		reg_file[wa] <= wd;
        	end
        end
    end

    assign rd1 = reg_file[ra1];
    assign rd2 = reg_file[ra2];


endmodule
