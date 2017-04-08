`include "util.vh"

module ac97_controller #(
    parameter SYS_CLK_FREQ = 50_000_000
) (
    // AC97 Protocol Signals
    input sdata_in,           // Serial line from the codec (not used in this lab)
    input bit_clk,            // Bit clock from the codec (used for all logic in this module except reset)
    input [19:0] sample_fifo_tone_data,
    input sample_fifo_empty,
    output sample_fifo_rd_en,
    output sdata_out,         // Serial line to the codec
    output sync,              // Sync signal to the codec
    output reset_b,           // Active low reset (reset bar) to the codec
    input [3:0] volume_control,  // This input is tied to GPIO switches 3, 4, 5, 6    
    
    input system_clock,       // Clock used for resetting codec
    input system_reset       // Reset signal coming from the CPU_RESET button
                              // you will need to generate the reset signal for the codec in this controller
                              // (This reset signal should trigger the codec reset)

);

    localparam [15:0] tag = {5'b11111, 11'b0};

    reg [16:0] reset_time = SYS_CLK_FREQ / 1000;

    reg ac_ready = 1;

    reg signed [19:0] pcm_data = 0;

    reg fifo_rd_en_reg = 0;
    assign sample_fifo_rd_en = fifo_rd_en_reg;

    reg fifo_empty_prev =0;

    wire [15:0] master_vol;
    wire [15:0] headphone_vol;
    wire [15:0] pcm_vol;

    assign master_vol = {1'b0, 2'b0, 1'b1, volume_control, 3'b0, 1'b1, volume_control};
    assign headphone_vol = {1'b0, 2'b0, 1'b1, volume_control, 3'b0, 1'b1, volume_control};
    assign pcm_vol = 16'h0808;

    reg  [1:0] control_reg_loop = 0;
    wire [19:0] control_reg_adr  = (control_reg_loop == 2'd0) ? {1'b0, 7'h02, 12'b0} :
                                   (control_reg_loop == 2'd1) ? {1'b0, 7'h04, 12'b0} :
                                                                {1'b0, 7'h18, 12'b0};
    wire [19:0] control_reg_data = (control_reg_loop == 2'd0) ? {master_vol   , 4'b0} :
                                   (control_reg_loop == 2'd1) ? {headphone_vol, 4'b0} :
                                                                {pcm_vol      , 4'b0};

    reg  [255:0] ac_data_shift = 0;
    wire [255:0] ac_data;
    assign ac_data = {tag, control_reg_adr, control_reg_data, pcm_data, pcm_data, 160'b0};

    reg [8:0] bit_counter = 0;

    reg sdata_out_reg = 0;
    reg sync_reg = 0;

    assign sdata_out = reset_b ? sdata_out_reg : 0;
    assign sync = reset_b ? sync_reg : 0;

    always @(posedge bit_clk) begin
        if(bit_counter == 9'd255) begin
            bit_counter <= 0; 
            {sdata_out_reg, ac_data_shift} <= {ac_data, 1'b0};
            if(control_reg_loop == 2'd2) begin
                control_reg_loop <= 0;
            end else begin
                control_reg_loop <= control_reg_loop + 1;
            end
        end else if(bit_counter == 15) begin
            sync_reg <= 0;
            {sdata_out_reg, ac_data_shift} <= {ac_data_shift, 1'b0};      
            bit_counter <= bit_counter + 1;
        end else if(bit_counter == 252) begin
            {sdata_out_reg, ac_data_shift} <= {ac_data_shift, 1'b0};      
            bit_counter <= bit_counter + 1;

            fifo_rd_en_reg <= 1;
            fifo_empty_prev <= sample_fifo_empty;
            
        end else if(bit_counter == 253) begin
            {sdata_out_reg, ac_data_shift} <= {ac_data_shift, 1'b0};      
            bit_counter <= bit_counter + 1;

            fifo_rd_en_reg <= 0;
        end else if(bit_counter == 254) begin
            sync_reg <= 1;
            {sdata_out_reg, ac_data_shift} <= {ac_data_shift, 1'b0};      
            bit_counter <= bit_counter + 1;

            fifo_rd_en_reg <= 0;
            if(fifo_empty_prev) begin
                pcm_data <= pcm_data;
            end else begin
                pcm_data <= sample_fifo_tone_data;
            end

        end else begin
            {sdata_out_reg, ac_data_shift} <= {ac_data_shift, 1'b0};      
            bit_counter <= bit_counter + 1;
        end
    end

    reg reset_ac = 1;
    assign reset_b = reset_ac;
    reg [16:0] reset_clk_counter = 0;
    reg [2:0] reset_2_clk_counter = 0;
    reg reset_done = 0;

    // RESET
    always @(posedge system_clock) begin
        if (system_reset) begin
            // reset
            reset_ac <= 0;
            reset_clk_counter <= 0;
            reset_2_clk_counter <= 0;
            ac_ready <= 0;
            reset_done <= 0;
        end else if(reset_ac == 0) begin
            if (reset_clk_counter == reset_time) begin
                reset_ac <= 1;
                reset_clk_counter <= 0;
                reset_2_clk_counter <= 0;
                reset_done <= 1;
            end else begin
                reset_clk_counter <= reset_clk_counter + 1;
                reset_done <= 0;
            end
        end

        // Timer to wait until clock in codec starts oscilating
        if (reset_done) begin
            if (reset_2_clk_counter == 3'd6) begin
                ac_ready <= 1;
                reset_2_clk_counter <= 0;
                reset_done <= 0;
            end else begin
                reset_2_clk_counter <= reset_2_clk_counter + 1;
                ac_ready <= 0;
            end
        end
    end



endmodule
