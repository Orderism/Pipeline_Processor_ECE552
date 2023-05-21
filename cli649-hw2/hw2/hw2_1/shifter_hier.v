/*
    CS/ECE 552 Spring '23
    Homework #2, Problem 1
    
    The wrapper module around the barrel shifter to combine it with 
    the clock and reset.
 */
`default_nettype none
module shifter_hier(In, ShAmt, Oper, Out);

    // declare constant for size of inputs, outputs, and # bits to shift
    parameter OPERAND_WIDTH  = 16;
    parameter SHAMT_WIDTH    =  4;
    parameter NUM_OPERATIONS =  2;   

    input wire [OPERAND_WIDTH -1:0] In   ; 
    input wire [SHAMT_WIDTH   -1:0] ShAmt; 
    input wire [NUM_OPERATIONS-1:0] Oper ; 
    output wire [OPERAND_WIDTH -1:0] Out  ; 

    // Signals for clkrst module
    wire clk;
    wire rst;
    wire err;

    assign err = 1'b0;
   
    shifter #(.OPERAND_WIDTH(OPERAND_WIDTH),
              .SHAMT_WIDTH(SHAMT_WIDTH),
              .NUM_OPERATIONS(NUM_OPERATIONS)) 
            DUT (.InBS(In), .ShAmt(ShAmt), .ShiftOper(Oper), .OutBS(Out));

    clkrst c0(.clk(clk),
              .rst(rst),
              .err(err));

   
endmodule // shifter_hier
`default_nettype wire
