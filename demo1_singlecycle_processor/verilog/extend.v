module extend(ext_sel, full_instr, ext_result);
input [2:0]ext_sel;
input [15:0]full_instr;
output [15:0] ext_result;

// 3'b000:zero extend for lowest 5 bits____LBI,SLBI
// 3'b001:zero extend for lowest 8 bits____XORI,ANDNI,
// 3'b010:signed extend for lowest 5 bits____BEQZ,BNEZ,BLTZ,BGEZ,JR,JALR
// 3'b011:signed extend for lowest 8 bits____ADDI,SUBI,LD,ST,STU
// 3'b100:signed extend for lowest 10 bits____J,JAL

assign ext_result= (ext_sel==3'b000)? {11'b0, full_instr[4:0]}://5 bits zero ext
                   (ext_sel==3'b001)? {8'b0, full_instr[7:0]}://8 bits zero ext
                   (ext_sel==3'b010)? {{11{full_instr[4]}}, full_instr[4:0]}://5 bits signed ext
                   (ext_sel==3'b011)? {{8{full_instr[7]}}, full_instr[7:0]}://8 bits signed ext
                   (ext_sel==3'b100)? {{5{full_instr[10]}}, full_instr[10:0]}://11 bits signed ext
                   full_instr;//10 bits signed extend


endmodule