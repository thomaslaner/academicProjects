onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group entity /ball_game_ex2_tb/UUT/clk
add wave -noupdate -expand -group entity /ball_game_ex2_tb/UUT/res_n
add wave -noupdate -expand -group entity -group gfx_signals /ball_game_ex2_tb/UUT/gfx_instr
add wave -noupdate -expand -group entity -group gfx_signals /ball_game_ex2_tb/UUT/gfx_instr_wr
add wave -noupdate -expand -group entity -group gfx_signals /ball_game_ex2_tb/UUT/gfx_instr_full
add wave -noupdate -expand -group entity -group gfx_signals /ball_game_ex2_tb/UUT/gfx_data
add wave -noupdate -expand -group entity -group gfx_signals /ball_game_ex2_tb/UUT/gfx_data_wr
add wave -noupdate -expand -group entity -group gfx_signals /ball_game_ex2_tb/UUT/gfx_data_full
add wave -noupdate -expand -group entity -group gfx_signals /ball_game_ex2_tb/UUT/gfx_frame_sync
add wave -noupdate -expand -group entity -expand -group i/o -expand /ball_game_ex2_tb/UUT/controller
add wave -noupdate -expand -group entity -expand -group i/o /ball_game_ex2_tb/UUT/synth_cntrl
add wave -noupdate -expand -group entity -expand -group i/o /ball_game_ex2_tb/UUT/player_points
add wave -noupdate -expand -group entity -expand -group i/o /ball_game_ex2_tb/UUT/game_state
add wave -noupdate -expand -group game_signals -expand -group internal_game_state /ball_game_ex2_tb/UUT/internal_game_state
add wave -noupdate -expand -group game_signals -expand -group internal_game_state /ball_game_ex2_tb/UUT/internal_game_state_next
add wave -noupdate -expand -group game_signals /ball_game_ex2_tb/UUT/game_state_next
add wave -noupdate -expand -group game_signals -group game_rotations /ball_game_ex2_tb/UUT/game_rotations
add wave -noupdate -expand -group game_signals -group game_rotations /ball_game_ex2_tb/UUT/game_rotations_next
add wave -noupdate -expand -group game_signals -group game_speed /ball_game_ex2_tb/UUT/game_speed
add wave -noupdate -expand -group game_signals -group game_speed /ball_game_ex2_tb/UUT/game_speed_next
add wave -noupdate -expand -group game_signals -group player_points_internal /ball_game_ex2_tb/UUT/player_points_internal
add wave -noupdate -expand -group game_signals -group player_points_internal /ball_game_ex2_tb/UUT/player_points_internal_next
add wave -noupdate -group {player handling} -group player /ball_game_ex2_tb/UUT/player
add wave -noupdate -group {player handling} -group player /ball_game_ex2_tb/UUT/player_next
add wave -noupdate -group {player handling} -group rndm_player_direction /ball_game_ex2_tb/UUT/random_player_direction
add wave -noupdate -group {player handling} -group rndm_player_direction /ball_game_ex2_tb/UUT/random_player_direction_next
add wave -noupdate -group {player handling} -group change_dir_counter /ball_game_ex2_tb/UUT/change_direction_counter
add wave -noupdate -group {player handling} -group change_dir_counter /ball_game_ex2_tb/UUT/change_direction_counter_next
add wave -noupdate -group item /ball_game_ex2_tb/UUT/item
add wave -noupdate -group item /ball_game_ex2_tb/UUT/item_next
add wave -noupdate -expand -group object_fifo -group object_fifo_inst /ball_game_ex2_tb/UUT/object_fifo_out_sig
add wave -noupdate -expand -group object_fifo -group object_fifo_inst /ball_game_ex2_tb/UUT/object_fifo_out_data
add wave -noupdate -expand -group object_fifo -group object_fifo_inst /ball_game_ex2_tb/UUT/object_fifo_in_sig
add wave -noupdate -expand -group object_fifo -group object_fifo_inst /ball_game_ex2_tb/UUT/object_fifo_in_data
add wave -noupdate -expand -group object_fifo -group object_fifo_inst /ball_game_ex2_tb/UUT/object_fifo_empty
add wave -noupdate -expand -group object_fifo -expand -group object_fifo_counter /ball_game_ex2_tb/UUT/object_fifo_counter
add wave -noupdate -expand -group object_fifo -expand -group object_fifo_counter /ball_game_ex2_tb/UUT/object_fifo_counter_next
add wave -noupdate -expand -group object_fifo -group object_processed /ball_game_ex2_tb/UUT/object_processed_counter
add wave -noupdate -expand -group object_fifo -group object_processed /ball_game_ex2_tb/UUT/object_processed_counter_next
add wave -noupdate -expand -group object_fifo -expand -group current_object -radix unsigned /ball_game_ex2_tb/UUT/current_object
add wave -noupdate -expand -group object_fifo -expand -group current_object -radix unsigned /ball_game_ex2_tb/UUT/current_object_next
add wave -noupdate -expand -group object_fifo -group lowest_height /ball_game_ex2_tb/UUT/lowest_height
add wave -noupdate -expand -group object_fifo -group lowest_height /ball_game_ex2_tb/UUT/lowest_height_next
add wave -noupdate -expand -group object_fifo -group initial_lowest_height /ball_game_ex2_tb/UUT/initial_lowest_height
add wave -noupdate -expand -group object_fifo -group initial_lowest_height /ball_game_ex2_tb/UUT/initial_lowest_height_next
add wave -noupdate -expand -group object_fifo -expand -group game_object_creation -expand -group current_x_pos /ball_game_ex2_tb/UUT/current_x_pos
add wave -noupdate -expand -group object_fifo -expand -group game_object_creation -expand -group current_x_pos /ball_game_ex2_tb/UUT/current_x_pos_next
add wave -noupdate -expand -group object_fifo -expand -group game_object_creation -expand -group current_width /ball_game_ex2_tb/UUT/current_width
add wave -noupdate -expand -group object_fifo -expand -group game_object_creation -expand -group current_width /ball_game_ex2_tb/UUT/current_width_next
add wave -noupdate -expand -group object_fifo -expand -group game_object_creation -expand -group current_y_pos /ball_game_ex2_tb/UUT/current_y_pos
add wave -noupdate -expand -group object_fifo -expand -group game_object_creation -expand -group current_y_pos /ball_game_ex2_tb/UUT/current_y_pos_next
add wave -noupdate -group initialization /ball_game_ex2_tb/UUT/init_gfx_instr
add wave -noupdate -group initialization /ball_game_ex2_tb/UUT/init_gfx_instr_wr
add wave -noupdate -group initialization /ball_game_ex2_tb/UUT/init_gfx_data
add wave -noupdate -group initialization /ball_game_ex2_tb/UUT/init_gfx_data_wr
add wave -noupdate -group initialization /ball_game_ex2_tb/UUT/gfx_initializer_start
add wave -noupdate -group initialization /ball_game_ex2_tb/UUT/gfx_initializer_busy
add wave -noupdate -group {object collider} -group game_object_cnt /ball_game_ex2_tb/UUT/game_object_cnt
add wave -noupdate -group {object collider} -group game_object_cnt /ball_game_ex2_tb/UUT/game_object_cnt_next
add wave -noupdate -group {object collider} /ball_game_ex2_tb/UUT/oc_start
add wave -noupdate -group {object collider} /ball_game_ex2_tb/UUT/oc_done
add wave -noupdate -group {object collider} /ball_game_ex2_tb/UUT/oc_apply_movement
add wave -noupdate -group {object collider} /ball_game_ex2_tb/UUT/oc_apply_gravity
add wave -noupdate -group {object collider} /ball_game_ex2_tb/UUT/oc_player_dir
add wave -noupdate -group {object collider} /ball_game_ex2_tb/UUT/oc_player_speed
add wave -noupdate -group {object collider} -expand -group gravity /ball_game_ex2_tb/UUT/gravity
add wave -noupdate -group {object collider} -expand -group gravity /ball_game_ex2_tb/UUT/gravity_next
add wave -noupdate -group {object collider} /ball_game_ex2_tb/UUT/oc_object_valid
add wave -noupdate -group {object collider} /ball_game_ex2_tb/UUT/oc_object_eol
add wave -noupdate -group {object collider} /ball_game_ex2_tb/UUT/oc_object
add wave -noupdate -group {object collider} /ball_game_ex2_tb/UUT/oc_object_is_blocking
add wave -noupdate -group {object collider} /ball_game_ex2_tb/UUT/oc_object_req
add wave -noupdate -group {object collider} /ball_game_ex2_tb/UUT/oc_collision_detected
add wave -noupdate -group {object collider} /ball_game_ex2_tb/UUT/oc_player_x
add wave -noupdate -group {object collider} /ball_game_ex2_tb/UUT/oc_player_y
add wave -noupdate -group random_value_generation /ball_game_ex2_tb/UUT/prdata
add wave -noupdate -group random_value_generation /ball_game_ex2_tb/UUT/load_seed
add wave -noupdate -group random_value_generation -expand -group x_pos -radix unsigned /ball_game_ex2_tb/UUT/random_x_pos
add wave -noupdate -group random_value_generation -expand -group x_pos /ball_game_ex2_tb/UUT/random_x_pos_valid
add wave -noupdate -group random_value_generation -expand -group r_0_3 -radix unsigned /ball_game_ex2_tb/UUT/random_value_r_0_3
add wave -noupdate -group random_value_generation -expand -group r_0_3 /ball_game_ex2_tb/UUT/random_value_r_0_3_valid
add wave -noupdate -group random_value_generation -expand -group r_1_10 -radix unsigned /ball_game_ex2_tb/UUT/random_value_r_1_10
add wave -noupdate -group random_value_generation -expand -group r_1_10 /ball_game_ex2_tb/UUT/random_value_r_1_10_valid
add wave -noupdate -group random_value_generation -expand -group r_2_5 -radix unsigned /ball_game_ex2_tb/UUT/random_value_r_2_5
add wave -noupdate -group random_value_generation -expand -group r_2_5 /ball_game_ex2_tb/UUT/random_value_r_2_5_valid
add wave -noupdate -group random_value_generation -expand -group direction -radix unsigned /ball_game_ex2_tb/UUT/random_direction
add wave -noupdate -group random_value_generation -expand -group direction /ball_game_ex2_tb/UUT/random_direction_valid
add wave -noupdate -group random_value_generation -expand -group item_value -radix unsigned /ball_game_ex2_tb/UUT/random_item_value
add wave -noupdate -group random_value_generation -expand -group item_value /ball_game_ex2_tb/UUT/random_item_value_valid
add wave -noupdate -group start_button_released /ball_game_ex2_tb/UUT/start_button_released
add wave -noupdate -group start_button_released /ball_game_ex2_tb/UUT/start_button_released_next
add wave -noupdate -group audio /ball_game_ex2_tb/UUT/synth_cntrl_1_sig
add wave -noupdate -group audio /ball_game_ex2_tb/UUT/synth_cntrl_0_sig
add wave -noupdate -group audio -expand -group item_collected_audio_counter /ball_game_ex2_tb/UUT/item_collected_audio_counter
add wave -noupdate -group audio -expand -group item_collected_audio_counter /ball_game_ex2_tb/UUT/item_collected_audio_counter_next
add wave -noupdate -group audio -expand -group game_over_audio_counter /ball_game_ex2_tb/UUT/game_over_audio_counter
add wave -noupdate -group audio -expand -group game_over_audio_counter /ball_game_ex2_tb/UUT/game_over_audio_counter_next
add wave -noupdate -expand -group fifo /ball_game_ex2_tb/UUT/object_fifo_inst/clk
add wave -noupdate -expand -group fifo /ball_game_ex2_tb/UUT/object_fifo_inst/res_n
add wave -noupdate -expand -group fifo /ball_game_ex2_tb/UUT/object_fifo_inst/rd_data
add wave -noupdate -expand -group fifo /ball_game_ex2_tb/UUT/object_fifo_inst/rd
add wave -noupdate -expand -group fifo /ball_game_ex2_tb/UUT/object_fifo_inst/wr_data
add wave -noupdate -expand -group fifo /ball_game_ex2_tb/UUT/object_fifo_inst/wr
add wave -noupdate -expand -group fifo /ball_game_ex2_tb/UUT/object_fifo_inst/empty
add wave -noupdate -expand -group fifo /ball_game_ex2_tb/UUT/object_fifo_inst/full
add wave -noupdate -expand -group fifo /ball_game_ex2_tb/UUT/object_fifo_inst/half_full
add wave -noupdate -expand -group fifo /ball_game_ex2_tb/UUT/object_fifo_inst/read_address
add wave -noupdate -expand -group fifo /ball_game_ex2_tb/UUT/object_fifo_inst/read_address_next
add wave -noupdate -expand -group fifo -radix unsigned /ball_game_ex2_tb/UUT/object_fifo_inst/write_address
add wave -noupdate -expand -group fifo /ball_game_ex2_tb/UUT/object_fifo_inst/write_address_next
add wave -noupdate -expand -group fifo /ball_game_ex2_tb/UUT/object_fifo_inst/full_next
add wave -noupdate -expand -group fifo /ball_game_ex2_tb/UUT/object_fifo_inst/empty_next
add wave -noupdate -expand -group fifo /ball_game_ex2_tb/UUT/object_fifo_inst/wr_int
add wave -noupdate -expand -group fifo /ball_game_ex2_tb/UUT/object_fifo_inst/rd_int
add wave -noupdate -expand -group fifo /ball_game_ex2_tb/UUT/object_fifo_inst/half_full_next
add wave -noupdate -expand -group fifo /ball_game_ex2_tb/UUT/object_fifo_inst/pointer_diff
add wave -noupdate -expand -group fifo /ball_game_ex2_tb/UUT/object_fifo_inst/pointer_diff_next
add wave -noupdate -group fifo_mem /ball_game_ex2_tb/UUT/object_fifo_inst/memory_inst/clk
add wave -noupdate -group fifo_mem -radix unsigned /ball_game_ex2_tb/UUT/object_fifo_inst/memory_inst/rd1_addr
add wave -noupdate -group fifo_mem /ball_game_ex2_tb/UUT/object_fifo_inst/memory_inst/rd1_data
add wave -noupdate -group fifo_mem /ball_game_ex2_tb/UUT/object_fifo_inst/memory_inst/rd1
add wave -noupdate -group fifo_mem -radix unsigned /ball_game_ex2_tb/UUT/object_fifo_inst/memory_inst/wr2_addr
add wave -noupdate -group fifo_mem /ball_game_ex2_tb/UUT/object_fifo_inst/memory_inst/wr2_data
add wave -noupdate -group fifo_mem /ball_game_ex2_tb/UUT/object_fifo_inst/memory_inst/wr2
add wave -noupdate -group fifo_mem /ball_game_ex2_tb/UUT/object_fifo_inst/memory_inst/ram
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 2} {153337278 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 264
configure wave -valuecolwidth 419
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
WaveRestoreZoom {0 ps} {1105135500 ps}
