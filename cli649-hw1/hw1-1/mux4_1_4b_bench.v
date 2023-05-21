`default_nettype none
module mux4_1_4b_bench;
    // No inputs and outputs : testbenchs just a wrapper.

    // reg/wire definitions, we'll use these to drive our inputs and capture our outputs
    reg [3:0] inA;
    reg [3:0] inB;
    reg [3:0] inC;
    reg [3:0] inD;
    reg [1:0] s;

    wire [3:0] out;

    wire clk;
    //2 dummy wires
    wire rst;
    wire err;

    //clkrst module instantiation
    clkrst my_clkrst( .clk(clk), .rst(rst), .err(err));

    // Module instantiation :
    mux4_1_4b DUT (.out(out), .inputA(inA), .inputB(inB), .inputC(inC), .inputD(inD), .sel(s));

    // Input drivers :
    //  Check every combination of S

    // Whatever you put within an initial block will be executed
    // when simulation starts
    initial begin
        // Lets initialize all inputs (We dont want any 'Z's)
        inA = 4'b0001;
        inB = 4'b1000;
        inC = 4'b1010;
        inD = 4'b0101;
        s = 2'b00;
        // #10 means wait for a delay of 10 ticks.
        // By doing this we hold every singal for some time, which allows
        // for the combinational logical delay and for the output to be computed

        #3200    $finish;
    end // initial begin
    // The test is not complete (we didn't check every combination of all inputs, InA for example. But we can be pretty confident if this much works.

    //Random values 
    always@(posedge clk) begin
        inA = $random;
        inB = $random;
        inC = $random;
        inD = $random;
        s = $random;
    end

    // Output monitors
    always@(negedge clk) begin
       // Sensitivity list ^^^ tells Modelsim what this always block is "sensitive" to.
       // Try to figure out what happens if you didnt include lets say InC...
       // Whenever any of these signals change, this block will execute
       case (s)
           // This is a behavior description of what the mux is supposed to do...
           // For every combination of S :
           2'b00 : 
               if (out !== inA) $display ("ERRORCHECK inA s=0");
           2'b01 : 
               if (out !== inB) $display ("ERRORCHECK inB s=1");  
           2'b10 :
               if (out !== inC) $display ("ERRORCHECK inC s=2");
           2'b11 : 
               if (out !== inD) $display ("ERRORCHECK inD s=3");
        endcase // case (S)
    end // always@ (s, inA, inB, inC, inD, out)
endmodule // End of module : mux4_1_4b_bench
`default_nettype wire
