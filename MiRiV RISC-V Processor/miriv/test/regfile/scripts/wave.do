onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/regfile_inst/clk
add wave -noupdate /tb/regfile_inst/res_n
add wave -noupdate -divider Input
add wave -noupdate -radix binary /tb/regfile_inst/rdaddr1
add wave -noupdate -radix binary /tb/regfile_inst/rdaddr2
add wave -noupdate /tb/regfile_inst/regwrite
add wave -noupdate /tb/regfile_inst/stall
add wave -noupdate -radix binary /tb/regfile_inst/wraddr
add wave -noupdate -radix hexadecimal /tb/regfile_inst/wrdata
add wave -noupdate -divider Output
add wave -noupdate -radix hexadecimal /tb/regfile_inst/rddata1
add wave -noupdate -radix hexadecimal /tb/regfile_inst/rddata2
add wave -noupdate -divider {Implementation Signals}
add wave -noupdate -color {Steel Blue} -expand -subitemconfig {/tb/regfile_inst/reg(31) {-color {Steel Blue}} /tb/regfile_inst/reg(30) {-color {Steel Blue}} /tb/regfile_inst/reg(29) {-color {Steel Blue}} /tb/regfile_inst/reg(28) {-color {Steel Blue}} /tb/regfile_inst/reg(27) {-color {Steel Blue}} /tb/regfile_inst/reg(26) {-color {Steel Blue}} /tb/regfile_inst/reg(25) {-color {Steel Blue}} /tb/regfile_inst/reg(24) {-color {Steel Blue}} /tb/regfile_inst/reg(23) {-color {Steel Blue}} /tb/regfile_inst/reg(22) {-color {Steel Blue}} /tb/regfile_inst/reg(21) {-color {Steel Blue}} /tb/regfile_inst/reg(20) {-color {Steel Blue}} /tb/regfile_inst/reg(19) {-color {Steel Blue}} /tb/regfile_inst/reg(18) {-color {Steel Blue}} /tb/regfile_inst/reg(17) {-color {Steel Blue}} /tb/regfile_inst/reg(16) {-color {Steel Blue}} /tb/regfile_inst/reg(15) {-color {Steel Blue}} /tb/regfile_inst/reg(14) {-color {Steel Blue}} /tb/regfile_inst/reg(13) {-color {Steel Blue}} /tb/regfile_inst/reg(12) {-color {Steel Blue}} /tb/regfile_inst/reg(11) {-color {Steel Blue}} /tb/regfile_inst/reg(10) {-color {Steel Blue}} /tb/regfile_inst/reg(9) {-color {Steel Blue}} /tb/regfile_inst/reg(8) {-color {Steel Blue}} /tb/regfile_inst/reg(7) {-color {Steel Blue}} /tb/regfile_inst/reg(6) {-color {Steel Blue}} /tb/regfile_inst/reg(5) {-color {Steel Blue}} /tb/regfile_inst/reg(4) {-color {Steel Blue}} /tb/regfile_inst/reg(3) {-color {Steel Blue}} /tb/regfile_inst/reg(2) {-color {Steel Blue}} /tb/regfile_inst/reg(1) {-color {Steel Blue}} /tb/regfile_inst/reg(0) {-color {Steel Blue}}} /tb/regfile_inst/reg
add wave -noupdate /tb/regfile_inst/rdaddr1_sig
add wave -noupdate /tb/regfile_inst/rdaddr2_sig
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {275000 ps} 0}
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
WaveRestoreZoom {0 ps} {357 ns}
