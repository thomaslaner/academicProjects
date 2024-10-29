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
			op				:	exec_op_type;
			pc_in			:	pc_type;
			memop_in		:	mem_op_type;
			wbop_in			:	wb_op_type;
			reg_write_mem	:	reg_write_type;
			reg_write_wr	:	reg_write_type;
		end record;
	
		type output_t is
		record
			pc_old_out			:	pc_type;
			pc_new_out			: 	pc_type;
			aluresult			:	data_type;
			wrdata				:	data_type;
			zero				:	std_logic;
			memop_out			:	mem_op_type;
			wbop_out			:	wb_op_type;
			exec_op				:	exec_op_type;
		end record;
	
		signal input_signal  : input_t := (
			stall => '0',
			flush => '0',
			op	  => (aluop => ALU_NOP, alusrc1 => '0', alusrc2 => '0', alusrc3 => '0', rs1 => (others => '0'), rs2 => (others => '0'), readdata1 => (others => '0'), readdata2 => (others => '0'), imm => (others => '0')),
			pc_in => (others => '0'),
			memop_in => (branch => BR_NOP, mem => (memread => '0', memwrite => '0', memtype => MEM_B)),
			wbop_in => (rd => (others => '0'), write => '0', src => WBS_ALU),
			reg_write_mem => (write => '0', reg => ZERO_REG, data => ZERO_DATA),
			reg_write_wr => (write => '0', reg => ZERO_REG, data => ZERO_DATA)
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

		--op

		l := get_next_valid_line(f);
		result.op.aluop := str_to_alu_op(l.all);

		l := get_next_valid_line(f);
		result.op.alusrc1 := str_to_sl(l(1));

		l := get_next_valid_line(f);
		result.op.alusrc2 := str_to_sl(l(1));

		l := get_next_valid_line(f);
		result.op.alusrc3 := str_to_sl(l(1));

		l := get_next_valid_line(f);
		result.op.rs1 := bin_to_slv(l.all, REG_BITS);

		l := get_next_valid_line(f);
		result.op.rs2 := bin_to_slv(l.all, REG_BITS);

		l := get_next_valid_line(f);
		result.op.readdata1 := bin_to_slv(l.all, DATA_WIDTH);

		l := get_next_valid_line(f);
		result.op.readdata2 := bin_to_slv(l.all, DATA_WIDTH);

		l := get_next_valid_line(f);
		result.op.imm := bin_to_slv(l.all, DATA_WIDTH);

		--pc_in

		l := get_next_valid_line(f);
		result.pc_in := bin_to_slv(l.all, PC_WIDTH);

		--memop_in

		l := get_next_valid_line(f);
		result.memop_in.branch := str_to_branch(l.all);

		l := get_next_valid_line(f);
		result.memop_in.mem.memread := str_to_sl(l(1));

		l := get_next_valid_line(f);
		result.memop_in.mem.memwrite := str_to_sl(l(1));

		l := get_next_valid_line(f);
		result.memop_in.mem.memtype := str_to_mem_op(l.all);

		--wbop_in

		l := get_next_valid_line(f);
		result.wbop_in.rd := bin_to_slv(l.all, REG_BITS);

		l := get_next_valid_line(f);
		result.wbop_in.write := str_to_sl(l(1));

		l := get_next_valid_line(f);
		result.wbop_in.src := str_to_wbs_op(l.all);

		--reg_write_mem

		l := get_next_valid_line(f);
		result.reg_write_mem.write := str_to_sl(l(1));

		l := get_next_valid_line(f);
		result.reg_write_mem.reg := bin_to_slv(l.all, REG_BITS);

		l := get_next_valid_line(f);
		result.reg_write_mem.data := bin_to_slv(l.all, DATA_WIDTH);

		--reg_write_wr

		l := get_next_valid_line(f);
		result.reg_write_wr.write := str_to_sl(l(1));

		l := get_next_valid_line(f);
		result.reg_write_wr.reg := bin_to_slv(l.all, REG_BITS);

		l := get_next_valid_line(f);
		result.reg_write_wr.data := bin_to_slv(l.all, DATA_WIDTH);

		return result;
	end function;

	impure function read_next_output(file f : text) return output_t is
		variable l : line;
		variable result : output_t;
	begin

		--pc_old_out

		l := get_next_valid_line(f);
		result.pc_old_out := bin_to_slv(l.all, PC_WIDTH);

		--pc_new_out

		l := get_next_valid_line(f);
		result.pc_new_out := bin_to_slv(l.all, PC_WIDTH);

		--aluresult
	
		l := get_next_valid_line(f);
		result.aluresult := bin_to_slv(l.all, DATA_WIDTH);

		--wrdata

		l := get_next_valid_line(f);
		result.wrdata := bin_to_slv(l.all, DATA_WIDTH);

		--zero

		l := get_next_valid_line(f);
        result.zero := str_to_sl(l(1));

		--memop_out

		l := get_next_valid_line(f);
		result.memop_out.branch := str_to_branch(l.all);

		l := get_next_valid_line(f);
		result.memop_out.mem.memread := str_to_sl(l(1));

		l := get_next_valid_line(f);
		result.memop_out.mem.memwrite := str_to_sl(l(1));

		l := get_next_valid_line(f);
		result.memop_out.mem.memtype := str_to_mem_op(l.all);

		--wbop_out

		l := get_next_valid_line(f);
		result.wbop_out.rd := bin_to_slv(l.all, REG_BITS);

		l := get_next_valid_line(f);
		result.wbop_out.write := str_to_sl(l(1));

		l := get_next_valid_line(f);
		result.wbop_out.src := str_to_wbs_op(l.all);

		--exec_op

		l := get_next_valid_line(f);
		result.exec_op.aluop := str_to_alu_op(l.all);

		l := get_next_valid_line(f);
		result.exec_op.alusrc1 := str_to_sl(l(1));

		l := get_next_valid_line(f);
		result.exec_op.alusrc2 := str_to_sl(l(1));

		l := get_next_valid_line(f);
		result.exec_op.alusrc3 := str_to_sl(l(1));

		l := get_next_valid_line(f);
		result.exec_op.rs1 := bin_to_slv(l.all, REG_BITS);

		l := get_next_valid_line(f);
		result.exec_op.rs2 := bin_to_slv(l.all, REG_BITS);
	
		l := get_next_valid_line(f);
		result.exec_op.readdata1 := bin_to_slv(l.all, DATA_WIDTH);

		l := get_next_valid_line(f);
		result.exec_op.readdata2 := bin_to_slv(l.all, DATA_WIDTH);

		l := get_next_valid_line(f);
		result.exec_op.imm := bin_to_slv(l.all, DATA_WIDTH);

		return result;
	end function;

	procedure check_output(output_ref : output_t) is
		variable passed : boolean;
	begin
		passed := (output_signal = output_ref);
		
		if passed then
			report " PASSED " & lf
			-- & "stall="     		& std_logic'image(input_signal.stall)
			-- & "flush=" 			& std_logic'image(input_signal.flush)
			-- & "pc_in=" 			& to_string(input_signal.pc_in)
			-- & "instr=" 			& to_string(input_signal.instr)
			-- & "reg_write=" 		& to_string(input_signal.instr) & lf
			severity note;
		else
			report "FAILED " & lf
			-- & "stall="     		& std_logic'image(input_signal.stall)
			-- & "flush=" 			& std_logic'image(input_signal.flush)
			-- & "pc_in=" 			& to_string(input_signal.pc_in)
			-- & "instr=" 			& to_string(input_signal.instr)
			-- & "reg_write=" 		& to_string(input_signal.instr) & lf
			severity note;

			--pc_old_out
			if (output_ref.pc_old_out /= output_signal.pc_old_out) then
				report lf & "** pc_old_out:" & lf
				& "**     expected:" & to_string(output_ref.pc_old_out) & lf
				& "**     actual:  " & to_string(output_signal.pc_old_out) & lf
				severity error;
			end if;

			--pc_new_out
			if (output_ref.pc_new_out /= output_signal.pc_new_out) then
				report lf & "** pc_new_out:" & lf
				& "**     expected:" & to_string(output_ref.pc_new_out) & lf
				& "**     actual:  " & to_string(output_signal.pc_new_out) & lf
				severity error;
			end if;

			--aluresult
			if (output_ref.aluresult /= output_signal.aluresult) then
				report lf & "** aluresult:" & lf
				& "**     expected:" & to_string(output_ref.aluresult) & lf
				& "**     actual:  " & to_string(output_signal.aluresult) & lf
				severity error;
			end if;

			--wrdata
			if (output_ref.wrdata /= output_signal.wrdata) then
				report lf & "** wrdata:" & lf
				& "**     expected:" & to_string(output_ref.wrdata) & lf
				& "**     actual:  " & to_string(output_signal.wrdata) & lf
				severity error;
			end if;

			--zero
			if (output_ref.zero /= output_signal.zero) then
				report lf & "** zero:" & lf
				& "**     expected:" & std_logic'image(output_ref.zero) & lf
				& "**     actual:  " & std_logic'image(output_signal.zero) & lf
				severity error;
			end if;

			--memop_out

			if (output_ref.memop_out.branch /= output_signal.memop_out.branch) then
				report lf & "** memop_out.branch:" & lf
				& "**     expected:" & to_string(output_ref.memop_out.branch) & lf
				& "**     actual:  " & to_string(output_signal.memop_out.branch) & lf
				severity error;
			end if;

			if (output_ref.memop_out.mem.memread /= output_signal.memop_out.mem.memread) then
				report lf & "** memop_out.mem.memread:" & lf
				& "**     expected:" & std_logic'image(output_ref.memop_out.mem.memread) & lf
				& "**     actual:  " & std_logic'image(output_signal.memop_out.mem.memread) & lf
				severity error;
			end if;

			if (output_ref.memop_out.mem.memwrite /= output_signal.memop_out.mem.memwrite) then
				report lf & "** memop_out.mem.memwrite:" & lf
				& "**     expected:" & std_logic'image(output_ref.memop_out.mem.memwrite) & lf
				& "**     actual:  " & std_logic'image(output_signal.memop_out.mem.memwrite) & lf
				severity error;
			end if;

			if (output_ref.memop_out.mem.memtype /= output_signal.memop_out.mem.memtype) then
				report lf & "** memop_out.branch:" & lf
				& "**     expected:" & to_string(output_ref.memop_out.mem.memtype) & lf
				& "**     actual:  " & to_string(output_signal.memop_out.mem.memtype) & lf
				severity error;
			end if;

			--wbop_out

			if (output_ref.wbop_out.rd /= output_signal.wbop_out.rd) then
				report lf & "** wbop_out.rd:" & lf
				& "**     expected:" & to_string(output_ref.wbop_out.rd) & lf
				& "**     actual:  " & to_string(output_signal.wbop_out.rd) & lf
				severity error;
			end if;

			if (output_ref.wbop_out.write /= output_signal.wbop_out.write) then
				report lf & "** wbop_out.rd:" & lf
				& "**     expected:" & std_logic'image(output_ref.wbop_out.write) & lf
				& "**     actual:  " & std_logic'image(output_signal.wbop_out.write) & lf
				severity error;
			end if;

			if (output_ref.wbop_out.src /= output_signal.wbop_out.src) then
				report lf & "** wbop_out.rd:" & lf
				& "**     expected:" & to_string(output_ref.wbop_out.src) & lf
				& "**     actual:  " & to_string(output_signal.wbop_out.src) & lf
				severity error;
			end if;

			--exec_op

			if (output_ref.exec_op.aluop /= output_signal.exec_op.aluop) then
				report lf & "** exec_op.aluop:" & lf
				& "**     expected:" & to_string(output_ref.exec_op.aluop) & lf
				& "**     actual:  " & to_string(output_signal.exec_op.aluop) & lf
				severity error;
			end if;

			if (output_ref.exec_op.alusrc1 /= output_signal.exec_op.alusrc1) then
				report lf & "** exec_op.alusrc1:" & lf
				& "**     expected:" & std_logic'image(output_ref.exec_op.alusrc1) & lf
				& "**     actual:  " & std_logic'image(output_signal.exec_op.alusrc1) & lf
				severity error;
			end if;

			if (output_ref.exec_op.alusrc2 /= output_signal.exec_op.alusrc2) then
				report lf & "** exec_op.alusrc2:" & lf
				& "**     expected:" & std_logic'image(output_ref.exec_op.alusrc2) & lf
				& "**     actual:  " & std_logic'image(output_signal.exec_op.alusrc2) & lf
				severity error;
			end if;

			if (output_ref.exec_op.alusrc3 /= output_signal.exec_op.alusrc3) then
				report lf & "** exec_op.alusrc3:" & lf
				& "**     expected:" & std_logic'image(output_ref.exec_op.alusrc3) & lf
				& "**     actual:  " & std_logic'image(output_signal.exec_op.alusrc3) & lf
				severity error;
			end if;

			if (output_ref.exec_op.rs1 /= output_signal.exec_op.rs1) then
				report lf & "** exec_op.rs1:" & lf
				& "**     expected:" & to_string(output_ref.exec_op.rs1) & lf
				& "**     actual:  " & to_string(output_signal.exec_op.rs1) & lf
				severity error;
			end if;

			if (output_ref.exec_op.rs2 /= output_signal.exec_op.rs2) then
				report lf & "** exec_op.rs2:" & lf
				& "**     expected:" & to_string(output_ref.exec_op.rs2) & lf
				& "**     actual:  " & to_string(output_signal.exec_op.rs2) & lf
				severity error;
			end if;

			if (output_ref.exec_op.readdata1 /= output_signal.exec_op.readdata1) then
				report lf & "** exec_op.readdata1:" & lf
				& "**     expected:" & to_string(output_ref.exec_op.readdata1) & lf
				& "**     actual:  " & to_string(output_signal.exec_op.readdata1) & lf
				severity error;
			end if;

			if (output_ref.exec_op.readdata2 /= output_signal.exec_op.readdata2) then
				report lf & "** exec_op.readdata2:" & lf
				& "**     expected:" & to_string(output_ref.exec_op.readdata2) & lf
				& "**     actual:  " & to_string(output_signal.exec_op.readdata2) & lf
				severity error;
			end if;
			
			if (output_ref.exec_op.imm /= output_signal.exec_op.imm) then
				report lf & "** exec_op.imm:" & lf
				& "**     expected:" & to_string(output_ref.exec_op.imm) & lf
				& "**     actual:  " & to_string(output_signal.exec_op.imm) & lf
				severity error;
			end if;

		end if;
	end procedure;

begin

	uut_inst: entity work.exec
    port map
    (
		clk => clk,
		res_n => res_n,
		stall => input_signal.stall,
		flush => input_signal.flush,

		-- from DEC
		op => input_signal.op,
		pc_in => input_signal.pc_in,

		-- to MEM
		pc_old_out => output_signal.pc_old_out,
		pc_new_out  => output_signal.pc_new_out,
		aluresult => output_signal.aluresult,
		wrdata => output_signal.wrdata,
		zero => output_signal.zero,

		memop_in => input_signal.memop_in,
		memop_out => output_signal.memop_out,
		wbop_in => input_signal.wbop_in,
		wbop_out => output_signal.wbop_out,

		-- FWD
		exec_op => output_signal.exec_op,
		reg_write_mem => input_signal.reg_write_mem,
		reg_write_wr => input_signal.reg_write_wr
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
