/*
    CS/ECE 552 Spring '23
    Homework #1, Problem 2

    3 input AND
*/
`default_nettype none
module and3 (out,in1,in2,in3);
    output wire out;
    input wire in1,in2,in3;
    assign out = (in1 & in2 & in3);
endmodule
`default_nettype wire
