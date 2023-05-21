/*
   CS/ECE 552, Spring '23
   Homework #3, Problem #1
  
   Random testbench for the 8x16b register file.
*/
module tb_rf_hier(/*AUTOARG*/);
    /*AUTOWIRE*/
    // Beginning of automatic wires (for undeclared instantiated-module outputs)
    wire [15:0]          read1Data;              // From top of rf_hier.v
    wire [15:0]          read2Data;              // From top of rf_hier.v
    // End of automatics
    /*AUTOREGINPUT*/
    // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
    reg [2:0]            read1RegSel;            // To top of rf_hier.v
    reg [2:0]            read2RegSel;            // To top of rf_hier.v
    reg                  writeEn;                // To top of rf_hier.v
    reg [15:0]           writeData;              // To top of rf_hier.v
    reg [2:0]            writeRegSel;            // To top of rf_hier.v
    // End of automatics

    integer              cycle_count;

    wire                 clk;
    wire                 rst;

    reg                  fail;

    // Instantiate the module we want to verify
    rf_hier DUT(/*AUTOINST*/
                     // Outputs
                     .read1Data               (read1Data[15:0]),
                     .read2Data               (read2Data[15:0]),
                     // Inputs
                     .read1RegSel             (read1RegSel[2:0]),
                     .read2RegSel             (read2RegSel[2:0]),
                     .writeRegSel             (writeRegSel[2:0]),
                     .writeData               (writeData[15:0]),
                     .writeEn                 (writeEn));

    // Pull out clk and rst from clkgenerator module
    assign               clk = DUT.clk_generator.clk;
    assign               rst = DUT.clk_generator.rst;

    // ref_rf is our reference register file
    reg [15:0]           ref_rf[7:0];
    reg [15:0]           ref_r1data;
    reg [15:0]           ref_r2data;

    initial begin
       cycle_count = 0;
       ref_rf[0] = 0;
       ref_rf[1] = 0;
       ref_rf[2] = 0;
       ref_rf[3] = 0;
       ref_rf[4] = 0;
       ref_rf[5] = 0;
       ref_rf[6] = 0;
       ref_rf[7] = 0;
       ref_r1data = 0;
       ref_r2data = 0;
       writeEn = 0;
       fail = 0;
       $dumpvars;
    end

    always @ (posedge clk)begin
        // create 2 random read ports
        read1RegSel = $random % 8;
        read2RegSel = $random % 8;

        // create random data
        writeData = $random % 65536;

        // create a random write port
        writeRegSel = $random % 8;

        // randomly choose whether to write or not
        writeEn = $random % 2;

        // Read values from reference model
        ref_r1data = ref_rf[ read1RegSel ];
        ref_r2data = ref_rf[ read2RegSel ];

        // Reference model. We compare simulation against this
        // Write data into reference model
        if ((cycle_count >= 2) && writeEn) begin
            ref_rf[ writeRegSel ] = writeData;
        end

        // Delay for simulation to occur
        #10;

        // Print log of what transpired
        $display("Cycle: %d R1: 0x%x Sim: 0x%x Exp: 0x%x R2: 0x%x Sim: 0x%x Exp: 0x%x W: 0x%x data: 0x%x enable: 0x%x",
                 cycle_count,
                 read1RegSel, read1Data, ref_r1data,
                 read2RegSel, read2Data, ref_r2data,
                 writeRegSel, writeData, writeEn );
        if ( !rst && ( (ref_r1data !== read1Data)
                       ||  (ref_r2data !== read2Data) ) ) begin
            $display("ERRORCHECK: Incorrect read data");
            fail = 1;
        end

        cycle_count = cycle_count + 1;
        if (cycle_count > 50) begin
            if (fail)
               $display("TEST FAILED");
            else
               $display("TEST PASSED!  YAHOO!!");
            $finish;
        end
    end

endmodule // tb_rf_hier
