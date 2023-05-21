module EX_MEM_Reg (
   input clk, 
   input rst,
   input wire [15:0] alu_result,
   input wire HALT_syn_IDEX,
   input wire HALT_c,
   input wire MemRead_syn_IDEX,
   input wire MemWrite_syn_IDEX,
   input wire MemReg_syn_IDEX,
   input wire RegWrite_syn_IDEX,
   input wire JAL_syn_IDEX,
   input wire [2:0]RegWrite_addr_syn_IDEX,
   input wire [15:0]Read_rg_data_1_syn_IDEX,
   input wire [15:0]Read_rg_data_2_syn_IDEX,
   input wire [2:0]Rs_syn_IDEX,
   input wire [2:0]Rt_syn_IDEX,
   input wire STALL,
   input wire en,
   input wire [15:0]PC_2_JAL_syn_IDEX,
   input wire full_instr_R_syn_IDEX,
   input wire [15:0] full_instr_syn_IDEX,


   output wire [15:0] alu_result_syn_EXMEM,
   output wire HALT_syn_EXMEM,
   output wire MemRead_syn_EXMEM,
   output wire MemWrite_syn_EXMEM,
   output wire MemReg_syn_EXMEM,
   output wire RegWrite_syn_EXMEM,
   output wire JAL_syn_EXMEM,
   output wire [2:0]RegWrite_addr_syn_EXMEM,
   output wire [15:0]Read_rg_data_1_syn_EXMEM,
   output wire [15:0]Read_rg_data_2_syn_EXMEM,
   output wire [2:0]Rs_syn_EXMEM,
   output wire [2:0]Rt_syn_EXMEM,
   output wire [15:0]PC_2_JAL_syn_EXMEM,
   output wire full_instr_R_syn_EXMEM,
   output wire [15:0] full_instr_syn_EXMEM
);


//module B3register (wdata, writeEn, clk, rst, rdata);
//alu_result
B16register B16_alu_result_EXMEM (.wdata(alu_result), .writeEn(en), .clk(clk), .rst(rst | HALT_c), .rdata(alu_result_syn_EXMEM));

//HALT
B1register B1_HALT_EXMEM(.wdata(HALT_syn_IDEX), .writeEn(en), .clk(clk), .rst(rst), .rdata(HALT_syn_EXMEM));

//MemRead
B1register B1_MemRead_EXMEM(.wdata(MemRead_syn_IDEX), .writeEn(en), .clk(clk), .rst(rst | HALT_c), .rdata(MemRead_syn_EXMEM));

//MemWrite
B1register B1_MemWrite_EXMEM(.wdata(MemWrite_syn_IDEX), .writeEn(en), .clk(clk), .rst(rst | HALT_c), .rdata(MemWrite_syn_EXMEM));

//MemReg
B1register B1_MemReg_EXMEM(.wdata(MemReg_syn_IDEX), .writeEn(en), .clk(clk), .rst(rst | HALT_c), .rdata(MemReg_syn_EXMEM));

//RegWrite
B1register B1_ALU_en_EXMEM(.wdata(RegWrite_syn_IDEX), .writeEn(en), .clk(clk), .rst(rst | HALT_c), .rdata(RegWrite_syn_EXMEM));

//JAL
B1register B1_JAL_EXMEM(.wdata(JAL_syn_IDEX), .writeEn(en), .clk(clk), .rst(rst | HALT_c), .rdata(JAL_syn_EXMEM));

//RegWRite_addr--Rd
B3register B3_RegWrite_addr_EXMEM(.wdata(RegWrite_addr_syn_IDEX), .writeEn(en), .clk(clk), .rst(rst | HALT_c), .rdata(RegWrite_addr_syn_EXMEM));

//Rs, RT
B3register B3_Rs_EXMEM(.wdata(Rs_syn_IDEX), .writeEn(en), .clk(clk), .rst(rst | HALT_c), .rdata(Rs_syn_EXMEM));
B3register B3_Rt_EXMEM(.wdata(Rt_syn_IDEX), .writeEn(en), .clk(clk), .rst(rst | HALT_c), .rdata(Rt_syn_EXMEM));

//Read_rg_data_1
B16register B16_Read_rg_data_1_EXMEM(.wdata(Read_rg_data_1_syn_IDEX), .writeEn(en), .clk(clk), .rst(rst | HALT_c), .rdata(Read_rg_data_1_syn_EXMEM));

//Read_rg_data_2
B16register B16_Read_rg_data_2_EXMEM(.wdata(Read_rg_data_2_syn_IDEX), .writeEn(en), .clk(clk), .rst(rst | HALT_c), .rdata(Read_rg_data_2_syn_EXMEM));

//PC_2_JAL
B16register B1F_PC_2_JAL_EXMEM(.wdata(PC_2_JAL_syn_IDEX), .writeEn(en), .clk(clk), .rst(rst | STALL), .rdata(PC_2_JAL_syn_EXMEM));

//full_instr_R
B1register B1_full_instr_R_EXMEM(.wdata(full_instr_R_syn_IDEX), .writeEn(en), .clk(clk), .rst(rst | HALT_c), .rdata(full_instr_R_syn_EXMEM));

//full_instr
B16register B16_full_instr_EXMEM(.wdata(full_instr_syn_IDEX), .writeEn(en), .clk(clk), .rst(rst | HALT_c), .rdata(full_instr_syn_EXMEM));

endmodule