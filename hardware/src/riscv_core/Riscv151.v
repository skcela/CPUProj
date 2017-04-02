`include "mux_selects.vh"
`include "Opcode.vh"
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
    reg [31:0] next_pc;
    assign pc_plus_4 = pc + 4;

    // Instruction in first stage
    wire [31:0] bios_mem_instruction_out;
    wire [31:0] imem_instruction_out;
    wire [31:0] instruction_1;
    assign instruction_1 = pc[30] ? bios_mem_instruction_out 
                                  : imem_instruction_out;

    // pipeline registers for pc and instruction
    wire [31:0] instruction_2;
    wire [31:0] instruction_3;

    wire [6:0] opcode_3;
    assign opcode_3 = instruction_3[6:0];

    wire [31:0] branch_address;

    wire [`PC_MUX_SEL_WIDTH-1:0] pc_mux_sel;
    wire [31:0] alu_out;


    always @(*) begin
        case(pc_mux_sel)
            `PC_MUX_BRANCH: next_pc = branch_address;
            `PC_MUX_J:      next_pc = alu_out;
            default:        next_pc = pc_plus_4;
        endcase
    end




    reg [31:0] pc_2;
    reg [31:0] pc_3;

    reg [31:0] pc_plus_4_2;
    reg [31:0] pc_plus_4_3;

    always @(posedge clk) begin
        pc_2 <= pc;
        pc_3 <= pc_2;

        pc_plus_4_2 <= pc_plus_4;
        pc_plus_4_3 <= pc_plus_4_2;
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

    // register for third pipeline stage
    reg [31:0] alu_out_3;

    // wires for reg file
    wire rf_write_enable;
    wire [31:0] rf_write_data;

    wire [31:0] rd1;
    wire [31:0] rd2;


    // Instantiate your memories here
    // You should tie the ena, enb inputs of your memories to 1'b1
    // They are just like power switches for your block RAMs
    wire [3:0] write_enable_mask;
    wire [3:0] dmem_write_enable;
    wire [3:0] imem_write_enable;
    wire cycle_counter_write_enable;
    wire uart_write_enable;
    wire [31:0] mem_controller_data_out;
    reg [31:0] mem_data_in;
    wire store_alu_hazard;
    mem_write_controller mem_write_controller(
        .instruction(instruction_2),
        .address(alu_out),
        .data_in(store_alu_hazard ? rf_write_data :  mem_data_in),
        .data_out(mem_controller_data_out),
        .write_enable_mask(write_enable_mask),
        .dmem_write_enable(dmem_write_enable),
        .imem_write_enable(imem_write_enable),
        .cycle_counter_write_enable(cycle_counter_write_enable),
        .uart_write_enable(uart_write_enable)
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

    wire [31:0] cycle_counter_dout;
    cycle_counter cycle_counter(
        .clk(clk),
        .rst(rst),
        .instruction_3(instruction_3),
        .address(alu_out),
        .write_enable(cycle_counter_write_enable),
        .d_in(mem_controller_data_out),
        .d_out(cycle_counter_dout)
    );

    wire [31:0] mem_dout;

    wire [7:0] uart_dout;
    wire uart_din_ready;
    wire uart_dout_valid;

    wire [31:0] uart_data_0;
    wire [31:0] uart_data_4;
    assign uart_data_0 = {30'b0, uart_dout_valid, uart_din_ready};
    assign uart_data_4 = {24'b0, uart_dout};

    mem_read_controller mem_read_controller(
        .instruction(instruction_3),
        .mem_addr(alu_out_3),
        .dmem_data_in(dmem_data_out),
        .bios_data_in(bios_mem_data_out),
        .uart_data_0_in(uart_data_0),
        .uart_data_4_in(uart_data_4),
        .cycle_counter_data_in(cycle_counter_dout),
        .data_out(mem_dout)
    );

    wire [`WB_MUX_SEL_WIDTH-1:0] wb_mux_sel;
    wire [`ALU_IN_MUX_SEL_WIDTH-1:0] alu_in_mux_1_sel;
    wire [`ALU_IN_MUX_SEL_WIDTH-1:0] alu_in_mux_2_sel;
    // Controll Unit

    wire branch_condition;
    wire store_wb_hazard;

    control_unit control_unit(
        .clk(clk),
        .rst(rst),
        .instruction_1(instruction_1),
        .instruction_2_o(instruction_2),
        .instruction_3_o(instruction_3),
        .branch_condition(branch_condition),
        .wb_reg_hazard_rs1(wb_reg_hazard_rs1),
        .wb_reg_hazard_rs2(wb_reg_hazard_rs2),
        .store_alu_hazard(store_alu_hazard),
        .store_wb_hazard(store_wb_hazard),
        .alu_in_mux_1_sel(alu_in_mux_1_sel),
        .alu_in_mux_2_sel(alu_in_mux_2_sel),
        .wb_mux_sel(wb_mux_sel),
        .pc_mux_sel(pc_mux_sel)
    );


    branch_checker branch_checker(
        .instruction_2(instruction_2),
        .alu_output(alu_out),
        .branch_condition(branch_condition)
    );

    // Construct your datapath, add as many modules as you want
    


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

    reg [31:0] rd1_2;
    reg [31:0] rd2_2;

    // Registers for first pipeline stage
    always @(posedge clk ) begin
        rd1_2 <= wb_reg_hazard_rs1 ? rf_write_data : rd1;
        rd2_2 <= wb_reg_hazard_rs2 ? rf_write_data : rd2;
        mem_data_in <= store_wb_hazard ? rf_write_data : rd2;
    end

    wire [31:0] alu_in_1;
    wire [31:0] alu_in_2;
    alu_in_muxes alu_in_muxes(
        .instruction(instruction_2),
        .mux_1_sel(alu_in_mux_1_sel),
        .mux_2_sel(alu_in_mux_2_sel),
        .rd1(rd1_2),
        .rd2(rd2_2),
        .pc(pc_2),
        .fw_writeback(rf_write_data),
        
        .alu_in_1(alu_in_1), 
        .alu_in_2(alu_in_2)
    );

    stage2 stage2(
        .instruction_in(instruction_2),

        .alu_in_1(alu_in_1),
        .alu_in_2(alu_in_2),
        .alu_out(alu_out),

        // pc for calculation of branch address
        .pc(pc_2),
        .branch_address(branch_address)
    );

    // register for third pipeline stage
    always @(posedge clk) begin
        alu_out_3 <= alu_out;
    end

    writeback_mux writeback_mux(
        .instruction(instruction_3),
        .mux_sel(wb_mux_sel),
        .pc_plus_4(pc_plus_4_3),
        .mem_dout(mem_dout),
        .alu_out(alu_out_3),
        .writeback_data(rf_write_data),
        .writeback_enable(rf_write_enable)
    );

    wire uart_dout_ready;
    assign uart_dout_ready = ((alu_out_3[31:4] == 28'h8000000) 
                              & (opcode_3 == `OPC_LOAD));

    // On-chip UART
    uart #(
        .CLOCK_FREQ(CPU_CLOCK_FREQ)
    ) on_chip_uart (
        .clk(clk),
        .reset(rst),
        .data_in(mem_controller_data_out[7:0]),
        .data_in_valid(uart_write_enable),
        .data_out_ready(uart_dout_ready),
        .serial_in(FPGA_SERIAL_RX),

        .data_in_ready(uart_din_ready),
        .data_out(uart_dout),
        .data_out_valid(uart_dout_valid),
        .serial_out(FPGA_SERIAL_TX)
    );





endmodule
