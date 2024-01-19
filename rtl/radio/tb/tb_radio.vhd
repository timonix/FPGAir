library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_radio is
end tb_radio;

architecture tb of tb_radio is


    signal clk       : std_logic;
    signal rst       : std_logic;
    signal channel_1 : std_logic;
    signal signal_1  : unsigned (10 downto 0);

    constant TbPeriod : time := 37 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin
    

    dut : entity work.radio_channel(rtl)
    port map (
        clk       => clk,
        rst       => rst,
        enable    => true,
        channel_pwm => channel_1,
        channel_data  => signal_1);

    
    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        channel_1 <= '0';

        -- Reset generation
        -- EDIT: Check that rst is really your reset signal
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 100 ns;
        
        wait for 100 ns;
        channel_1 <= '1';
        wait for 1500 us;
        channel_1 <= '0';
        
        wait for 500 us;

        -- EDIT Add stimuli here
        wait for 100 * TbPeriod;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;