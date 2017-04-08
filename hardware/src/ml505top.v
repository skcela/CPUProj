// These are the compass button mappings in the 5-bit signal
`define B_CENTER 0
`define B_EAST 1
`define B_NORTH 2
`define B_SOUTH 3
`define B_WEST 4

module ml505top # (
    // We are using a 100 Mhz input clock for our design
    // It is declared as a parameter so the testbench can override it if desired
    // This clock isn't used directly
    parameter SYSTEM_CLOCK_FREQ = 100_000_000,

    // CPU clock frequency in Hz (can't be set arbitrarily)
    // Needs to be 600Mhz/x, where x is some integer, by default x = 12
    parameter CPU_CLOCK_FREQ = 50_000_000,

    // These are used for the button debouncer and the rotary A/B debouncer
    // They are overridden in the testbench for faster runtime
    parameter integer B_SAMPLE_COUNT_MAX = 0.00076 * CPU_CLOCK_FREQ,
    parameter integer B_PULSE_COUNT_MAX = 0.11364/0.00076,
    parameter integer R_SAMPLE_COUNT_MAX = 0.000303 * CPU_CLOCK_FREQ,
    parameter integer R_PULSE_COUNT_MAX = 0.003636/0.00030
) (
    input USER_CLK,             // 100 Mhz clock from crystal (divided internally with PLL)

    input [7:0] GPIO_DIP,       // 8 GPIO DIP Switches
    input FPGA_ROTARY_INCA,     // Rotary Encoder Wheel A Signal
    input FPGA_ROTARY_INCB,     // Rotary Encoder Wheel B Signal
    input FPGA_ROTARY_PUSH,     // Rotary Encoder Push Button Signal (Active-high)
    input [4:0] GPIO_BUTTONS,   // Compass Pushbuttons (Active-high)
    input FPGA_CPU_RESET_B,     // CPU_RESET Pushbutton (Active-LOW), signal should be interpreted as logic high when 0

    output PIEZO_SPEAKER,       // Piezo Speaker Output Line (buffered off-FPGA, drives piezo)
    output [7:0] GPIO_LED,      // 8 GPIO LEDs
    output GPIO_LED_C,          // Compass Center LED
    output GPIO_LED_N,          // Compass North LED
    output GPIO_LED_E,          // Compass East LED
    output GPIO_LED_W,          // Compass West LED
    output GPIO_LED_S,          // Compass South LED

    // AC97 Protocol Signals
    input AUDIO_BIT_CLK,
    input AUDIO_SDATA_IN,
    output AUDIO_SDATA_OUT,
    output AUDIO_SYNC,
    output FLASH_AUDIO_RESET_B,

    // UART connections
    input FPGA_SERIAL_RX,
    output FPGA_SERIAL_TX
);

    //// Clocking
    wire user_clk_g, cpu_clk, cpu_clk_g, pll_lock;

    // The clocks need to be buffered before they can be used
    IBUFG user_clk_buf ( .I(USER_CLK), .O(user_clk_g) );
    BUFG  cpu_clk_buf  ( .I(cpu_clk),  .O(cpu_clk_g)  );

    /* The PLL that generates all the clocks used in this design
    * The global mult/divide ratio is set to 6. The input clk is 100MHz.
    * Therefore, freq of each output = 600MHz / CLKOUTx_DIVIDE
    */
    PLL_BASE #(
        .COMPENSATION("SYSTEM_SYNCHRONOUS"),
        .BANDWIDTH("OPTIMIZED"),
        .CLKFBOUT_MULT(6),
        .CLKFBOUT_PHASE(0.0),
        .DIVCLK_DIVIDE(1),
        .REF_JITTER(0.100),
        .CLKIN_PERIOD(10.0),
        .CLKOUT0_DIVIDE(600_000_000 / CPU_CLOCK_FREQ),
        .CLKOUT0_DUTY_CYCLE(0.5),
        .CLKOUT0_PHASE(0.0)
    ) user_clk_pll (
        .CLKFBOUT(pll_fb),
        .CLKOUT0(cpu_clk),      // This is our CPU clock (default 50 Mhz)
        .LOCKED(pll_lock),
        .CLKFBIN(pll_fb),
        .CLKIN(user_clk_g),
        .RST(1'b0)
    );

    // User IO
    wire [4:0] compass_buttons;
    wire rotary_push, reset, rotary_event, rotary_left;

    button_parser #(
        .width(7),
        .sample_count_max(B_SAMPLE_COUNT_MAX),
        .pulse_count_max(B_PULSE_COUNT_MAX)
    ) b_parser (
        .clk(cpu_clk_g),
        .in({FPGA_ROTARY_PUSH, GPIO_BUTTONS, ~FPGA_CPU_RESET_B}),
        .out({rotary_push, compass_buttons, reset})
    );

    rotary_parser #(
        .sample_count_max(R_SAMPLE_COUNT_MAX),
        .pulse_count_max(R_PULSE_COUNT_MAX)
    ) r_parser (
        .clk(cpu_clk_g),
        .rst(reset),
        .rotary_A(FPGA_ROTARY_INCA),
        .rotary_B(FPGA_ROTARY_INCB),
        .rotary_event(rotary_event),
        .rotary_left(rotary_left)
    );

    wire [12:0] leds;
    assign {GPIO_LED_C, GPIO_LED_N, GPIO_LED_E, 
            GPIO_LED_S, GPIO_LED_W, GPIO_LED} = leds;

    // AC97 Controller
    wire sdata_out, sync, reset_b;
    // Buffer the AC97 bit clock
    BUFG BitClockBuffer(.I(AUDIO_BIT_CLK), .O(bit_clk));

    // Route the sdata_out sdata_in, sync, and reset signals through IOBs (input/output blocks)
    reg sdata_out_iob, sdata_in_iob, sync_iob, reset_b_iob /* synthesis iob="true" */;
    assign AUDIO_SDATA_OUT = sdata_out_iob;
    assign AUDIO_SYNC = sync_iob;
    assign FLASH_AUDIO_RESET_B = reset_b_iob;
   
    // Drive sdata_out and sync on the rising edge of the bit_clk
    always @ (posedge bit_clk) begin
        sdata_out_iob <= sdata_out;
        sync_iob <= sync;
    end

    // Sample sdata_in on the falling edge of the bit_clk
    always @ (negedge bit_clk) begin
        sdata_in_iob <= AUDIO_SDATA_IN;
    end

    // Drive reset_b on the CPU (system) clock
    always @ (posedge cpu_clk_g) begin
      reset_b_iob <= reset_b;
    end

    
    wire [3:0] ac_volume;
   
    ac97_controller #(
        .SYS_CLK_FREQ(CPU_CLOCK_FREQ)
    ) audio_controller (
        .sdata_in(sdata_in_iob),
        .sdata_out(sdata_out),
        .bit_clk(bit_clk),
        .sync(sync),
        .sample_fifo_tone_data(sample_fifo_tone_data),
        .sample_fifo_empty(sample_fifo_empty),
        .sample_fifo_rd_en(sample_fifo_rd_en),
        .reset_b(reset_b),
        .volume_control(ac_volume),
        .system_clock(cpu_clk_g),
        .system_reset(reset)
    );

    wire ac_fifo_full;
    wire ac_fifo_wr_en;
    wire [19:0] ac_fifo_din;

    async_fifo #(
        .data_width(20),
        .fifo_depth(8)
    ) async_fifo (
        .wr_clk(cpu_clk_g),
        .rd_clk(bit_clk),

        .wr_en(ac_fifo_wr_en),
        .din(ac_fifo_din),
        .full(ac_fifo_full),

        .rd_en(sample_fifo_rd_en),
        .dout(sample_fifo_tone_data),
        .empty(sample_fifo_empty)
    );

    wire tone_generator_enable;
    wire [23:0] tone_generator_switch_period;

    tone_generator tone_generator(
        .clk(cpu_clk_g),
        .rst(reset),
        
        .output_enable(tone_generator_enable & GPIO_DIP[0]),
        .tone_switch_period(tone_generator_switch_period),

        .square_wave_out(PIEZO_SPEAKER)
    );


    // FIFO connections
    wire fifo_rd_en, fifo_empty;
    wire [7:0] fifo_dout;

    wire [7:0] button_data;
    assign button_data = {compass_buttons[`B_CENTER], compass_buttons[`B_NORTH], 
                            compass_buttons[`B_EAST], compass_buttons[`B_SOUTH], 
                            compass_buttons[`B_WEST], rotary_push, rotary_event, rotary_left};
    reg [7:0] fifo_din;
    reg fifo_wr_en;
    wire fifo_full;

    always @(posedge cpu_clk_g) begin
        if (reset) begin
            fifo_din <= 0;
            fifo_wr_en <= 0;
        end else if ( |button_data[7:1] & ~fifo_full) begin
            fifo_din <= button_data;
            fifo_wr_en <= 1;
        end else begin
            fifo_din <= 0;
            fifo_wr_en <= 0;
        end
    end

    // FIFO
    fifo #(
        .data_width(8),
        .fifo_depth(32)
    ) fifo (
        .clk(cpu_clk_g),
        .rst(reset),

        .wr_en(fifo_wr_en),
        .din(fifo_din),
        .full(fifo_full),

        .rd_en(fifo_rd_en),
        .dout(fifo_dout),
        .empty(fifo_empty)
    );

    // RISC-V 151 CPU
    Riscv151 #(
        .CPU_CLOCK_FREQ(CPU_CLOCK_FREQ)
    ) CPU(
        .clk(cpu_clk_g),
        .rst(reset),

        .io_fifo_rd_en(fifo_rd_en),
        .io_fifo_dout(fifo_dout),
        .io_fifo_empty(fifo_empty),

        .gpio_switches(GPIO_DIP),

        .leds_dout(leds),

        .tone_generator_enable(tone_generator_enable),
        .tone_generator_switch_period(tone_generator_switch_period),

        .ac_fifo_full(ac_fifo_full),
        .ac_fifo_wr_en(ac_fifo_wr_en),
        .ac_fifo_din(ac_fifo_din),
        .ac_volume(ac_volume),

        .FPGA_SERIAL_RX(FPGA_SERIAL_RX),
        .FPGA_SERIAL_TX(FPGA_SERIAL_TX)
    );
endmodule
