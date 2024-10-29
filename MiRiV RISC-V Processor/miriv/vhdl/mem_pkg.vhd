library ieee;
use ieee.std_logic_1164.all;

package mem_pkg is

	-- width of a dataword
	constant DATA_WIDTH_BITS  : integer := 5;
	constant DATA_WIDTH       : integer := 2**DATA_WIDTH_BITS;	--32

	constant BYTE_WIDTH       : integer := 8;
	constant BYTES_PER_WORD   : integer := (DATA_WIDTH+BYTE_WIDTH-1)/BYTE_WIDTH;	--4

	-- bits to address memory
	-- NOTE: these are word addresses
	constant ADDR_WIDTH       : integer := 14;

	constant BYTEEN_WIDTH     : integer := DATA_WIDTH/BYTE_WIDTH;	--4

	subtype mem_address_type    is std_logic_vector(ADDR_WIDTH-1 downto 0);		-- type for memory addresses
	subtype mem_data_type       is std_logic_vector(DATA_WIDTH-1 downto 0);		-- type for actual data transferred to / from memory
	subtype mem_byteena_type    is std_logic_vector(BYTEEN_WIDTH-1 downto 0);	-- type for byte enable

	-- NOTE: memory direction (in, out) is seen from RiscV.
	type mem_out_type is
	record
		address  : mem_address_type;	-- address to read from or write to
		rd, wr   : std_logic;			-- asserted for rd/wr
		byteena  : mem_byteena_type;	-- byte-enable signal for sub-word writes
		wrdata   : mem_data_type;		-- data to be written
	end record;

	constant MEM_OUT_NOP : mem_out_type := (
		address => (others => '0'),
		rd      => '0',
		wr      => '0',
		byteena => (others => '1'),
		wrdata  => (others => '0')
	);

	type mem_in_type is
	record
		busy   : std_logic;		-- memory busy
		rddata : mem_data_type;	-- actual data read from memory
	end record;

	constant MEM_IN_NOP : mem_in_type := (
		busy   => '0',
		rddata => (others => '0')
	);

	subtype mem_out_range_type is natural range DATA_WIDTH + ADDR_WIDTH + 1 + 1 + BYTEEN_WIDTH - 1 downto 0;
	subtype mem_in_range_type  is natural range DATA_WIDTH + 1 - 1 downto 0;

	pure function to_std_logic_vector(i : mem_out_type) return std_logic_vector;
	pure function to_std_logic_vector(i : mem_in_type)  return std_logic_vector;
	pure function to_mem_out_type(i : std_logic_vector(mem_out_range_type)) return mem_out_type;
	pure function to_mem_in_type(i : std_logic_vector(mem_in_range_type)) return mem_in_type;

end package;

package body mem_pkg is

	pure function to_std_logic_vector(i : mem_out_type) return std_logic_vector is
	begin
		return i.address & i.wrdata & i.wr & i.rd & i.byteena;
	end function;

	pure function to_mem_out_type(i : std_logic_vector(mem_out_range_type)) return mem_out_type is
		variable ofs : natural := 0;
		variable ret : mem_out_type;
	begin
		ret.byteena := i(ofs + BYTEEN_WIDTH - 1 downto ofs);
		ofs := ofs + BYTEEN_WIDTH;
		ret.rd := i(ofs);
		ofs := ofs + 1;
		ret.wr := i(ofs);
		ofs := ofs + 1;
		ret.wrdata := i(ofs + DATA_WIDTH - 1 downto ofs);
		ofs := ofs + DATA_WIDTH;
		ret.address := i(ofs + ADDR_WIDTH - 1 downto ofs);
		return ret;
	end function;

	pure function to_std_logic_vector(i : mem_in_type)  return std_logic_vector is
	begin
		return i.busy & i.rddata; 
	end function;

	pure function to_mem_in_type(i : std_logic_vector(mem_in_range_type)) return mem_in_type is
	begin
		return mem_in_type'(
			rddata => i(31 downto 0), 
			busy   => i(32)
		);
	end function;

end package body;
