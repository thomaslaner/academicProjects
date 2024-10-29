library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mem_pkg.all;
use work.cache_pkg.all;
use work.single_clock_rw_ram_pkg.all;

entity data_st_1w is
	generic (
		SETS_LD  : natural := SETS_LD
	);
	port (
		clk       : in std_logic;

		we        : in std_logic;			--contorl updating stored data
		rd        : in std_logic;			--control reading stored data
		index     : in c_index_type;		--index i.e. set to be accessed
		byteena   : in mem_byteena_type;	--byte-enable signal for sub-word writes

		data_in   : in mem_data_type;		--for updating stored data
		data_out  : out mem_data_type		--for receiving stored data
);
end entity;

architecture impl of data_st_1w is
begin

--explanation of generate usage
	--i:	    	i=3		  i=2	    i=1	    i=0   	
	--data:	|31 --- 24|23 --- 16|15 --- 8|7 --- 0|	

	--i=x -> data_out((7+(i*8)) downto (0+(i*8)))
		--i=0	-> data_out((7+(0*8)) downto (0+(0*8))) = data_out(7 downto 0)
		--i=1	-> data_out((7+(1*8)) downto (0+(1*8))) = data_out(15 downto 8)
		--i=2	-> data_out((7+(2*8)) downto (0+(2*8))) = data_out(23 downto 16)
		--i=3	-> data_out((7+(3*8)) downto (0+(3*8))) = data_out(31 downto 24)

--generate a ram for each byte in DATA (32bit)
	RAM_BYTEi_INST : for i in 0 to BYTEEN_WIDTH-1 generate
		ram_inst : entity work.single_clock_rw_ram
			generic map (
				ADDR_WIDTH => SETS_LD,
				DATA_WIDTH => DATA_WIDTH/BYTEEN_WIDTH
			)	
			port map (
				clk 			=> clk,
				data_in			=> data_in((7+(i*8)) downto (0+(i*8))),		--depends on byte instantiation covers
				write_address	=> index,									--stays the same in all 4 byte-instantations
				read_address	=> index,									--stays the same in all 4 byte-instantations
				we				=> (we and byteena(i)),						--only activated byteenas shall be written 				
				data_out		=> data_out((7+(i*8)) downto (0+(i*8)))		--depends on byte instantiation covers
			);
	end generate;
end architecture;
