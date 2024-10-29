library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.gfx_if_pkg.all;

package vbs_graphics_controller_pkg is

	constant COLOR_DEPTH         : integer := 2;

	component vbs_graphics_controller is
		generic (
			CLK_FREQ : integer := 50_000_000
		);
		port (
			clk : in std_logic;
			res_n : in std_logic;
			gfx_instr : in std_logic_vector(GFX_INSTR_WIDTH-1 downto 0);
			gfx_instr_wr : in std_logic;
			gfx_instr_full : out std_logic;
			gfx_data : in std_logic_vector(GFX_DATA_WIDTH-1 downto 0);
			gfx_data_wr : in std_logic;
			gfx_data_full : out std_logic;
			gfx_frame_sync : out std_logic;
			vga_r : out std_logic_vector(7 downto 0);
			vga_g : out std_logic_vector(7 downto 0);
			vga_b : out std_logic_vector(7 downto 0);
			vga_clk : out std_logic;
			vga_sync_n : out std_logic;
			vga_blank_n : out std_logic
		);
	end component;

	component tpg is
		generic (
			WIDTH : integer;
			HEIGHT : integer
		);
		port (
			clk : in std_logic;
			res_n : in std_logic;
			pix_rd : in std_logic;
			pix_data : out std_logic_vector(1 downto 0)
		);
	end component;

	component frame_reader is
		generic (
			WIDTH : integer;
			HEIGHT : integer;
			VRAM_ADDR_WIDTH : integer;
			VRAM_DATA_WIDTH : integer
		);
		port (
			clk : in std_logic;
			res_n : in std_logic;
			frame_start : out std_logic;
			vram_base_addr : in std_logic_vector(VRAM_ADDR_WIDTH-1 downto 0) := 	(others=>'0');
			vram_rd : out std_logic;
			vram_addr : out std_logic_vector(VRAM_ADDR_WIDTH-1 downto 0);
			vram_data : in std_logic_vector(VRAM_DATA_WIDTH-1 downto 0);
			pix_rd : in std_logic;
			pix_data : out std_logic_vector(VRAM_DATA_WIDTH-1 downto 0)
		);
	end component;

end package;

