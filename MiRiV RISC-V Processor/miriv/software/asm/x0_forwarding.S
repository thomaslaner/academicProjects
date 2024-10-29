		.text
		.align  2
		.globl  _start

# Testcase Nr.5

_start:
		addi x0, x0, 3  # x0 = 0
        addi x1, x0, 7  # x1 = 7
		nop
		nop

loop:
        j loop
		nop
		nop
		nop

		.end _start
		.size _start, .-_start