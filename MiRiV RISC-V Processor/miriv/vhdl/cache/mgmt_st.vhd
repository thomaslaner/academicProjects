library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.mem_pkg.all;
use work.cache_pkg.all;

entity mgmt_st is
	generic (
		SETS_LD  : natural := SETS_LD;
		WAYS_LD  : natural := WAYS_LD
	);
	port (
		clk   : in std_logic;
		res_n : in std_logic;

		index : in c_index_type;		--index i.e. to be accessed set
		wr    : in std_logic;			--control updating management info
		rd    : in std_logic;			--control reading management info	(unused in my implementation - replacement policy operates only on write)

		valid_in    : in std_logic;		--valdidity info of entry to be written
		dirty_in    : in std_logic;		--dirty infor of entry to be written
		tag_in      : in c_tag_type;	--tag of entry to be written
		way_out     : out c_way_type;	--way where hit ocurred or where data has to be updated (for adv. implementation)
		valid_out   : out std_logic;	--validity info of accessed entry
		dirty_out   : out std_logic;	--dirty info of accessed entry
		tag_out     : out c_tag_type;	--tag of accessed entry
		hit_out     : out std_logic		--hit						
	);
end entity;

architecture impl of mgmt_st is

	--signal definitions
		signal current_way, last_way, hit_way : integer := 0;		--used to save current_way, last used current_way and way in which a hit has been registered
		signal index_integer : integer := 0;						--used to save integer representation of index
		signal hit_internal : std_logic := '0';

	--memories for replacement policy
		--[way_3, way_2, way_1, way_0] = "0000" / [way_1, way_0] = "00" / [way_0] = "0"
		type REPL_MEM_TYPE is array(0 to ((2**SETS_LD)-1)) of std_logic_vector(WAYS_LD-1 downto 0);		
		constant EMPTY_REPL_MEM : REPL_MEM_TYPE := (others => (others => '0'));						--used for reset
		signal repl_mem, repl_mem_update : REPL_MEM_TYPE := EMPTY_REPL_MEM;							--used to save repl info
		signal valid_mem : REPL_MEM_TYPE := EMPTY_REPL_MEM;											--used to save valid info
		signal dirty_mem : REPL_MEM_TYPE := EMPTY_REPL_MEM;											--used to save dirty info
						
		--> data flow: 				repl_out	->	mgmt_st_1w_in	->	mgmt_st_1w_out		->		cache.vhd & repl_in	->	repl_out ... 
		--								  	 repl_mem								   repl_mem_update

		--> repl_mem:					input: repl_out				output: mgmt_st_1w_in
		--> repl_mem_update:			input: mgmt_st_1w_out		output: cache.vhd & repl_in


	--memory for output
		type MGMT_INFO_OUT_ARRAY_TYPE is array(0 to (WAYS_LD-1)) of c_mgmt_info;
		constant EMPTY_MGMT_INFO_OUT_ARRAY_TYPE : MGMT_INFO_OUT_ARRAY_TYPE := (others => (valid => '0', dirty => '0', replace => '0', tag => (others => '0')));	--used for reset	
		signal mgmt_info_out_array : MGMT_INFO_OUT_ARRAY_TYPE := EMPTY_MGMT_INFO_OUT_ARRAY_TYPE;

begin

	--calculate integer representation of current index input
	index_integer <= to_integer(unsigned(index));

	--calculate correct current_way in integer-format
	current_way <= last_way when (to_integer(unsigned(repl_mem(index_integer))) = 0) else
						  0 when (to_integer(unsigned(repl_mem(index_integer))) = 1) else
						  1 when (to_integer(unsigned(repl_mem(index_integer))) = 2) else
						  2 when (to_integer(unsigned(repl_mem(index_integer))) = 4) else 
						  3;

	--mgmt_1w instances for every way
	mgmt_st_1w_gen : for i in 0 to (WAYS_LD-1) generate
		signal correct_way : std_logic;
	begin	
		mgmt_st_1w : entity work.mgmt_st_1w
		generic map (
			SETS_LD  => SETS_LD
		)
		port map (
			clk     => clk,
			res_n   => res_n,

			index   => index,																								--index i.e. to be accessed set
			we      => wr and valid_in and correct_way,																		--control updating management info
			we_repl	=> wr and valid_in and correct_way,																							--control updating the replacement info
												
			mgmt_info_in  => (valid => valid_in, dirty => dirty_in, replace => repl_mem(index_integer)(i), tag => tag_in),	--for updating menegement info	
			mgmt_info_out => mgmt_info_out_array(i)																			--for recieving stored management info
		);

		--calculate if this generated instance of mgmt_st_1w is the correct way
		correct_way <= '1' when (i = current_way) else '0';
	
	end generate;

	LOGIC_PROC : process(all)
	begin

		if res_n = '0' then

			--reset internal mgmt_memories
			repl_mem_update  <= EMPTY_REPL_MEM;
			valid_mem <= EMPTY_REPL_MEM;
			dirty_mem <= EMPTY_REPL_MEM;

			hit_internal <= '0';
			hit_way <= 0;

		else
			if rising_edge(clk) then 

				--update internal mgmt_memories with output of correct way
				repl_mem_update(index_integer)(current_way) <= mgmt_info_out_array(current_way).replace;
				valid_mem(index_integer)(current_way) <= mgmt_info_out_array(current_way).valid;
				dirty_mem(index_integer)(current_way) <= mgmt_info_out_array(current_way).dirty;
				last_way <= current_way;

			end if;

			hit_internal <= '0';
			hit_way <= 0;

			for i in 0 to (WAYS_LD-1) loop
				if ((mgmt_info_out_array(i).tag = tag_in) and (mgmt_info_out_array(i).valid = '1')) then
					hit_way <= i; 
					hit_internal <= '1';
				end if;
			end loop;

		end if;

	end process;

	--output towards cache.vhd
	hit_out   <= hit_internal;
	valid_out <= mgmt_info_out_array(hit_way).valid when hit_internal else mgmt_info_out_array(current_way).valid;
	dirty_out <= mgmt_info_out_array(hit_way).dirty when hit_internal else mgmt_info_out_array(current_way).dirty;
	tag_out   <= mgmt_info_out_array(hit_way).tag when hit_internal else mgmt_info_out_array(current_way).tag;
	way_out	  <= std_logic_vector(to_unsigned((2**hit_way), WAYS_LD)) when hit_internal else repl_mem(index_integer);
		--1000 -> 3
		--0100 -> 2
		--0010 -> 1
		--0001 -> 0	

	--replacement policy instantiations for the differents SETS
	repl_gen : for j in 0 to ((2**SETS_LD)-1) generate
		repl_inst : entity work.repl
		generic map (
			WAYS  => WAYS_LD
		)
		port map (
			valid_in    => valid_mem(j),		--valid information of all ways of the current set
			dirty_in    => dirty_mem(j),		--dirty information of all ways of the current set
			replace_in  => repl_mem_update(j),	--replacement information of all ways of the current set
			replace_out => repl_mem(j)			--updated replacement information for all ways of the current set
		);
	end generate;
	
end architecture;