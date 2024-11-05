addi x1, x0, 1
here:	addi x2, x0, 2
addi x3, x0, 8
addi x4, x0, 4
addi x5, x0, 5
nop
nop
add x3, x1, x2
bne x5,	x0, here #
ori x6, x0, 8
ori x7, x0, 8
ori x8, x0, 8
ori x9, x0, 8
nop
nop
nop
nop
sw x3, 100(x0)
wfi

