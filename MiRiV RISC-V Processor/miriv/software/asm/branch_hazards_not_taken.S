		.text
		.align  2
		.globl  _start

# Testcase Nr.4

_start:
        addi x1, x3, 7      # x1 = 7
        beq x1, x5, loop    # x1 = 7, x5 = 0 -> not taken
        addi x1, x1, 7      # x1 = 14
        nop
		nop

loop:
        j loop
		nop
		nop

		.end _start
		.size _start, .-_start
		