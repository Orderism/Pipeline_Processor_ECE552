module branch_comp(
input wire Branch,//it is a branch instruction!!! Control logic said in decode.v
input wire [4:0]Opcode,//to make sure which kind of branch it is
//COMPARE INPUT Rs 
input wire [15:0]Read_rg_data_1,
//OUTPUT ENABLE FOR THE JUMP
output reg bcomp_en// ready to jump, be used in PC addr mux control
);


//14				01110 sss iiiiiiii		BLTZ Rs, immediate	if (Rs < 0) then PC <- PC + 2 + I(sign ext.)
//15				01111 sss iiiiiiii		BGEZ Rs, immediate	if (Rs >= 0) then PC <- PC + 2 + I(sign ext.)
always@(*)begin
case(Opcode)
5'b01100:bcomp_en=((Read_rg_data_1==3'd0) & (Branch))?1:0;//01100 sss iiiiiiii		BEQZ Rs, immediate	if (Rs == 0) then PC <- PC + 2 + I(sign ext.)
5'b01101:bcomp_en=((Read_rg_data_1!==3'd0) & (Branch))?1:0;//01101 sss iiiiiiii		BNEZ Rs, immediate	if (Rs != 0) then PC <- PC + 2 + I(sign ext.)
5'b01110:bcomp_en=((Read_rg_data_1[15]) & (Branch))?1:0;//BLTZ
5'b01111:bcomp_en=((~(Read_rg_data_1[15]) & (Branch)))?1:0;//bgez
default: bcomp_en=0;
endcase
end



endmodule
