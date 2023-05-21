module mux4_1(out, inputA, inputB, inputC, inputD, sel);

//sel= 2'b00,output=inputA
//sel= 2'b01,output=inputB
//sel= 2'b10,output=inputC
//sel= 2'b11,output=inputD
//we should prepare the result of MuxAB and MuxCD, then these 2 output will be regard as the input of the mux_all, and the sel[1] decided which will be output finally

//input & output declaration
input wire inputA, inputB, inputC, inputD;
input wire [1:0] sel;
output wire out;

//temp result store
wire tempAB;//store the result A?B?
wire tempCD;//store the result C?D?


//first mux for the sel[1], to select the AB & CD, which group will be output
//terminal of the mux2_1: module mux2_1(out, inputA, inputB, sel);
mux2_1 Mux_all(.out(out), .inputA(tempAB), .inputB(tempCD), .sel(sel[1]));

//sel[0] as selection signal in mux for AB
mux2_1 Mux_AB(.out(tempAB), .inputA(inputA), .inputB(inputB), .sel(sel[0]));

//sel[0] also as selection signal in mux for CD
mux2_1 Mux_CD(.out(tempCD), .inputA(inputC), .inputB(inputD), .sel(sel[0]));



endmodule