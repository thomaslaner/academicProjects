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
			pc_in			:	pc_type;
			instr			:	instr_type;
			reg_write		: 	reg_write_type;
		end record;
	
		type output_t is
		record
			pc_out			:	pc_type;
			exec_op			:	exec_op_type;
			mem_op			:	mem_op_type;
			wb_op			: 	wb_op_type;
			exc_dec			: 	std_logic;
		end record;
	
		signal input_signal  : input_t := (
			stall => '0',
			flush => '0',
			pc_in => (others => '0'),
			instr => NOP_INST,
			reg_write => (write => '0', reg => ZERO_REG, data => ZERO_DATA)
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

		--pc_in

		l := get_next_valid_line(f);
		result.pc_in := bin_to_slv(l.all, PC_WIDTH);

		--instr

		l := get_next_valid_line(f);
		result.instr := bin_to_slv(l.all, INSTR_WIDTH);

		--reg_write

		l := get_next_valid_line(f);
		result.reg_write.write := str_to_sl(l(1));

		l := get_next_valid_line(f);
		result.reg_write.reg := bin_to_slv(l.all, REG_BITS);

		l := get_next_valid_line(f);
		result.reg_write.data := bin_to_slv(l.all, DATA_WIDTH);

		return result;
	end function;

	impure function read_next_output(file f : text) return output_t is
		variable l : line;
		variable result : output_t;
	begin

		--pc_out

		l := get_next_valid_line(f);
		result.pc_out := bin_to_slv(l.all, PC_WIDTH);
	
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

		--mem_op

        l := get_next_valid_line(f);
        result.mem_op.branch := str_to_branch(l.all);
        
        l := get_next_valid_line(f);
        result.mem_op.mem.memread := str_to_sl(l(1));

        l := get_next_valid_line(f);
        result.mem_op.mem.memwrite := str_to_sl(l(1));

        l := get_next_valid_line(f);
        result.mem_op.mem.memtype := str_to_mem_op(l.all);

		--wb_op

		l := get_next_valid_line(f);
        result.wb_op.rd := bin_to_slv(l.all, REG_BITS);

        l := get_next_valid_line(f);
        result.wb_op.write := str_to_sl(l(1));

        l := get_next_valid_line(f);
        result.wb_op.src := str_to_wbs_op(l.all);

		--exception

		l := get_next_valid_line(f);
        result.exc_dec := str_to_sl(l(1));

		return result;
	end function;

	procedure check_output(output_ref : output_t) is
		variable passed : boolean;
	begin
		passed := (output_signal = output_ref);
		
		if passed then
			report " PASSED: " & lf
			-- & "stall="     		& std_logic'image(input_signal.stall)
			-- & "flush=" 			& std_logic'image(input_signal.flush)
			-- & "pc_in=" 			& to_string(input_signal.pc_in)
			-- & "instr=" 			& to_string(input_signal.instr)
			-- & "reg_write=" 		& to_string(input_signal.instr) & lf
			severity note;
		else
			report "FAILED: " & lf
			-- & "stall="     		& std_logic'image(input_signal.stall)
			-- & "flush=" 			& std_logic'image(input_signal.flush)
			-- & "pc_in=" 			& to_string(input_signal.pc_in)
			-- & "instr=" 			& to_string(input_signal.instr)
			-- & "reg_write=" 		& to_string(input_signal.instr) & lf
			severity error;

			--pc_out
			if (output_ref.pc_out /= output_signal.pc_out) then
				report lf & "** pc_out:" & lf
				& "**     expected:" & to_string(output_ref.pc_out) & lf
				& "**     actual:  " & to_string(output_signal.pc_out) & lf
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

			--mem_op

			if (output_ref.mem_op.branch /= output_signal.mem_op.branch) then
				report lf & "** mem_op.branch:" & lf
				& "**     expected:" & to_string(output_ref.mem_op.branch) & lf
				& "**     actual:  " & to_string(output_signal.mem_op.branch) & lf
				severity error;
			end if;

			if (output_ref.mem_op.mem.memread /= output_signal.mem_op.mem.memread) then
				report lf & "** mem_op.mem.memread:" & lf
				& "**     expected:" & std_logic'image(output_ref.mem_op.mem.memread) & lf
				& "**     actual:  " & std_logic'image(output_signal.mem_op.mem.memread) & lf
				severity error;
			end if;

			if (output_ref.mem_op.mem.memwrite /= output_signal.mem_op.mem.memwrite) then
				report lf & "** mem_op.mem.memwrite:" & lf
				& "**     expected:" & std_logic'image(output_ref.mem_op.mem.memwrite) & lf
				& "**     actual:  " & std_logic'image(output_signal.mem_op.mem.memwrite) & lf
				severity error;
			end if;

			if (output_ref.mem_op.mem.memtype /= output_signal.mem_op.mem.memtype) then
				report lf & "** mem_op.branch:" & lf
				& "**     expected:" & to_string(output_ref.mem_op.mem.memtype) & lf
				& "**     actual:  " & to_string(output_signal.mem_op.mem.memtype) & lf
				severity error;
			end if;

			--wb_op

			if (output_ref.wb_op.rd /= output_signal.wb_op.rd) then
				report lf & "** wb_op.rd:" & lf
				& "**     expected:" & to_string(output_ref.wb_op.rd) & lf
				& "**     actual:  " & to_string(output_signal.wb_op.rd) & lf
				severity error;
			end if;

			if (output_ref.wb_op.write /= output_signal.wb_op.write) then
				report lf & "** wb_op.write:" & lf
				& "**     expected:" & std_logic'image(output_ref.wb_op.write) & lf
				& "**     actual:  " & std_logic'image(output_signal.wb_op.write) & lf
				severity error;
			end if;

			if (output_ref.wb_op.src /= output_signal.wb_op.src) then
				report lf & "** wb_op.src:" & lf
				& "**     expected:" & to_string(output_ref.wb_op.src) & lf
				& "**     actual:  " & to_string(output_signal.wb_op.src) & lf
				severity error;
			end if;

			--exception

			if (output_ref.exc_dec /= output_signal.exc_dec) then
				report lf & "** exc_dec:" & lf
				& "**     expected:" & std_logic'image(output_ref.exc_dec) & lf
				& "**     actual:  " & std_logic'image(output_signal.exc_dec) & lf
				severity error;
			end if;

		end if;
	end procedure;

begin

	uut_inst: entity work.decode
    port map
    (
		clk => clk,
		res_n => res_n,
		stall => input_signal.stall,
		flush => input_signal.flush,

		-- from fetch
		pc_in => input_signal.pc_in,
		instr => input_signal.instr,

		-- from writeback
		reg_write => input_signal.reg_write,

		-- towards next stages
		pc_out => output_signal.pc_out,
		exec_op => output_signal.exec_op,
		mem_op => output_signal.mem_op,
		wb_op => output_signal.wb_op,

		-- exceptions
		exc_dec => output_signal.exc_dec
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
