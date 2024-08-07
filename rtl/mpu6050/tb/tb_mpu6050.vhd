library ieee;
use ieee.std_logic_1164.all;
use IEEE.fixed_pkg.all;
entity tb_mpu6050 is
end tb_mpu6050;



architecture tb of tb_mpu6050 is



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

    dut : entity work.mpu(rtl)
    generic map(
        frequency_mhz => 27.0,
        i2c_frequency_mhz => 0.4,
        start_on_reset => false,
        simulation => true
    )
    port map (clk       => clk,
        rst       => rst,
        sda       => sda,
        scl       => scl,
        o_working => o_working,
        i_update  => i_update);

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