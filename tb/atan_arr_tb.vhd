library ieee;
use ieee.std_logic_1164.all;

entity tb_atan_arr is
end tb_atan_arr;

architecture tb of tb_atan_arr is



signal clk         : std_logic;
signal rst         : std_logic;
signal i_update    : boolean;
signal i_iteration : positive;
signal i_d         : boolean;
signal o_z         : boolean;

constant TbPeriod : time := 1000 ns; -- EDIT Put right period here
signal TbClock : std_logic := '0';
signal TbSimEnded : std_logic := '0';

begin

    dut : entity work.atan_arr(rtl)
    port map (clk         => clk,
        rst         => rst,
        i_update    => i_update,
        i_iteration => i_iteration,
        i_d         => i_d,
        o_z         => o_z);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        i_update <= true;
        i_iteration <= 20;
        i_d <= true;

        -- Reset generation
        -- EDIT: Check that rst is really your reset signal
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 100 ns;

        -- EDIT Add stimuli here
        wait for 100 * TbPeriod;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;
