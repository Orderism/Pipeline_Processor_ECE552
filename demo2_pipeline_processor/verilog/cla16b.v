module  cla16b(inA, inB, sum, cIn, cOut);
input wire [15:0]inA, inB;
input wire cIn;
output wire cOut;
output wire [15:0] sum;

//
wire cOut0_3, cOut4_7, cOut8_11, cOut12_15;


//module  cla4b(inA, inB, sum, cIn, cOut);
cla4b b0_3(.inA(inA[3:0]), .inB(inB[3:0]), .cIn(cIn), .cOut(cOut0_3), .sum(sum[3:0]));
cla4b b4_7(.inA(inA[7:4]), .inB(inB[7:4]), .cIn(cOut0_3), .cOut(cOut4_7), .sum(sum[7:4]));
cla4b b8_11(.inA(inA[11:8]), .inB(inB[11:8]), .cIn(cOut4_7), .cOut(cOut8_11), .sum(sum[11:8]));
cla4b b12_15(.inA(inA[15:12]), .inB(inB[15:12]), .cIn(cOut8_11), .cOut(cOut12_15), .sum(sum[15:12]));
assign cOut = cOut12_15;

endmodule