/* $Author: karu $ */
/* $LastChangedDate: 2009-03-04 23:09:45 -0600 (Wed, 04 Mar 2009) $ */
/* $Rev: 45 $ */
/* Revised 04/22 2:22pm */
/* Modified by KARL JOHN WALLINGER and SAMUEL LAWRENCE WASMUNDT 04/19/2011 */
/* To make similar to cache interface */
//////////////////////////////////////
//
// Memory -- stalling single cycle version
//
// written for CS/ECE 552, Spring '06
// Andy Phelps, 25 Jan 2006
//
// Added reading seed from command line args
// all mem is intialized to zero first
// 
// This is a byte-addressable,
// 16-bit wide, 64K-byte memory that allows aligned accesses only.
//
// This module produces a "ready" signal;
// if "ready" is not asserted, the read
// or write did not take place.
//
// Reads happen combinationally with zero delay in cycles that ready is high.
// Writes occur on rising clock edge in cycles that ready is high.
// Concurrent read and write not allowed.
//
// On reset, memory loads from file "loadfile_all.img".
// (You may change the name of the file in
// the $readmemh statement below.)
// File format:
//     @0
//     <hex data 0>
//     <hex data 1>
//     ...etc
//
// If input "createdump" is true on rising clock,
// contents of memory will be dumped to
// file "dumpfile", from location 0 up through
// the highest location modified by a write.
//
//
//////////////////////////////////////

`default_nettype none
module stallmem (DataOut, Done, Stall, CacheHit, err, Addr, DataIn, Rd, Wr, createdump, clk, rst);

   output wire [15:0] DataOut;
   output wire        Done;
   output wire        Stall;
   output wire        CacheHit;
   input wire [15:0]  DataIn;
   input wire [15:0]  Addr;
   input wire         Wr;
   input wire         Rd;
   input wire         createdump;
   input wire         clk;
   input wire         rst;
   output wire        err;

   reg [7:0]      mem [0:65535];
   reg            loaded;
   reg [16:0]     largest;
   reg [31:0]     rand_pat;

   wire           ready;

   integer        mcd;
   integer        i;

   assign         ready = (Wr|Rd) & rand_pat[0];
   assign         Stall = (Wr|Rd) & ~rand_pat[0];
   assign         err = ready & Addr[0]; //word aligned; odd address is invalid
   assign         Done = ready;
   assign         DataOut = err ? 
                            ((ready & (~Wr))? {mem[Addr-8'h1],mem[Addr]}: 0) :
                            ((ready & (~Wr))? {mem[Addr],mem[Addr+8'h1]}: 0);
   assign         CacheHit = 1'b0;

   integer        seed;
   
   initial begin
      loaded = 0;
      largest = 0;
//      rand_pat = 32'b01010010011000101001111000001010;
      seed = 0;
      $value$plusargs("seed=%d", seed);
      $display("Using seed %d", seed);
      rand_pat = $random(seed);
      $display("rand_pat=%08x %32b", rand_pat, rand_pat);
      // initialize memories to 0 first
      for (i=0; i<=65535; i=i+1) begin
         mem[i] = 8'd0;
      end 
         
   end

   always @(posedge clk) begin
      if (rst) begin
         if (!loaded) begin
            $readmemh("loadfile_all.img", mem);
            loaded = 1;
         end
      end
      else begin
         if (ready & Wr & ~err) begin
            mem[Addr] = DataIn[15:8];       // The actual write
            mem[Addr+1] = DataIn[7:0];      // The actual write part 2
            if ({1'b0, Addr} > largest) largest = Addr;  // avoid negative numbers
         end
         if (createdump) begin
            mcd = $fopen("dumpfile");
            for (i=0; i<=largest; i=i+1) begin
               $fdisplay(mcd,"%4h %4h", i, mem[i]);
            end
            $fclose(mcd);
         end
         rand_pat = (rand_pat >> 1) | (rand_pat[0] << 31);
      end
   end


endmodule
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :0:
