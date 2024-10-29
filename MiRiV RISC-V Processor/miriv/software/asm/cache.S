		.text
		.align  2
		.globl  _start
	
		# Testcase(s) for cache implementation

_start:
		nop
		addi x5, x0, 1000	# x5 = 2
		addi x6, x0, 5	# x6 = 5
		nop
		sw x5, 4(x3)	# 16(x0) = x5 = 2	<= WRITE_MISS
		sw x6, 0(x7)	# 32(x0) = x6 = 5 	<= WRITE_MISS
		nop
		nop
		nop
		lw x8, 0(x7)	# x8 = 16(x0) = 5	<= READ_MISS
	#	lw x9, 4(x3)	# x9 = 32(x0) = 2	<= READ_MISS
		lb x9, 4(x3)	# x9 = 32(x0) = 2	<= READ_MISS BYTE
		lw x8, 0(x7)	# x8 = 16(x0) = 5	<= READ_HIT
		nop
		nop
		nop
		sw x5, 4(x3)	# x5 = 16(x0) = 2	<= WRITE_HIT
		nop
		nop
		nop	
		lw x6, 100(x3)	# x6 = 100(x3) = 0	<= DIRTY_READ_MISS

loop:
		jal x0, loop
		nop	
		nop
		nop

		.end _start
		.size _start, .-_start
		