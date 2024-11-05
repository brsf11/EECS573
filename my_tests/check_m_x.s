nop
li sp, 2048
nop
nop
nop
nop
addi x1, x0, 1 #r1=1
addi x2, x0, 1 #r2=1
addi x3, x0, 8 #r3=8
addi x4, x0, 4 #r4=4
ori x5, x0, 5  #r5=5
nop
nop
lbu x3, 0(sp) #r3 = mem(2048) =0
#add x3, x1, x2 #r3=r1+r2=2
add x4, x2, x3 #r4=r2+r3=1
add x5, x4, x3 #r5=r4+r3=1+0=1
add x2, x1, x1 #r2=r1+r1=2
nop
sw x3, 100(x0)
wfi

