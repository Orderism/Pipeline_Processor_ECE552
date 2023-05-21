module MEM_WB_Reg ( 
   input clk,
   input rst,
   input wire [15:0]MemRead_data,
   input wire HALT_syn_EXMEM,
   input wire MemReg_syn_EXMEM,
   input wire JAL_syn_EXMEM,
   input wire [15:0]alu_result_syn_EXMEM,
   input wire [2:0]RegWrite_addr_syn_EXMEM,
   input wire RegWrite_syn_EXMEM,
   input wire STALL,
   input wire en,
   input wire [15:0] PC_2_JAL_syn_EXMEM,
   input wire full_instr_R_syn_EXMEM,
   input wire [15:0]full_instr_syn_EXMEM,
   input wire HALT_c,
   input wire MemRead_syn_EXMEM,

   output wire [15:0]MemRead_data_syn_MEMWB,
   output wire HALT_syn_MEMWB,
   output wire MemReg_syn_MEMWB,
   output wire JAL_syn_MEMWB,
   output wire [15:0]alu_result_syn_MEMWB,   
   output wire [2:0]RegWrite_addr_syn_MEMWB,
   output wire RegWrite_syn_MEMWB,
   output wire [15:0]PC_2_JAL_syn_MEMWB,
   output wire full_instr_R_syn_MEMWB,
   output wire [15:0]full_instr_syn_MEMWB,
   output wire MemRead_syn_MEMWB
);




//MemRead_data
B16register B16_MemRead_data_MEMWB (.wdata(MemRead_data), .writeEn(en), .clk(clk), .rst(rst| HALT_c ), .rdata(MemRead_data_syn_MEMWB));

//HALT
B1register B1_HALT_MEMWB(.wdata(HALT_syn_EXMEM), .writeEn(en), .clk(clk), .rst(rst), .rdata(HALT_syn_MEMWB));

//MemReg
B1register B1_MemReg_MEMWB(.wdata(MemReg_syn_EXMEM), .writeEn(en), .clk(clk), .rst(rst | HALT_c), .rdata(MemReg_syn_MEMWB));

//JAL
B1register B1_JAL_MEMWB(.wdata(JAL_syn_EXMEM), .writeEn(en), .clk(clk), .rst(rst | HALT_c), .rdata(JAL_syn_MEMWB));

//alu_result
B16register B16_alu_result_MEMWB(.wdata(alu_result_syn_EXMEM), .writeEn(en), .clk(clk), .rst(rst | HALT_c), .rdata(alu_result_syn_MEMWB));

//RegWrite_addr
B3register B3_RegWrite_addr_MEMWB(.wdata(RegWrite_addr_syn_EXMEM), .writeEn(en), .clk(clk), .rst(rst | HALT_c), .rdata(RegWrite_addr_syn_MEMWB));

//RegWrite
B1register B1_RegWrite_MEMWB(.wdata(RegWrite_syn_EXMEM), .writeEn(en), .clk(clk), .rst(rst | HALT_c), .rdata(RegWrite_syn_MEMWB));

//PC_2_JAL
B16register B1F_PC_2_JAL_MEMWB(.wdata(PC_2_JAL_syn_EXMEM), .writeEn(en), .clk(clk), .rst(rst | HALT_c), .rdata(PC_2_JAL_syn_MEMWB));

//full_instr_R
B1register B1_full_instr_R_MEMWB(.wdata(full_instr_R_syn_EXMEM), .writeEn(1'b1), .clk(clk), .rst(rst |  HALT_c), .rdata(full_instr_R_syn_MEMWB));

//full_instr
B16register B16_full_instr_MEMWB(.wdata(full_instr_syn_EXMEM), .writeEn(1'b1), .clk(clk), .rst(rst |  HALT_c), .rdata(full_instr_syn_MEMWB));

//MemRead
B1register B1_MemRead_MEMWB(.wdata(MemRead_syn_EXMEM), .writeEn(en), .clk(clk), .rst(rst | HALT_c), .rdata(MemRead_syn_MEMWB));





endmodule