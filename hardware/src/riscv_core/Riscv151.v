/**
 * Top-level module for the RISCV processor.
 * Contains instantiations of datapath and control unit.
 */
module Riscv151 #(
    parameter CPU_CLOCK_FREQ = 50_000_000
)(
    input clk,
    input rst,

    // Ports for UART that go off-chip to UART level shifter
    input FPGA_SERIAL_RX,
    output FPGA_SERIAL_TX
);

    reg [31:0] pc;
    wire [31:0] pc_plus_4;
    wire [31:0] next_pc;
    assign pc_plus_4 = pc + 4;

    // TODO: mux with branch, JALR, ...
    assign next_pc = pc_plus_4;

    // Instruction in first stage
    wire [31:0] bios_mem_instruction_out;
    wire [31:0] imem_instruction_out;

    wire [31:0] instruction_1;
    assign instruction_1 = pc[30] ? bios_mem_instruction_out 
                                  : imem_instruction_out;

    // pipeline registers for pc and instruction
    reg [31:0] instruction_2;
    reg [31:0] instruction_3;

    reg [31:0] pc_2;
    reg [31:0] pc_3;

    reg [31:0] pc_plus_4_2;
    reg [31:0] pc_plus_4_3;

    always @(posedge clk) begin
        pc_2 <= pc;
        pc_3 <= pc_2;

        pc_plus_4_2 <= pc_plus_4;
        pc_plus_4_3 <= pc_plus_4_2;

        instruction_2 <= instruction_1;
        instruction_3 <= instruction_2;
    end

    always @(posedge clk) begin
        if (rst) begin
            // reset
            pc <= 32'h3FFFFFFC;
        end
        else begin
            pc <= next_pc;
        end
    end

    wire [31:0] alu_out;

    // register for third pipeline stage
    reg [31:0] alu_out_3;

    // Instantiate your memories here
    // You should tie the ena, enb inputs of your memories to 1'b1
    // They are just like power switches for your block RAMs
    wire [3:0] write_enable_mask;
    wire dmem_write_enable;
    wire imem_write_enable;
    reg [31:0] mem_data_in;
    mem_write_controller mem_write_controller(
        .instruction(instruction_2),
        .address(alu_out),
        .data_in(mem_data_in),
        .data_out(mem_controller_data_out),
        .write_enable_mask(write_enable_mask),
        .dmem_write_enable(dmem_write_enable),
        .imem_write_enable(imem_write_enable)
    );

    wire [31:0] dmem_data_out;
    wire [31:0] bios_mem_data_out;

    dmem_blk_ram dmem (
        .clka(clk),
        .ena(1'b1),
        .wea(dmem_write_enable & write_enable_mask),
        .addra(alu_out[15:2]),
        .dina(mem_controller_data_out),
        .douta(dmem_data_out)
    );

    bios_mem bios_mem(
        .clka(clk),
        .clkb(clk),
        .ena(1'b1),
        .enb(1'b1),
        .addra(next_pc[15:2]),
        .douta(bios_mem_instruction_out),
        .addrb(alu_out[15:2]),
        .doutb(bios_mem_data_out)
    );

    imem_blk_ram imem( 
        .clka(clk),
        .clkb(clk),
        .ena(1'b1),
        .wea(imem_write_enable & write_enable_mask),
        .addra(alu_out[15:2]),
        .dina(mem_controller_data_out),
        .addrb(next_pc[15:2]),
        .doutb(imem_instruction_out)
    );

    wire [31:0] mem_dout;
    mem_read_controller mem_read_controller(
        .instruction(instruction_3),
        .mem_addr(alu_out_3),
        .dmem_data_in(dmem_data_out),
        .bios_data_in(bios_mem_data_out),
        .io_data_in(),
        .data_out(mem_dout)
    );

    // Construct your datapath, add as many modules as you want
    

    wire rf_write_enable;
    wire [31:0] rf_write_data;

    wire [31:0] rd1;
    wire [31:0] rd2;

    reg_file rf(
        .clk(clk),
        .rst(rst),
        .we(rf_write_enable),
        .ra1(instruction_1[19:15]), 
        .ra2(instruction_1[24:20]), 
        .wa(instruction_3[11:7]),
        .wd(rf_write_data),
        .rd1(rd1), 
        .rd2(rd2)
    );

    wire [31:0] alu_mux_out_1;
    wire [31:0] alu_mux_out_2;

    alu_in_muxes alu_in_muxes(
        .instruction(instruction_1),
        .rd1(rd1),
        .rd2(rd2),
        .pc(pc),
        .writeback(),
        .fwi(),
        
        .alu_in_1(alu_mux_out_1), 
        .alu_in_2(alu_mux_out_2)
    );


    reg [31:0] alu_in_1;
    reg [31:0] alu_in_2;

    // Registers for second pipeline stage
    always @(posedge clk ) begin
        alu_in_1 <= alu_mux_out_1;
        alu_in_2 <= alu_mux_out_2;
        mem_data_in <= rd2;
    end

    stage2 stage2(
        .instruction_in(instruction_2),

        .alu_in_1(alu_in_1),
        .alu_in_2(alu_in_2),
        .alu_out(alu_out),

        // pc for calculation of branch address
        .pc(pc_2),
        .branch_address()
    );

    // register for third pipeline stage
    always @(posedge clk) begin
        alu_out_3 <= alu_out;
    end

    writeback_mux writeback_mux(
        .instruction(instruction_3),
        .pc_plus_4(pc_plus_4_3),
        .mem_dout(mem_dout),
        .alu_out(alu_out_3),
        .writeback_data(rf_write_data),
        .writeback_enable(rf_write_enable)
    );

    assign writeback_adr = instruction_3[11:7];


    // On-chip UART
    uart #(
        .CLOCK_FREQ(CPU_CLOCK_FREQ)
    ) on_chip_uart (
        .clk(clk),
        .reset(rst),
        .data_in(),
        .data_in_valid(),
        .data_out_ready(),
        .serial_in(FPGA_SERIAL_RX),

        .data_in_ready(),
        .data_out(),
        .data_out_valid(),
        .serial_out(FPGA_SERIAL_TX)
    );





endmodule
