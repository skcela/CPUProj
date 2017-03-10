`include "util.vh"

module uart_transmitter #(
    parameter CLOCK_FREQ = 33_000_000,
    parameter BAUD_RATE = 115_200)
(
    input clk,
    input reset,

    input [7:0] data_in,
    input data_in_valid,
    output data_in_ready,

    output serial_out
);
    // See diagram in the lab guide
    localparam  SYMBOL_EDGE_TIME    =   CLOCK_FREQ / BAUD_RATE;
    localparam  CLOCK_COUNTER_WIDTH =   `log2(SYMBOL_EDGE_TIME);

    wire running;

    reg [9:0] data;
    reg [3:0] bit_counter;
    reg [CLOCK_COUNTER_WIDTH-1:0] clock_counter;

    // Goes high at every symbol edge
    assign symbol_edge = clock_counter == (SYMBOL_EDGE_TIME - 1);

    // Goes high when it is time to start sending a new character
    assign start = data_in_valid && !running;

    // Goes high while we are sending a character
    assign running = bit_counter != 4'd0;

    // Counts cycles until a single symbol is done
    always @ (posedge clk) begin
        clock_counter <= (start || reset || symbol_edge) ? 0 : clock_counter + 1;
    end

    always @(posedge clk) begin
        if (reset) begin
            // reset
            bit_counter <= 0;
        end
        else if(start) begin
            bit_counter <= 10;
        end
        else if (symbol_edge && running) begin
            bit_counter <= bit_counter - 1;
        end
    end

    wire [9:0] data_out;

    assign data_out = (data << (bit_counter-1));
    assign serial_out = running ? data_out[9] : 1;

    assign  data_in_ready = !running;


    always @(posedge clk) begin
        if (reset) begin
            // reset
            data <= 0;
        end
        else if (start) begin
            data <= {1'b1, data_in, 1'b0};
        end
    end

endmodule
