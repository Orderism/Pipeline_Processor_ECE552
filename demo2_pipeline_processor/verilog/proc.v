/* $Author: sinclair $ */
/* $LastChangedDate: 2020-02-09 17:03:45 -0600 (Sun, 09 Feb 2020) $ */
/* $Rev: 46 $ */
`default_nettype none
module proc (/*AUTOARG*/
   // Outputs
   err, 
   // Inputs
   clk, rst
   );

   input wire clk;
   input wire rst;

   output wire err;//Matt's reg is exchanged to wire

   // None of the above lines can be modified

   // OR all the err ouputs for every sub-module and assign it as this
   // err output
   
   // As desribed in the homeworks, use the err signal to trap corner
   // cases that you think are illegal in your statemachines
   //CODE AS FOLLOW:
   
   //fetch 
   wire [15:0]ext_result;
   wire HALT;
   wire [15:0]alu_result;
   wire JR;  
   wire bcomp_en;
   wire Jump;
   wire fetch_err;
   
   
   //wire [15:0]PC_nxt;
   wire [15:0]PC_2_JAL;
   wire [15:0]full_instr;
   wire [15:0]PC_nxt_asyn;

   //
   wire HALT_syn_EXMEM , HALT_syn_IDEX , HALT_syn_MEMWB;
   wire JR_syn_IDEX;
   //wire [15:0]PC_nxt_asyn_ID;

   //
   // Reg_enable _control 
   wire RegWrite_syn_MEMWB, RegWrite_syn_EXMEM;
   wire [2:0]RegWrite_addr_syn_EXMEM;
   wire [2:0]Rs_syn_IDEX, Rt_syn_IDEX;
   wire [2:0]RegWrite_addr_syn_MEMWB;
   wire MemRead_syn_EXMEM, MemRead_syn_MEMWB;
   wire MemWrite_syn_IDEX, MemWrite_syn_MEMWB;
   wire Branch_syn_IDEX;
   wire hazard1_EX2EX_flag, hazard2_MEM2EX_flag, hazard3_L2USE_flag, hazard4_L2S_flag, hazard5_EX2ID_flag, hazard6_MEM2ID_flag;
   wire hazard1_EX2EX_flag_Rs, hazard1_EX2EX_flag_Rt, hazard2_MEM2EX_flag_Rs, hazard2_MEM2EX_flag_Rt;
   wire hazard7_EX2EX_flag_Rd,hazard8_MEM2EX_flag_Rd;



   
   //decode decode signal declaration
   //control signal input
   wire [15:0]Writeback_data;
   //control signal 
   wire [1:0]RegDst;//RegDst as the selection for the write back address
   wire Branch;//
   wire MemRead;//
   wire MemReg;//
   wire MemWrite;
   wire ALUsrc;//ALU inB from Rd'0' or from extended imm_number'1' 
   wire [7:0]ALU_op;//Be used as the control signal of ALU in Excution stage
   wire ALU_en;
   wire RegWrite;
   wire LBI_flag;//for LBI flag write back avoid the ex/mem period
   wire JAL;//for JAL; JALR; when we need to write back the PC+2 into R7
   wire [2:0]ext_sel;
   wire SIIC_flag;

   //module Register
   wire [15:0]Read_rg_data_1;
   wire [15:0]Read_rg_data_2;
   wire decode_err;
   wire [2:0]RegWrite_addr;   

   //R_format flag
   wire full_instr_R, full_instr_R_syn_EXMEM, full_instr_R_syn_IDEX, full_instr_R_syn_MEMWB;

   //IF/ID
   //wire bcomp_en_syn_IDEX, IF_ID_Reg_en;
   wire STALL;
   wire [15:0]PC_cur;
   wire [15:0]PC_cur_syn_IFID, PC_2_JAL_syn_IFID, PC_2_JAL_syn_IDEX, PC_2_JAL_syn_EXMEM, PC_2_JAL_syn_MEMWB;
   wire [15:0]full_instr_syn_IFID,full_instr_syn_IDEX, full_instr_syn_EXMEM, full_instr_syn_MEMWB;

   //Decode
   wire [2:0]Rs_asyn_ID, Rt_asyn_ID;


   //ID/EX
   wire [1:0]RegDst_syn_IDEX;
   wire MemRead_syn_IDEX;
   wire MemReg_syn_IDEX;
   wire ALUsrc_syn_IDEX, ALU_en_syn_IDEX;
   wire [7:0]ALU_op_syn_IDEX;
   wire RegWrite_syn_IDEX;
   wire LBI_flag_syn_IDEX;
   wire [15:0] ext_result_syn_IDEX;
   wire [2:0]RegWrite_addr_syn_IDEX;
   wire [15:0]Read_rg_data_1_syn_IDEX, Read_rg_data_2_syn_IDEX;
   wire SIIC_flag_syn_IDEX;
   //wire Jump_syn_IDEX,bcomp_en_syn_IDEX;

   //Excute



   //EX/MEM
   wire JAL_syn_IDEX;
   wire [15:0]alu_result_syn_EXMEM;
   wire MemWrite_syn_EXMEM;
   wire MemReg_syn_EXMEM;
   wire JAL_syn_EXMEM;
   wire [15:0]Read_rg_data_1_syn_EXMEM, Read_rg_data_2_syn_EXMEM;
   wire [2:0]Rs_syn_EXMEM, Rt_syn_EXMEM;



   //memory
   wire [15:0]MemRead_data;
   wire [15:0]MemWrite_data;
   

   //module wb
   wire [15:0]MemRead_data_syn_MEMWB;
   wire MemReg_syn_MEMWB;
   wire JAL_syn_MEMWB;
   wire [15:0]alu_result_syn_MEMWB;



/////////////*************///////
   //hazard detection & forwarding
Reg_enable_control REC(
   .clk(clk),
   .rst(rst),
    //hazard1
    .RegWrite_syn_EXMEM(RegWrite_syn_EXMEM),
    .RegWrite_addr_syn_EXMEM(RegWrite_addr_syn_EXMEM),
    .Rs_syn_IDEX(Rs_syn_IDEX),
    .Rt_syn_IDEX(Rt_syn_IDEX),
    .full_instr_R_syn_IDEX(full_instr_R_syn_IDEX),
    .MemRead_syn_EXMEM(MemRead_syn_EXMEM),
    //hazard2
    .RegWrite_syn_MEMWB(RegWrite_syn_MEMWB),
    .RegWrite_addr_syn_MEMWB(RegWrite_addr_syn_MEMWB),
    //.[2:0] Rs_syn_IDEX,
    //.[2:0] Rt_syn_IDEX,
    //hazard3 & 4
    //.RegWrite_syn_EXMEM(RegWrite_syn_EXMEM),
    .MemRead(MemRead),//make sure ld to use is for ST
    .MemWrite_syn_IDEX(MemWrite_syn_IDEX),
    .MemRead_syn_IDEX(MemRead_syn_IDEX),
    .full_instr_R(full_instr_R),//make sure the ld to use is for Rformat 

    //hazard5
    .Branch(Branch),
    .RegWrite_syn_IDEX(RegWrite_syn_IDEX),
    .Rs_asyn_ID(Rs_asyn_ID),
    .Rt_asyn_ID(Rt_asyn_ID),
    .RegWrite_addr_syn_IDEX(RegWrite_addr_syn_IDEX),
    .MemWrite(MemWrite),
    //input wire [2:0] RegWrite_addr_syn_EXMEM,
    //input wire [2:0] RegWrite_addr_syn_MEMWB,
    .hazard1_EX2EX_flag(hazard1_EX2EX_flag),//not sure will be used or not, hold it
    .hazard2_MEM2EX_flag(hazard2_MEM2EX_flag),//not sure will be used or not, hold it  
    .hazard1_EX2EX_flag_Rs(hazard1_EX2EX_flag_Rs),
    .hazard1_EX2EX_flag_Rt(hazard1_EX2EX_flag_Rt),
    .hazard2_MEM2EX_flag_Rs(hazard2_MEM2EX_flag_Rs),
    .hazard2_MEM2EX_flag_Rt(hazard2_MEM2EX_flag_Rt),
    .hazard3_L2USE_flag(hazard3_L2USE_flag),
    //.hazard3_L2USE_flag_dl1(hazard3_L2USE_flag_dl1),
    .hazard4_L2S_flag(hazard4_L2S_flag),
    .hazard5_EX2ID_flag(hazard5_EX2ID_flag),
    .hazard6_MEM2ID_flag(hazard6_MEM2ID_flag),
    .hazard7_EX2EX_flag_Rd(hazard7_EX2EX_flag_Rd),
    .hazard8_MEM2EX_flag_Rd(hazard8_MEM2EX_flag_Rd),
    .STALL(STALL)
);






/////////////*************///////



   fetch fetch(
      .clk(clk), 
      .rst(rst),
      .ext_result(ext_result),
      .HALT(HALT),
      .alu_result(alu_result),
      .JR(JR_syn_IDEX),  
      .bcomp_en(bcomp_en),
      .Jump(Jump),
      .PC_nxt_asyn(PC_nxt_asyn),//PC should be output from the dff to make sure the synchronus
      .PC_2_JAL(PC_2_JAL),//for JAL AND JALR reserve PC+2 into R7
      .PC_cur(PC_cur),
      .full_instr(full_instr),
      .fetch_err(fetch_err),
      .STALL(STALL),
      .en(~STALL),
      .JAL(JAL),
      .JAL_syn_IDEX(JAL_syn_IDEX),

         //if there is hazard 5, 6, stall the PC address updated in PC_Register_IDEX until they disasserted, need put the logic
      .hazard5_EX2ID_flag(hazard5_EX2ID_flag),
      .hazard6_MEM2ID_flag(hazard6_MEM2ID_flag)
);


   //IF_ID register
   IF_ID_Reg ifidr(
   //input
   .clk (clk),
   .rst (rst),
   .STALL(STALL),// once there is a STALL the STALL should be global
   .HALT_c(HALT|HALT_syn_IDEX|HALT_syn_EXMEM|HALT_syn_MEMWB),//halt for the PC holding
   .PC_2_JAL(PC_2_JAL),//from fetch.v
   .full_instr(full_instr),//from fetch.v
   .en(~STALL),
   .FLUSH(Jump |bcomp_en |JR|JR_syn_IDEX),
   //output 
   .PC_2_JAL_syn_IFID(PC_2_JAL_syn_IFID),
   .full_instr_syn_IFID(full_instr_syn_IFID)
);

   //decode connection
   decode decode(   //control signal input
   .full_instr(full_instr_syn_IFID),
   .rst(rst),
   .clk(clk),
   .Writeback_data(Writeback_data),//****************,
   .STALL(STALL),
   .RegWrite_syn_MEMWB(RegWrite_syn_MEMWB),
   .RegWrite_addr_syn_MEMWB(RegWrite_addr_syn_MEMWB),

   //control signal output 
   .RegDst(RegDst),//RegDst as the selection for the write back address
   .HALT(HALT),//Halt be 1 when halt
   .Jump(Jump),//'PC+2' or 'PC+2+ext(I)' or 'PC+2+ext(D)'
   .Branch(Branch),//
   .MemRead(MemRead),//
   .MemReg(MemReg),//
   .MemWrite(MemWrite),
   .ALUsrc(ALUsrc),//ALU inB from Rd'0' or from extended imm_number'1' 
   .ALU_op(ALU_op),//Be used as the control signal of ALU in Excution stage
   .ALU_en(ALU_en),
   .RegWrite(RegWrite),
   .JR(JR),//JR, JALR, when we need to control PC in fetch
   .LBI_flag(LBI_flag),//for LBI flag write back avoid the ex/mem period
   .JAL(JAL),//for JAL, JALR, when we need to write back the PC+2 into R7
   .ext_sel(ext_sel),
   .ext_result(ext_result),
   .RegWrite_addr(RegWrite_addr),// actually this is rd
   .Rs_asyn_ID(Rs_asyn_ID),
   .Rt_asyn_ID(Rt_asyn_ID),
   //hazard 5 & 6   
   .hazard5_EX2ID_flag(hazard5_EX2ID_flag),
   .hazard6_MEM2ID_flag(hazard6_MEM2ID_flag),
   .MemRead_data(MemRead_data),
   .alu_result(alu_result),
   .alu_result_syn_EXMEM(alu_result_syn_EXMEM),
   .MemRead_syn_EXMEM(MemRead_syn_EXMEM),
   
   //module Register
   .Read_rg_data_1(Read_rg_data_1),
   .Read_rg_data_2(Read_rg_data_2),
   .decode_err(decode_err),
   //module branch Comparator
   .bcomp_en(bcomp_en),
   .SIIC_flag(SIIC_flag),
   .full_instr_R(full_instr_R)
   );


   //ID_EX register
   ID_EX_Reg idexr(
   //input
   .clk(clk),
   .rst(rst|STALL),
   .RegDst(RegDst),//RegDst as the selection for the write back address
   .HALT_c(HALT|HALT_syn_EXMEM |HALT_syn_MEMWB),//Halt control signal
   .HALT(HALT | HALT_syn_EXMEM | HALT_syn_MEMWB),//Halt passing through signal
   .MemRead(MemRead),//
   .MemReg(MemReg),//
   .MemWrite(MemWrite),
   .ALUsrc(ALUsrc),//ALU inB from Rd'0' or from extended imm_number'1' 
   .ALU_op(ALU_op),//Be used as the control signal of ALU in Excution stage
   .ALU_en(ALU_en),
   .RegWrite(RegWrite),
   .JR(JR),//JR, JALR, when we need to control PC in fetch
   .LBI_flag(LBI_flag),//for LBI flag write back avoid the ex/mem period 
   .JAL(JAL),//for JAL, JALR, when we need to write back the PC+2 into R7
   .ext_result(ext_result),
   .RegWrite_addr(RegWrite_addr),
   .SIIC_flag(SIIC_flag),
   .Rs_asyn_ID(Rs_asyn_ID),
   .Rt_asyn_ID(Rt_asyn_ID),
   .Read_rg_data_1(Read_rg_data_1),
   .Read_rg_data_2(Read_rg_data_2),
   .STALL(STALL),
   .en(1'b1),
   .PC_2_JAL_syn_IFID(PC_2_JAL_syn_IFID),
   .full_instr_R(full_instr_R),
   .full_instr_syn_IFID(full_instr_syn_IFID),
   .FLUSH(1'b0),//JUMP/Branch Jump has been deteceted in ID stage
   .hazard7_EX2EX_flag_Rd(hazard7_EX2EX_flag_Rd),
   .hazard8_MEM2EX_flag_Rd(hazard8_MEM2EX_flag_Rd),
   .Writeback_data(Writeback_data),
   .alu_result_syn_EXMEM(alu_result_syn_EXMEM),
   

   //output 
   .RegDst_syn_IDEX(RegDst_syn_IDEX),//RegDst as the selection for the write back address
   .HALT_syn_IDEX(HALT_syn_IDEX),//Halt be 1 when halt
   //. Jump_syn_IDEX,//'PC+2' or 'PC+2+ext(I)'****JUMP work in the decoder and connect with fetch.v with 0 dely
   //. Branch_syn_IDEX,//Branch work in the decoder and connect with fetch.v with 0 dely
   .MemRead_syn_IDEX(MemRead_syn_IDEX),//
   .MemReg_syn_IDEX(MemReg_syn_IDEX),//
   .MemWrite_syn_IDEX(MemWrite_syn_IDEX),
   .ALUsrc_syn_IDEX(ALUsrc_syn_IDEX),//ALU inB from Rd'0' or from extended imm_number'1' 
   .ALU_op_syn_IDEX(ALU_op_syn_IDEX),//Be used as the control signal of ALU in Excution stage
   .ALU_en_syn_IDEX(ALU_en_syn_IDEX),
   .RegWrite_syn_IDEX(RegWrite_syn_IDEX),
   .JR_syn_IDEX(JR_syn_IDEX),//JR, JALR, when we need to control PC in fetch
   .JAL_syn_IDEX(JAL_syn_IDEX),
   .LBI_flag_syn_IDEX(LBI_flag_syn_IDEX),//for LBI flag write back avoid the ex/mem period
   .ext_result_syn_IDEX(ext_result_syn_IDEX),
   .RegWrite_addr_syn_IDEX(RegWrite_addr_syn_IDEX),
   //module Register, have already passed 1 cycle in read process, dont need extra register for syn
   .Read_rg_data_1_syn_IDEX(Read_rg_data_1_syn_IDEX),
   .Read_rg_data_2_syn_IDEX(Read_rg_data_2_syn_IDEX),
   //output wire decode_err_syn_IDEX,
   //module branch Comparator
   .SIIC_flag_syn_IDEX(SIIC_flag_syn_IDEX),
   .Rs_syn_IDEX(Rs_syn_IDEX),
   .Rt_syn_IDEX(Rt_syn_IDEX),
   .PC_2_JAL_syn_IDEX(PC_2_JAL_syn_IDEX),
   .full_instr_R_syn_IDEX(full_instr_R_syn_IDEX),
   .full_instr_syn_IDEX(full_instr_syn_IDEX)
);
   

   //excute connection //////////// NEED TO BE COMPLETE
   execute execute(
   //input
   .Read_rg_data_1(Read_rg_data_1_syn_IDEX),// from decode stage
   .Read_rg_data_2(Read_rg_data_2_syn_IDEX),// from decode stage
   .ext_result(ext_result_syn_IDEX),
   .ALU_op(ALU_op_syn_IDEX),
   .ALU_en(ALU_en_syn_IDEX),
   .ALUsrc(ALUsrc_syn_IDEX),
   .LBI_flag(LBI_flag_syn_IDEX),
   .hazard1_EX2EX_flag_Rs(hazard1_EX2EX_flag_Rs),
   .hazard1_EX2EX_flag_Rt(hazard1_EX2EX_flag_Rt),
   .hazard2_MEM2EX_flag_Rs(hazard2_MEM2EX_flag_Rs),
   .hazard2_MEM2EX_flag_Rt(hazard2_MEM2EX_flag_Rt),
   .hazard3_L2USE_flag(hazard3_L2USE_flag),
   .Writeback_data(Writeback_data),
   .alu_result_syn_EXMEM(alu_result_syn_EXMEM),
   .MemRead_syn_MEMWB(MemRead_syn_MEMWB),
   .MemRead_data_syn_MEMWB(MemRead_data_syn_MEMWB),
   .MemWrite_syn_IDEX(MemWrite_syn_IDEX),

   //output
   .alu_result(alu_result)

);


   //EX/MEM register
   EX_MEM_Reg exmemr(
   .clk(clk), 
   .rst(rst),
   .alu_result(alu_result),
   .HALT_syn_IDEX(HALT_syn_IDEX|HALT_syn_MEMWB),
   .HALT_c(HALT_syn_IDEX|HALT_syn_MEMWB),
   .MemRead_syn_IDEX(MemRead_syn_IDEX),
   .MemWrite_syn_IDEX(MemWrite_syn_IDEX),
   .MemReg_syn_IDEX(MemReg_syn_IDEX),   
   .RegWrite_syn_IDEX(RegWrite_syn_IDEX),
   .JAL_syn_IDEX(JAL_syn_IDEX),
   .RegWrite_addr_syn_IDEX(RegWrite_addr_syn_IDEX),
   .Read_rg_data_1_syn_IDEX(Read_rg_data_1_syn_IDEX),
   .Read_rg_data_2_syn_IDEX(Read_rg_data_2_syn_IDEX),
   .Rs_syn_IDEX(Rs_syn_IDEX),
   .Rt_syn_IDEX(Rt_syn_IDEX),
   .STALL(1'b0),
   .en(1'b1),
   .PC_2_JAL_syn_IDEX(PC_2_JAL_syn_IDEX),
   .full_instr_R_syn_IDEX(full_instr_R_syn_IDEX),
   .full_instr_syn_IDEX(full_instr_syn_IDEX),

   .alu_result_syn_EXMEM(alu_result_syn_EXMEM),
   .HALT_syn_EXMEM(HALT_syn_EXMEM),
   .MemRead_syn_EXMEM(MemRead_syn_EXMEM),
   .MemWrite_syn_EXMEM(MemWrite_syn_EXMEM),
   .MemReg_syn_EXMEM(MemReg_syn_EXMEM),
   .RegWrite_syn_EXMEM(RegWrite_syn_EXMEM),
   .JAL_syn_EXMEM(JAL_syn_EXMEM),
   .RegWrite_addr_syn_EXMEM(RegWrite_addr_syn_EXMEM),
   .Read_rg_data_1_syn_EXMEM(Read_rg_data_1_syn_EXMEM),
   .Read_rg_data_2_syn_EXMEM(Read_rg_data_2_syn_EXMEM),
   .Rs_syn_EXMEM(Rs_syn_EXMEM),
   .Rt_syn_EXMEM(Rt_syn_EXMEM),
   .PC_2_JAL_syn_EXMEM(PC_2_JAL_syn_EXMEM),
   .full_instr_R_syn_EXMEM(full_instr_R_syn_EXMEM),
   .full_instr_syn_EXMEM(full_instr_syn_EXMEM)
);


   //memory
   memory memory(
   .clk(clk), 
   .rst(rst),
   .HALT(HALT_syn_MEMWB),
   .MemRead(MemRead_syn_EXMEM),
   .MemWrite(MemWrite_syn_EXMEM),
   .SIIC_flag(SIIC_flag_syn_IDEX),
   .Read_rg_data_1(Read_rg_data_1_syn_EXMEM),//
   .Read_rg_data_2(Read_rg_data_2_syn_EXMEM),
   .alu_result(alu_result_syn_EXMEM),
   .MemRead_data(MemRead_data),
   .Writeback_data(Writeback_data),
   .hazard4_L2S_flag(hazard4_L2S_flag)
   );

   //MEM/WB register
   MEM_WB_Reg memwbr( 
   //input
   .clk(clk),
   .rst(rst),
   .MemRead_data(MemRead_data),
   .HALT_syn_EXMEM(HALT_syn_EXMEM),
   .MemReg_syn_EXMEM(MemReg_syn_EXMEM),
   .JAL_syn_EXMEM(JAL_syn_EXMEM),
   .alu_result_syn_EXMEM(alu_result_syn_EXMEM),
   .RegWrite_addr_syn_EXMEM(RegWrite_addr_syn_EXMEM),
   .RegWrite_syn_EXMEM(RegWrite_syn_EXMEM),
   .STALL(1'b0),
   .en(1'b1),
   .PC_2_JAL_syn_EXMEM(PC_2_JAL_syn_EXMEM),
   .full_instr_R_syn_EXMEM(full_instr_R_syn_EXMEM),
   .HALT_c(HALT_syn_EXMEM),
   .full_instr_syn_EXMEM(full_instr_syn_EXMEM),
   .MemRead_syn_EXMEM(MemRead_syn_EXMEM),

   //output
   .MemRead_data_syn_MEMWB(MemRead_data_syn_MEMWB),
   .HALT_syn_MEMWB(HALT_syn_MEMWB),
   .MemReg_syn_MEMWB(MemReg_syn_MEMWB),
   .JAL_syn_MEMWB(JAL_syn_MEMWB),
   .alu_result_syn_MEMWB(alu_result_syn_MEMWB),   
   .RegWrite_addr_syn_MEMWB(RegWrite_addr_syn_MEMWB),
   .RegWrite_syn_MEMWB(RegWrite_syn_MEMWB),
   .PC_2_JAL_syn_MEMWB(PC_2_JAL_syn_MEMWB),
   .full_instr_R_syn_MEMWB(full_instr_R_syn_MEMWB),
   .full_instr_syn_MEMWB(full_instr_syn_MEMWB),
   .MemRead_syn_MEMWB(MemRead_syn_MEMWB)
);




   //wb connection
   wb wb(
      .alu_result(alu_result_syn_MEMWB),
      .MemRead_data(MemRead_data_syn_MEMWB),
      .MemReg(MemReg_syn_MEMWB),
      .PC_2_JAL (PC_2_JAL_syn_MEMWB),
      .JAL (JAL_syn_MEMWB),
      .HALT(HALT_syn_MEMWB),//if HALT, stop write back   
      //output
      .Writeback_data(Writeback_data)
   );

   //err
   /*
   wire err_asycn;
   assign err_asycn = fetch_err| decode_err;
   dff dff_errs(.d(err_asycn), .q(err), .clk(clk) ,.rst(rst));
*/

endmodule // proc
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :0
