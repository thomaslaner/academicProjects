library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ball_game_pkg.all;
use work.nes_controller_pkg.all;

entity ssd_controller is
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
end entity;

architecture beh of ssd_controller is

	type state_t is (READ_PLAYER_POINTS, CONV_THOUSANDS, CONV_HUNDREDS, CONV_TENS, CONV_ONES, SET_DISPLAY, BLINK_ON, BLINK_OFF);
	signal state, state_next : state_t;

	--used to save the calculated digits
	signal thousands_digit, thousands_digit_next : integer := 0;
	signal hundreds_digit, hundreds_digit_next : integer := 0;
	signal tens_digit, tens_digit_next : integer := 0;
	signal ones_digit, ones_digit_next : integer := 0;

	--player_points variables
	signal player_points_conv, player_points_conv_next : integer := 0; --used to calculate the digits
	signal player_points_og, player_points_og_next : integer := 0; --last calculated int values
	signal output_hex0, output_hex0_next : std_logic_vector(6 downto 0);
	signal output_hex1, output_hex1_next : std_logic_vector(6 downto 0);
	signal output_hex2, output_hex2_next : std_logic_vector(6 downto 0);
	signal output_hex3, output_hex3_next : std_logic_vector(6 downto 0);

	--used to adjust blinking
	signal blinkCount_Counter, blinkCount_Counter_next : integer := 0;
	signal blinkInterval_Counter, blinkInterval_Counter_next : integer := 0;

	--to calculate right 7 segment code depending on deliviered int-input
	function calc_sevSegDig (intNum : integer) return std_logic_vector is
		variable sevSegDigit : std_logic_vector(6 downto 0);
		begin
		case(intNum) is
			when 0 =>
				sevSegDigit := "1000000";
			when 1 =>
				sevSegDigit := "1111001";
			when 2 =>
				sevSegDigit := "0100100";
			when 3 =>
				sevSegDigit := "0110000";
			when 4 =>
				sevSegDigit := "0110001";
			when 5 =>
				sevSegDigit := "0010010";
			when 6 =>
				sevSegDigit := "0000010";
			when 7 =>
				sevSegDigit := "1111000";
			when 8 =>
				sevSegDigit := "0000000";
			when 9 =>
				sevSegDigit := "0010000";
			when others =>
				sevSegDigit := "1111111";
		end case ;
		return sevSegDigit;
	end function;
	
	--has to be used when invalid score would have to be displayed
	constant invalid_num : std_logic_vector(6 downto 0) := "0111111";

	--BONUS TASK 
	type state_running is (ANIMATION_1, ANIMATION_2, ANIMATION_3, ANIMATION_4);
	signal state_animation, state_animation_next : state_running;
	signal hex7_animation, hex7_animation_next, hex6_animation, hex6_animation_next : std_logic_vector(6 downto 0);
	signal animation_interval_counter, animation_interval_counter_next : integer := 0;

begin 
--Task 2
-- turn 0-3 off permanently
	/*
	hex0 <= "1111111";
	hex1 <= "1111111";
	hex2 <= "1111111";
	hex3 <= "1111111";
	*/
--process for led control_state config
	
	controls: process (controller)
	begin
		if ((controller.btn_left = '1') and (controller.btn_right = '1')) then
			hex5 <= "0000110";
			hex4 <= "0101111";
		elsif ((controller.btn_left = '1') and (controller.btn_right /= '1')) then
			hex5 <= "1000111";
			hex4 <= "0000110";	
		elsif ((controller.btn_left /= '1') and (controller.btn_right = '1')) then
			hex5 <= "0101111";
			hex4 <= "1101111";
		else
			hex5 <= "1111111";
			hex4 <= "1111111";
		end if;
	end process;
	
--process for led game_state config
	
	gamestate: process (game_state, clk, hex7_animation, hex6_animation)
	begin
		case game_state is
		when IDLE => 
			hex7 <= "0111111";
			hex6 <= "0111111";
		when RUNNING =>
			-- hex7 <= "0011100";
			-- hex6 <= "0100011";
			hex7 <= hex7_animation;
			hex6 <= hex6_animation;
		when PAUSED =>
			hex7 <= "1110000";
			hex6 <= "1000110";
		when GAME_OVER =>
			hex7 <= "1000010";
			hex6 <= "1000000";
		when others => 
			-- state that can't happen anyways, because rndm state is chosen if no state has been activated
			hex7 <= "1111111";
			hex6 <= "1111111";
		end case;
	end process;

