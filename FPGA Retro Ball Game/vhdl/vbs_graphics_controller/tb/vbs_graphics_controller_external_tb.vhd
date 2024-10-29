--TB

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use work.vbs_graphics_controller_pkg.all;

entity vbs_graphics_controller_external_tb is
end entity;

architecture tb of vbs_graphics_controller_external_tb is 

    signal clk : std_logic;
    signal stop_clk : std_logic := '0';
    signal res_n : std_logic;
    constant CLK_PERIOD : time := 20 ns;   
    
    signal vga_r : std_logic_vector(7 downto 0);
	signal vga_g : std_logic_vector(7 downto 0);
	signal vga_b : std_logic_vector(7 downto 0);

begin

--UUT
    uut: vbs_graphics_controller 
    generic map (
        CLK_FREQ => 50_000_000
    )
    port map (
        clk =>  clk,
        res_n =>  res_n,
        gfx_instr => (others => '0'),
        gfx_instr_wr => '0',
        gfx_instr_full => open,
        gfx_data => (others => '0'),
        gfx_data_wr => '0',
        gfx_data_full => open,
        gfx_frame_sync => open,
        vga_r =>  vga_r,
        vga_g =>  vga_g,
        vga_b =>  vga_b,
        vga_clk =>  open,
        vga_sync_n =>  open,
        vga_blank_n =>  open
    );

--CLK_GENERATOR

    clk_generator : process
    begin
        clk_loop : while not stop_clk loop
        clk <= '0', '1' after CLK_PERIOD/2;
        wait for CLK_PERIOD;
        end loop ; -- clk_loop
    end process ; -- clk_generator

--RESET
    reset : process
	begin
		wait until rising_edge(clk);
		res_n <= '0';
		for i in 0 to 30 loop
			wait until rising_edge(clk);
            
		end loop;
		res_n <= '1';
		wait;
	end process;

end architecture;