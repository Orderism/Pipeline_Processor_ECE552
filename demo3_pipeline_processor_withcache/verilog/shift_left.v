module shift_left(InBS, ShAmt, OutBS);
//for the 2'b00 Opcode
input wire [15:0]InBS;
input wire [3:0] ShAmt;
output [15:0] OutBS;

//Opcode 
//2'b00 left shift, LSB filled with 'b0
//2'b01 shift right logical, MSB filled with 'b0
//2'b10 rotate left
//2'b11 shift rith arith, keep the MSB


//shift bit selection logic
wire [15:0] sh_0, sh_1, sh_2, sh_3;//for the 1/2/4/8bits shift temp varibles
assign sh_0=(ShAmt[0])? {InBS[14:0], 1'b0}:InBS; 
assign sh_1=(ShAmt[1])? {sh_0[13:0], 2'b0}:sh_0; 
assign sh_2=(ShAmt[2])? {sh_1[11:0], 4'b0}:sh_1; 
assign sh_3=(ShAmt[3])? {sh_2[7:0], 8'b0}:sh_2; 

assign OutBS=sh_3;



endmodule