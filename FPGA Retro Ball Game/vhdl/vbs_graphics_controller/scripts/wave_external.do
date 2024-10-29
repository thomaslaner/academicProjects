onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /vbs_graphics_controller_external_tb/uut/clk
add wave -noupdate /vbs_graphics_controller_external_tb/uut/res_n
add wave -noupdate -group dp_vram -group dp_vram /vbs_graphics_controller_external_tb/uut/dp_video_ram_rd_addr
add wave -noupdate -group dp_vram -group dp_vram /vbs_graphics_controller_external_tb/uut/dp_video_ram_rd_data
add wave -noupdate -group dp_vram -group dp_vram /vbs_graphics_controller_external_tb/uut/dp_video_ram_rd_data_next
add wave -noupdate -group dp_vram -group dp_vram /vbs_graphics_controller_external_tb/uut/dp_video_ram_rd
add wave -noupdate -group dp_vram -group dp_vram /vbs_graphics_controller_external_tb/uut/dp_video_ram_wr_addr
add wave -noupdate -group dp_vram -group dp_vram /vbs_graphics_controller_external_tb/uut/dp_video_ram_wr_addr_next
add wave -noupdate -group dp_vram -group dp_vram /vbs_graphics_controller_external_tb/uut/dp_video_ram_wr_data
add wave -noupdate -group dp_vram -group dp_vram /vbs_graphics_controller_external_tb/uut/dp_video_ram_wr_data_next
add wave -noupdate -group dp_vram -group dp_vram /vbs_graphics_controller_external_tb/uut/dp_video_ram_wr
add wave -noupdate -group dp_vram -group dp_vram /vbs_graphics_controller_external_tb/uut/dp_video_ram_wr_next
add wave -noupdate -group dp_vram -group write_primary_read_secondary_sig /vbs_graphics_controller_external_tb/uut/write_primary_read_secondary_vram
add wave -noupdate -group dp_vram -group write_primary_read_secondary_sig /vbs_graphics_controller_external_tb/uut/write_primary_read_secondary_vram_next
add wave -noupdate -group dp_vram -group {primary dp vram} /vbs_graphics_controller_external_tb/uut/dp_primary_video_ram_rd_addr
add wave -noupdate -group dp_vram -group {primary dp vram} /vbs_graphics_controller_external_tb/uut/dp_primary_video_ram_rd_addr_next
add wave -noupdate -group dp_vram -group {primary dp vram} /vbs_graphics_controller_external_tb/uut/dp_primary_video_ram_rd_data
add wave -noupdate -group dp_vram -group {primary dp vram} /vbs_graphics_controller_external_tb/uut/dp_primary_video_ram_rd
add wave -noupdate -group dp_vram -group {primary dp vram} /vbs_graphics_controller_external_tb/uut/dp_primary_video_ram_rd_next
add wave -noupdate -group dp_vram -group {primary dp vram} /vbs_graphics_controller_external_tb/uut/dp_primary_video_ram_wr_addr
add wave -noupdate -group dp_vram -group {primary dp vram} /vbs_graphics_controller_external_tb/uut/dp_primary_video_ram_wr_addr_next
add wave -noupdate -group dp_vram -group {primary dp vram} /vbs_graphics_controller_external_tb/uut/dp_primary_video_ram_wr_data
add wave -noupdate -group dp_vram -group {primary dp vram} /vbs_graphics_controller_external_tb/uut/dp_primary_video_ram_wr_data_next
add wave -noupdate -group dp_vram -group {primary dp vram} /vbs_graphics_controller_external_tb/uut/dp_primary_video_ram_wr
add wave -noupdate -group dp_vram -group {primary dp vram} /vbs_graphics_controller_external_tb/uut/dp_primary_video_ram_wr_next
add wave -noupdate -group dp_vram -group {secondary dp vram} /vbs_graphics_controller_external_tb/uut/dp_secondary_video_ram_rd_addr
add wave -noupdate -group dp_vram -group {secondary dp vram} /vbs_graphics_controller_external_tb/uut/dp_secondary_video_ram_rd_addr_next
add wave -noupdate -group dp_vram -group {secondary dp vram} /vbs_graphics_controller_external_tb/uut/dp_secondary_video_ram_rd_data
add wave -noupdate -group dp_vram -group {secondary dp vram} /vbs_graphics_controller_external_tb/uut/dp_secondary_video_ram_rd
add wave -noupdate -group dp_vram -group {secondary dp vram} /vbs_graphics_controller_external_tb/uut/dp_secondary_video_ram_rd_next
add wave -noupdate -group dp_vram -group {secondary dp vram} /vbs_graphics_controller_external_tb/uut/dp_secondary_video_ram_wr_addr
add wave -noupdate -group dp_vram -group {secondary dp vram} /vbs_graphics_controller_external_tb/uut/dp_secondary_video_ram_wr_addr_next
add wave -noupdate -group dp_vram -group {secondary dp vram} /vbs_graphics_controller_external_tb/uut/dp_secondary_video_ram_wr_data
add wave -noupdate -group dp_vram -group {secondary dp vram} /vbs_graphics_controller_external_tb/uut/dp_secondary_video_ram_wr_data_next
add wave -noupdate -group dp_vram -group {secondary dp vram} /vbs_graphics_controller_external_tb/uut/dp_secondary_video_ram_wr
add wave -noupdate -group dp_vram -group {secondary dp vram} /vbs_graphics_controller_external_tb/uut/dp_secondary_video_ram_wr_next
add wave -noupdate -expand -group {frame reader} /vbs_graphics_controller_external_tb/uut/frame_reader_frame_start
add wave -noupdate -expand -group {frame reader} /vbs_graphics_controller_external_tb/uut/frame_reader_next_pixel
add wave -noupdate -expand -group {frame reader} /vbs_graphics_controller_external_tb/uut/frame_reader_next_pixel_next
add wave -noupdate -expand -group {frame reader} /vbs_graphics_controller_external_tb/uut/frame_reader_data
add wave -noupdate -expand -group {frame reader} /vbs_graphics_controller_external_tb/uut/frame_reader_base_addr
add wave -noupdate -expand -group {internal interface} -group entity /vbs_graphics_controller_external_tb/uut/gfx_instr
add wave -noupdate -expand -group {internal interface} -group entity /vbs_graphics_controller_external_tb/uut/gfx_instr_wr
add wave -noupdate -expand -group {internal interface} -group entity /vbs_graphics_controller_external_tb/uut/gfx_instr_full
add wave -noupdate -expand -group {internal interface} -group entity /vbs_graphics_controller_external_tb/uut/gfx_data_wr
add wave -noupdate -expand -group {internal interface} -group entity /vbs_graphics_controller_external_tb/uut/gfx_data_full
add wave -noupdate -expand -group {internal interface} -group entity /vbs_graphics_controller_external_tb/uut/gfx_data
add wave -noupdate -expand -group {internal interface} -group entity /vbs_graphics_controller_external_tb/uut/gfx_frame_sync
add wave -noupdate -expand -group {internal interface} -group {fifo buffer} -group {instr fifo} /vbs_graphics_controller_external_tb/uut/instr_fifo_rd_data
add wave -noupdate -expand -group {internal interface} -group {fifo buffer} -group {instr fifo} /vbs_graphics_controller_external_tb/uut/instr_fifo_rd
add wave -noupdate -expand -group {internal interface} -group {fifo buffer} -group {instr fifo} /vbs_graphics_controller_external_tb/uut/instr_fifo_rd_next
add wave -noupdate -expand -group {internal interface} -group {fifo buffer} -group {instr fifo} /vbs_graphics_controller_external_tb/uut/instr_fifo_empty
add wave -noupdate -expand -group {internal interface} -group {fifo buffer} -group {instr fifo} /vbs_graphics_controller_external_tb/uut/instr_fifo_full
add wave -noupdate -expand -group {internal interface} -group {fifo buffer} -group {data fifo} /vbs_graphics_controller_external_tb/uut/data_fifo_rd_data
add wave -noupdate -expand -group {internal interface} -group {fifo buffer} -group {data fifo} /vbs_graphics_controller_external_tb/uut/data_fifo_rd
add wave -noupdate -expand -group {internal interface} -group {fifo buffer} -group {data fifo} /vbs_graphics_controller_external_tb/uut/data_fifo_rd_next
add wave -noupdate -expand -group {internal interface} -group {fifo buffer} -group {data fifo} /vbs_graphics_controller_external_tb/uut/data_fifo_empty
add wave -noupdate -expand -group {internal interface} -group {fifo buffer} -group {data fifo} /vbs_graphics_controller_external_tb/uut/data_fifo_full
add wave -noupdate -expand -group {internal interface} -group rasterizer -group x /vbs_graphics_controller_external_tb/uut/x
add wave -noupdate -expand -group {internal interface} -group rasterizer -group x /vbs_graphics_controller_external_tb/uut/x_next
add wave -noupdate -expand -group {internal interface} -group rasterizer -group y /vbs_graphics_controller_external_tb/uut/y
add wave -noupdate -expand -group {internal interface} -group rasterizer -group y /vbs_graphics_controller_external_tb/uut/y_next
add wave -noupdate -expand -group {internal interface} -group rasterizer -group line /vbs_graphics_controller_external_tb/uut/line_start
add wave -noupdate -expand -group {internal interface} -group rasterizer -group line /vbs_graphics_controller_external_tb/uut/line_start_next
add wave -noupdate -expand -group {internal interface} -group rasterizer -group line /vbs_graphics_controller_external_tb/uut/line_busy
add wave -noupdate -expand -group {internal interface} -group rasterizer -group line /vbs_graphics_controller_external_tb/uut/line_x0
add wave -noupdate -expand -group {internal interface} -group rasterizer -group line /vbs_graphics_controller_external_tb/uut/line_x0_next
add wave -noupdate -expand -group {internal interface} -group rasterizer -group line /vbs_graphics_controller_external_tb/uut/line_x1
add wave -noupdate -expand -group {internal interface} -group rasterizer -group line /vbs_graphics_controller_external_tb/uut/line_x1_next
add wave -noupdate -expand -group {internal interface} -group rasterizer -group line /vbs_graphics_controller_external_tb/uut/line_y0
add wave -noupdate -expand -group {internal interface} -group rasterizer -group line /vbs_graphics_controller_external_tb/uut/line_y0_next
add wave -noupdate -expand -group {internal interface} -group rasterizer -group line /vbs_graphics_controller_external_tb/uut/line_y1
add wave -noupdate -expand -group {internal interface} -group rasterizer -group line /vbs_graphics_controller_external_tb/uut/line_y1_next
add wave -noupdate -expand -group {internal interface} -group rasterizer -group line /vbs_graphics_controller_external_tb/uut/line_pixel_valid
add wave -noupdate -expand -group {internal interface} -group rasterizer -group line /vbs_graphics_controller_external_tb/uut/line_pixel_x
add wave -noupdate -expand -group {internal interface} -group rasterizer -group line /vbs_graphics_controller_external_tb/uut/line_pixel_y
add wave -noupdate -expand -group {internal interface} -group rasterizer -group circle /vbs_graphics_controller_external_tb/uut/circle_start
add wave -noupdate -expand -group {internal interface} -group rasterizer -group circle /vbs_graphics_controller_external_tb/uut/circle_start_next
add wave -noupdate -expand -group {internal interface} -group rasterizer -group circle /vbs_graphics_controller_external_tb/uut/circle_busy
add wave -noupdate -expand -group {internal interface} -group rasterizer -group circle /vbs_graphics_controller_external_tb/uut/circle_x_center
add wave -noupdate -expand -group {internal interface} -group rasterizer -group circle /vbs_graphics_controller_external_tb/uut/circle_x_center_next
add wave -noupdate -expand -group {internal interface} -group rasterizer -group circle /vbs_graphics_controller_external_tb/uut/circle_y_center
add wave -noupdate -expand -group {internal interface} -group rasterizer -group circle /vbs_graphics_controller_external_tb/uut/circle_y_center_next
add wave -noupdate -expand -group {internal interface} -group rasterizer -group circle /vbs_graphics_controller_external_tb/uut/circle_radius
add wave -noupdate -expand -group {internal interface} -group rasterizer -group circle /vbs_graphics_controller_external_tb/uut/circle_radius_next
add wave -noupdate -expand -group {internal interface} -group rasterizer -group circle /vbs_graphics_controller_external_tb/uut/circle_pixel_valid
add wave -noupdate -expand -group {internal interface} -group rasterizer -group circle /vbs_graphics_controller_external_tb/uut/circle_pixel_x
add wave -noupdate -expand -group {internal interface} -group rasterizer -group circle /vbs_graphics_controller_external_tb/uut/circle_pixel_y
add wave -noupdate -expand -group {internal interface} -group rasterizer -group rect /vbs_graphics_controller_external_tb/uut/rect_start
add wave -noupdate -expand -group {internal interface} -group rasterizer -group rect /vbs_graphics_controller_external_tb/uut/rect_start_next
add wave -noupdate -expand -group {internal interface} -group rasterizer -group rect /vbs_graphics_controller_external_tb/uut/rect_busy
add wave -noupdate -expand -group {internal interface} -group rasterizer -group rect /vbs_graphics_controller_external_tb/uut/rect_x
add wave -noupdate -expand -group {internal interface} -group rasterizer -group rect /vbs_graphics_controller_external_tb/uut/rect_x_next
add wave -noupdate -expand -group {internal interface} -group rasterizer -group rect /vbs_graphics_controller_external_tb/uut/rect_y
add wave -noupdate -expand -group {internal interface} -group rasterizer -group rect /vbs_graphics_controller_external_tb/uut/rect_y_next
add wave -noupdate -expand -group {internal interface} -group rasterizer -group rect /vbs_graphics_controller_external_tb/uut/rect_w
add wave -noupdate -expand -group {internal interface} -group rasterizer -group rect /vbs_graphics_controller_external_tb/uut/rect_w_next
add wave -noupdate -expand -group {internal interface} -group rasterizer -group rect /vbs_graphics_controller_external_tb/uut/rect_h
add wave -noupdate -expand -group {internal interface} -group rasterizer -group rect /vbs_graphics_controller_external_tb/uut/rect_h_next
add wave -noupdate -expand -group {internal interface} -group rasterizer -group rect /vbs_graphics_controller_external_tb/uut/rect_bw
add wave -noupdate -expand -group {internal interface} -group rasterizer -group rect /vbs_graphics_controller_external_tb/uut/rect_bw_next
add wave -noupdate -expand -group {internal interface} -group rasterizer -group rect /vbs_graphics_controller_external_tb/uut/rect_bh
add wave -noupdate -expand -group {internal interface} -group rasterizer -group rect /vbs_graphics_controller_external_tb/uut/rect_bh_next
add wave -noupdate -expand -group {internal interface} -group rasterizer -group rect /vbs_graphics_controller_external_tb/uut/rect_dx
add wave -noupdate -expand -group {internal interface} -group rasterizer -group rect /vbs_graphics_controller_external_tb/uut/rect_dx_next
add wave -noupdate -expand -group {internal interface} -group rasterizer -group rect /vbs_graphics_controller_external_tb/uut/rect_dy
add wave -noupdate -expand -group {internal interface} -group rasterizer -group rect /vbs_graphics_controller_external_tb/uut/rect_dy_next
add wave -noupdate -expand -group {internal interface} -group rasterizer -group rect /vbs_graphics_controller_external_tb/uut/rect_ls
add wave -noupdate -expand -group {internal interface} -group rasterizer -group rect /vbs_graphics_controller_external_tb/uut/rect_ls_next
add wave -noupdate -expand -group {internal interface} -group rasterizer -group rect /vbs_graphics_controller_external_tb/uut/rect_fill
add wave -noupdate -expand -group {internal interface} -group rasterizer -group rect /vbs_graphics_controller_external_tb/uut/rect_fill_next
add wave -noupdate -expand -group {internal interface} -group rasterizer -group rect /vbs_graphics_controller_external_tb/uut/rect_draw
add wave -noupdate -expand -group {internal interface} -group rasterizer -group rect /vbs_graphics_controller_external_tb/uut/rect_draw_next
add wave -noupdate -expand -group {internal interface} -group rasterizer -group rect /vbs_graphics_controller_external_tb/uut/rect_pixel_valid
add wave -noupdate -expand -group {internal interface} -group rasterizer -group rect /vbs_graphics_controller_external_tb/uut/rect_pixel_x
add wave -noupdate -expand -group {internal interface} -group rasterizer -group rect /vbs_graphics_controller_external_tb/uut/rect_pixel_y
add wave -noupdate -expand -group {internal interface} -group rasterizer -group rect /vbs_graphics_controller_external_tb/uut/rect_pixel_color
add wave -noupdate -expand -group {internal interface} -group rasterizer -group state /vbs_graphics_controller_external_tb/uut/state
add wave -noupdate -expand -group {internal interface} -group rasterizer -group state /vbs_graphics_controller_external_tb/uut/state_next
add wave -noupdate -expand -group {internal interface} -group rasterizer -group {current instruction} /vbs_graphics_controller_external_tb/uut/current_instruction
add wave -noupdate -expand -group {internal interface} -group rasterizer -group {current instruction} /vbs_graphics_controller_external_tb/uut/current_instruction_next
add wave -noupdate -expand -group {internal interface} -group rasterizer -group op_step /vbs_graphics_controller_external_tb/uut/op_step
add wave -noupdate -expand -group {internal interface} -group rasterizer -group op_step /vbs_graphics_controller_external_tb/uut/op_step_next
add wave -noupdate -expand -group {internal interface} -group rasterizer -group color /vbs_graphics_controller_external_tb/uut/primary_color
add wave -noupdate -expand -group {internal interface} -group rasterizer -group color /vbs_graphics_controller_external_tb/uut/primary_color_next
add wave -noupdate -expand -group {internal interface} -group rasterizer -group color /vbs_graphics_controller_external_tb/uut/secondary_color
add wave -noupdate -expand -group {internal interface} -group rasterizer -group color /vbs_graphics_controller_external_tb/uut/secondary_color_next
add wave -noupdate -expand -group {internal interface} -group rasterizer -group {read data} /vbs_graphics_controller_external_tb/uut/read_data_counter
add wave -noupdate -expand -group {internal interface} -group rasterizer -group {read data} /vbs_graphics_controller_external_tb/uut/read_data_counter_next
add wave -noupdate -expand -group {internal interface} -group rasterizer -group {read data} /vbs_graphics_controller_external_tb/uut/data_needed
add wave -noupdate -expand -group {internal interface} -group rasterizer -group {read data} /vbs_graphics_controller_external_tb/uut/data_needed_next
add wave -noupdate -expand -group {internal interface} -group rasterizer -group {current data} /vbs_graphics_controller_external_tb/uut/current_data
add wave -noupdate -expand -group {internal interface} -group rasterizer -group {current data} /vbs_graphics_controller_external_tb/uut/current_data_next
add wave -noupdate -expand -group {internal interface} -group rasterizer -group {current data} /vbs_graphics_controller_external_tb/uut/current_data_one
add wave -noupdate -expand -group {internal interface} -group rasterizer -group {current data} /vbs_graphics_controller_external_tb/uut/current_data_one_next
add wave -noupdate -expand -group {internal interface} -group rasterizer -group {current data} /vbs_graphics_controller_external_tb/uut/current_data_two
add wave -noupdate -expand -group {internal interface} -group rasterizer -group {current data} /vbs_graphics_controller_external_tb/uut/current_data_two_next
add wave -noupdate -expand -group {internal interface} -group rasterizer -group {current data} /vbs_graphics_controller_external_tb/uut/current_data_three
add wave -noupdate -expand -group {internal interface} -group rasterizer -group {current data} /vbs_graphics_controller_external_tb/uut/current_data_three_next
add wave -noupdate -expand -group {internal interface} -group rasterizer -group {current data} /vbs_graphics_controller_external_tb/uut/current_data_four
add wave -noupdate -expand -group {internal interface} -group rasterizer -group {current data} /vbs_graphics_controller_external_tb/uut/current_data_four_next
add wave -noupdate -expand -group {internal interface} -group rasterizer -group pattern /vbs_graphics_controller_external_tb/uut/pattern_0
add wave -noupdate -expand -group {internal interface} -group rasterizer -group pattern /vbs_graphics_controller_external_tb/uut/pattern_1
add wave -noupdate -expand -group {internal interface} -group rasterizer -group pattern /vbs_graphics_controller_external_tb/uut/pattern_1_next
add wave -noupdate -expand -group {internal interface} -group rasterizer -group pattern /vbs_graphics_controller_external_tb/uut/pattern_2
add wave -noupdate -expand -group {internal interface} -group rasterizer -group pattern /vbs_graphics_controller_external_tb/uut/pattern_2_next
add wave -noupdate -expand -group {internal interface} -group rasterizer -group pattern /vbs_graphics_controller_external_tb/uut/pattern_3
add wave -noupdate -expand -group {internal interface} -group rasterizer -group pattern /vbs_graphics_controller_external_tb/uut/pattern_3_next
add wave -noupdate -expand -group {internal interface} -group rasterizer -group pattern /vbs_graphics_controller_external_tb/uut/pattern_4
add wave -noupdate -expand -group {internal interface} -group rasterizer -group pattern /vbs_graphics_controller_external_tb/uut/pattern_4_next
add wave -noupdate -expand -group {internal interface} -group rasterizer -group pattern /vbs_graphics_controller_external_tb/uut/pattern_5
add wave -noupdate -expand -group {internal interface} -group rasterizer -group pattern /vbs_graphics_controller_external_tb/uut/pattern_5_next
add wave -noupdate -expand -group {internal interface} -group rasterizer -group pattern /vbs_graphics_controller_external_tb/uut/pattern_6
add wave -noupdate -expand -group {internal interface} -group rasterizer -group pattern /vbs_graphics_controller_external_tb/uut/pattern_6_next
add wave -noupdate -expand -group {internal interface} -group rasterizer -group pattern /vbs_graphics_controller_external_tb/uut/pattern_7
add wave -noupdate -expand -group {internal interface} -group rasterizer -group {double buffering} /vbs_graphics_controller_external_tb/uut/double_buffering
add wave -noupdate -expand -group {internal interface} -group rasterizer -group {double buffering} /vbs_graphics_controller_external_tb/uut/double_buffering_next
add wave -noupdate -expand -group {internal interface} -group rasterizer /vbs_graphics_controller_external_tb/uut/gfx_frame_sync_next
add wave -noupdate -expand -group {external interface} /vbs_graphics_controller_external_tb/uut/line_counter
add wave -noupdate -expand -group {external interface} /vbs_graphics_controller_external_tb/uut/line_counter_next
add wave -noupdate -expand -group {external interface} /vbs_graphics_controller_external_tb/uut/clk_cycle_counter
add wave -noupdate -expand -group {external interface} /vbs_graphics_controller_external_tb/uut/clk_cycle_counter_next
add wave -noupdate -expand -group {external interface} /vbs_graphics_controller_external_tb/uut/new_vbs_frame
add wave -noupdate -expand -group {external interface} /vbs_graphics_controller_external_tb/uut/new_vbs_frame_next
add wave -noupdate -expand -group {external interface} -expand -group mod_counter /vbs_graphics_controller_external_tb/uut/mod_counter
add wave -noupdate -expand -group {external interface} -expand -group mod_counter /vbs_graphics_controller_external_tb/uut/mod_counter_next
add wave -noupdate -expand -group {external interface} -expand -group vga_g_sig /vbs_graphics_controller_external_tb/uut/vga_g_sig
add wave -noupdate -expand -group {external interface} -expand -group vga_g_sig /vbs_graphics_controller_external_tb/uut/vga_g_sig_next
add wave -noupdate -expand -group {external interface} -expand -group vga_blank_sig /vbs_graphics_controller_external_tb/uut/vga_blank_sig
add wave -noupdate -expand -group {external interface} -expand -group vga_blank_sig /vbs_graphics_controller_external_tb/uut/vga_blank_sig_next
add wave -noupdate -expand -group {external interface} -expand -group vga_sync_sig /vbs_graphics_controller_external_tb/uut/vga_sync_sig
add wave -noupdate -expand -group {external interface} -expand -group vga_sync_sig /vbs_graphics_controller_external_tb/uut/vga_sync_sig_next
add wave -noupdate -expand -group {external interface} -expand -group vga_r/g/b /vbs_graphics_controller_external_tb/uut/vga_r
add wave -noupdate -expand -group {external interface} -expand -group vga_r/g/b /vbs_graphics_controller_external_tb/uut/vga_g
add wave -noupdate -expand -group {external interface} -expand -group vga_r/g/b /vbs_graphics_controller_external_tb/uut/vga_b
add wave -noupdate -expand -group {external interface} -expand -group entity /vbs_graphics_controller_external_tb/uut/vga_clk
add wave -noupdate -expand -group {external interface} -expand -group entity /vbs_graphics_controller_external_tb/uut/vga_sync_n
add wave -noupdate -expand -group {external interface} -expand -group entity /vbs_graphics_controller_external_tb/uut/vga_blank_n
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2957050000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 299
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
configure wave -timelineunits us
update
WaveRestoreZoom {0 ps} {42 ms}
