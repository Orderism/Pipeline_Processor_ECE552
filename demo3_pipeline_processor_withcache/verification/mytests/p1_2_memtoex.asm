// Write your assembly program for Problem 1 (a) #2 here.

//Test seq instruction
//11100 sss ttt ddd xx | SEQ Rd, Rs, Rt | if (Rs == Rt) then Rd <- 1 else Rd <- 0

lbi r1, 1
lbi r2, 2
ld  r3, r2, 1
addi r5, r1, 2
addi r4, r3, 3 
nop
nop
nop
nop
halt
