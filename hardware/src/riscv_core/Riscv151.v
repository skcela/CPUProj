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

    wire [31:0] alu_out;

    // Instantiate your memories here
    // You should tie the ena, enb inputs of your memories to 1'b1
    // They are just like power switches for your block RAMs
    wire [3:0] write_enable_mask;
    wire dmem_write_enable;
    wire imem_write_enable;
    wire [31:0] mem_data_in;
    mem_write_controller mem_write_controller(
        .instruction(instruction_2),
        .address(alu_out),
        .data_in(),
        .data_out(mem_data_in),
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
        .dina(mem_data_in),
        .douta(dmem_data_out)
    );

    bios_mem bios_mem(
        .clka(clk),
        .clkb(clk),
        .ena(1'b1),
        .enb(1'b1),
        .addra(pc),
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
        .dina(mem_data_in),
        .addrb(pc),
        .doutb(imem_instruction_out)
    );

    wire [31:0] mem_dout;
    mem_read_controller mem_read_controller(
        .instruction(instruction_3),
        .mem_addr(),
        .dmem_data_in(dmem_data_out),
        .bios_data_in(bios_mem_data_out),
        .io_data_in(),
        .data_out(mem_dout)
    );

    // Construct your datapath, add as many modules as you want
    
    stage2 stage2(
        .instruction_in(),
        .instruction_out(),

        .alu_in_1(),
        .alu_in_2(),
        .alu_out(alu_out),

        // pc for calculation of branch address
        .pc(),
        .branch_address(),
        
        // immediate for LUI to forward
        .immediate_in(),
        .immediate_out(),

        // pc + 4 to worward to writeback stage
        .pc_plus_4_in(),
        .pc_plus_4_out(),

    );

    writeback_mux writeback_mux(
        .instruction(instruction_3),
        .pc_plus_4(),
        .mem_dout(mem_dout),
        .alu_out(),
        .immediate(),
        .writeback_data(),
        .writeback_enable()
    )
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
