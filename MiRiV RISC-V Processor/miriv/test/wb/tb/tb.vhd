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
			stall			:	std_logic;
			flush 			:	std_logic;
			wb_op			:	wb_op_type;
			aluresult  		:   data_type;
			memresult		:   data_type;
			pc_old_in  		:   pc_type;
		end record;
	
		type output_t is
		record
			reg_write  		:  reg_write_type;
		end record;
	
		signal input_signal  : input_t := (
			stall => '0',
			flush => '0',
			wb_op	  => WB_NOP,
			aluresult => ZERO_DATA,
			memresult => ZERO_DATA,
			pc_old_in => ZERO_PC
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

		--WB_OP
		l := get_next_valid_line(f);
		result.wb_op.rd := bin_to_slv(l.all, REG_BITS);

		l := get_next_valid_line(f);
		result.wb_op.write := str_to_sl(l(1));

		l := get_next_valid_line(f);
		result.wb_op.src := str_to_wbs_op(l.all);

		--data
        l := get_next_valid_line(f);--aluresult
        result.aluresult := hex_to_slv(l.all, DATA_WIDTH);

        l := get_next_valid_line(f);--memresult
        result.memresult := hex_to_slv(l.all, DATA_WIDTH);

        l := get_next_valid_line(f);--PC
        result.pc_old_in := hex_to_slv(l.all, PC_WIDTH);

		return result;
	end function;

	impure function read_next_output(file f : text) return output_t is
		variable l : line;
		variable result : output_t;
	begin

        l := get_next_valid_line(f);--regwrite wr
        result.reg_write.write := str_to_sl(l(1));

        l := get_next_valid_line(f);--regwrite addr
        result.reg_write.reg := bin_to_slv(l.all, REG_BITS);

        l := get_next_valid_line(f);--regwrite data
        result.reg_write.data := hex_to_slv(l.all, DATA_WIDTH);

		return result;
	end function;

	procedure check_output(output_ref : output_t) is
		variable passed : boolean;
	begin
		passed := (output_signal = output_ref);
		
		if passed then
			report " PASSED: " & lf
			& "stall="  & std_logic'image(input_signal.stall)
			& " flush=" & std_logic'image(input_signal.flush)
			& " wr="	& std_logic'IMAGE(input_signal.wb_op.write)
            & " src=" 	& wbsrc_type'IMAGE(input_signal.wb_op.src)
            & " ALUin=" & to_string(input_signal.aluresult)
            & " MEMin=" & to_string(input_signal.memresult)
            & " OPCin=" & to_string(input_signal.pc_old_in) & lf
			severity note;
		else
			report "FAILED: " & lf
			& "stall="  & std_logic'image(input_signal.stall)
			& " flush=" & std_logic'image(input_signal.flush)
			& " wr="	& std_logic'IMAGE(input_signal.wb_op.write)
            & " src=" 	& wbsrc_type'IMAGE(input_signal.wb_op.src)
            & " ALUin=" & to_string(input_signal.aluresult)
            & " MEMin=" & to_string(input_signal.memresult)
            & " OPCin=" & to_string(input_signal.pc_old_in) & lf
			severity error;

			--reg_write - write
			if (output_ref.reg_write.write /= output_signal.reg_write.write) then
				report lf & "** reg_write - write:" & lf
				& "**     expected:" & to_string(output_ref.reg_write.write) & lf
				& "**     actual:  " & to_string(output_signal.reg_write.write) & lf
				severity error;
			end if;

			--reg_write - reg
			if (output_ref.reg_write.reg /= output_signal.reg_write.reg) then
				report lf & "** reg_write - reg:" & lf
				& "**     expected:" & to_string(output_ref.reg_write.reg) & lf
				& "**     actual:  " & to_string(output_signal.reg_write.reg) & lf
				severity error;
			end if;

			--reg_write - data
			if (output_ref.reg_write.data /= output_signal.reg_write.data) then
				report lf & "** reg_write - data:" & lf
				& "**     expected:" & to_string(output_ref.reg_write.data) & lf
				& "**     actual:  " & to_string(output_signal.reg_write.data) & lf
				severity error;
			end if;

		end if;
	end procedure;

begin

	uut_inst: entity work.wb
	port map
	(
		clk   => clk,
		res_n => res_n,
		stall => input_signal.stall,
		flush => input_signal.flush,
		
		-- from mem
		pc_old_in => input_signal.pc_old_in,
		aluresult => input_signal.aluresult,
		memresult => input_signal.memresult,
		
		op     => input_signal.wb_op,

		-- to decode
		reg_write => output_signal.reg_write
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
		variable test_case_counter : integer := 0;
	begin
		file_open(fstatus, output_ref_file, "testdata/output.txt", READ_MODE);

		wait until res_n = '1';
		timeout(1, CLK_PERIOD);

		while not endfile(output_ref_file) loop
			output_ref := read_next_output(output_ref_file);
			test_case_counter := test_case_counter +1;
			report integer'image(test_case_counter) & ")" & lf;

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
