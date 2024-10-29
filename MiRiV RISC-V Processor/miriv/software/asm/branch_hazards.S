		.text
		.align  2
		.globl  _start

#	Testcase Nr.3

_start:
loop:
		j loop
		addi x1, x1, 1 	# x1 = 0
        addi x2, x2, 1	# x2 = 0
        and  x3, x3, 1	# x3 = 0

		.end _start
		.size _start, .-_start
