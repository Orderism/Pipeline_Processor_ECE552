onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /mem_system_randbench/clk
add wave -noupdate /mem_system_randbench/rst
add wave -noupdate -radix unsigned /mem_system_randbench/n_requests
add wave -noupdate -radix unsigned /mem_system_randbench/n_replies
add wave -noupdate -radix unsigned /mem_system_randbench/n_cache_hits
add wave -noupdate -radix unsigned /mem_system_randbench/n_cache_hits_total
add wave -noupdate -radix unsigned /mem_system_randbench/DUT/clkgen/cycle_count
add wave -noupdate -divider Top-Level
add wave -noupdate /mem_system_randbench/Addr
add wave -noupdate /mem_system_randbench/index
add wave -noupdate /mem_system_randbench/tag
add wave -noupdate /mem_system_randbench/Rd
add wave -noupdate /mem_system_randbench/Wr
add wave -noupdate /mem_system_randbench/DataIn
add wave -noupdate /mem_system_randbench/Done
add wave -noupdate /mem_system_randbench/Stall
add wave -noupdate /mem_system_randbench/CacheHit
add wave -noupdate /mem_system_randbench/DataOut
add wave -noupdate /mem_system_randbench/DataOut_ref
add wave -noupdate -divider FSM
add wave -noupdate /mem_system_randbench/DUT/m0/ccc/cur_state
add wave -noupdate /mem_system_randbench/DUT/m0/ccc/nxt_state
add wave -noupdate /mem_system_randbench/DUT/m0/ff_victim
add wave -noupdate /mem_system_randbench/DUT/m0/V_in
add wave -noupdate /mem_system_randbench/DUT/m0/V_out
add wave -noupdate -divider {Way 0}
add wave -noupdate /mem_system_randbench/DUT/m0/c0/enable
add wave -noupdate /mem_system_randbench/DUT/m0/c0/comp
add wave -noupdate /mem_system_randbench/DUT/m0/c0/write
add wave -noupdate /mem_system_randbench/DUT/m0/c0/tag_in
add wave -noupdate /mem_system_randbench/DUT/m0/c0/index
add wave -noupdate /mem_system_randbench/DUT/m0/c0/offset
add wave -noupdate /mem_system_randbench/DUT/m0/c0/data_in
add wave -noupdate /mem_system_randbench/DUT/m0/c0/valid_in
add wave -noupdate /mem_system_randbench/DUT/m0/c0/dirty_in
add wave -noupdate /mem_system_randbench/DUT/m0/c0/tag_out
add wave -noupdate /mem_system_randbench/DUT/m0/c0/data_out
add wave -noupdate /mem_system_randbench/DUT/m0/c0/hit
add wave -noupdate /mem_system_randbench/DUT/m0/c0/dirty
add wave -noupdate /mem_system_randbench/DUT/m0/c0/valid
add wave -noupdate -divider {Way 1}
add wave -noupdate /mem_system_randbench/DUT/m0/c1/enable
add wave -noupdate /mem_system_randbench/DUT/m0/c1/comp
add wave -noupdate /mem_system_randbench/DUT/m0/c1/write
add wave -noupdate /mem_system_randbench/DUT/m0/c1/tag_in
add wave -noupdate /mem_system_randbench/DUT/m0/c1/index
add wave -noupdate /mem_system_randbench/DUT/m0/c1/offset
add wave -noupdate /mem_system_randbench/DUT/m0/c1/data_in
add wave -noupdate /mem_system_randbench/DUT/m0/c1/valid_in
add wave -noupdate /mem_system_randbench/DUT/m0/c1/dirty_in
add wave -noupdate /mem_system_randbench/DUT/m0/c1/hit
add wave -noupdate /mem_system_randbench/DUT/m0/c1/dirty
add wave -noupdate /mem_system_randbench/DUT/m0/c1/valid
add wave -noupdate /mem_system_randbench/DUT/m0/c1/tag_out
add wave -noupdate /mem_system_randbench/DUT/m0/c1/data_out
add wave -noupdate -divider {Main Mem}
add wave -noupdate /mem_system_randbench/DUT/m0/mem/addr
add wave -noupdate /mem_system_randbench/DUT/m0/mem/data_in
add wave -noupdate /mem_system_randbench/DUT/m0/mem/wr
add wave -noupdate /mem_system_randbench/DUT/m0/mem/rd
add wave -noupdate /mem_system_randbench/DUT/m0/mem/data_out
add wave -noupdate /mem_system_randbench/DUT/m0/mem/stall
add wave -noupdate /mem_system_randbench/DUT/m0/mem/busy
add wave -noupdate /mem_system_randbench/DUT/m0/mem/en
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {600494 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 285
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {599885 ns} {600733 ns}
