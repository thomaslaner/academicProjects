		.text
		.align  2
		.globl  _start

# Testcase Nr.2

_start:
        addi x1, x0, 7  # x1 = 7		# 0
        sw x1, 0(x5)     				# 4
		nop								# 8
		nop								# 12

loop:
        lw x6, 0(x5)    # x6 = 7		# 16
        addi x4, x6, 5  # x4 = 12		# 20
        j loop							# 24
		nop								# 28
		nop								# 32
		nop								# 36
										# 40 -> 16
		.end _start
		.size _start, .-_start
		