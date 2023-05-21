// Write your assembly program for Problem 1 (a) #3 here.

//Test seq instruction
//11100 sss ttt ddd xx | SEQ Rd, Rs, Rt | if (Rs == Rt) then Rd <- 1 else Rd <- 0

lbi r1, 1
lbi r2, 3
addi r3, r1, 2
addi r4, r1, 3
seq r5, r2, r3
nop
nop
nop
nop
halt
