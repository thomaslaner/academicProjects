--game tbs

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.gfx_if_pkg.all;
use work.math_pkg.all;
use work.nes_controller_pkg.all;
use work.audio_cntrl_pkg.all;
use work.object_collider_pkg.all;
use work.ball_game_pkg.all;
use work.prng_pkg.all;
use work.ram_pkg.all;

use std.textio.all;
use std.env.finish;

entity ball_game_ex2_tb is
end ball_game_ex2_tb;

architecture sim of ball_game_ex2_tb is

    constant clk_period : time := 20 ns;

    signal clk : std_logic := '1';
    signal res_n : std_logic;

    signal gfx_instr : std_logic_vector(7 downto 0);
    signal gfx_instr_wr : std_logic;
    signal gfx_instr_full : std_logic;
    signal gfx_data : std_logic_vector(15 downto 0);
    signal gfx_data_wr : std_logic;
    signal gfx_data_full : std_logic;
    signal gfx_frame_sync : std_logic;
    signal controller : nes_buttons_t;
    signal synth_cntrl  : synth_cntrl_vec_t(0 to 1);
    signal player_points : std_logic_vector(15 downto 0);
    signal game_state : ball_game_state_t;
	signal stop_clk : boolean := false;

begin

 	clk_process:process is
	begin
	
		while not stop_clk loop
			clk <= '1';
			wait for clk_period/2;
			clk <= '0';
			wait for clk_period/2;
		end loop;

	end process;

    UUT : entity work.ball_game(arch_ex2)
    generic map (
        DISPLAY_WIDTH => 400,
        DISPLAY_HEIGHT => 240
    )
    port map (
        clk => clk,
        res_n => res_n,
        gfx_instr => gfx_instr,
        gfx_instr_wr => gfx_instr_wr,
        gfx_instr_full => gfx_instr_full,
        gfx_data => gfx_data,
        gfx_data_wr => gfx_data_wr, 
        gfx_data_full => gfx_data_full, 
        gfx_frame_sync => gfx_frame_sync,
        controller => controller,
        synth_cntrl => synth_cntrl,
        player_points => player_points,
        game_state => game_state
        
    );
    
    SEQUENCER_PROC : process
        variable start_button_needed : std_logic := '1';
        variable change_dir_counter : integer := 0;
        variable start_button_asserted_counter : integer := 0;
    begin
        res_n <= '0';
        gfx_instr_full <= '0';
        gfx_data_full <= '0';
        gfx_frame_sync <= '0';
        controller <= (others => '0');
        wait for clk_period * 20;
        res_n <= '1';
        wait for clk_period * 2;

        while true loop

            if (gfx_instr = GFX_INSTR_FRAME_SYNC) then
                
                gfx_frame_sync <= '1';
                wait for clk_period;
                gfx_frame_sync <= '0';
            
            elsif game_state = RUNNING then

                if change_dir_counter = 80 then
                    controller.btn_right <= '1';
                    controller.btn_left <= '0';
                elsif change_dir_counter = 160 then
                    controller.btn_right <= '0';
                    controller.btn_left <= '1';
                    change_dir_counter := 0;
                end if;

                change_dir_counter := change_dir_counter +1;
            
            elsif start_button_needed = '1' then
                controller.btn_start <= '1';
                start_button_needed := '0';
                start_button_asserted_counter := 0;
                
            elsif start_button_asserted_counter = 20 then
                controller.btn_start <= '0';

                if (game_state = IDLE) or (game_state = GAME_OVER) then
                    start_button_needed := '1';
                end if;
            
            end if;

            if start_button_asserted_counter < 20 then
                start_button_asserted_counter := start_button_asserted_counter +1;
            end if;

            wait for clk_period;
        end loop;

        wait for clk_period * 850;
        stop_clk <= true;
        
        wait;

    end process;

end architecture;
