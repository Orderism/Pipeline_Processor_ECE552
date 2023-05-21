/* $Author: karu $ */
/* $LastChangedDate: 2009-03-04 23:09:45 -0600 (Wed, 04 Mar 2009) $ */
/* $Rev: 45 $ */
//`timescale 1ns/1ns
`default_nettype none
module proc_hier();
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire                 clk;                    // From c0 of clkrst.v
   wire                 err;                    // From p0 of proc.v
   wire                 rst;                    // From c0 of clkrst.v
   // End of automatics
   clkrst c0(/*AUTOINST*/
             // Outputs
             .clk                       (clk),
             .rst                       (rst),
             // Inputs
             .err                       (err));
   
   proc p0(/*AUTOINST*/
           // Outputs
           .err                         (err),
           // Inputs
           .clk                         (clk),
           .rst                         (rst));   
   

endmodule
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :0:
