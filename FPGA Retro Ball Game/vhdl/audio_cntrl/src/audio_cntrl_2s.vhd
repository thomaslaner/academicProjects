
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.audio_cntrl_pkg.all;

entity audio_cntrl_2s is
	port (
		clk   : in std_logic;									--has to be a 12MHz clk, recieves it from pll
		res_n : in std_logic;
		
		--clk output signal for the wm8731
		wm8731_xck     : out std_logic;							--has to be a 12MHz clk, recieves it from pll
		
		--cgf interface to wm8731: i2c configuration interface
		wm8731_sdat : inout std_logic;							--data signal of the I2C bus of the wm8731's control interface
		wm8731_sclk : inout std_logic;							--clk signal of the I2C bus of the wm8731's control interface
		
		--data interface to wm8731: digital audio interface 
		wm8731_dacdat  : out std_logic;							--DAC's digital autio data input of the wm8731's digital audio interface
		wm8731_daclrck : out std_logic; 						--DAC's sample rate left/right clk of the wm8731's digital audio interface
		wm8731_bclk    : out std_logic;							--digital audio bit clk of the wm8731's digital audio interface
		
		--internal interface to the synthesizers
		synth_cntrl : in synth_cntrl_vec_t(0 to 1)				--synthesizer control signals, only these are delivered directly by other components
	);
end entity;


architecture arch of audio_cntrl_2s is
	component audio_cntrl_top is
		port (
			synth_cntrl_0_high_time : IN std_logic_vector(7 DOWNTO 0);
			synth_cntrl_1_high_time : IN std_logic_vector(7 DOWNTO 0);
			synth_cntrl_0_play : IN std_logic;
			synth_cntrl_1_play : IN std_logic;
			synth_cntrl_0_low_time : IN std_logic_vector(7 DOWNTO 0);
			synth_cntrl_1_low_time : IN std_logic_vector(7 DOWNTO 0);
			clk : IN std_logic;
			res_n : IN std_logic;
			wm8731_xck : OUT std_logic;
			wm8731_sdat : INOUT std_logic;
			wm8731_sclk : INOUT std_logic;
			wm8731_dacdat : OUT std_logic;
			wm8731_daclrck : OUT std_logic;
			wm8731_bclk : OUT std_logic
		);
	end component;
begin
	--this is just a wrapper for the precompiled audio controller
	audio_cntrl_inst : audio_cntrl_top
	port map (
		synth_cntrl_0_high_time => synth_cntrl(0).high_time,
		synth_cntrl_1_high_time =>  synth_cntrl(1).high_time,
		synth_cntrl_0_play => synth_cntrl(0).play,
		synth_cntrl_1_play => synth_cntrl(1).play,
		synth_cntrl_0_low_time => synth_cntrl(0).low_time,
		synth_cntrl_1_low_time => synth_cntrl(1).low_time,
		clk => clk,
		res_n => res_n,
		wm8731_xck => wm8731_xck,
		wm8731_sdat => wm8731_sdat,
		wm8731_sclk => wm8731_sclk,
		wm8731_dacdat => wm8731_dacdat,
		wm8731_daclrck => wm8731_daclrck,
		wm8731_bclk => wm8731_bclk
	);

end architecture;


