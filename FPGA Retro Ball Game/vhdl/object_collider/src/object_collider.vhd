
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use work.math_pkg.all;

use work.object_collider_pkg.all;

entity object_collider is
	generic(
		DISPLAY_WIDTH    : integer := 400;
		DISPLAY_HEIGHT   : integer := 240
	);
	port (
		clk   : in std_logic;
		res_n : in std_logic;
		
		--control signals
		start : in std_logic;
		done  : out std_logic;
		apply_movement : in std_logic;
		apply_gravity : in std_logic;
		
		-- player information
		player : in game_object_t;
		player_speed : in std_logic_vector(GAME_OBJECT_SPEED_WIDTH-1 downto 0);
		player_dir : in std_logic;
		gravity : in std_logic_vector(GAME_OBJECT_SPEED_WIDTH-1 downto 0);
		player_x : out std_logic_vector(COORDINATE_WIDTH-1 downto 0);
		player_y : out std_logic_vector(COORDINATE_WIDTH-1 downto 0);

		-- block information
		object : in game_object_t;
		object_req : out std_logic;
		object_valid : in std_logic;
		object_is_blocking : in std_logic;
		object_eol : in std_logic;

		collision_detected  : out std_logic
	);
end entity;

architecture arch of object_collider is 
	type state_t is (
		IDLE, READY,
		MOVE_PLAYER_GRAVITY, G_REQ_OBJ, G_WAIT_OBJ, G_CHECK_OBJ,
		MOVE_PLAYER, P_REQ_OBJ, P_WAIT_OBJ, P_CHECK_OBJ);
	signal state : state_t;
	
	signal player_int : game_object_t;
	signal gravity_int : std_logic_vector(gravity'range);
	signal player_speed_int : std_logic_vector(player_speed'range);
	signal player_dir_int : std_logic;
	
	signal apply_movement_int : std_logic;
	signal apply_gravity_int : std_logic;
	
	signal collision : std_logic;
	signal blocked : std_logic;

begin

--state machine
	sync : process(clk, res_n)
	begin
		if (res_n = '0') then
			state <= IDLE;
			done <= '0';
			object_req <= '0';
			gravity_int <= (others=>'0');
			player_int <= GAME_OBJECT_NULL;
			player_speed_int <= (others=>'0');
			player_dir_int <= '0';
			blocked <= '0';
			player_x <= (others=>'0');
			player_y <= (others=>'0');
			collision_detected <= '0';
			apply_movement_int <= '0';
			apply_gravity_int <= '0';
		elsif (rising_edge(clk)) then
			collision_detected <= '0';
			done <= '0';
			case state is
				when IDLE =>
					done <= '0';
					object_req <= '0';
					if(start = '1') then
						state <= MOVE_PLAYER_GRAVITY;
						gravity_int <= gravity;
						player_speed_int <= player_speed;
						player_dir_int <= player_dir;
						player_int <= player;
						apply_movement_int <= apply_movement;
						apply_gravity_int <= apply_gravity;
						blocked <= '0';
					end if;
			--vertical movement
				when MOVE_PLAYER_GRAVITY =>
					if (apply_gravity_int = '0' or unsigned(gravity_int) = 0 or blocked = '1') then
					--if gravity should be overlooked, if gravity is zero or if the player is blocked switch directly to the horizontal movement
						state <= MOVE_PLAYER;
						blocked <= '0';
					else
					--if gravity can be applied, apply it and request a new object
						state <= G_REQ_OBJ;
						blocked <= '0';
						player_int.y <= std_logic_vector(signed(player_int.y) + 1);
						gravity_int <= std_logic_vector(unsigned(gravity_int) - 1);
					end if;
				
				when G_REQ_OBJ =>
				--request new object
					object_req <= '1';
					state <= G_WAIT_OBJ;
				
				when G_WAIT_OBJ =>
					if (object_eol = '1') then
					--if end of list is reached, apply gravity until it is depleted
						state <= MOVE_PLAYER_GRAVITY;
						object_req <= '0';
					elsif (object_valid = '1') then
					--if new valid object has been passed
						state <= G_CHECK_OBJ;
						object_req <= '0';
					end if;
					
				when G_CHECK_OBJ =>
					if (collision = '1') then
					--if player collides with the new object
						if (object_is_blocking = '1') then
						--if the object blocks the player, lift him up by one y
							player_int.y <= std_logic_vector(signed(player_int.y) - 1);
							blocked <= '1';
						else
						--notify about collision
							collision_detected <= '1';
						end if;
					end if;
					state <= G_REQ_OBJ;
			--horizontal movement
				when MOVE_PLAYER =>
				--check if player is able to move further, if so move him in the intended direction
					if (apply_movement_int = '0') then
						--if player shouldn't be moved horizontally during the run
						state <= READY;
						blocked <= '0';
					elsif (player_dir_int = DIR_LEFT and signed(player_int.x) <= 0) then
						--if player cannot go further left
						state <= READY;
						player_int.x <= (others=>'0');
						blocked <= '0';
					elsif (player_dir_int = DIR_RIGHT and signed(player_int.x) + signed(player_int.w) >= DISPLAY_WIDTH) then
						--if player cannot go further right
						state <= READY;
						player_int.x <= std_logic_vector(DISPLAY_WIDTH - signed(player_int.w));
						blocked <= '0';
					elsif(unsigned(player_speed_int) = 0 or blocked = '1') then
						--if player is blocked or player's speed is 0
						state <= READY;
						blocked <= '0';
					else
					--if player can move further in the passed direction
						state <= P_REQ_OBJ;
						blocked <= '0';
						if (player_dir_int = '1') then
						--if player's direction is to the right
							player_int.x <= std_logic_vector(signed(player_int.x) + 1);
						else
						--if player's direction is to the left
							player_int.x <= std_logic_vector(signed(player_int.x) - 1);
						end if;
						--decrease player speed with every new step, used as counter to how far player should move with one button press
						player_speed_int <= std_logic_vector(unsigned(player_speed_int) - 1);
					end if;
				
				when P_REQ_OBJ =>
				--request a new object
					object_req <= '1';
					state <= P_WAIT_OBJ;
				
				when P_WAIT_OBJ =>
					if (object_eol = '1') then
					--if end of object list is recognized, move the player until it's speed is depleted
						state <= MOVE_PLAYER;
						object_req <= '0';
					elsif (object_valid = '1') then
					--if new object is available, check it
						state <= P_CHECK_OBJ;
						object_req <= '0';
					end if;
					
				when P_CHECK_OBJ =>
					if (collision = '1') then
					--if a collision with the new object is recognized
						if (object_is_blocking = '1') then
						--if the new object is blocking the player
							if (player_dir_int = '1') then
							--move player away from the object by 1 so that they don't overlap
								player_int.x <= std_logic_vector(signed(player_int.x) - 1);
							else
								player_int.x <= std_logic_vector(signed(player_int.x) + 1);
							end if;
							blocked <= '1';
							--used to check if the player can move further
						else
						--if the object isn't blocking notify the core about a collision
							collision_detected <= '1';
							
						end if;
					end if;
					state <= P_REQ_OBJ;
			--end
				when READY =>
				--if player can't move further - end
					state <= IDLE;
					done <= '1';
					player_x <= player_int.x;
					player_y <= player_int.y;
				
			end case;
		end if;
	end process;

--collision_check_process
	--checks if player is colliding with current object, returns collision '1' if so	
	collide : process(all)
	begin
		collision <= '0';
		if (signed(player_int.x) < signed(object.x) + signed(object.w) and
			signed(player_int.x) + signed(player_int.w) > signed(object.x) and
			signed(player_int.y) < signed(object.y) + signed(object.h) and
			signed(player_int.y) + signed(player_int.h) > signed(object.y)) then
			collision <= '1';
		end if;
	end process; 

end architecture;
