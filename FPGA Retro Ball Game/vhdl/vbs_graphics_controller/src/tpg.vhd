
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tpg is
	generic (
		WIDTH : integer;
		HEIGHT : integer
	);
	port (
		clk : in std_logic;
		res_n : in std_logic;
		
		pix_rd : in std_logic;
		pix_data : out std_logic_vector(1 downto 0)
	);
end entity;


architecture arch of tpg is
	signal x : integer range 0 to WIDTH-1;
	signal y : integer range 0 to HEIGHT-1;
	constant SIZE_A : integer := 64;
	constant SIZE_B : integer := 48;
	constant SIZE_C : integer := 32;
	constant SIZE_D : integer := 16;
begin
	sync : process(clk, res_n)
	begin
		if (res_n = '0') then
			x <= 0;
			y <= 0;
			pix_data <= (others=>'0');
		elsif (rising_edge(clk)) then
			if (pix_rd = '1') then
				if (x = WIDTH-1) then
					if (y = HEIGHT-1) then
						y <= 0;
						-- report "y: " & integer'image(y);
					else
						y <= y + 1;
						-- report "y: " & integer'image(y);
					end if;
					x <= 0;
				else
					x <= x + 1;
				end if;

				-- report "x: '" & integer'image(x) & "' y: '" & integer'image(y) & "'";
				
				pix_data <= (others=>'0'); --black background

				if (x=0 or x=WIDTH-1 or y=0 or y=HEIGHT-1) then
					pix_data <= (others=>'1'); --white frame
				end if;
				
				if (x >= WIDTH/2-SIZE_A/2 and x <= WIDTH/2+SIZE_A/2 and 		--168 -> 232 : 155
					y >= HEIGHT/2-SIZE_A/2 and y <= HEIGHT/2+SIZE_A/2 ) then 	--88  -> 152 : 64
					pix_data <= "11"; --white
				end if;
				
				if (x >= WIDTH/2-SIZE_B/2 and x <= WIDTH/2+SIZE_B/2 and 
					y >= HEIGHT/2-SIZE_B/2 and y <= HEIGHT/2+SIZE_B/2 ) then
					pix_data <= "10"; --gray
				end if;
				
				if (x >= WIDTH/2-SIZE_C/2 and x <= WIDTH/2+SIZE_C/2 and 
					y >= HEIGHT/2-SIZE_C/2 and y <= HEIGHT/2+SIZE_C/2 ) then
					pix_data <= "01"; --gray
				end if;
				
				if (x >= WIDTH/2-SIZE_D/2 and x <= WIDTH/2+SIZE_D/2 and 
					y >= HEIGHT/2-SIZE_D/2 and y <= HEIGHT/2+SIZE_D/2 ) then
					pix_data <= "00"; --black
				end if;

				-- if (x=0 or x=WIDTH-2) then
				-- 	pix_data <= (others => '1');
				-- elsif x=1 then
				-- 	pix_data <= "10";
				-- elsif x=2 then
				-- 	pix_data <= "01";
				-- end if;

				-- if ((x mod 2) = 0) then
				-- 	pix_data <= "11";
				-- else
				-- 	pix_data <= "00";
				-- end if;
				
				-- if y = 0 then
				-- 	pix_data <= "11";
				-- end if;

			end if;
		end if;
	end process;

end architecture;
