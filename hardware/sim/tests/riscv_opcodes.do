radix define riscV {
	32'b0000000??????????000?????0110011 "ADD" -color {Green},
	32'b0100000??????????000?????0110011 "SUB" -color {Green},
	32'b0000000??????????001?????0110011 "SLL" -color {Green},
	32'b0000000??????????010?????0110011 "SLT" -color {Green},
	32'b0000000??????????011?????0110011 "SLTU" -color {Green},
	32'b0000000??????????100?????0110011 "XOR" -color {Green},
	32'b0000000??????????101?????0110011 "SRL" -color {Green},
	32'b0100000??????????101?????0110011 "SRA" -color {Green},
	32'b0000000??????????110?????0110011 "OR" -color {Green},
	32'b0000000??????????111?????0110011 "AND" -color {Green},
	32'b?????????????????000?????0010011 "ADDI" -color {Green},
	32'b?????????????????010?????0010011 "SLTI" -color {Green},
	32'b?????????????????011?????0010011 "SLTIU" -color {Green},
	32'b?????????????????100?????0010011 "XORI" -color {Green},
	32'b?????????????????110?????0010011 "ORI" -color {Green},
	32'b?????????????????111?????0010011 "ANDI" -color {Green},
	32'b0000000??????????001?????0010011 "SLLI" -color {Green},
	32'b0000000??????????101?????0010011 "SRLI" -color {Green},
	32'b0100000??????????101?????0010011 "SRAI" -color {Green},
	32'b?????????????????010?????0100011 "SW" -color {Green},
	32'b?????????????????001?????0100011 "SH" -color {Green},
	32'b?????????????????000?????0100011 "SB" -color {Green},
	32'b?????????????????000?????0000011 "LB" -color {Green},
	32'b?????????????????001?????0000011 "LH" -color {Green},
	32'b?????????????????010?????0000011 "LW" -color {Green},
	32'b?????????????????100?????0000011 "LBU" -color {Green},
	32'b?????????????????101?????0000011 "LHU" -color {Green},
	32'b?????????????????000?????1100011 "BEQ" -color {Green},
	32'b?????????????????001?????1100011 "BNE" -color {Green},
	32'b?????????????????100?????1100011 "BLT" -color {Green},
	32'b?????????????????101?????1100011 "BGE" -color {Green},
	32'b?????????????????110?????1100011 "BLTU" -color {Green},
	32'b?????????????????111?????1100011 "BGEU" -color {Green},
	32'b?????????????????000?????1100111 "JALR" -color {Green},
	32'b?????????????????????????1101111 "JAL" -color {Green},
	32'b?????????????????????????0010111 "AUIPC" -color {Green},
	32'b?????????????????????????0110111 "LUI" -color {Green},
	32'b00000000000000000000000000000000 "NULL" -color {Red},
	-default hex
	-defaultcolor {Red}
}
