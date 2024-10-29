#Task 3

#arguments to the compiler (-2008 selects the VHDL 2008 standard)
VCOM_ARGS=-2008 -work work -suppress 1236

#additional arguments to vsim
VSIM_ARGS=-msgmode both

#list the VHDL input files here (notice the escape character!)
VHDL_FILES = \
	../math/src/math_pkg.vhd\
	../ram/src/ram_pkg.vhd\
	../ram/src/dp_ram_1c1r1w.vhd\
	../ram/src/fifo_1c1r1w.vhd\
	../lcd_graphics_controller/src/gfx_if_pkg.vhd\
	../gfx_util/src/gfx_util_pkg.vhd\
	../gfx_util/src/gfx_line.vhd\
	../gfx_util/src/gfx_rect.vhd\
	../gfx_util/src/gfx_circle.vhd\
	./src/frame_reader.vhd\
	./src/tpg.vhd\
	./src/vbs_graphics_controller_pkg.vhd\
	./src/vbs_graphics_controller.vhd\

#list the VHDL used during simulation (testbenches etc.)
TB_FILES = \
	./tb/vbs_graphics_controller_external_tb.vhd\
	./tb/vbs_graphics_controller_internal_tb.vhd

#the name of your testbench entity
TB_EXTERNAL = vbs_graphics_controller_external_tb
TB_INTERNAL = vbs_graphics_controller_internal_tb

#simulation time
SIM_TIME = 40 ms #-all

#wave_file
WAVE_FILE_EXTERNAL = scripts/wave_external.do
WAVE_FILE_INTERNAL = scripts/wave_internal.do

#compile everything
compile: clean log

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

sim_gui_external: clean compile
	vsim -do "vsim $(TB_EXTERNAL) $(VSIM_ARGS); do $(WAVE_FILE_EXTERNAL);run $(SIM_TIME)"

sim_gui_internal: clean compile
	vsim -do "vsim $(TB_INTERNAL) $(VSIM_ARGS); do $(WAVE_FILE_INTERNAL);run $(SIM_TIME)"

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
