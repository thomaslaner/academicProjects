library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.op_pkg.all;

-- ATTENTION: zero flag is only valid on SUB and SLT(U)

entity alu is
	port (
		op   : in  alu_op_type;
		A, B : in  data_type;
		R    : out data_type := (others => '0');
		Z    : out std_logic := '0'
	);
end alu;

architecture rtl of alu is
begin

	ALU_PROC : process(all)
	begin
		R <= (others => '0');
		Z <= '-';

		case op is
		
			when ALU_NOP =>

				R <= B;
				
			when ALU_SLT => -- set less than signed

				if signed(A) < signed(B) then
					R <= (0 => '1', others => '0');
				end if;
				Z <= not R(0);

			when ALU_SLTU => -- set less than unsigned

				if unsigned(A) < unsigned(B) then
					R <= (0 => '1', others => '0');
				end if;
				Z <= not R(0);

			when ALU_SLL => -- shift left logical

				R <= std_logic_vector(shift_left(unsigned(A), to_integer(unsigned(B(4 downto 0)))));

			when ALU_SRL =>	-- shift right logical

				R <= std_logic_vector(shift_right(unsigned(A), to_integer(unsigned(B(4 downto 0)))));

			when ALU_SRA =>	-- shift right arithmetic

				R <= std_logic_vector(shift_right(signed(A), to_integer(unsigned(B(4 downto 0)))));

			when ALU_ADD =>	-- A + B

				R <= std_logic_vector(signed(A) + signed(B));

			when ALU_SUB => -- A - B

				R <= std_logic_vector(signed(A) - signed(B));
				if A = B then
					Z <= '1';
				else
					Z <= '0';
				end if;

			when ALU_AND => -- A and B

				R <= A and B;

			when ALU_OR => -- A or B

				R <= A or B;

			when ALU_XOR => -- A xor B

				R <= A xor B;
		
			when others =>
				null;		

		end case;
	end process;

end architecture;
