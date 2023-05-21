/*
   CS/ECE 552 Spring '22
  
   Filename        : fetch.v
   Description     : This is the module for the overall fetch stage of the processor.
*/
`default_nettype none
module fetch (
   // TODO: Your code here
   input wire clk, rst,
   input wire [15:0]ext_result,
   input wire HALT,
   input wire [15:0]alu_result,
   input wire JR,  
   input wire bcomp_en,
   input wire Jump,
   input wire hazard5_EX2ID_flag,//if there is hazard 5, 6, stall the PC address updated in PC_Register_IDEX 
   input wire hazard6_MEM2ID_flag,
   input wire STALL,
   input wire en,
   input wire JAL,
   input wire JAL_syn_IDEX,
   //input wire FLUSH,


   output wire [15:0]PC_nxt_asyn,//PC should be output from the dff to make sure the synchronus
   output wire [15:0]PC_2_JAL,//for JAL AND JALR reserve PC+2 into R7
   output wire [15:0] full_instr,
   output wire fetch_err,
   output wire [15:0]PC_cur
);

   //nxt_PC addr could be:
   //cur_PC: HALT
   
   //Rs+I(sign extended): from alu, the alu_result JR, JALR
   //PC+2+D(sign extended) : J, JAL
   //PC+2+I(sign extended): BEQZ, BNEZ, BLTZ, BGEZPC_nxt_syn' not found in the connected module (10th connection).


   /*assign PC_2_JAL=PC_cur+16'd2;*/
   //module  cla16b(inA, inB, sum, cIn, cOut);
   cla16b cla_PC_2(.inA(PC_cur),.inB(16'd2),.sum(PC_2_JAL), .cIn(1'b0), .cOut());
   

   //PC_overflow err check
   //wire [16:0] PC_nxt_asyn17;//for err checking
   wire [15:0] PC_cur_2_ext_result;
   cla16b cla_PC_2_extresult(.inA(PC_cur), .inB(ext_result), .sum(PC_cur_2_ext_result), .cIn(1'b0), .cOut(fetch_err));

   wire [15:0] alu_result_neg2;
   cla16b cla_JALR_ALUresult_neg2(.inA(alu_result), .inB(16'b1111_1111_1111_1101), .sum(alu_result_neg2), .cIn(1'b1), .cOut());


   assign PC_nxt_asyn=
                     (HALT | STALL )? PC_cur:
                     (bcomp_en | Jump)? PC_cur_2_ext_result://both the D and I sign extended has been included
                     (JR & ~JAL)? alu_result: //16bit 17
                     (JR & JAL_syn_IDEX)? alu_result_neg2:
                     (rst)?16'd2://for the initial start
                      PC_2_JAL;//PC_cur+16'd2;
   //assign PC_nxt_asyn=PC_nxt_asyn17[15:0];
    
   //assign fetch_err=PC_nxt_asyn17[16];












   //dff 
   //PC_addr 
   dff  dffPC[15:0](.d(PC_nxt_asyn), .q(PC_cur), .clk(clk), .rst(rst));



   //module memory2c (data_out, data_in, addr, enable, wr, createdump, clk, rst);
   //wire [15:0]full_instr_pre;
   memory2c Instruction_Memory(.data_out(full_instr) ,.data_in(16'd0), .addr(PC_cur), .enable(1'b1), .wr(1'b0), .createdump(1'b0), .clk(clk), .rst(rst));//it should be set with the flag signal of the                    
   //if there is a FLUSH the output full_instr should be instead as a nop, so
   //assign full_instr= (FLUSH & (~rst))? 16'h0800:full_instr_pre;


endmodule
`default_nettype wire
