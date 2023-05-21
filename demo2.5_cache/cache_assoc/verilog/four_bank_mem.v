/* $Author: karu $ */
/* $LastChangedDate: 2009-03-04 23:09:45 -0600 (Wed, 04 Mar 2009) $ */
/* $Rev: 45 $ */
////////////////////////////////////////////////
//
// four_bank_mem -- four banks of the
// 4-cycle "final_memory" for use in the
// most advanced stage of the project
//
// written for CS/ECE 552, Spring '06
// Andy Phelps, 6 Mar 2006
//
// Modified 30 Oct 2006 by Derek Hower
//   - memory was made byte-addressable, word aligned
//   - added busy output for DRAM controller
//   - set err to high on unaligned access
// 
// Modified by Karu 05/03
// Added & (rd |wr ) to err
//
// Modified by Matt Sinclair 3/5/22
// Added default_nettype and appropriate missing wire/reg declarations
//
// This is a word-addressable,
// 16-bit wide, 64K-word memory.
//
//    |            |            |            |            |            |
//    | addr       | addr etc   | read data  |            | new addr   |
//    | data_in    | OK to any  | available  |            | etc. is    |
//    | wr, rd     |*diffferent*|            |            | OK to      |
//    | enable     | bank       |            |            | *same*     |
//    |            |            |            |            | bank       |
//                  <----bank busy; any new request to--->
//                       the *same* bank will stall
//
// Requests may be presented every cycle.
// They will be directed to one of the four banks depending
// on the least significant 2 bits of the address.
//
// Two requests to the same bank which are closer than cycles N and N+4
// will result in the second request not happening, and a "stall" output
// being generated.
//
// Busy output reflects the current status of each individual bank.
//
// Concurrent read and write not allowed.
//
// On reset, memory loads from file "loadfile_0.img",
// "loadfile_1.img", "loadfile_2.img", and "loadfile_3.img".
// Each file supplies every fourth word.
// (The latest version of the assembler generates
// these four files.)
//
// Format of each file:
//     @0
//     <hex data 0>
//     <hex data 1>
//     ...etc
//
// If input "create_dump" is true on rising clock,
// contents of memory will be dumped to
// file "dumpfile_0", "dumpfile_1", etc.
// Each file will be a dump from location 0 up through
// the highest location modified by a write in that bank.
//
//////////////////////////////////////

`default_nettype none
module four_bank_mem (
    input wire         clk,
    input wire         rst,
    input wire         createdump,
    input wire  [15:0] addr,
    input wire  [15:0] data_in,
    input wire         wr,
    input wire         rd,               
    output wire [15:0] data_out,
    output wire        stall,
    output wire [3:0]  busy,
    output wire        err
);

   wire [15:0]         data0_out, data1_out, data2_out, data3_out;
   wire                err0, err1, err2, err3;
   wire                sel0, sel1, sel2, sel3;

   assign sel0 = (addr[2:1] == 2'd0);
   assign sel1 = (addr[2:1] == 2'd1);
   assign sel2 = (addr[2:1] == 2'd2);
   assign sel3 = (addr[2:1] == 2'd3);

   wire [3:0]          en;
   assign en[0] = sel0 & ~busy[0] & (wr | rd);
   assign en[1] = sel1 & ~busy[1] & (wr | rd);
   assign en[2] = sel2 & ~busy[2] & (wr | rd);
   assign en[3] = sel3 & ~busy[3] & (wr | rd);

   assign stall = (wr | rd) & ~rst & ( (sel0 & busy[0])
                                       |(sel1 & busy[1])
                                       |(sel2 & busy[2])
                                       |(sel3 & busy[3]) );
   
   
   final_memory m0 (data0_out, err0, data_in, addr[15:3], wr, rd, en[0],
                    createdump, 2'd0, clk, rst);
   final_memory m1 (data1_out, err1, data_in, addr[15:3], wr, rd, en[1],
                    createdump, 2'd1, clk, rst);
   final_memory m2 (data2_out, err2, data_in, addr[15:3], wr, rd, en[2],
                    createdump, 2'd2, clk, rst);
   final_memory m3 (data3_out, err3, data_in, addr[15:3], wr, rd, en[3],
                    createdump, 2'd3, clk, rst);

   assign data_out = data0_out | data1_out | data2_out | data3_out;

   assign err = (wr | rd) & (err0 | err1 | err2 | err3 | addr[0]==1); //word aligned; odd addresses are illegal

   wire [3:0]          bsy0, bsy1, bsy2;
   dff b0 [3:0] (bsy0, en,    clk, rst);
   dff b1 [3:0] (bsy1, bsy0, clk, rst);
   dff b2 [3:0] (bsy2, bsy1, clk, rst);

   assign busy = bsy0 | bsy1 | bsy2;

endmodule
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :0:
