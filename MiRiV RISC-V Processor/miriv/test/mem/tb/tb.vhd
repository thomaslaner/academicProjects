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
			mem_op       	:   mem_op_type;
			wbop_in			:	wb_op_type;
			pc_new_in    	:	pc_type;
            pc_old_in      	: 	pc_type;
            aluresult_in  	: 	data_type;
            wrdata          :	data_type;
            zero          	: 	std_logic;
            mem_in        	: 	mem_in_type;
		end record;
	
		type output_t is
		record
			mem_busy      : std_logic;
			reg_write     : reg_write_type;	
			pc_new_out    : pc_type;
			pcsrc         : std_logic;
			wbop_out      : wb_op_type;
			pc_old_out    : pc_type;
			aluresult_out : data_type;	
			memresult     : data_type;
			mem_out       : mem_out_type;
			exc_load      : std_logic;
			exc_store     : std_logic;
		end record;
	
		signal input_signal  : input_t := (
			stall => '0',
			flush => '0',
			mem_op => MEM_NOP,
			wbop_in	=> WB_NOP,
			pc_new_in => ZERO_PC,
			pc_old_in => ZERO_PC,
			aluresult_in => ZERO_DATA,
			wrdata => ZERO_DATA,
			zero => '0',
			mem_in => MEM_IN_NOP
		);

	signal output_signal : output_t;

	impure function read_next_input(file f : text) return input_t is
		variable l : line;
		variable result : input_t;
	begin

		-- stall
		l := get_next_valid_line(f);
		result.stall := str_to_sl(l(1));

		-- flush
		l := get_next_valid_line(f);
		result.flush := str_to_sl(l(1));

		-- PC
		l := get_next_valid_line(f);
		result.pc_new_in := hex_to_slv(l.all, PC_WIDTH);

		l := get_next_valid_line(f);
		result.pc_old_in := hex_to_slv(l.all, PC_WIDTH);

		-- MEM_OP
		l := get_next_valid_line(f);
		result.mem_op.branch := str_to_branch(l.all);

		l := get_next_valid_line(f);
		result.mem_op.mem.memread := str_to_sl(l(1));

		l := get_next_valid_line(f);
		result.mem_op.mem.memwrite := str_to_sl(l(1));

		l := get_next_valid_line(f);
		result.mem_op.mem.memtype := str_to_mem_op(l.all);
		
		result.wbop_in := WB_NOP; -- WB_OP just forwarded 

		-- data
		l := get_next_valid_line(f);
		result.aluresult_in := hex_to_slv(l.all, DATA_WIDTH);

		l := get_next_valid_line(f);
		result.wrdata := hex_to_slv(l.all, DATA_WIDTH);

		-- Zero
		l := get_next_valid_line(f);
		result.zero := str_to_sl(l(1));

		-- MEM_in
		l := get_next_valid_line(f);
		result.mem_in.busy := str_to_sl(l(1));

		l := get_next_valid_line(f);
		result.mem_in.rddata := hex_to_slv(l.all, DATA_WIDTH);

		return result;
	end function;

	impure function read_next_output(file f : text) return output_t is
		variable l : line;
		variable result : output_t;
	begin

		--PC
        l := get_next_valid_line(f);--pc_new
        result.pc_new_out := hex_to_slv(l.all, PC_WIDTH);

        l := get_next_valid_line(f);--pc_old
        result.pc_old_out := hex_to_slv(l.all, PC_WIDTH);

        l := get_next_valid_line(f);--pcsrc
        result.pcsrc := str_to_sl(l(1));

        --busy
        l := get_next_valid_line(f);
        result.mem_busy := str_to_sl(l(1));

        --reg_write not implemented
        result.reg_write := (write => '0', reg => ZERO_REG, data => ZERO_DATA);
        
        result.wbop_out := WB_NOP; --WB_OP just forwarded 

        --data
        l := get_next_valid_line(f);--aluresult
        result.aluresult_out := hex_to_slv(l.all, DATA_WIDTH);

        l := get_next_valid_line(f);--memresult
        result.memresult := hex_to_slv(l.all, DATA_WIDTH);

        --MEM_OUT
        l := get_next_valid_line(f);--addr
        result.mem_out.address := bin_to_slv(l.all, ADDR_WIDTH);

        l := get_next_valid_line(f);--rd
        result.mem_out.rd := str_to_sl(l(1));

        l := get_next_valid_line(f);--wr
        result.mem_out.wr := str_to_sl(l(1));

        l := get_next_valid_line(f);--byteena
        result.mem_out.byteena := bin_to_slv(l.all, BYTEEN_WIDTH);

        l := get_next_valid_line(f);--wrdata
        result.mem_out.wrdata := hex_to_slv(l.all, DATA_WIDTH);

        --Exceptions
        l := get_next_valid_line(f);--l
        result.exc_load := str_to_sl(l(1));

        l := get_next_valid_line(f);--s
        result.exc_store := str_to_sl(l(1));

		return result;
	end function;

	procedure check_output(output_ref : output_t) is
		variable passed : boolean;
	begin
		passed := (output_signal = output_ref);
		
		if passed then
			report " PASSED: " & lf
			& " stall="     	& std_logic'image(input_signal.stall)
			& " flush=" 		& std_logic'image(input_signal.flush)
			& " pc_old_in="		& to_string(input_signal.pc_old_in)
            & " branch=" 		& branch_type'IMAGE(input_signal.mem_op.branch)& lf
			severity note;
		else
			report "FAILED: " & lf
			& " stall="     	& std_logic'image(input_signal.stall)
			& " flush=" 		& std_logic'image(input_signal.flush)
			& " pc_old_in="		& to_string(input_signal.pc_old_in)
            & " branch=" 		& branch_type'IMAGE(input_signal.mem_op.branch)& lf
			severity error;

			--mem_busy
			if (output_ref.mem_busy /= output_signal.mem_busy) then
				report lf & "** mem_busy:" & lf
				& "**     expected:" & to_string(output_ref.mem_busy) & lf
				& "**     actual:  " & to_string(output_signal.mem_busy) & lf
				severity error;
			end if;

			--pc_new_out
			if (output_ref.pc_new_out /= output_signal.pc_new_out) then
				report lf & "** pc_new_out:" & lf
				& "**     expected:" & to_string(output_ref.pc_new_out) & lf
				& "**     actual:  " & to_string(output_signal.pc_new_out) & lf
				severity error;
			end if;

			--pc_old_out
			if (output_ref.pc_old_out /= output_signal.pc_old_out) then
				report lf & "** pc_old_out:" & lf
				& "**     expected:" & to_string(output_ref.pc_old_out) & lf
				& "**     actual:  " & to_string(output_signal.pc_old_out) & lf
				severity error;
			end if;

			--pcsrc
			if (output_ref.pcsrc /= output_signal.pcsrc) then
				report lf & "** pcsrc:" & lf
				& "**     expected:" & to_string(output_ref.pcsrc) & lf
				& "**     actual:  " & to_string(output_signal.pcsrc) & lf
				severity error;
			end if;

			--aluresult
			if (output_ref.aluresult_out /= output_signal.aluresult_out) then
				report lf & "** aluresult_out:" & lf
				& "**     expected:" & to_string(output_ref.aluresult_out) & lf
				& "**     actual:  " & to_string(output_signal.aluresult_out) & lf
				severity error;
			end if;

			--memresult
			if (output_ref.memresult /= output_signal.memresult) then
				report lf & "** memresult:" & lf
				& "**     expected:" & to_string(output_ref.memresult) & lf
				& "**     actual:  " & to_string(output_signal.memresult) & lf
				severity error;
			end if;

			--MEM_OUT - address
			if (output_ref.mem_out.address /= output_signal.mem_out.address) then
				report lf & "** MEM_OUT - Address:" & lf
				& "**     expected:" & to_string(output_ref.mem_out.address) & lf
				& "**     actual:  " & to_string(output_signal.mem_out.address) & lf
				severity error;
			end if;

			--MEM_OUT - rd
			if (output_ref.mem_out.rd /= output_signal.mem_out.rd) then
				report lf & "** MEM_OUT - rd:" & lf
				& "**     expected:" & to_string(output_ref.mem_out.rd) & lf
				& "**     actual:  " & to_string(output_signal.mem_out.rd) & lf
				severity error;
			end if;

			--MEM_OUT - wr
			if (output_ref.mem_out.wr /= output_signal.mem_out.wr) then
				report lf & "** MEM_OUT - wr:" & lf
				& "**     expected:" & to_string(output_ref.mem_out.wr) & lf
				& "**     actual:  " & to_string(output_signal.mem_out.wr) & lf
				severity error;
			end if;

			--MEM_OUT - byteena
			if (output_ref.mem_out.byteena /= output_signal.mem_out.byteena) then
				report lf & "** MEM_OUT - byteena:" & lf
				& "**     expected:" & to_string(output_ref.mem_out.byteena) & lf
				& "**     actual:  " & to_string(output_signal.mem_out.byteena) & lf
				severity error;
			end if;

			--MEM_OUT - wrdata
			if (output_ref.mem_out.wrdata /= output_signal.mem_out.wrdata) then
				report lf & "** MEM_OUT - wrdata:" & lf
				& "**     expected:" & to_string(output_ref.mem_out.wrdata) & lf
				& "**     actual:  " & to_string(output_signal.mem_out.wrdata) & lf
				severity error;
			end if;

			--EXCEPTIONS - XL
			if (output_ref.exc_load /= output_signal.exc_load) then
				report lf & "** EXCEPTIONS - XL:" & lf
				& "**     expected:" & to_string(output_ref.exc_load) & lf
				& "**     actual:  " & to_string(output_signal.exc_load) & lf
				severity error;
			end if;

			--EXCEPTIONS - XS
			if (output_ref.exc_store /= output_signal.exc_store) then
				report lf & "** EXCEPTIONS - XS:" & lf
				& "**     expected:" & to_string(output_ref.exc_store) & lf
				& "**     actual:  " & to_string(output_signal.exc_store) & lf
				severity error;
			end if;

			--WRITEBACK - rd
			if (output_ref.wbop_out.rd /= output_signal.wbop_out.rd) then
				report lf & "** WB - rd (hardcoded):" & lf
				& "**     expected:" & to_string(output_ref.wbop_out.rd) & lf
				& "**     actual:  " & to_string(output_signal.wbop_out.rd) & lf
				severity error;
			end if;

			--WRITEBACK - write
			if (output_ref.wbop_out.write /= output_signal.wbop_out.write) then
				report lf & "** WB - write:" & lf
				& "**     expected:" & to_string(output_ref.wbop_out.write) & lf
				& "**     actual:  " & to_string(output_signal.wbop_out.write) & lf
				severity error;
			end if;

			--REGWR - rd
			if (output_ref.reg_write.reg /= output_signal.reg_write.reg) then
				report lf & "** REGWR - rd:" & lf
				& "**     expected:" & to_string(output_ref.reg_write.reg) & lf
				& "**     actual:  " & to_string(output_signal.reg_write.reg) & lf
				severity error;
			end if;

			--REGWR - write
			if (output_ref.reg_write.write /= output_signal.reg_write.write) then
				report lf & "** REGWR - write:" & lf
				& "**     expected:" & to_string(output_ref.reg_write.write) & lf
				& "**     actual:  " & to_string(output_signal.reg_write.write) & lf
				severity error;
			end if;

			--REGWR - data
			if (output_ref.reg_write.data /= output_signal.reg_write.data) then
				report lf & "** REGWR - data:" & lf
				& "**     expected:" & to_string(output_ref.reg_write.data) & lf
				& "**     actual:  " & to_string(output_signal.reg_write.data) & lf
				severity error;
			end if;

		end if;
	end procedure;

begin

	uut_inst: entity work.mem
    port map
    (
		clk   => clk,
		res_n => res_n,

		stall => input_signal.stall,
		flush => input_signal.flush,
		
		-- -- to Ctrl
		mem_busy      => output_signal.mem_busy,

		-- from EXEC
		mem_op        => input_signal.mem_op,
		wbop_in       => input_signal.wbop_in,
		pc_new_in     => input_signal.pc_new_in,
		pc_old_in     => input_signal.pc_old_in,
		aluresult_in  => input_signal.aluresult_in,
		wrdata        => input_signal.wrdata,
		zero          => input_signal.zero,
		
		-- to EXEC (forwarding)
		reg_write     => output_signal.reg_write,

		-- to FETCH
		pc_new_out    => output_signal.pc_new_out,
		pcsrc         => output_signal.pcsrc,

		-- to WB
		wbop_out      => output_signal.wbop_out,
		pc_old_out    => output_signal.pc_old_out,
		aluresult_out => output_signal.aluresult_out,
		memresult     => output_signal.memresult,

		-- memory controller interface
		mem_out       => output_signal.mem_out,
		mem_in        => input_signal.mem_in,

		-- exceptions
		exc_load      => output_signal.exc_load,
		exc_store     => output_signal.exc_store
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
