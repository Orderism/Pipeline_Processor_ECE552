lbi r1, 0xfc		//-4 in decimal
addi r1, r1, 0x01
bgez r1, .done          //after 4 total executions of add, go to halt
j 0x7fa
.done:
halt