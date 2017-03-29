start assembly_testbench
file copy -force ../../../software/assembly_tests/assembly_tests.mif imem_blk_ram.mif
file copy -force ../../../software/assembly_tests/assembly_tests.mif dmem_blk_ram.mif
file copy -force ../../../software/assembly_tests/assembly_tests.mif bios_mem.mif
add wave assembly_testbench/*
add wave assembly_testbench/CPU/*
add wave assembly_testbench/CPU/alu_in_muxes/*
add wave assembly_testbench/CPU/rf/*
run 100us

