module cache_controller(
    input wire clk,
    input wire rst,
    //input from the orginal data and addr
    //input wire [4:0] tag_in,
    //input wire [7:0] index,
    //input wire [2:0] offset,
    //input wire [15:0] data_in_cache,//named 'cache ' because the input is to the cache
    input wire wr,//LD----MemRead
    input wire rd,//ST, STU----MemWrite    
    input wire [2:0]cache_offset_in,
    //input from the cache
    input reg hit,
    input wire dirty,
    input wire valid,// to make sure the data is not from the empty gibbergabber when the CPU start,
    input wire [4:0]tag_out,
    //input from the 4-bank memory
    input wire [15:0]data_out_mem,
    input wire stall_mem,// which means all the 4 banks are in busy, only stall in mem
    //output to cache
    output reg comp,//from tag & index comparator
    output reg valid_in,
    output reg wr_cache,// cache write in control enable
    output reg [2:0] offset_cache,
    output reg offset_cache_sel,//--------flag
    output wire hit_cache,
    output reg stall_outside,
    output reg done,
    output reg err,
    output reg data_in_cache_sel,//-------flag
    output reg enable,
    //output to memory
    output reg rd_mem,
    output reg wr_mem,
    output reg tag_sel,//------------flag
    output reg [2:0] offset_mem,    
    //victim switch
    output reg ff_victim

);



/*Signal	In/Out	Width	Description
enable	    In	    1	    Enable cache. Active high. If low, "write" and "comp" have no effect, and all outputs are zero.
index	    In	    8	    The address bits used to index into the cache memory.
offset	    In	    3	    offset[2:1] selects which word to access in the cache line. The least significant bit should be 0 for word alignment. If the least significant bit is 1, it is an error condition.
comp	    In	    1	    Compare. When "comp"=1, the cache will compare tag_in to the tag of the selected line and indicate if a hit has occurred; the data portion of the cache is read or written but writes are suppressed if there is a miss. When "comp"=0, no compare is done and the Tag and Data portions of the cache will both be read or written.
write	    In	    1	    Write signal. If high at the rising edge of the clock, a write is performed to the data selected by "index" and "offset", and (if "comp"=0) to the tag selected by "index".
tag_in	    In	    5	    When "comp"=1, this field is compared against stored tags to see if a hit occurred; when "comp"=0 and "write"=1 this field is written into the tag portion of the array.
data_in	    In	    16	    On a write, the data that is to be written to the location specified by the "index" and "offset" inputs.
valid_in	In	    1	    On a write when "comp"=0, the data that is to be written to valid bit at the location specified by the "index" input.
clk	        In	    1	    Clock signal; rising edge active.
rst	        In	    1	    Reset signal. When "rst"=1 on the rising edge of the clock, all lines are marked invalid. (The rest of the cache state is not initialized and may contain X's.)
createdump	In	    1	    Write contents of entire cache to memory file. Active on rising edge.
hit	        Out	    1	    Goes high during a compare if the tag at the location specified by the "index" lines matches the "tag_in" lines.
dirty	    Out	    1	    When this bit is read, it indicates whether this cache line has been written to. It is valid on a read cycle, and also on a compare-write cycle when hit is false. On a write with "comp"=1, the cache sets the dirty bit to 1. On a write with "comp"=0, the dirty bit is reset to 0.
tag_out 	Out	    5	    When "write"=0, the tag selected by "index" appears on this output. (This value is needed during a writeback.)
data_out	Out	    16	    When "write"=0, the data selected by "index" and "offset" appears on this output.
valid	    Out	    1	    During a read, this output indicates the state of the valid bit in the selected cache line.
*/



//State parameter define
parameter IDLE=4'd0;// IDLE state
parameter TAG_COMP=4'd1;// For the tag compare Rd
parameter WRITE_C2M_0=4'd2;
parameter WRITE_C2M_1=4'd3;
parameter WRITE_C2M_2=4'd4;
parameter WRITE_C2M_3=4'd5;
parameter ALLOCATE_0=4'd6;
parameter ALLOCATE_1=4'd7;
parameter ALLOCATE_2=4'd8;
parameter ALLOCATE_3=4'd9;
parameter ALLOCATE_4=4'd10;
parameter ALLOCATE_5=4'd11;
parameter ALLOCATE_6=4'd12;
parameter ERR=4'd13;
parameter DONE=4'd14;




reg [3:0] cur_state, nxt_state;

//FSM
always @(posedge clk or negedge rst) begin
    if(rst) cur_state<=0;
    else cur_state<=nxt_state;
    end
//cache hit
//if hit in cache, when it done, the hit
//and the path to done is IDLE-->DONE,1 cycle
dff cache_hit_a(.d(hit), .q(hit_cache), .clk(clk), .rst(rst));




