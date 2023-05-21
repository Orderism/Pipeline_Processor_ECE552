module mux2_1(out, inputA, inputB, sel);

input wire inputA, inputB;
input wire sel;
output wire out;


// standard 2-to-1 multiplexer, converted to not and nand gates
//sel=0, out=inputA
//sel=1, out=inputB

wire tempB;// temp B be used for preparation of B output
wire tempA_1;// temp A_1 &tempA_2 for preparation of A output
wire tempA_2;//

nand2 nand_B(tempB, sel, inputB);
not1 not_Sel(tempA_1, sel);
nand2 nand_A(tempA_2, tempA_1, inputA);
nand2 nand_ALL(out, tempB, tempA_2);

endmodule
