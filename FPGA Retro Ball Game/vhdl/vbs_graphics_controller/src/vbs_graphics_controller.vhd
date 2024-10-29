library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.vbs_graphics_controller_pkg.all;
use work.ram_pkg.all;
use work.math_pkg.all;
use work.gfx_util_pkg.all;
use work.gfx_if_pkg.all;

entity vbs_graphics_controller is
	generic (
		CLK_FREQ : integer := 50_000_000
	);
	port (
		clk   : in std_logic;
		res_n : in std_logic;
		
		--instruction interface
		gfx_instr       : in std_logic_vector(GFX_INSTR_WIDTH-1 downto 0);
		gfx_instr_wr    : in std_logic;
		gfx_instr_full  : out std_logic;
		gfx_data        : in std_logic_vector(GFX_DATA_WIDTH-1 downto 0);
		gfx_data_wr     : in std_logic;
		gfx_data_full   : out std_logic;
		
		gfx_frame_sync    : out std_logic;
		
		-- interface to ADV7123
		vga_r : out std_logic_vector(7 downto 0);
		vga_g : out std_logic_vector(7 downto 0);
		vga_b : out std_logic_vector(7 downto 0);
		vga_clk : out std_logic;
		vga_sync_n : out std_logic;
		vga_blank_n : out std_logic
	);
end entity;

architecture arch of vbs_graphics_controller is

--constants
	constant FIFO_BUFFER_DEPTH : integer := 128;
	constant SCREEN_RESOLUTION_WIDTH : integer := 400;
	constant SCREEN_RESOLUTION_HEIGHT : integer := 240;
	constant DP_VIDEO_RAM_ADDR_WIDTH : integer := log2c(96000);	
	constant DP_VIDEO_RAM_DATA_WIDTH : integer := 2;

--fifo_buffer signals

	--instr_fifo_buffer
		signal instr_fifo_rd_data : std_logic_vector(GFX_INSTR_WIDTH-1 downto 0);
		signal instr_fifo_rd, instr_fifo_rd_next : std_logic;
		signal instr_fifo_empty : std_logic;
		signal instr_fifo_full : std_logic;

	--data_fifo_buffer
		signal data_fifo_rd_data : std_logic_vector(GFX_DATA_WIDTH-1 downto 0);
		signal data_fifo_rd, data_fifo_rd_next : std_logic;
		signal data_fifo_empty : std_logic;
		signal data_fifo_full : std_logic;

--dp_video_ram_signals 

	--read port signals 
		signal dp_video_ram_rd_addr : std_logic_vector(DP_VIDEO_RAM_ADDR_WIDTH - 1 downto 0);		--address from which to read
		signal dp_video_ram_rd_data : std_logic_vector(DP_VIDEO_RAM_DATA_WIDTH - 1 downto 0);		--data which is read
		signal dp_video_ram_rd : std_logic;															--high in order to read

	--write port signals
		signal dp_video_ram_wr_addr, dp_video_ram_wr_addr_next : std_logic_vector(DP_VIDEO_RAM_ADDR_WIDTH - 1 downto 0);		--address onto which data is written
		signal dp_video_ram_wr_data, dp_video_ram_wr_data_next : std_logic_vector(DP_VIDEO_RAM_DATA_WIDTH - 1 downto 0);		--data which is written
		signal dp_video_ram_wr, dp_video_ram_wr_next : std_logic;															--high in order to write

	--double_buffering

		signal write_primary_read_secondary_vram,write_primary_read_secondary_vram_next : boolean := true;

	--primary_buffer_signals
		--used to write or read into/from primary buffer

			--read port signals 
			signal dp_primary_video_ram_rd_addr : std_logic_vector(DP_VIDEO_RAM_ADDR_WIDTH - 1 downto 0);		
			signal dp_primary_video_ram_rd_data : std_logic_vector(DP_VIDEO_RAM_DATA_WIDTH - 1 downto 0);	
			signal dp_primary_video_ram_rd : std_logic;													
	
			--write port signals
			signal dp_primary_video_ram_wr_addr : std_logic_vector(DP_VIDEO_RAM_ADDR_WIDTH - 1 downto 0);	
			signal dp_primary_video_ram_wr_data : std_logic_vector(DP_VIDEO_RAM_DATA_WIDTH - 1 downto 0);	
			signal dp_primary_video_ram_wr : std_logic;	

	--secondary_buffer_signals	
		--used to write or read into/from secondary buffer

			--read port signals 
			signal dp_secondary_video_ram_rd_addr : std_logic_vector(DP_VIDEO_RAM_ADDR_WIDTH - 1 downto 0);		
			signal dp_secondary_video_ram_rd_data : std_logic_vector(DP_VIDEO_RAM_DATA_WIDTH - 1 downto 0);	
			signal dp_secondary_video_ram_rd : std_logic;													
	
			--write port signals
			signal dp_secondary_video_ram_wr_addr : std_logic_vector(DP_VIDEO_RAM_ADDR_WIDTH - 1 downto 0);	
			signal dp_secondary_video_ram_wr_data : std_logic_vector(DP_VIDEO_RAM_DATA_WIDTH - 1 downto 0);	
			signal dp_secondary_video_ram_wr : std_logic;	

--frame_reader
	signal frame_reader_frame_start : std_logic;
	signal frame_reader_next_pixel, frame_reader_next_pixel_next : std_logic;
	signal frame_reader_data : std_logic_vector(DP_VIDEO_RAM_DATA_WIDTH-1 downto 0);

