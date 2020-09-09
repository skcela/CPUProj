`include "util.vh"

module async_fifo #(
    parameter data_width = 8,
    parameter fifo_depth = 32,
    parameter addr_width = `log2(fifo_depth)
) (
    input wr_clk,
    input rd_clk,

    input wr_en,
    input rd_en,
    input [data_width-1:0] din,

    output full,
    output empty,
    output [data_width-1:0] dout
);



    reg [data_width-1:0] buffer [fifo_depth-1:0];
    reg [addr_width:0] write_address_left = 0;
    wire [addr_width:0] read_address_left;

    wire [addr_width:0] write_address_gray_left;
    wire [addr_width:0] read_address_gray_left;


    wire [addr_width:0] write_address_right;
    reg [addr_width:0] read_address_right =  0;

    wire [addr_width:0] write_address_gray_right;
    wire [addr_width:0] read_address_gray_right;

    reg [data_width-1:0] dout_reg = 0;


    binToGray #(.addr_width(addr_width+1)) 
        b2gTop (.bin(write_address_left),
                .gray(write_address_gray_left));


    grayToBin #(.addr_width(addr_width+1)) 
        g2bTop (.gray(write_address_gray_right),
                .bin(write_address_right));

    synchronizer #(.width(addr_width+1))
        syncTop (.clk(rd_clk),
            .async_signal(write_address_gray_left),
            .sync_signal(write_address_gray_right));

    binToGray #(.addr_width(addr_width+1)) 
        b2gBot (.bin(read_address_right),
                .gray(read_address_gray_right));


    grayToBin #(.addr_width(addr_width+1)) 
        g2bBot (.gray(read_address_gray_left),
                .bin(read_address_left));


    synchronizer #(.width(addr_width+1))
        syncBot (.clk(wr_clk),
            .async_signal(read_address_gray_right),
            .sync_signal(read_address_gray_left));



    always @(posedge wr_clk) begin
        if (~full & wr_en) begin
            buffer[write_address_left[addr_width-1:0]] <= din;
            write_address_left <= write_address_left + 1;
        end 
    end

    always @(posedge rd_clk) begin
        if (~empty & rd_en) begin
            dout_reg <= buffer[read_address_right[addr_width-1:0]];
            read_address_right <= read_address_right + 1;
        end
    end

    assign empty = (write_address_right== read_address_right);
    assign full = (write_address_left[addr_width-1:0] == read_address_left[addr_width-1:0])
                 & (write_address_left[addr_width] != read_address_left[addr_width]);

    assign dout = dout_reg;


endmodule
