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

	type input_t is
	record
        op   : alu_op_type;
        A, B : data_type;
	end record;

	type output_t is
	record
        R    : data_type;
        Z    : std_logic;
	end record;

	signal inp  : input_t := (
		ALU_NOP,
		(others => '0'),
		(others => '0')
	);
	signal outp : output_t;

	impure function read_next_input(file f : text) return input_t is
		variable l : line;
		variable result : input_t;
	begin
		l := get_next_valid_line(f);
		result.op := str_to_alu_op(l.all);

		l := get_next_valid_line(f);
		result.A := bin_to_slv(l.all, DATA_WIDTH);

		l := get_next_valid_line(f);
		result.B := bin_to_slv(l.all, DATA_WIDTH);

		return result;
	end function;

	impure function read_next_output(file f : text) return output_t is
		variable l : line;
		variable result : output_t;
	begin
		l := get_next_valid_line(f);
		result.R := bin_to_slv(l.all, DATA_WIDTH);

		l := get_next_valid_line(f);
		result.Z := str_to_sl(l(1));

		return result;
	end function;

	procedure check_output(output_ref : output_t) is
		variable passed : boolean;
	begin
		passed := (outp = output_ref);

		if passed then
			report " PASSED: "
			& "OP=" & alu_op_type'IMAGE(inp.OP)
			& " A=" & to_string(inp.A)
            & " B=" & to_string(inp.B) & lf
			severity note;
		else
			report "FAILED: "
			& "OP=" & alu_op_type'IMAGE(inp.OP)
            & " A=" & to_string(inp.A)
            & " B=" & to_string(inp.B) & lf
            & "**      expected: R=" & to_string(output_ref.R) & " Z=" & std_logic'IMAGE(output_ref.Z) & lf
            & "**        actual: R=" & to_string(outp.R) & " Z=" & std_logic'IMAGE(outp.Z) & lf
			severity error;
		end if;
	end procedure;

begin

	alu_inst : entity work.alu
    port map
    (
        op  => inp.op,
        A   => inp.A,
        B   => inp.B, 
        R   => outp.R, 
        Z   => outp.Z
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
			inp <= read_next_input(input_file);
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