--rasterizer signals
	
	--instruction & data handling
		
		type state_t is (CHECK_NEW_INSTR, WAIT_UNTIL_READ_INSTR_READY, READ_INSTR, HANDLE_INSTR, CHECK_DATA_AVAILABILITY, WAIT_UNTIL_READ_DATA_READY, READ_DATA);
		signal state, state_next : state_t;
	
		signal current_instruction, current_instruction_next : std_logic_vector(GFX_INSTR_WIDTH-1 downto 0);
		signal op_step, op_step_next : integer := 0;
		
		signal primary_color, primary_color_next : std_logic_vector(1 downto 0);
		signal secondary_color, secondary_color_next : std_logic_vector(1 downto 0);
		
		signal read_data_counter, read_data_counter_next : integer := 0;
		signal data_needed, data_needed_next : integer := 0;
		
		signal current_data, current_data_next : std_logic_vector(GFX_DATA_WIDTH-1 downto 0);
		signal current_data_one, current_data_one_next : std_logic_vector(GFX_DATA_WIDTH-1 downto 0);
		signal current_data_two, current_data_two_next : std_logic_vector(GFX_DATA_WIDTH-1 downto 0);
		signal current_data_three, current_data_three_next : std_logic_vector(GFX_DATA_WIDTH-1 downto 0);
		signal current_data_four, current_data_four_next : std_logic_vector(GFX_DATA_WIDTH-1 downto 0);
		
		signal current_pattern, current_pattern_next : std_logic_vector(20 downto 0);
		signal pattern_0 : std_logic_vector(20 downto 0);
		signal pattern_1, pattern_1_next : std_logic_vector(20 downto 0);
		signal pattern_2, pattern_2_next : std_logic_vector(20 downto 0);
		signal pattern_3, pattern_3_next : std_logic_vector(20 downto 0);
		signal pattern_4, pattern_4_next : std_logic_vector(20 downto 0);
		signal pattern_5, pattern_5_next : std_logic_vector(20 downto 0);
		signal pattern_6, pattern_6_next : std_logic_vector(20 downto 0);
		signal pattern_7 : std_logic_vector(20 downto 0);
			-- each pattern contains the same parameters:
			-- 20 -> 16 :	ls (line shift parameter, how many pixel in each new line the blocks are shiftet to the right)
			-- 15 -> 12 :	dx (amount of pixel between each block-column)
			-- 11 -> 8  :	dy (amount of pixel between each block-lines)
			-- 7 -> 4   :	bw (block width, amount of pixels colored in primary color in x-direction) 
			-- 3 -> 0   :	bh (block height, amount of pixels colored in primary color in y-direction)  
		
		signal double_buffering, double_buffering_next : boolean := false;
		signal gfx_frame_sync_next : std_logic;
		
		signal x, x_next : integer := 0;
		signal y, y_next : integer := 0;
				
	--gfx_line
		
		--control signals
			signal line_start, line_start_next : std_logic;
			signal line_busy : std_logic;
		
		--drawing parameters
			signal line_x0, line_x0_next : std_logic_vector(log2c(SCREEN_RESOLUTION_WIDTH)-1 downto 0);
			signal line_x1, line_x1_next : std_logic_vector(log2c(SCREEN_RESOLUTION_WIDTH)-1 downto 0);
			signal line_y0, line_y0_next : std_logic_vector(log2c(SCREEN_RESOLUTION_HEIGHT)-1 downto 0);
			signal line_y1, line_y1_next : std_logic_vector(log2c(SCREEN_RESOLUTION_HEIGHT)-1 downto 0);
		
		--pixel coordinates output
			signal line_pixel_valid : std_logic;
			signal line_pixel_x : std_logic_vector(log2c(SCREEN_RESOLUTION_WIDTH)-1 downto 0);
			signal line_pixel_y : std_logic_vector(log2c(SCREEN_RESOLUTION_HEIGHT)-1 downto 0);
				
	--gfx_circle

		--control signals
			signal circle_start, circle_start_next : std_logic;
			signal circle_busy : std_logic;
		
		--drawing parameters
			signal circle_x_center, circle_x_center_next : std_logic_vector(log2c(SCREEN_RESOLUTION_WIDTH)-1 downto 0);
			signal circle_y_center, circle_y_center_next : std_logic_vector(log2c(SCREEN_RESOLUTION_HEIGHT)-1 downto 0);
			signal circle_radius, circle_radius_next : std_logic_vector(log2c(SCREEN_RESOLUTION_WIDTH)-1 downto 0);
			
		--pixel coordinates output
			signal circle_pixel_valid : std_logic;
			signal circle_pixel_x : std_logic_vector(log2c(SCREEN_RESOLUTION_WIDTH)-1 downto 0);
			signal circle_pixel_y : std_logic_vector(log2c(SCREEN_RESOLUTION_HEIGHT)-1 downto 0);

	--gfx_rect

		--control signals
			signal rect_start, rect_start_next : std_logic;
			signal rect_busy : std_logic;
			
		--drawing paramers
			signal rect_x, rect_x_next : std_logic_vector(log2c(SCREEN_RESOLUTION_WIDTH)-1 downto 0);
			signal rect_y, rect_y_next : std_logic_vector(log2c(SCREEN_RESOLUTION_HEIGHT)-1 downto 0);
			signal rect_w, rect_w_next : std_logic_vector(log2c(SCREEN_RESOLUTION_WIDTH)-1 downto 0);
			signal rect_h, rect_h_next : std_logic_vector(log2c(SCREEN_RESOLUTION_HEIGHT)-1 downto 0);
			signal rect_bw, rect_bw_next : std_logic_vector(3 downto 0);
			signal rect_bh, rect_bh_next : std_logic_vector(3 downto 0);
			signal rect_dx, rect_dx_next : std_logic_vector(3 downto 0);
			signal rect_dy, rect_dy_next : std_logic_vector(3 downto 0);
			signal rect_ls, rect_ls_next : std_logic_vector(4 downto 0);
			signal rect_fill, rect_fill_next : std_logic;
			signal rect_draw, rect_draw_next : std_logic;

		--pixel coordinates output
			signal rect_pixel_valid : std_logic;
			signal rect_pixel_x : std_logic_vector(log2c(SCREEN_RESOLUTION_WIDTH)-1 downto 0);
			signal rect_pixel_y : std_logic_vector(log2c(SCREEN_RESOLUTION_HEIGHT)-1 downto 0);
			signal rect_pixel_color : std_logic;

--external interface signals

	signal line_counter, line_counter_next : integer := 1;
	signal new_vbs_frame, new_vbs_frame_next : std_logic;
	signal vga_g_sig, vga_g_sig_next : std_logic_vector(7 downto 0);
	signal vga_blank_sig, vga_blank_sig_next : std_logic;
	signal vga_sync_sig, vga_sync_sig_next : std_logic;
	signal clk_cycle_counter, clk_cycle_counter_next : integer := 1;
	signal mod_counter, mod_counter_next : integer range 0 to 8 := 0;

begin

--primary dual_port_video_ram instantiation
	--used to save frames
	dp_video_ram_inst_primary : dp_ram_1c1r1w
	generic map (
		ADDR_WIDTH => DP_VIDEO_RAM_ADDR_WIDTH,
		DATA_WIDTH => DP_VIDEO_RAM_DATA_WIDTH
	)
	port map (
		clk => clk,
		
		--read port which reads into frame_reader
		rd1_addr => dp_primary_video_ram_rd_addr, 						
		rd1_data => dp_primary_video_ram_rd_data, 						
		rd1 => dp_primary_video_ram_rd,									

		--write port which gets input from rasterizer
		wr2_addr => dp_primary_video_ram_wr_addr,									
		wr2_data => dp_primary_video_ram_wr_data,						
		wr2 => dp_primary_video_ram_wr 									
	);

--secondary dual_port_video_ram instantiation
	--used to save frames when double buffering is enabled
	dp_video_ram_inst_secondary : dp_ram_1c1r1w
	generic map (
		ADDR_WIDTH => DP_VIDEO_RAM_ADDR_WIDTH,
		DATA_WIDTH => DP_VIDEO_RAM_DATA_WIDTH
	)
	port map (
		clk => clk,
		
		--read port which reads into frame_reader
		rd1_addr => dp_secondary_video_ram_rd_addr, 						
		rd1_data => dp_secondary_video_ram_rd_data, 						
		rd1 => dp_secondary_video_ram_rd,									

		--write port which gets input from rasterizer
		wr2_addr => dp_secondary_video_ram_wr_addr,									
		wr2_data => dp_secondary_video_ram_wr_data,						
		wr2 => dp_secondary_video_ram_wr 									
	);	

--frame_reader instantiation
	--transforms data in dp_vram into data which can be used in the external interface
	frame_reader_inst : frame_reader
	generic map (
		WIDTH => SCREEN_RESOLUTION_WIDTH,
		HEIGHT => SCREEN_RESOLUTION_HEIGHT,
		VRAM_ADDR_WIDTH => DP_VIDEO_RAM_ADDR_WIDTH,
		VRAM_DATA_WIDTH => DP_VIDEO_RAM_DATA_WIDTH
	)
	port map (
		clk => clk,
		res_n => res_n,
		
		-- frame synchronization signal
		frame_start => frame_reader_frame_start,													--output to notify about soon starting new frame
		vram_base_addr => (others => '0'),
		
		-- interface to the video RAM (dp_video_ram_inst)
		vram_rd => dp_video_ram_rd,
		vram_addr => dp_video_ram_rd_addr,
		vram_data => dp_video_ram_rd_data,
		
		--asserting pix_rd yields the next pixel data on the next clock edge 
		pix_rd => frame_reader_next_pixel, 														--asserting high yiels next pix_data on next clk_edge
		pix_data => frame_reader_data																--next pixel data
		-- pix_rd => '0',
		-- pix_data => open																
	
	);

