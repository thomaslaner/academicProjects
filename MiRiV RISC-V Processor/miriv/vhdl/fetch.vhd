library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.op_pkg.all;
use work.mem_pkg.all;

entity fetch is
	port (
		clk        : in  std_logic;
		res_n      : in  std_logic;
		stall      : in  std_logic;
		flush      : in  std_logic;

		-- to control
		mem_busy   : out std_logic;

		pcsrc      : in  std_logic;
		pc_in      : in  pc_type;
		pc_out     : out pc_type := (others => '0');
		instr      : out instr_type;

		-- memory controller interface
		mem_out   : out mem_out_type;
		mem_in    : in  mem_in_type
	);
end entity;

architecture rtl of fetch is

	signal pc, pc_next : pc_type := std_logic_vector(to_signed(-4, PC_WIDTH));
	signal instr_sig, instr_sig_next : instr_type := NOP_INST;				
	signal flush_sig, stall_sig : std_logic;									--used to know if the last cycle has been stalled/flushed

begin

	--instrucion memory read and next value of pc computed

	SYNC_PROC : process(clk, res_n)
	begin
		if res_n = '0' then
		-- after res_n = '0' fetch shall return the instruction located at address 0 in instr memory
		-- correct instruction must be fetched after reset and no unwanted instr shall be entered into the pipeline
		
			pc <= std_logic_vector(to_signed(-4, PC_WIDTH));	--hence in the next cycle the pc will be 0 (-4+4=0)
			instr_sig <= NOP_INST;
			flush_sig <= '1';
			stall_sig <= '0';
			
		elsif rising_edge(clk) then
			
			--only change pc if not currently stalled
			if stall = '0' then
                pc <= pc_next;
            end if;
			
			instr_sig <= instr_sig_next;
			flush_sig <= flush;
			stall_sig <= stall;
	
		end if;
	end process;

	FETCH_PROC : process(all)
	begin
		pc_next <= pc;

		--pc calculation
			-- if stall = '1': pc shall not change
			-- if stall = '0':
			if stall = '0' then
				
				if pcsrc = '1' then
					pc_next <= pc_in;
				else 
					pc_next <= std_logic_vector(unsigned(pc) + 4); -- next pc shall be current_pc + 4
				end if;
				
			end if;

		--instr calculation
			if flush_sig = '1' then
				--if flush = '1': nop instr shall be inserted into the pipeline
				instr_sig_next <= NOP_INST;
			elsif stall_sig = '1' then
				--if flush = '0' & stall = '1' next instr shall be last issued instruction which has not been read because of stall
				instr_sig_next <= instr_sig; 
			else
				--if flush = '0' & stall = '0' next instr shall be read from instr mem
				--individual bytes of instr-word must be in correct order when passing them to decode-stage (RISC-V uses little endian)
				instr_sig_next <= mem_in.rddata(7 downto 0) & mem_in.rddata(15 downto 8) & mem_in.rddata(23 downto 16) & mem_in.rddata(31 downto 24);
			end if;

		end process;

	--outside signal assignments

		--signals passed on to decode stage
		pc_out <= pc;	
		instr <= instr_sig_next;	--next signal to make sure that instruction arrives in time with memory operation

		--interface for instr mem is same as for data mem
			--some signals will not be used (default values!)
			--read port of instr mem is registered! (has to be connected to next program counter)
			--pc is byte_addressed while instr mem is accessed word-wise -> lowest two bits of pc are not used to address to instr mem

		mem_out.address <= pc_next(pc_type'length -1 downto 2);	--memory addressed word wise: +4 on byte addressed pc is equal to +1 in memory
		mem_out.rd <= '1';
		mem_out.wr <= '0';
		mem_out.byteena <= (others => '1');
		mem_out.wrdata <= (others => '0');

		--connect mem_in.busy to mem_busy (used later on when not guaranteed that read access to instr mem always returns value in next cyc)
		mem_busy <= mem_in.busy;

end architecture;
