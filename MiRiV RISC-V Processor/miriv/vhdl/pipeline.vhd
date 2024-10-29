library ieee;
use ieee.std_logic_1164.all;

use work.core_pkg.all;
use work.mem_pkg.all;
use work.op_pkg.all;

entity pipeline is
	port (
		clk    : in  std_logic;
		res_n  : in  std_logic;

		-- instruction interface
		mem_i_out    : out mem_out_type;		--interface from pipeline to instruction memory
		mem_i_in     : in  mem_in_type;			--interface from instruction memory to pipeline

		-- data interface
		mem_d_out    : out mem_out_type;		--interface from pipeline to data memory
		mem_d_in     : in  mem_in_type			--interface from data memory to pipeline
	);
end entity;

architecture impl of pipeline is

	--memory_busy_stall signal (used by ctrl)
	signal memory_busy_stall : std_logic;

	--separate stall and flush signals for every stage
	signal stall_f, stall_d, stall_e, stall_m, stall_w : std_logic;
	signal flush_f, flush_d, flush_e, flush_m, flush_w : std_logic;

	-- fetch stage signals
	signal mem_busy_f 	: std_logic;
	signal pc_out_f 	: pc_type;
	signal instr_f		: instr_type;

	--decode stage signals
	signal pc_out_d 	: pc_type;
	signal exec_op_d	: exec_op_type;
	signal mem_op_d		: mem_op_type;
	signal wb_op_d		: wb_op_type;
	signal exc_dec_d	: std_logic;

	--exec stage signals
	signal pc_old_out_e : pc_type;
	signal pc_new_out_e	: pc_type;
	signal aluresult_e	: data_type;
	signal wrdata_e		: data_type;
	signal zero_e 		: std_logic;
	signal memop_out_e	: mem_op_type;
	signal wbop_out_e	: wb_op_type;
	signal exec_op_e	: exec_op_type;

	--memory stage signals
	signal mem_busy_m 		: std_logic;
	signal reg_write_m		: reg_write_type;
	signal pc_new_out_m		: pc_type;
	signal pcsrc_m			: std_logic;
	signal wbop_out_m		: wb_op_type;
	signal pc_old_out_m		: pc_type;
	signal aluresult_out_m	: data_type;
	signal memresult_m 		: data_type;
	signal exc_load_m		: std_logic;
	signal exc_store_m		: std_logic;

	--wb stage signals
	signal reg_write_w	: reg_write_type;

	--ctrl_signals
	signal pcsrc_ctrl : std_logic;

