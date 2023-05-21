/* $Author: karu $ */
/* $LastChangedDate: 2009-04-24 09:28:13 -0500 (Fri, 24 Apr 2009) $ */
/* $Rev: 77 $ */

`default_nettype none
module mem_system(/*AUTOARG*/
   // Outputs
   DataOut, Done, Stall, CacheHit, err,
   // Inputs
   Addr, DataIn, Rd, Wr, createdump, clk, rst
   );
   
   input wire [15:0] Addr;
   input wire [15:0] DataIn;
   input wire        Rd;
   input wire        Wr;
   input wire        createdump;
   input wire        clk;
   input wire        rst;
   
   output wire [15:0] DataOut;
   output wire        Done;
   output wire        Stall;
   output wire        CacheHit;
   output wire        err;



//Rain's code here
   wire [15:0]data_out_cache;
   wire hit;
   wire dirty;
   wire valid;
   wire err_cache;
   wire enable;
   wire [2:0]offset_out_cache;
   wire [15:0]data_in_cache;
   wire comp;
   wire wr_cache;
   wire valid_in;
   wire [15:0]data_out_mem;
   wire stall_mem;
   wire [3:0]busy;
   wire err_mem;
   wire [15:0]addr_mem;
   wire rd_mem;
   wire wr_mem;
   wire wr,rd;
   wire [4:0]tag_out;
   wire [2:0] offset_cache;
   wire cache_hit;
   wire stall_out;
   wire done;
   wire err_cache_ctrl;
   wire data_in_cache_sel;
   wire tag_sel;
   wire offset_cache_sel;
   wire [2:0]offset_mem;
   wire victim;

   /* data_mem = 1, inst_mem = 0 *
    * needed for cache parameter */
   parameter memtype = 0;
   cache #(0 + memtype) c0(// Outputs
                          .tag_out              (tag_out),
                          .data_out             (data_out_cache),
                          .hit                  (hit),
                          .dirty                (dirty),
                          .valid                (valid),
                          .err                  (err_cache),
                          // Inputs
                          .enable               (enable),
                          .clk                  (clk),
                          .rst                  (rst),
                          .createdump           (createdump),
                          .tag_in               (Addr[15:11]),
                          .index                (Addr[10:3]),
                          .offset               (offset_out_cache),
                          .data_in              (data_in_cache),
                          .comp                 (comp),
                          .write                (wr_cache),
                          .valid_in             (valid_in));

   four_bank_mem mem(// Outputs
                     .data_out          (data_out_mem),
                     .stall             (stall_mem),
                     .busy              (busy),
                     .err               (err_mem),
                     // Inputs
                     .clk               (clk),
                     .rst               (rst),
                     .createdump        (createdump),
                     .addr              (addr_mem),
                     .data_in           (data_out_cache),
                     .wr                (rd_mem),
                     .rd                (wr_mem));
   
   // your code here









   cache_controller ccc(  
                     .clk(clk),
                     .rst(rst),
                     .wr(wr),//LD----MemRead
                     .rd(rd),//ST, STU----MemWrite    
                     //input from the cache
                     .hit(hit),
                     .dirty(dirty),
                     .valid(valid),// to make sure the data is not from the empty gibbergabber when the CPU start,
                     .tag_out(tag_out),
                     //input from the 4-bank memory
                     .data_out_mem(data_out_mem),
                     .stall_mem(stall_mem),// which means all the 4 banks are in busy, only stall in mem
                     .Busy(busy),// every bit of the 'busy' means that the memory bank is on busy
                     //output to cache
                     .comp(comp),//from tag & index comparator
                     .valid_in(valid_in),
                     .wr_cache(wr_cache),// cache write in control enable
                     .offset_cache(offset_cache),
                     .offset_cache_sel(offset_cache_sel),//--------flag
                     .hit_cache(CacheHit),
                     .stall_outside(stall_out),
                     .done(done),
                     .err(err_cache_ctrl),
                     .enable(enable),
                     .data_in_cache_sel(data_in_cache_sel),//-------flag
                        //output to memory
                     .rd_mem(rd_mem),
                     .wr_mem(wr_mem),
                     .tag_sel(tag_sel),//------------flag
                     .offset_mem(offset_mem),    
                        //victim switch
                     .ff_victim(victim)
   );


   //combinational logic in addr and data_in sel
   //data_in_cache_sel asserted in all WR_C2M state, which means stall the outside and write mem data into cache
   assign data_in_cache = data_in_cache_sel? data_out_mem : DataIn; 

   //offset_cache_sel asserted in all ALLOCATE state, which means:
   //In cache hit: addr come from the outside, it won't trigger any state except the 'IDLE', and 'DONE'
   //In cache miss: ALLOCATE working for mem write into cache, and the addr come from '00' to '11', write 4 times in 4 cycle 
   assign offset_cache= offset_cache_sel? offset_cache : Addr[2:0];

   //tag sel in WR_C2M state, when we need to write mem, the data always from the cache  
   //actual could replace tag_sel with wr_mem

   //assign addr_mem = tag_sel? {tag_out_cache, Addr[10:3], offset_mem} : {Addr[15:3], offset_mem}:// 
   //when there is a cache miss, the cache output the tag for mem_addr
   //when there is a hit, outside logic never connect with the memory without cache
   assign addr_mem = {tag_out, Addr[10:3], offset_mem};

   
   
   
   //variable connection
   assign DataOut=data_out_cache;
   assign Stall=stall_out;
   assign Done=done;
   assign err= err_cache |err_mem | err_cache_ctrl;
   assign Done=done;








   
endmodule // mem_system
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :9:


