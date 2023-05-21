module mux4_1_RegWrite(RegDst, RegWrite_addr, full_instr);
    input wire [1:0]RegDst;
    output wire [2:0]RegWrite_addr;// the 'goto' address of the instructions
    input wire [15:0]full_instr;
    assign RegWrite_addr = (RegDst==2'b00)? full_instr[10:8]: 
                       (RegDst==2'b01)? full_instr[7:5] :
                       (RegDst==2'b10)? full_instr[4:2] :
                       3'd7;//R7

endmodule