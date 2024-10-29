library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.op_pkg.all;

entity decode is
	port (
		clk        : in  std_logic;
		res_n      : in  std_logic;
		stall      : in  std_logic;
		flush      : in  std_logic;

		-- from fetch
		pc_in      : in  pc_type;
		instr      : in  instr_type;

		-- from writeback
		reg_write  : in reg_write_type;

		-- towards next stages
		pc_out     : out pc_type;
		exec_op    : out exec_op_type;
		mem_op     : out mem_op_type;
		wb_op      : out wb_op_type;

		-- exceptions
		exc_dec    : out std_logic
	);
end entity;

architecture rtl of decode is
	signal instr_reg : instr_type := NOP_INST;
	signal pc_reg 	 : pc_type	  := ZERO_PC;

	signal rddata1, rddata2 : data_type;

	-- From intruction formats
	alias opcode 	: std_logic_vector(6 downto 0) is instr_reg(6 downto 0);		-- for all types
	alias rd		: reg_adr_type is instr_reg(11 downto 7);						-- for all types
	alias funct3	: std_logic_vector(2 downto 0) is instr_reg(14 downto 12);		-- for R, I, S and B
	alias rs1 		: reg_adr_type is instr_reg(19 downto 15);						-- for R, I, S and B
	alias rs2 		: reg_adr_type is instr_reg(24 downto 20);						-- for R, I, S and B
	alias funct7	: std_logic_vector(6 downto 0) is instr_reg(31 downto 25);		-- for R

	alias imm		: std_logic_vector(19 downto 0) is instr_reg(31 downto 12);		-- for U

	-- Opcode: Partially specifies which of thr 6 types of instruction format
	-- Funct7, funct3: Witch the opcode, these 2 fields specify the operation to perform
	-- rs1: Register containing the first operand
	-- rs2: Register containing the second operand
	-- rd: Destination register (where the computation result will be redirected)

	-- R - Register/register
	-- I - Immediate
	-- S - Store
	-- B - Branch
	-- U - Upper Immediate
	-- J - Jump


	-- Table 4.6: MiRiV base opcodes
	constant OPC_LOAD 		: std_logic_vector(6 downto 0) := "0000011";
	constant OPC_STORE 		: std_logic_vector(6 downto 0) := "0100011";
	constant OPC_BRANCH 	: std_logic_vector(6 downto 0) := "1100011";
	constant OPC_JALR 		: std_logic_vector(6 downto 0) := "1100111";
	constant OPC_JAL 		: std_logic_vector(6 downto 0) := "1101111";
	constant OPC_OP_IMM 	: std_logic_vector(6 downto 0) := "0010011";
	constant OPC_OP 		: std_logic_vector(6 downto 0) := "0110011";
	constant OPC_AUIPC 		: std_logic_vector(6 downto 0) := "0010111";
	constant OPC_LUI 		: std_logic_vector(6 downto 0) := "0110111";
