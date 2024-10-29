		.text
		.align  2
		.globl  _start

# Testcase Nr.6

_start:
        addi x1, x0, 7   # x1 = 7
		addi x1, x1, 20  # x1 = 27
        addi x1, x1, 5   # x1 = 32 
		nop
		nop

loop:
        j loop
		nop
		nop
		nop

		.end _start
		.size _start, .-_start

