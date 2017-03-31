
`ifndef MUX_SELECTS
`define MUX_SELECTS

`define ALU_IN_MUX_SEL_WIDTH	4
`define ALU_IN_MUX_RF 			4'b0000
`define ALU_IN_MUX_IMM_I 		4'b0001
`define ALU_IN_MUX_IMM_S		4'b0010
`define ALU_IN_MUX_IMM_U 		4'b0011
`define ALU_IN_MUX_IMM_UJ 		4'b0100
`define ALU_IN_MUX_PC		    4'b0101
`define ALU_IN_MUX_NULL		    4'b0110
`define ALU_IN_MUX_FW_WB	    4'b0111


`define WB_MUX_SEL_WIDTH	3
`define WB_ALU				3'b000
`define WB_MEM				3'b001
`define WB_PC				3'b011
`define WB_NULL				3'b100




`define PC_MUX_SEL_WIDTH	2
`define PC_MUX_PLUS_4		2'b00
`define PC_MUX_BRANCH		2'b01
`define PC_MUX_J			2'b10


`endif //MUX_SELECTS
