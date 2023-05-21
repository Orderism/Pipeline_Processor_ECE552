/*
    CS/ECE 552 Spring '23
    Homework #2, Problem 2

    A multi-bit ALU module (defaults to 16-bit). It is designed to choose
    the correct operation to perform on 2 multi-bit numbers from rotate
    left, shift left, shift right arithmetic, shift right logical, add,
    or, xor, & and.  Upon doing this, it should output the multi-bit result
    of the operation, as well as drive the output signals Zero and Overflow
    (OFL).
*/
`default_nettype none
module alu (InA, InB, Cin, Oper, invA, invB, sign, Out, en);

    parameter OPERAND_WIDTH = 16;    
       
    input wire  [OPERAND_WIDTH -1:0] InA ; // Input wire operand A
    input wire  [OPERAND_WIDTH -1:0] InB ; // Input wire operand B
    input wire                       Cin ; // Carry in
    input wire  [3:0] Oper; // Operation type
    input wire                       invA; // Signal to invert A
    input wire                       invB; // Signal to invert B
    input wire                       sign; // Signal for signed operation
    output wire [OPERAND_WIDTH -1:0] Out ; // Result of comput wireation
           wire                      Ofl ; // Signal if overflow occured
           wire                      Zero; // Signal if Out is 0


//ALU enable
input wire en;
wire [15:0]Out_alu;

//inv A and inv B
wire [15:0] A,B;// the actually A, B which has been used in ALU
assign A=(invA)? ~InA : InA;
assign B=(invB)? ~InB : InB;

//result from shifter (000 to 011)
//
//module shifter (InBS, ShAmt, ShiftOper, OutBS);
wire [15:0] result_s;//result from shifter
shifter ALU_shifter(.OutBS(result_s), .InBS(A), .ShiftOper(Oper[1:0]), .ShAmt(B[3:0]));

//result from adder (100)
//module  cla16b(inA, inB, sum, cIn, cOut);
wire [15:0] result_a;//adder result
wire adder_cOut;// for unsign overflow test
cla16b ALU_adder(.sum(result_a), .cIn(Cin), .inA(A), .inB(B), .cOut(adder_cOut));

//result from and, or, xor (101,110,111)
wire [15:0] result_and, result_or, result_xor;
assign result_and = A & B;
assign result_or = ({A[7:0],8'd0}) | B;//for the SLBI
assign result_xor = A^B; 

//result for BTR
wire [15:0] result_btr;
assign result_btr = {A[0],A[1],A[2],A[3],A[4],A[5],A[6],A[7],A[8],A[9],A[10],A[11],A[12],A[13],A[14],A[15]};

//result of the slt, sle ,seq
wire [15:0] result_slt, result_sle, result_seq;
assign result_seq= (A==B)?16'd1:16'd0;
assign result_slt= (((A[15]==~B[15])&result_a[15]
                    |(A[15]==(B[15]) &(A[15]))
                    ))?16'd1:16'd0;





assign result_sle= ((result_slt) | (A==~B))?16'd1:16'd0;



//ALU logic
assign Out=(Oper[3:2]==2'b00)? result_s:
           (Oper==4'b0100)? result_a:
           (Oper==4'b0101)? result_and:
           (Oper==4'b0110)? result_or:
           (Oper==4'b0111)? result_xor:
           (Oper==4'b1000)? result_btr:
           (Oper==4'b1001)? result_seq:
           (Oper==4'b1010)? result_slt:
           (Oper==4'b1011)? result_sle:  
           (Oper==4'b1100)? adder_cOut:         //SCO=unsigned adder_cOut 
           Out;
//enable lock
//assign Out=Out & {16{en}}; //Out_alu

//Zero logic
assign Zero=(Out==16'd0)? 1'b1 : 1'b0;

//Overflow logic
wire both_neg, both_pos;
wire Ofl_sign, Ofl_unsign;// for sign and unsign both need to test the over flow
assign both_neg=(A[15] & B[15])? 1'b1 : 1'b0;  
assign both_pos=((~A[15]) & (~B[15]))? 1'b1 : 1'b0; 
assign Ofl_sign=((both_neg) & (~Out[15])) | ((both_pos) & (Out[15]));
assign Ofl=(sign)? Ofl_sign: adder_cOut;

  
endmodule
`default_nettype wire
