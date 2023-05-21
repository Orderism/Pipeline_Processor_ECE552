module ID_EX_Reg(
   //the output control signal from the ID stage
   input wire clk,
   input wire rst,
   input wire [1:0]RegDst,//RegDst as the selection for the write back address
   input wire HALT,//Halt be 1 when halt
   input wire MemRead,//
   input wire MemReg,//
   input wire MemWrite,
   input wire ALUsrc,//ALU inB from Rd'0' or from extended imm_number'1' 
   input wire [7:0]ALU_op,//Be used as the control signal of ALU in Excution stage
   input wire ALU_en,
   input wire RegWrite,
   input wire JR,//JR, JALR, when we need to control PC in fetch
   input wire LBI_flag,//for LBI flag write back avoid the ex/mem period 
   input wire JAL,//for JAL, JALR, when we need to write back the PC+2 into R7
   input wire [15:0]ext_result,
   input wire [2:0] RegWrite_addr,
   input wire [2:0]  Rs_asyn_ID,
   input wire [2:0]  Rt_asyn_ID,
   input wire SIIC_flag,
   input wire [15:0] Read_rg_data_1,
   input wire [15:0] Read_rg_data_2,
   input wire STALL,//enable of the register
   input wire en,
   input wire [15:0]PC_2_JAL_syn_IFID,
   input wire HALT_c,
   input wire full_instr_R,
   input wire FLUSH,
   input wire [15:0]full_instr_syn_IFID,//for debug
   //LD forwarding
   input wire [15:0]Writeback_data,
   input wire [15:0] alu_result_syn_EXMEM,
   input wire hazard7_EX2EX_flag_Rd,
   input wire hazard8_MEM2EX_flag_Rd,




   //control signal output 
   output wire [1:0]RegDst_syn_IDEX,//RegDst as the selection for the write back address
   output wire HALT_syn_IDEX,//Halt be 1 when halt
   //output reg Jump_syn_IDEX,//'PC+2' or 'PC+2+ext(I)'****JUMP work in the decoder and connect with fetch.v with 0 dely
   //output reg Branch_syn_IDEX,//Branch work in the decoder and connect with fetch.v with 0 dely
   output wire MemRead_syn_IDEX,//
   output wire MemReg_syn_IDEX,//
   output wire MemWrite_syn_IDEX,
   output wire ALUsrc_syn_IDEX,//ALU inB from Rd'0' or from extended imm_number'1' 
   output wire ALU_en_syn_IDEX,
   output wire [7:0]ALU_op_syn_IDEX,
   output wire RegWrite_syn_IDEX,
   output wire JR_syn_IDEX,//JR, JALR, when we need to control PC in fetch
   output wire JAL_syn_IDEX,
   output wire LBI_flag_syn_IDEX,//for LBI flag write back avoid the ex/mem period
   output wire [15:0]ext_result_syn_IDEX,
   output wire [2:0] RegWrite_addr_syn_IDEX,//rd
   output wire [2:0]  Rs_syn_IDEX,
   output wire [2:0]  Rt_syn_IDEX,
   //module Register, have already passed 1 cycle in read process, dont need extra register for syn
   output wire [15:0]Read_rg_data_1_syn_IDEX,// need to be used in Memory not only the Execution
   output wire [15:0]Read_rg_data_2_syn_IDEX,
   //output wire decode_err_syn_IDEX,
   //module branch Comparator
   output wire SIIC_flag_syn_IDEX,
   output wire [15:0]PC_2_JAL_syn_IDEX,
   output wire full_instr_R_syn_IDEX,
   output wire [15:0] full_instr_syn_IDEX

);

//module B3register (wdata, writeEn, clk, rst, rdata);

//RegDst
B2register B2_RegDst_IDEX(.wdata(RegDst), .writeEn(en), .clk(clk), .rst(rst | HALT_c |FLUSH), .rdata(RegDst_syn_IDEX));//ID/EX

//HALT
B1register B1_HALT_IDEX(.wdata(HALT), .writeEn(en), .clk(clk), .rst(rst | FLUSH), .rdata(HALT_syn_IDEX));// ID/EX, EX/MEM, MEM/WB

//MemRead
B1register B1_MemRead_IDEX(.wdata(MemRead), .writeEn(en), .clk(clk), .rst(rst | HALT_c |FLUSH), .rdata(MemRead_syn_IDEX));//ID/EX, EXMEM

//MemReg
B1register B1_MemReg_IDEX(.wdata(MemReg), .writeEn(en), .clk(clk), .rst(rst | HALT_c |FLUSH), .rdata(MemReg_syn_IDEX));//ID/EX, EX/MEM, MEM/WB

//MemWrite
B1register B1_MemWrite_IDEX(.wdata(MemWrite), .writeEn(en), .clk(clk), .rst(rst | HALT_c |FLUSH), .rdata(MemWrite_syn_IDEX));//ID/EX, EXMEM

