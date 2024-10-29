library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library std; -- for Printing
use std.textio.all;

use work.mem_pkg.all;
use work.op_pkg.all;
use work.core_pkg.all;
use work.tb_util_pkg.all;

entity tb is
end entity;

architecture bench of tb is
  
	constant CLK_PERIOD : time := 10 ns;

	signal clk : std_logic;
	signal res_n : std_logic := '0';
	signal stop : boolean := false;
	
	file input_file : text;
	file output_ref_file : text;

	subtype addr is std_logic_vector(REG_BITS-1 downto 0);
	subtype data is std_logic_vector(DATA_WIDTH-1 downto 0);

	type memory_array_type is array (0 to ((2**ADDR_WIDTH)-1)) of mem_data_type;
	signal mem_simulation : memory_array_type := (others => (others => '0'));

	type input_t is
	record
		stall   :	std_logic;
		flush   :	std_logic;
		pcsrc  	:	std_logic;
		pc_in	:	pc_type;
		mem_in 	:	mem_in_type;
	end record;

	type output_t is
	record
		mem_busy	:	std_logic;
		pc_out		:	pc_type;
		instr     	:	instr_type;
		mem_out  	:	mem_out_type;
	end record;

	signal input_signal  : input_t := (
		stall => '0',
        flush => '0',
		pcsrc => '0',
		pc_in => (others => '0'),
		mem_in => MEM_IN_NOP
	);

	signal output_signal : output_t;

	impure function read_next_input(file f : text) return input_t is
		variable l : line;
		variable result : input_t;
	begin

		--stall

		l := get_next_valid_line(f);
		result.stall := str_to_sl(l(1));

		--flush

		l := get_next_valid_line(f);
		result.flush := str_to_sl(l(1));

		--pcsrc

		l := get_next_valid_line(f);
		result.pcsrc := str_to_sl(l(1));

		--pc_in

		l := get_next_valid_line(f);
		result.pc_in := bin_to_slv(l.all, PC_WIDTH);

		--mem_in

		l := get_next_valid_line(f);
		result.mem_in.busy := str_to_sl(l(1));

		
		result.mem_in.rddata := mem_simulation(to_integer(unsigned(output_signal.mem_out.address)));

		return result;
	end function;

	impure function read_next_output(file f : text) return output_t is
		variable l : line;
		variable result : output_t;
	begin

		--mem_busy

		l := get_next_valid_line(f);
		result.mem_busy := str_to_sl(l(1));

		--pc_out

		l := get_next_valid_line(f);
		result.pc_out := bin_to_slv(l.all, PC_WIDTH);

		--instr

		l := get_next_valid_line(f);
		result.instr := hex_to_slv(l.all, INSTR_WIDTH);

		--mem_out

		l := get_next_valid_line(f);
		result.mem_out.address := bin_to_slv(l.all, ADDR_WIDTH);

		l := get_next_valid_line(f);
		result.mem_out.rd := str_to_sl(l(1));

		l := get_next_valid_line(f);
		result.mem_out.wr := str_to_sl(l(1));

		l := get_next_valid_line(f);
        result.mem_out.byteena := bin_to_slv(l.all, BYTEEN_WIDTH);

		l := get_next_valid_line(f);
		result.mem_out.wrdata := bin_to_slv(l.all, DATA_WIDTH);

		return result;
	end function;

	procedure check_output(output_ref : output_t) is
		variable passed : boolean;
	begin
		passed := (output_signal = output_ref);

		if passed then
			report " PASSED: "
			& "stall="     & std_logic'image(input_signal.stall)
			& " flush=" 	& std_logic'image(input_signal.flush)
            & " pcsrc=" & std_logic'image(input_signal.pcsrc)
			& " pc_in=" & to_string(input_signal.pc_in)
            & " mem_in.busy=" & std_logic'image(input_signal.mem_in.busy)
			& " mem_in.rddata=" & to_string(input_signal.mem_in.rddata) & lf

			--& "**      output:   mem_busy= " & std_logic'image(output_ref.mem_busy) & " pc_out= " & to_string(output_ref.pc_out) & " instr= " & to_string(output_ref.instr) & " mem_out.address= " & to_string(output_ref.mem_out.address) & lf

			severity note;
		else
			report "FAILED: "
			& "stall="     & std_logic'image(input_signal.stall)
			& " flush=" 	& std_logic'image(input_signal.flush)
            & " pcsrc=" & std_logic'image(input_signal.pcsrc)
			& " pc_in=" & to_string(input_signal.pc_in)
            & " mem_in.busy=" & std_logic'image(input_signal.mem_in.busy)
			& " mem_in.rddata=" & to_string(input_signal.mem_in.rddata) & lf

			& "**      expected: mem_busy= " & std_logic'image(output_ref.mem_busy) & " pc_out= " & to_string(output_ref.pc_out) & " instr= " & to_string(output_ref.instr) & " mem_out.address= " & to_string(output_ref.mem_out.address) & lf

			& "**      actual:   mem_busy= " & std_logic'image(output_signal.mem_busy) & " pc_out= " & to_string(output_signal.pc_out) & " instr= " & to_string(output_signal.instr) & " mem_out.address= " & to_string(output_signal.mem_out.address) & lf

			severity error;
		end if;
	end procedure;

begin

	--memory_simulation inst

	mem_simulation(0) <= x"00000000";
	mem_simulation(1) <= x"1243dfa1";
    mem_simulation(2) <= x"010d005f";
    mem_simulation(3) <= x"cfd2a126";
	mem_simulation(4) <= x"a7b60023";
	mem_simulation(5) <= x"b27da987";
	mem_simulation(6) <= x"aaaabbbb"; --skipped by flush
	mem_simulation(7) <= x"4b4baeae";
	mem_simulation(8) <= x"b37e3b1a";
	mem_simulation(9) <= x"893b2a2b";

	fetch_inst: entity work.fetch
    port map
    (
		clk => clk,
		res_n => res_n,
		stall => input_signal.stall,
		flush => input_signal.flush,

		mem_busy => output_signal.mem_busy,

		pcsrc => input_signal.pcsrc,
		pc_in => input_signal.pc_in,
		pc_out => output_signal.pc_out,
		instr => output_signal.instr,

		mem_out => output_signal.mem_out,
		mem_in => input_signal.mem_in

    );

	stimulus : process
		variable fstatus: file_open_status;
	begin
		res_n <= '0';
		wait until rising_edge(clk);
		res_n <= '1';
		
		file_open(fstatus, input_file, "testdata/input.txt", READ_MODE);
		
		timeout(1, CLK_PERIOD);

		while not endfile(input_file) loop
			input_signal <= read_next_input(input_file);
			timeout(1, CLK_PERIOD);
		end loop;
		
		wait;
	end process;

	output_checker : process
		variable fstatus: file_open_status;
		variable output_ref : output_t;
	begin
		file_open(fstatus, output_ref_file, "testdata/output.txt", READ_MODE);

		wait until res_n = '1';
		timeout(1, CLK_PERIOD);

		while not endfile(output_ref_file) loop
			output_ref := read_next_output(output_ref_file);

			wait until falling_edge(clk);
			check_output(output_ref);
			wait until rising_edge(clk);
		end loop;
		stop <= true;
		
		wait;
	end process;

	generate_clk : process
	begin
		clk_generate(clk, CLK_PERIOD, stop);
		wait;
	end process;

end architecture;
