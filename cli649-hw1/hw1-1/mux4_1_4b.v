module mux4_1_4b(out, inputA, inputB, inputC, inputD, sel);

input wire [3:0]inputA, inputB, inputC, inputD;
input wire [1:0]sel;
output wire [3:0]out;
//module mux4_1(out, inputA, inputB, inputC, inputD, sel);
mux4_1 muxsinglebit[3:0](.out(out), .inputA(inputA), .inputB(inputB), .inputC(inputC), .inputD(inputD), .sel(sel));


endmodule