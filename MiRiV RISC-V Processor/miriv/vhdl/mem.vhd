library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.mem_pkg.all;
use work.op_pkg.all;

entity mem is
	port (
		clk           : in  std_logic;
		res_n         : in  std_logic;
		stall         : in  std_logic;
		flush         : in  std_logic;

		-- to Ctrl
		mem_busy      : out std_logic;			-- signaling to cntrl that data memory is busy (high for exactly one cycle per read access)

		-- from EXEC
		mem_op        : in  mem_op_type;		--memory operation for execute stage (used to get branch type and memory access type)
		wbop_in       : in  wb_op_type;			--write-back operaition from execute stage (pass _in to _out if stall & flush are low)
		pc_new_in     : in  pc_type;			--program counter (i.e. branch target) from execute stage (pass _in to _out if stall & flush are low - branch pc)
		pc_old_in     : in  pc_type;			--program counter (i.e. branch target) from excute stage  (pass _in to _out if stall & flush are low - non branch pc)
		aluresult_in  : in  data_type;			--result from alu from execute stage (pass _in to _out if stall & flush are low)
		wrdata        : in  data_type;			--used to get the data which should be written to memory
		zero          : in  std_logic;			--used to decide if branch taken

		-- to EXEC (forwarding)
		reg_write     : out reg_write_type;		--register to be written by current instruction - unused since forwarding is not yet implemented

		-- to FETCH
		pc_new_out    : out pc_type;			--target address of branch - program counter (i.e. branch target) to fetch stage
		pcsrc         : out std_logic;			--taken/not taken branch - to fetch stage

		-- to WB
		wbop_out      : out wb_op_type;			--write-back operation to writeback stage (pass _in to _out if stall & flush are low)
		pc_old_out    : out pc_type;			--program counter to writeback stage 	  (pass _in to _out if stall & flush are low)
		aluresult_out : out data_type;			--result from ALU to writeback stage 	  (pass _in to _out if stall & flush are low)
		memresult     : out data_type;			--result of memory load to writeback stage - passed from memu (R)

		-- memory controller interface
		mem_out       : out mem_out_type;		--memory operation sent to outside pipeline - passed from memu (M)
		mem_in        : in  mem_in_type;		--memory load result received from outside to pipeline - passed to memu (D)

		-- exceptions
		exc_load      : out std_logic;			--Load Exception - passed from memu (XL)
		exc_store     : out std_logic			--Store Exception - passed from memu (XS)
	);
end entity;

architecture rtl of mem is

	--signal definictions (registers used to corretly send data to other parts of logic (MEMU_INST, BRANCH_PROC))
	signal mem_op_reg : mem_op_type;
	signal aluresult_in_reg : data_type; 
	signal wrdata_reg : data_type;
	signal zero_reg : std_logic;
	signal reg_write_data_signal : data_type;

begin
	--input signals are synchronized (clk, res_n, stall, flush)
	--output signals are send directly out (besides forwarding-only signals which are to be synchronized)

--SYNC_PROC: used for synchronization
	SYNC_PROC : process(clk, res_n)
	begin
		if res_n = '0' then
			--MEMU_INST & BRANCH_PROC input signals
			mem_op_reg <= MEM_NOP;
			aluresult_in_reg <= ZERO_DATA;
			wrdata_reg <= ZERO_DATA;
			zero_reg <= '0';

			--signals with suffixes _out (forwarding to wb and fetch)
			pc_new_out <= ZERO_PC;	
			wbop_out <= WB_NOP;
			pc_old_out <= ZERO_PC;
			
	
		elsif rising_edge(clk) then

			if flush = '1' then
				--MEMU_INST & BRANCH_PROC input signals
				mem_op_reg <= MEM_NOP;
				aluresult_in_reg <= ZERO_DATA;
				wrdata_reg <= ZERO_DATA;
				zero_reg <= '0';

				--signals with suffixes _out (forwarding to wb and fetch)
				pc_new_out <= ZERO_PC;	
				wbop_out <= WB_NOP;
				pc_old_out <= ZERO_PC;

			else 

				if stall = '0' then

					--MEMU_INST & BRANCH_PROC input signals
					mem_op_reg <= mem_op;
					aluresult_in_reg <= aluresult_in;
					wrdata_reg <= wrdata;
					zero_reg <= zero;

					--signals with suffixes _out (forwarding to wb and fetch)
					pc_new_out <= pc_new_in;	
					wbop_out <= wbop_in;
					pc_old_out <= pc_old_in;

				else 
					--STALL = '1':
						--do not transfer inputs into internal registers
						--op.memread & op.memwrite shall be low

					mem_op_reg.mem.memread <= '0';
					mem_op_reg.mem.memwrite <= '0';

				end if;
			end if;
	
		end if;
	end process;

--MEMU_INST: used for memory operations
	MEMU_INST : entity work.memu
	port map (
		-- to mem
		op   => mem_op_reg.mem,					-- memory access type
		A    => aluresult_in_reg,				-- empty (32 downto 16) & address of memory access (15 downto 2) & which byte should be used for memory op (1 downto 0)	
		W    => wrdata_reg,						-- write data (data which should be written into memory)
		R    => memresult,						-- result of memory load (data which will be fed to pipeline from memory)

		B    => mem_busy,						-- memory busy (indicate to pipeline if memory is busy)
		XL   => exc_load,						-- load exeption (indicate to pipeline if load exception happened)
		XS   => exc_store,						-- store exception (indicate to pipeline if store exception happened)

		-- to memory controller
		D    =>	mem_in,							-- interface from memory to unit (D.busy: if memory access is ongoing, D.rddata: data read from memory)
		M    =>	mem_out							-- interface to memory from unit (M.address: which address has been read from memory, M.rd: if read acces has been used, M.wr: if write acces has been used , M.byteena: which byte is enabled, M.wrdata: Data that should be written to memory)

	);

	--pass aluresult to out (since input is synchronized, output doesn't have to)
	aluresult_out <= aluresult_in_reg;

--BRANCH_PROC: used for branch operations
	--used to set new pc depending on mem_op.branch type and ALU's Z output
	BRANCH_PROC : process(all)	
	begin
		case mem_op_reg.branch is
		
			when BR_NOP =>
				--no branch -> pc_old should be used
				pcsrc <= '0';
			when BR_BR =>
				--branch -> pc new should be used
				pcsrc <= '1';
			when BR_CND =>
				--branch conditional (only branch if ALU's Z output is high)
				if zero_reg = '1' then
					--pc_new should be used
					pcsrc <= '1';
				else 
					--pc_old should be used
					pcsrc <= '0';
				end if;
			when BR_CNDI =>
				--branch conditional (condition inverted - only branch if ALU's Z output is not high)
				if zero_reg = '0' then
					--pc_new should be used
					pcsrc <= '1';
				else 
					--pc_old should be used
					pcsrc <= '0';
				end if;
			when others =>
				report "INVALID CASE IN MEM BRANCH_PROC";
		end case;
	end process;

--FORWARDING

	reg_write <= (write => wbop_out.write, reg => wbop_out.rd, data => aluresult_in_reg);	--send outputs to forwarding unit

end architecture;
