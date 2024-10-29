library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.op_pkg.all;

entity ctrl is
	port (
		clk         : in std_logic;
		res_n       : in std_logic;
		stall       : in std_logic;

		stall_fetch : out std_logic;
		stall_dec   : out std_logic;
		stall_exec  : out std_logic;
		stall_mem   : out std_logic;
		stall_wb    : out std_logic;

		flush_fetch : out std_logic;
		flush_dec   : out std_logic;
		flush_exec  : out std_logic;
		flush_mem   : out std_logic;
		flush_wb    : out std_logic;

		-- from FWD
		wb_op_exec  : in  wb_op_type;	-- from execute stage
		exec_op_dec : in  exec_op_type;

		pcsrc_in : in std_logic;	-- Branch decision (taken/not taken)
		pcsrc_out : out std_logic
	);
end entity;

architecture rtl of ctrl is
begin
	pcsrc_out <= pcsrc_in;	-- not modified

	ctrl_proc : process(all)
	begin
	-- Default values
		flush_fetch <= '0';
		flush_dec   <= '0';
		flush_exec  <= '0';
		flush_mem   <= '0';
		flush_wb    <= '0';

		stall_fetch <= '0';
		stall_dec   <= '0';
		stall_exec  <= '0';
		stall_mem   <= '0';
		stall_wb    <= '0';


	-- Branch Hazard: Flush the pipeline if branch is taken
		if pcsrc_in = '1' then	
			
			flush_dec   <= '1';
			flush_exec  <= '1';
			flush_mem   <= '1';

			-- no flush at fetch and wb: 
				--wb is not concerned by things happening earlier in the pipeline
				--fetch needs a new value to be able to send it to the other stages after the flush

		end if;

	--Memory busy: Stall if memory is currently busy (Stall_signal from pipeline: stall if mem_busy_f or mem_busy_m are high)
		if stall = '1' then

			stall_fetch <= '1';
			stall_dec   <= '1';
			stall_exec  <= '1';
			stall_mem   <= '1';
			stall_wb    <= '1';
		
	--Data Hazard: Stall (only if memory is not currently busy) pipeline if forwarding a result of a memory load would be needed
		elsif ((wb_op_exec.src = WBS_MEM) and (wb_op_exec.write = '1')) then
			-- Check if source of data is memory and that a value should be written to memory
			if ((wb_op_exec.rd /= ZERO_REG) and ((wb_op_exec.rd = exec_op_dec.rs1) or (wb_op_exec.rd = exec_op_dec.rs2))) then
				--Check if address of to which data is needed is not Zero_Reg and is equal to one of the input values

				stall_fetch <= '1';
				stall_dec   <= '1';
				stall_exec  <= '1';
				-- no flush on memory, otherwise data is lost
				-- no stall on wb, otherwise values will not be saved to memory

			end if;
		end if;

	end process;

end architecture;

/*\

Testcases:
* Testcase Nr.1: forwarding after exec -> expected: normal forwarding						@ forwarding.S
* Testcase Nr.2: forwarding after mem_load -> expected: stall								@ forwarding_mem_load.S
* Testcase Nr.3: branch taken -> expected: instructions after branch are not executed		@ branch_hazards.S
* Testcase Nr.4: branch not taken -> expected: instructions after branch are executed		@ branch_hazards_not_taken.S
* Testcase Nr.5: check that x0 is not forwarded												@ x0_forwarding.S
* Testcase Nr.6: double data hazard check, check that always the most recent value is used  @ double_data_hazard.S

\*/