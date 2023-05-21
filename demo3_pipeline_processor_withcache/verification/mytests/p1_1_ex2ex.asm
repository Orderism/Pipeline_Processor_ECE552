// Write your assembly program for Problem 1 (a) #1 here.

//Test seq instruction
//11100 sss ttt ddd xx | SEQ Rd, Rs, Rt | if (Rs == Rt) then Rd <- 1 else Rd <- 0

lbi r1, 1
lbi r2, 2
add r3, r2, r2
nop
nop
nop
nop
halt
