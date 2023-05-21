/*
    CS/ECE 552 Spring '23
    Homework #1, Problem 1

    2 input NAND
*/
`default_nettype none
module nand2 (out,in1,in2);
    output wire out;
    input wire in1,in2;
    assign out = ~(in1 & in2);
endmodule
`default_nettype wire
