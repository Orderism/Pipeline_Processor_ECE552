/*
   CS/ECE 552, Spring '23
   Homework #3, Problem #1
  
   This module creates a 16-bit register file.  It has 1 write port, 2 read
   ports, 3 register select inputs, a write enable, a reset, and a clock
   input.  All register state changes occur on the rising edge of the
   clock. 
*/
`default_nettype none
module rf (
           // Outputs
           read1OutData_test, read2OutData_test, err,
           // Inputs
           clk, rst, read1RegSel, read2RegSel, writeRegSel, writeInData, writeEn
           );

   input wire       clk, rst;
   input wire [2:0] read1RegSel;
   input wire [2:0] read2RegSel;
   input wire [2:0] writeRegSel;
   input wire [15:0] writeInData;
   input wire        writeEn;

   output wire [15:0] read1OutData_test;
   output wire [15:0] read2OutData_test;
   output wire        err;


    localparam wb=16; 

   /* YOUR CODE HERE */
wire [wb-1:0] register[0:7];
wire [wb-1:0] outDataR0, outDataR1, outDataR2, outDataR3, outDataR4, outDataR5, outDataR6, outDataR7;

//Read
assign read1OutData_test= /*(read1RegSel == 3'h0) ? outDataR0 : 
                           (read1RegSel == 3'h1) ? outDataR1 :
                            (read1RegSel == 3'h2) ? outDataR2 :
                             (read1RegSel == 3'h3) ? outDataR3 : 
                              (read1RegSel == 3'h4) ? outDataR4 : 
                               (read1RegSel == 3'h5) ? outDataR5 : 
                                (read1RegSel == 3'h6) ? outDataR6 : outDataR7;*/    register[read1RegSel];
assign read2OutData_test=/*(read2RegSel == 3'h0) ? outDataR0 : 
                           (read2RegSel == 3'h1) ? outDataR1 :
                            (read2RegSel == 3'h2) ? outDataR2 :
                             (read2RegSel == 3'h3) ? outDataR3 : 
                              (read2RegSel == 3'h4) ? outDataR4 : 
                               (read2RegSel == 3'h5) ? outDataR5 : 
                                (read2RegSel == 3'h6) ? outDataR6 : outDataR7;*/    register[read2RegSel];





//write
wire [7:0]w_selen;//the result after the sel and the en
assign w_selen[0] = (writeRegSel==3'd0) & writeEn;
assign w_selen[1] = (writeRegSel==3'd1) & writeEn;
assign w_selen[2] = (writeRegSel==3'd2) & writeEn;
assign w_selen[3] = (writeRegSel==3'd3) & writeEn;
assign w_selen[4] = (writeRegSel==3'd4) & writeEn;
assign w_selen[5] = (writeRegSel==3'd5) & writeEn;
assign w_selen[6] = (writeRegSel==3'd6) & writeEn;
assign w_selen[7] = (writeRegSel==3'd7) & writeEn;

//module B16register (wdata, writeEn, clk, rst, rdata);

B16register edff0(.clk(clk), .rst(rst), .wdata(writeInData), .rdata(/*outDataR0*/register[0]), .writeEn(w_selen[0]));
B16register edff1(.clk(clk), .rst(rst), .wdata(writeInData), .rdata(/*outDataR1*/register[1]), .writeEn(w_selen[1]));
B16register edff2(.clk(clk), .rst(rst), .wdata(writeInData), .rdata(/*outDataR2*/register[2]), .writeEn(w_selen[2]));
B16register edff3(.clk(clk), .rst(rst), .wdata(writeInData), .rdata(/*outDataR3*/register[3]), .writeEn(w_selen[3]));
B16register edff4(.clk(clk), .rst(rst), .wdata(writeInData), .rdata(/*outDataR4*/register[4]), .writeEn(w_selen[4]));
B16register edff5(.clk(clk), .rst(rst), .wdata(writeInData), .rdata(/*outDataR5*/register[5]), .writeEn(w_selen[5]));
B16register edff6(.clk(clk), .rst(rst), .wdata(writeInData), .rdata(/*outDataR6*/register[6]), .writeEn(w_selen[6]));
B16register edff7(.clk(clk), .rst(rst), .wdata(writeInData), .rdata(/*outDataR7*/register[7]), .writeEn(w_selen[7]));












//err check
wire [15:0] err_16;
err_check ec[15:0] (.in(writeInData), .err(err_16));
assign err=(err_16==16'd0)? 1'b0:1'b1;



endmodule
`default_nettype wire