--sync
	sync : process(clk, res_n)
	begin
		if res_n = '0' then

			--instruction & data handling
			state <= CHECK_NEW_INSTR;
			current_instruction <= (others => '0');
			current_data <= (others => '0');
			current_data_one <= (others => '0');
			current_data_two <= (others => '0');
			current_data_three <= (others => '0');
			current_data_four <= (others => '0');
			op_step <= 0;
			
			--fifo_buffer
			instr_fifo_rd <= '0';
			data_fifo_rd <= '0';

			--read data
			read_data_counter <= 0;
			data_needed <= 0;

			--clear
			x <= 0;
			y <= 0;

			--color
			primary_color <= "11";
			secondary_color <= "00";
			
			--user patterns
			current_pattern <= (others => '0');
			pattern_1 <= (others => '0');
			pattern_2 <= (others => '0');
			pattern_3 <= (others => '0');
			pattern_4 <= (others => '0');
			pattern_5 <= (others => '0');
			pattern_6 <= (others => '0');

			gfx_frame_sync <= '0';
			new_vbs_frame <= '0';

			--double buffering
			double_buffering <= false;

			--gfx_line
			line_start <= '0';
			line_x0 <= (others => '0');
			line_x1 <= (others => '0');
			line_y0 <= (others => '0');
			line_y1 <= (others => '0');
			
			--gfx_circle
			circle_start <= '0';
			circle_x_center <= (others => '0');
			circle_y_center <= (others => '0');
			circle_radius <= (others => '0');

			--gfx_rect
			rect_start <= '0';
			rect_fill  <= '0';
			rect_draw <= '0';
			rect_x <= (others => '0');
			rect_y <= (others => '0');
			rect_w <= (others => '0');
			rect_h <= (others => '0');
			rect_bw <= (others => '0');
			rect_bh <= (others => '0');
			rect_dx <= (others => '0');
			rect_dy <= (others => '0');
			rect_ls <= (others => '0');

			--dual port video ram											
			dp_video_ram_wr_addr <= (others => '0');	
			dp_video_ram_wr_data <= (others => '0');	
			dp_video_ram_wr <= '0';											
			
			--external interface
			vga_g_sig <= (others => '0');
			line_counter <= 1;
			clk_cycle_counter <= 1;
			vga_blank_sig <= '0';
			vga_sync_sig <= '0';
			frame_reader_next_pixel <= '0';
			write_primary_read_secondary_vram <= true;
			mod_counter <= 0;

		elsif rising_edge(clk) then
		
			state <= state_next;
			current_instruction <= current_instruction_next;
			op_step <= op_step_next;
			gfx_frame_sync <= gfx_frame_sync_next;
			new_vbs_frame <= new_vbs_frame_next;
			
			--fifo buffer
			instr_fifo_rd <= instr_fifo_rd_next;
			data_fifo_rd <= data_fifo_rd_next;

			--read data
			read_data_counter <= read_data_counter_next;
			data_needed <= data_needed_next;
			current_data <= current_data_next;
			current_data_one <= current_data_one_next;
			current_data_two <= current_data_two_next;
			current_data_three <= current_data_three_next;
			current_data_four <= current_data_four_next;

			--clear
			x <= x_next;
			y <= y_next;

			--color
			primary_color <= primary_color_next;
			secondary_color <= secondary_color_next;

			--pattern
			current_pattern <= current_pattern_next;
			pattern_1 <= pattern_1_next;
			pattern_2 <= pattern_2_next;
			pattern_3 <= pattern_3_next;
			pattern_4 <= pattern_4_next;
			pattern_5 <= pattern_5_next;
			pattern_6 <= pattern_6_next;

			--double buffering
			double_buffering <= double_buffering_next;

			--gfx_line
			line_start <= line_start_next;
			line_x0 <= line_x0_next;
			line_x1 <= line_x1_next;
			line_y0 <= line_y0_next;
			line_y1 <= line_y1_next;

			--gfx_circle
			circle_start <= circle_start_next;
			circle_x_center <= circle_x_center_next;
			circle_y_center <= circle_y_center_next;
			circle_radius <= circle_radius_next;

			--rect
			rect_start <= rect_start_next;
			rect_draw <= rect_draw_next;
			rect_fill <= rect_fill_next;
			rect_x <= rect_x_next;
			rect_y <= rect_y_next;
			rect_w <= rect_w_next;
			rect_h <= rect_h_next;
			rect_bw <= rect_bw_next;
			rect_bh <= rect_bh_next;
			rect_dx <= rect_dx_next;
			rect_dy <= rect_dy_next;
			rect_ls <= rect_ls_next;

			--dual port vram												
			dp_video_ram_wr_addr <= dp_video_ram_wr_addr_next;	
			dp_video_ram_wr_data <= dp_video_ram_wr_data_next;	
			dp_video_ram_wr <= dp_video_ram_wr_next;											
			
			--external interface
			line_counter <= line_counter_next;
			vga_g_sig <= vga_g_sig_next;
			vga_blank_sig <= vga_blank_sig_next;
			vga_sync_sig <= vga_sync_sig_next;
			frame_reader_next_pixel <= frame_reader_next_pixel_next;
			write_primary_read_secondary_vram <= write_primary_read_secondary_vram_next;
			clk_cycle_counter <= clk_cycle_counter_next;
			mod_counter <= mod_counter_next;
		
		end if;
	end process;

