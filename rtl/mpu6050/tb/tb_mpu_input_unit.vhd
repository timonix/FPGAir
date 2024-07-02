library ieee;
use ieee.std_logic_1164.all;
use IEEE.fixed_pkg.all;
entity tb_mpu_input_unit is
end tb_mpu_input_unit;



architecture tb of tb_mpu_input_unit is



    signal clk       : std_logic;
    signal rst       : std_logic;
    signal sda       : std_logic;
    signal scl       : std_logic;
    signal o_working : boolean;
    signal i_update  : boolean;

    constant TbPeriod : time := 37 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : entity work.mpu_input_unit(rtl)
    port map (clk       => clk,
        rst       => rst,
        sda       => sda,
        scl       => scl,
        o_working => o_working,
        i_update  => i_update,
        acc_x_bias => to_sfixed(1.5,15,-16));

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    begin

        i_update <= false;

        rst <= '1';
        wait for 100 ns;
        
        rst <= '0';
        wait for 100 ns;
        i_update <= true;
        wait for 1 * TbPeriod;
        i_update <= false;
        
        wait until not o_working;
        wait for 50000 * TbPeriod;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;