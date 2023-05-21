module B1register (wdata, writeEn, clk, rst, rdata);
input clk,rst;
input wdata, rdata;
input writeEn;
wire writeInData_En;
assign writeInData_En= writeEn? wdata: rdata;
dff dff_en(.clk(clk), .rst(rst), .d(writeInData_En), .q(rdata));

endmodule