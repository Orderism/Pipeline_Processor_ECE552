/*
   CS/ECE 552 Spring '22
  
   Filename        : wb.v
   Description     : This is the module for the overall Write Back stage of the processor.
*/
`default_nettype none
module wb (
   input wire [15:0]alu_result,
   input wire [15:0]MemRead_data,
   input wire MemReg,
   input wire HALT,

   input wire [15:0]PC_2_JAL,
   input wire JAL,
   output wire [15:0] Writeback_data
   );


   wire [15:0] outmux1;
  


   assign outmux1 = (MemReg)? MemRead_data:alu_result;//use Memreaddata or use alu data as the write back data
   assign Writeback_data = (HALT)? 16'd0:
                           (JAL)? PC_2_JAL: 
                           outmux1;//use PC+2 or use outmux1 data as the write back data



   //assign Writeback_data = (LBI_flag)? ext_result:outmux2;//use extend result(LBI) or outmux2 as the write back data

   // TODO: Your code here

endmodule
`default_nettype wire