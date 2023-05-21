module shift_right_arith(InBS, ShAmt, OutBS);
//for the 2'b00 Opcode
input wire [15:0]InBS;
input wire [3:0]ShAmt;
output [15:0]OutBS;

//Opcode 
//2'b00 left shift, LSB filled with 'b0
//2'b01 shift right logical, MSB filled with 'b0
//2'b10 rotate left
//2'b11 shift rith arith, keep the MSB


//shift bit selection logic
wire [15:0]sh_0, sh_1, sh_2, sh_3;//for the 1/2/4/8bits shift temp varibles
assign sh_0=(ShAmt[0])? {InBS[15], InBS[15:1]}:InBS; 
assign sh_1=(ShAmt[1])? {{2{sh_0[15]}}, sh_0[15:2]}:sh_0; 
assign sh_2=(ShAmt[2])? {{4{sh_1[15]}}, sh_1[15:4]}:sh_1; 
assign sh_3=(ShAmt[3])? {{8{sh_2[15]}}, sh_2[15:8]}:sh_2; 

assign OutBS=sh_3;



endmodule