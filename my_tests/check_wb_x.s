addi x1, x0, 1 #r1=1
addi x2, x0, 1 #r2=1
addi x3, x0, 8 #r3=8
addi x4, x0, 4 #r4=4
ori x5, x0, 5  #r5=5
nop
nop
add x3, x1, x2 #r3=r1+r2=2
nop
add x4, x3, x3 #r4=r3+r3=4
nop
nop
sw x3, 100(x0)
wfi

