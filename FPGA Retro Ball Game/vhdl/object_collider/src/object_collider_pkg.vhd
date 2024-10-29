library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package object_collider_pkg is
	
	constant COORDINATE_WIDTH : integer := 12;
	constant GAME_OBJECT_ID_WIDTH : integer := 2;
	constant GAME_OBJECT_SPEED_WIDTH : integer := 4;
	
	constant DIR_LEFT : std_logic := '0';
	constant DIR_RIGHT : std_logic := '1';
	
	type game_object_t is
	record
		id : std_logic_vector(GAME_OBJECT_ID_WIDTH-1 downto 0);		--intended to attach other information to a game object that is not directly relevant for the collision detection
		x : std_logic_vector(COORDINATE_WIDTH-1 downto 0);			
		y : std_logic_vector(COORDINATE_WIDTH-1 downto 0);
		w : std_logic_vector(COORDINATE_WIDTH-1 downto 0);
		h : std_logic_vector(COORDINATE_WIDTH-1 downto 0);
	end record;
	
	constant GAME_OBJECT_NULL : game_object_t := (
		id => (others=>'0'),
		x  => (others=>'0'),
		y  => (others=>'0'),
		w  => (others=>'0'),
		h  => (others=>'0')
	);
	
	component object_collider is
		generic (
			DISPLAY_WIDTH : integer := 400;
			DISPLAY_HEIGHT : integer := 240
		);
		port (
			clk : in std_logic;
			res_n : in std_logic;
			
			--to start movement operation
			start : in std_logic;																	--asserting signal for one clk_cycle starts player movement process (run)

			--to notify when movement complete
			done : out std_logic;																	--indicated that run is completed, stays high for one clk_cycle
			
			--final position of player	
			player_x : out std_logic_vector(COORDINATE_WIDTH-1 downto 0);							--final horizontal position of the player, valid between done going high and start of a new run
			player_y : out std_logic_vector(COORDINATE_WIDTH-1 downto 0);							--final vertical position of the player, valid between done going high and start of a new run
			
			--game object representing the player (must be valid exactly when start is asserted)
			player : in game_object_t;																--game_object representing the player

			--information about intended movement (must be valid exactly when start is asserted)
			player_speed : in std_logic_vector(GAME_OBJECT_SPEED_WIDTH-1 downto 0);					--horizontal speed of player, maximum horizontal distance it is allowed to be moved by object collider in one run
			player_dir : in std_logic;																--direction player moves in (1: right, 0: left)
			apply_movement : in std_logic;															--indicates if player should be moved horizontally during the run
			apply_gravity : in std_logic;															--indicated if player should be moved vertically during the run
			gravity : in std_logic_vector(GAME_OBJECT_SPEED_WIDTH-1 downto 0);						--vertical speed of player, maximum vertial distance it is allowed to be moved by the object collider during one run
			
			--to access "list" of all game objects placed on screen
			object : in game_object_t;																--must only be changed when object_valid is beeing asserted, otherwise it has to keep it's value
			object_valid : in std_logic;															--indicates that data at the object and object_is_blocking input is valid, must only be asserted for one clk_cycle and only as a response to an object request (object_req going high)
			object_eol : in std_logic;																--is asserted instead of object_valid to notify that all objects from the game object list have been processed, asserted for one clk_cycle only as a response to an object request (object_req going high)

			--to nofity about a detected collision
			object_req : out std_logic;																--used to request the next game object from the list, stays asserted until object_valid or object_eol go high
			collision_detected : out std_logic;														--indicates whether player colided with game object currently applied at object input, is only valid for one clk_cycle after object_valid has been asserted, for one clk_cycle
			object_is_blocking : in std_logic														--indicates that the by object supplied game_object is blocking the player, blocking objects stop the player and are not reported using the collision_detected output signal (-> is blocking, collision_detected is deasserted), must only be changed when object_valid is asserted										
		);
	end component;
	
	function go_to_slv(go : game_object_t) return std_logic_vector;
	function slv_to_go(slv : std_logic_vector) return game_object_t;
	function create_game_object(x,y,w,h : integer; id : std_logic_vector ) return game_object_t;
end package;



package body object_collider_pkg is

	function go_to_slv(go : game_object_t) return std_logic_vector is
	begin
		return go.id & go.x & go.y & go.w & go.h;
	end function;
	
	function slv_to_go(slv : std_logic_vector) return game_object_t is
		variable go : game_object_t;
	begin
		go.id := slv(go.id'length+go.x'length+go.y'length+go.w'length+go.h'length-1 downto go.x'length+go.y'length+go.w'length+go.h'length);
		go.x := slv(go.x'length+go.y'length+go.w'length+go.h'length-1 downto go.y'length+go.w'length+go.h'length);
		go.y := slv(go.y'length+go.w'length+go.h'length-1 downto go.w'length+go.h'length);
		go.w := slv(go.w'length+go.h'length-1 downto go.h'length);
		go.h := slv(go.h'length-1 downto 0);
		return go;
	end function;


	function create_game_object(x,y,w,h : integer; id : std_logic_vector ) return game_object_t is
		variable go : game_object_t;
	begin
		go.x := std_logic_vector(to_signed(x, COORDINATE_WIDTH));
		go.y := std_logic_vector(to_signed(y, COORDINATE_WIDTH));
		go.w := std_logic_vector(to_signed(w, COORDINATE_WIDTH));
		go.h := std_logic_vector(to_signed(h, COORDINATE_WIDTH));
		go.id := id;
		return go;
	end function;

end package body;


