/*
   CS/ECE 552, Spring '23
   Homework #3, Problem #2
  
   This module creates a wrapper around the 8x16b register file, to do
   do the bypassing logic for RF bypassing.
*/
`default_nettype none
module rf_bypass (
                  // Outputs
                  read1OutData, read2OutData, err,
                  // Inputs
                  clk, rst, read1RegSel, read2RegSel, writeRegSel, writeInData, writeEn
                  );

   input wire       clk, rst;
   input wire [2:0] read1RegSel;
   input wire [2:0] read2RegSel;
   input wire [2:0] writeRegSel;
   input wire [15:0] writeInData;
   input wire        writeEn;

   output wire [15:0] read1OutData;
   output wire [15:0] read2OutData;
   output wire        err;

   /* YOUR CODE HERE */
localparam bw=16;// changeable bitwidth

//based on the rf 
//actually just confirm when read and write at same time, send the writedata to read
//a mux for the read1 and read2 output

//module rf (read1OutData, read2OutData, err, clk, rst, read1RegSel, read2RegSel, writeRegSel, writeInData, writeEn);
wire [15:0] read1_unf, read2_unf;//unforwarding read data
rf rf_orginal(.read1OutData(read1_unf), .read2OutData(read2_unf), .err(err), .clk(clk),
              .rst(rst), .read1RegSel(read1RegSel), .read2RegSel(read2RegSel), .writeRegSel, 
              .writeInData(writeInData), .writeEn(writeEn));

assign read1OutData=((writeRegSel==read1RegSel) & (writeEn))? writeInData : read1_unf;
assign read2OutData=((writeRegSel==read2RegSel) & (writeEn))? writeInData : read2_unf;


endmodule
`default_nettype wire
