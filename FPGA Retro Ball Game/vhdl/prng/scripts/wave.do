onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /prng_tb/clk
add wave -noupdate /prng_tb/res_n
add wave -noupdate /prng_tb/en
add wave -noupdate /prng_tb/prdata
add wave -noupdate /prng_tb/load_seed
add wave -noupdate /prng_tb/seed
add wave -noupdate /prng_tb/stop_clk

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
WaveRestoreZoom {31 ns} {536 ns}
