lbi r1, 1
lbi r2, 0
lbi r3, 2
jalr r2, 10 //should jump to add, skip one add instruction
addi r2, r7, 1
addi r3, r7, 2
lbi r4, 0
beqz r2 .label1 //only flush the next add, jump to label1
add r4, r1, r3
add r5, r1, r3
nop
nop
nop
nop
halt



.label1:
addi r6, r7, 1
nop
nop
nop
nop
halt
