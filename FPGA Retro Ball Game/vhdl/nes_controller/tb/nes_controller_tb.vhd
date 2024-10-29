library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.nes_controller_pkg.all;
use std.env.finish;

entity nes_controller_tb is
end nes_controller_tb;

architecture bench of nes_controller_tb is
 
    signal clk : std_logic;
    signal res_n : std_logic;
    signal nes_clk : std_logic;
    signal nes_latch : std_logic;
    signal nes_data : std_logic;
    signal button_state : nes_buttons_t;
    signal stop_clk : boolean := false;     

    constant CYCLE_TIME : time := 20 ns; --(1/(CLK_FREQ))*1000000000;
   
begin

    uut: nes_controller
    generic map (
        CLK_FREQ => 50000000,
        CLK_OUT_FREQ => 1000000,
        REFRESH_TIMEOUT => 20
    )
    
    port map (
        clk => clk,
		res_n => res_n,
		nes_clk => nes_clk,
		nes_latch => nes_latch,
		nes_data => nes_data,
		button_state => button_state
    );

    -- clk generator, which stops generating when stop_clk is high
    clk_generator : process
    begin
        clk_loop : while not stop_clk loop
            clk <= '1';
            wait for CYCLE_TIME/2;
            clk <= '0';
            wait for CYCLE_TIME/2;
        end loop ; -- clk_loop
    end process ; -- clk_generator

    simulation : process

     --button state value calc: 
        --11807845 mod 2^16 = 11365 = 0x2C65
            --b_0: 0x2C = 00101100
            --b_1: 0x65 = 01100101

    --have to be defined here, because they are var's
    variable b_0 : std_logic_vector(7 downto 0) := "00101100";
    variable b_1 : std_logic_vector(7 downto 0) := "01100101";

    procedure data_transmission (data : in std_logic_vector(7 downto 0)) is
        begin
            sending_loop : for i in 7 downto 0 loop
                wait until falling_edge(nes_clk);
                nes_data <= data(i);
            end loop ; -- sending_loop
        end procedure;

    begin
        --reset
        res_n <= '0';
        wait for 20*CYCLE_TIME;
        nes_data <= '0';
        wait until rising_edge(clk);
        res_n <= '1';

        --starting simulation
        wait until rising_edge(clk);
        report "starting simulation";

        --sending button data
        wait until rising_edge(nes_latch);
        data_transmission(b_0);
        wait until rising_edge(clk);
        data_transmission(b_1);

        --ending simulation
        wait for 300*CYCLE_TIME;
        report "simulation complete";
        stop_clk <= true;
        finish;
        wait;

    end process ; -- simulation

end bench ; -- bench