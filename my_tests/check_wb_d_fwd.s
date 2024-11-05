addi x1, x0, 1
addi x2, x0, 2
addi x3, x0, 8
addi x4, x0, 4
ori x5, x0, 5
nop
nop
add x3, x1, x2
nop
nop
add x4, x3, x3
nop
nop
sw x3, 100(x0)
wfi

