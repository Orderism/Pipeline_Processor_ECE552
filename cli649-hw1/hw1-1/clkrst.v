/* $Author: karu $ */
/* $LastChangedDate: 2009-03-04 23:09:45 -0600 (Wed, 04 Mar 2009) $ */
/* $Rev: 45 $ */
// clock and reset generator
// CS/ECE 552
// Andy Phelps (TA)
// 3/22/06

// Clock period is 100 time units, and reset length
// to 201 time units (two rising edges of clock).

`default_nettype none
module clkrst (clk, rst, err);

    output clk;
    output rst;
    input wire err;

    reg clk;
    reg rst;
    integer cycle_count;

    initial begin
      $dumpvars;
      cycle_count = 0;
      rst = 1;
      clk = 1;
      #201 rst = 0; // delay until slightly after two clock periods
    end

    always #50 begin   // delay 1/2 clock period each time thru loop
      clk = ~clk;
      if (clk & err) begin
        $display("Error signal asserted");
        $stop;
      end
    end
    always @(posedge clk) begin
       cycle_count = cycle_count + 1;
       /*
        MDS (3/25/19): change from 100000 cycles to 100004 cycles to
        allow tests that intentionally loop infinitely to pass in wiscalculator;
        without this change, such benchmarks will erroneously fail due to
        reset cycles at the beginning.
        */
       if (cycle_count > 100004) begin
          $display("hmm....more than 100004 cycles of simulation...error?\n");
          $finish;
       end
    end

endmodule
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :0:
