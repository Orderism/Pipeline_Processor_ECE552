/*
    CS/ECE 552 Spring '23
    Homework #1, Problem 2

    2 input XOR
*/
`default_nettype none
module xor2 (out,in1,in2);
    output wire out;
    input wire in1,in2;
    assign out = in1 ^ in2;
endmodule
`default_nettype none

