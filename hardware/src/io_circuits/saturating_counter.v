module saturating_counter #(
    parameter pulse_count_max = 150,
    parameter saturating_counter_width = `log2(pulse_count_max))
	(
    input clk,
    input sample_pulse,
    input synchronized_signal,
    output debounced_signal
	);

	reg [saturating_counter_width:0] counter = 0;

	always @(posedge clk) begin
		if (sample_pulse && synchronized_signal && (counter != pulse_count_max)) begin
			counter <= counter + 1;
		end else if(~synchronized_signal) begin
			counter <= 0;
		end
	end

	assign debounced_signal = (counter == pulse_count_max);

endmodule