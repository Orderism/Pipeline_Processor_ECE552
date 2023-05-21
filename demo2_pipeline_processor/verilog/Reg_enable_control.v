module Reg_enable_control(
    input clk,
    input rst,
    //hazard1
    input wire RegWrite_syn_EXMEM,
    input wire [2:0] RegWrite_addr_syn_EXMEM,
    input wire [2:0] Rs_syn_IDEX,
    input wire [2:0] Rt_syn_IDEX,
    input wire full_instr_R_syn_IDEX,
    input wire MemRead_syn_EXMEM,
    //hazard2
    input wire RegWrite_syn_MEMWB,
    input wire [2:0] RegWrite_addr_syn_MEMWB,
    //input wire [2:0] Rs_syn_IDEX,
    //input wire [2:0] Rt_syn_IDEX,
    //hazard3 & 4
    //input wire RegWrite_syn_EXMEM,
    input wire MemWrite,
    input wire MemRead_syn_IDEX,
    input wire MemWrite_syn_IDEX,
    input wire MemRead,
    input wire full_instr_R,
    //hazard5 & 6
    //input wire RegWrite_syn_EXMEM,
    input wire RegWrite_syn_IDEX,
    input wire [2:0]Rs_asyn_ID,
    input wire [2:0]Rt_asyn_ID,
    input wire Branch,
    input wire [2:0]RegWrite_addr_syn_IDEX,
    //input wire Rs_syn_IDEX,
    //input wire [2:0] RegWrite_addr_syn_EXMEM,
    //input wire [2:0] RegWrite_addr_syn_MEMWB,
    output wire hazard1_EX2EX_flag,
    output wire hazard2_MEM2EX_flag,
    output wire hazard1_EX2EX_flag_Rs,
    output wire hazard1_EX2EX_flag_Rt,
    output wire hazard2_MEM2EX_flag_Rs,
    output wire hazard2_MEM2EX_flag_Rt,
    output wire hazard3_L2USE_flag,
    //output wire hazard3_L2USE_flag_dl1,
    output wire hazard4_L2S_flag,
    output wire hazard5_EX2ID_flag,
    output wire hazard6_MEM2ID_flag,
    //st
    output wire hazard7_EX2EX_flag_Rd,
    output wire hazard8_MEM2EX_flag_Rd,
    output wire STALL
    
);


//Basic Register Write dis-enable
//HALT
//STALL
//FLUSH
//Forwarding



//Structure bypassing
//#1. Register read and write in one time (use bypassing register to solve)
//#2. Register read and write twice in one cycle (use the data_register and instruction register split the mission out)
//#3. Cache confliction (will be considered in next stage such as theReg_enable_control cache design)


//Data bypassing
//RAW

//#1.EX  confliction--hazard 1
//Inspection:
//a)----------current instruction EX/MEM (Rd)==nxt_instruction ID/EX (Rs)
//b)----------current instruction will change the Rd! (cur instruction will feed back)
//**********EX/MEM.RegWrite &   ((EX/MEM.Register_Rd== ID/EX.Register_Rs) | (EX/MEM.Register_Rd== ID/EX.Register_Rt))
//wire hazard1_EX2EX_flag;
assign hazard1_EX2EX_flag=hazard1_EX2EX_flag_Rs | hazard1_EX2EX_flag_Rt;
assign hazard1_EX2EX_flag_Rs =( (RegWrite_syn_EXMEM)  & (~MemRead_syn_EXMEM) &
                            ((RegWrite_addr_syn_EXMEM==Rs_syn_IDEX)/*|(RegWrite_addr_syn_EXMEM==Rt_syn_IDEX)*/))? 1'b1:1'b0;

assign hazard1_EX2EX_flag_Rt =( (RegWrite_syn_EXMEM) & (~MemRead_syn_EXMEM) &
                               (full_instr_R_syn_IDEX) & //R format or store [10:8] hazard
                            (/*(RegWrite_addr_syn_EXMEM==Rs_syn_IDEX)*/|(RegWrite_addr_syn_EXMEM==Rt_syn_IDEX)))? 1'b1:1'b0;
//Solution:
//Send the EX/MEM output Rd into the  EX stage as input,  EX to EX forwarding






//#2.MEM confliction--hazard2
//Inspection:
//a)----------current instruction MEM/WB (Rd)==nxt_instruction ID/EX (Rs)
//b)----------current instruction will change the Rd! (cur instruction will feed back)
//c)---------- they are not EX confliction
//**********EX/MEM.RegWrite &  (MEM/WB.Register_Rd !=0) & ((MEM/WB.Register_Rd== ID/EX.Register_Rs) | (MEM/WB.Register_Rd== ID/EX.Register_Rt)) & (~hazard1)
//wire hazard2_MEM2EX_flag;
assign hazard2_MEM2EX_flag= hazard2_MEM2EX_flag_Rs | hazard2_MEM2EX_flag_Rt; 
assign hazard2_MEM2EX_flag_Rs =( ((RegWrite_syn_MEMWB)) & /* (~MemRead_syn_EXMEM) &*/ 
                            ((RegWrite_addr_syn_MEMWB==Rs_syn_IDEX)/*|(RegWrite_addr_syn_EXMEM==Rt_syn_IDEX)*/)  &
                            (~hazard1_EX2EX_flag_Rs))? 1'b1:1'b0;