//ALUsrc
B1register B1_ALUsrc_IDEX(.wdata(ALUsrc), .writeEn(en), .clk(clk), .rst(rst | HALT_c |FLUSH), .rdata(ALUsrc_syn_IDEX));//ID/EX

//ALU_op
B8register B8_ALU_op_IDEX(.wdata(ALU_op), .writeEn(en), .clk(clk), .rst(rst | HALT_c |FLUSH), .rdata(ALU_op_syn_IDEX)); //ID/EX


//ALU_en
B1register B1_ALU_en_IDEX(.wdata(ALU_en), .writeEn(en), .clk(clk), .rst(rst | HALT_c |FLUSH), .rdata(ALU_en_syn_IDEX));// ID/EX

//RegWrite
B1register B1_RegWrite_IDEX(.wdata(RegWrite), .writeEn(en), .clk(clk), .rst(rst | HALT_c |FLUSH), .rdata(RegWrite_syn_IDEX));//ID/EX, EX/MEM, MEM/WB

//JR
B1register B1_JR_IDEX(.wdata(JR), .writeEn(en), .clk(clk), .rst(rst | HALT_c |FLUSH), .rdata(JR_syn_IDEX));//ID/EX

//JAL
B1register B1_JAL_IDEX(.wdata(JAL), .writeEn(en), .clk(clk), .rst(rst | HALT_c |FLUSH), .rdata(JAL_syn_IDEX));//ID/EX, EX/MEM, MEM/WB

//SLBI, LBI, BTR, SIIC flag
B1register B1_LBI_flag_IDEX(.wdata(LBI_flag), .writeEn(en), .clk(clk), .rst(rst | HALT_c |FLUSH), .rdata(LBI_flag_syn_IDEX));//ID/EX
B1register B1_SIIC_flag_IDEX(.wdata(SIIC_flag), .writeEn(en), .clk(clk), .rst(rst | HALT_c |FLUSH), .rdata(SIIC_flag_syn_IDEX));//???

//ext_result
B16register B16_ext_result_IDEX(.wdata(ext_result), .writeEn(en), .clk(clk), .rst(rst | HALT_c |FLUSH), .rdata(ext_result_syn_IDEX));//IDEX

//RegWrite_addr--RD
B3register B3_RegWrite_addr_IDEX(.wdata(RegWrite_addr), .writeEn(en), .clk(clk), .rst(rst | HALT_c |FLUSH), .rdata(RegWrite_addr_syn_IDEX));//ID/EX, EX/MEM, MEM/WB

//RS, Rt///   .Rs_asyn_ID(Rs_asyn_ID),   .Rt_asyn_ID(Rt_asyn_ID),
B3register B3_Rs_IDEX(.wdata(Rs_asyn_ID), .writeEn(en), .clk(clk), .rst(rst | HALT_c |FLUSH), .rdata(Rs_syn_IDEX));
B3register B3_Rt_IDEX(.wdata(Rt_asyn_ID), .writeEn(en), .clk(clk), .rst(rst | HALT_c |FLUSH), .rdata(Rt_syn_IDEX));

//Read_rg_data_1 & 2
wire [15:0]Read_rg_data_1_syn_IDEX_pre;
wire [15:0]Read_rg_data_2_syn_IDEX_pre;
B16register B16_Read_rg_data_1_IDEX(.wdata(Read_rg_data_1), .writeEn(en), .clk(clk), .rst(rst | HALT_c |FLUSH), .rdata(Read_rg_data_1_syn_IDEX));
B16register B16_Read_rg_data_2_IDEX(.wdata(Read_rg_data_2), .writeEn(en), .clk(clk), .rst(rst | HALT_c |FLUSH), .rdata(Read_rg_data_2_syn_IDEX_pre));

//ld forwarding
assign Read_rg_data_2_syn_IDEX= (hazard7_EX2EX_flag_Rd)?    alu_result_syn_EXMEM:
                                 (hazard8_MEM2EX_flag_Rd)?    Writeback_data:
Read_rg_data_2_syn_IDEX_pre;







//PC_2_JAL
B16register B1F_PC_2_JAL_IDEX(.wdata(PC_2_JAL_syn_IFID), .writeEn(en), .clk(clk), .rst(rst | STALL), .rdata(PC_2_JAL_syn_IDEX));

//full_instr_R_syn_IDEX
B1register B1_full_instr_R_IDEX(.wdata(full_instr_R), .writeEn(en), .clk(clk), .rst(rst | HALT_c |FLUSH), .rdata(full_instr_R_syn_IDEX));

//full_instrsyn_IDEX
B16register B1_full_instr_IDEX(.wdata(full_instr_syn_IFID), .writeEn(en), .clk(clk), .rst(rst | HALT_c |FLUSH), .rdata(full_instr_syn_IDEX));

endmodule