--internal interface
	--instr_fifo_buffer instantiation
		instr_fifo_inst : fifo_1c1r1w
		generic map (
			DEPTH  => FIFO_BUFFER_DEPTH,
			DATA_WIDTH => GFX_INSTR_WIDTH
		)
		port map (
			clk => clk,
			res_n => res_n,
			
			--read signals from fifo_buffer
			rd_data => instr_fifo_rd_data,
			rd => instr_fifo_rd,
			
			--write signals to fifo_buffer
			wr_data => gfx_instr,				--write directly from input to fifo buffer
			wr => gfx_instr_wr,					--write directly from input to fifo buffer

			--synchronization signals
			empty => instr_fifo_empty,
			full => instr_fifo_full,
			half_full => open
		);

	--data_fifo_buffer instantiation
		data_fifo_inst : fifo_1c1r1w
		generic map (
			DEPTH  => FIFO_BUFFER_DEPTH,
			DATA_WIDTH => GFX_DATA_WIDTH
		)
		port map (
			clk => clk,
			res_n => res_n,

			--read signals from fifo_buffer
			rd_data => data_fifo_rd_data,
			rd => data_fifo_rd,

			--write signals to fifo_buffer
			wr_data => gfx_data,				--write directly from input to fifo buffer
			wr => gfx_data_wr,					--write directly from input to fifo buffer
			
			--synchronization signals
			empty => data_fifo_empty,
			full => data_fifo_full,
			half_full => open
		);

	--gfx_line instantiation

		gfx_line_inst : gfx_line
		generic map (
			WIDTH => SCREEN_RESOLUTION_WIDTH, 
			HEIGHT => SCREEN_RESOLUTION_HEIGHT
		)
		port map (
			clk => clk, 
			res_n => res_n, 
			start => line_start,
			stall => '0',
			busy => line_busy,
			x0 => line_x0,
			x1 => line_x1,
			y0 => line_y0,
			y1 => line_y1,
			pixel_valid => line_pixel_valid,
			pixel_x => line_pixel_x,
			pixel_y => line_pixel_y
		);

	--gfx_circle instantiation

		gfx_circle_inst : gfx_circle
		generic map (
			WIDTH => SCREEN_RESOLUTION_WIDTH, 
			HEIGHT => SCREEN_RESOLUTION_HEIGHT
		)
		port map (
			clk => clk, 
			res_n => res_n, 
			start => circle_start,
			stall => '0',
			busy => circle_busy,
			x_center => circle_x_center,
			y_center => circle_y_center,
			radius => circle_radius,
			pixel_valid => circle_pixel_valid,
			pixel_x => circle_pixel_x,
			pixel_y => circle_pixel_y
		);

	--gfx_rect instantiation
		gfx_rect_inst : gfx_rect
		generic map (
			WIDTH => SCREEN_RESOLUTION_WIDTH, 
			HEIGHT => SCREEN_RESOLUTION_HEIGHT
		)
		port map (
			clk => clk, 
			res_n => res_n, 
			start => rect_start,
			stall => '0',
			busy => rect_busy,
			x => rect_x,
			y => rect_y,
			w => rect_w,
			h => rect_h,
			bw => rect_bw,
			bh => rect_bh,
			dx => rect_dx,
			dy => rect_dy,
			ls => rect_ls,
			fill => rect_fill,
			draw =>  rect_draw,
			pixel_valid => rect_pixel_valid,
			pixel_x => rect_pixel_x,
			pixel_y => rect_pixel_y,
			pixel_color => rect_pixel_color
		);


		--to set x_fifo full flag if x_fifo is full
		gfx_instr_full <= instr_fifo_full;
		gfx_data_full <= data_fifo_full;
		
	--rasterizer

		--to set the predefined patterns
		pattern_0 <= "000000001000100000000";
		pattern_7 <= "000000000000000010001";

		rasterizer : process(all) 

			--calculates address in dp_video_ram from passed x- and y-coord and saves the specified color at it in dp_video_ram
				procedure write_pixel_to_dp_vram(x_coord_data : std_logic_vector(log2c(SCREEN_RESOLUTION_WIDTH)-1 downto 0); y_coord_data : std_logic_vector(log2c(SCREEN_RESOLUTION_HEIGHT)-1 downto 0); color : std_logic_vector(1 downto 0)) is
					variable x_int, y_int, address_value_int : integer;
				begin
					--calculate corresponding address in dp_vram and feed signal dp_video_ram_wr_addr with it
					x_int := (to_integer(unsigned(x_coord_data)));
					y_int := (to_integer(unsigned(y_coord_data)));
					address_value_int := x_int + y_int * SCREEN_RESOLUTION_WIDTH;
					dp_video_ram_wr_addr_next <= std_logic_vector(to_unsigned(address_value_int, DP_VIDEO_RAM_ADDR_WIDTH));

					--define color for to be stored pixel
					dp_video_ram_wr_data_next <= color;

					--store pixel into dp_video_ram
					dp_video_ram_wr_next <= '1';

				end procedure;
			
		begin
			--signal_next <= signal
				state_next <= state;
				current_instruction_next <= current_instruction;
				op_step_next <= op_step;
				gfx_frame_sync_next <= gfx_frame_sync;
				new_vbs_frame_next <= new_vbs_frame;
				write_primary_read_secondary_vram_next <= write_primary_read_secondary_vram;
				
				--fifo buffer
				instr_fifo_rd_next <= instr_fifo_rd;
				data_fifo_rd_next <= '0';

				--read data
				read_data_counter_next <= read_data_counter;
				data_needed_next <= data_needed;
				current_data_next <= current_data;
				current_data_one_next <= current_data_one;
				current_data_two_next <= current_data_two;
				current_data_three_next <= current_data_three;
				current_data_four_next <= current_data_four;

				--clear
				y_next <= y;
				x_next <= x;

				--color
				primary_color_next <= primary_color;
				secondary_color_next <= secondary_color;

				--pattern
				current_pattern_next <= current_pattern;
				pattern_1_next <= pattern_1;
				pattern_2_next <= pattern_2;
				pattern_3_next <= pattern_3;
				pattern_4_next <= pattern_4;
				pattern_5_next <= pattern_5;
				pattern_6_next <= pattern_6;

				double_buffering_next <= double_buffering;

				--gfx_line
				line_start_next <= line_start;
				line_x0_next <= line_x0;
				line_x1_next <= line_x1;
				line_y0_next <= line_y0;
				line_y1_next <= line_y1;
				
				--gfx_circle
				circle_start_next <= circle_start;
				circle_x_center_next <= circle_x_center;
				circle_y_center_next <= circle_y_center;
				circle_radius_next <= circle_radius;

				--rect
				rect_start_next <= rect_start;
				rect_draw_next <= rect_draw;
				rect_fill_next <= rect_fill;
				rect_x_next <= rect_x;
				rect_y_next <= rect_y;
				rect_w_next <= rect_w;
				rect_h_next <= rect_h;
				rect_bw_next <= rect_bw;
				rect_bh_next <= rect_bh;
				rect_dx_next <= rect_dx;
				rect_dy_next <= rect_dy;
				rect_ls_next <= rect_ls;

				--write port signals
				dp_video_ram_wr_addr_next <= dp_video_ram_wr_addr;	
				dp_video_ram_wr_data_next <= dp_video_ram_wr_data;	
				dp_video_ram_wr_next <= dp_video_ram_wr;

				if frame_reader_frame_start then
					new_vbs_frame_next <= '1';
				else 
					new_vbs_frame_next <= '0';
				end if;

			case state is
			
				when CHECK_NEW_INSTR =>
					op_step_next <= 0;
					dp_video_ram_wr_next <= '0'; 
					if instr_fifo_empty = '1' then
						state_next <= CHECK_NEW_INSTR;
					else
						instr_fifo_rd_next <= '1';	
						state_next <= WAIT_UNTIL_READ_INSTR_READY;
					end if;

				when WAIT_UNTIL_READ_INSTR_READY =>

						state_next <= READ_INSTR;
						instr_fifo_rd_next <= '0';

				when READ_INSTR =>

						current_instruction_next <= instr_fifo_rd_data;
						state_next <= HANDLE_INSTR;
			
				when CHECK_DATA_AVAILABILITY =>
					
						if data_fifo_empty = '1' then
							state_next <= CHECK_DATA_AVAILABILITY;
						else
							--set data_fifo_rd signal high, so that it's possible to read from the fifo
							data_fifo_rd_next <= '1';
							state_next <= WAIT_UNTIL_READ_DATA_READY;
						end if;
				
				when WAIT_UNTIL_READ_DATA_READY =>

					state_next <= READ_DATA;
					data_fifo_rd_next <= '0';

				when READ_DATA =>
							
							--apply new data to comparison signal
							current_data_next <= data_fifo_rd_data;
							--increase counter to show that additional value has been read
							read_data_counter_next <= read_data_counter +1;
							
							case read_data_counter is
								when 0 =>
									current_data_one_next <= data_fifo_rd_data;
								when 1 =>
									current_data_two_next <= data_fifo_rd_data;
								when 2 =>
									current_data_three_next <= data_fifo_rd_data;
								when 3 =>
									current_data_four_next <= data_fifo_rd_data;
								when others =>
							end case;
						
							if (read_data_counter+1) /= data_needed then
								state_next <= CHECK_DATA_AVAILABILITY;
							else
								read_data_counter_next <= 0;
								state_next <= HANDLE_INSTR;
							end if;
						
				when HANDLE_INSTR =>

					--FORMAT A
					if is_instr_format_A(current_instruction) then

						case( current_instruction(3 downto 0) ) is
							when OPCODE_NOP =>
								--do nothing
								state_next <= CHECK_NEW_INSTR;
							when OPCODE_CLEAR => 
								--loop through whole dp_video_ram and set every value to secondary_color

									--check if end of column
									if x = 399 then
										x_next <= 0;
										
										--check if all pixels have been processed
										if y = 239 then
											state_next <= CHECK_NEW_INSTR;
											dp_video_ram_wr_next <= '0'; 
											y_next <= 0;
											
										else
											--if not, handle next row
											y_next <= y+1;
											state_next <= HANDLE_INSTR;
										end if;
									else
										--if not end of column, process next pixel in row
										x_next <= x+1;
										state_next <= HANDLE_INSTR;
									end if;

									write_pixel_to_dp_vram(std_logic_vector(to_unsigned(x, log2c(SCREEN_RESOLUTION_WIDTH))), std_logic_vector(to_unsigned(y, log2c(SCREEN_RESOLUTION_HEIGHT))), secondary_color);
									

							when OPCODE_FRAME_SYNC =>
									--blocks instructions until start of new frame is frame_start signal has a rising_edge

									if op_step = 0 then
										--check if frame_start has a rising edge (-> new frame in 2 clk_cycles)
										if frame_reader_frame_start then
											op_step_next <= op_step+1;
											
											--switch buffers if double buffering is enabled
											if double_buffering then
												write_primary_read_secondary_vram_next <= not write_primary_read_secondary_vram;
											end if;

										end if;
										
										state_next <= HANDLE_INSTR;
										
									elsif op_step <= 2 then
										--wait two clk_cycles until frame_reader actually starts to fetch a new frame
										--assert gfx_frame_sync for one clk_cycle when new frame starts

										if op_step = 2 then
											gfx_frame_sync_next <= '1';
										end if;

										state_next <= HANDLE_INSTR;
										op_step_next <= op_step+1;
									else
										gfx_frame_sync_next <= '0';
										state_next <= CHECK_NEW_INSTR;
									end if;

							when OPCODE_SET_PIXEL =>

								if op_step = 0 then
									--get necessary data
									state_next <= CHECK_DATA_AVAILABILITY;
									data_needed_next <= 2;
									op_step_next <= op_step+1;
								elsif op_step = 1 then
									--save pixel colored in the prim_color into dp_vram
									write_pixel_to_dp_vram(current_data_one(log2c(SCREEN_RESOLUTION_WIDTH)-1 downto 0), current_data_two(log2c(SCREEN_RESOLUTION_HEIGHT)-1 downto 0), primary_color);
									state_next <= CHECK_NEW_INSTR;
								end if;
								
							when OPCODE_DRAW_LINE =>
								
								if op_step = 0 then
									--get necessary data
									state_next <= CHECK_DATA_AVAILABILITY;
									data_needed_next <= 4;
									op_step_next <= op_step +1;
								elsif op_step = 1 then
									--pass drawing parameters to function
									line_x0_next <= current_data_one(log2c(SCREEN_RESOLUTION_WIDTH)-1 downto 0);
									line_y0_next <= current_data_two(log2c(SCREEN_RESOLUTION_HEIGHT)-1 downto 0);
									line_x1_next <= current_data_three(log2c(SCREEN_RESOLUTION_WIDTH)-1 downto 0);
									line_y1_next <= current_data_four(log2c(SCREEN_RESOLUTION_HEIGHT)-1 downto 0);

									--initiate drawing operation
									line_start_next <= '1';

									state_next <= HANDLE_INSTR;
									op_step_next <= op_step +1;
								elsif op_step = 2 then
									line_start_next <= '0';	
									state_next <= HANDLE_INSTR;
									op_step_next <= op_step +1;
								else 

									--while line is busy -> expect outputs
									if line_busy = '1' then
										--if valid output is recieved, put it into the dp_vram
										if line_pixel_valid = '1' then
											--handle output: write calculated pixel intp dp_video_ram
											write_pixel_to_dp_vram(line_pixel_x, line_pixel_y, primary_color);
										end if;
										state_next <= HANDLE_INSTR;
									else 
										state_next <= CHECK_NEW_INSTR;
										dp_video_ram_wr_next <= '0';
									end if;

								end if;

							when OPCODE_DRAW_CIRCLE =>

								if op_step = 0 then
									--get necessary data
									state_next <= CHECK_DATA_AVAILABILITY;
									data_needed_next <= 3;
									op_step_next <= op_step +1;
								elsif op_step = 1 then
									
									--pass drawing parameters to function
									circle_x_center_next <= current_data_one(log2c(SCREEN_RESOLUTION_WIDTH)-1 downto 0);
									circle_y_center_next <= current_data_two(log2c(SCREEN_RESOLUTION_HEIGHT)-1 downto 0);
									circle_radius_next <= current_data_three(log2c(SCREEN_RESOLUTION_WIDTH)-1 downto 0);

									--initiate drawing operation
									circle_start_next <= '1';

									state_next <= HANDLE_INSTR;
									op_step_next <= op_step +1;
								
								elsif op_step = 2 then
									circle_start_next <= '0';	
									state_next <= HANDLE_INSTR;
									op_step_next <= op_step +1;
								else

									--while line is busy -> expect outputs
									if circle_busy = '1' then
										--if valid output is recieved, put it into the dp_vram
										if circle_pixel_valid = '1' then
											--handle output: write calculated pixel intp dp_video_ram
											write_pixel_to_dp_vram(circle_pixel_x, circle_pixel_y, primary_color);
										end if;
										state_next <= HANDLE_INSTR;
									else 
										state_next <= CHECK_NEW_INSTR;
										dp_video_ram_wr_next <= '0';
									end if;

								end if;

							when others => 
								--report "invalid instruction format recognized";
						end case;
					--FORMAT B
					elsif is_instr_format_B(current_instruction) then
						
						case( current_instruction(5 downto 4) ) is
							when OPCODE_SET_CFG =>
								double_buffering_next <= true;
								state_next <= CHECK_NEW_INSTR;
							when OPCODE_SET_COLOR =>
								
								if op_step = 0 then
									--get necessary data
									state_next <= CHECK_DATA_AVAILABILITY;
									data_needed_next <= 1;
									op_step_next <= op_step+1;
								else
									case( current_instruction(0) ) is
										when '1' =>
										--primary color
											primary_color_next <= current_data_one(1 downto 0);
										when '0' =>
										--secondary color
											secondary_color_next <= current_data_one(1 downto 0);
										when others =>
											--report "invalid instruction format recognized";
									end case ;
									state_next <= CHECK_NEW_INSTR;
								end if;

							when OPCODE_SET_PATTERN =>
									
								if op_step = 0 then 
									state_next <= CHECK_DATA_AVAILABILITY;
									data_needed_next <= 2;
									op_step_next <= op_step+1;
								else
									case(current_instruction(2 downto 0)) is
										when "001" =>
											pattern_1_next <= current_data_two(4 downto 0) & current_data_one;
										when "010" =>
											pattern_2_next <= current_data_two(4 downto 0) & current_data_one;
										when "011" =>
											pattern_3_next <= current_data_two(4 downto 0) & current_data_one;
										when "100" =>
											pattern_4_next <= current_data_two(4 downto 0) & current_data_one;
										when "101" =>
											pattern_5_next <= current_data_two(4 downto 0) & current_data_one;
										when "110" =>
											pattern_6_next <= current_data_two(4 downto 0) & current_data_one;
										when others =>
											--ignore pattern ID 0 and 7
									end case ;
									state_next <= CHECK_NEW_INSTR; 
								end if;

							when others =>
								--report "invalid instruction format recognized";
						end case ;
					--FORMAT C
					elsif is_instr_format_C(current_instruction) then
						case( current_instruction(6 downto 5) ) is
							when OPCODE_DRAW_RECT =>
								
								if op_step = 0 then
									--get necessary data
									state_next <= CHECK_DATA_AVAILABILITY;
									data_needed_next <= 4;
									op_step_next <= op_step +1;
								elsif op_step = 1 then
									
									--pass drawing parameters to function
									rect_x_next <= current_data_one(log2c(SCREEN_RESOLUTION_WIDTH)-1 downto 0);
									rect_y_next <= current_data_two(log2c(SCREEN_RESOLUTION_HEIGHT)-1 downto 0);
									rect_w_next <= current_data_three(log2c(SCREEN_RESOLUTION_WIDTH)-1 downto 0);
									rect_h_next <= current_data_four(log2c(SCREEN_RESOLUTION_HEIGHT)-1 downto 0);

									--if border should be drawn of not (1 -> drawn, 0 -> not drawn)
									rect_draw_next <= current_instruction(3);

									--defines if rectangle should be filled. if alpha_mode is enabled, this should be false
									rect_fill_next <= '1';

									--pass pattern defined by instruction to rect_component
									case(current_instruction(2 downto 0)) is
										when "000" =>
											current_pattern_next <= pattern_0;
										when "001" =>
											current_pattern_next <= pattern_1;
										when "010" =>
											current_pattern_next <= pattern_2;
										when "011" =>
											current_pattern_next <= pattern_3;
										when "100" =>
											current_pattern_next <= pattern_4;
										when "101" =>
											current_pattern_next <= pattern_5;
										when "110" =>
											current_pattern_next <= pattern_6;
										when "111" =>
											current_pattern_next <= pattern_7;
										when others =>
											--not possible
									end case ;

									state_next <= HANDLE_INSTR;
									op_step_next <= op_step +1;

								elsif op_step = 2 then
									
									rect_ls_next <= current_pattern(20 downto 16);
									rect_dx_next <= current_pattern(15 downto 12);
									rect_dy_next <= current_pattern(11 downto 8);
									rect_bw_next <= current_pattern(7 downto 4);
									rect_bh_next <= current_pattern(3 downto 0);

									state_next <= HANDLE_INSTR;
									op_step_next <= op_step +1;
								
								elsif op_step = 3 then

									--initiate drawing operation
									op_step_next <= op_step +1;
									rect_start_next <= '1';
									state_next <= HANDLE_INSTR;

								elsif op_step = 4 then

									op_step_next <= op_step +1;
									rect_start_next <= '0';
									state_next <= HANDLE_INSTR;

								else

									--while rect is busy -> expect outputs
									if rect_busy = '1' then
										--if valid output is recieved, put it into the dp_vram
										if rect_pixel_valid = '1' then
											--handle output: write calculated pixel intp dp_video_ram
											if rect_pixel_color = '1' then
												--part of pattern (primary color)
												write_pixel_to_dp_vram(rect_pixel_x, rect_pixel_y, primary_color);
											else
												--not part of pattern (secondary color or nothing (alpha mode))
												if current_instruction(4) = '0' then
													--otherwise alpha mode is enabled and only pixel which are part of the pattern should be drawn
													write_pixel_to_dp_vram(rect_pixel_x, rect_pixel_y, secondary_color);
												end if ;
											end if ;
										end if;
										state_next <= HANDLE_INSTR;
									else 
										state_next <= CHECK_NEW_INSTR;
										dp_video_ram_wr_next <= '0';
									end if;

								end if;

							when others =>
								--report "invalid instruction format recognized";
						end case ;

					else
						--report "invalid instruction format recognized";
					end if ;

				when others =>
			
			end case;
		end process ; -- rasterizer

