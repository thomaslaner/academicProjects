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
        op	: memu_op_type;
        A	: data_type;
		W	: data_type;
		D	: mem_in_type; 
	end record;

	type output_t is
	record
        R	: data_type;
		B	: std_logic;
        XL	: std_logic;
		XS	: std_logic;
		M	: mem_out_type;
	end record;

	signal input_signal  : input_t := (
		op => (memread => '0', memwrite => '0', memtype => MEM_B),
        A => (others => '0'),
        W => (others => '0'),
        D => (busy => '0', rddata => (others => '0'))
	);
	signal outp : output_t;

	impure function read_next_input(file f : text) return input_t is
		variable l : line;
		variable result : input_t;
	begin

		--op

		l := get_next_valid_line(f);
		result.op.memread := str_to_sl(l(1));

		l := get_next_valid_line(f);
		result.op.memwrite := str_to_sl(l(1));

		l := get_next_valid_line(f);
		result.op.memtype := str_to_mem_op(l.all);

		--A

		l := get_next_valid_line(f);
		result.A := bin_to_slv(l.all, DATA_WIDTH);

		--W

		l := get_next_valid_line(f);
		result.W := bin_to_slv(l.all, DATA_WIDTH);

		--D

		l := get_next_valid_line(f);
		result.D.busy := str_to_sl(l(1));

		l := get_next_valid_line(f);
		result.D.rddata := bin_to_slv(l.all, DATA_WIDTH);

		return result;
	end function;

	impure function read_next_output(file f : text) return output_t is
		variable l : line;
		variable result : output_t;
	begin

		--R

		l := get_next_valid_line(f);
		result.R := bin_to_slv(l.all, DATA_WIDTH);

		--B

		l := get_next_valid_line(f);
		result.B := str_to_sl(l(1));

		--XL

		l := get_next_valid_line(f);
		result.XL := str_to_sl(l(1));

		l := get_next_valid_line(f);
        result.XS := str_to_sl(l(1));
		--M

		l := get_next_valid_line(f);
		result.M.address := bin_to_slv(l.all, ADDR_WIDTH);

		l := get_next_valid_line(f);
		result.M.rd := str_to_sl(l(1));

		l := get_next_valid_line(f);
		result.M.wr := str_to_sl(l(1));

		l := get_next_valid_line(f);
        result.M.byteena := bin_to_slv(l.all, BYTEEN_WIDTH);

		l := get_next_valid_line(f);
		result.M.wrdata := bin_to_slv(l.all, DATA_WIDTH);

		return result;
	end function;

	procedure check_output(output_ref : output_t) is
		variable passed : boolean;
	begin
		passed := (outp = output_ref);

		if passed then
			report " PASSED: "
			& "OP.memread="     & std_logic'image(input_signal.op.memread)
			& "OP.memwrite=" & std_logic'image(input_signal.op.memwrite)
            & "OP.memtype=" & memtype_type'image(input_signal.op.memtype)
			& " A=" & to_string(input_signal.A)
            & " W=" & to_string(input_signal.W)
			& " D.busy=" & std_logic'image(input_signal.D.busy)
            & " D.rddata=" & to_string(input_signal.D.rddata) & lf
			severity note;
		else
			report "FAILED: "
			& "OP.memread="     & std_logic'image(input_signal.op.memread)
			& "OP.memwrite=" & std_logic'image(input_signal.op.memwrite)
            & "OP.memtype=" & memtype_type'image(input_signal.op.memtype)
			& " A=" & to_string(input_signal.A)
            & " W=" & to_string(input_signal.W)
			& " D.busy=" & std_logic'image(input_signal.D.busy)
            & " D.rddata=" & to_string(input_signal.D.rddata) & lf

			& "**      expected: R=" & to_string(output_ref.R) & " B=" & std_logic'image(output_ref.B) & " XL=" & std_logic'image(output_ref.XL) & " XS=" & std_logic'image(output_ref.XS) &
                          "M.address=" & to_string(output_ref.M.address) & "M.rd=" & std_logic'image(output_ref.M.rd) & "M.wr=" & std_logic'image(output_ref.M.wr) & 
                          "M.byteena=" & to_string(output_ref.M.byteena) & "M.wrdata=" & to_string(output_ref.M.wrdata) & lf

             & "**        actual: R=" & to_string(outp.R) & " B=" & std_logic'image(outp.B) & " XL=" & std_logic'image(outp.XL) & " XS=" & std_logic'image(outp.XS) &
                          "M.address=" & to_string(outp.M.address) & "M.rd=" & std_logic'image(outp.M.rd) & "M.wr=" & std_logic'image(outp.M.wr) & 
                          "M.byteena=" & to_string(outp.M.byteena) & "M.wrdata=" & to_string(outp.M.wrdata) & lf
			severity error;
		end if;
	end procedure;

begin

	memu_inst: entity work.memu
    port map
    (
        op  => input_signal.op,
        A   => input_signal.A,
		W   => input_signal.W,
        R   => outp.R, 

		B   => outp.B, 
		XL => outp.XL,
        XS => outp.XS,

        D   => input_signal.D, 
        M   => outp.M
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
