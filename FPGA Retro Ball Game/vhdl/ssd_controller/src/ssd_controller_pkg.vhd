library ieee;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

use work.ball_game_pkg.all;
use work.nes_controller_pkg.all;

package ssd_controller_pkg is

	component ssd_controller is 
	generic ( 
		BLINK_INTERVAL : integer;			--determines durations of a flash in clk_cycles
		BLINK_COUNT : integer; 				--number of times hex display should flash BLINK_INTERVAL*clk_cycles long (1 => 1x off 1x on)
		ANIMATION_INTERVAL : integer		--determines duration of animation steps for hex6,hex7
	);
	port (
		clk: in std_logic;
		res_n: in std_logic;
		game_state: in ball_game_state_t;
		controller: in nes_buttons_t;
		player_points : in std_logic_vector(15 downto 0);
		hex0, hex1, hex2, hex3, hex4, hex5, hex6, hex7: out std_logic_vector(6 downto 0)
	);
	end component;

end ssd_controller_pkg;