--double/single buffering

	double_buffering_process : process(all)
	begin
		--initial next assignment
			--read port signals
				dp_video_ram_rd_data <= (others => '0');																						

			--primary_buffer_signals
				--read port signals 
				dp_primary_video_ram_rd_addr <= (others => '0');		
				dp_primary_video_ram_rd <= '0';											
				--write port signals
				dp_primary_video_ram_wr_addr <= (others => '0');	
				dp_primary_video_ram_wr_data <= (others => '0');	
				dp_primary_video_ram_wr <= '0';	

			--secondary_buffer_signals	
				--read port signals 
				dp_secondary_video_ram_rd_addr <= (others => '0');			
				dp_secondary_video_ram_rd <= '0';													
				--write port signals
				dp_secondary_video_ram_wr_addr <= (others => '0');	
				dp_secondary_video_ram_wr_data <= (others => '0');	
				dp_secondary_video_ram_wr <= '0';

		if (double_buffering = true) then
			--double buffering is enabled

			if write_primary_read_secondary_vram = true then

				--write to primary buffer and read from secondary
				dp_secondary_video_ram_rd_addr <= dp_video_ram_rd_addr; 						
				dp_video_ram_rd_data <= dp_secondary_video_ram_rd_data; 						
				dp_secondary_video_ram_rd <= dp_video_ram_rd; 								
				dp_primary_video_ram_wr_addr <= dp_video_ram_wr_addr;									
				dp_primary_video_ram_wr_data <= dp_video_ram_wr_data;						
				dp_primary_video_ram_wr <= dp_video_ram_wr;

			else

				--write to secondary buffer and read from primary
				dp_primary_video_ram_rd_addr <= dp_video_ram_rd_addr; 						
				dp_video_ram_rd_data <= dp_primary_video_ram_rd_data; 						
				dp_primary_video_ram_rd <= dp_video_ram_rd; 							
				dp_secondary_video_ram_wr_addr <= dp_video_ram_wr_addr;									
				dp_secondary_video_ram_wr_data <= dp_video_ram_wr_data;						
				dp_secondary_video_ram_wr <= dp_video_ram_wr;
			
			end if;

		else
			--double buffering is disabled
			--read and write only to primary buffer
			dp_primary_video_ram_rd_addr <= dp_video_ram_rd_addr; 						
			dp_video_ram_rd_data <= dp_primary_video_ram_rd_data; 						
			dp_primary_video_ram_rd <= dp_video_ram_rd;								
			dp_primary_video_ram_wr_addr <= dp_video_ram_wr_addr;									
			dp_primary_video_ram_wr_data <= dp_video_ram_wr_data;						
			dp_primary_video_ram_wr <= dp_video_ram_wr;

		end if;

	end process;	



