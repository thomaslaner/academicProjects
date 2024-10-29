onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /lcd_graphics_controller_tb/clk
add wave -noupdate /lcd_graphics_controller_tb/res_n
add wave -noupdate /lcd_graphics_controller_tb/display_clk
add wave -noupdate /lcd_graphics_controller_tb/display_res_n
add wave -noupdate /lcd_graphics_controller_tb/tb_write_file

add wave -noupdate -expand -group instruction_interface /lcd_graphics_controller_tb/gfx_instr
add wave -noupdate -expand -group instruction_interface /lcd_graphics_controller_tb/gfx_instr_wr
add wave -noupdate -expand -group instruction_interface /lcd_graphics_controller_tb/gfx_instr_full
add wave -noupdate -expand -group instruction_interface /lcd_graphics_controller_tb/gfx_data
add wave -noupdate -expand -group instruction_interface /lcd_graphics_controller_tb/gfx_data_wr
add wave -noupdate -expand -group instruction_interface /lcd_graphics_controller_tb/gfx_data_full
add wave -noupdate -expand -group instruction_interface /lcd_graphics_controller_tb/gfx_frame_sync

add wave -noupdate -expand -group external_interface_to_the_sram /lcd_graphics_controller_tb/sram_dq
add wave -noupdate -expand -group external_interface_to_the_sram /lcd_graphics_controller_tb/sram_addr
add wave -noupdate -expand -group external_interface_to_the_sram /lcd_graphics_controller_tb/sram_ub_n
add wave -noupdate -expand -group external_interface_to_the_sram /lcd_graphics_controller_tb/sram_lb_n
add wave -noupdate -expand -group external_interface_to_the_sram /lcd_graphics_controller_tb/sram_we_n
add wave -noupdate -expand -group external_interface_to_the_sram /lcd_graphics_controller_tb/sram_ce_n
add wave -noupdate -expand -group external_interface_to_the_sram /lcd_graphics_controller_tb/sram_oe_n

add wave -noupdate -expand -group external_interface_to_the_LCD /lcd_graphics_controller_tb/nclk
add wave -noupdate -expand -group external_interface_to_the_LCD /lcd_graphics_controller_tb/hd
add wave -noupdate -expand -group external_interface_to_the_LCD /lcd_graphics_controller_tb/vd
add wave -noupdate -expand -group external_interface_to_the_LCD /lcd_graphics_controller_tb/den
add wave -noupdate -expand -group external_interface_to_the_LCD /lcd_graphics_controller_tb/r
add wave -noupdate -expand -group external_interface_to_the_LCD /lcd_graphics_controller_tb/g
add wave -noupdate -expand -group external_interface_to_the_LCD /lcd_graphics_controller_tb/b
add wave -noupdate -expand -group external_interface_to_the_LCD /lcd_graphics_controller_tb/grest

add wave -noupdate -expand -group serial_interface_to_LCD_driver_IC /lcd_graphics_controller_tb/sda
add wave -noupdate -expand -group serial_interface_to_LCD_driver_IC /lcd_graphics_controller_tb/sclk
add wave -noupdate -expand -group serial_interface_to_LCD_driver_IC /lcd_graphics_controller_tb/scen

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
