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

architecture arch_ex2 of ball_game is 

    --constants
        --player
            constant PLAYER_BALL_RADIUS : integer := 6;
            constant PLAYER_SPEED : integer := 6;

        --game
            constant INITIAL_GAME_SPEED : integer := 1;
            constant INITIAL_GRAVITY : integer := 4;    
            constant GAME_DIFFICULTY : integer := 1000; --increasing this value makes the game easier since game_speed is increased slower

        --display instantiation
            constant BG_COLOR    : std_logic_vector(15 downto 0) := x"0000";
            constant BRICK_COLOR : std_logic_vector(15 downto 0) := x"ff03";
            constant BRICK_PATTERN_P0 : std_logic_vector(15 downto 0) := x"1293";
            constant BRICK_PATTERN_P1 : std_logic_vector(15 downto 0) := x"0008";
            constant ITEM_PATTERN_P0 : std_logic_vector(15 downto 0) := x"3311";
            constant ITEM_PATTERN_P1 : std_logic_vector(15 downto 0) := x"0001";

        --block constants
            constant GAMEOBJ_DATA_WIDTH : integer := 50; --GAME_OBJECT_ID_WIDTH + (COORDINATE_WIDTH * 4)
            constant BLOCK_WIDTH : integer := 16;
            constant BLOCK_DISTANCE_IDLE : integer := 36;
            constant BLOCK_HEIGHT : integer := 12;
            constant BLOCK_ID : std_logic_vector(1 downto 0) := "00";

        --item constants
            constant HIGHEST_VALUE_ITEM_SIZE : integer := 4;
            constant HIGHEST_VALUE_ITEM_ID : std_logic_vector(1 downto 0) := "11";
            constant HIGH_VALUE_ITEM_SIZE : integer := 6;
            constant HIGH_VALUE_ITEM_ID : std_logic_vector(1 downto 0) := "10";
            constant NORMAL_VALUE_ITEM_SIZE : integer := 8;
            constant NORMAL_VALUE_ITEM_ID : std_logic_vector(1 downto 0) := "01";

        --audio constants
            constant ITEM_COLLECTED_DURATION_COUNTER_MAX : integer := 10000000;
            constant GAME_OVER_DURATION_COUNTER_MAX :integer := 26000000;
            constant GAME_OVER_LOWER_FREQ_DURATION_COUNTER : integer := 12500000;

    --signals
        --game state control
            type game_state_internal is (
                RESET, 
                INIT_GFX_CNTRL, INIT_GFX_CNTRL_WAIT,
                SEED_PRNG,
                CLEAN_BLOCKS,

                IDLE_CREATE_BLOCKS_1, IDLE_CREATE_BLOCKS_2, IDLE_CREATE_BLOCKS_3, IDLE_CREATE_BLOCKS_4,
                IDLE_RANDOM_PLAYER_POSITION,
                IDLE_RANDOM_PLAYER_DIRECTION,

                RUNNING_PLAYER_UPDATE, 
                RUNNING_BLOCK_UPDATE_1, RUNNING_BLOCK_UPDATE_2, RUNNING_BLOCK_UPDATE_3,
                RUNNING_CREATE_BLOCKS_1, RUNNING_CREATE_BLOCKS_2, RUNNING_CREATE_BLOCKS_3, RUNNING_CREATE_BLOCKS_4,
                RUNNING_RANDOM_PLAYER_POSITION,
                RUNNING_RANDOM_ITEM_VALUE, RUNNING_RANDOM_ITEM_POSITION, RUNNING_SAVE_ITEM,
                
                PERFORM_FRAME_SYNC, WAIT_FRAME_SYNC,
                MOVE_PLAYER, MOVE_PLAYER_WAIT_OBJECT_REQ, MOVE_PLAYER_OBJECT_VALID, MOVE_PLAYER_WAIT_CYCLE, MOVE_PLAYER_CHECK_COLLISION, MOVE_PLAYER_DONE,
                CLEAR_SCREEN,
                DRAW_OBJECT, DRAW_OBJECT_INSTR, DRAW_OBJECT_X, DRAW_OBJECT_Y, DRAW_OBJECT_WIDTH, DRAW_OBJECT_HEIGHT,
                DRAW_PLAYER_INSTR, DRAW_PLAYER_X, DRAW_PLAYER_Y, DRAW_PLAYER_RADIUS,
                FRAME_DONE

            );

            signal internal_game_state, internal_game_state_next : game_state_internal;
            signal game_state_next : ball_game_state_t;
            signal game_rotations, game_rotations_next : integer := 0;
            signal game_speed, game_speed_next : integer := INITIAL_GAME_SPEED;
            signal player_points_internal, player_points_internal_next : std_logic_vector(player_points'range);
            signal gravity, gravity_next : integer := INITIAL_GRAVITY;
            signal start_button_released, start_button_released_next : std_logic := '1';   
            
        --item handling
            signal item, item_next : game_object_t;

        --player handling
            signal player, player_next : game_object_t;
            signal random_player_direction, random_player_direction_next : std_logic;
            signal change_direction_counter, change_direction_counter_next : integer := 10;

        --object fifo 
            --block_fifo_signals
                signal object_fifo_out_sig : std_logic;
                signal object_fifo_out_data : std_logic_vector(GAMEOBJ_DATA_WIDTH-1 downto 0);
                signal object_fifo_in_sig : std_logic;
                signal object_fifo_in_data : std_logic_vector(GAMEOBJ_DATA_WIDTH-1 downto 0);
                signal object_fifo_empty : std_logic;

            --block_fifo_handling
                signal current_object, current_object_next : game_object_t;
                signal object_processed_counter, object_processed_counter_next : integer := 0;
                signal object_fifo_counter, object_fifo_counter_next : integer := 0;
                signal lowest_height, lowest_height_next : integer := 0;
                signal initial_lowest_height, initial_lowest_height_next : integer := 0;

        --game object creation
            signal current_y_pos, current_y_pos_next    : integer := 0;
            signal current_x_pos, current_x_pos_next    : integer := 0;
            signal current_width, current_width_next    : integer := 0;
                
        --gfx controller initializer
            signal init_gfx_instr : std_logic_vector(GFX_INSTR_WIDTH-1 downto 0);
            signal init_gfx_instr_wr : std_logic;
            signal init_gfx_data : std_logic_vector(GFX_DATA_WIDTH-1 downto 0);
            signal init_gfx_data_wr : std_logic;
            signal gfx_initializer_start : std_logic;
            signal gfx_initializer_busy : std_logic;

        --object collider related signals 
            
            signal game_object_cnt, game_object_cnt_next : integer := 0;
            signal current_oc_object, current_oc_object_next : game_object_t;

            --to start movement operation (in)
            signal oc_start : std_logic;                                                                --asserting signal for one clk_cycle starts player movement process (run)

            --to notify when movement complete (out)        
            signal oc_done : std_logic;                                                                 --indicated that run is completed, stays high for one clk_cycle

            --information about intended movement (must be valid exactly when start is asserted) (in)
            signal oc_apply_movement : std_logic;                                                       --indicates if player should be moved horizontally during the run
            signal oc_apply_gravity : std_logic;                                                        --indicated if player should be moved vertically during the run
            signal oc_player_dir : std_logic;                                                           --direction player moves in (1: right, 0: left)
            signal oc_player_speed : std_logic_vector(GAME_OBJECT_SPEED_WIDTH-1 downto 0);              --horizontal speed of player, maximum horizontal distance it is allowed to be moved by object collider in one run
        
            --to access "list" of all game objects placed on screen (in)
            signal oc_object_valid : std_logic;                                                         --indicates that data at the object and object_is_blocking input is valid, asserted for one clk_cycle only as a response to an object request (object_req going high)
            signal oc_object_eol : std_logic;                                                           --is asserted instead of object_valid to notify that all objects from the game object list have been processed, asserted for one clk_cycle only as a response to an object request (object_req going high)
            signal oc_object : game_object_t;                                                           --must only be changed when object_valid is beeing asserted, otherwise it has to keep it's value
            signal oc_object_is_blocking : std_logic;                                                   --indicates that the by oc_object supplied game_object is blocking the player, blocking objects stop the player and are not reported using the collision_detected output signal (-> is blocking, collision_detected is deasserted), must only be changed when object_valid is asserted
            
            --to notify about a detected collision or to request the next game object (out)
            signal oc_object_req : std_logic;                                                           --used to request the next game object from the list, stays asserted until object_valid or object_eol go high
            signal oc_collision_detected : std_logic;                                                   --indicates whether player colided with game object currently applied at oc_object input, is only valid for one clk_cycle after object_valid has been asserted, for one clk_cycle

            --finasl position of player (out)
            signal oc_player_x : std_logic_vector(COORDINATE_WIDTH-1 downto 0);                         --final horizontal position of the player, valid between done going high and start of a new run
            signal oc_player_y : std_logic_vector(COORDINATE_WIDTH-1 downto 0);                         --final vertical position of the player, valid between done going high and start of a new run

        --random number generation related signals
            signal prdata : std_logic_vector(9 downto 0);                                               --data generated by prng and used by the random number generator
            signal load_seed : std_logic;                                                               --is used to load a new seed into prng (high -> enable)
            signal random_x_pos, random_value_r_0_3, random_value_r_1_10, random_value_r_2_5, random_direction, random_item_value : std_logic_vector(log2c(DISPLAY_WIDTH)-1 downto 0);
            signal random_x_pos_valid, random_value_r_0_3_valid, random_value_r_1_10_valid, random_value_r_2_5_valid, random_direction_valid, random_item_value_valid : std_logic;
   
        --audio
            signal item_collected_audio_counter, item_collected_audio_counter_next : integer := ITEM_COLLECTED_DURATION_COUNTER_MAX;
            signal game_over_audio_counter, game_over_audio_counter_next : integer := GAME_OVER_DURATION_COUNTER_MAX;
            signal synth_cntrl_0_sig, synth_cntrl_1_sig : std_logic := '0';

    begin
    
--object fifo instantiation
    object_fifo_inst : fifo_1c1r1w
		generic map (
			DEPTH => 128,
			DATA_WIDTH => GAMEOBJ_DATA_WIDTH
		)
		port map (
			clk => clk,
			res_n => res_n,

			rd_data => object_fifo_out_data,
			rd => object_fifo_out_sig,

			wr_data => object_fifo_in_data,
			wr => object_fifo_in_sig,

			empty => object_fifo_empty,
			full => open,
			half_full => open
		);
    
    --drive output from internal latch
    player_points <= player_points_internal;

--sync
    sync : process(clk, res_n)
    begin
        if (res_n = '0') then
            --game state control
            game_state <= IDLE;
            internal_game_state <= RESET;
            player_points_internal <= (others=>'0');
            game_rotations <= 0;
            game_speed <= 1;
            gravity <= INITIAL_GRAVITY;

            --item handling
            item <= GAME_OBJECT_NULL;

            --player handling
            player <= GAME_OBJECT_NULL;
            random_player_direction <= '0';
            change_direction_counter <= 10;                         --used to ensure that direction doesn't change to often in IDLE state

            --object_fifo_handling
            game_object_cnt <= 0;
            object_fifo_counter <= 0;
            object_processed_counter <= 0;
            current_object <= GAME_OBJECT_NULL;

            --game object creation
            current_y_pos <= 0;
            current_x_pos <= 0;
            current_width <= 0;
            
            --used to check if blocks are ready for new line
            lowest_height <= 0;
            initial_lowest_height <= 0;

            --used to check if start button has been pressed, or is still pressed
            start_button_released <= '1';
        
            --audio signals            
            item_collected_audio_counter <= ITEM_COLLECTED_DURATION_COUNTER_MAX;
            game_over_audio_counter <= GAME_OVER_DURATION_COUNTER_MAX;

            current_oc_object <= GAME_OBJECT_NULL;

        elsif (rising_edge(clk)) then
            internal_game_state <= internal_game_state_next;
            player <= player_next;
            item <= item_next;
            game_object_cnt <= game_object_cnt_next;
            player_points_internal <= player_points_internal_next;
            random_player_direction <= random_player_direction_next;
            object_fifo_counter <= object_fifo_counter_next;
            object_processed_counter <= object_processed_counter_next;
            current_y_pos <= current_y_pos_next;
            current_x_pos <= current_x_pos_next;
            current_width <= current_width_next;
            current_object <= current_object_next;
            game_state <= game_state_next;
            change_direction_counter <= change_direction_counter_next;
            game_rotations <= game_rotations_next;
            game_speed <= game_speed_next;
            lowest_height <= lowest_height_next;
            initial_lowest_height <= initial_lowest_height_next;
            gravity <= gravity_next;
            start_button_released <= start_button_released_next;
            item_collected_audio_counter <= item_collected_audio_counter_next;
            game_over_audio_counter <= game_over_audio_counter_next;
            current_oc_object <= current_oc_object_next;
        end if;
    end process;

--next_state_logic
    next_state_logic : process(all)
        
        -- utility functions which write to the graphics controller and change the state according to passed inputs
            procedure write_gfx_data_and_goToState(data : std_logic_vector; state : game_state_internal) is
            begin
                if (gfx_data_full = '0') then
                    gfx_data(data'range) <= data;
                    gfx_data_wr <= '1';
                    internal_game_state_next <= state;
                end if;
            end procedure;
            
            procedure write_gfx_instr_and_goToState(instr : std_logic_vector; state : game_state_internal) is
            begin
                if (gfx_instr_full = '0') then
                    gfx_instr <= instr;
                    gfx_instr_wr <= '1';
                    internal_game_state_next <= state;
                end if;
            end procedure;
    begin
  
    --default assignments
        -- default next state signals 
            internal_game_state_next <= internal_game_state;
            item_next <= item;
            player_next <= player;
            game_object_cnt_next <= game_object_cnt;
            player_points_internal_next <= player_points_internal;
            random_player_direction_next <= random_player_direction;
            object_fifo_counter_next <= object_fifo_counter;
            object_processed_counter_next <= object_processed_counter;
            current_x_pos_next <= current_x_pos;
            current_y_pos_next <= current_y_pos;
            current_width_next <= current_width;
            current_object_next <= current_object;
            game_state_next <= game_state;
            change_direction_counter_next <= change_direction_counter;
            game_rotations_next <= game_rotations;
            game_speed_next <= game_speed;
            lowest_height_next <= lowest_height;
            initial_lowest_height_next <= initial_lowest_height;
            gravity_next <= gravity;
            current_oc_object_next <= current_oc_object;
        
        -- defines next position of player (player_ball_radius stays the same)
            player_next.w <= std_logic_vector(to_unsigned(2*PLAYER_BALL_RADIUS+1,COORDINATE_WIDTH));
            player_next.h <= std_logic_vector(to_unsigned(2*PLAYER_BALL_RADIUS+1,COORDINATE_WIDTH));

        -- signals that core comes out of reset
            load_seed <= '0';
        
        -- reset interface to graphics controller
            gfx_instr <= (others=>'0');
            gfx_instr_wr <= '0';
            gfx_data <= (others=>'0');
            gfx_data_wr <= '0';
            
        --object collider signal
            oc_start <= '0';
            oc_object_valid <= '0';
            oc_object_eol <= '0';
            oc_player_dir <= '0';
            oc_player_speed <= std_logic_vector(to_unsigned(4, GAME_OBJECT_SPEED_WIDTH));
            oc_apply_gravity <= '0';
            oc_apply_movement <= '0';
            
            gfx_initializer_start <= '0';

        --block_fifo_signals
            object_fifo_in_sig <= '0';
            object_fifo_in_data <= (others => '0');
            object_fifo_out_sig <= '0';

        --audio signals
            synth_cntrl_0_sig <= '0';
            synth_cntrl_1_sig <= '0';
            item_collected_audio_counter_next <= item_collected_audio_counter;
            game_over_audio_counter_next <= game_over_audio_counter;

    --start_button_released signal
        --signal to check if start_button has been pressed multiple times
            if (controller.btn_start = '0') then
                start_button_released_next <= '1';
            else 
                start_button_released_next <= start_button_released;
            end if;

    --audio signals
            
            --control item_collected audio
            if (item_collected_audio_counter < ITEM_COLLECTED_DURATION_COUNTER_MAX) then
                item_collected_audio_counter_next <= item_collected_audio_counter +1;
                synth_cntrl_0_sig <= '1';
            end if;
            
            --control game_over audio (increasing frequency)
            if (game_over_audio_counter < GAME_OVER_DURATION_COUNTER_MAX) then
                game_over_audio_counter_next <= game_over_audio_counter +1;
            
                if (game_over_audio_counter < GAME_OVER_LOWER_FREQ_DURATION_COUNTER) then

                    synth_cntrl_0_sig <= '1';

                elsif (game_over_audio_counter >= (GAME_OVER_LOWER_FREQ_DURATION_COUNTER + 1000000))  then

                    synth_cntrl_1_sig <= '1';

                end if;

            end if;
    --internal_game_state - state machine
        case internal_game_state is
        --GFX_INIT
                when RESET =>
                    internal_game_state_next <= INIT_GFX_CNTRL;
                    game_state_next <= IDLE;
                
                when INIT_GFX_CNTRL =>
                    gfx_initializer_start <= '1';
                    internal_game_state_next <= INIT_GFX_CNTRL_WAIT;
                
                when INIT_GFX_CNTRL_WAIT =>
                    gfx_instr <= init_gfx_instr;
                    gfx_instr_wr <= init_gfx_instr_wr;
                    gfx_data <= init_gfx_data;
                    gfx_data_wr <= init_gfx_data_wr;
                    if (gfx_initializer_busy = '0') then
                        internal_game_state_next <= SEED_PRNG;
                    end if;
                
                when SEED_PRNG =>
                    -- initialize the PRNG
                    load_seed <= '1';
                    internal_game_state_next <= IDLE_CREATE_BLOCKS_1;
                    current_y_pos_next <= BLOCK_DISTANCE_IDLE;

        --CLEAN

                when CLEAN_BLOCKS =>
                    --clean the fifo from blocks created in the running or idle state
                    if object_fifo_empty = '0' then
                        object_fifo_out_sig <= '1';
                        internal_game_state_next <= CLEAN_BLOCKS;
                        object_fifo_counter_next <= object_fifo_counter -1;
                    else                

                        if game_state = IDLE then
                            internal_game_state_next <= IDLE_CREATE_BLOCKS_1;
                        else
                            internal_game_state_next <= RUNNING_CREATE_BLOCKS_1;
                        end if;
            
                    end if;
        --IDLE - block creation
                when IDLE_CREATE_BLOCKS_1 =>
                --set initial rndm x-value
                    if random_value_r_0_3_valid = '1' then
                        current_x_pos_next <= to_integer(unsigned(random_value_r_0_3)) * BLOCK_WIDTH;
                        internal_game_state_next <= IDLE_CREATE_BLOCKS_2;
                    else 
                        internal_game_state_next <= IDLE_CREATE_BLOCKS_1;
                    end if;
                
                when IDLE_CREATE_BLOCKS_2 =>
                --set rndm width
                    if random_value_r_1_10_valid = '1' then
                        
                        if ((current_x_pos + to_integer(unsigned(random_value_r_1_10) * BLOCK_WIDTH)) >= DISPLAY_WIDTH) then   
                            current_width_next <=  DISPLAY_WIDTH - current_x_pos;
                        else 
                            current_width_next <=  to_integer(unsigned(random_value_r_1_10)) * BLOCK_WIDTH;
                        end if;
                        internal_game_state_next <= IDLE_CREATE_BLOCKS_3;
                    else 
                        internal_game_state_next <= IDLE_CREATE_BLOCKS_2;
                    end if;

                when IDLE_CREATE_BLOCKS_3 =>
                    --save new block to block_fifo and increase object_fifo_counter
                    object_fifo_in_sig <= '1';
                    object_fifo_in_data <= go_to_slv(create_game_object(current_x_pos, current_y_pos, current_width, BLOCK_HEIGHT, BLOCK_ID));
                    object_fifo_counter_next <= object_fifo_counter + 1;
                    internal_game_state_next <= IDLE_CREATE_BLOCKS_4;

                when IDLE_CREATE_BLOCKS_4 => 
                    object_fifo_in_sig <= '0';
                    if random_value_r_2_5_valid = '1' then

                        if (current_x_pos + (to_integer(unsigned(random_value_r_2_5)) * BLOCK_WIDTH) + current_width) >= DISPLAY_WIDTH then
                            --if line has been filled fully

                            current_x_pos_next <= 0;
                            
                            if current_y_pos + BLOCK_DISTANCE_IDLE + BLOCK_HEIGHT > 240 then
                                --when all lines have been filled
                                internal_game_state_next <= IDLE_RANDOM_PLAYER_POSITION;
                                current_y_pos_next <= BLOCK_DISTANCE_IDLE;
                            else    
                                --if not all lines have been filled, switch to next line
                                internal_game_state_next <= IDLE_CREATE_BLOCKS_1;
                                current_y_pos_next <= current_y_pos + BLOCK_DISTANCE_IDLE + BLOCK_HEIGHT;
                            end if;
                        else
                            --get next x_pos for next block in line
                            current_x_pos_next <= current_x_pos + (to_integer(unsigned(random_value_r_2_5)) * BLOCK_WIDTH) + current_width;
                            internal_game_state_next <= IDLE_CREATE_BLOCKS_2;
                        end if;
                        
                    else 
                        --if rndm value is not yet valid
                        internal_game_state_next <= IDLE_CREATE_BLOCKS_4;
                    end if;
        --IDLE - random player position & direction
                when IDLE_RANDOM_PLAYER_POSITION => 
                    --defines random x position and sets the y position to the highest possible one
                    if random_x_pos_valid = '1' then

                        -- reset player position
                        player_next.x <= "000" & random_x_pos;
                        player_next.y <= std_logic_vector(to_unsigned(0, player.y'length));
                        internal_game_state_next <= IDLE_RANDOM_PLAYER_DIRECTION;
                        change_direction_counter_next <= 10;                  
                    else 
                        internal_game_state_next <= IDLE_RANDOM_PLAYER_POSITION;
                    end if;

                when IDLE_RANDOM_PLAYER_DIRECTION =>
                    if change_direction_counter = 10 then
                        
                        change_direction_counter_next <= 0;

                        if random_direction_valid = '1' then
                            if (to_integer(unsigned(random_direction)) <= 5) then
                                random_player_direction_next <= '0';
                            else 
                                random_player_direction_next <= '1';
                            end if;

                            internal_game_state_next <= PERFORM_FRAME_SYNC; 
                        else 
                            internal_game_state_next <= IDLE_RANDOM_PLAYER_DIRECTION;
                        end if;
                    else
                        internal_game_state_next <= PERFORM_FRAME_SYNC;
                        change_direction_counter_next <= change_direction_counter +1;
                    end if;
        --RUNNING - player update

            when RUNNING_PLAYER_UPDATE => 

                player_next.y <=  std_logic_vector(to_unsigned((to_integer(unsigned(player.y)) - game_speed), player.y'length));
                internal_game_state_next <= RUNNING_BLOCK_UPDATE_1;
            
        --RUNNING - block update

                when RUNNING_BLOCK_UPDATE_1 =>
                    object_fifo_in_sig <= '0';

                    --check if all objects have been processed
                    if object_processed_counter = object_fifo_counter then
                        object_processed_counter_next <= 0;
                        
                        --blocks:
                        --  240-12*5 = 180
                        --  180/5 = 36
                        --  36+12+12 = 60 (height of seconds row when first one should be drawn)
                        --  240-60 = 180
                        if (lowest_height <= 180) and (initial_lowest_height > 180) then
                            --if a block has been deleted, a new row of blocks has to be created
                            internal_game_state_next <= RUNNING_CREATE_BLOCKS_1;
                        else
                            --otherwise no action is necessary
                            internal_game_state_next <= PERFORM_FRAME_SYNC;
                        end if;

                        lowest_height_next <= 0;
                        initial_lowest_height_next <= 0;
                    else
                        --if not all objects have been processed, read next element from fifo
                        object_fifo_out_sig <= '1';
                        object_fifo_in_sig <= '0';
                        object_processed_counter_next <= object_processed_counter +1;
                        internal_game_state_next <= RUNNING_BLOCK_UPDATE_2;
                    end if;

                when RUNNING_BLOCK_UPDATE_2 =>

                    current_object_next <= slv_to_go(object_fifo_out_data);
                    object_fifo_out_sig <= '0';

                    --if the y-coordinate is still bigger that the game_speed in order to know
                    --if the element would not touch the end of the screen after the next movement operation
                    if ((to_integer(unsigned(slv_to_go(object_fifo_out_data).y))) > game_speed) then
                        current_object_next.y <= std_logic_vector(to_unsigned((to_integer(unsigned(slv_to_go(object_fifo_out_data).y)) - game_speed), current_object.y'length));
                                
                        --set new lowest height if smaller than earlier height (since lowest height = biggest value -> > for comparison)
                        if ((to_integer(unsigned(slv_to_go(object_fifo_out_data).y)) - game_speed) > lowest_height) then
                            lowest_height_next <= (to_integer(unsigned(slv_to_go(object_fifo_out_data).y)) - game_speed);
                            initial_lowest_height_next <= to_integer(unsigned(slv_to_go(object_fifo_out_data).y)); 
                        end if;

                        internal_game_state_next <= RUNNING_BLOCK_UPDATE_3;
                    else
                        --decrement object_fifo counter to show that there is one element less in the fifo
                        object_fifo_counter_next <= object_fifo_counter -1;
                        internal_game_state_next <= RUNNING_BLOCK_UPDATE_1;
                    end if;
                    
                when RUNNING_BLOCK_UPDATE_3 =>
                    --write the not deleted elements back into the fifo
                    object_fifo_in_sig <= '1';
                    object_fifo_in_data <= go_to_slv(current_object);
                    internal_game_state_next <= RUNNING_BLOCK_UPDATE_1;

        --RUNNING - create objects
            --block creation
                when RUNNING_CREATE_BLOCKS_1 =>
                --set initial rndm x-value
                    if random_value_r_0_3_valid = '1' then
                        current_x_pos_next <= to_integer(unsigned(random_value_r_0_3)) * BLOCK_WIDTH;
                        internal_game_state_next <= RUNNING_CREATE_BLOCKS_2;
                    else 
                        internal_game_state_next <= RUNNING_CREATE_BLOCKS_1;
                    end if;
                
                when RUNNING_CREATE_BLOCKS_2 =>
                --set rndm width
                    if random_value_r_1_10_valid = '1' then
                        
                        if ((current_x_pos + to_integer(unsigned(random_value_r_1_10) * BLOCK_WIDTH)) >= DISPLAY_WIDTH) then   
                            current_width_next <=  DISPLAY_WIDTH - current_x_pos;
                        else 
                            current_width_next <=  to_integer(unsigned(random_value_r_1_10)) * BLOCK_WIDTH;
                        end if;
                        internal_game_state_next <= RUNNING_CREATE_BLOCKS_3;
                    else 
                        internal_game_state_next <= RUNNING_CREATE_BLOCKS_2;
                    end if;
                
                when RUNNING_CREATE_BLOCKS_3 =>
                    --save new block to block_fifo and increase object_fifo_counter
                    object_fifo_in_sig <= '1';
                    object_fifo_in_data <= go_to_slv(create_game_object(current_x_pos, (DISPLAY_HEIGHT - BLOCK_HEIGHT), current_width, BLOCK_HEIGHT, BLOCK_ID));
                    object_fifo_counter_next <= object_fifo_counter + 1; 
                    internal_game_state_next <= RUNNING_CREATE_BLOCKS_4;

                when RUNNING_CREATE_BLOCKS_4 => 
                    object_fifo_in_sig <= '0';
                    if random_value_r_2_5_valid = '1' then

                        if (current_x_pos + (to_integer(unsigned(random_value_r_2_5)) * BLOCK_WIDTH) + current_width) >= DISPLAY_WIDTH then
                            --if line has been filled fully

                            current_x_pos_next <= 0;

                            if game_rotations = 0 then
                                internal_game_state_next <= RUNNING_RANDOM_PLAYER_POSITION;
                            else 
                                internal_game_state_next <= RUNNING_RANDOM_ITEM_VALUE;
                            end if;
                
                        else
                            --get next x_pos for next block in line
                            current_x_pos_next <= current_x_pos + (to_integer(unsigned(random_value_r_2_5)) * BLOCK_WIDTH) + current_width;
                            internal_game_state_next <= RUNNING_CREATE_BLOCKS_2;
                        end if;
                        
                    else 
                        --if rndm value is not yet valid
                        internal_game_state_next <= RUNNING_CREATE_BLOCKS_4;
                    end if;

            --random player position
                when RUNNING_RANDOM_PLAYER_POSITION => 
                    --defines random x position and sets the y position to the highest possible one
                    if random_x_pos_valid = '1' then

                        -- reset player position
                        player_next.x <= "000" & random_x_pos;
                        player_next.y <= std_logic_vector(to_unsigned(0, player.y'length));
                        internal_game_state_next <= PERFORM_FRAME_SYNC;                  
                    else 
                        internal_game_state_next <= RUNNING_RANDOM_PLAYER_POSITION;
                    end if;

            --random item value
                when RUNNING_RANDOM_ITEM_VALUE => 
                    --defines the value of the item
                    if random_item_value_valid = '1' then

                        if to_integer(unsigned(random_item_value)) = 16 then
                            --highest value item with propability of 1/16
                            item_next.id <= HIGHEST_VALUE_ITEM_ID;
                        elsif to_integer(unsigned(random_item_value)) > 13 then
                            --high value item with propability of 1/8 = 2/16
                            item_next.id <= HIGH_VALUE_ITEM_ID;
                        else 
                            --other item with propability of 13/16 
                            item_next.id <= NORMAL_VALUE_ITEM_ID;
                        end if;

                        internal_game_state_next <= RUNNING_RANDOM_ITEM_POSITION;                  
                    else 
                        internal_game_state_next <= RUNNING_RANDOM_ITEM_VALUE;
                    end if;

                when RUNNING_RANDOM_ITEM_POSITION =>
                    --defines the x_pos of the item
                    if random_x_pos_valid = '1' then

                        --set item position based on rndm value
                        item_next.x <= "000" & random_x_pos;

                        --set item parameters according to calculated type
                        if item.id = HIGHEST_VALUE_ITEM_ID then
                            item_next.y <= std_logic_vector(to_unsigned((DISPLAY_HEIGHT - BLOCK_HEIGHT - HIGHEST_VALUE_ITEM_SIZE), player.y'length));
                            item_next.w <= std_logic_vector(to_unsigned(HIGHEST_VALUE_ITEM_SIZE, item.w'length));
                            item_next.h <= std_logic_vector(to_unsigned(HIGHEST_VALUE_ITEM_SIZE, item.h'length));
                        elsif item.id = HIGH_VALUE_ITEM_ID then
                            item_next.y <= std_logic_vector(to_unsigned((DISPLAY_HEIGHT - BLOCK_HEIGHT - HIGH_VALUE_ITEM_SIZE), player.y'length));
                            item_next.w <= std_logic_vector(to_unsigned(HIGH_VALUE_ITEM_SIZE, item.w'length));
                            item_next.h <= std_logic_vector(to_unsigned(HIGH_VALUE_ITEM_SIZE, item.h'length));
                        else 
                            item_next.y <= std_logic_vector(to_unsigned((DISPLAY_HEIGHT - BLOCK_HEIGHT - NORMAL_VALUE_ITEM_SIZE), player.y'length));
                            item_next.w <= std_logic_vector(to_unsigned(NORMAL_VALUE_ITEM_SIZE, item.w'length));
                            item_next.h <= std_logic_vector(to_unsigned(NORMAL_VALUE_ITEM_SIZE, item.h'length));
                        end if;

                        internal_game_state_next <= RUNNING_SAVE_ITEM;                  
                    else 
                        internal_game_state_next <= RUNNING_RANDOM_ITEM_POSITION;
                    end if;

                when RUNNING_SAVE_ITEM =>
                    object_fifo_in_sig <= '1';
                    object_fifo_in_data <= go_to_slv(item);
                    object_fifo_counter_next <= object_fifo_counter +1;
                    internal_game_state_next <= PERFORM_FRAME_SYNC;

        --FRAME SYNC
                when PERFORM_FRAME_SYNC =>
                    --check if the gfx instr interface is ready and issue a frame sync instruction
                    object_fifo_in_sig <= '0';

                    if (gfx_instr_full = '0') then
                        gfx_instr <= GFX_INSTR_FRAME_SYNC;
                        gfx_instr_wr <= '1';
                        internal_game_state_next <= WAIT_FRAME_SYNC;
                    else 
                        internal_game_state_next <= PERFORM_FRAME_SYNC;
                    end if;

                when WAIT_FRAME_SYNC =>
                    if (gfx_frame_sync = '1') then
                        internal_game_state_next <= MOVE_PLAYER;
                    else
                        internal_game_state_next <= WAIT_FRAME_SYNC;
                    end if;

        --MOVE PLAYER
                when MOVE_PLAYER =>
                    if game_state = IDLE then
                        oc_apply_movement <= '1';
                        oc_player_dir <= random_player_direction;
                    else
                        if ( (controller.btn_left or controller.btn_right) = '1') then
                            oc_apply_movement <= '1';
                        end if;
                        oc_player_dir <= controller.btn_right;
                    end if;
    
                    oc_apply_gravity <= '1';
                    internal_game_state_next <= MOVE_PLAYER_WAIT_OBJECT_REQ;
                    game_object_cnt_next <= 0;

                    oc_start <= '1'; -- start the object collider

                when MOVE_PLAYER_WAIT_OBJECT_REQ =>
                    object_fifo_in_sig <= '0';
                    -- wait for the object collider to either
                    --  (a) request a game object to check for collision or
                    --  (b) indicate that it has completed its operation
                    if (oc_object_req = '1') then
                        internal_game_state_next <= MOVE_PLAYER_OBJECT_VALID;
                        if (game_object_cnt < object_fifo_counter) then
                            object_fifo_out_sig <= '1';
                        end if;
                    elsif (oc_done = '1') then
                        internal_game_state_next <= MOVE_PLAYER_DONE;
                        current_oc_object_next <= GAME_OBJECT_NULL;
                    end if;

                when MOVE_PLAYER_OBJECT_VALID =>
                    if (game_object_cnt >= object_fifo_counter) then
                        -- if game_object_cnt is object_fifo_counter all objects have been processed by the object collider, 
                        --hence we have to notify it that there are no more objects left and reset the game_object_cnt
                        oc_object_eol <= '1';
                        internal_game_state_next <= MOVE_PLAYER_WAIT_OBJECT_REQ;
                        game_object_cnt_next <= 0;
                    else
                        --if not all objects have been processed, use the output of the block fifo buffer to
                        --save the current object to the current_object signal and back into the fifo for further use
                        oc_object_valid <= '1';
                        object_fifo_out_sig <= '0';
                        current_oc_object_next <= slv_to_go(object_fifo_out_data);
                        internal_game_state_next <= MOVE_PLAYER_WAIT_CYCLE;
                    end if;

                when MOVE_PLAYER_WAIT_CYCLE =>
                    internal_game_state_next <= MOVE_PLAYER_CHECK_COLLISION;

                when MOVE_PLAYER_CHECK_COLLISION =>
                    -- check if there was a collision with the item currently applied to the input of the object collider (oc_object)
                    -- since the bricks are marked as blocking (oc_object_is_blocking = '1'), collisions with them will not be reported
                    if oc_collision_detected = '1' then
                        
                        if current_object.id = HIGHEST_VALUE_ITEM_ID then
                            player_points_internal_next <= std_logic_vector(to_unsigned((to_integer(unsigned(player_points_internal)) + 25), player_points'length));
                        elsif current_object.id = HIGH_VALUE_ITEM_ID then
                            player_points_internal_next <= std_logic_vector(to_unsigned((to_integer(unsigned(player_points_internal)) + 10), player_points'length));
                        else
                            player_points_internal_next <= std_logic_vector(to_unsigned((to_integer(unsigned(player_points_internal)) + 5), player_points'length));
                        end if;

                        object_fifo_counter_next <= object_fifo_counter -1;
                        item_collected_audio_counter_next <= 0;
                    else
                        object_fifo_in_sig <= '1';
                        object_fifo_in_data <= go_to_slv(current_oc_object_next);
                    end if;

                    game_object_cnt_next <= game_object_cnt + 1;
                    internal_game_state_next <= MOVE_PLAYER_WAIT_OBJECT_REQ;

                when MOVE_PLAYER_DONE =>
                    player_next.x <= oc_player_x;
                    player_next.y <= oc_player_y;
                    internal_game_state_next <= CLEAR_SCREEN;

        --DRAWING
            --clear
                when CLEAR_SCREEN =>
                write_gfx_instr_and_goToState(GFX_INSTR_CLEAR, DRAW_OBJECT);

            --draw blocks
                when DRAW_OBJECT => 
                    if object_processed_counter = object_fifo_counter then
                        internal_game_state_next <= DRAW_PLAYER_INSTR;
                        object_processed_counter_next <= 0;
                    else 
                        internal_game_state_next <= DRAW_OBJECT_INSTR;
                        object_fifo_out_sig <= '1';
                    end if;
        
                when DRAW_OBJECT_INSTR =>
                    
                    if slv_to_go(object_fifo_out_data).id = BLOCK_ID then
                        write_gfx_instr_and_gotoState(GFX_INSTR_DRAW_RECT(enable_alpha=>true, draw_border=>true, pattern_id=>1), DRAW_OBJECT_X);
                    else
                        write_gfx_instr_and_gotoState(GFX_INSTR_DRAW_RECT(enable_alpha=>true, draw_border=>true, pattern_id=>2), DRAW_OBJECT_X);
                    end if;

                    object_fifo_out_sig <= '0';
                    object_fifo_in_sig <= '1';
                    object_fifo_in_data <= object_fifo_out_data;
                    current_object_next <= slv_to_go(object_fifo_out_data);
                    object_processed_counter_next <= object_processed_counter +1;

                when DRAW_OBJECT_X =>
                    object_fifo_in_sig <= '0';
                    write_gfx_data_and_gotoState(current_object.x, DRAW_OBJECT_Y);
                when DRAW_OBJECT_Y => 
                    write_gfx_data_and_gotoState(current_object.y, DRAW_OBJECT_WIDTH);
                when DRAW_OBJECT_WIDTH => 
                    write_gfx_data_and_gotoState(current_object.w, DRAW_OBJECT_HEIGHT);
                when DRAW_OBJECT_HEIGHT => 
                    write_gfx_data_and_gotoState(current_object.h, DRAW_OBJECT);

            --draw player
                when DRAW_PLAYER_INSTR =>
                    
                    if ((to_integer(unsigned(player.y))) > 6) then
                        write_gfx_instr_and_goToState(GFX_INSTR_DRAW_CIRCLE, DRAW_PLAYER_X);
                    else 
                        internal_game_state_next <= FRAME_DONE;
                    end if;

                when DRAW_PLAYER_X =>
                    write_gfx_data_and_goToState(std_logic_vector(unsigned(player.x)+PLAYER_BALL_RADIUS), DRAW_PLAYER_Y);

                when DRAW_PLAYER_Y =>
                    write_gfx_data_and_goToState(std_logic_vector(unsigned(player.y)+PLAYER_BALL_RADIUS), DRAW_PLAYER_RADIUS);

                when DRAW_PLAYER_RADIUS =>
                    write_gfx_data_and_goToState(std_logic_vector(to_unsigned(PLAYER_BALL_RADIUS, gfx_data'length)), FRAME_DONE);

        --FRAME_DONE
                when FRAME_DONE => 
                
                    if game_state = RUNNING then

                        if (((to_integer(unsigned(player.y))) >= DISPLAY_HEIGHT) or ((to_integer(unsigned(player.y))) <= 0)) then
                            --if the player is outside of the screen -> game_over
                            game_speed_next <= INITIAL_GAME_SPEED;
                            gravity_next <= INITIAL_GRAVITY;
                            game_rotations_next <= 0; 
                            game_over_audio_counter_next <= 0;
                            game_state_next <= GAME_OVER;
                            internal_game_state_next <= FRAME_DONE;
                        
                        else

                            game_rotations_next <= game_rotations +1;

                            if game_rotations = GAME_DIFFICULTY then
                                game_speed_next <= game_speed +1;
                                gravity_next <= gravity +1;
                                game_rotations_next <= 0;
                            end if;

                            
                            if (controller.btn_start = '1') and (start_button_released = '1') then
                                --if start pressed while game running -> pause state
                                start_button_released_next <= '0';
                                game_state_next <= PAUSED;
                                internal_game_state_next <= FRAME_DONE;
                            else
                                --if current game continous 
                                internal_game_state_next <= RUNNING_PLAYER_UPDATE;
                            end if;
                        end if;

                    elsif game_state = PAUSED then

                        if (controller.btn_start = '1') and (start_button_released = '1') then
                            start_button_released_next <= '0';
                            game_state_next <= RUNNING;
                            internal_game_state_next <= RUNNING_PLAYER_UPDATE;
                        else 
                            internal_game_state_next <= FRAME_DONE;
                        end if;

                    elsif game_state = GAME_OVER then

                        if (controller.btn_start = '1') and (start_button_released = '1') then
                            --if start pressed, change to IDLE state
                            start_button_released_next <= '0';
                            player_points_internal_next <= (others => '0');
                            game_state_next <= IDLE;
                            internal_game_state_next <= CLEAN_BLOCKS;       
                        else
                            internal_game_state_next <= FRAME_DONE;
                        end if;
                    
                    else --game_state = IDLE

                        if (controller.btn_start = '1') and (start_button_released = '1') then
                            --if start pressed, change to running state
                            start_button_released_next <= '0';
                            game_state_next <= RUNNING;
                            internal_game_state_next <= CLEAN_BLOCKS;     
                        else
                            
                            if ((to_integer(unsigned(player.y))) >= DISPLAY_HEIGHT) then
                                internal_game_state_next <= IDLE_RANDOM_PLAYER_POSITION;
                            else 
                                internal_game_state_next <= IDLE_RANDOM_PLAYER_DIRECTION;
                            end if;
        
                        end if;

                    end if;

                when others =>
                    null;
            end case;
    end process;

--random number generation
    --This block uses the parameter random_source to try to generate a random number in the range [a:b] and stores it in the output signal vector random_value.
    --If no valid random number could be obtained the output signal random_valid will be set to '0', otherwise it is set to '1'
    random_number_generation : block 
        procedure random_slv(random_source : std_logic_vector; a, b : integer; signal random_value : out std_logic_vector; signal random_valid : out std_logic) is
        -- This function uses the parameter random_source to try to generate a random number in the range [a:b] and stores it in the output signal vector random_value.
        -- If no valid random number could be obtained the output signal random_valid will be set to '0', otherwise it is set to '1'
        begin
            random_value <= std_logic_vector(to_unsigned(a + to_integer(unsigned(random_source(log2c(b-a)-1 downto 0))), random_value'length));
            if(unsigned(random_source(log2c(b-a)-1 downto 0))>(b-a)) then
                random_valid <= '0';
            else
                random_valid <= '1';
            end if;
        end procedure;
    begin
    --prng instantiation
        gen_prngs : for i in prdata'range generate
        begin
             --generates a ranom number out of the passed seed. Because en is always high, a new random number will always be asserted at the nex clk edge. 
            --When load_seed goes high, the currently passed seed is loaded into the prng and a new value is returned into prdata. 
            prng_inst: prng
            port map (
                clk       => clk,
                res_n     => res_n,
                load_seed => load_seed,                                     
                seed      => std_logic_vector(to_unsigned(i+3,8)),
                en        => '1',
                prdata    => prdata(i)
            );

        end generate;


    --sync : generating the random vector
        sync : process(clk, res_n)
        begin
            if (res_n = '0') then

                random_x_pos_valid <= '0';
                random_x_pos <= (others=>'0');
                
                random_value_r_0_3_valid <= '0';
                random_value_r_0_3 <= (others=>'0');

                random_value_r_1_10_valid <= '0';
                random_value_r_1_10 <= (others=>'0');
                
                random_value_r_2_5_valid <= '0';
                random_value_r_2_5 <= (others=>'0');

                random_direction_valid <= '0';
                random_direction <= (others => '0');

                random_item_value_valid <= '0';
                random_item_value <= (others => '0');

            elsif (rising_edge(clk)) then
                --prdata = prng generated data

                --generate data for the initial player positioning
                random_slv(prdata, PLAYER_BALL_RADIUS, DISPLAY_WIDTH-PLAYER_BALL_RADIUS, random_x_pos, random_x_pos_valid);

                --generate data for player direction
                random_slv(prdata, 1, 10, random_direction, random_direction_valid);

                --generate data used for block creation
                random_slv(prdata, 0, 3, random_value_r_0_3, random_value_r_0_3_valid); 
                random_slv(prdata, 1, 10, random_value_r_1_10, random_value_r_1_10_valid);
                random_slv(prdata, 2,5, random_value_r_2_5, random_value_r_2_5_valid);

                --generate propability for item value
                random_slv(prdata, 1, 16, random_item_value, random_item_value_valid);
                
            end if;
        end process;
        
    end block;

--object collider
    --Used to move player object according to inputs, if collision of player object with
    --object is detected, and object is non-blocking, oc_collision detected it set high.  
     
    --LEFT AND RIGHT BORDER:
    --This core doesn't let the player_object move pass the left or right border of the screen,
    --but it doesn't check if the player_object touches the upper or lower end of the screen

    --OUTPUT:
    --Until the block recieves a new high on the start signal, the previous output values are 
    --still valid and available.

    --INTERACTION WITH THE CORE:
    --The core starts to request game objects from the game object list after 2 clk_cycles after
    --the assertion of the start signal

    --EOL_OBJECT: 
    --The core uses the eol_object to recognize an end of the object list. Until then it expects
    --more input objects.

    --DONE:
    --The core applies the done signal when it has processed the passed movement direction. 
    
    object_collider_block : block
    begin
        oc_object_mux : process(all)
        begin
            -- the game_object_cnt signal determines which game object
            -- is relayed to the input of the object collider 
            if game_object_cnt <= object_fifo_counter then
                oc_object <= current_oc_object;
            else 
                oc_object <= GAME_OBJECT_NULL;
            end if;
        end process;
        
        -- bricks are blocking, all other objects are non-blocking
        oc_object_is_blocking <= '1' when oc_object.id = "00" else '0';

        object_collider_inst : object_collider
        generic map (
            DISPLAY_WIDTH  => DISPLAY_WIDTH,
            DISPLAY_HEIGHT => DISPLAY_HEIGHT
        )
        port map (
            clk                => clk,
            res_n              => res_n,
            start              => oc_start,
            done               => oc_done,
            apply_movement     => oc_apply_movement,
            apply_gravity      => oc_apply_gravity,
            player_x           => oc_player_x,
            player_y           => oc_player_y,
            player             => player,
            player_speed       => oc_player_speed,
            player_dir         => oc_player_dir,
            gravity            => std_logic_vector(to_unsigned(gravity, GAME_OBJECT_SPEED_WIDTH)),
            object             => oc_object,
            object_req         => oc_object_req,
            object_valid       => oc_object_valid,
            object_is_blocking => oc_object_is_blocking,
            object_eol         => oc_object_eol,
            collision_detected => oc_collision_detected
        );
        
    end block;

--gfx initialisation
    --This block performs the initialization of the display.    
        --double buffering -> true
        --primary color -> BRICK_COLOR
        --secondary color -> BG_COLOR
        --pattern -> BRICK_PATTERN  
        --clear of the screen    

    --START:
    --The block starts this operation when the gfx_initializer_start signals is set to 1. While the operation in running, 
    --the gfx_initializer busy signal ist set to high

    --END:
    --It is done when the block set the gfx_initializer_signal is set back to low
    
    --instructions and data necessary for intialization


    gfx_initializer : block 
    

        constant INIT_INSTR : gfx_instr_array_t(0 to 5) := (
            GFX_INSTR_SET_CFG(enable_double_buffering=>true),
            GFX_INSTR_SET_COLOR(true), -- set primary drawing color
            GFX_INSTR_SET_COLOR(false), -- set secondary drawing color
            GFX_INSTR_SET_PATTERN(1),
            GFX_INSTR_SET_PATTERN(2),
            GFX_INSTR_CLEAR
        );

        constant INIT_DATA : gfx_data_array_t(0 to 5) := (
            BRICK_COLOR, -- primary color information
            BG_COLOR,  -- secondary color information
            BRICK_PATTERN_P0,--first part of the brick pattern data
            BRICK_PATTERN_P1, --second part of the brick pattenr data
            ITEM_PATTERN_P0,
            ITEM_PATTERN_P1
        );
        
    --counter signals
        signal instr_cnt : integer := 0;
        signal instr_cnt_next : integer := 0;
        signal data_cnt : integer := 0;
        signal data_cnt_next : integer := 0;
        
    --state machine signals
        signal init_gfx_data_next : std_logic_vector(GFX_DATA_WIDTH-1 downto 0);
        signal init_gfx_instr_next : std_logic_vector(GFX_INSTR_WIDTH-1 downto 0);
        signal instr_busy, instr_busy_next : std_logic; 
        signal data_busy, data_busy_next : std_logic;
    begin
        process(clk, res_n)
        begin
            if (res_n = '0') then
                instr_cnt <= 0;
                data_cnt <= 0;
                init_gfx_instr <= (others=>'0');
                init_gfx_data <= (others=>'0');
                instr_busy <= '0';
                data_busy <= '0';
            elsif (rising_edge(clk)) then
                init_gfx_instr <= init_gfx_instr_next;
                init_gfx_data <= init_gfx_data_next;
                instr_cnt <= instr_cnt_next;
                data_cnt <= data_cnt_next;
                instr_busy <= instr_busy_next;
                data_busy <= data_busy_next;
            end if;
        end process;
        
        output : process(all)
        begin
            init_gfx_instr_wr <= '0';
            init_gfx_data_wr <= '0';
            
            gfx_initializer_busy <= '0';
            
            instr_cnt_next <= instr_cnt;
            data_cnt_next <= data_cnt;
            
            init_gfx_instr_next <= init_gfx_instr;
            init_gfx_data_next <= init_gfx_data;
            
            instr_busy_next <= instr_busy;
            data_busy_next <= data_busy;
            
            if (gfx_initializer_start = '1') then
            --if initialization should start, set all signals to start state and set busy signal
                gfx_initializer_busy <= '1';
                instr_cnt_next <= 1;
                data_cnt_next <= 1;
                instr_busy_next <= '1';
                data_busy_next <= '1';
                init_gfx_instr_next <= INIT_INSTR(0);
                init_gfx_data_next <= INIT_DATA(0);
            end if;
            
            if(instr_busy = '1' or data_busy = '1') then
            --as long as instructions or data should be written, set busy signal high
                gfx_initializer_busy <= '1';
            end if;
            
            if (instr_busy = '1') then
                if (gfx_instr_full = '0') then
                --if the instruction busy signal is set and and gfx_instr is not full
                    init_gfx_instr_wr <= '1';
                    
                    if (instr_cnt = 0) then
                    --when all instructions have been processed
                        instr_busy_next <= '0';
                    elsif (instr_cnt = INIT_INSTR'length-1) then
                    --when every instruction but the last one has been processed, set counter indicating how many instructions have been processed to 0 and load next instruction
                        instr_cnt_next <= 0;
                        init_gfx_instr_next <= INIT_INSTR(instr_cnt);
                    else
                    --every other case, process next instruciton and increase the counter indicating how many instructions have been processed
                        init_gfx_instr_next <= INIT_INSTR(instr_cnt);
                        instr_cnt_next <= instr_cnt + 1;
                    end if;
                end if;
            end if;
            
            if (data_busy = '1') then
                if (gfx_data_full = '0') then
                --if the data busy signal is set and and gfx_data is not full

                    init_gfx_data_wr <= '1';
                    
                    if (data_cnt = 0) then
                     --when all instructions have been processed
                        data_busy_next <= '0';
                    elsif (data_cnt = INIT_DATA'length-1) then
                    --when every instruction but the last one has been processed, set counter indicating how many instructions have been processed to 0 and load next instruction
                        data_cnt_next <= 0;
                        init_gfx_data_next <= INIT_DATA(data_cnt);
                    else
                    --every other case, process next instruciton and increase the counter indicating how many instructions have been processed
                        init_gfx_data_next <= INIT_DATA(data_cnt);
                        data_cnt_next <= data_cnt + 1;
                    end if;
                end if;
            end if;
            
        end process;
    end block;

--audio control
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


    synth_cntrl(0).high_time <= x"20";
    synth_cntrl(0).low_time <= x"20"; 
    synth_cntrl(0).play <= synth_cntrl_0_sig;

    synth_cntrl(1).high_time <= x"10";
    synth_cntrl(1).low_time <= x"10"; 
    synth_cntrl(1).play <= synth_cntrl_1_sig;

end arch_ex2 ;
