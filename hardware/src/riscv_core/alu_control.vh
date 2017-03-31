
`ifndef ALU_CONTROL
`define ALU_CONTROL


`define ADD 	4'b0000
`define SUB 	4'b0001
`define AND 	4'b0010
`define OR 		4'b0011
`define XOR		4'b0100
`define SLL		4'b0101
`define SRL		4'b0111
`define SRA		4'b1000
`define LT		4'b1001
`define LTU 	4'b1010
`define GTE		4'b1011
`define GTEU 	4'b1100
`define EQ	 	4'b1101

// No operation, for instructions that don't
// need the ALU, for example LUI
`define NOP		4'b1111

`endif //ALU_CONTROL
