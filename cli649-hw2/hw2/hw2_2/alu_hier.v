/*
    CS/ECE 552 Spring '23
    Homework #2, Problem 2

    A wrapper for a multi-bit ALU module combined with clkrst.
*/
`default_nettype none
module alu_hier(InA, InB, Cin, Oper, invA, invB, sign, Out, Zero, Ofl);

    // declare constant for size of inputs, outputs, and operations
    parameter OPERAND_WIDTH = 16;    
    parameter NUM_OPERATIONS = 3;
       
    input wire [OPERAND_WIDTH -1:0] InA ; // Input operand A
    input wire [OPERAND_WIDTH -1:0] InB ; // Input operand B
    input wire                       Cin ; // Carry in
    input wire  [NUM_OPERATIONS-1:0] Oper; // Operation type
    input wire                       invA; // Signal to invert A
    input wire                       invB; // Signal to invert B
    input wire                       sign; // Signal for signed operation
    output wire [OPERAND_WIDTH -1:0] Out ; // Result of comput wireation
    output wire                      Zero; // Signal if Out is 0
    output wire                      Ofl ; // Signal if overflow occured

    // clkrst signals
    wire clk;
    wire rst;
    wire err;

    assign err = 1'b0;

    alu #(.OPERAND_WIDTH(OPERAND_WIDTH),
          .NUM_OPERATIONS(NUM_OPERATIONS)) 
        DUT (// Outputs
             .Out(Out),
             .Ofl(Ofl), 
             .Zero(Zero),
             // Inputs
             .InA(InA), 
             .InB(InB), 
             .Cin(Cin), 
             .Oper(Oper), 
             .invA(invA), 
             .invB(invB), 
             .sign(sign));
   
    clkrst c0(// Outputs
              .clk                       (clk),
              .rst                       (rst),
              // Inputs
              .err                       (err)
              );

endmodule // alu_hier
`default_nettype wire
