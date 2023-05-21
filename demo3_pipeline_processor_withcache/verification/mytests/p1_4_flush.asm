lbi r1, 0x1
lbi r2, 0x0
lbi r3, 0x2
nop
nop
nop
nop
j 0x0002 //only flush the next add, jump to label1
add r4, r1, r3
add r5, r1, r3
nop
nop
nop
nop
halt



.label1:
addi r6, r2, 0x1
nop
nop
nop
halt
