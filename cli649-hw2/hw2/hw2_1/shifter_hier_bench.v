/*
    CS/ECE 552 Spring '23
    Homework #2, Problem 1
    
    Testbench for the barrel shifter.  It is not exhaustive.  Rather,
    it uses random values for In, ShAmt, and Oper across a large timespan
    to test as many cases as possible and compare it with the golden
    output (Expected).
 */
`default_nettype none
module shifter_hier_bench;

    // declare constant for size of inputs, outputs (N) and # bits to shift (C)
    parameter OP_WIDTH    = 16;
    parameter SHAMT_WIDTH =  4;
    parameter NUM_OPS     =  2;   

    // Signals for barrel shifter 
    reg [OP_WIDTH   -1:0] In;
    reg [SHAMT_WIDTH-1:0] ShAmt;
    reg [NUM_OPS    -1:0] Oper;
    wire [OP_WIDTH  -1:0] Out;

    reg                   fail;

    reg [31:0]            Expected;
    integer               idx;

    shifter_hier #(.OPERAND_WIDTH(OP_WIDTH),
                   .SHAMT_WIDTH(SHAMT_WIDTH),
                   .NUM_OPERATIONS(NUM_OPS)) 
                 DUT (.In(In), .ShAmt(ShAmt), .Oper(Oper), .Out(Out));

    initial begin
        In = 16'h0000;
        ShAmt = 4'b0000;
        Oper = 2'b00;
        fail = 0;
        
        #10000;
        if (fail)
            $display("TEST FAILED");
        else
            $display("TEST PASSED!  YAHOOO!!");
        $finish;
    end

    always @(posedge DUT.clk) begin
        In[15:0] = $random;
        ShAmt[3:0] = $random;
        Oper[1:0] = $random;
    end

   
    always @(negedge DUT.clk) begin
        case (Oper)
            2'b00 : begin // Shift Left
                Expected = In << ShAmt;

                if (Expected[15:0] !== Out) begin
                    $display("ERRORCHECK :: BarrelShifter :: Shift Left        : ShAmt : %d, In = 0x%x ; Expected : 0x%x, Got 0x%x", 
                            ShAmt, 
                            In, 
                            Expected[15:0], 
                            Out);
                    fail = 1;
                end else begin
                    $display("LOG :: BarrelShifter :: Shift Left        : ShAmt : %d, In = 0x%x ; Expected : 0x%x, Got 0x%x", 
                            ShAmt, 
                            In, 
                            Expected[15:0], 
                            Out);
                end
            end
            2'b01 : begin // Shift Right Logical
                Expected = In >> ShAmt;

                if (Expected[15:0] !== Out) begin
                    $display("ERRORCHECK :: BarrelShifter :: Shift Right Logic : ShAmt : %d, In = 0x%x ; Expected : 0x%x, Got 0x%x", 
                            ShAmt, 
                            In, 
                            Expected[15:0], 
                            Out);
                    fail = 1;
                end else begin
                    $display("LOG :: BarrelShifter :: Shift Right Logic : ShAmt : %d, In = 0x%x ; Expected : 0x%x, Got 0x%x", 
                            ShAmt, 
                            In, 
                            Expected[15:0], 
                            Out);
                end
            end
            2'b10 : begin // Rotate Left
                Expected = (In << ShAmt) | (In >> (16-ShAmt));

                if (Expected[15:0] !== Out) begin
                    $display("ERRORCHECK :: BarrelShifter :: Rotate Left       : ShAmt : %d, In = 0x%x ; Expected : 0x%x, Got 0x%x", 
                            ShAmt, 
                            In, 
                            Expected[15:0], 
                            Out);
                    fail = 1;
                end else begin
                    $display("LOG :: BarrelShifter :: Rotate Left       : ShAmt : %d, In = 0x%x ; Expected : 0x%x, Got 0x%x", 
                            ShAmt, 
                            In, 
                            Expected[15:0], 
                            Out);
                end
            end
            2'b11 : begin // Shift Right Arithmetic
                for(idx = 31; idx > 15 ; idx = idx - 1)
                    Expected[idx] = In[15];

                Expected[15:0] = In[15:0];
                Expected[15:0] = Expected >> ShAmt;
                if (Expected[15:0] !== Out) begin
                    $display("ERRORCHECK :: BarrelShifter :: Shift Right Arith : ShAmt : %d, In = 0x%x ; Expected : 0x%x, Got 0x%x", 
                            ShAmt, 
                            In, 
                            Expected[15:0], 
                            Out);
                    fail = 1;
                end else begin
                    $display("LOG :: BarrelShifter :: Shift Right Arith : ShAmt : %d, In = 0x%x ; Expected : 0x%x, Got 0x%x", 
                            ShAmt, 
                            In, 
                            Expected[15:0], 
                            Out);
                end
            end
        endcase
    end
   
endmodule // shifter_hier_bench
`default_nettype wire