--TASK 7
--state machine to calculate player points

	sync : process(clk, res_n)
	begin
	
		if res_n = '0' then
			state <= READ_PLAYER_POINTS;
			player_points_og <= 0;
			player_points_conv <= 0;
			thousands_digit <= 0;
			hundreds_digit <= 0;
			tens_digit <= 0;
			ones_digit <= 0;

			output_hex0 <= (others => '1');
			output_hex1 <= (others => '1');
			output_hex2 <= (others => '1');
			output_hex3 <= (others => '1');

		elsif rising_edge(clk) then
			state <= state_next;
			player_points_og <= player_points_og_next;
			player_points_conv <= player_points_conv_next;

			thousands_digit <= thousands_digit_next;
			hundreds_digit <= hundreds_digit_next;
			tens_digit <= tens_digit_next;
			ones_digit <= ones_digit_next;

			output_hex0 <= output_hex0_next;
			output_hex1 <= output_hex1_next;
			output_hex2 <= output_hex2_next;
			output_hex3 <= output_hex3_next;

			blinkInterval_Counter <= blinkInterval_Counter_next;
			blinkCount_Counter <= blinkCount_Counter_next;
		end if ;
		
	end process ; -- sync
	
	binary_to_bcd_conv : process(state, player_points, player_points_og, player_points_conv, thousands_digit, hundreds_digit, tens_digit, ones_digit, hex0, hex1, hex2, hex3, output_hex0, output_hex1, output_hex2, output_hex3, blinkInterval_Counter, blinkCount_Counter)
			
	begin

		state_next <= state;
		player_points_og_next <= player_points_og;
		player_points_conv_next <= player_points_conv;

		thousands_digit_next <= thousands_digit;
		hundreds_digit_next <= hundreds_digit;
		tens_digit_next <= tens_digit;
		ones_digit_next <= ones_digit;

		output_hex0_next <= output_hex0;
		output_hex1_next <= output_hex1;
		output_hex2_next <= output_hex2;
		output_hex3_next <= output_hex3;

		blinkInterval_Counter_next <= blinkInterval_Counter;
		blinkCount_Counter_next <= blinkCount_Counter;

		case(state) is
		
			when READ_PLAYER_POINTS =>

				thousands_digit_next <= 0;
				hundreds_digit_next <= 0;
				tens_digit_next <= 0;
				ones_digit_next <= 0;
				
				--if new value has been provided
				if to_integer(unsigned(player_points)) /= player_points_og then
					--if new value is valid or not
					if to_integer(unsigned(player_points)) > 9999 then
						output_hex0_next <= invalid_num;
						output_hex1_next <= invalid_num;
						output_hex2_next <= invalid_num;
						output_hex3_next <= invalid_num;
						state_next <= READ_PLAYER_POINTS;
					else
						player_points_conv_next <= to_integer(unsigned(player_points));
						state_next <= CONV_THOUSANDS;
					end if ;
				else
					state_next <= READ_PLAYER_POINTS;
				end if ;

			when CONV_THOUSANDS =>

					if player_points_conv > 999 then
						player_points_conv_next <= player_points_conv - 1000;
						thousands_digit_next <= thousands_digit +1;
					else
						state_next <= CONV_HUNDREDS;
					end if ;

			when CONV_HUNDREDS =>

					if player_points_conv > 99 then
						player_points_conv_next <= player_points_conv - 100;
						hundreds_digit_next <= hundreds_digit +1;
					else
						state_next <= CONV_TENS;
					end if ;

			when CONV_TENS =>
			
				if player_points_conv > 9 then
					player_points_conv_next <= player_points_conv - 10;
					tens_digit_next <= tens_digit +1;
				else
					state_next <= CONV_ONES;
				end if ;

			when CONV_ONES =>
			
				ones_digit_next <= player_points_conv;
				state_next <= SET_DISPLAY;

			when SET_DISPLAY =>
				--if new value causes blinking
				if (to_integer(unsigned(player_points))) > (player_points_og + 25) then
					state_next <= BLINK_ON;
				else
					state_next <= READ_PLAYER_POINTS;
					output_hex0_next <= calc_sevSegDig(thousands_digit);
					output_hex1_next <= calc_sevSegDig(hundreds_digit);
					output_hex2_next <= calc_sevSegDig(tens_digit);
					output_hex3_next <= calc_sevSegDig(ones_digit);
					
				end if ;

				player_points_og_next <= to_integer(unsigned(player_points));
			
			WHEN BLINK_ON  =>
				
				output_hex0_next <= calc_sevSegDig(thousands_digit);
				output_hex1_next <= calc_sevSegDig(hundreds_digit);
				output_hex2_next <= calc_sevSegDig(tens_digit);
				output_hex3_next <= calc_sevSegDig(ones_digit);
				
				if blinkCount_Counter = BLINK_COUNT then
					state_next <= READ_PLAYER_POINTS;
					blinkCount_Counter_next <= 0;
				else
				
					if blinkInterval_Counter = BLINK_INTERVAL-1 then
						state_next <= BLINK_OFF;
						blinkCount_Counter_next <= blinkCount_Counter +1;
						blinkInterval_Counter_next <= 0;
					else
						state_next <= BLINK_ON;
						blinkInterval_Counter_next <= blinkInterval_Counter +1;
					end if ;
				end if ; 

			when BLINK_OFF =>

				output_hex0_next <= "0000000";
				output_hex1_next <= "0000000";
				output_hex2_next <= "0000000";
				output_hex3_next <= "0000000";
				
				if blinkInterval_Counter = BLINK_INTERVAL-1 then
					state_next <= BLINK_ON;
					blinkInterval_Counter_next <= 0; 
				else
					state_next <= BLINK_OFF;
					blinkInterval_Counter_next <= blinkInterval_Counter +1;
				end if ;
			
				when others =>
					state_next <= READ_PLAYER_POINTS;
		end case ;

	end process ; -- binary_to_bcd_conv

