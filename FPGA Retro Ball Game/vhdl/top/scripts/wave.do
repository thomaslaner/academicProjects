onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top_tb/sram_we_n
add wave -noupdate /top_tb/sram_ub_n
add wave -noupdate /top_tb/sram_oe_n
add wave -noupdate /top_tb/sram_lb_n
add wave -noupdate /top_tb/sram_ce_n
add wave -noupdate /top_tb/sram_dq
add wave -noupdate /top_tb/sram_addr
add wave -noupdate /top_tb/scen
add wave -noupdate /top_tb/sda
add wave -noupdate /top_tb/sclk

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {135 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
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
WaveRestoreZoom {0 ns} {752483 ns}
