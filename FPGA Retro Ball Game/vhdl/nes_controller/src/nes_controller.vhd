library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.nes_controller_pkg.all;

entity nes_controller is
    generic (
        CLK_FREQ : integer := 50000000;
        CLK_OUT_FREQ : integer := 1000000; --max possible value: 1MHz
        REFRESH_TIMEOUT : integer := 400000--8/((1/CLK_FREQ)*1000), 8ms on chosen clk_time
    );
    port (
        clk : in std_logic;
        res_n : in std_logic;
        nes_latch : out std_logic;
        nes_clk : out std_logic;
        nes_data : in std_logic;
        button_state : out nes_buttons_t
    );

end nes_controller;

architecture beh of nes_controller is

    type state_t is (WAIT_TIMEOUT, LATCH, LATCH_WAIT, CLK_LOW, SAMPLE, CLK_HIGH);

    signal state, state_next : state_t;
    signal bit_cnt, bit_cnt_next : integer := 0;
    signal clk_cnt, clk_cnt_next : integer := 0;
    signal shiftreg, shiftreg_next : std_logic_vector(7 downto 0);
    signal button_state_next : nes_buttons_t;

    constant BIT_TIME : integer := CLK_FREQ/CLK_OUT_FREQ;
    -- hz/hz = num
    
begin

    sync_proc : process(all)
    begin
        
        if res_n = '0' then

            --reset values
            state <= WAIT_TIMEOUT;
            bit_cnt <= 0;
            clk_cnt <= 0;
            shiftreg <= (others => '0');
            button_state.btn_up <= '0';
            button_state.btn_down <= '0';
            button_state.btn_left <= '0';
            button_state.btn_right <= '0';
            button_state.btn_a <= '0';
            button_state.btn_b <= '0';
            button_state.btn_start <= '0';
            button_state.btn_select <= '0';

        elsif rising_edge(clk) then

            --update values
            state <= state_next;
            bit_cnt <= bit_cnt_next;
            clk_cnt <= clk_cnt_next;
            shiftreg <= shiftreg_next;
            button_state <= button_state_next;
            
        end if;

    end process ; -- sync_proc

    next_state : process(all)
    begin
        --define default values for _next which can be used it no new value is added
        state_next <= state;
        bit_cnt_next <= bit_cnt;  
        clk_cnt_next <= clk_cnt;
        shiftreg_next <= shiftreg;
        button_state_next <= button_state;

        case state is
            
            when WAIT_TIMEOUT =>

                nes_latch <= '0';
                nes_clk <= '1';

                button_state_next.btn_a <= shiftreg(7);
                button_state_next.btn_b <= shiftreg(6);
                button_state_next.btn_select <= shiftreg(5);
                button_state_next.btn_start <= shiftreg(4);
                button_state_next.btn_up <= shiftreg(3);
                button_state_next.btn_down <= shiftreg(2);
                button_state_next.btn_left <= shiftreg(1);
                button_state_next.btn_right <= shiftreg(0);

                if clk_cnt = (REFRESH_TIMEOUT) then
                    clk_cnt_next <= 0;
                    state_next <= LATCH;
                else
                
                    clk_cnt_next <= clk_cnt +1;
                end if ;
            
            when LATCH =>

                nes_latch <= '1';
                nes_clk <= '1';

                if clk_cnt = (BIT_TIME/2) then
                    clk_cnt_next <= 0;
                    state_next <= LATCH_WAIT;
                else
                    clk_cnt_next <= clk_cnt +1;
                end if ;

            when LATCH_WAIT =>

                nes_latch <= '0';
                nes_clk <= '1';

                if clk_cnt = (BIT_TIME/2) then
                    clk_cnt_next <= 0;
                    state_next <= CLK_LOW;
                else
                    clk_cnt_next <= clk_cnt +1;
                end if ;

            when CLK_LOW =>

                nes_latch <= '0';
                nes_clk <= '0';

                if clk_cnt = (BIT_TIME/2-1) then
                    clk_cnt_next <= 0;
                    state_next <= SAMPLE;
                else
                    clk_cnt_next <= clk_cnt +1;
                end if ;

            when SAMPLE =>

                nes_latch <= '0';
                nes_clk <= '0';

                shiftreg_next <= shiftreg(6 downto 0) & not nes_data;

                state_next <= CLK_HIGH;

            when CLK_HIGH =>

                nes_latch <= '0';
                nes_clk <= '1';

                if ((bit_cnt /= 7) and (clk_cnt = BIT_TIME/2)) then
                    bit_cnt_next <= bit_cnt+1;
                    clk_cnt_next <= 0;
                    state_next <= CLK_LOW;
                elsif ((bit_cnt = 7) and (clk_cnt = BIT_TIME/2)) then
                    bit_cnt_next <= 0;
                    clk_cnt_next <= 0;
                    state_next <= WAIT_TIMEOUT;
                else
                    clk_cnt_next <= clk_cnt+1;
                end if;
            
            when others =>
                state_next <= WAIT_TIMEOUT;
            
        end case;

    end process ; -- next_state

end beh ; -- beh

