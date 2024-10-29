onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider inputs
add wave -noupdate -label op /tb/alu_inst/op
add wave -noupdate -label A /tb/alu_inst/A
add wave -noupdate -label B /tb/alu_inst/B
add wave -noupdate -divider outputs
add wave -noupdate -label R /tb/alu_inst/R
add wave -noupdate -label Z /tb/alu_inst/Z
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {52462 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
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
configure wave -timelineunits ms
update
WaveRestoreZoom {0 ps} {304500 ps}
