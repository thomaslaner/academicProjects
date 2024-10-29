#Task 3

#arguments to the compiler (-2008 selects the VHDL 2008 standard)
VCOM_ARGS=-2008 -work work -suppress 1236

#additional arguments to vsim
VSIM_ARGS=-msgmode both

#list the VHDL input files here (notice the escape character!)
VHDL_FILES = \
	../math/src/math_pkg.vhd\
	./src/pll.vhd\
	../ram/src/ram_pkg.vhd\
	../ram/src/dp_ram_1c1r1w.vhd\
	../ram/src/fifo_1c1r1w.vhd\
	../prng/src/prng_pkg.vhd\
	../prng/src/prng.vho\
	../nes_controller/src/nes_controller_pkg.vhd\
	../lcd_graphics_controller/src/gfx_if_pkg.vhd\
	../lcd_graphics_controller/src/lcd_graphics_controller_pkg.vhd\
	../lcd_graphics_controller/src/lcd_graphics_controller.vho\
	../audio_cntrl/src/audio_cntrl_pkg.vhd\
	../audio_cntrl/src/audio_cntrl_2s.vhd\
	../audio_cntrl/src/audio_cntrl_top.vho\
	../synchronizer/src/sync_pkg.vhd\
	../synchronizer/src/sync.vhd\
	../dbg_port/src/dbg_port_pkg.vhd\
	../dbg_port/src/dbg_port.vhd\
	../dbg_port/src/dbg_port_top.vho\
	../display_switch/src/display_switch_pkg.vhd\
	../display_switch/src/display_switch.vhd\
	../ball_game/src/ball_game_pkg.vhd\
	../ball_game/src/ball_game.vhd\
	../ball_game/src/ball_game_ex1.vhd\
	../ssd_controller/src/ssd_controller_pkg.vhd\
	../ssd_controller/src/ssd_controller.vhd\
	./src/top.vhd

#list the VHDL used during simulation (testbenches etc.)
TB_FILES = \
	./tb/top_tb.vhd

#sdo (timing) file & vho (netlist) file
SDO_FILE=./quartus/simulation/modelsim/top_7_1200mv_85c_vhd_slow.sdo
VHO_FILE=./quartus/simulation/modelsim/top_7_1200mv_85c_slow.vho

#time resolution
TIME_RESOLUTION = 1ps

#the name of your testbench entity
TB = top_tb

#simulation time
SIM_TIME = -all

#wave_file
WAVE_FILE = scripts/wave.do
WAVE_FILE_POST = scripts/wave_post.do

#compile everything
compile: log

log: $(VHDL_FILES) $(TB_FILES)
	rm -f log
	vlib work | tee log
	for i in $(VHDL_FILES); do \
		vcom $(VCOM_ARGS) $$i | tee -a log;\
	done;
	for i in $(TB_FILES); do \
		vcom $(VCOM_ARGS) $$i | tee -a log;\
	done;
	@echo "--------------------------------------------------------------"
	@echo "--              Error and Warning Summary                   --"
	@echo "--------------------------------------------------------------"
	@cat log | grep 'Warning\|Error'
	@if [[ $$(grep "Error:" -m 1 log) ]]; then \
		echo "Compilation had errors!" \
		exit 1; \
	fi;

#show used vhdl_files
list_sources:
	@for i in $(VHDL_FILES) $(TB_FILES); do \
		echo $$i;\
	done;

#open sim_gui with given input wave_file and sim_time
sim_gui: clean compile
	vsim -do "vsim $(TB) $(VSIM_ARGS); do $(WAVE_FILE);run $(SIM_TIME)" 

#open sim_gui with given input wave_file and sim_time
sim_gui_post: clean compile
	vlib work
	vcom $(VCOM_ARGS) $(VHO_FILE)
	vcom $(VCOM_ARGS) $(TB_FILES)
	vsim -do "vsim $(TB) $(VSIM_ARGS) -t $(TIME_RESOLUTION) -sdftyp /uut=$(SDO_FILE); do $(WAVE_FILE_POST);run $(SIM_TIME)"

#clean everything
clean:
	rm -f transcript
	rm -f vsim.wlf
	rm -f log
	rm -fr work

.PHONY: compile
.PHONY: sim_gui
.PHONY: clean
.PHONY: list_sources
