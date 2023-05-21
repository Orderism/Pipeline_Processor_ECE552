module B8register (wdata, writeEn, clk, rst, rdata);

localparam wb=8;
input clk,rst;
input [wb-1:0]wdata, rdata;
input writeEn;
wire[wb-1:0] writeInData_En;
assign writeInData_En= writeEn? wdata: rdata;
dff dff_en[wb-1:0](.clk(clk), .rst(rst), .d(writeInData_En), .q(rdata));

endmodule