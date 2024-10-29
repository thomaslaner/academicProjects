--TB

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use work.vbs_graphics_controller_pkg.all;
use work.gfx_if_pkg.all;

entity vbs_graphics_controller_internal_tb is
end entity;

architecture tb of vbs_graphics_controller_internal_tb is 
--LCD_GRAPHICS_CONTROLLER

    signal clk : std_logic;
    signal stop_clk : std_logic := '0';
    signal res_n : std_logic;
    constant CLK_PERIOD : time := 20 ns;   

    signal vga_r : std_logic_vector(7 downto 0);
    signal vga_g : std_logic_vector(7 downto 0);
    signal vga_b : std_logic_vector(7 downto 0);

    --instruction interface
    signal gfx_instr : std_logic_vector(GFX_INSTR_WIDTH -1 downto 0);        --actual instruction
    signal gfx_instr_wr : std_logic;                                         --write signal of instruction FIFO
    signal gfx_instr_full : std_logic;                                       --full signal of instruction FIFO
    signal gfx_data : std_logic_vector(GFX_DATA_WIDTH -1 downto 0);          --data associated with instruction (coordinates, colors...)
    signal gfx_data_wr : std_logic;                                          --write signal of data FIFO
    signal gfx_data_full :  std_logic;                                       --full signal of data FIFO
    signal gfx_frame_sync :  std_logic;                                      --frame synchronization signal

    constant w : integer := 4;
    constant h : integer := 4;
    
begin

--UUT
uut: vbs_graphics_controller 
generic map (
    CLK_FREQ => 50_000_000
)
port map (
    clk =>  clk,
    res_n =>  res_n,
    gfx_instr => gfx_instr,
    gfx_instr_wr => gfx_instr_wr,
    gfx_instr_full => gfx_instr_full,
    gfx_data => gfx_data,
    gfx_data_wr => gfx_data_wr,
    gfx_data_full => gfx_data_full,
    gfx_frame_sync => gfx_frame_sync,
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

--STIMULUS

    stimulus : process

        procedure instruction_assignment (instruction : std_logic_vector(7 downto 0)) is
        begin

            if gfx_instr_full = '1' then
                report "instr_full - waiting";
                wait until gfx_instr_full = '0';
            end if ;

            gfx_instr_wr <= '1';
            gfx_instr <= instruction;
            wait until rising_edge(clk);
            gfx_instr_wr <= '0';
            wait until rising_edge(clk);

        end procedure; --instruction_assignment

        procedure data_assignment (data : std_logic_vector(15 downto 0)) is
        begin

            if gfx_data_full = '1' then
                report "instr_data - waiting";
                wait until gfx_data_full = '0';
            end if ;

            gfx_data_wr <= '1';
            gfx_data <= data;
            wait until rising_edge(clk);
            gfx_data_wr <= '0';
            wait until rising_edge(clk);
    
        end procedure; --data_assignment

    begin
    --reset
        res_n <= '0';
        gfx_data_wr <= '0';
        gfx_data <= (others => '0');
        gfx_instr_wr <= '0';
        gfx_instr <= (others => '0');
        wait for 20*CLK_PERIOD;
        res_n <= '1';
        wait for 20*CLK_PERIOD;
        report "starting simulation";

    --set primary color
        instruction_assignment(GFX_INSTR_SET_COLOR(true));                  --01010001
        
        --color
        data_assignment("0000000000000010");
        
/*
    --set pixel
        
        instruction_assignment(GFX_INSTR_SET_PIXEL);

        --x
        data_assignment("0000000110001111");

        --y
        data_assignment("0000000011101111");

        -- instruction_assignment(GFX_INSTR_SET_CFG(true));
*/

/*
        instruction_assignment(GFX_INSTR_CLEAR);                            --00000001
        instruction_assignment(GFX_INSTR_FRAME_SYNC);                       --00000010
*/
/*
    --set pattern
        instruction_assignment(GFX_INSTR_SET_PATTERN(3));                   --01100011
        --p0
        data_assignment("0001001010010011"); --bw,bh,dx,dy
        --p1
        data_assignment("0000000000001000");  --ls -> in lower 5 bit
*/
/*
    --draw rectangles
        instruction_assignment(GFX_INSTR_DRAW_RECT(false, true, 3)); --enable_alpha, draw_border, pattern_id             --10011011
        data_assignment(std_logic_vector(to_unsigned(0, 16))); --x
        data_assignment(std_logic_vector(to_unsigned(0, 16))); --y
        data_assignment(std_logic_vector(to_unsigned(400, 16))); --w
        data_assignment(std_logic_vector(to_unsigned(240, 16))); --h
*/

/*
    --frame sync
        instruction_assignment(GFX_INSTR_FRAME_SYNC);

*/
/*
        instruction_assignment(GFX_INSTR_FRAME_SYNC);
        instruction_assignment(GFX_INSTR_CLEAR);

        instruction_assignment(GFX_INSTR_FRAME_SYNC);
        instruction_assignment(GFX_INSTR_DRAW_CIRCLE);
        data_assignment("0000000000100000");
        data_assignment("0000000000001000");
        data_assignment("0000000000000010");

*/
/*
        -- Set primary color
        instruction_assignment(GFX_INSTR_SET_COLOR(false));
                        
        -- Color
        data_assignment("0000000000000000");

        -- instruction_assignment(x"98");
        instruction_assignment(GFX_INSTR_DRAW_RECT(false, true, 7));
        data_assignment(std_logic_vector(to_unsigned(0, 16)));
        data_assignment(std_logic_vector(to_unsigned(0, 16)));
        data_assignment(std_logic_vector(to_unsigned(400, 16)));
        data_assignment(std_logic_vector(to_unsigned(240, 16)));

*/

        report "simulation complete";
        wait;
    end process ; -- stimulus
    
end architecture; -- tb 