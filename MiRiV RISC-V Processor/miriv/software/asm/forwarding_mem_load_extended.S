		.text
		.align  2
		.globl  _start

# Testcase Nr.2

_start:
        addi x1, x0, 7   # x1 = 7			# 0
		addi x2, x1, 24  # x2 = 31			# 4
        sw x1, 0(x7)   	 # 0(x7) = 7		# 8
		sw x2, 4(x3)     # 4(x3) = 31		# 12
		nop									# 16
		nop									# 20

loop:
		lw x8, 0(x7)     # x8 = 31			# 24
		lw x6, 4(x3)     # x6 = 7			# 28
        add x4, x6, x8   # x4 = 38			# 32
        j loop								# 36
		nop									# 40
		nop									# 44
		nop									# 48
											# 52 -> 24
		.end _start
		.size _start, .-_start
		