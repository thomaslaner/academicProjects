library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.mem_pkg.all;
use work.cache_pkg.all;

entity cache is
	generic (
		SETS_LD   : natural          := SETS_LD;
		WAYS_LD   : natural          := WAYS_LD;
		ADDR_MASK : mem_address_type := (others => '1')
	);
	port (
		clk   : in std_logic;
		res_n : in std_logic;

		mem_out_cpu : in  mem_out_type;					--data_output of cpu
		mem_in_cpu  : out mem_in_type;					--data_input into cpu
		mem_out_mem : out mem_out_type;					--data_output of memory
		mem_in_mem  : in  mem_in_type					--data_input into memory
	);
end entity;

architecture bypass of cache is 						--bypass cache for exIII and testing
	alias cpu_to_cache : mem_out_type is mem_out_cpu; 
	alias cache_to_cpu : mem_in_type is mem_in_cpu;   
	alias cache_to_mem : mem_out_type is mem_out_mem; 
	alias mem_to_cache : mem_in_type is mem_in_mem;   
begin
	cache_to_mem <= cpu_to_cache; 						--mem_out_mem <= mem_out_cpu;
	cache_to_cpu <= mem_to_cache;						--mem_in_cpu <= mem_in_mem; 
end architecture;

architecture impl of cache is

	alias cpu_output : mem_out_type is mem_out_cpu; 
	alias cpu_input : mem_in_type is mem_in_cpu;   
	alias mem_input : mem_out_type is mem_out_mem; 
	alias mem_output : mem_in_type is mem_in_mem;  
	
	constant ADDR_MASK_INT : integer := to_integer(unsigned(ADDR_MASK));

	type state_type is (IDLE, READ_CACHE, READ_MEM_START, READ_MEM, WRITE_BACK_START, WRITE_BACK);
	signal state, state_next : state_type;

	signal busy, busy_next	: std_logic;

	--tag, set_index
		--explanation
		--| tag | set_index | offset | = |11|3|0| (with initial inputs)
		--offset: starting point of data in  is 0 bits wide since memory interface operates on same word-length as processor (32 bits -> block = memory unit in processor)
		--set_index: determines chache set
		-- Direct mapped cache:
		-- 	#blocks is a power of 2
		--	Cache address = (Block address) mod (#blocks in cache)
		--	Cache size = log_2{#Blocks}
		-- 	If data in location: valid bit = 1, else 0 (=> initially set to 0)
		-- 	Index size = n for a 2^n cache
		--	Address offset = 0
		--	Tag size = 32 - index size
		--	Word size = 32 

		-- => for example: 32 bit address with a 2^10 cache =>
		--		Index = 10 bits, Tag = 22 bits, Valid bit = 1 bit
	signal set_index, set_index_next, st_index_in : std_logic_vector(INDEX_SIZE-1 downto 0) := (others => '0');
	signal tag, tag_next, st_tag_in : std_logic_vector(TAG_SIZE-1 downto 0) := (others => '0');

	--data_st input signals
	signal data_st_we_in	: std_logic;
	signal data_st_rd_in	: std_logic;
	signal data_st_data_in 	: mem_data_type;

	--data_st output signals
	signal data_st_data_out : mem_data_type;

	--mgmt_st input signals
	signal mgmt_st_wr_in	: std_logic;
	signal mgmt_st_valid_in	: std_logic;
	signal mgmt_st_dirty_in	: std_logic;

	--mgmt_st output signals
	signal mgmt_st_way_out 	 : c_way_type;
	signal mgmt_st_dirty_out : std_logic;
	signal mgmt_st_tag_out	 : std_logic_vector(TAG_SIZE-1 downto 0) := (others => '0');
	signal mgmt_st_hit_out 	 : std_logic;

begin

--cache management instantiation
	mgmt_st_inst : entity work.mgmt_st
		generic map (
			SETS_LD  => SETS_LD,
			WAYS_LD  => WAYS_LD
		)
		port map (
			clk   => clk,
			res_n => res_n,
	
			index => st_index_in,				--index i.e. to be accessed set
			wr    => mgmt_st_wr_in,				--control updating management info
			rd    => '0',						--control reading management info - unused in my implementation
	
			valid_in    => mgmt_st_valid_in,	--valdidity info of entry to be written
			dirty_in    => mgmt_st_dirty_in,	--dirty info of entry to be written
			tag_in      => st_tag_in,			--tag of entry to be written
			
			way_out     => mgmt_st_way_out,		--way where hit ocurred or where data has to be updated (for adv. implementation)
			valid_out   => open,				--validity info of accessed entry (used inside of mgmt_st for hit_out)
			dirty_out   => mgmt_st_dirty_out,	--dirty info of accessed entry
			tag_out     => mgmt_st_tag_out,		--tag of accessed entry
			hit_out     => mgmt_st_hit_out		--hit
		);

		--set index and tag either from cpu_output directly or from the registered cpu_output depending on state of fsm

		--set mgmt inputs either directly to cpu_output if fsm is in idle state (input is directly relayed to mgmt_in)
		--or to the corresponding internal signal (if operation is ongoing)
		st_index_in <= cpu_output.address((ADDR_WIDTH - TAG_SIZE)-1 downto 0) when state = IDLE else set_index;
		st_tag_in 	 <= cpu_output.address(ADDR_WIDTH-1 downto (ADDR_WIDTH - TAG_SIZE)) when state = IDLE else tag;

--data storage instantiation
	data_st_inst : entity work.data_st
		generic map (
			SETS_LD => SETS_LD,
			WAYS_LD => WAYS_LD
		)
		port map (
			clk        => clk,

			we         => data_st_we_in,		--control updating stored data
			rd         => data_st_rd_in,		--control reading stored data
			way        => mgmt_st_way_out,		--way to be accessed (for adv. implementation)
			index      => st_index_in,			--index i.e. set to be accessed
			byteena    => cpu_output.byteena, 	--byte-enable signal for sub-word writes

			data_in    => data_st_data_in,		--for updating stored data
			data_out   => data_st_data_out		--for recieveing stored data
		);

--sync
	SYNC_PROC : process(clk, res_n)
		begin
			if res_n = '0' then

				set_index <= (others => '0');
				tag <= (others => '0');

				state <= IDLE;
				busy <= '0';
		
			elsif rising_edge(clk) then

				set_index <= set_index_next;
				tag   <= tag_next;
				
				state <= state_next;
				busy  <= busy_next;
				
			end if;
		end process;

--cache_fsm
	CACHE_FSM_PROC : process(all)
	begin
		--standard signal assignments
			state_next <= IDLE;
			busy_next  <= busy;

			--index & tag
			set_index_next <= set_index;
			tag_next 	   <= tag;

			--mgmt inputs
			mgmt_st_wr_in 	 <= '0';
			mgmt_st_valid_in <= '0';
			mgmt_st_dirty_in <= '0';

			--data inputs
			data_st_we_in 	<= '0';
			data_st_rd_in 	<= '0';
			data_st_data_in <= (others => '0');

			--component outputs
			cpu_input  <= (busy => busy, rddata => data_st_data_out);
			mem_input  <= (address => (others => '0'), rd => '0', wr => '0', byteena => (others => '0'), wrdata => (others => '0'));  

		--FSM
			case state is

				when IDLE =>
				--no memory operation ongoing (no memory request from processor)

				--set index & tag according to new inputs
				set_index_next <= cpu_output.address((ADDR_WIDTH - TAG_SIZE)-1 downto 0);
				tag_next <= cpu_output.address(ADDR_WIDTH-1 downto (ADDR_WIDTH - TAG_SIZE));

				-- if (((cpu_output.address AND not ADDR_MASK) /= 14x"0000")) then
				if (to_integer(unsigned(cpu_output.address)) > ADDR_MASK_INT) then
					--bypass cache if access to device is performed (if a bit of address not set by ADDR_MASK is high)
						--ex: UART uses mem to communicate with CPU
						mem_input <= cpu_output;				
						cpu_input <= mem_output;
				else 

					if cpu_output.rd = '1' then
						--starting read operation

							--check output of mgmt_st - if data corresponding to read request can be found in cache
							if mgmt_st_hit_out then
								--on read_hit: return cached data by using data from data_st
								report "read_hit" severity note;

								data_st_rd_in <= '1';		--activate rd signal of data_st
								busy_next <= '1';						
								state_next <= READ_CACHE;
										
							else 
								--on read_miss: fetch data from memory, add it into corresponding cache location and provide data to cpu

								busy_next <= '1';

								if mgmt_st_dirty_out = '1' then
									report "read_miss (dirty)" severity note;
									state_next <= WRITE_BACK_START;
								else
									report "read_miss (clean)" severity note;
									state_next <= READ_MEM_START;
								end if;

							end if;
						
						elsif cpu_output.wr = '1' then
						--starting write operation

							if mgmt_st_hit_out then
							--on write_hit: update location in cache and mark location as dirty
								report "write_hit" severity note;
								
								--no busy flag -> write immediately
								state_next <= IDLE;
								
								--update data_st
								data_st_we_in <= '1';		--activate wr signal of data_st
								data_st_data_in <= mem_output.rddata;
								
								--update mgmt_st
								mgmt_st_wr_in <= '1';
								mgmt_st_dirty_in <= '1';			
								mgmt_st_valid_in <= '1';			--location is still valid
							else 
							-- on write_miss: write to main memory without fetching into cache	
								report "write_miss" severity note;
								mem_input <= cpu_output;				
								state_next <= IDLE;
							end if;

						end if;

					end if;

					
				when READ_CACHE =>
				--read access to cache
					--data of cache on output is valid as soon as busy is low
					busy_next <= '0';
					state_next <= IDLE;

				when WRITE_BACK_START =>
				--first cycle of memory write if evicted cache location was dirty
					mem_input <= (address => mgmt_st_tag_out & set_index, rd => '0', wr => '1', byteena => (others => '1'), wrdata => data_st_data_out);
					state_next <= WRITE_BACK;

				when WRITE_BACK =>
				--finishing write operation
						
					if mem_output.busy = '1' then
					--loop until write operation to mem is completed (busy low)
						state_next <= WRITE_BACK;
					else 
						state_next <= READ_MEM_START;
					end if;

				when READ_MEM_START =>
				--first cycle of memory read (assert read line to memory)

					mem_input <= (address => cpu_output.address, rd => '1', wr => '0', byteena => cpu_output.byteena, wrdata => (others => '0'));
					state_next <= READ_MEM;

				when READ_MEM =>
				--waiting for memory request to finish and write result into cache

					if mem_output.busy = '1' then
					--loop until data is provided by mem (busy goes low)
						state_next <= READ_MEM;
					else 
					--write data from mem into cache
						
						--update mgmt_st
						mgmt_st_wr_in <= '1';
						mgmt_st_dirty_in <= '0';
						mgmt_st_valid_in <= '1';

						--update data_st
						data_st_we_in <= '1';
						data_st_data_in <= mem_output.rddata;
						
						state_next <= IDLE;
						busy_next <= '0';

					
					
					end if;

			end case;

	end process;

end architecture;