always @(*) begin
    //initializing 
    nxt_state=cur_state;
    //cache operation
    wr_cache=0;
    offset_cache=3'd0;
    offset_cache_sel=0;
    data_in_cache_sel=0;
    //mem operation
    rd_mem=0;
    wr_mem=0;
    offset_mem=3'd0;
    stall_outside=1;//asserted when mem has been done, when it got 0, it will stall the outside logic(out of cache)
    //global
    enable=0;//enable=1 when we need to start the cache, we always start the cache in TAG_COMP and IDLE
    comp=0;//comp start with disassered
    tag_sel=0;//tag
    err=0;
    valid_in= 1'b0;
    done=0;
    


    case(cur_state)
    //IDLE do nothing and waiting for the cache trigger
    IDLE: begin
        enable=1;
        stall_outside=(rd|wr);//once there is an operation in cache, stall outside
        nxt_state=(rd & wr)? ERR:
                  (rd ^ wr)? TAG_COMP: 
                  IDLE;    
    end


    TAG_COMP: begin //hit , rd/wr and dirty?
        enable=1;
        comp=1;//set comp=1 as 'cache control working' flag 
    //TAG_COMP
    //for this state, need 1 cycle to get the output from cache:
        wr_cache=~rd & (wr);
        nxt_state=(hit & valid)? DONE://the simplest path is the HIT-DONE loop
        //the only difference is dirty or not when not hit or not valid
                  (~(hit & valid) & ~dirty)? ALLOCATE_0://start cache operation
                  (~(hit & valid) & dirty)? WRITE_C2M_0://start mem operation
                  ERR;
    end


    //WRITE_C2M:
    //for this state, wrt the dirty data to mem, 4 times, we need to:
    //#1 wait the mem rd/wr process, and stall until there is no busy
    //#2 calculate the Addr_Mem, it should be the dirty tag with the other part from input
    //In all WRITE_CWM state, the wr_mem=1, 
    //When there is a stall_mem from mem(because of busy), stall in current stage


    /*Addr logic for the mem & cache
    // mem_input include:
    #1. the data from cache (13 bits)
    Need to extend to 16 bits
    #2. the address is combined by the cache tag and cache index
        2.1: cache tag could be tag_in and tag_out----1 mux
        2.2: 
    // cache_input include:
    #1. the data from outside/ the data from the mem (sel by comp?)
    #2. Tag[4:0]=Address[15:11] from outside
    #3. Index[7:0]=Address[10:3]
    #4. Offset[2:0]=Address[2:0] from outside, be used in hit or first visit/ cache offset[2:0] from the ALLOCATE state
    tag_sel: 1--tag from cache_tag_in   , or ,   0--tag from cache_tag_out

    offset_cache_sel:1--mem_addr= {cache_tag_out(tag of the dirty data), addr[10:3](from outside),offset_mem(from FSM)} 
                 0--mem_addr= {addr[15:3](from outside)}

    data_in_cache_sel:

*/


    WRITE_C2M_0: begin
        wr_mem=1;
        offset_cache=3'd0;//bank 0
        offset_cache_sel=1;//cache offset is from cache
        tag_sel=1;//tag is from cache
        offset_mem=3'd0;//mem address combined with mem offset
        
        nxt_state=stall_mem? WRITE_C2M_0: WRITE_C2M_1;

    end

    WRITE_C2M_1: begin
        wr_mem=1;
        offset_cache=3'd1;//bank 0
        offset_cache_sel=1;//cache offset is from cache
        tag_sel=1;//tag is from cache
        offset_mem=3'd0;//mem address combined with mem offset
        
        nxt_state=stall_mem? WRITE_C2M_1: WRITE_C2M_2;

    end

    WRITE_C2M_2: begin
        wr_mem=1;
        offset_cache=3'd2;//bank 0
        offset_cache_sel=1;//cache offset is from cache
        tag_sel=1;//tag is from cache
        offset_mem=3'd0;//mem address combined with mem offset
        
        nxt_state=stall_mem? WRITE_C2M_2: WRITE_C2M_3;

    end

    WRITE_C2M_3: begin
        wr_mem=1;
        offset_cache=3'd3;//bank 0
        offset_cache_sel=1;//cache offset is from cache
        tag_sel=1;//tag is from cache
        offset_mem=3'd0;//mem address combined with mem offset
        
        nxt_state=stall_mem? WRITE_C2M_3: ALLOCATE_0;

    end




    //ALLOCATE:
    //Read data from the  WRITE_C2M and write back to cache, we need write 4 times, AND Read 4 times
    //for example, the CPU want to write the dirty byte in one row
    //we need:
    //#1. get the full set(row) from the mem with the Cache tag_out+offset [00, 01, 10, 11]
    //#2. write both tag and the data into cache;
    //#3. write the CPI new data in to the right position with offset and address from outside logic
    //#4. done asseted and comp disasserted


    //#1. With the Addr_mem provided by {tag_out , offset_mem} in FSM, write completed in 4 cycles
    //#2. All ALLOCATE need to read the mem and set the rd_mem to 1
    //#3. Data was from the mem, when we rd the mem, set valid_in=1

    ALLOCATE_0: begin //read data 0 from mem in required row
        rd_mem=1;
        offset_mem=3'b000;

        nxt_state=(stall_mem)? ALLOCATE_0: ALLOCATE_1; //read process be controlled by the mem status-- busy or not          
    end

    ALLOCATE_1: begin //read data 1 from mem in required row
        rd_mem=1;
        offset_mem=3'b010;

        nxt_state=(stall_mem)? ALLOCATE_1: ALLOCATE_2; //read process be controlled by the mem status-- busy or not          
    end

    ALLOCATE_2: begin //read data 2 from mem in required row, and write the data in cache offset 00 (from mem)
        rd_mem=1;
        offset_mem=3'b100;

        valid_in=1;// valid_in work for cache write data_in
        wr_cache=1;
        offset_cache=3'b000;
        offset_cache_sel=((cache_offset_in==3'd0) & (wr==1))?0:1;//cache offset from the cache,not outside
        data_in_cache_sel=((cache_offset_in==3'd0) & (wr==1))?0:1;// cacge data from the mem, not outside
        comp=((cache_offset_in==3'd0) & (wr==1))?0:1;

        nxt_state=(stall_mem)? ALLOCATE_2: ALLOCATE_3;    
    end

    ALLOCATE_3: begin //read data 3 from mem in required row, and write the data in cache offset 01 (from mem)
        rd_mem=1;
        offset_mem=3'b110;

        valid_in=1;// valid_in work for cache write data_in
        wr_cache=1;
        offset_cache=3'b010;
        offset_cache_sel=((cache_offset_in==3'd1) & (wr==1))?0:1;//cache offset from the cache,not outside
        data_in_cache_sel=((cache_offset_in==3'd1) & (wr==1))?0:1;// cacge data from the mem, not outside
        comp=((cache_offset_in==3'd1) & (wr==1))?0:1;

        nxt_state=(stall_mem)? ALLOCATE_3: ALLOCATE_4;
    
    end


    ALLOCATE_4: begin //write the data in cache offset 10 (from mem)
        //rd_mem=1;
        //offset_mem=3'b110;

        valid_in=1;// valid_in work for cache write data_in
        wr_cache=1;
        offset_cache=3'b100;
        offset_cache_sel=((cache_offset_in==3'd2) & (wr==1))?0:1;//cache offset from the cache,not outside
        data_in_cache_sel=((cache_offset_in==3'd2) & (wr==1))?0:1;// cacge data from the mem, not outside
        comp=((cache_offset_in==3'd2) & (wr==1))?0:1;

        nxt_state=ALLOCATE_5;
    
    end

    ALLOCATE_5: begin //write the data in cache offset 11 (from mem)
        //rd_mem=1;
        //offset_mem=3'b110;

        valid_in=1;// valid_in work for cache write data_in
        wr_cache=1;
        offset_cache=3'b110;
        offset_cache_sel=((cache_offset_in==3'd3) & (wr==1))?0:1;//cache offset from the cache,not outside
        data_in_cache_sel=((cache_offset_in==3'd3) & (wr==1))?0:1;// cacge data from the mem, not outside
        comp=((cache_offset_in==3'd3) & (wr==1))?0:1;
        
        nxt_state=DONE;
    
    end


    DONE: begin
        stall_outside=0;// accept the input when the mission in cache has been done, disasserted stall_outside
        done=1;
        nxt_state=(wr & rd)?IDLE:
		          (wr ^ rd)?TAG_COMP:
		          ERR;
    end

    ERR: begin
        err=1;
        nxt_state=IDLE;
    end

    default:begin
        nxt_state=IDLE;
    end


    endcase
end



//rd_mem & wr_mem logic
/*
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rd_mem<=0;
        wr_mem<=0;
    end
    else if (comp) begin//cache controller in work mode
        rd_mem<=(~hit)//read-miss (whatever dirty or not), 
                      //write-miss-~dirty:1st write, only in cache, and set dirty to 1
                      //write-miss-dirty:write to an new-updated position:
                      //2 ways to do it:a) write to mem either, set dirty to 0
                      //                b) write to cache only, keep dirty to 1
        wr_mem<= ~hit & dirty;//read-miss-dirty & write-miss-dirty
    end
    else begin
        rd_mem<=rd_mem;
        wr_mem<=wr_mem;
    end
end

*/



//Index compare logic (for 2-ways-associate-cache)







endmodule