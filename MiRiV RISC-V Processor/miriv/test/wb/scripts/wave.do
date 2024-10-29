onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Input
add wave -noupdate /tb/uut_inst/clk
add wave -noupdate /tb/uut_inst/res_n
add wave -noupdate /tb/uut_inst/stall
add wave -noupdate /tb/uut_inst/flush
add wave -noupdate /tb/uut_inst/op
add wave -noupdate /tb/uut_inst/aluresult
add wave -noupdate /tb/uut_inst/memresult
add wave -noupdate /tb/uut_inst/pc_old_in
add wave -noupdate -divider Output
add wave -noupdate /tb/uut_inst/reg_write
add wave -noupdate -divider Internal
add wave -noupdate /tb/uut_inst/op_reg
add wave -noupdate /tb/uut_inst/aluresult_reg
add wave -noupdate /tb/uut_inst/memresult_reg
add wave -noupdate /tb/uut_inst/pc_old_in_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {18372 ps} 0}
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
WaveRestoreZoom {0 ps} {105 ns}
