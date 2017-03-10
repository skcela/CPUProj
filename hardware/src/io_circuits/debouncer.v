`include "util.vh"

module debouncer #(
    parameter width = 1,
    parameter sample_count_max = 25000, 
    parameter pulse_count_max = 150,
    parameter wrapping_counter_width = `log2(sample_count_max),
    parameter saturating_counter_width = `log2(pulse_count_max))
    (
    input clk,
    input [width-1:0] glitchy_signal,
    output [width-1:0] debounced_signal
    );

    // Create your debouncer circuit here
    // This module takes in a vector of 1-bit synchronized, but possibly glitchy signals
    // and should output a vector of 1-bit signals that hold high when their respective counter saturates

    wire pulse;

    sample_pulse_generator  #(
        .sample_count_max(sample_count_max),
        .wrapping_counter_width(wrapping_counter_width)
        ) pulse_gen (
        .clk(clk),
        .pulse(pulse)
    );

    genvar i;
    generate
        for (i = 0; i < width; i = i + 1) begin:sat_counter_loop
            saturating_counter #(
                .pulse_count_max(pulse_count_max),
                .saturating_counter_width(saturating_counter_width)
                ) sat_counter (
                .clk(clk),
                .sample_pulse(pulse),
                .synchronized_signal(glitchy_signal[i]),
                .debounced_signal(debounced_signal[i])
            ); 
        end
    endgenerate
endmodule
