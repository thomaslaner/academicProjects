library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mem_pkg.all;
use work.cache_pkg.all;

entity repl is
	generic (
		WAYS  : natural := WAYS
	);
	port (
		valid_in    : in std_logic_vector(WAYS-1 downto 0);		--valid information of all ways of the current set
		dirty_in    : in std_logic_vector(WAYS-1 downto 0);		--dirty information of all ways of the current set
		replace_in  : in std_logic_vector(WAYS-1 downto 0);		--replacement information of all ways of the current set
		replace_out : out std_logic_vector(WAYS-1 downto 0)		--updated replacement information for all ways of the current set
);
end entity;

architecture impl of repl is
begin
		
	ONE_WAY: if WAYS = 1 generate
	
			--since there is only one way, replace it if necessary

			--replace_in:	[0]
			replace_out <= "1";

	elsif WAYS = 2 generate
				
		LOGIC_PROC : process(all)
			--if true -> the lower way shall be switched
			variable lower_way_least_recently_used : std_logic := '1';
		begin

			if replace_in = "00" then
			--if replace is needed

				-- replace_in:	[0,0]
				-- valid_in:	[0,0]

				--lowest priority: invalid entries (lowest way when multiple are present)
				if valid_in(0) = '0' then
					--if entry at way_0 is invalid - use it for replacements
					replace_out <= "01";
					
				elsif valid_in(1) = '0' then
					--if entry at way_1 is invalid - use it for replacements
					replace_out <= "10";

				else
				--if all entries are valid: evict entry which hasn't been used the longest time

					if lower_way_least_recently_used = '1' then
						replace_out <= "01";
						lower_way_least_recently_used := '0';
					else
						replace_out <= "10";
						lower_way_least_recently_used := '1';
					end if;

				end if;

			else

				replace_out <= replace_in;

			end if;

		end process;

	elsif WAYS = 4 generate

		LOGIC_PROC : process(all)
			--if true -> the lower way shall be switched
			variable lower_way_least_recently_used : std_logic := '1';
		begin

			if replace_in = "0000" then
			--if replace is needed

				-- replace_in:	[0,0,0,0]
				-- valid_in:	[0,0,0,0]
				-- dirty_in:	[0,0,0,0]

				--lowest priority: invalid entries (lowest way when multiple are present)
				if valid_in(0) = '0' then
					--if entry at way_0 is invalid - use it for replacements
					replace_out <= "0001";
					
				elsif valid_in(1) = '0' then
					--if entry at way_1 is invalid - use it for replacements
					replace_out <= "0010";
				
				elsif valid_in(2) = '0' then
					--if entry at way_2 is invalid - use it for replacements
					replace_out <= "0100";
				
				elsif valid_in(3) = '0' then
					--if entry at way_3 is invalid - use it for replacements
					replace_out <= "1000";

				else
				--if all entries are valid: evict entry which hasn't been used the longest time

					-- replace_in:	[0,0,0,0]	-> [0,0],[0,0]
					-- valid_in:	[0,0,0,0]	-> [0,0],[0,0]
					-- dirty_in:	[0,0,0,0]	-> [0,0],[0,0]

					if lower_way_least_recently_used = '1' then
						--if set 1 has been lru
						if dirty_in(0) = '0' then
							--if entry_0 is not dirty, replace it
							replace_out <= "0001";
						elsif dirty_in(1) = '0' then
							--if entry_1 is not dirty and entry_0 is dirty, replace entry_1
							replace_out <= "0010";
						else
							--if entry_0 and entry_1 are dirty, replace entry_0
							replace_out <= "0001";
						end if;

						lower_way_least_recently_used := '0';

					else
						--if set 2 has been lru
						if dirty_in(2) = '0' then
							--if entry_3 is not dirty, replace it
							replace_out <= "0100";
						elsif dirty_in(3) = '0' then
							--if entry_4 is not dirty and entry_3 is dirty, replace entry_4
							replace_out <= "1000";
						else
							--if entry_3 and entry_4 are dirty, replace entry_3
							replace_out <= "0100";
						end if;

						lower_way_least_recently_used := '1';

					end if;

				end if;

			else

				replace_out <= replace_in;

			end if;

		end process;

	else generate

		LOGIC_PROC : process(all)
		begin
			report "INVALID AMOUNT OF WAYS CHOSEN" severity error;
			replace_out <= (others => '0');					
		end process;

	end generate;

end architecture;
