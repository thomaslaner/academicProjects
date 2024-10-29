library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package audio_cntrl_pkg is

	--GENERAL:
	--allows to contorl individual synthesizers (2 synthesizers are available)
	
	--INPUTS:
	--is the only input derived directly from other components

	--HIGH_TIME & LOW_TIME:
	--if high_time and low_time are 1 -> maximum frequency output signal is generated -> the actuals samples
	--which are sent to the DAC switch between the maximum and mimimum valua at every sampling period
	--changing these values while a sound is playing has no effect

	--PLAY:
	--determines length of created PWM signal, high active, on rising_edge synthesizer reads current value of 
	--high_time and low_time and uses these values to generate the PWM signal until play returns to zero
	--to change the PWM signal, PLAY must be low for >= 1 clk_cycle of the 12MHz input clk of the audio_controller

	--CLK_HURDLES
	--the core uses a 3-stage synchronizer on the play signals to ensure a correct clk domain crossing (from clk to 
	--12MHz clk).
	--high_time and low_time are not synchronized -> whenever these values are changed, they must stay stable long enough
	--to ensure that the audio controller can sample them correctly. 
	--synchronisation delay!

	type synth_cntrl_t is record 
		play : std_logic; 
		high_time : std_logic_vector(7 downto 0);								
		low_time : std_logic_vector(7 downto 0);
	end record;

	type synth_cntrl_vec_t is array(natural range <>) of synth_cntrl_t;

	component audio_cntrl_2s is
		port (
			clk : in std_logic;
			res_n : in std_logic;
			wm8731_sdat : inout std_logic;
			wm8731_sclk : inout std_logic;
			wm8731_xck : out std_logic;
			wm8731_dacdat : out std_logic;
			wm8731_daclrck : out std_logic;
			wm8731_bclk : out std_logic;
			synth_cntrl : in synth_cntrl_vec_t(0 to 1)
		);
	end component;
end package;

