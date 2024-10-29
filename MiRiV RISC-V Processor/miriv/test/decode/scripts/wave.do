onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Input
add wave -noupdate /tb/uut_inst/clk
add wave -noupdate /tb/uut_inst/res_n
add wave -noupdate /tb/uut_inst/stall
add wave -noupdate /tb/uut_inst/flush
add wave -noupdate /tb/uut_inst/pc_in
add wave -noupdate /tb/uut_inst/instr
add wave -noupdate /tb/uut_inst/reg_write
add wave -noupdate -divider Output
add wave -noupdate /tb/uut_inst/pc_out
add wave -noupdate /tb/uut_inst/exec_op
add wave -noupdate /tb/uut_inst/mem_op
add wave -noupdate /tb/uut_inst/wb_op
add wave -noupdate /tb/uut_inst/exc_dec
add wave -noupdate -divider Internal
add wave -noupdate /tb/uut_inst/rddata1
add wave -noupdate /tb/uut_inst/rddata2
add wave -noupdate /tb/uut_inst/imm
add wave -noupdate /tb/uut_inst/funct7
add wave -noupdate /tb/uut_inst/rs1
add wave -noupdate /tb/uut_inst/rs2
add wave -noupdate /tb/uut_inst/funct3
add wave -noupdate /tb/uut_inst/rd
add wave -noupdate /tb/uut_inst/opcode
add wave -noupdate /tb/uut_inst/instr_reg
add wave -noupdate /tb/uut_inst/pc_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {37291 ps} 0}
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
WaveRestoreZoom {0 ps} {451500 ps}
