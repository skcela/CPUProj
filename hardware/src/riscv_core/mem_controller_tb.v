`timescale 1ns/100ps

`include "alu_control.vh"
`include "Opcode.vh"

module mem_controller_tb();

	reg [31:0] instruction_2;
	reg [31:0] instruction_3;

	reg [31:0] alu_out;
	reg [31:0] read_addr;
	reg [31:0] mem_data_in;
	reg [31:0] dmem_data;
	reg [31:0] bios_data;

	wire [3:0] alu_controll;
	wire [31:0] data_out;

    wire [3:0] write_enable_mask;
    wire dmem_write_enable;
    wire imem_write_enable;

    mem_write_controller mem_write_controller(
        .instruction(instruction_2),
        .address(alu_out),
        .data_in(mem_data_in),
        .data_out(data_out),
        .write_enable_mask(write_enable_mask),
        .dmem_write_enable(dmem_write_enable),
        .imem_write_enable(imem_write_enable)
    );


    wire [31:0] mem_dout;
    mem_read_controller mem_read_controller(
        .instruction(instruction_3),
        .mem_addr(read_addr),
        .dmem_data_in(dmem_data),
        .bios_data_in(bios_data),
        .io_data_in(),
        .data_out(mem_dout)
    );

	initial begin
		$display("---- STORE TESTS ----");
		// sw 
		instruction_2 = {7'b0, 10'b0, `FNC_SW, 5'b0, `OPC_STORE};
		alu_out = {4'b0010, 26'b0 ,2'b0};
		mem_data_in = 32'hABABABAB;
		#1;
		$display("SW dout: %h", data_out);
		$display("SW write mask: %b", write_enable_mask);
		$display("SW enables: dmem: %b imem: %b", dmem_write_enable, imem_write_enable);

		
		// sh
		instruction_2 = {7'b0, 10'b0, `FNC_SH, 5'b0, `OPC_STORE};
		alu_out = {4'b0001, 26'b0 ,2'b0};
		mem_data_in = 32'hABABABAB;
		#1;
		$display("SH 00 dout: %h", data_out);
		$display("SH 00 write mask: %b", write_enable_mask);
		$display("SH 00 enables: dmem: %b imem: %b", dmem_write_enable, imem_write_enable);

		
		// sh
		instruction_2 = {7'b0, 10'b0, `FNC_SH, 5'b0, `OPC_STORE};
		alu_out = {4'b0001, 26'b0 ,2'b01};
		mem_data_in = 32'hABABABAB;
		#1;
		$display("SH 01 dout: %h", data_out);
		$display("SH 01 write mask: %b", write_enable_mask);
		$display("SH 01 enables: dmem: %b imem: %b", dmem_write_enable, imem_write_enable);

		
		// sb
		instruction_2 = {7'b0, 10'b0, `FNC_SB, 5'b0, `OPC_STORE};
		alu_out = {4'b0001, 26'b0 ,2'b00};
		mem_data_in = 32'hABABABAB;
		#1;
		$display("sb 00 dout: %h", data_out);
		$display("sb 00 write mask: %b", write_enable_mask);
		$display("sb 00 enables: dmem: %b imem: %b", dmem_write_enable, imem_write_enable);

		
		// sb
		instruction_2 = {7'b0, 10'b0, `FNC_SB, 5'b0, `OPC_STORE};
		alu_out = {4'b0001, 26'b0 ,2'b10};
		mem_data_in = 32'hABABABAB;
		#1;
		$display("sb 10 dout: %h", data_out);
		$display("sb 10 write mask: %b", write_enable_mask);
		$display("sb 10 enables: dmem: %b imem: %b", dmem_write_enable, imem_write_enable);

		
		// sb
		instruction_2 = {7'b0, 10'b0, `FNC_SB, 5'b0, `OPC_STORE};
		alu_out = {4'b0010, 26'b0 ,2'b11};
		mem_data_in = 32'hABABABAB;
		#1;
		$display("sb 11 dout: %h", data_out);
		$display("sb 11 write mask: %b", write_enable_mask);
		$display("sb 11 enables: dmem: %b imem: %b", dmem_write_enable, imem_write_enable);


		$display("---- LOAD TESTS ----");
		// lw
		instruction_3 = {7'b0, 10'b0, `FNC_LW, 5'b0, `OPC_LOAD};
		read_addr = {4'b0001, 26'b0 ,2'b0};
		dmem_data = 32'hAABBCCDD;
		bios_data = 32'h11223344;
		#1;
		$display("LW dmem dout: %h", mem_dout);
		// lw
		instruction_3 = {7'b0, 10'b0, `FNC_LW, 5'b0, `OPC_LOAD};
		read_addr = {4'b0100, 26'b0 ,2'b0};
		dmem_data = 32'hAABBCCDD;
		bios_data = 32'h11223344;
		#1;
		$display("LW bios dout: %h", mem_dout);
		// lw
		instruction_3 = {7'b0, 10'b0, `FNC_LW, 5'b0, `OPC_LOAD};
		read_addr = {4'b0001, 26'b0 ,2'b11};
		dmem_data = 32'hAABBCCDD;
		bios_data = 32'h11223344;
		#1;
		$display("LW 11 dmem dout: %h", mem_dout);
		

		// LH
		instruction_3 = {7'b0, 10'b0, `FNC_LH, 5'b0, `OPC_LOAD};
		read_addr = {4'b0001, 26'b0 ,2'b0};
		dmem_data = 32'hAABBCCDD;
		bios_data = 32'h11223344;
		#1;
		$display("LH 00 dmem dout: %h", mem_dout);
		// LH
		instruction_3 = {7'b0, 10'b0, `FNC_LH, 5'b0, `OPC_LOAD};
		read_addr = {4'b0100, 26'b0 ,2'b0};
		dmem_data = 32'hAABBCCDD;
		bios_data = 32'h11223344;
		#1;
		$display("LH 00 bios dout: %h", mem_dout);



		// LH
		instruction_3 = {7'b0, 10'b0, `FNC_LH, 5'b0, `OPC_LOAD};
		read_addr = {4'b0001, 26'b0 ,2'b01};
		dmem_data = 32'hAABBCCDD;
		bios_data = 32'h11223344;
		#1;
		$display("LH 01 dmem dout: %h", mem_dout);
		// LH
		instruction_3 = {7'b0, 10'b0, `FNC_LH, 5'b0, `OPC_LOAD};
		read_addr = {4'b0100, 26'b0 ,2'b01};
		dmem_data = 32'hAABBCCDD;
		bios_data = 32'h11223344;
		#1;
		$display("LH 01 bios dout: %h", mem_dout);

		// LB
		instruction_3 = {7'b0, 10'b0, `FNC_LB, 5'b0, `OPC_LOAD};
		read_addr = {4'b0001, 26'b0 ,2'b01};
		dmem_data = 32'hAABBCCDD;
		bios_data = 32'h11223344;
		#1;
		$display("LB 01 dmem dout: %h", mem_dout);
		// LB
		instruction_3 = {7'b0, 10'b0, `FNC_LB, 5'b0, `OPC_LOAD};
		read_addr = {4'b0100, 26'b0 ,2'b01};
		dmem_data = 32'hAABBCCDD;
		bios_data = 32'h11223344;
		#1;
		$display("LB 01 bios dout: %h", mem_dout);


		// LB
		instruction_3 = {7'b0, 10'b0, `FNC_LB, 5'b0, `OPC_LOAD};
		read_addr = {4'b0001, 26'b0 ,2'b11};
		dmem_data = 32'hAABBCCDD;
		bios_data = 32'h11223344;
		#1;
		$display("LB 11 dmem dout: %h", mem_dout);
		// LB
		instruction_3 = {7'b0, 10'b0, `FNC_LB, 5'b0, `OPC_LOAD};
		read_addr = {4'b0100, 26'b0 ,2'b11};
		dmem_data = 32'hAABBCCDD;
		bios_data = 32'h11223344;
		#1;
		$display("LB 11 bios dout: %h", mem_dout);
	end


endmodule