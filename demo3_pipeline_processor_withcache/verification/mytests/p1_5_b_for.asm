lbi r0, 5
addi r0, r0, -5         // r0 = 0x0000
beqz r0, .go1           // taken
halt
lbi r5, 100
.go1:
lbi r1, -1              // r1 = 0xffff
slt r2, r1, r0          // r2 = 0x0001
st r0, r0, 0            // doesn't execute
halt
