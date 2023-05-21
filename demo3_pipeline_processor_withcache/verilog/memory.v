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
   output wire [15:0]MemRead_data,
   //new signal of mem_cache
   output wire CacheHit_data,
   output wire err_data_mc,////////////for all the err happened in memory ,v whatever it is
   output wire done_data_mc,
   output wire stall_data_mc,
   output wire MEM_addr_invalid_flag
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


   
  
   // Outputs
   // memory2c_align (data_out, data_in, addr, enable, wr, createdump, clk, rst);
   //memory2c_align mmc1(.data_out(MemRead_data), .data_in(MemWrite_data), .addr(alu_result), .enable((MemWrite | MemRead) & (~alu_result[0]) & (~HALT)), .wr((MemWrite /*& (~alu_result[0]*/)), .createdump(HALT), .clk(clk), .rst(rst), .err(err_data_mc));
   //the solution without cache as above, now we start an new epoch
   assign MEM_addr_invalid_flag=(alu_result[0] & ( MemRead | MemWrite));
   //CCCCCCCCCCCC!!!! Cache in it!
      wire err_data_mc_pre;
     // wire[15:0] MemRead_data_pre;
     // assign MemRead_data=(MemRead)? 16'd0: MemRead_data_pre;


   mem_system mem_data_cache(
   .DataOut(MemRead_data),//prev
   .Done(done_data_mc),//new
   .Stall(stall_data_mc), //new
   .CacheHit(CacheHit_data),//new 
   .err(err_data_mc_pre),//new
   // Inputs
   .Addr(alu_result),//prev 
   .DataIn(MemWrite_data), //prev
   .Rd(MemRead & (~alu_result[0]) & (~HALT)), //prev
   .Wr(MemWrite & (~alu_result[0]) & (~HALT)), //prev
   .createdump(HALT), //prev
   .clk(clk), //prev
   .rst(rst)//prev
   );


   assign err_data_mc=err_data_mc_pre & (( MemRead | MemWrite));
  // assign stall_data_mc=0;
   //assign done_data_mc=0;
    //assign CacheHit_data=0;
   ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////for 2.1 back to state








endmodule
`default_nettype wire
