		.text
		.align  2
		.globl  _start

_start:
		nop
		nop
		addi x5, x0, 2	# x5 = 2
		addi x6, x0, 5	# x6 = 5
		nop
		sw x5, 16(x3)	# 16(x0) = x5 = 2
		sw x6, 32(x7)	# 32(x0) = x6 = 5 
		nop
		nop
		nop

loop:
		lw x8, 32(x7)	# x8 = 16(x0) = 5
		lw x9, 16(x3)	# x9 = 32(x0) = 2
		jal x0, loop
		nop
		nop
		nop

		.end _start
		.size _start, .-_start
