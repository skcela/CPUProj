`include "util.vh"

module fifo #(
    parameter data_width = 8,
    parameter fifo_depth = 32,
    parameter addr_width = `log2(fifo_depth)
) (
    input clk, rst,
    
    // Write side
    input wr_en,
    input [data_width-1:0] din,
    output full,

    // Read side
    input rd_en,
    output [data_width-1:0] dout,
    output empty
);

    reg [data_width-1:0] buffer [fifo_depth-1:0];
    reg [addr_width-1:0] write_address;
    reg [addr_width-1:0] read_address;

    reg [data_width-1:0] dout_reg;

    // 0 for read, 1 for write
    reg lastop;

    always @(posedge clk) begin
        if (rst) begin
            // reset
            write_address <= 0;
            read_address <= 0;
            lastop <= 0;
        end
        else if (~full & wr_en) begin
            buffer[write_address] <= din;
            write_address <= write_address + 1;
            lastop <= 1;
        end else if (~empty & rd_en) begin
            dout_reg <= buffer[read_address];
            read_address <= read_address + 1;
            lastop <= 0;
        end
    end

    assign full = (write_address == read_address ) & lastop;
    assign empty = (write_address == read_address ) & ~lastop;

    assign dout = dout_reg;


endmodule
