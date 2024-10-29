library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use ieee.std_logic_textio.all;
use work.lcd_graphics_controller_pkg.all;

entity sram is
	generic (
		OUTPUT_DIR   : string  := "./"
	);
	port (
		-- SRAM interface
		dq     : inout std_logic_vector(15 downto 0);
		addr   : in	std_logic_vector(19 downto 0);
		lb_n   : in	std_logic;
		ub_n   : in	std_logic;
		ce_n   : in	std_logic;
		oe_n   : in	std_logic;
		we_n   : in	std_logic;

		-- on rising_edge: dump frame to file
		write_file : in std_logic;
		base_address : natural := 0;
		width        : natural := 400;
		height       : natural := 240
	);
end entity;


architecture arch of sram is

	--storage	
	type storage_array is array (0 to 999999) of std_logic_vector(15 downto 0); --define type of storage
	signal storage : storage_array := (others => (others => '0')); --initialize storage with 0
	
	--time_constants
	constant t_doe : time := 8 ns;

	constant t_sce : TIME := 6.5 ns;
	constant t_sd : TIME := 5 ns;
	constant t_lzwe : TIME := 2 ns;

begin
	
	sram_process : process
		variable valid_addr : integer := 0;
	begin
		
		if ce_n = '1' then
			--chip not enabled
			dq <= (others => 'Z');
		else
			if lb_n = '1' and ub_n = '1' then
				--output disabled
				dq <= (others => 'Z');
			elsif we_n = '1' then 
				if oe_n = '1' then
					--output disabled
					dq <= (others => 'Z');
				elsif falling_edge(oe_n) then 
					
				--read from sram

					valid_addr := to_integer(unsigned(addr));

					report "HELLO I'M ALIVE!";

					wait for t_doe;

					dq <= storage(valid_addr);

					wait until rising_edge(oe_n);

				end if;

			elsif falling_edge(we_n) then
			--write into sram

				--get valid addr and wait for writing timeslot
				valid_addr := to_integer(unsigned(addr));
				wait for (t_sce-t_sd);

				-- report "dq: " & to_string(dq) & "addr: " & to_string(valid_addr) & "storage_before: " & to_string(storage(valid_addr));

				--store new value at addr and wait until end of writing time
				storage(valid_addr) <= dq;
				wait for t_lzwe;

				-- report " ------ storage_afterwards: " & to_string(storage(valid_addr));

			end if;

		end if;
		wait on lb_n, ub_n, ce_n, we_n;
	end process ; -- sram_process	

	image_dump : process

		file file_pointer : text;
		variable file_mode : FILE_OPEN_KIND := write_mode; --in which type file should be opened
		variable row : line; --serves as buffer for write/read operations

		function getFileName(counter: integer) return string is
		begin
			return OUTPUT_DIR & "sram_dump_" & integer'image(counter) & ".ppm";	
		end function; --getFileName

		variable red_string : integer;
		variable green_string : integer;
		variable blue_string : integer;

		variable counter : integer := 0;

	begin
		
		wait until rising_edge(write_file);

		--open file, and adjust counter for next use
		file_open(file_pointer, getFileName(counter), file_mode);
		counter := counter +1;

		--write header
			
			--write magic number to file
			swrite(row, "P3");
			writeline(file_pointer, row);
			
			--write img resolution to file
			swrite(row, integer'image(width) & " " & integer'image(height));
			writeline(file_pointer, row);

			--write max value for color to file 
			swrite (row, "16");
			writeline(file_pointer, row);

		--write image data

			report "START WRITING TO IMG_FILE";

			row_loop : for y in 0 to height-1 loop
				column_loop : for x in 0 to width-1 loop

					red_string := to_integer(unsigned(get_red(storage(base_address + y*width + x))));
					green_string := to_integer(unsigned(get_green(storage(base_address + y*width + x))));
					blue_string := to_integer(unsigned(get_blue(storage(base_address + y*width + x))));

					write(row, integer'image(red_string) & " " & integer'image(green_string) & " " & integer'image(blue_string));
					writeline(file_pointer, row);

				end loop ; -- column_loop
			end loop ; -- row_loop

			file_close(file_pointer);

			report "DONE WRITING TO IMG_FILE";

	--termination of process closes opened file
	end process ; -- image_dump
	

	

	


end architecture;