--external interface
	/*
	--test_bench_generator_instantiation
		tpg_instatiation : tpg 
		generic map (
			WIDTH => SCREEN_RESOLUTION_WIDTH,
			HEIGHT => SCREEN_RESOLUTION_HEIGHT
		)
		port map(
			clk => clk,
			res_n => res_n,
			pix_rd => frame_reader_next_pixel,
			pix_data => frame_reader_data
		);
	*/
	
	vga_r <= (others => '0');
	vga_b <= (others => '0');
	vga_g <= vga_g_sig;

	vga_clk <= clk;

	vga_blank_n <= vga_blank_sig;
	vga_sync_n <= vga_sync_sig;

	external_interface : process(all)
		
		--constants

			--scanline duration: 64microsec															-> /clk(0.02microsec) 	-> 3200 clk_cycles/scanline
			constant scanline_duration			: integer := 3200;
			constant scanline_duration_half		: integer := 1600;
				
			--vbs format times
				--h_sync_duration = broad_sync_pulse_duration: 						4.7microsec 	-> 	/clk(0.02 microsec)	-> 235 clk_cycles/scanline
				--short_sync_pulse_duration: 		 broad_sync_pulse_duration /2 = 2.35microsec	-> 	/clk(0.02 microsec)	-> 117.5 clk_cycles/scanline
				--broad_sync_low_duration: 	   (scanline duration/2)-4.7microsec) = 27.3microsec	->	/clk(0.02 microsec)	-> 1365 clk_cycles/scanline
				--short_sync_low_duration: 	 ((scanline_duration/2)-2.35microsec) = 29.65microsec	->	/clk(0.02 microsec)	-> 1482.5 clk_cycles/scanline
				--back_porch_duration: 												5.7microsec 	-> 	/clk(0.02 microsec) -> 285 clk_cycles/scanline
				--front_porch_duration: 											1.65microsec	-> 	/clk(0.02 microsec)	-> 82.5 clk_cycles/scanline
				--display_area_duration: 											51.95microsec	-> 	/clk(0.02 microsec)	-> 2597.5 clk_cycles/scanline
				
			constant h_sync_duration 			: integer := 235;
			constant broad_sync_pulse_duration 	: integer := 235;
			constant short_sync_pulse_duration 	: integer := 118;
			constant broad_sync_low_duration	: integer := 1365;
			constant short_sync_low_duration	: integer := 1482;
			constant back_porch_duration		: integer := 285;
			constant front_porch_duration		: integer := 83;
			constant display_area_duration		: integer := 2597;

			


		--functions & procedures
			--returns hex value corresponding to passed color parameter
				function color_setter(color_data : std_logic_vector(1 downto 0)) return std_logic_vector is
					begin
						case(color_data) is
							when "00" =>
								return "00000000";	--black
							when "01" =>
								return "00001000"; 	--darkgray
							when "10" =>
								return "00001111"; 	--lightgray
							when others =>
								return "11111111"; 	--white
						end case ;
					end function;
		
			--broad_sync_section_line
				procedure broad_sync_section_line is
				begin
					if ((clk_cycle_counter <= broad_sync_low_duration-1) or (clk_cycle_counter = scanline_duration)) then
					--1 -> 1365
						--0V
						vga_blank_sig_next <= '0';
						vga_sync_sig_next 	<= '0';

					elsif (clk_cycle_counter <= (scanline_duration_half)-1) then
					--1366 -> 1600
						--0.3V
						vga_blank_sig_next <= '0';
						vga_sync_sig_next 	<= '1';

					elsif (clk_cycle_counter <= (scanline_duration-broad_sync_pulse_duration)-1) then 
					-- 1601 -> 2965
						--0V
						vga_blank_sig_next <= '0';
						vga_sync_sig_next 	<= '0';

					else
					-- 2966 -> 3200 
						--0.3V
						vga_blank_sig_next <= '0';
						vga_sync_sig_next 	<= '1';

					end if;
				end procedure;

			--short_sync_section_line
				procedure short_sync_section_line is
				begin
					if ((clk_cycle_counter <= short_sync_pulse_duration-1) or (clk_cycle_counter = scanline_duration)) then
						--0V
						vga_blank_sig_next <= '0';
						vga_sync_sig_next 	<= '0';

					elsif (clk_cycle_counter <= (scanline_duration_half)-1) then
						--0.3V
						vga_blank_sig_next <= '0';
						vga_sync_sig_next 	<= '1';

					elsif (clk_cycle_counter <= (scanline_duration_half)+short_sync_pulse_duration-1) then
						--0V
						vga_blank_sig_next <= '0';
						vga_sync_sig_next 	<= '0';

					else
						--0.3V
						vga_blank_sig_next <= '0';
						vga_sync_sig_next 	<= '1';

					end if;
				end procedure;

			--broad_short_sync_section_line
				procedure broad_short_sync_section_line is
				begin
					if ((clk_cycle_counter <= broad_sync_low_duration-1) or (clk_cycle_counter = scanline_duration)) then
						--0V
						vga_blank_sig_next <= '0';
						vga_sync_sig_next 	<= '0';

					elsif (clk_cycle_counter <= (scanline_duration_half)-1) then
						--0.3V
						vga_blank_sig_next <= '0';
						vga_sync_sig_next 	<= '1';
					
					elsif (clk_cycle_counter <= (scanline_duration_half)+short_sync_pulse_duration-1) then
						--0V
						vga_blank_sig_next <= '0';
						vga_sync_sig_next 	<= '0';

					else
						--0.3V
						vga_blank_sig_next <= '0';
						vga_sync_sig_next 	<= '1';

					end if;
				end procedure;

			--short_broad_sync_section_line
				procedure short_broad_sync_section_line is
					begin
						if ((clk_cycle_counter <= short_sync_pulse_duration-1) or (clk_cycle_counter = scanline_duration)) then
							--0V
							vga_blank_sig_next <= '0';
							vga_sync_sig_next 	<= '0';
	
						elsif (clk_cycle_counter <= (scanline_duration_half)-1) then
							--0.3V
							vga_blank_sig_next <= '0';
							vga_sync_sig_next 	<= '1';
						
						elsif (clk_cycle_counter <= (scanline_duration_half)+broad_sync_low_duration-1) then
							--0V
							vga_blank_sig_next <= '0';
							vga_sync_sig_next 	<= '0';
	
						else
							--0.3V
							vga_blank_sig_next <= '0';
							vga_sync_sig_next 	<= '1';
	
						end if;
					end procedure;

			--blank_line
			
				procedure blank_line is
					begin
						if ((clk_cycle_counter <= h_sync_duration-1) or (clk_cycle_counter = scanline_duration)) then
							--1 -> 235
							--0V
							vga_blank_sig_next <= '0';
							vga_sync_sig_next 	<= '0';
					
						else

							--0.3V
							vga_blank_sig_next <= '0';
							vga_sync_sig_next 	<= '1';
			
						end if;
					end procedure;


			
			--blank_short_sync_section_line
				procedure blank_short_sync_section_line is
				begin
					if ((clk_cycle_counter <= h_sync_duration-1) or (clk_cycle_counter = scanline_duration)) then
						--0V
						vga_blank_sig_next <= '0';
						vga_sync_sig_next 	<= '0';

					elsif (clk_cycle_counter <= (scanline_duration_half)-1) then
								
						--0.3V
						vga_blank_sig_next <= '0';
						vga_sync_sig_next 	<= '1';

					elsif (clk_cycle_counter <= ((scanline_duration_half)+short_sync_pulse_duration-1)) then
						
						--0V
						vga_blank_sig_next <= '0';
						vga_sync_sig_next 	<= '0';
	
					else
						--0.3V
						vga_blank_sig_next <= '0';
						vga_sync_sig_next 	<= '1';
	
					end if;
				end procedure;
			
			--short_sync_blank_line

				procedure short_sync_blank_line is
					begin
						if ((clk_cycle_counter <= short_sync_pulse_duration-1) or (clk_cycle_counter = scanline_duration)) then
							--0V
							vga_blank_sig_next <= '0';
							vga_sync_sig_next 	<= '0';
						
						else
							--0.3V
							vga_blank_sig_next <= '0';
							vga_sync_sig_next 	<= '1';
	
						end if;
					end procedure;

			--data_line

				procedure data_line is
				begin
					
					if ((clk_cycle_counter <= h_sync_duration-1) or (clk_cycle_counter = scanline_duration)) then
					--1 -> 235
						--0V
						vga_blank_sig_next <= '0';
						vga_sync_sig_next 	<= '0';

					elsif (clk_cycle_counter <= (h_sync_duration + back_porch_duration)-1) then
					--236 -> 520 
						--0.3V
						vga_blank_sig_next <= '0';
						vga_sync_sig_next 	<= '1';
						
					elsif (clk_cycle_counter <= (scanline_duration - front_porch_duration)-1) then
					-- 521 -> 3117	

						--2597 data clk_cycles /400 x-pixel -> 6.4925 clk_cycles/x-pixel -> 6 clk_cycles/x-pixel, 197 clk_cycles not written

						--frame_reader_next_pixel <= '1' on clk_cycle -1(next_signal!) before reading from frame_reader starts
						--6 clk_cycles per data, every 6th clk_cycle
							--520 is earliest possible clk_cycle to read
						--data should be central in image -> 197 clk_cycle to much -> 98 on one side, 99 on the other of 0.3V
						--time to read from frame reader: h_sync_duration + back_porch_duration + 99	until	scanline_duration - front_porch_duration - 99 

						if (clk_cycle_counter  <= (h_sync_duration + back_porch_duration + 98)-1) then
							--521 -> 618
							--leave blank to position frame in middle of screen

							--assert signal to get new pixel from frame_reader in next clk_cycle

							--make sure that data can pass
							vga_blank_sig_next <= '0';
							vga_sync_sig_next 	<= '1';

							if (clk_cycle_counter = (h_sync_duration + back_porch_duration + 98-2)) then
							--616
								--617: frame_reader_next_pixel <= '1';
								--618: new data at sig_next
								--619: new data at sig
								frame_reader_next_pixel_next <= '1';
							end if;

							if (clk_cycle_counter  = (h_sync_duration + back_porch_duration + 98)-1) then
								frame_reader_next_pixel_next <= '0';
								mod_counter_next <= 2;
							end if;

						elsif (clk_cycle_counter <= (scanline_duration - front_porch_duration - 99)-1) then
						--619 -> 3018

							--make sure that data can pass
							vga_blank_sig_next <= '1';
							vga_sync_sig_next 	<= '1';

							vga_g_sig_next <= color_setter(frame_reader_data);

							--assert frame_reader_next_pixel in every sixth step
								--frame_reader_next_pixel -> frame_reader_next -> new pixel ... -> = clk_cycle
								--first pixel starts at 619, at 624 new pixel shall be available
									--frame_reader_next_pixel shall be assigned at 622, 628, ...
									--no new pixel at 3017, cannot be processed in this line anymore

							--every 6th value new pixel is requested, +1 because of next_pixel; only set new pixel if < 3017, otherwise a pixel is lost
							if (mod_counter = 6) and (clk_cycle_counter < 3016) then 
								frame_reader_next_pixel_next <= '1';
								mod_counter_next <= 1;
							else
								frame_reader_next_pixel_next <= '0';
								mod_counter_next <= mod_counter +1;
								
							end if;

						else
						--3019 -> 3117
							frame_reader_next_pixel_next <= '0';

							--make sure that data can pass
							vga_blank_sig_next <= '0';
							vga_sync_sig_next 	<= '1';

						end if;
	
					else
						--3118 -> 3200
						--0.3V
						vga_blank_sig_next <= '0';
						vga_sync_sig_next 	<= '1';
	
					end if;
				end procedure;
				

	begin

			line_counter_next <= line_counter;
			vga_g_sig_next <= vga_g_sig;
			clk_cycle_counter_next <= clk_cycle_counter;
			vga_blank_sig_next <= vga_blank_sig;
			vga_sync_sig_next <= vga_sync_sig;
			frame_reader_next_pixel_next <= frame_reader_next_pixel;
			mod_counter_next <= mod_counter;

			--use SYNC only when BLANK is used
			--BLANK = 0 is used to reach 0.3V
			--adding SYNC = 0 as well can be used to reach 0V 
			--to transmit data, set BLANK to high (hence also SYNC should be high)

			if (((line_counter < 3) and (not ((line_counter = 2) and (clk_cycle_counter = scanline_duration)))) or ((line_counter = 625) and (clk_cycle_counter = scanline_duration) ) ) then

				broad_sync_section_line;

			elsif (((line_counter = 3) and (not(clk_cycle_counter = scanline_duration))) or ((line_counter = 2) and (clk_cycle_counter = scanline_duration))) then

				broad_short_sync_section_line;
				
			elsif (((line_counter < 6) and (not ((line_counter = 5) and (clk_cycle_counter = scanline_duration)))) or ((line_counter = 3) and (clk_cycle_counter = scanline_duration))) then
				
				short_sync_section_line;

			elsif (((line_counter < 47) and (not ((line_counter = 46) and (clk_cycle_counter = scanline_duration)))) or ((line_counter = 5) and (clk_cycle_counter = scanline_duration))) then

				blank_line;

			elsif (((line_counter < 287) and (not ((line_counter = 286) and (clk_cycle_counter = scanline_duration)))) or ((line_counter = 46) and (clk_cycle_counter = scanline_duration))) then

				data_line;

			elsif (((line_counter < 311) and (not ((line_counter = 310) and (clk_cycle_counter = scanline_duration)))) or ((line_counter = 286) and (clk_cycle_counter = scanline_duration))) then

				blank_line;

			elsif (((line_counter < 313) and (not ((line_counter = 312) and (clk_cycle_counter = scanline_duration)))) or ((line_counter = 310) and (clk_cycle_counter = scanline_duration))) then

				short_sync_section_line;

			elsif (((line_counter = 313) and (not ((line_counter = 313) and (clk_cycle_counter = scanline_duration)))) or ((line_counter = 312) and (clk_cycle_counter = scanline_duration))) then

				short_broad_sync_section_line;

			elsif (((line_counter < 316) and (not ((line_counter = 315) and (clk_cycle_counter = scanline_duration)))) or ((line_counter = 313) and (clk_cycle_counter = scanline_duration))) then

				broad_sync_section_line;

			elsif (((line_counter < 318) and (not ((line_counter = 317) and (clk_cycle_counter = scanline_duration)))) or ((line_counter = 315) and (clk_cycle_counter = scanline_duration))) then

				short_sync_section_line;

			elsif (((line_counter = 318) and (not ((line_counter = 318) and (clk_cycle_counter = scanline_duration)))) or ((line_counter = 317) and (clk_cycle_counter = scanline_duration))) then

				short_sync_blank_line;

			elsif (((line_counter < 359) and (not ((line_counter = 358) and (clk_cycle_counter = scanline_duration)))) or ((line_counter = 318) and (clk_cycle_counter = scanline_duration))) then

				blank_line;

			elsif (((line_counter < 599) and (not ((line_counter = 598) and (clk_cycle_counter = scanline_duration)))) or ((line_counter = 358) and (clk_cycle_counter = scanline_duration))) then
				
				data_line;

			elsif (((line_counter < 623) and (not ((line_counter = 622) and (clk_cycle_counter = scanline_duration)))) or ((line_counter = 598) and (clk_cycle_counter = scanline_duration))) then
				
				blank_line;	

			elsif (((line_counter = 623) and (not ((line_counter = 623) and (clk_cycle_counter = scanline_duration)))) or ((line_counter = 622) and (clk_cycle_counter = scanline_duration))) then

				blank_short_sync_section_line;

			elsif (((line_counter < 626) and (not ((line_counter = 625) and (clk_cycle_counter = scanline_duration)))) or ((line_counter = 623) and (clk_cycle_counter = scanline_duration))) then

				short_sync_section_line;
	
			end if;

			if (clk_cycle_counter = 3200) then
				clk_cycle_counter_next <= 1;
				
				if line_counter = 625 then
					line_counter_next <= 1;

				else 
					line_counter_next <= line_counter + 1;
				end if;
			else 
				clk_cycle_counter_next <= clk_cycle_counter +1;

			end if;

	end process ; -- external_interface
	

end arch ;



