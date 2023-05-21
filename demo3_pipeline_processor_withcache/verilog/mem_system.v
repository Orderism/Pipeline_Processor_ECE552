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

//
   //Rain's code here
   wire [15:0] data_out_cache, data_out_cache_0, data_out_cache_1;
   wire hit, hit_cache_0, hit_cache_1;
   wire dirty, dirty_0,dirty_1;
   wire valid, valid_0,valid_1;
   wire err_cache;
   wire enable;
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
   wire [4:0] tag_out, tag_out_0, tag_out_1;
   wire [2:0] offset_cache_in;
   wire [2:0] offset_cache;

   wire done;
   wire err_cache_ctrl;
   wire data_in_cache_sel;
   wire tag_sel;
   wire offset_cache_sel;
   wire [2:0]offset_mem;
   wire err_cache_0, err_cache_1;




   
   


   //Victimway, Victimway flip logic
   wire V_in;
   wire V_out;
   wire ff_victim;// invert the state of victim way in each read/ WRITE
   assign V_in=ff_victim ^ V_out;
   //assign V_in= (ff_victim)? ~V_out: V_out;//the victim in nxt cycle
   dff V_in_out(.d(V_in), .q(V_out), .clk(clk), .rst(rst));


   //cache data sel logic
   wire cache_sel;
   assign cache_sel= ((hit_cache_0 & valid_0) | (~valid_0 & valid_1) | (~valid_0 & ~valid_1))? 0:
                     ((hit_cache_1 & valid_1) | (~valid_1 & valid_0))? 1:
                     V_in;


   //cache_en_sel is different with the cache_sel, as the enable control and based on victim(from out side logic)
   //cache_sel is based on the hit or not(from inside logic)
   wire cache_en_sel;
   wire cache_en_sel_nxt;
   //assign cache_en_sel_nxt=cache_sel; //maintain the sel for 1 turn (keep unchanged until one mission done), discard
   assign cache_en_sel_nxt= ff_victim? cache_sel: cache_en_sel;//hold the cache Order in the state except comp// only in TAG_COMP there will be inverted the victim
   dff cache_en_sel1(.d(cache_en_sel_nxt), .q(cache_en_sel), .clk(clk), .rst(rst));


   //cache enable logic
   wire enable_0, enable_1;// input of enable signal of the cache is come from the cache select.
   assign enable_0=(enable)? 1:(~cache_en_sel);
   assign enable_1=(enable)? 1:(cache_en_sel); 

   //cache relative logic
   assign data_out_cache= cache_en_sel? data_out_cache_1: data_out_cache_0;//DataOut=data_out_cache
   assign tag_out=cache_en_sel? tag_out_1:tag_out_0;
   assign err_cache= cache_en_sel? err_cache_1: err_cache_0;

   //3 global data signal
   assign hit=cache_sel? hit_cache_1: hit_cache_0;//hit_cache
   assign dirty=cache_sel? dirty_1: dirty_0;
   assign valid=cache_sel? valid_1: valid_0;

   //combinational logic in addr and data_in sel
   //data_in_cache_sel asserted in all WR_C2M state, which means stall the outside and write mem data into cache
   assign data_in_cache = data_in_cache_sel? data_out_mem : DataIn; 

   //offset_cache_sel asserted in all ALLOCATE state, which means:
   //In cache hit: addr come from the outside, it won't trigger any state except the 'IDLE', and 'DONE'
   //In cache miss: ALLOCATE working for mem write into cache, and the addr come from '00' to '11', write 4 times in 4 cycle 
   assign offset_cache_in= offset_cache_sel? offset_cache : Addr[2:0];

   //tag sel in WR_C2M state, when we need to write mem, the data always from the cache  
   //actual could replace tag_sel with wr_mem

   //assign addr_mem = tag_sel? {tag_out, Addr[10:3], offset_mem} : {Addr[15:3], offset_mem}:// 
   //when there is a cache miss, the cache output the tag for mem_addr
   //when there is a hit, outside logic never connect with the memory without cache
   //assign addr_mem = {tag_out, Addr[10:3], offset_mem};  
   assign addr_mem =tag_sel? {tag_out, Addr[10:3], offset_mem} : {Addr[15:3], offset_mem};



   assign err=err_cache | err_cache_ctrl | err_mem;
   assign Done=done;
   assign DataOut=data_out_cache;














// 2 cache share the control signal, but not the input/output value/status
   /* data_mem = 1, inst_mem = 0 *
    * needed for cache parameter */
   parameter memtype = 0;
   cache #(0 + memtype) c0(// Outputs
                          .tag_out              (tag_out_0),
                          .data_out             (data_out_cache_0),
                          .hit                  (hit_cache_0),
                          .dirty                (dirty_0),
                          .valid                (valid_0),
                          .err                  (err_cache_0),
                          // Inputs
                          .enable               (enable_0),
                          .clk                  (clk),
                          .rst                  (rst),
                          .createdump           (createdump),
                          .tag_in               (Addr[15:11]),
                          .index                (Addr[10:3]),
                          .offset               (offset_cache_in),//share the same offset, but one of the output should be locked by the cache_sel
                          .data_in              (data_in_cache),// both of the 2 cache data_in is come from the data_out_mem or data from out side
                          .comp                 (comp),//one of them is comparing means 'it's cache time!'
                          .write                (wr_cache),//cache write signal will be same?????
                          .valid_in             (valid_in));
   cache #(2 + memtype) c1(// Outputs
                          .tag_out              (tag_out_1),
                          .data_out             (data_out_cache_1),
                          .hit                  (hit_cache_1),
                          .dirty                (dirty_1),
                          .valid                (valid_1),
                          .err                  (err_cache_1),
                          // Inputs
                          .enable               (enable_1),
                          .clk                  (clk),
                          .rst                  (rst),
                          .createdump           (createdump),
                          .tag_in               (Addr[15:11]),
                          .index                (Addr[10:3]),
                          .offset               (offset_cache_in),
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
                     .wr                (wr_mem),
                     .rd                (rd_mem));
   
   // your code here

   cache_controller ccc(  
                     .clk(clk),
                     .rst(rst),
                     .wr(Wr),//LD----MemRead
                     .rd(Rd),//ST, STU----MemWrite    
                     //input from the cache
                     .hit(hit),
                     .dirty(dirty),
                     .valid(valid),// to make sure the data is not from the empty gibbergabber when the CPU start,
                     .tag_out(tag_out),
                     //input from the 4-bank memory
                     .index_out(Addr[7:0]),
                     .data_out_mem(data_out_mem),
                     .stall_mem(stall_mem),// which means all the 4 banks are in busy, only stall in mem
                     //output to cache
                     .comp(comp),//from tag & index comparator
                     .valid_in(valid_in),
                     .wr_cache(wr_cache),// cache write in control enable
                     .offset_cache(offset_cache),
                     .offset_cache_sel(offset_cache_sel),//--------flag
                     .hit_cache(CacheHit),
                     .stall_outside(Stall),
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
                     .ff_victim(ff_victim),
                     .cache_offset_in(Addr[2:0])
   );






   
endmodule // mem_system
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :9:
