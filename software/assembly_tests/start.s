.section    .start
.global     _start

_start:

# Follow a convention
# x1 = result register 1
# x2 = result register 2
# x10 = argument 1 register
# x11 = argument 2 register
# x20 = flag register

# Test ADD

li x10, 100		# Load argument 1 (rs1)
li x11, 200		# Load argument 2 (rs2)
add x1, x10, x11	# Execute the instruction being tested
li x20, 1		# Set the flag register to stop execution and inspect the result register
			# Now we check that x1 contains 300


# Test BEQ
li x2, 100		# Set an initial value of x2
beq x0, x0, branch1	# This branch should succeed and jump to branch1
li x2, 123		# This shouldn't execute, but if it does x2 becomes an undesirable value
li x11, 200		# Load argument 2 (rs2)
branch1: li x1, 500	# x1 now contains 500
li x20, 2		# Set the flag register
			# Now we check that x1 contains 500 and x2 contains 100

# Test BNE followed by JAL
li x2, 100		# Set an initial value of x2
li x1, 0		# Set an initial value of x2
bne x0, x0, branch2	# This branch should succeed and jump to branch1
j j1			# this jump should NOT be taken
li x2, 123		# This shouldn't execute, but if it does x2 becomes an undesirable value
li x11, 200		# Load argument 2 (rs2)
branch2: li x1, 500	# x1 now contains 500
li x20, 3		# Set the flag register
			# Now we check that x1 contains 500 and x2 contains 100

j testfw
j1: li x2, 234 # this code should NOT be executed
li x1, 600	# x1 now contains 500
li x20, 3		# Set the flag register


testfw: li x1, 1
slli x1, x1, 28
sw x10, 100(x1)     # store x10 into memory
sw x11, 104(x1)     # store x10 into memory
lw x2, 100(x1)   # load to register x2
lw x3, 104(x1)   # load to register x2
bne x2,x3, branch3
li x1, 100
li x20, 4 # should not be executed


branch3:
li x1, 200
li x20, 4 

addi x1, x0, 10
addi x1, x1, 10
addi x2, x1, 10
li x20, 6

addi x1, x0, 10
addi x2, x1, 10
add x3, x1, x2
li x20, 7

Done: j Done