begin
	-- Regfile instantiation
    regfile_inst : entity work.regfile
	port map(
		clk              	=> clk,
		res_n           	=> res_n,
		stall           	=> stall,
		rdaddr1				=> instr(19 downto 15),
		rdaddr2 			=> instr(24 downto 20),
		rddata1				=> rddata1,
		rddata2 			=> rddata2,
		wraddr           	=> reg_write.reg,
		wrdata         		=> reg_write.data,
		regwrite        	=> reg_write.write
	);

	sync : process(clk, res_n)
	begin
		if res_n = '0' then
			instr_reg <= NOP_INST;
			pc_reg <= ZERO_PC;
		elsif rising_edge(clk) then
			-- if flush then
			-- 	instr_reg <= NOP_INST;
			-- 	pc_reg <= pc_in;
			-- elsif not stall then
			-- 	instr_reg <= instr;
			-- 	pc_reg <= pc_in;
			-- end if;
			if not stall then
                pc_reg <= pc_in;
                instr_reg <= instr;
            end if;
            if flush then
                instr_reg <= NOP_INST;
            end if;
		end if;
	end process;


	decode : process(all)
		variable immediate : data_type := ZERO_DATA;
	begin
		pc_out  <= pc_reg;
		exec_op <= EXEC_NOP;
		mem_op  <= MEM_NOP;
		wb_op   <= WB_NOP;
		exc_dec <= '0';


		exec_op.rs1 <= rs1; -- instr_reg(19 downto 15);
		exec_op.rs2 <= rs2; -- instr_reg(24 downto 20);	

		if instr_reg = NOP_INST then -- ADDI x0, x0, 0
			-- No data
			exec_op.readdata1 <= ZERO_DATA;
			exec_op.readdata2 <= ZERO_DATA;
		else
			exec_op.readdata1 <= rddata1;
			exec_op.readdata2 <= rddata2;
		end if;

		-- Sign extension for immediate
		immediate := (others => instr_reg(31)); -- initialize immediate as Figure 4.2
		wb_op.rd <= rd; -- Set writeback destination

		case opcode is
			when OPC_LUI =>
				-- Load Upper Immediate
				-- Format: U
				-- Syntax: LUI rd, imm
				-- Semantics: rd=imm<<12

				immediate := imm & "000000000000"; -- imm == instr_reg(31 downto 12)

				exec_op.aluop <= ALU_AND;
				exec_op.alusrc1 <= '1';
				exec_op.alusrc2 <= '1';

				wb_op.src <= WBS_ALU; -- ALU result
				wb_op.write <= '1';

			when OPC_AUIPC =>
				-- Add Upper Immediate to Program Counter
				-- Format: U
				-- Syntax: AUIPC rd, imm
				-- Semantics: rd=pc+(imm<<12)

				--immediate := imm sll 12;
				immediate := instr_reg(31 downto 12) & "000000000000";

				exec_op.alusrc3 <= '1'; -- Selecting new PC to be calculated for jump/branch
				exec_op.aluop <= ALU_ADD;

				wb_op.src <= WBS_ALU; -- ALU result
				wb_op.write <= '1';

			when OPC_JAL =>
				-- Jump and Link
				-- Format: J
				-- Syntax: JAL rd, imm
				-- Semantics: rd=pc+4; pc=pc+(imm<<1)

				immediate(19 downto 0) := instr_reg(19 downto 12) & instr_reg(20) & instr_reg(30 downto 21) & '0';

				mem_op.branch <= BR_BR; -- normal branch

				wb_op.src <= WBS_OPC; -- old PC + 4
				wb_op.write <= '1';

			when OPC_JALR =>
				-- Jump and Link Register
				-- Format: I
				-- Syntax: JALR rd, rs1, imm
				-- Semantics: rd=pc+4; pc=imm+rs1; pc[0]=’0’

				if funct3 = "000" then
					immediate(10 downto 0) := instr_reg(30 downto 20); -- figure 4.2

					mem_op.branch <= BR_BR; -- normal branch

					wb_op.src <= WBS_OPC; -- old PC + 4
					wb_op.write <= '1';

					exec_op.alusrc3 <= '1';	-- pc=imm+rs1; pc[0]=’0’
					exec_op.aluop <= ALU_ADD;
				else
					-- Wrong funct3 => decoding exception
					exc_dec <= '1';
				end if;

			--*********************************************************--

			when OPC_BRANCH =>
				-- Various branch versions
				-- Format: B
				-- Branch to PC + imm (if evaluation is true)
				
				wb_op <= WB_NOP;
				immediate(11 downto 0) := instr_reg(7) & instr_reg(30 downto 25) & instr_reg(11 downto 8) & '0' ; -- figure 4.2

				case funct3 is
					when "000" =>
						-- Branch equal to
						-- Syntax: BEQ rs1, rs2, imm
						-- Semantics: if(rs1=rs2)pc=pc+(imm<<1)
						-- Use Zero flag of ALU to check at ALU_SUB if A=B

						exec_op.aluop <= ALU_SUB;
						mem_op.branch <= BR_CND; -- conditioned branch if zero ALU.Z=1

					when "001" =>
						-- Branch not equal to
						-- Syntax: BNE rs1, rs2, imm
						-- Semantics: if(rs1!=rs2)pc=pc+(imm<<1)
						-- Use Zero flag of ALU to check at ALU_SUB if A!=B

						exec_op.aluop <= ALU_SUB;
						mem_op.branch <= BR_CNDI; -- conditioned branch if zero ALU.Z=0

					when "100" =>
						-- Branch less than
						-- Pseudoinstruction: blt $8, $9, 4
						--	Translates to:	  slt $1, $8, $9 $1=($8<$9)?1:0;
						--					  bne $1, $0, 4	 branch if $1 is negative 
						-- Syntax: BLT rs1, rs2, imm
						-- Semantics: if(rs1<rs2)pc=pc+(imm<<1)
						
						exec_op.aluop <= ALU_SLT;
						mem_op.branch <= BR_CNDI;

					when "101" =>
						-- Branch greater equal
						-- Syntax: BGE rs1, rs2, imm
						-- Semantics: if(rs1>=rs2)pc=pc+(imm<<1)

						exec_op.aluop <= ALU_SLT;
						mem_op.branch <= BR_CND;

					when "110" =>
						-- Branch less than unsigned
						-- Syntax: BLTU rs1, rs2, imm
						-- Semantics: if(u(rs1)<u(rs2))pc=pc+(imm<<1)

						exec_op.aluop <= ALU_SLTU;
						mem_op.branch <= BR_CNDI;

					when "111" =>
						-- Branch greater equal unsigned
						-- Syntax: BGEU rs1, rs2, imm
						-- Semantics: if(u(rs1)>=u(rs2))pc=pc+(imm<<1)

						exec_op.aluop <= ALU_SLTU;
						mem_op.branch <= BR_CND;
				
					when others =>
						-- Wrong funct3 => decoding exception
						exc_dec <= '1';
				end case;

			--*********************************************************--

			when OPC_LOAD =>
				-- Various load versions
				-- Format: I

				immediate(10 downto 0) := instr_reg(30 downto 20);

				exec_op.alusrc2 <= '1'; -- imm
				exec_op.aluop <= ALU_ADD;

				mem_op.mem.memread <= '1';

				wb_op.write <= '1';		-- Write loaded value
				wb_op.src <= WBS_MEM;

				case funct3 is
					when "000" =>
						-- Load Byte
						-- Syntax: LB rd, rs1, imm
						-- Semantics: rd=(int8_t)DMEM[rs1+imm]

						mem_op.mem.memtype <= MEM_B;

					when "001" =>
						-- Load Halfword
						-- Syntax: LH rd, rs1, imm
						-- Semantics: rd=(int16_t)DMEM[rs1+imm]

						mem_op.mem.memtype <= MEM_H;

					when "010" =>
						-- Load Word
						-- Syntax: LW rd, rs1, imm
						-- Semantics: rd=(int32_t)DMEM[rs1+imm]

						mem_op.mem.memtype <= MEM_W;

					when "100" =>
						-- Load Byte Unsigned
						-- Syntax: LBU rd, rs1, imm
						-- Semantics: rd=(uint8_t)DMEM[rs1+imm]

						mem_op.mem.memtype <= MEM_BU;

					when "101" =>
						-- Load Halfword Unsigned
						-- Syntax: LHU rd, rs1, imm
						-- Semantics: rd=(uint16_t)DMEM[rs1+imm]

						mem_op.mem.memtype <= MEM_HU;
				
					when others =>
						-- Wrong funct3 => decoding exception
						exc_dec <= '1';
				end case;

			--*********************************************************--

			when OPC_STORE =>
				-- Various store versions
				-- Format: S

				immediate(10 downto 0) := instr_reg(30 downto 25) & instr_reg(11 downto 7);

				exec_op.alusrc2 <= '1'; -- imm
				exec_op.aluop <= ALU_ADD;

				mem_op.mem.memwrite <= '1';

				wb_op <= WB_NOP;

				case funct3 is
					when "000" =>
						-- Store Byte
						-- Syntax: SB rs1, rs2, imm
						-- Semantics: DMEM[rs1+imm]=rs2(7 downto 0)

						mem_op.mem.memtype <= MEM_B;

					when "001" =>
						-- Store Halfword
						-- Syntax: SH rs1, rs2, imm
						-- Semantics: DMEM[rs1+imm]=rs2(15 downto 0)

						mem_op.mem.memtype <= MEM_H;

					when "010" =>
						-- Store Word
						-- Syntax: SW rs1, rs2, imm
						-- Semantics: DMEM[rs1+imm]=rs2

						mem_op.mem.memtype <= MEM_W;

					when others =>
						-- Wrong funct3 => decoding exception
						exc_dec <= '1';
				end case;

			--*********************************************************--

			when OPC_OP_IMM =>
				-- Various immediate operations
				-- Format: I
				-- First source is rs1, second source is immediate

				immediate(10 downto 0) := instr_reg(30 downto 20);
				exec_op.alusrc2 <= '1';

				wb_op.write <= '1';
				wb_op.src <= WBS_ALU;

				case funct3 is
					when "000" =>
						-- ADD immediate
						-- Syntax: ADDI rd, rs1, imm
						-- Semantics: rd=rs1+imm

						exec_op.aluop <= ALU_ADD;

					when "010" =>
						-- Set less than immediate
						-- Syntax: SLTI rd, rs1, imm
						-- Semantics: rd=(rs1<imm))?1:0

						exec_op.aluop <= ALU_SLT;
					
					when "011" =>
						-- Set less than immediate unsigned
						-- Syntax: SLTIU rd, rs1, imm
						-- Semantics: rd=(u(rs1)<imm)?1:0  (first sign-extend the immediate, then treat the resulting value as unsigned for the comparison)

						exec_op.aluop <= ALU_SLTU;

					when "100" =>
						-- Bitwise XOR immediate
						-- Syntax: XORI rd, rs1, imm
						-- Semantics: rd=rs1^imm

						exec_op.aluop <= ALU_XOR;

					when "110" =>
						-- Bitwise OR immediate
						-- Syntax: ORI rd, rs1, imm
						-- Semantics: rd=rs1|imm

						exec_op.aluop <= ALU_OR;

					when "111" =>
						-- Bitwise AND immediate
						-- Syntax: ANDI rd, rs1, imm
						-- Semantics: rd=rs1&imm

						exec_op.aluop <= ALU_AND;

					when "001" =>
						-- Shift logic left immediate
						-- Syntax: SLLI rd, rs1, shamt
						-- Semantics: rd=rs1<<shamt

						exec_op.aluop <= ALU_SLL;

					when "101" =>
						if immediate(10) then
							-- Shift right arithmetic immediate
							-- Syntax: SRAI rd, rs1, shamt
							-- Semantics: rd=u(rs1)>>shamt

							exec_op.aluop <= ALU_SRA;
						else
							-- Shift right logic immediate
							-- Syntax: SRLI rd, rs1, shamt
							-- Semantics: rd=rs1>>shamt
						
							exec_op.aluop <= ALU_SRL;
						end if;

					when others =>
						-- Wrong funct3 => decoding exception
						exc_dec <= '1';
				
				end case;

			--*********************************************************--

			when OPC_OP =>
				-- Various calculations
				-- Format: R
				-- First source is rs1, second source is rs2

				immediate := (others => '0'); -- not used

				wb_op.src <= WBS_ALU;
				wb_op.write <= '1';

				if funct7 = "0000000" then -- ADD and SRL
					case funct3 is
						when "000" =>
							-- ADD
							-- Syntax: ADD rd, rs1, rs2
							-- Semantics: rd=rs1+rs2

							exec_op.aluop <= ALU_ADD;

						when "001" =>
							-- Shift logic left 
							-- Syntax: SLL rd, rs1, rs2
							-- Semantics: rd=rs1<<rs2[4 downto 0]

							exec_op.aluop <= ALU_SLL;

						when "010" =>
							-- Set less than
							-- Syntax: SLT rd, rs1, rs2
							-- Semantics: rd=(rs1<rs2))?1:0

							exec_op.aluop <= ALU_SLT;

						when "011" =>
							-- Set less than unsigned
							-- Syntax: SLTU rd, rs1, rs2
							-- Semantics: rd=(u(rs1)<u(rs2)))?1:0

							exec_op.aluop <= ALU_SLTU;

						when "100" =>
							-- Bitwise XOR
							-- Syntax: XOR rd, rs1, rs2
							-- Semantics: rd=rs1^rs2

							exec_op.aluop <= ALU_XOR;

						when "101" =>
							-- Shift right logic
							-- Syntax: SRL rd, rs1, rs2
							-- Semantics: rd=rs1>>rs2[4 downto 0]
						
							exec_op.aluop <= ALU_SRL;

						when "110" =>
							-- Bitwise OR 
							-- Syntax: OR rd, rs1, rs2
							-- Semantics: rd=rs1|rs2

							exec_op.aluop <= ALU_OR;

						when "111" =>
							-- Bitwise AND 
							-- Syntax: AND rd, rs1, rs2
							-- Semantics: rd=rs1&rs2

							exec_op.aluop <= ALU_AND;
					
						when others =>
							-- Wrong funct3 => decoding exception
							exc_dec <= '1';
					end case;
				elsif funct7 = "0100000" then -- SUB and SRA
					case funct3 is
						when "000" =>
							-- SUB
							-- Syntax: SUB rd, rs1, rs2
							-- Semantics: rd=rs1-rs2

							exec_op.aluop <= ALU_SUB;

						when "101" =>
							-- Shift right arithmetical
							-- Syntax: SRA rd, rs1, rs2
							-- Semantics: rd=rs1>>rs2[4 downto 0]
						
							exec_op.aluop <= ALU_SRA;

						when others =>
							-- Wrong funct3 => decoding exception
							exc_dec <= '1';
					end case;
				else
					-- Wrong funct7 => decoding exception
					exc_dec <= '1';
				end if;

			--*********************************************************--

			when "0001111"=>
				if funct3 = "000" then
					-- NOP
					wb_op <= WB_NOP;
				else
					-- Wrong funct7 => decoding exception
					exc_dec <= '1';
				end if; 

			when others =>
			-- opcode not accepted => decoding exception
			exc_dec <= '1';
			
		end case;

		exec_op.imm <= immediate;
	
		
	end process;


end architecture;
