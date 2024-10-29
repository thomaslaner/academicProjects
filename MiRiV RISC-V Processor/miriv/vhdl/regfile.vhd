library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;

entity regfile is
	port (
		clk              : in  std_logic;
		res_n            : in  std_logic;
		stall            : in  std_logic;
		rdaddr1, rdaddr2 : in  reg_adr_type;
		rddata1, rddata2 : out data_type;
		wraddr           : in  reg_adr_type;
		wrdata           : in  data_type;
		regwrite         : in  std_logic
	);
end entity;

architecture rtl of regfile is

	type reg_type is array ((2**REG_BITS)-1 downto 0) of data_type;
	signal reg : reg_type := (others => ZERO_DATA);

	signal rdaddr1_sig, rdaddr2_sig : reg_adr_type := ZERO_REG;	--used to save last addr in case of a stall

begin

	WRITE_PROC : process(all)
	begin
		if res_n = '0' then

			--reset the last addr
			rdaddr1_sig <= ZERO_REG;
			rdaddr2_sig <= ZERO_REG;

			--reset the register array
			reg <= (others => ZERO_DATA);			

		elsif rising_edge(clk) then
	
			if (stall = '0') then

				--if not stalled set net last addr
				rdaddr1_sig <= rdaddr1;
				rdaddr2_sig <= rdaddr2;
				
				--only write of regwrite is high and if wraddr is not address 0
				if (regwrite = '1') and (wraddr /= ZERO_REG) then
					reg(to_integer(unsigned(wraddr))) <= wrdata;
				end if;

			end if;

		end if;
	end process;

	READ_PROC : process(all)
	begin
		if res_n = '0' then

			--reset output data
			rddata1 <= ZERO_DATA;
			rddata2 <= ZERO_DATA;
	
		else
				
			--set outputs
			rddata1 <= reg(to_integer(unsigned(rdaddr1_sig)));
			rddata2 <= reg(to_integer(unsigned(rdaddr2_sig)));

			--pass-through logic to implement forwarding
			--if wraddr is address 0, then return 0 and not the passed value
			if (regwrite = '1') and (stall = '0') then 

				if rdaddr1_sig = wraddr then
					if wraddr = ZERO_REG then
						rddata1 <= ZERO_DATA;
					else
						rddata1 <= wrdata;
					end if;
				end if;

				if rdaddr2_sig = wraddr then
					if wraddr = ZERO_REG then
						rddata2 <= ZERO_DATA;
					else
						rddata2 <= wrdata;
					end if;
				end if;

			end if;
	
		end if;
	end process;

end architecture;
