/*
   CS/ECE 552 Spring '22
  
   Filename        : fetch.v
   Description     : This is the module for the overall fetch stage of the processor.
*/

////set the err trigger until the write back, the err need to be keep passing through the until the 
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
   //output wire err_fetch,
   output wire [15:0]PC_cur,

   //cache output 
   output wire err_instr_mc,
   output wire done_instr_mc,
   output wire stall_instr_mc,
   output wire stall_data_mc,
   output wire CacheHit_instr,
   output wire PC_addr_invalid_flag
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
   cla16b cla_PC_2_extresult(.inA(PC_cur), .inB(ext_result), .sum(PC_cur_2_ext_result), .cIn(1'b0), .cOut());

   wire [15:0] alu_result_neg2;
   cla16b cla_JALR_ALUresult_neg2(.inA(alu_result), .inB(16'b1111_1111_1111_1101), .sum(alu_result_neg2), .cIn(1'b1), .cOut());

   wire Jump_dl1;
   dff Jumpdl1(.d(Jump), .q(Jump_dl1), .clk(clk), .rst(rst));
   
   assign PC_nxt_asyn=
                     ((bcomp_en | Jump) /*& ~stall_instr_mc*/)? PC_cur_2_ext_result://both the D and I sign extended has been included,J
                     (HALT | STALL | (stall_instr_mc & ~Jump & ~(JR & JAL_syn_IDEX) & ~(JR & ~JAL)))? PC_cur: //we could not hold it when we got a Jump in decode, it need to be updated immediately
                     ((JR & ~JAL) /*& ~stall_instr_mc*/)? alu_result: //JR signal inside have connect with the JR
                     ((JR & JAL_syn_IDEX)/* & ~stall_instr_mc*/)? alu_result_neg2://JALR
                     (rst)? 16'd2://for the initial start
                      PC_2_JAL;//PC_cur+16'd2;


   //dff 
   //PC_addr 
   dff  dffPC[15:0](.d(PC_nxt_asyn), .q(PC_cur), .clk(clk), .rst(rst));


   //module memory2c (data_out, data_in, addr, enable, wr, createdump, clk, rst);
   //wire [15:0]full_instr_pre;
   //memory2c_align Instruction_Memory(.data_out(full_instr) ,.data_in(16'd0), .addr(PC_cur), .enable(~(PC_cur[0] /*| alu_result[0]*/)), .wr(1'b0), .createdump(1'b0), 
                                       //.clk(clk), .rst(rst), .err(err_instr_mc));//it should be set with the flag signal of the                    

   //the mem has replaced with the memory design with cache inside
   wire [15:0]PC_cur_ultra;
   assign PC_cur_ultra=((Jump|JR|(JAL_syn_IDEX & JR) | (JR & ~JAL)) & ~done_instr_mc)? PC_nxt_asyn : PC_cur;
   //when JALR goto the EX/MEM, the nop is in decode, which means the PC ultra will back to PC_cur(have alredy get the PC_NXT_SYN from last period, THE JALR)
   // AND GET SAME INSTRUCTION COMPARE WITH LAST PERIOD
   //wire PC_addr_invalid_flag;
   assign PC_addr_invalid_flag=PC_nxt_asyn[0];



   wire [15:0] full_instr_pre;
   mem_system mem_instr_cache(
   .DataOut(full_instr_pre),//prev
   .Done(done_instr_mc),//new
   .Stall(stall_instr_mc), //new
   .CacheHit(CacheHit_instr),//new 
   .err(),//new
   // Inputs
   .Addr(PC_cur_ultra),//prev 
   .DataIn(16'd0), //prev
   .Rd(~PC_cur[0]) /*& ~stall_data_mc*/, //prev
   .Wr(1'b0 /*& (~stall_data_mc)*/), //prev
   .createdump(1'b0), //prev
   .clk(clk), //prev
   .rst(rst)//prev
   );
    
    //AND FIND  THE REASON THAT WHY THERE'S A HALT AND MAKE A CONDITIONAL THAT THE HALT WON'T BE ASSERTED IF THERE IS A JALR

   assign full_instr=((stall_instr_mc & ~stall_data_mc & !(JR & JAL_syn_IDEX) & ~(JR & !JAL)) )? 16'h0800: full_instr_pre;// if JALR, dont lock the full instr to nop, if locked , it will clear the alu_output and got zero to every where.
   assign err_instr_mc=0;
   //for aligntesting just stop the stall//////////////////////////^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
   //assign stall_instr_mc=0;//for proc.v 'or' logic
   //assign done_instr_mc=0;
   //assign CacheHit_instr=0;

endmodule
`default_nettype wire
