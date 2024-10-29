library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.op_pkg.all;

entity exec is
	port (
		clk           : in  std_logic;
		res_n         : in  std_logic;
		stall         : in  std_logic;
		flush         : in  std_logic;

		-- from DEC
		op            : in  exec_op_type;		-- Operation for this stage
		pc_in         : in  pc_type;			-- Program counter from decode stage

		-- to MEM
		pc_old_out    : out pc_type;			-- Program counter for the memory stage
		pc_new_out    : out pc_type;			-- Program counter (i.e., branch target) for the memory stage
		aluresult     : out data_type;			-- Result from ALU
		wrdata        : out data_type;			-- Value to be written to memory
		zero          : out std_logic;			-- Zero flag from ALU

		memop_in      : in  mem_op_type;		-- Memory operation from decode stage (not modified, passed directly)
		memop_out     : out mem_op_type;		-- Memory operation to memory stage (not modified, passed directly)
		wbop_in       : in  wb_op_type;			-- Write-back operation from decode stage (not modified, passed directly)
		wbop_out      : out wb_op_type;			-- Write-back operation to memory stage (not modified, passed directly)

		-- FWD
		exec_op       : out exec_op_type;		-- needed in Exercise IV
		reg_write_mem : in  reg_write_type;		-- needed in Exercise IV
		reg_write_wr  : in  reg_write_type		-- needed in Exercise IV
	);
end entity;

architecture rtl of exec is
	
	--forwarding signals
	signal fwd_rs1_val, fwd_rs2_val : data_type;
	signal fwd_rs1_do_fwd, fwd_rs2_do_fwd : std_logic;
	signal op_sig : exec_op_type;
	
	--alu signals
	signal alu_op : exec_op_type := EXEC_NOP;
	signal alu_a, alu_b, alu_res : data_type;
	signal alu_z : std_logic := '0';
	
	--other signals
	signal pc_in_exec : pc_type;
	signal memop_in_next : mem_op_type;
	signal wbop_in_next : wb_op_type;

begin
--alu_inst
	alu_inst : entity work.alu
	port map(
		op   => alu_op.aluop,	-- operation
		A	 => alu_a,			-- operand A
		B 	 => alu_b,			-- operand B
		R    => alu_res,		-- result (of i.e. a R-type instr.)
		Z    => alu_z			-- zero flag
	);
--sync
	sync : process(clk, res_n)
	begin
		if res_n = '0' then
			pc_in_exec <= (others => '0');
			alu_op <= EXEC_NOP;
			memop_in_next <= MEM_NOP;
			wbop_in_next <= WB_NOP;
			op_sig <= EXEC_NOP;			--output to forwarding
		elsif rising_edge(clk) then
			if flush then
				pc_in_exec <= (others => '0');
				alu_op <= EXEC_NOP;
				memop_in_next <= MEM_NOP;
				wbop_in_next <= WB_NOP;
				op_sig <= EXEC_NOP;		--output to forwarding
			elsif not stall then
				pc_in_exec <= pc_in;
				alu_op <= op;
				memop_in_next <= memop_in;
				wbop_in_next <= wbop_in;
				op_sig <= op;			--output to forwarding
			end if;
		end if;
	end process;

--forwarding
	fwd_inst_rs1 : entity work.fwd
	port map (
	
		-- from Mem
		reg_write_mem => reg_write_mem,

		-- from WB
		reg_write_wb  => reg_write_wr,

		-- from/to EXEC
		reg    => op_sig.rs1,
		val    => fwd_rs1_val,
		do_fwd => fwd_rs1_do_fwd
	
	);

	fwd_inst_rs2 : entity work.fwd
	port map (
	
		-- from Mem
		reg_write_mem => reg_write_mem,

		-- from WB
		reg_write_wb  => reg_write_wr,

		-- from/to EXEC
		reg    => op_sig.rs2,
		val    => fwd_rs2_val,
		do_fwd => fwd_rs2_do_fwd
	
	);

	exec_op <= op_sig;

--exec (forwarding incl.) operations
	exec : process(all)
	begin
	--standard signal assignments
		pc_old_out <= pc_in_exec;
		memop_out <= memop_in_next;
		wbop_out <= wbop_in_next;

	--ALU operations		
	
		-- Check if imm. value or value from register has to be used for the alu operation
		if alu_op.alusrc1='0' then
			--if immediate shouldn't be used

			if fwd_rs1_do_fwd = '1' then
				--if forwarding should be used
				alu_a <= fwd_rs1_val; -- value from forwarding
			else 
				alu_a <= alu_op.readdata1; -- Register value
			end if;
	
		else
			alu_a <= alu_op.imm; -- Immediate value	
		end if;

		if alu_op.alusrc2='0' then
			--if immediate shouldn't be used

			if fwd_rs2_do_fwd = '1' then
				--if forwarding should be used
				alu_b <= fwd_rs2_val; -- value from forwarding
			else 
				alu_b <= alu_op.readdata2; -- Register value
			end if;
			
		else
			alu_b <= alu_op.imm; -- Immediate value	
		end if;


		aluresult <= alu_res;
		zero <= alu_z;
		
		--Check if  -- value that has to be stored in the memory in the mem stage (S-Instr.) should be taken from readdata2 or from forwarded value 2
		if fwd_rs2_do_fwd = '1' then
			--if forwarding should be used for data
			wrdata <= fwd_rs2_val;
		else 
			wrdata <= alu_op.readdata2; -- Register value
		end if;

	--Branch operation (calculate branch target address)
		if alu_op.alusrc3='0' then
			-- It is already shifted (see Figure 4.2, where bit 0 is already 0)
			pc_new_out <= std_logic_vector(unsigned(alu_op.imm(PC_WIDTH-1 downto 0)) + unsigned(pc_in_exec)); -- take only the 16 lsb of immediate, because PC_WIDTH is 16 bit (and immediate is 32 bit wide)
		
		else
			alu_a <= 16d"0" & pc_in_exec;
			alu_b <= alu_op.imm;

			--pc=imm+rs1 - value saved in rs1 and nor rs1 itself 
			if fwd_rs1_do_fwd = '1' then
				--if forwarding should be used
				pc_new_out <= std_logic_vector(unsigned(alu_op.imm(PC_WIDTH-1 downto 0)) + unsigned(fwd_rs1_val(PC_WIDTH-1 downto 0))); -- take only the 16 lsb of immediate, because PC_WIDTH is 16 bit (and immediate is 32 bit wide)
			else 
				pc_new_out <= std_logic_vector(unsigned(alu_op.imm(PC_WIDTH-1 downto 0)) + unsigned(alu_op.readdata1(PC_WIDTH-1 downto 0))); -- take only the 16 lsb of immediate, because PC_WIDTH is 16 bit (and immediate is 32 bit wide)
			end if;

			--pc[0]=’0’ (Table 4.7 decode stage)
			pc_new_out(0) <= '0';

		end if;
	end process;

end architecture;