assign hazard2_MEM2EX_flag_Rt =( (RegWrite_syn_MEMWB) & /*(~MemRead_syn_EXMEM) &*/ 
                                ((full_instr_R_syn_IDEX)) &
                            (/*(RegWrite_addr_syn_MEMWB==Rs_syn_IDEX)|*/(RegWrite_addr_syn_MEMWB==Rt_syn_IDEX)) &
                            (~hazard1_EX2EX_flag_Rt))? 1'b1:1'b0;

//Solution:
//MEM to EX forwarding




//#3.Load to use confliction---the result is stall=1!!! it should be connect with the enable
//Inspection: will be inspect in IF/ID and ID/EX stage (as earily as possible)
//a)----------cur_instruction_IDEX is load, nxt instruction in ID need to be read
//b)----------nxt_instruction Rs_asyn_ID is same with the Rd_EXMEM of load
//c)----------nxt_instruction is not store group (should be solved in M to M forwarding)
//d)----------not the previous 2 kind of forwarding,  because (ID/EX.Register Rd== IF/ID Register Rd) SHOULD Be MEM to EX forwarding
//**********ID/EX.MemRead & ((ID/EX.Register Rd == IF/ID Register Rs)) & (~MemWrite_syn_IFID)  & (~hazard1) & (~hazard2)
assign hazard3_L2USE_flag = (MemRead_syn_IDEX &
                            ((((Rt_syn_IDEX==Rs_asyn_ID) | (Rt_syn_IDEX==Rt_asyn_ID))) |// for load to R format use (rt or rs)
                             (MemWrite & (Rt_syn_IDEX==Rs_asyn_ID))))//for load to st rs
                             ? 1'b1:1'b0;


//dff hz3l2use(.d(hazard3_L2USE_flag),.q(hazard3_L2USE_flag_dl1),.clk(clk), .rst(rst));
assign STALL=hazard3_L2USE_flag;

//Solution
//stall 1 cycle, stall=1!!!

//#4 store after load (Special load to use, can be solved with the M to M forwarding)
//Example:
//ld r1, r2,10000;
//st r1, r3,900;
//Inspection: 
//a)----------cur_instruction is load
//b)----------nxt_instruction Rs is same with the Rd of load
//c)----------nxt instruction is st group 
//**********ID/EX.MemRead & ((ID/EX.Register Rt == IF/ID Register Rs) | (ID/EX.Register Rt== IF/ID Register Rt)) & (~MemWrite_syn_IFID)
assign hazard4_L2S_flag =   ((MemRead_syn_IDEX) &
                            (MemWrite & (RegWrite_addr_syn_IDEX==Rt_asyn_ID)) )? 1'b1:1'b0;
//#5 & 6 Branch comparasion in ID confliction (EX to ID; MEM to ID)
//Example (EX to ID):
//ADDI r1,r2,1000;
//BEQZ r1, 350;

//Example (Mem to ID):
//LD r1, 1000;
//BEQZ r1, 350;

//a) cur/prev_instruction will write back (exmem for 5 ,memwb for 6)
//b) nxt_instruction is BEQ group in DECODE stage
//c) (nxt_instruction Rs= cur_instruction Rd) --#5 or (nxt_instruction Rs = prev instruction Rd) --#6
//*************
assign hazard5_EX2ID_flag = ((RegWrite_syn_IDEX) &
                            (Branch) &
                            (Rs_asyn_ID== RegWrite_addr_syn_IDEX))? 1:0;



assign hazard6_MEM2ID_flag =((RegWrite_syn_EXMEM) &
                            (Branch) &
                            (~hazard5_EX2ID_flag) &
                            (Rs_asyn_ID== RegWrite_addr_syn_EXMEM))?1:0;

//Solution: EX to ID or MEM to ID,
// when we detect the hazard, stall the BEQ into the ID!


//#7 & 8 hazard store RD logic flag
//example
//lbi r2,8
//*****instru
//st r2,r1,8 the destination of the st need to be replaced when the previous lbi write back, 
//logic :
//a) store in ID, MemReg_syn_MEMWB=1
//b) Rd of store need to be replaced 
//c) 

assign hazard7_EX2EX_flag_Rd =((RegWrite_syn_EXMEM)  &
                              (MemWrite_syn_IDEX) & //R format or store [10:8] hazard
                                (RegWrite_addr_syn_EXMEM==Rt_syn_IDEX))? 1'b1:1'b0;


assign hazard8_MEM2EX_flag_Rd =((RegWrite_syn_MEMWB)  &
                                (MemWrite_syn_IDEX) & //R format or store [10:8] hazard
                                (~hazard7_EX2EX_flag_Rd) &
                                (RegWrite_addr_syn_MEMWB==Rt_syn_IDEX))? 1'b1:1'b0;

endmodule