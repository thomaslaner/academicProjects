-- Task 5

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.prng_pkg.all;
use std.env.finish;

entity prng_tb is
end entity;

architecture tb of prng_tb is 

	signal clk : std_logic := '0';
	signal res_n : std_logic;
	signal load_seed : std_logic;
	signal seed : std_logic_vector(7 downto 0);
	signal en : std_logic;
	signal prdata : std_logic;

	-- shared variable stop_clk : boolean := false;
	signal stop_clk : boolean := false;
	constant clk_period : time := 2 ns;

	--n_a = ((11807845 mod 15)+1) << 4 =
	--(11807845 mod 15) = 10
	-- 11 -> 1011
	-- 1011 << 4 = 10110000 = 176

	constant n_a : integer := 176;
	constant n_b : integer := n_a + 15;

	signal current_seed : std_logic;

	-- shared variable t_lsfr : std_logic_vector (15 downto 0) := (others => '0');----------
	-- shared variable t_snapshot : std_logic_vector (15 downto 0) := (others => '0');----------

begin 

	uut: prng
	port map (
		clk => clk,
		res_n => res_n,
		load_seed => load_seed,
		seed => seed,
		en => en,
		prdata => prdata
	);

	-- clk generator, which stops generating when stop_clk is high
	clk_generator: process
	begin
		while not stop_clk loop
			clk <= '1';
			wait for clk_period	/ 2;
			clk <= '0';
			wait for clk_period / 2;
		end loop;
	end process;

	-- delivers random number to lsfr
	randomizer_proc: process
		variable lsfr_fill_counter : integer;
		variable lsfr : std_logic_vector (15 downto 0) := (others => '0'); --reset of lsfr
		variable snapshot : std_logic_vector (15 downto 0) := (others => '0');
		variable cycle_counter : integer;
		variable min_period : integer := integer'HIGH;
		variable max_period : integer := 0;
	
	begin
		-- reset
		en <= '0';
		res_n <= '0';
		load_seed <= '0';
		seed <= (others => '0');
		wait for 10 * CLK_PERIOD;
		wait until rising_edge(clk);	
		res_n <= '1';

		report "starting simulation";	

		for seed_pos in n_a to n_b loop

			en <= '0';

			-- convert seed_pos from int to std_logic_vector
			seed <=  std_logic_vector(to_unsigned(seed_pos, seed'length));
 
			-- feed new seed to prng
			wait until rising_edge(clk);
			load_seed <= '1';
			wait until rising_edge(clk);
			load_seed <= '0';
			wait until rising_edge(clk);
			
			-- get prdata from prng
			en <= '1';
			wait until rising_edge(clk);
		
			-- update lsfr with new prng data
			lsfr_fill_counter := 0;
			cycle_counter := 0;

			lsfr_logic : loop
				if lsfr_fill_counter < 32 then
					
					lsfr_fill_counter := lsfr_fill_counter + 1;

					lsfr := lsfr(14 downto 0) & prdata;
					-- t_lsfr := lsfr; ----------
					
					if lsfr_fill_counter = 32 then
						snapshot := lsfr;
						-- t_snapshot := snapshot; ----------
					end if;

				else 
					
					cycle_counter := cycle_counter +1;
					
					lsfr := lsfr(14 downto 0) & prdata;
					-- t_lsfr := lsfr; ----------

					if lsfr = snapshot then
						exit lsfr_logic;
					end if;
				
				end if;
				wait until rising_edge(clk);
			end loop ; -- lsfr_logic

			-- apply new cycle_counter to min & max values
			if cycle_counter < min_period then
				min_period := cycle_counter;
			elsif cycle_counter > max_period then
				max_period := cycle_counter;
			end if;

			report "seed: " & integer'IMAGE(seed_pos) & ", period: " & integer'IMAGE(cycle_counter);
			
		end loop;
		
		report "min period: " & integer'IMAGE(min_period) & ", max period: " & integer'IMAGE(max_period);

		-- stop clk because required interval has been processed 
		stop_clk <= true;
		finish;
		wait;

	end process;

end architecture;


