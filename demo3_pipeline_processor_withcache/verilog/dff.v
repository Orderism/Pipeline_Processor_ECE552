/* $Author: karu $ */
/* $LastChangedDate: 2009-03-04 23:09:45 -0600 (Wed, 04 Mar 2009) $ */
/* $Rev: 45 $ */
// D-flipflop
`default_nettype none
module dff (q, d, clk, rst);

    output wire        q;
    input wire         d;
    input wire         clk;
    input wire         rst;

    reg            state;

    assign #(1) q = state;

    always @(posedge clk) begin
      state = rst? 0 : d;
    end
endmodule
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :0:
