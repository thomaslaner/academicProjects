library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mem_pkg.all;
use work.core_pkg.all;
use work.op_pkg.all;

entity memu is
	port (
		-- to mem
		op   : in  memu_op_type;					-- memory access type
		A    : in  data_type;						-- empty (32 downto 16) & address of memory access (15 downto 2) & which byte should be used for memory op (1 downto 0)
		W    : in  data_type;						-- write data (data which should be written into memory)
		R    : out data_type := (others => '0');	-- result of memory load (data which will be fed to pipeline from memory)

		B    : out std_logic := '0';				-- memory busy (indicate to pipeline if memory is busy)
		XL   : out std_logic := '0';				-- load exeption (indicate to pipeline if load exception happened)
		XS   : out std_logic := '0';				-- store exception (indicate to pipeline if store exception happened)

		-- to memory controller
		D    : in  mem_in_type;						-- interface from memory to unit (D.busy: if memory access is ongoing, D.rddata: data read from memory)
		M    : out mem_out_type := MEM_OUT_NOP		-- interface to memory from unit (M.address: which address has to be read from memory, M.rd: if read acces has to be used, M.wr: if write acces has to be used , M.byteena: which byte shall be enabled, M.wrdata: Data that should be written to memory)
	);
end entity;

--Description of the unit
--Accesses from the pipeline to the memory are translated by this unit. The unit calculated the necessary inputs to the memory/pipeline from the data passed by the pipeline/memory to the unit. 
--Since the pipeline is word based (32b) and the memory should allow subword accesses, the unit and must support translation into byte, halfword and word inputs for the memory. Further the unit
--is responsible to detect load- and store-exceptions between the two components.

architecture rtl of memu is
begin

	MEMU_PROC : process(all)
		--empty byte
		constant LOW_BYTE : std_logic_vector(7 downto 0) := (others => '-');
		
		--byte start-end values
		constant b_0_start 	: integer := 0;
		constant b_0_end 	: integer := 7;
		constant b_1_start 	: integer := 8;
		constant b_1_end 	: integer := 15;
		constant b_2_start 	: integer := 16;
		constant b_2_end 	: integer := 23;
		constant b_3_start 	: integer := 24;
		constant b_3_end 	: integer := 31;
		
		--exception variables
		variable XS_var : std_logic := '0';
		variable XL_var : std_logic := '0';

		--exception calculation function
		function exception_calc(op : memtype_type; byte_address : std_logic_vector(1 downto 0)) return std_logic is
		begin

			case op is
					
				when MEM_H =>
					
					case byte_address(1 downto 0) is
						when "01"|"11" => return '1';	
						when others => return '0';
					end case;

				when MEM_HU =>
					
					case byte_address(1 downto 0) is
						when "01"|"11" => return '1';	
						when others => return '0';
					end case;
			
				when MEM_W =>
					
					case byte_address(1 downto 0) is
						when "01"|"10"|"11" => return '1';	
						when others => return '0';
					end case;

				when others => return '0';
			
			end case;

		end function;
		
	begin
		--default signal assignments
	
			M.wrdata <= (others => '0');
			M.byteena <= (others => '0');

			M.wr <= op.memwrite;
			M.rd <= op.memread;

		--memory address
			-- A (1 downto 0) = division of a by 4 -> used for byte addressing
			-- mem_address is 14 bits wide, address is located in 14 bits of A from 1 upwards

			M.address <= A(15 downto 2);	-- word address of A

		--computation of M.byteena and M.wrdata

			--W consists of four bytes b_3, ... b_0, with b_3 beeing the most significant bit

			case op.memtype is
			
				when MEM_B|MEM_BU =>

					case A(1 downto 0) is
							
						when "00" =>
							
							M.byteena <= "1000";
							M.wrdata <= W(b_0_end downto b_0_start) & LOW_BYTE & LOW_BYTE & LOW_BYTE;	-- b_0XXX

						when "01" =>

							M.byteena <= "0100";
							M.wrdata <= LOW_BYTE & W(b_0_end downto b_0_start) & LOW_BYTE & LOW_BYTE;	-- Xb_0XX

						when "10" =>

							M.byteena <= "0010";
							M.wrdata <= LOW_BYTE & LOW_BYTE & W(b_0_end downto b_0_start) & LOW_BYTE;	-- XXb_0X

						when "11" =>
						
							M.byteena <= "0001";
							M.wrdata <= LOW_BYTE & LOW_BYTE & LOW_BYTE & W(b_0_end downto b_0_start);	-- XXXb_0

						when others =>
							null;
					end case;

				when MEM_H|MEM_HU =>
 						
					case A(1 downto 0) is
							
						when "00"|"01" =>
							
							M.byteena <= "1100";	
							M.wrdata <= W(b_0_end downto b_0_start) & W(b_1_end downto b_1_start) & LOW_BYTE & LOW_BYTE;	-- b_0b_1XX

						when "10"|"11" =>

							M.byteena <= "0011";
							M.wrdata <= LOW_BYTE & LOW_BYTE & W(b_0_end downto b_0_start) & W(b_1_end downto b_1_start);	-- XXb_0b_1
						
						when others =>
							null;
					end case;

				when MEM_W => 

					case A(1 downto 0) is
								
						when "00"|"01"|"10"|"11" =>

							M.byteena <= "1111";
							M.wrdata <= W(b_0_end downto b_0_start) & W(b_1_end downto b_1_start) & W(b_2_end downto b_2_start) & W(b_3_end downto b_3_start);	-- b_0b_1b_2b_3
						
						when others =>
							null;
					end case;

				when others =>
					null;
			end case;

		--translation of values from the external interface - R

			--D.rddata consists of four bytes b_3, ... b_0, with b_3 beeing the most significant byte

			case op.memtype is
			
				when MEM_B =>
					
					case A(1 downto 0) is
						when "00" => R <= (b_1_start to b_3_end => D.rddata(b_3_end)) & D.rddata(b_3_end downto b_3_start);	-- SSSb_3
						when "01" => R <= (b_1_start to b_3_end => D.rddata(b_2_end)) & D.rddata(b_2_end downto b_2_start);	-- SSSb_2
						when "10" => R <= (b_1_start to b_3_end => D.rddata(b_1_end)) & D.rddata(b_1_end downto b_1_start);	-- SSSb_1
						when "11" => R <= (b_1_start to b_3_end => D.rddata(b_0_end)) & D.rddata(b_0_end downto b_0_start);	-- SSSb_0
						when others => null;
					end case;

				when MEM_BU =>
				
					case A(1 downto 0) is
						when "00" => R <= LOW_BYTE & LOW_BYTE & LOW_BYTE & D.rddata(b_3_end downto b_3_start);	-- 000b_3
						when "01" => R <= LOW_BYTE & LOW_BYTE & LOW_BYTE & D.rddata(b_2_end downto b_2_start);	-- 000b_2
						when "10" => R <= LOW_BYTE & LOW_BYTE & LOW_BYTE & D.rddata(b_1_end downto b_1_start);	-- 000b_1
						when "11" => R <= LOW_BYTE & LOW_BYTE & LOW_BYTE & D.rddata(b_0_end downto b_0_start);	-- 000b_0
						when others => null;
					end case;

				when MEM_H =>

					case A(1 downto 0) is	
						when "00"|"01" => R <= (b_2_start to b_3_end => D.rddata(b_2_end)) & D.rddata(b_2_end downto b_2_start) & D.rddata(b_3_end downto b_3_start);	-- SSb_2b_3
						when "10"|"11" => R <= (b_2_start to b_3_end => D.rddata(b_0_end)) & D.rddata(b_0_end downto b_0_start) & D.rddata(b_1_end downto b_1_start);	-- SSb_0b_1
						when others => null;
					end case;

				when MEM_HU =>

					case A(1 downto 0) is
						when "00"|"01" => R <= LOW_BYTE & LOW_BYTE & D.rddata(b_2_end downto b_2_start) & D.rddata(b_3_end downto b_3_start);	-- 00b_2b_3
						when "10"|"11" => R <= LOW_BYTE & LOW_BYTE & D.rddata(b_0_end downto b_0_start) & D.rddata(b_1_end downto b_1_start);	-- 00b_0b_1
						when others => null;
					end case;

				when MEM_W =>

					case A(1 downto 0) is
						when "00"|"01"|"10"|"11" => R <= D.rddata(b_0_end downto b_0_start) & D.rddata(b_1_end downto b_1_start) & D.rddata(b_2_end downto b_2_start) & D.rddata(b_3_end downto b_3_start);	-- b_0b_1b_2b_3
						when others => null;
					end case;

				when others =>
					null;
			end case;

		--assertion of B if valid memory read access starting/ongoing - B

			--D.busy has to be regarded since it indicates a ongoing memory read access
			--memread and not XL_var has to be regarded since it indicates a starting valid memory read access
			--valid memory write operations don't have to be regarded, since writing is fast enough (no specific address has to be looked for) + assignment
			case (D.busy or (op.memread and not XL_var)) is
				when '1' => B <= '1';
				when '0' => B <= '0';
				when others => null;	
			end case;

		--exception handling

			--memory load exception computation - XL

				if op.memread = '1' then
					XL_var := exception_calc(op.memtype, A(1 downto 0));
				else
					XL_var := '0';
				end if;

			--memory store exception computation - XS

				if op.memwrite = '1' then
					XS_var := exception_calc(op.memtype, A(1 downto 0));
				else
					XS_var := '0';
				end if;

			--if XL or XS are asserted M.rd and M.wr must be zero -> processor must not issue memory acces that raises exception

				if XS_var = '1' or XL_var = '1' then
					M.rd <= '0';
					M.wr <= '0';				
				end if;

			--assign exception variables to exception signals

				XL <= XL_var;
				XS <= XS_var;


	end process;

end architecture;
