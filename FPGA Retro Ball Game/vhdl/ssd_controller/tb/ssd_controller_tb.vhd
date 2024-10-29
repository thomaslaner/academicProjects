--Task 7

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;

use work.ball_game_pkg.all;
use work.nes_controller_pkg.all;

entity ssd_controller_tb is
end entity;

architecture bench of ssd_controller_tb is
--component ssd_controller
    component ssd_controller is 
	generic ( 
		BLINK_INTERVAL : integer;			--determines durations of a flash in clk_cycles
		BLINK_COUNT : integer; 				--number of times hex display should flash BLINK_INTERVAL*clk_cycles long (1 => 1x off 1x on)
        ANIMATION_INTERVAL : integer        --determines duration of animation steps for hex6,hex7
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

--tb definitions
    --ssd_controller
    signal clk : std_logic;
    signal res_n : std_logic;
    signal game_state : ball_game_state_t;
    signal controller : nes_buttons_t;
    signal player_points : std_logic_vector(15 downto 0);
    signal hex0, hex1, hex2, hex3, hex4, hex5, hex6, hex7 : std_logic_vector(6 downto 0);
    
    --clk
    constant CLK_PERIOD : time := 20 ns; -- 1/50000000 * 1000000000
    signal stop_clk : boolean := false;
    constant tb_player_points : std_logic_vector(15 downto 0) := "0000011000101011"; --1234+(11807845 mod 500)=1579 in binary

begin

--UUT
    uut: ssd_controller
    generic map ( 
		BLINK_INTERVAL => 10000, --12500000,       --0.25=1/50000000
		BLINK_COUNT => 3,
        ANIMATION_INTERVAL => 4  --4 clk_cycles for simulation			     
    )
    port map (
        clk => clk,
		res_n => res_n,
		game_state => game_state,
		controller => controller,
		player_points => player_points,
		hex0 => hex0,
        hex1 => hex1, 
        hex2 => hex2, 
        hex3 => hex3,
        hex4 => hex4,
        hex5 => hex5,
        hex6 => hex6,
        hex7 => hex7
    );

--CLK_GENERATOR
    clk_generator : process
    begin
        clk_loop : while not stop_clk loop
            clk <= '0', '1' after CLK_PERIOD/2;
            wait for CLK_PERIOD;
        end loop ; -- clk_loop
    end process ; -- clk_generator

--stimulus

    stimulus : process
    begin
        report "reset";
        res_n <= '0';
        wait for 50*CLK_PERIOD;
        player_points <= (others => '0');
        hex0 <= (others => '1');
        hex1 <= (others => '1');
        hex2 <= (others => '1');
        hex3 <= (others => '1');
        controller <= (others => '0');
        res_n <= '1';
        report "simulation starting";

        -- player_points <= (others => '0');
        -- wait for 20*clk_period;

        player_points <= tb_player_points;

        -- wait for 20*clk_period;
        -- player_points <= "0000000000000100";

        wait for 2 sec;
        stop_clk <= true;
        report "simulation complete";
        wait;
        finish;
    end process ; -- stimulus

end bench ; -- bench

