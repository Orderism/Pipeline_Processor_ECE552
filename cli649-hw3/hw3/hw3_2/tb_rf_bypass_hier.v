/*
   CS/ECE 552, Spring '23
   Homework #3, Problem #2
  
   Random testbench for the 8x16b register file.
*/
`default_nettype none
module tb_rf_bypass_hier(/*AUTOARG*/);
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
   integer              n_errors;

   wire                 clk;
   wire                 rst;

   // Instantiate the module we want to verify

   rf_bypass_hier DUT(/*AUTOINST*/
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
      n_errors = 0;
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
      $dumpvars;
      $display("Simulation 1000 cycles");

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

      // Reference model. We compare simulation against this
      // Write data into reference model

      if ((cycle_count >= 2) && writeEn) begin
          ref_rf[ writeRegSel ] = writeData;
      end

      // Read values from reference model
      ref_r1data = ref_rf[ read1RegSel ];
      ref_r2data = ref_rf[ read2RegSel ];

      // Delay for simulation to occur
      #10

      // Print log of what transpired
      $display("Cycle: %4d R1 Sel: 0x%x R1 Data: 0x%x Expected R1 Data: 0x%x R2 Sel: 0x%x R2 Data: 0x%x Expected R2 Data: 0x%x W Sel: 0x%x W Data: 0x%x W Enable: 0x%x",
               cycle_count,
               read1RegSel, read1Data, ref_r1data,
               read2RegSel, read2Data, ref_r2data,
               writeRegSel, writeData, writeEn );
      if ( !rst && ( (ref_r1data !== read1Data)
           ||  (ref_r2data !== read2Data) ) ) begin
         $display("ERRORCHECK: Read data incorrect in cycle %4d", cycle_count);
           n_errors = n_errors + 1;
      end

      if ( !rst && ( (read1RegSel === read2RegSel) ) ) begin
         $display("FYI: Both read ports are same in cycle %4d", cycle_count);
      end

      if ( !rst && ( (read1RegSel === writeRegSel) || (read2RegSel === writeRegSel) ) && (writeEn) ) begin
         $display("FYI: Read/write of same port in cycle %4d", cycle_count);
      end

      cycle_count = cycle_count + 1;
      if (cycle_count > 1000) begin
        if (n_errors > 0)
          $display("\nTEST FAILED WITH %2d ERRORS\n", n_errors);
        else
          $display("\nTEST PASSED!  YAHOO!!\n");
        $finish;
      end

   end

endmodule // tb_rf_bypass_hier
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :4:
