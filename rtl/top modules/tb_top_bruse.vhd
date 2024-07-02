library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_top_bruse is
end entity tb_top_bruse;

architecture Behavioral of tb_top_bruse is
    constant TbPeriod : time := 37 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';
    
    signal clk : std_logic;
    signal rst : std_logic := '1';
    signal pulse_out : std_logic;
    signal led_out : std_logic;
    signal start_btn : std_logic := '1';
    
begin
    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';
    clk <= TbClock;
    
    -- Instantiate the top module
    uut: entity work.top_bruse
    port map (
        clk => clk,
        rst => rst,
        pulse_out => pulse_out,
        led_out => led_out,
        start_btn => start_btn
    );
    
    -- Stimulus process
    stim_proc: process
    begin
        -- Reset the module
        rst <= '0';
        wait for 100 ns;
        rst <= '1';
        wait for 100 ns;
        wait for 1000 us;
        -- Press the start button
        start_btn <= '0';
        wait for 200 ns;
        start_btn <= '1';
        wait for 10000 us;
        
        
        -- End the simulation
        TbSimEnded <= '1';
        wait;
    end process;
    
end architecture Behavioral;