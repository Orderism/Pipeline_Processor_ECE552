module IF_ID_Reg(
    input wire clk,
    input wire rst,
    input wire STALL,
    input wire en,

    input wire HALT_c,
    input wire FLUSH,//for wrong prediction of the branch, FLUSH=bcomp_en, flush will be done in fetch
    input wire [15:0]PC_2_JAL,//input name is same as demo1
    input wire [15:0]full_instr,


    output wire[15:0]PC_2_JAL_syn_IFID,
    output wire [15:0]full_instr_syn_IFID// output name should be 'name demo1'_syn_stages ()

);
//Input
//#1.PC_2_JAL
//#2.full_instr from instruction memory
//output PC_2_JAL
//#1. PC_2_JAL_syn_IFID
//#2. full_instr_IFID
wire [15:0]full_instr_IF_Regin;
assign full_instr_IF_Regin=(rst | FLUSH)?16'h0800:
                           (HALT_c)?16'd0:
                           (STALL)? full_instr_IF_Regin:// if there is a stall needed, hold the current instruction
                           full_instr;




//Reg16
//module B16register (wdata, writeEn, clk, rst, rdata);

//PC+2 register
B16register dff_PC_2_JAL(.wdata(PC_2_JAL), .rdata(PC_2_JAL_syn_IFID), .clk(clk), .rst(rst| HALT_c), .writeEn(en));//

//Instruction register
B16register dff_full_instr(.wdata(full_instr_IF_Regin), .rdata(full_instr_syn_IFID), .clk(clk), .rst(1'b0), .writeEn(en));//



endmodule