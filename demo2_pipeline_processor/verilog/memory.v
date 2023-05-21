/*
   CS/ECE 552 Spring '22
  
   Filename        : memory.v
   Description     : This module contains all components in the Memory stage of the 
                     processor.
*/
`default_nettype none
module memory (
   input wire clk, rst,
   input wire HALT,
   input wire MemRead,
   input wire MemWrite,
   input wire SIIC_flag,
   input wire [15:0]Read_rg_data_2, //Rd FOR ST
   input wire [15:0]Read_rg_data_1,
   input wire [15:0]alu_result,
   //hazard 3 MEM to MEM forwarding
   input wire hazard4_L2S_flag, 
   input wire [15:0]Writeback_data,
// input wire [15:0]Memaddress
   output wire [15:0]MemRead_data

);
//   assign Memaddress=alu_result'
// Mem write data logic
   wire[15:0]MemWrite_data;
   assign MemWrite_data= (MemWrite)?Read_rg_data_2://Both ST and STU use the R2 data
                  //(SIIC_flag | HALT)?full_instr://work for the instruction STORE
                  (hazard4_L2S_flag)?Writeback_data:
                  MemWrite_data;

//Mem write address
//it always the alu_result!
/*
   wire [15:0]Mem_addr;
   assign Mem_addr=()? alu_result://LD Rd, Rs, immediate	Rd <- Mem[Rs + I(sign ext.)]
            (MemWrite)? Read_rg_data_1://ST Rd, Rs, immediate	Mem[Rs + I(sign ext.)] <- Rd
            alu_result;//STU Rd, Rs, immediate	Mem[Rs + I(sign ext.)] <- Rd, Rs <- Rs + I(sign ext.)
*/



   wire writeEn;
   assign writeEn=(MemRead)|(MemWrite);
   // TODO: Your code here
   //module memory2c (data_out, data_in, addr, enable, wr, createdump, clk, rst);
   memory2c mmc(.data_out(MemRead_data), .data_in(MemWrite_data), .addr(alu_result), .enable(writeEn), .wr((MemWrite)), .createdump(HALT), .clk(clk), .rst(rst));
endmodule
`default_nettype wire
