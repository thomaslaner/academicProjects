library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mem_pkg.all;
use work.cache_pkg.all;

entity mgmt_st_1w is
	generic (
		SETS_LD  : natural := SETS_LD
	);
	port (
		clk     : in std_logic;
		res_n   : in std_logic;

		index   : in c_index_type;			--index i.e. to be accessed set
		we      : in std_logic;				--cntrol updating management info
		we_repl	: in std_logic;				--control updating the replacement info

		mgmt_info_in  : in c_mgmt_info;		--for updating manegement info
		mgmt_info_out : out c_mgmt_info		--for recieving stored management info
	);
end entity;

architecture impl of mgmt_st_1w is

	--empty const for mgmt_info
	constant MGMT_INFO_EMPTY : c_mgmt_info := (valid => '0', dirty => '0', replace => '0', tag => (others => '0'));

	--storage using registers that contains mgmt_info of this way
	type MGMT_MEM_TYPE is array(0 to ((2**SETS_LD)-1)) of c_mgmt_info;
	constant EMPTY_MGMT_MEM : MGMT_MEM_TYPE := (others => MGMT_INFO_EMPTY);	--used for reset
	signal mgmt_mem : MGMT_MEM_TYPE := EMPTY_MGMT_MEM;

	--current set calculated out of index
	signal current_set : integer := 0;
begin
		
	LOGIC_PROC : process(all)
	begin
		if res_n = '0' then
			
			--delete all management info on reset
			mgmt_mem <= EMPTY_MGMT_MEM;

		elsif rising_edge(clk) then

			if we = '1' then
				--overwrite stored value if we is high
				mgmt_mem(current_set) <= mgmt_info_in;
				mgmt_mem(current_set).valid <= '1';
			end if;

			if we_repl = '1' then
				--overwrite stored replace value
				mgmt_mem(current_set).replace <= '0';
			end if;

		end if;

	end process;

	--set current index
	current_set <= to_integer(unsigned(index));
	
	--set output to mgmt_st.vhd
	mgmt_info_out <= mgmt_mem(to_integer(unsigned(index)));

end architecture;