--set hex0-3 according to the output of the state machine
	
	hex3 <= output_hex0;
	hex2 <= output_hex1;
	hex1 <= output_hex2;
	hex0 <= output_hex3;
	
--state machine for bonus task

sync_animation : process(clk,res_n,game_state)
begin
	if ((res_n = '0') or (game_state /= RUNNING)) then
		state_animation <= ANIMATION_1;
		hex7_animation <= "0011100";
		hex6_animation <= "0100011";
		animation_interval_counter <= 0;
	elsif (rising_edge(clk) and (game_state = RUNNING)) then
		state_animation <= state_animation_next;
		hex7_animation <= hex7_animation_next;
		hex6_animation <= hex6_animation_next;
		animation_interval_counter <= animation_interval_counter_next;
	end if ;

end process ; -- sync_animation

running_animation : process(state_animation, hex7_animation, hex6_animation, animation_interval_counter)
begin
	state_animation_next <= state_animation;
	hex7_animation_next <= hex7_animation;
	hex6_animation_next <= hex6_animation;
	animation_interval_counter_next <= animation_interval_counter;
	case state_animation is
		
		when ANIMATION_1 =>
			hex7_animation_next <= "0011100";
			hex6_animation_next <= "0100011";
			
			if animation_interval_counter = ANIMATION_INTERVAL-1 then
				state_animation_next <= ANIMATION_2;
				animation_interval_counter_next <= 0;
			else
				state_animation_next <= state_animation;
				animation_interval_counter_next <= animation_interval_counter +1;
			end if ;

		when ANIMATION_2 =>
			hex7_animation_next <= "0011100";
			hex6_animation_next <= "0011100";

			if animation_interval_counter = ANIMATION_INTERVAL-1 then
				state_animation_next <= ANIMATION_3;
				animation_interval_counter_next <= 0;
			else
				state_animation_next <= state_animation;
				animation_interval_counter_next <= animation_interval_counter +1;
			end if ;

		when ANIMATION_3 =>
			hex7_animation_next <= "0100011";
			hex6_animation_next <= "0011100";

			if animation_interval_counter = ANIMATION_INTERVAL-1 then
				state_animation_next <= ANIMATION_4;
				animation_interval_counter_next <= 0;
			else
				state_animation_next <= state_animation;
				animation_interval_counter_next <= animation_interval_counter +1;
			end if ;

		when ANIMATION_4 =>
			hex7_animation_next <= "0100011";
			hex6_animation_next <= "0100011";

			if animation_interval_counter = ANIMATION_INTERVAL-1 then
				state_animation_next <= ANIMATION_1;
				animation_interval_counter_next <= 0;
			else
				state_animation_next <= state_animation;
				animation_interval_counter_next <= animation_interval_counter +1;
			end if ;

		when others =>
			-- state that can't happen anyways
			state_animation_next <= ANIMATION_1;
	end case ;
end process ; -- running_animation

end architecture;

