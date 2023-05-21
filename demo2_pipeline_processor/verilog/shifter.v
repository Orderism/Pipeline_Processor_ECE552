/*
    CS/ECE 552 Spring '23
    Homework #2, Problem 1
    
    A barrel shifter module.  It is designed to shift a number via rotate
    left, shift left, shift right arithmetic, or shift right logical based
    on the 'Oper' value that is passed in.  It uses these
    shifts to shift the value any number of bits.
 */
`default_nettype none
module shifter (InBS, ShAmt, ShiftOper, OutBS);

    // declare constant for size of inputs, outputs, and # bits to shift
    parameter OPERAND_WIDTH = 16;
    parameter SHAMT_WIDTH   =  4;
    parameter NUM_OPERATIONS = 2;

    input wire [OPERAND_WIDTH -1:0] InBS;  // Input operand
    input wire [SHAMT_WIDTH   -1:0] ShAmt; // Amount to shift/rotate
    input wire [NUM_OPERATIONS-1:0] ShiftOper;  // Operation type
    output wire [OPERAND_WIDTH -1:0] OutBS;  // Result of shift/rotate

   /* YOUR CODE HERE */
   //get 4 kind of the structure from the sub-structure
   wire [15:0] result_ls, result_lr, result_rsl, result_rr;
   shift_left ls1(.OutBS(result_ls), .InBS(InBS), .ShAmt(ShAmt));
   rotate_left lr1(.OutBS(result_lr), .InBS(InBS), .ShAmt(ShAmt));
   shift_right_logic rsl1(.OutBS(result_rsl), .InBS(InBS), .ShAmt(ShAmt));
   rotate_right rr1(.OutBS(result_rr), .InBS(InBS), .ShAmt(ShAmt));


// Output selection based on the opercode
assign OutBS=(ShiftOper==2'b00)? result_ls: (ShiftOper==2'b01)? result_rsl: (ShiftOper==2'b10)? result_lr: result_rr; 








endmodule
`default_nettype wire
