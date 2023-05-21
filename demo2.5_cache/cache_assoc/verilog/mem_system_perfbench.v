/* $Author: karu $ */
/* $LastChangedDate: 2009-04-24 09:28:13 -0500 (Fri, 24 Apr 2009) $ */
/* $Rev: 77 $ */

// Name of the file with the address trace

`default_nettype none
module mem_system_perfbench(/*AUTOARG*/);
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [15:0]          DataOut;                // From DUT of mem_system_hier.v
   wire                 Done;                   // From DUT of mem_system_hier.v
   wire                 Stall;                  // From DUT of mem_system_hier.v
   // End of automatics
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   reg [15:0]           Addr;                   // To DUT of mem_system_hier.v
   reg [15:0]           DataIn;                 // To DUT of mem_system_hier.v
   reg                  Rd;                     // To DUT of mem_system_hier.v
   reg                  Wr;                     // To DUT of mem_system_hier.v
   // End of automatics
   
   reg [256*8:1]        addr_trace_file_name;
   
   wire                 clk;
   wire                 rst;
   wire                 CacheHit;

   // Pull out clk and rst from clkgenerator module
   assign               clk = DUT.clkgen.clk;
   assign               rst = DUT.clkgen.rst;

   // Instantiate the module we want to verify   

   mem_system_hier DUT(/*AUTOINST*/
                       // Outputs
                       .DataOut         (DataOut[15:0]),
                       .Done            (Done),
                       .Stall           (Stall),
                       .CacheHit        (CacheHit),
                       // Inputs
                       .Addr            (Addr[15:0]),
                       .DataIn          (DataIn[15:0]),
                       .Rd              (Rd),
                       .Wr              (Wr),
                       .createdump      (1'b0));

   wire [15:0]          DataOut_ref;
   wire                 Done_ref;
   wire                 Stall_ref;
   wire                 CacheHit_ref;
   
   mem_system_ref ref(
                      // Outputs
                      .DataOut          (DataOut_ref[15:0]),
                      .Done             (Done_ref),
                      .Stall            (Stall_ref),
                      .CacheHit         (CacheHit_ref),
                      // Inputs
                      .Addr             (Addr[15:0]),
                      .DataIn           (DataIn[15:0]),
                      .Rd               (Rd),
                      .Wr               (Wr),
                      .clk( DUT.clkgen.clk),
                      .rst( DUT.clkgen.rst) );
   
   reg                  reg_readorwrite;
   integer              n_requests;
   integer              n_replies;
   integer              n_cache_hits;
   reg                  test_success;
   integer              req_cycle;
   
   // variables for reading address trace
   integer              fd;
   integer              rval;
   
   initial begin
      Rd = 1'b0;
      Wr = 1'b0;
      Addr = 16'd0;
      DataIn = 16'd0;
      reg_readorwrite = 1'b0;
      n_requests = 0;
      n_replies = 0;
      n_cache_hits = 0;
      test_success = 1'b1;
      req_cycle = 0;
      
      if (!$value$plusargs("addr_trace_file_name=%s", addr_trace_file_name) ) begin
         $display("ERROR: FAIL no input file specified. Cannot proceed. Specify input using the -addr flag to wsrun.pl");
         $stop;
      end
      $display("Using trace file %s", addr_trace_file_name );
      fd = $fopen(addr_trace_file_name, "r");
   end
   
   


   
   
   always @ (posedge clk) begin

      #2;
      // simulation delay
      
      if (Done) begin
         n_replies = n_replies + 1;
         if (CacheHit) begin
            n_cache_hits = n_cache_hits + 1;
         end
         if (Rd) begin
            $display("LOG: ReqNum %4d Cycle %8d ReqCycle %8d Rd Addr 0x%04x Value 0x%04x ValueRef 0x%04x HIT %1d\n",
                     n_replies, DUT.clkgen.cycle_count, req_cycle, Addr, DataOut, DataOut_ref, CacheHit);
         end
         if (Wr) begin
            $display("LOG: ReQNum %4d Cycle %8d ReqCycle %8d Wr Addr 0x%04x Value 0x%04x ValueRef 0x%04x HIT %1d\n",
                     n_replies, DUT.clkgen.cycle_count, req_cycle, Addr, DataIn, DataIn, CacheHit);
         end
         if (Rd | Wr) begin
            if (CacheHit) begin
               if ((DUT.clkgen.cycle_count - req_cycle) > 2) begin
                  $display("LOG: WARNING: PERFORMANCE ERROR? CacheHit Latency (%3d) greater than 2 cycles?", DUT.clkgen.cycle_count - req_cycle );
                  test_success = 1'b0;
               end
            end else begin
               if ( ((DUT.clkgen.cycle_count - req_cycle) > 20) ||  ((DUT.clkgen.cycle_count - req_cycle) <= 2) ) begin
                  $display("LOG: WARNING: PERFORMANCE ERROR? CacheMiss Latency (%3d) greater than 20 or less than 2 cycles?", DUT.clkgen.cycle_count - req_cycle);
                  test_success = 1'b0;
               end
            end
            
         end
         
         if (Rd) begin
            if (DataOut != DataOut_ref) begin
               $display("ERROR Ref: 0x%04x DUT: 0x%04x", DataOut_ref, DataOut);
               test_success = 1'b0;
            end
         end

         Rd = 1'd0;
         Wr = 1'd0;
      end // if (Done_ref)

      #85;
      // transition inputs just before rising edge
      read_line;

   end

   task read_line;
      reg [1023:0] line;
      integer      rval;
      
      begin
         if (!rst && (!Stall)) begin
            if (n_replies != n_requests) begin
               if (Rd) begin
                  $display("LOG: ReqNum %4d Cycle %8d ReqCycle %8d Rd Addr 0x%04x RefValue 0x%04x\n",
                           n_replies, DUT.clkgen.cycle_count, req_cycle, Addr, DataOut_ref);
               end
               if (Wr) begin
                  $display("LOG: ReQNum %4d Cycle %8d ReqCycle %8d Wr Addr 0x%04x Value 0x%04x\n",
                           n_replies, DUT.clkgen.cycle_count, req_cycle, Addr, DataIn);
               end
               $display("ERROR! Request dropped");
               test_success = 1'b0;               
               n_replies = n_requests;         
            end            
            rval = $fscanf(fd, "%d %d %d %d", 
                           Wr, Rd, Addr, DataIn);
            if (rval == 0) begin
               rval = $fgets(line, fd);
               $display("Line interpretted as comment: %s", line);
            end

            if (rval <= 0) begin
               end_simulation;
            end
            if (Wr | Rd) begin
               req_cycle = DUT.clkgen.cycle_count;
               n_requests = n_requests + 1;
            end
         end // if (!rst && (!Stall))
      end         
   endtask 

   task end_simulation;
      begin
         $display("LOG: Done all Requests: %10d Replies: %10d Cycles: %10d Hits: %10d",
                  n_requests,
                  n_replies,
                  DUT.clkgen.cycle_count,
                  n_cache_hits );
         if (!test_success)  begin
            $display("Test status: FAIL");
         end else begin
            $display("Test status: SUCCESS");
         end
         $stop;
      end
   endtask // end_simulation
   
   
endmodule // mem_system_bench
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :9:
