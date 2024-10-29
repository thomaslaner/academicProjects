--Task 5B

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use work.lcd_graphics_controller_pkg.all;
use work.gfx_if_pkg.all;
use std.env.finish;

entity lcd_graphics_controller_tb is
end entity;

architecture tb of lcd_graphics_controller_tb is 
--LCD_GRAPHICS_CONTROLLER

    signal clk : std_logic;                                                  --global clk
    signal res_n : std_logic;                                                --global reset, low active, not internally synchronized
    signal display_clk : std_logic;                                          --clk used to interface with display (max 3.8 MHz)
    signal display_res_n : std_logic;                                        --display reset, low active, not internally synchronized                        
    
    --instruction interface
    signal gfx_instr : std_logic_vector(GFX_INSTR_WIDTH -1 downto 0);        --actual instruction
    signal gfx_instr_wr : std_logic;                                         --write signal of instruction FIFO
    signal gfx_instr_full : std_logic;                                       --full signal of instruction FIFO
    signal gfx_data : std_logic_vector(GFX_DATA_WIDTH -1 downto 0);          --data associated with instruction (coordinates, colors...)
    signal gfx_data_wr : std_logic;                                          --write signal of data FIFO
    signal gfx_data_full :  std_logic;                                       --full signal of data FIFO
    signal gfx_frame_sync :  std_logic;                                      --frame synchronization signal
    
    --external interface to the SRAM
    signal sram_dq : std_logic_vector(SRAM_DATA_WIDTH -1 downto 0);         --SRAM data inputs/outputs
    signal sram_addr : std_logic_vector(SRAM_ADDRESS_WIDTH -1 downto 0);    --SRAM address input
    signal sram_ub_n : std_logic;                                           --SRAM upper byte control
    signal sram_lb_n : std_logic;                                           --SRAM lower byte control
    signal sram_we_n :  std_logic;                                          --SRAM write enable
    signal sram_ce_n :  std_logic;                                          --SRAM chip enable
    signal sram_oe_n : std_logic;                                           --SRAM output enable
    
    --external interface to the LCD
    signal nclk : std_logic;                                                --LCD clock signal
    signal hd : std_logic;                                                  --LCD horizontal sync input
    signal vd : std_logic;                                                  --LCD vertical sync input
    signal den : std_logic;                                                 --LCD rgb data enable
    signal r : std_logic_vector(7 downto 0);                                --LCD red color data bus
    signal g : std_logic_vector(7 downto 0);                                --LCD green color data bus
    signal b : std_logic_vector(7 downto 0);                                --LCD blue color data bus
    signal grest : std_logic;                                               --LCD global reset, low active
    
    --serial interface to LCD driver IC
    signal sda : std_logic;                                                 --data signal of serial interface to LCD driver IC
    signal sclk : std_logic;                                                --clk signal of the serial interface to LCD driver IC
    signal scen : std_logic;                                                --chip select signal of the serial interface to LCD driver IC

--Testbench signals, variables and constants

    signal tb_write_file : std_logic;                                       --used to enable image dump of sram, high active
    signal stop_clk : boolean := false;
    signal clk_cyc_since_write : integer;

    constant CLK_PERIOD : time := 20 ns;                                    
    constant DISPLAY_CLK_PERIOD : time := 500 ns;
    constant n : integer := 16;

--SRAM

    component sram is
        generic (
            OUTPUT_DIR   : string  := "./"
        );
        port (
            -- SRAM interface
            dq : inout std_logic_vector(15 downto 0);                       --SRAM data in-/outputs
            addr : in std_logic_vector(19 downto 0);                        --SRAM address input
            lb_n : in std_logic;                                            --SRAM lower byte control
            ub_n : in std_logic;                                            --SRAM upper byte control                             
            ce_n : in std_logic;                                            --SRAM chip enable
            oe_n : in std_logic;                                            --SRAM output enable
            we_n : in std_logic;                                            --SRAM write enable
    
            -- on rising_edge: dump frame to file
            write_file : in std_logic;                                      --signals the SRAM to start a image dump
            base_address : natural := 0;
            width : natural := 400;
            height : natural := 240
        );
    end component;

begin

