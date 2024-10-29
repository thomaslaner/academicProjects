		.text
		.align  2
		.globl  _start

# Testcase Nr.1

_start:
		addi x1, x0, 7	# x1 = 7
        addi x2, x0, 5	# x2 = 5
        and  x1, x2, x1	# x1 = 5 
		nop
		nop

loop:
		j loop
		nop
		nop
		nop


		.end _start
		.size _start, .-_start
