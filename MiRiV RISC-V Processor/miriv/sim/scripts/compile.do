vlib work
vmap work work

vcom -work work -2008 ../vhdl/mem_pkg.vhd
vcom -work work -2008 ../vhdl/core_pkg.vhd
vcom -work work -2008 ../vhdl/op_pkg.vhd
vcom -work work -2008 ../vhdl/alu.vhd
vcom -work work -2008 ../vhdl/memu.vhd
vcom -work work -2008 ../vhdl/regfile.vhd
vcom -work work -2008 ../vhdl/ctrl.vhd
vcom -work work -2008 ../vhdl/fwd.vhd
vcom -work work -2008 ../vhdl/fetch.vhd
vcom -work work -2008 ../vhdl/decode.vhd
vcom -work work -2008 ../vhdl/exec.vhd
vcom -work work -2008 ../vhdl/mem.vhd
vcom -work work -2008 ../vhdl/wb.vhd
vcom -work work -2008 ../vhdl/pipeline.vhd

set fexists [file exists "../vhdl/cache/cache_pkg.vhd"]
if  {$fexists} {
	vcom -work work -2008 ../vhdl/cache/cache_pkg.vhd
	vcom -work work -2008 ../vhdl/cache/repl.vhd
	vcom -work work -2008 ../vhdl/cache/ram/single_clock_rw_ram_pkg.vhd
	vcom -work work -2008 ../vhdl/cache/ram/single_clock_rw_ram.vhd
	vcom -work work -2008 ../vhdl/cache/data_st_1w.vhd
	vcom -work work -2008 ../vhdl/cache/data_st.vhd
	vcom -work work -2008 ../vhdl/cache/mgmt_st_1w.vhd
	vcom -work work -2008 ../vhdl/cache/mgmt_st.vhd
}
vcom -work work -2008 ../vhdl/cache/cache.vhd

vcom -work work -2008 ../vhdl/core.vhd

vmap bootloader bootloader

vcom -work work -2008 tb/tb.vhd
