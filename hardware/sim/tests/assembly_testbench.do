start assembly_testbench
file copy -force ../../../software/assembly_tests/assembly_tests.mif imem_blk_ram.mif
file copy -force ../../../software/assembly_tests/assembly_tests.mif dmem_blk_ram.mif
file copy -force ../../../software/assembly_tests/assembly_tests.mif bios_mem.mif
add wave assembly_testbench/*
add wave assembly_testbench/CPU/*
add wave assembly_testbench/CPU/alu_in_muxes/*
add wave assembly_testbench/CPU/rf/*
add wave assembly_testbench/CPU/rf/reg_file/*
add wave assembly_testbench/CPU/stage2/*
add wave assembly_testbench/CPU/control_unit/*
add wave assembly_testbench/CPU/cycle_counter/*
run 100us
