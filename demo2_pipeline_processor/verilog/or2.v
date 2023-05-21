/*
    CS/ECE 552 Spring '23
    Homework #1, Problem 2

    2 input OR
*/
`default_nettype none
module or2 (out,in1,in2);
    output wire out;
    input wire in1,in2;
    assign out = (in1 | in2);
endmodule
`default_nettype wire
