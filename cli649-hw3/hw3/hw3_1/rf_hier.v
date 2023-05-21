/*
   CS/ECE 552, Spring '23
   Homework #3, Problem #1
  
   Wrapper module around 8x16b register file.

   YOU SHALL NOT EDIT THIS FILE. ANY CHANGES TO THIS FILE WILL
   RESULT IN ZERO FOR THIS PROBLEM.
*/
`default_nettype none
module rf_hier (
                // Outputs
                read1Data, read2Data, 
                // Inputs
                read1RegSel, read2RegSel, writeRegSel, writeData, writeEn
                );

   input wire [2:0]   read1RegSel;
   input wire [2:0]   read2RegSel;
   input wire [2:0]   writeRegSel;
   input wire [15:0]  writeData;
   input wire         writeEn;

   output wire [15:0] read1Data;
   output wire [15:0] read2Data;

   wire          clk, rst;
   wire          err;

   // Ignore err for now
   clkrst clk_generator(.clk(clk), .rst(rst), .err(err) );
   rf rf0 (
           // Outputs
           .read1OutData                 (read1Data[15:0]),
           .read2OutData                 (read2Data[15:0]),
           .err                          (err),
           // Inputs
           .clk                          (clk),
           .rst                          (rst),
           .read1RegSel                  (read1RegSel[2:0]),
           .read2RegSel                  (read2RegSel[2:0]),
           .writeRegSel                  (writeRegSel[2:0]),
           .writeInData                  (writeData[15:0]),
           .writeEn                      (writeEn));

endmodule
`default_nettype wire
