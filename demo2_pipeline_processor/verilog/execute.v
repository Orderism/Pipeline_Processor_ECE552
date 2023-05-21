/*
   CS/ECE 552 Spring '22
  
   Filename        : execute.v
   Description     : This is the overall module for the execute stage of the processor.
*/
`default_nettype none
module execute (
   input wire [15:0]Read_rg_data_1,
   input wire [15:0]Read_rg_data_2,
   input wire [15:0]ext_result,
   input wire [7:0]ALU_op,
   input wire ALU_en,
   input wire ALUsrc,
   input wire LBI_flag,
   input wire [15:0]alu_result_syn_EXMEM,
   input wire [15:0]Writeback_data,

   //hazard 4  load to st rs
   input wire hazard3_L2USE_flag,
   input wire MemWrite_syn_IDEX,
   //for loada to use dectection
   input wire [15:0] MemRead_data_syn_MEMWB,
   input wire MemRead_syn_MEMWB,

   //hazard 1 & 2
   input wire hazard1_EX2EX_flag_Rs,
   input wire hazard2_MEM2EX_flag_Rs,
   input wire hazard1_EX2EX_flag_Rt,
   input wire hazard2_MEM2EX_flag_Rt,
   output wire [15:0] alu_result
);

   // TODO: Your code here
      
   //mux for ALU input (inB = Imm number or Rd)?
   wire [15:0]InA, InB, InB_pre;
   wire [15:0] alu_result_pre;
   //assign InA=Read_rg_data_1;
   assign InB_pre=(ALUsrc)? ext_result : Read_rg_data_2;
   assign alu_result= (LBI_flag)? ext_result: 
                      alu_result_pre;



   

   //hazard 1(EX to EX), and hazard 2(MEM to EX)
   //replace Rs
   assign InA=(hazard1_EX2EX_flag_Rs)? alu_result_syn_EXMEM://hazard1_Rs, alu_result_EXMEM to InA
              ((hazard2_MEM2EX_flag_Rs & (~MemRead_syn_MEMWB)) )? Writeback_data://hazard2_Rs, Writeback_data to InA   or load to st rs, Write back data to InA
              (((hazard2_MEM2EX_flag_Rs & MemRead_syn_MEMWB)))? MemRead_data_syn_MEMWB:// only the load to use with store
                  Read_rg_data_1;


   //replace Rt
   assign InB=(hazard1_EX2EX_flag_Rt )? alu_result_syn_EXMEM: //hazard1_Rt, alu_result_EXMEM to InB
              (hazard2_MEM2EX_flag_Rt & (~MemRead_syn_MEMWB))? Writeback_data://hazard2_Rt, Writeback_data to InB
               (hazard2_MEM2EX_flag_Rt & MemRead_syn_MEMWB)? MemRead_data_syn_MEMWB:
               InB_pre;// the normal result selected by mux from the Register data or ext_result


   //ALU 
   //module alu (InA, InB, Cin, Oper, invA, invB, sign, Out, en);
   /*  ALU_op[7:0]:
    [7]:Cin, only be 1 when we start a subtraction
    [3:6]:ALU oper, from 000 to 111, include shift, add, or, and, xor
    [2]:invA   set 1 in SUB and SUBI
    [1]:invB   set 1 in ANDN and ANDNI
    [0]:signed or unsigned   */
 
   alu alu(.InA(InA), .InB(InB), .Cin(ALU_op[7]), .Oper(ALU_op[6:3]), .invA(ALU_op[2]), .invB(ALU_op[1]), .sign(ALU_op[0]), .Out(alu_result_pre), .en(ALU_en));
   //no one need the Ofl and Zero, left them alone


endmodule
`default_nettype wire
