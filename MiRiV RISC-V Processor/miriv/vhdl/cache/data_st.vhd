library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mem_pkg.all;
use work.cache_pkg.all;
use work.single_clock_rw_ram_pkg.all;

entity data_st is
	generic (
		SETS_LD  : natural := SETS_LD;
		WAYS_LD  : natural := WAYS_LD
	);
	port (
		clk        : in std_logic;

		we         : in std_logic;			--control updating stored data
		rd         : in std_logic;			--control reading stored data
		way        : in c_way_type;			--way to be accessed (for adv. implementation)
		index      : in c_index_type;		--index i.e. set to be accessed
		byteena    : in mem_byteena_type;	--byte-enable signal for sub-word writes

		data_in    : in mem_data_type;		--for updating stored data
		data_out   : out mem_data_type		--for recieveing stored data
);
end entity;

architecture impl of data_st is
	type DATA_OUT_ARRAY_TYPE is array(0 to (WAYS_LD-1)) of mem_data_type;	
	signal data_out_array : DATA_OUT_ARRAY_TYPE := (others => (others => '0'));
	signal current_way, last_way : integer := 0;
	
begin
			
		--calculate correct current_way in integer-format
		current_way <= last_way when (to_integer(unsigned(way)) = 0) else
							  0 when (to_integer(unsigned(way)) = 1) else
							  1 when (to_integer(unsigned(way)) = 2) else
						      2 when (to_integer(unsigned(way)) = 4) else 
							  3;

		--data_1w instances for every way
		data_st_1w_gen : for i in 0 to WAYS_LD-1 generate	
			signal correct_way : std_logic;
		begin
			data_st_1w : entity work.data_st_1w
			generic map (
				SETS_LD  => SETS_LD
			)
			port map (
				clk       => clk,
		
				we        => we and correct_way,	--contorl updating stored data			
				rd        => rd and correct_way,	--control reading stored data
				index     => index,					--index i.e. set to be accessed
				byteena   => byteena,				--byte-enable signal for sub-word writes
		
				data_in   => data_in,				--for updating stored data
				data_out  => data_out_array(i)		--for receiving stored data
			);

			--calculate if this generated instance of mgmt_st_1w is the correct way
			correct_way <= '1' when (i = current_way) else '0';

		end generate;

		--set output to output of correct way
		data_out <= data_out_array(current_way);

		SYNC_PROC : process(clk)
		begin
			if rising_edge(clk) then
				last_way <= current_way;
			end if;
		end process;

end architecture;