--UUT
    uut: lcd_graphics_controller 
    port map (
        clk => clk,
		res_n => res_n,
		display_clk => display_clk,
		display_res_n => display_res_n,
		gfx_instr => gfx_instr,
		gfx_instr_wr => gfx_instr_wr,
		gfx_instr_full => gfx_instr_full,
		gfx_data => gfx_data,
		gfx_data_wr => gfx_data_wr,
		gfx_data_full => gfx_data_full,
		gfx_frame_sync => gfx_frame_sync,
		sram_dq => sram_dq,
		sram_addr => sram_addr,
		sram_ub_n => sram_ub_n,
		sram_lb_n => sram_lb_n,
		sram_we_n => sram_we_n,
		sram_ce_n => sram_ce_n,
		sram_oe_n => sram_oe_n,
		nclk => nclk,
		hd => hd,
		vd => vd,
		den => den,
		r => r,
		g => g,
		b => b,
		grest => grest,
		sclk => sclk,
		sda => sda,
		scen => scen
    );

--SRAM_INST
    sram_inst: sram
    generic map (
        OUTPUT_DIR => "./"
    )
    port map (
        dq => sram_dq,
		addr => sram_addr,
		lb_n => sram_lb_n,
		ub_n => sram_ub_n,
		ce_n => sram_ce_n,
		oe_n => sram_oe_n,
		we_n => sram_we_n,
		write_file => tb_write_file,
		base_address => 0,
		width => 400,
		height => 240
    );

--CLK_GENERATOR

    clk_generator : process
    begin
        clk_loop : while not stop_clk loop
        clk <= '0', '1' after CLK_PERIOD/2;
        wait for CLK_PERIOD;
        end loop ; -- clk_loop
    end process ; -- clk_generator

--DISPLAY_CLK_GENERATOR

    display_clk_generator : process
    begin
        display_clk_loop : while not stop_clk loop
        display_clk <= '0', '1' after DISPLAY_CLK_PERIOD/2;
        wait for DISPLAY_CLK_PERIOD;
        end loop ; -- display_clk_loop
    end process ; -- display_clk_generator

--STOP_CHECK
    
    stop_check : process
    begin
        if rising_edge(clk) then

            if (sram_we_n = '0') then
                clk_cyc_since_write <= 0;
            else
                clk_cyc_since_write <= clk_cyc_since_write +1;
            end if ;

            if clk_cyc_since_write = 100 then
                wait for 2000*CLK_PERIOD;
                report "simulation done!";
                stop_clk <= true;
                finish;
            end if ;
        end if ; 
        wait on clk, gfx_instr_wr, gfx_data_wr;
    end process ; -- stop_check

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
        display_res_n <= '0';
        tb_write_file <= '0';
        gfx_data_wr <= '0';
        gfx_data <= (others => '0');
        instruction_assignment(GFX_INSTR_CLEAR);
        instruction_assignment(GFX_INSTR_NOP);
        res_n <= '1';
        wait until rising_edge(display_clk);
        display_res_n <= '1';
        wait for 20*CLK_PERIOD;
        report "starting simulation";
        
    --set primary color
        instruction_assignment(GFX_INSTR_SET_COLOR(true));
        
        --color
        data_assignment("1010101010101010"); --red = 5bit, green = 6bit, blue = 5bit
        
    --set pattern
        instruction_assignment(GFX_INSTR_SET_PATTERN(3));

        --p0
        data_assignment("0001001010010011"); --bw,bh,dx,dy
        --p1
        data_assignment("0000000000001000");  --ls -> in lower 5 bit
    
    --draw rectangles
        instruction_assignment(GFX_INSTR_DRAW_RECT(true, true, 3)); --enable_alpha, draw_border, pattern_id
        data_assignment(std_logic_vector(to_unsigned(0, 16))); --x
        data_assignment(std_logic_vector(to_unsigned(0, 16))); --y
        data_assignment(std_logic_vector(to_unsigned(n, 16))); --w
        data_assignment(std_logic_vector(to_unsigned(n, 16))); --h

        /* 
            wait until rising_edge(clk);
            tb_write_file <= '1';
            wait until rising_edge(clk);
            tb_write_file <= '0';
            wait until rising_edge(clk);
        */
        
        instruction_assignment(GFX_INSTR_DRAW_RECT(true, true, 3)); --enable_alpha, draw_border, pattern_id
        data_assignment(std_logic_vector(to_unsigned(400-n, 16))); --x 400
        data_assignment(std_logic_vector(to_unsigned(240-n, 16))); --y 240
        data_assignment(std_logic_vector(to_unsigned(n, 16))); --w
        data_assignment(std_logic_vector(to_unsigned(n, 16))); --h

    --frame sync
        instruction_assignment(GFX_INSTR_FRAME_SYNC);

    --dump file
        wait for 2000*clk_period;
        tb_write_file <= '1';
        

        wait;
    end process ; -- stimulus
    
end tb ; -- tb 