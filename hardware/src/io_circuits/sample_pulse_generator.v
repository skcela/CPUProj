module sample_pulse_generator #(
    parameter sample_count_max = 25000,
    parameter wrapping_counter_width = `log2(sample_count_max)
	)(
    input clk,
    output reg pulse
	);

	reg [wrapping_counter_width:0] counter = 0;

	always @(posedge clk) begin
		if (counter == sample_count_max) begin
			counter <= 0;
			pulse <= 1;
		end else begin
			counter <= counter + 1;
			pulse <= 0;
		end
	end

endmodule