begin

	memory_busy_stall <= '1' when mem_busy_f = '1' or mem_busy_m = '1' else '0';

	ctrl_inst: entity work.ctrl
	port map (
		clk			=> clk,
		res_n       => res_n,
		stall       => memory_busy_stall,

		stall_fetch => stall_f,
		stall_dec   => stall_d,
		stall_exec  => stall_e,
		stall_mem   => stall_m,
		stall_wb    => stall_w,

		flush_fetch => flush_f,
		flush_dec   => flush_d,
		flush_exec  => flush_e,
		flush_mem   => flush_m,
		flush_wb    => flush_w,

		-- from FWD
		wb_op_exec  => wbop_out_m,			--output from memory - write-back operation to writeback stage (pass _in to _out if stall & flush are low)
		exec_op_dec => exec_op_e,			--output from exec - used to check if forwarding is needed (is rs1/rs2 is equal to last calculated reg)

		pcsrc_in 	=> pcsrc_m,				--taken/not taken branch - from memory - to ctrl_unit
		pcsrc_out 	=> pcsrc_ctrl			--taken/not taken branch - from ctrl - to fetch stage
	);

	--handles exceptions by reporting them when encountered
	EXCEPTION_PROC : process(all)
	begin
		
		if exc_dec_d = '1' then
			report "decode exception in component DECODE" severity error;
		end if;

		if exc_load_m = '1' then
			report "load exception in component MEMORY" severity error;
		end if;

		if exc_store_m = '1' then
			report "store exception in component MEMORY" severity error;
		end if;

	end process;
	

	fetch_inst : entity work.fetch
		port map(
			clk  	=> clk,
			res_n 	=> res_n,
			stall 	=> stall_f,
			flush 	=> flush_f,
	
			-- to control
			mem_busy  => mem_busy_f,
			pcsrc     => pcsrc_ctrl,
			pc_in     => pc_new_out_m,
			pc_out    => pc_out_f,
			instr     => instr_f,
	
			-- memory controller interface
			mem_out   => mem_i_out,
			mem_in    => mem_i_in
		);
	

	decode_inst : entity work.decode
		port map (
			clk     => clk,
			res_n	=> res_n,
			stall   => stall_d,
			flush   => flush_d,
	
			-- from fetch
			pc_in      => pc_out_f,
			instr      => instr_f,
	
			-- from writeback
			reg_write  => reg_write_w,
	
			-- towards next stages
			pc_out     => pc_out_d,
			exec_op    => exec_op_d,
			mem_op     => mem_op_d,
			wb_op      => wb_op_d,
	
			-- exceptions
			exc_dec    => exc_dec_d
		);

	execute_inst : entity work.exec
		port map (
			clk    	=> clk,
			res_n	=> res_n,
			stall   => stall_e,
			flush   => flush_e,
	
			-- from DEC
			op      => exec_op_d,					-- Operation for this stage
			pc_in   => pc_out_d,					-- Program counter from decode stage
	
			-- to MEM
			pc_old_out    => pc_old_out_e,			-- Program counter for the memory stage
			pc_new_out    => pc_new_out_e,			-- Program counter (i.e., branch target) for the memory stage
			aluresult     => aluresult_e,			-- Result from ALU
			wrdata        => wrdata_e,				-- Value to be written to memory
			zero          => zero_e,				-- Zero flag from ALU
	
			memop_in      => mem_op_d,				-- Memory operation from decode stage (not modified, passed directly)
			memop_out     => memop_out_e,			-- Memory operation to memory stage (not modified, passed directly)
			wbop_in       => wb_op_d,				-- Write-back operation from decode stage (not modified, passed directly)
			wbop_out      => wbop_out_e,			-- Write-back operation to memory stage (not modified, passed directly)
	
			-- FWD
			exec_op       	=> exec_op_e,			--used to check if forwarding is needed (is rs1/rs2 is equal to last calculated reg)
			reg_write_mem 	=> reg_write_m,			--register to be written by current instruction from Memory
			reg_write_wr  	=> reg_write_w			--register to be written by current instruction (for decode stage and fwd) from WB
		);

	memory_inst : entity work.mem
		port map (
			clk           => clk,
			res_n         => res_n,
			stall         => stall_m,
			flush         => flush_m,

			-- to Ctrl
			mem_busy      => mem_busy_m,			-- signaling to ctrl that data memory is busy (high for exactly one cycle per read access)

			-- from EXEC
			mem_op        => memop_out_e,			--memory operation for execute stage (used to get branch type and memory access type)
			wbop_in       => wbop_out_e,			--write-back operaition from execute stage (pass _in to _out if stall & flush are low)
			pc_new_in     => pc_new_out_e,			--program counter (i.e. branch target) from execute stage (pass _in to _out if stall & flush are low - branch pc)
			pc_old_in     => pc_old_out_e,			--program counter (i.e. branch target) from excute stage  (pass _in to _out if stall & flush are low - non branch pc)
			aluresult_in  => aluresult_e,			--result from alu from execute stage (pass _in to _out if stall & flush are low)
			wrdata        => wrdata_e,				--used to get the data which should be written to memory
			zero          => zero_e,				--used to decide if branch taken

			-- to EXEC (forwarding)
			reg_write     => reg_write_m,			--register to be written by current instruction
			-- to FETCH
			pc_new_out    => pc_new_out_m,			--target address of branch - program counter (i.e. branch target) to fetch stage
			pcsrc         => pcsrc_m,				--taken/not taken branch - to ctrl unit

			-- to WB
			wbop_out      => wbop_out_m,			--write-back operation to writeback stage (pass _in to _out if stall & flush are low)
			pc_old_out    => pc_old_out_m,			--program counter to writeback stage 	  (pass _in to _out if stall & flush are low)
			aluresult_out => aluresult_out_m,		--result from ALU to writeback stage 	  (pass _in to _out if stall & flush are low)
			memresult     => memresult_m,			--result of memory load to writeback stage - passed from memu (R)

			-- memory controller interface
			mem_out       => mem_d_out,				--memory operation sent to outside pipeline - passed from memu (M)
			mem_in        => mem_d_in,				--memory load result received from outside to pipeline - passed to memu (D)

			-- exceptions
			exc_load      => exc_load_m,			--Load Exception - passed from memu (XL)
			exc_store     => exc_store_m			--Store Exception - passed from memu (XS)
		);

	writeback_inst: entity work.wb
		port map (
			clk        => clk,
			res_n      => res_n,
			stall      => stall_w,
			flush      => flush_w,

			-- from MEM
			op         => wbop_out_m, 				--write-back operation from memory stage
			aluresult  => aluresult_out_m,			--result from ALU from memory stage
			memresult  => memresult_m,				--result from memory load for memory stage
			pc_old_in  => pc_old_out_m,				--program counter

			-- to FWD and DEC
			reg_write  => reg_write_w				--register to be written by current instruction (for decode stage and fwd)
		);

end architecture;
