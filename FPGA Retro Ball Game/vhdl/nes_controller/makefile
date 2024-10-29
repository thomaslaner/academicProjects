#Task 3

#arguments to the compiler (-2008 selects the VHDL 2008 standard)
VCOM_ARGS=-2008 -work work -suppress 1236

#additional arguments to vsim
VSIM_ARGS=-msgmode both

#list the VHDL input files here (notice the escape character!)
VHDL_FILES = \
	./src/nes_controller_pkg.vhd\
	./src/nes_controller.vhd
	
#list the VHDL used during simulation (testbenches etc.)
TB_FILES = \
	./tb/nes_controller_tb.vhd

#the name of your testbench entity
TB = nes_controller_tb

#simulation time
SIM_TIME = -all

#wave_file
WAVE_FILE = scripts/wave.do

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

sim: compile
	vsim -c -do "vsim -onfinish exit $(TB) $(VSIM_ARGS); run $(SIM_TIME)"

sim_gui: compile
	vsim -do "vsim $(TB) $(VSIM_ARGS); do $(WAVE_FILE);run $(SIM_TIME)"


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
