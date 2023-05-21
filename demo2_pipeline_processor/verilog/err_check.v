module err_check(in, err);
input wire in;
output wire err;

assign err=((in==1'b1) | (in==1'b0))? 1'b0 :1'b1;



endmodule