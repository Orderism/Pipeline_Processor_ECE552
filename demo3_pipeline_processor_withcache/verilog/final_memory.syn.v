/* $Author: karu $ */
/* $LastChangedDate: 2009-03-04 23:09:45 -0600 (Wed, 04 Mar 2009) $ */
/* $Rev: 45 $ */
// Synthesizable memory
////////////////////////////////////////////////
//
// final_memory -- four cycle version of memory
// for use in the four-banked memory
//
// written for CS/ECE 552, Spring '06
// Andy Phelps, 1 May 2006
//
// modified 30 Oct 2006 by Derek Hower
//    - byte-addressable, word aligned
// modified 23 Apr 2008 by karu
//    - addr_1c must be 14 bits wide
// This is a word-addressable,
// 16-bit wide, 16K-byte memory.
//
//    |            |            |            |            |            |
//    | addr       | busy       | read data  |            | new addr   |
//    | data_in    |            |            |            | etc.       |
//    | wr, rd     |            |            |            |            |
//    | enable     |            |            |            |            |
//    |            |            |            |            |            |
//                  <----bank busy; do not try new req--->
//
// Requests may be presented at most every 4th cycle;
// a new request before this time will result in an error.
// Read requests presented in cycle N will deliver data in cycle N+2.
// Concurrent read and write not allowed.
//
// On reset, memory loads from file "loadfile_0.img",
// "loadfile_1.img", "loadfile_2.img", or "loadfile_3.img", depending
// on the "bank_id" input.
//
// File format:
//     @0
//     <hex data 0>
//     <hex data 1>
//     ...etc
//
// If input "create_dump" is true on rising clock,
// contents of memory will be dumped to
// file "dumpfile_0", "dumpfile_1", etc, depending on
// "bank_id".  It will dump from location 0 up through
// the highest location modified by a write.
//
// File names for loading and dumping is the only purpose of
// the "bank_id" input.  (You may change the name of the file
// in the $readmemh statement below.)
//
//////////////////////////////////////

`default_nettype none
module final_memory (
    output wire [15:0] data_out,
    output wire        err,
    input wire  [15:0] data_in,
    input wire  [12:0] addr,
    input wire         wr,
    input wire         rd,
    input wire         enable,
    input wire         create_dump,
    input wire   [1:0] bank_id,
    input wire         clk,
    input wire         rst
);

    reg     [7:0]  mem [0:32];
    reg            loaded;
    reg     [15:0] largest;

    wire [13:0] addr_1c;
    wire [15:0] data_in_1c;
    wire        rd0, rd1, rd2, rd3;
    wire        wr0, wr1, wr2, wr3;
    wire        busy;
 
    integer        mcd;
    integer        largeout;
    integer        i;

    assign rd0 = rd & ~wr & enable & ~rst;
    assign wr0 = ~rd & wr & enable & ~rst;

//   clkrst clkmod(clk, rst, err);
   
   
    dff ff0 (rd1, rd0, clk, rst);
    dff ff1 (wr1, wr0, clk, rst);
    dff reg0 [12:0] (addr_1c[12:0], addr, clk, rst);
    dff reg1 [15:0] (data_in_1c, data_in, clk, rst);
    assign addr_1c[13]=1'b0;

    wire [15:0] data_out_1c = rd1 ? {mem[addr_1c<<1], mem[(addr_1c<<1)+1]} : 0;

    dff reg2 [15:0] (data_out, data_out_1c, clk, rst);

    dff ff2 (rd2, rd1, clk, rst);
    dff ff3 (wr2, wr1, clk, rst);
    dff ff4 (rd3, rd2, clk, rst);
    dff ff5 (wr3, wr2, clk, rst);

    assign busy = rd1 | rd2 | rd3 | wr1 | wr2 | wr3;
    assign err = ((rd0 | wr0) & busy)
               | (rd & wr & enable & ~rst);

    initial begin
      loaded = 0;
      largest = 1;
    end

    always @(posedge clk) begin
      if (rst) begin
        /* 
        if (!loaded) begin
           for (i = 0; i  <= 16384; i=i+1) begin
              mem[i] = 0;
           end
          case (bank_id)
            0: $readmemh("loadfile_0.img", mem);
            1: $readmemh("loadfile_1.img", mem);
            2: $readmemh("loadfile_2.img", mem);
            3: $readmemh("loadfile_3.img", mem);
          endcase
          loaded = 1;
        end
        */
      end
      else begin
        if (wr1) begin
          mem[addr_1c<<1] = data_in_1c[15:8];       // The actual write
          mem[(addr_1c<<1)+1] = data_in_1c[7:0];
          //if ({1'b0, (addr_1c<<1)+1} > largest) largest = (addr_1c<<1)+1;  
           // avoid negative numbers
        end
        /*
        if (create_dump) begin
          case (bank_id)
            0: mcd = $fopen("dumpfile_0", "w");
            1: mcd = $fopen("dumpfile_1", "w");
            2: mcd = $fopen("dumpfile_2", "w");
            3: mcd = $fopen("dumpfile_3", "w");
          endcase
          for (i=0; i<=largest; i=i+1) begin
            $fdisplay(mcd,"%4h %2h", i, mem[i]);
          end
          largeout = $fopen("largest");
          $fdisplay(largeout,"%4h",largest);
          $fclose(largeout);
          $fclose(mcd);
        end
        */
      end
    end


endmodule  // final_memory
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :0:
