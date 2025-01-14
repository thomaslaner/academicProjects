onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Input
add wave -noupdate /tb/fetch_inst/clk
add wave -noupdate /tb/fetch_inst/res_n
add wave -noupdate /tb/fetch_inst/stall
add wave -noupdate /tb/fetch_inst/flush
add wave -noupdate /tb/fetch_inst/pcsrc
add wave -noupdate -radix unsigned /tb/fetch_inst/pc_in
add wave -noupdate /tb/fetch_inst/mem_in
add wave -noupdate -divider Output
add wave -noupdate /tb/fetch_inst/mem_busy
add wave -noupdate -radix unsigned /tb/fetch_inst/pc_out
add wave -noupdate -radix hexadecimal /tb/fetch_inst/instr
add wave -noupdate /tb/fetch_inst/mem_out
add wave -noupdate -divider Internal
add wave -noupdate -expand -group pc_sig -radix unsigned /tb/fetch_inst/pc
add wave -noupdate -expand -group pc_sig -radix unsigned /tb/fetch_inst/pc_next
add wave -noupdate -expand -group instr_sig -radix hexadecimal /tb/fetch_inst/instr_sig
add wave -noupdate -expand -group instr_sig -radix hexadecimal /tb/fetch_inst/instr_sig_next
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {RESET_END {10000 ps} 1 {Sky Blue} default} {{Cursor 1} {3055 ps} 0}
quietly wave cursor active 2
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
WaveRestoreZoom {0 ps} {190298 ps}
