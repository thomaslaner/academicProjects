.PHONY: all clean compile sim sim_gui

all: compile

clean:
	rm -fr work
	rm -f transcript
	rm -f *.wlf
	rm -f modelsim.ini

compile: clean
	@vsim -c -do "do scripts/compile.do;quit -f"

sim: clean compile
	@vsim -c -t ps work.tb -quiet -do "run -all;quit -f" | grep -E "\*\*|Errors"

sim_gui: clean compile
	@vsim -t ps work.tb -quiet -do "do scripts/wave.do;run -all;wave zoom full"
