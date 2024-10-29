onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Input
add wave -noupdate /tb/uut_inst/clk
add wave -noupdate /tb/uut_inst/res_n
add wave -noupdate /tb/uut_inst/stall
add wave -noupdate /tb/uut_inst/flush
add wave -noupdate /tb/uut_inst/op
add wave -noupdate /tb/uut_inst/pc_in
add wave -noupdate /tb/uut_inst/memop_in
add wave -noupdate /tb/uut_inst/wbop_in
add wave -noupdate /tb/uut_inst/reg_write_mem
add wave -noupdate /tb/uut_inst/reg_write_wr
add wave -noupdate -divider Output
add wave -noupdate /tb/uut_inst/pc_old_out
add wave -noupdate /tb/uut_inst/pc_new_out
add wave -noupdate /tb/uut_inst/aluresult
add wave -noupdate /tb/uut_inst/wrdata
add wave -noupdate /tb/uut_inst/zero
add wave -noupdate /tb/uut_inst/memop_out
add wave -noupdate /tb/uut_inst/wbop_out
add wave -noupdate /tb/uut_inst/exec_op
add wave -noupdate -divider Internal
add wave -noupdate /tb/uut_inst/alu_op
add wave -noupdate /tb/uut_inst/alu_a
add wave -noupdate /tb/uut_inst/alu_b
add wave -noupdate /tb/uut_inst/alu_res
add wave -noupdate /tb/uut_inst/alu_z
add wave -noupdate /tb/uut_inst/pc_in_exec
add wave -noupdate /tb/uut_inst/memop_in_next
add wave -noupdate /tb/uut_inst/wbop_in_next
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
WaveRestoreZoom {0 ps} {126 ns}
