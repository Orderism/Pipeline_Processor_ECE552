/*
   CS/ECE 552, Spring '23
   Homework #3, Problem #1
  
   This module creates a 1-bit D-flipflop (DFF).

   YOU SHALL NOT EDIT THIS FILE. ANY CHANGES TO THIS FILE WILL
   RESULT IN ZERO FOR THIS PROBLEM.
*/
`default_nettype none
module dff (
            // Output
            q,
            // Inputs
            d, clk, rst
            );

    output wire    q;
    input wire     d;
    input wire     clk;
    input wire     rst;

    reg            state;

    assign #(1) q = state;

    always @(posedge clk) begin
      state = rst? 0 : d;
    end

endmodule
`default_nettype wire
