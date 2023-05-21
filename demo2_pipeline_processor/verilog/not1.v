/*
    CS/ECE 552 Spring '23
    Homework #1, Problem 2

    1 input NOT
*/
`default_nettype none
module not1 (out, in1);
    output wire out;
    input wire in1;
    assign out = ~in1;
endmodule
`default_nettype wire
