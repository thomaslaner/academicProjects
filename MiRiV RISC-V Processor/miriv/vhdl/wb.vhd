library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.op_pkg.all;

entity wb is
	port (
		clk        : in  std_logic;
		res_n      : in  std_logic;
		stall      : in  std_logic;
		flush      : in  std_logic;

		-- from MEM
		op         : in  wb_op_type;	--write-back operation from memory stage
		aluresult  : in  data_type;		--result from ALU from memory stage
		memresult  : in  data_type;		--result from memory load for memory stage
		pc_old_in  : in  pc_type;		--program counter

		-- to FWD and DEC
		reg_write  : out reg_write_type	--register to be written by current instruction (for decode stage and fwd)
	);
end entity;

architecture rtl of wb is

	signal op_reg : wb_op_type;
	signal aluresult_reg : data_type;
	signal pc_old_in_reg : pc_type;
	signal memresult_reg : data_type;

	--ex3: memresult unregistered, since otherwise timming does not fit with mem_out in memu_inst
	--ex4: memresult now registered, since stalling is now fully functional
		--mem_busy_m (in pipeline.vhd) was not triggered since a beginning of a memory_load has not been regarded (in memu.vhd)
		--now memory has enough time to deliver data and hence data is available one clk_cycle before it is needed -> hence the register

begin
	--input signals are synchronized (clk, res_n, stall, flush)
	--output signals are send directly out

	SYNC_PROC : process(clk, res_n)
	begin
		if res_n = '0' then
			
			--set input_registers to NOP
			op_reg <= WB_NOP;
			aluresult_reg <= ZERO_DATA;
			pc_old_in_reg <= ZERO_PC;
			memresult_reg <= ZERO_DATA;

		elsif rising_edge(clk) then

			if flush = '1' then
				--set input_registers to NOP
				op_reg <= WB_NOP;
				aluresult_reg <= ZERO_DATA;
				pc_old_in_reg <= ZERO_PC;
				memresult_reg <= ZERO_DATA;

			else 

				if stall = '0' then

					--update input signals
					op_reg <= op;
					aluresult_reg <= aluresult;
					memresult_reg <= memresult;
					pc_old_in_reg <= pc_old_in;

				else 

					--do not update registers

				end if;

			end if;

	
		end if;
	end process;

	WB_PROC : process(all)
		variable pc_vector : std_logic_vector(32-1 downto 0) := (others => '0');		--DATA_WIDTH = 32
	begin

		case op_reg.src is
		
			when WBS_ALU =>
				--source = ALU result
				reg_write <= (write => op_reg.write, reg => op_reg.rd, data => aluresult_reg); 

			when WBS_MEM =>
				--source = MEM result
				reg_write <= (write => op_reg.write, reg => op_reg.rd, data => memresult_reg);

			when WBS_OPC =>
				--source = old PC + 4
				pc_vector := "0000000000000000" & pc_old_in_reg;
				reg_write <= (write => op_reg.write, reg => op_reg.rd, data => std_logic_vector(unsigned(pc_vector)+4));
			when others =>
		
		end case;

	end process;

end architecture;
