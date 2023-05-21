/*
   CS/ECE 552 Spring '22
  
   Filename        : decode.v
   Description     : This is the module for the overall decode stage of the processor.
*/
`default_nettype none
module decode (
   //control signal input
   input wire [15:0] full_instr,
   input wire rst,
   input wire clk,
   input wire [15:0]Writeback_data,
   //hazard 5&6 forwarding input
   input wire hazard5_EX2ID_flag,
   input wire hazard6_MEM2ID_flag,
   input wire [15:0]MemRead_data,
   input wire [15:0]alu_result,
   input wire STALL,
   //writeback part
   input wire [2:0] RegWrite_addr_syn_MEMWB,
   input wire RegWrite_syn_MEMWB,
   //branch forwarding
   input wire [15:0] alu_result_syn_EXMEM,
   input wire MemRead_syn_EXMEM,



   //control signal output 
   output reg [1:0]RegDst,//RegDst as the selection for the write back address
   output reg HALT,//Halt be 1 when halt
   output reg Jump,//'PC+2' or 'PC+2+ext(I)'
   output reg Branch,//
   output reg MemRead,//
   output reg MemReg,//
   output reg MemWrite,
   output reg ALUsrc,//ALU inB from Rd'0' or from extended imm_number'1' 
   output wire [7:0]ALU_op,//Be used as the control signal of ALU in Excution stage
   output reg ALU_en,
   output reg RegWrite,
   output reg JR,//JR, JALR, when we need to control PC in fetch
   output reg LBI_flag,//for LBI flag write back avoid the ex/mem period
   output reg JAL,//for JAL, JALR, when we need to write back the PC+2 into R7
   output reg [2:0]ext_sel,
   output wire [15:0]ext_result,
   output wire [2:0] RegWrite_addr,
   output wire [2:0] Rs_asyn_ID,
   output wire [2:0] Rt_asyn_ID,
   //module Register
   output wire [15:0]Read_rg_data_1,//Rs
   output wire [15:0]Read_rg_data_2,//Rd
   output wire decode_err,
   //module branch Comparator
   output wire bcomp_en,
   output reg SIIC_flag,
   output wire full_instr_R
);

   // TODO: Your code here


/*
/		         INPUTS: Op_code - Instruction to be performed
/0					00000 xxxxxxxxxxx	HALT	Cease instruction issue, dump memory state to file
/1					00001 xxxxxxxxxxx	NOP	None


/8		    		01000 sss ddd iiiii		ADDI Rd, Rs, immediate	Rd <- Rs + I(sign ext.)
/9			   	01001 sss ddd iiiii		SUBI Rd, Rs, immediate	Rd <- I(sign ext.) - Rs
/10				01010 sss ddd iiiii		XORI Rd, Rs, immediate	Rd <- Rs XOR I(zero ext.)
/11				01011 sss ddd iiiii		ANDNI Rd, Rs, immediate	Rd <- Rs AND ~I(zero ext.)
/20				10100 sss ddd iiiii		ROLI Rd, Rs, immediate	Rd <- Rs <<(rotate) I(lowest 4 bits)
/21				10101 sss ddd iiiii		SLLI Rd, Rs, immediate	Rd <- Rs << I(lowest 4 bits)
/22				10110 sss ddd iiiii		RORI Rd, Rs, immediate	Rd <- Rs >>(rotate) I(lowest 4 bits)
/23				10111 sss ddd iiiii		SRLI Rd, Rs, immediate	Rd <- Rs >> I(lowest 4 bits)
/16				10000 sss ddd iiiii		ST Rd, Rs, immediate	Mem[Rs + I(sign ext.)] <- Rd
/17				10001 sss ddd iiiii		LD Rd, Rs, immediate	Rd <- Mem[Rs + I(sign ext.)]
/19				10011 sss ddd iiiii		STU Rd, Rs, immediate	Mem[Rs + I(sign ext.)] <- Rd, Rs <- Rs + I(sign ext.)


/25				11001 sss xxx ddd xx	BTR Rd, Rs	Rd[bit i] <- Rs[bit 15-i] for i=0..15
/27				11011 sss ttt ddd 00	ADD Rd, Rs, Rt	Rd <- Rs + Rt
/27				11011 sss ttt ddd 01	SUB Rd, Rs, Rt	Rd <- Rt - Rs
/27				11011 sss ttt ddd 10	XOR Rd, Rs, Rt	Rd <- Rs XOR Rt
/27				11011 sss ttt ddd 11	ANDN Rd, Rs, Rt	Rd <- Rs AND ~Rt
/26				11010 sss ttt ddd 00	SLL Rd, Rs, Rt	Rd <- Rs << Rt (lowest 4 bits)
/26				11010 sss ttt ddd 01	SRL Rd, Rs, Rt	Rd <- Rs >> Rt (lowest 4 bits)
/26				11010 sss ttt ddd 10	ROL Rd, Rs, Rt	Rd <- Rs << (rotate) Rt (lowest 4 bits)
/26				11010 sss ttt ddd 11	ROR Rd, Rs, Rt	Rd <- Rs >> (rotate) Rt (lowest 4 bits)
/28				11100 sss ttt ddd xx	SEQ Rd, Rs, Rt	if (Rs == Rt) then Rd <- 1 else Rd <- 0
/29				11101 sss ttt ddd xx	SLT Rd, Rs, Rt	if (Rs < Rt) then Rd <- 1 else Rd <- 0
/30   		  	11110 sss ttt ddd xx	SLE Rd, Rs, Rt	if (Rs <= Rt) then Rd <- 1 else Rd <- 0
/31				11111 sss ttt ddd xx	SCO Rd, Rs, Rt	if (Rs + Rt) generates carry out then Rd <- 1 else Rd <- 0


/12				01100 sss iiiiiiii		BEQZ Rs, immediate	if (Rs == 0) then PC <- PC + 2 + I(sign ext.)
/13				01101 sss iiiiiiii		BNEZ Rs, immediate	if (Rs != 0) then PC <- PC + 2 + I(sign ext.)
/14				01110 sss iiiiiiii		BLTZ Rs, immediate	if (Rs < 0) then PC <- PC + 2 + I(sign ext.)
/15				01111 sss iiiiiiii		BGEZ Rs, immediate	if (Rs >= 0) then PC <- PC + 2 + I(sign ext.)
/24				11000 sss iiiiiiii		LBI Rs, immediate	Rs <- I(sign ext.)
/18				10010 sss iiiiiiii		SLBI Rs, immediate	Rs <- (Rs << 8) | I(zero ext.)

/4	      		00100 ddddddddddd		J displacement	PC <- PC + 2 + D(sign ext.)
/5			   	00101 sss iiiiiiii	JR Rs, immediate	PC <- Rs + I(sign ext.)
/6			   	00110 ddddddddddd		JAL displacement	R7 <- PC + 2, ///PC <- PC + 2 + D(sign ext.)
/7			   	00111 sss iiiiiiii	JALR Rs, immediate	R7 <- PC + 2 ///PC <- Rs + I(sign ext.)

/2			   	00010 siic Rs			produce IllegalOp exception. Must provide one source register.
/3			   	00011 xxxxxxxxxxx		NOP / RTI	PC <- EPC
*/

   wire [4:0]Op_code;
   wire [1:0]Op_func;
   assign Op_code = full_instr[15:11];
   assign Op_func = full_instr[1:0];  
   reg [3:0]ALU_mode;
   assign full_instr_R= (full_instr[15:12]==4'b1101) | (full_instr[15:13]==3'b111);

   //The Rs and Rd will come from the full_instr_syn_IFID
   // for the hazard control logic
   assign Rs_asyn_ID=full_instr[10:8];// for all instructions
   //assign Rd_asyn_ID=RegWrite_addr;
   assign Rt_asyn_ID=full_instr[7:5];





   //All instruction case control logic
   always @(*) begin
      //initial the control signal
      RegDst=2'd0;
      HALT=0;
      Jump=0;
      Branch=0;
      MemRead=0;
      MemReg=0;
      MemWrite=0;
      RegWrite=0;
      ALU_mode=4'd8;//IDLE, set ALUop to d8 when do nothing, (at that time ALU_op is 8'd1), distinct from the sll
      ALU_en=0;
      ext_sel=3'd0;
      JR=0;
      LBI_flag=0;
      JAL=0;
      ALUsrc=0;
      SIIC_flag=1;

      //bcomp_en=0;
   case (Op_code)

   5'd0:begin// Halt do nothing, PC=cur_PC
   HALT=1;
   ALU_mode=4'd8; 
   ALU_en=0;
   end

   5'd1:begin// NOP, PC=PC+2
     // ALU_mode=4'd8; 
   ALU_en=0;
   end

   5'd2: begin//siic, do nothing?// need to complete the alu logic parts just like the STU store the data, it store the instructions
   MemWrite=1;
   SIIC_flag=1;
   ALU_mode=4'd8; 
   ALU_en=0;
   end

   5'd3: begin//NOP / RTI	PC <- EPC???
   //save the PC address to R7, PC=PC+2
   ///////////////////////////////////////////???
   ALU_mode=4'd8; 
   ALU_en=0;
   end

   5'd4: begin//00100 ddddddddddd		J displacement	PC <- PC + 2 + D(sign ext.)
   Jump=1;
   ext_sel=3'd4;
   ALU_mode=4'd8; 
   ALU_en=0;
   end

   5'd5: begin//00101 sss iiiiiiii	JR Rs, immediate	PC <- Rs + I(sign ext.)
   JR=1;
   ext_sel=3'b011;
   ALU_mode=4'd0; 
   ALU_en=1;
   ALUsrc=1;
   end

   5'd6: begin//00110 ddddddddddd		JAL displacement	R7 <- PC + 2, PC <- PC + 2 + D(sign ext.)
   RegWrite=1;
   RegDst=2'b11;
   Jump=1;
   ext_sel=3'b100;
   JAL=1;
   ALU_mode=4'd8; 
   ALU_en=0;
   end

   5'd7: begin//00111 sss iiiiiiii	JALR Rs, immediate	R7 <- PC + 2 /.////PC <- Rs + I(sign ext.)
   RegWrite=1;
   RegDst=2'b11;
   JR=1;
   ext_sel=3'b011;
   JAL=1;
   ALU_mode=4'd0; 
   ALU_en=1;
   ALUsrc=1;
   end

   5'd8: begin//01000 sss ddd iiiii		ADDI Rd, Rs, immediate	Rd <- Rs + I(sign ext.)
   RegWrite=1;
   ALUsrc=1;
   RegDst=2'b01;
   ext_sel=3'b010;
   ALU_mode=4'd0; 
   ALU_en=1;
   end
   
   5'd9: begin//01001 sss ddd iiiii		SRead_rg_data_2UBI Rd, Rs, immediate	Rd <- I(sign ext.) - Rs
   RegWrite=1;
   ALUsrc=1;
   RegDst=2'b01;
   ext_sel=3'b010;
   ALU_mode=4'd1; 
   ALU_en=1;
   end

   5'd10: begin//01010 sss ddd iiiii		XORI Rd, Rs, immediate	Rd <- Rs XOR I(zero ext.)
   RegWrite=1;
   ALUsrc=1;
   RegDst=2'b01;
   ext_sel=3'b000;
   ALU_mode=4'd2; 
   ALU_en=1;
   end

   5'd11: begin//01011 sss ddd iiiii		ANDNI Rd, Rs, immediate	Rd <- Rs AND ~I(zero ext.)
   RegWrite=1;
   ALUsrc=1;
   RegDst=2'b01;
   ext_sel=3'b000;
   ALU_mode=4'd3; 
   ALU_en=1;
   end

   5'd12, 5'd13, 5'd14, 5'd15: begin
//12           01100 sss iiiiiiii		BEQZ Rs, immediate	if (Rs == 0) then PC <- PC + 2 + I(sign ext.)
//13				01101 sss iiiiiiii		BNEZ Rs, immediate	if (Rs != 0) then PC <- PC + 2 + I(sign ext.)
//14				01110 sss iiiiiiii		BLTZ Rs, immediate	if (Rs < 0) then PC <- PC + 2 + I(sign ext.)
//15				01111 sss iiiiiiii		BGEZ Rs, immediate	if (Rs >= 0) then PC <- PC + 2 + I(sign ext.)
   //ALU opcode is same and we will finish it in the branch_comp.v
   Branch=1;
   ext_sel=3'b011;
   ALU_mode=4'd8; 
   ALU_en=0;
   end

   5'd16: begin//10000 sss ddd iiiii		ST Rd, Rs, immediate	Mem[Rs + I(sign ext.)] <- Rd
   MemWrite=1;
   ALUsrc=1;
   ext_sel=3'b010;
   ALU_mode=4'd0; 
   ALU_en=1;
   end

   5'd17: begin//10001 sss ddd iiiii		LD Rd, Rs, immediate	Rd <- Mem[Rs + I(sign ext.)]
   MemRead=1;
   MemReg=1;
   RegWrite=1;
   RegDst=2'b01;
   ALUsrc=1;
   ext_sel=3'b010;
   ALU_mode=4'd0; 
   ALU_en=1;
   end

   5'd18: begin//10010 sss iiiiiiii		SLBI Rs, immediate	Rs <- (Rs << 8) | I(zero ext.)
   //NEED 1 MORE signal to left shift before data enter ALU
   //SLBI_flag=1;
   RegWrite=1;
   ext_sel=3'b001;
   ALU_mode=4'd9; 
   ALU_en=1;
   ALUsrc=1;
   end

			
   5'd19: begin//10011 sss ddd iiiii		STU Rd, Rs, immediate	Mem[Rs + I(sign ext.)] <- Rd, Rs <- Rs + I(sign ext.)
   MemRead=0;
   MemWrite=1;
   RegWrite=1;
   ALUsrc=1;
   ext_sel=3'b010;
   ALU_mode=4'd0; 
   ALU_en=1;   
   end

   5'd20, 5'd21, 5'd22, 5'd23: begin
//20				10100 sss ddd iiiii		ROLI Rd, Rs, immediate	Rd <- Rs <<(rotate) I(lowest 4 bits)
//21				10101 sss ddd iiiii		SLLI Rd, Rs, immediate	Rd <- Rs << I(lowest 4 bits)
//22				10110 sss ddd iiiii		RORI Rd, Rs, immediate	Rd <- Rs >>(rotate) I(lowest 4 bits)
//23				10111 sss ddd iiiii		SRLI Rd, Rs, immediate	Rd <- Rs >> I(lowest 4 bits)
   ALUsrc=1;
   RegWrite=1;
   RegDst=2'b01;
   ext_sel=3'b010;
   ALU_en=1;
   ALU_mode=(Op_code==5'd20)? 4'd6:
            (Op_code==5'd21)? 4'd4:
            (Op_code==5'd22)? 4'd7:
            4'd5 ;//(Op_code==5'd23)? 
   end
   
   5'd24: begin//11000 sss iiiiiiii		LBI Rs, immediate	Rs <- I(sign ext.)
   RegWrite=1;
   LBI_flag=1;
   ext_sel=3'b011;
   ALU_mode=4'd0; 
   ALU_en=0; 
   RegDst=2'b00;
   end

   5'd25: begin//11001 sss xxx ddd xx	BTR Rd, Rs	Rd[bit i] <- Rs[bit 15-i] for i=0..15 $$$$$$$$$$$$$$$$$$$$$
   RegWrite=1;
   RegDst=2'b10;
   ALU_mode=4'd11; 
   ALU_en=1;  
   end

   5'd26: begin
//26				11010 sss ttt ddd 00	SLL Rd, Rs, Rt	Rd <- Rs << Rt (lowest 4 bits)
//26				11010 sss ttt ddd 01	SRL Rd, Rs, Rt	Rd <- Rs >> Rt (lowest 4 bits)
//26				11010 sss ttt ddd 10	ROL Rd, Rs, Rt	Rd <- Rs << (rotate) Rt (lowest 4 bits)
//26				11010 sss ttt ddd 11	ROR Rd, Rs, Rt	Rd <- Rs >> (rotate) Rt (lowest 4 bits)
   RegWrite=1;
   RegDst=2'b10;
   ALU_en=1;

   //ALU op is different based on the Op_func
   ALU_mode=(Op_func==2'b00)? 4'd4:
          (Op_func==2'b01)? 4'd5:
          (Op_func==2'b10)? 4'd6:
          4'd7;// if(Op_func==2'b11) 
   end


   5'd27: begin
//27				11011 sss ttt ddd 00	ADD Rd, Rs, Rt	Rd <- Rs + Rt
//27				11011 sss ttt ddd 01	SUB Rd, Rs, Rt	Rd <- Rt - Rs
//27				11011 sss ttt ddd 10	XOR Rd, Rs, Rt	Rd <- Rs XOR Rt
//27				11011 sss ttt ddd 11	ANDN Rd, Rs, Rt	Rd <- Rs AND ~Rt
   RegWrite=1;
   RegDst=2'b10;
   ALU_en=1;
   ALU_mode=(Op_func==2'b00)? 4'd0:
          (Op_func==2'b01)? 4'd1:
          (Op_func==2'b10)? 4'd2:
          4'd3;// if(Op_func==2'b11) 
   ALUsrc=0;
   end

   5'd28: begin//11100 sss ttt ddd xx	SEQ Rd, Rs, Rt	if (Rs == Rt) then Rd <- 1 else Rd <- 0
   RegWrite=1;
   RegDst=2'b10;
   ALU_en=1;
   ALU_mode=4'd12;
   end



   5'd29: begin//11101 sss ttt ddd xx	SLT Rd, Rs, Rt	if (Rs < Rt) then Rd <- 1 else Rd <- 0
   RegWrite=1;
   RegDst=2'b10;
   ALU_en=1;
   ALU_mode=4'd13;
   end

   5'd30: begin//11110 sss ttt ddd xx	SLE Rd, RsRead_rg_data_2
   RegWrite=1;
   RegDst=2'b10;
   ALU_en=1;
   ALU_mode=4'd14;


   end
   5'd31: begin//11111 sss ttt ddd xx	SCO Rd, Rs, Rt	if (Rs + Rt) generates carry out then Rd <- 1 else Rd <- 0
   RegWrite=1;
   RegDst=2'b10;
   ALU_en=1;
   ALU_mode=4'd10;
   end

   endcase
end

//from the decode control logic, we send the 'alu mode', 'alu enable' into the ALU cntrl

ALU_cntrl ctl(.ALU_mode(ALU_mode), .ALU_en(ALU_en) , .ALU_op(ALU_op));

//Mux 4 to 1 DUT
//module mux4_1_RegWrite(RegDst, RegWrite_addr, full_instr);
mux4_1_RegWrite RW41(.RegDst(RegDst), .RegWrite_addr(RegWrite_addr), .full_instr(full_instr));


//Extend DUT
//module extend(ext_sel, full_instr, ext_result);
extend extend1(.ext_sel(ext_sel), .full_instr(full_instr), .ext_result(ext_result));


//Registers DUT
//get part of the instruction and read the data from the matched place (output data to the ALU)
   wire [2:0]Read_rg_addr_1;//full_instr[10:8]
   wire [2:0]Read_rg_addr_2;//full_instr[7:5]
   assign Read_rg_addr_1=full_instr[10:8]; //Rs for all instructions who have Rs
   assign Read_rg_addr_2=full_instr[7:5]; //Rd
   wire IDcontrol_err;
   wire IDregister_err;
   assign decode_err= IDcontrol_err | IDregister_err;
        rf_bypass rfInst(
           .read1OutData(Read_rg_data_1), .read2OutData(Read_rg_data_2), .err(IDregister_err),
           .clk(clk), .rst(rst), .read1RegSel(Read_rg_addr_1), .read2RegSel(Read_rg_addr_2),
           .writeRegSel(RegWrite_addr_syn_MEMWB), .writeInData(Writeback_data), .writeEn(RegWrite_syn_MEMWB)
           );




//forwarding branch jump:

//Example (EX to ID):5
//ADDI r1,r2,1000;
//BEQZ r1, 350;
//Example (Mem to ID):6
//LD r1, 1000;
//BEQZ r1, 350;
wire [15:0]Read_rg_data_1_fw;
assign Read_rg_data_1_fw = (hazard5_EX2ID_flag)? alu_result://if datahazard5, send the alu_result as to the input of comparator
                          (hazard6_MEM2ID_flag & MemRead_syn_EXMEM)? MemRead_data://if datahazard6, send the MemRead_data as the input of comparator
                          (hazard6_MEM2ID_flag & (~MemRead_syn_EXMEM))? alu_result_syn_EXMEM:
                          Read_rg_data_1;


//Branch Comparator DUT
//module branch_comp(Branch, Opcode, Read_rg_addr_1, bcomp_en);
branch_comp bc(.Branch(Branch), .Opcode(Op_code), .Read_rg_data_1(Read_rg_data_1_fw), .bcomp_en(bcomp_en));
endmodule
`default_nettype wire
