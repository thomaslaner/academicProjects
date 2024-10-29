onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ssd_controller_tb/uut/clk
add wave -noupdate /ssd_controller_tb/uut/res_n
add wave -noupdate /ssd_controller_tb/uut/game_state
add wave -noupdate /ssd_controller_tb/uut/controller
add wave -noupdate /ssd_controller_tb/uut/player_points
add wave -noupdate -expand -group hex_segments /ssd_controller_tb/uut/hex0
add wave -noupdate -expand -group hex_segments /ssd_controller_tb/uut/hex1
add wave -noupdate -expand -group hex_segments /ssd_controller_tb/uut/hex2
add wave -noupdate -expand -group hex_segments /ssd_controller_tb/uut/hex3
add wave -noupdate -expand -group hex_segments /ssd_controller_tb/uut/hex4
add wave -noupdate -expand -group hex_segments /ssd_controller_tb/uut/hex5
add wave -noupdate -expand -group hex_segments /ssd_controller_tb/uut/hex6
add wave -noupdate -expand -group hex_segments /ssd_controller_tb/uut/hex7
add wave -noupdate -expand -group constants /ssd_controller_tb/uut/BLINK_INTERVAL
add wave -noupdate -expand -group constants /ssd_controller_tb/uut/BLINK_COUNT
add wave -noupdate -expand -group constants /ssd_controller_tb/uut/invalid_num
add wave -noupdate -expand -group state_machine /ssd_controller_tb/uut/thousands_digit
add wave -noupdate -expand -group state_machine /ssd_controller_tb/uut/hundreds_digit
add wave -noupdate -expand -group state_machine /ssd_controller_tb/uut/tens_digit
add wave -noupdate -expand -group state_machine /ssd_controller_tb/uut/ones_digit
add wave -noupdate -expand -group state_machine /ssd_controller_tb/uut/player_points_conv
add wave -noupdate -expand -group state_machine /ssd_controller_tb/uut/player_points_og
add wave -noupdate -expand -group state_machine /ssd_controller_tb/uut/state
add wave -noupdate -expand -group state_machine /ssd_controller_tb/uut/output_hex0
add wave -noupdate -expand -group state_machine /ssd_controller_tb/uut/output_hex1
add wave -noupdate -expand -group state_machine /ssd_controller_tb/uut/output_hex2
add wave -noupdate -expand -group state_machine /ssd_controller_tb/uut/output_hex3
add wave -noupdate -expand -group blink_interval_timer /ssd_controller_tb/uut/blinkCount_Counter
add wave -noupdate -expand -group blink_interval_timer /ssd_controller_tb/uut/blinkInterval_Counter
add wave -noupdate -expand -group bonus_task /ssd_controller_tb/uut/state_animation
add wave -noupdate -expand -group bonus_task /ssd_controller_tb/uut/hex7_animation
add wave -noupdate -expand -group bonus_task /ssd_controller_tb/uut/hex6_animation
add wave -noupdate -expand -group bonus_task /ssd_controller_tb/uut/animation_interval_counter

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
