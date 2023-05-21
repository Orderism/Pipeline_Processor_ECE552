module fullAdder1b(inA, inB, cIn, s, cOut);
// Label the inputs as inA, inB, and cIn (carry-in). Label the outputs as s and cOut
input wire inA;
input wire inB;
input wire cIn;
output wire s, cOut;

//Sum of the A and B
wire tempS_1;

xor2 xor_AB(.out(tempS_1), .in1(inA), .in2(inB));
xor2 xor_Sum(.out(s), .in1(cIn), .in2(tempS_1));

//Carry out of the A and B
wire tempCout_1;
wire tempCout_2;

and2 and_CS(.out(tempCout_1), .in1(cIn), .in2(tempS_1));
and2 and_AB(.out(tempCout_2), .in1(inA), .in2(inB));
or2 or_out(.out(cOut), .in1(tempCout_1), .in2(tempCout_2));

endmodule

