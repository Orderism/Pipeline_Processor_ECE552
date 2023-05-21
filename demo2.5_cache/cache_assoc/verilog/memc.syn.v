/* $Author: karu $ */
/* $LastChangedDate: 2009-03-04 23:09:45 -0600 (Wed, 04 Mar 2009) $ */
/* $Rev: 45 $ */
// Synthesizable memory
// Memories used by the cache:

`default_nettype none
module memc (data_out, addr, data_in, write, clk, rst, createdump, file_id);
   parameter Size = 1;
   output wire [Size-1:0] data_out;
   input wire [7:0]       addr;
   input wire [Size-1:0]  data_in;
   input wire             write;
   input wire             clk;
   input wire             rst;
   input wire             createdump;
   input wire [4:0]       file_id;

   reg [Size-1:0]    mem [0:31];

   integer           mcd;
   integer           i;

   assign            data_out = (write | rst)? 0 : mem[addr];

   always @(posedge clk) begin

      if (rst) begin
         /*
         for (i=0; i<256; i=i+1) begin
            mem[i] = 0;
         end
          */
      end

      if (!rst && write) mem[addr] = data_in;
      /*
      if (!rst && createdump) begin
         case (file_id)
           0: mcd = $fopen("Icache_0_data_0");
           1: mcd = $fopen("Icache_0_data_1");
           2: mcd = $fopen("Icache_0_data_2");
           3: mcd = $fopen("Icache_0_data_3");
           4: mcd = $fopen("Icache_0_tags");
           5: mcd = $fopen("Icache_0_dirty");
           
           8: mcd = $fopen("Dcache_0_data_0");
           9: mcd = $fopen("Dcache_0_data_1");
           10: mcd = $fopen("Dcache_0_data_2");
           11: mcd = $fopen("Dcache_0_data_3");
           12: mcd = $fopen("Dcache_0_tags");
           13: mcd = $fopen("Dcache_0_dirty");
           
           16: mcd = $fopen("Icache_1_data_0");
           17: mcd = $fopen("Icache_1_data_1");
           18: mcd = $fopen("Icache_1_data_2");
           19: mcd = $fopen("Icache_1_data_3");
           20: mcd = $fopen("Icache_1_tags");
           21: mcd = $fopen("Icache_1_dirty");
           
           24: mcd = $fopen("Dcache_1_data_0");
           25: mcd = $fopen("Dcache_1_data_1");
           26: mcd = $fopen("Dcache_1_data_2");
           27: mcd = $fopen("Dcache_1_data_3");
           28: mcd = $fopen("Dcache_1_tags");
           29: mcd = $fopen("Dcache_1_dirty");
           default: $display("Unknown file_id %d", file_id);
         endcase
         for (i=0; i<256; i=i+1) begin
            $fdisplay(mcd,"%2h %4h", i, mem[i]);
         end
         $fclose(mcd);
      end
       */
   end
endmodule
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :0:
