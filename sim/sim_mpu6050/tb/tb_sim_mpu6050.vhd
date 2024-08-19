library ieee;
use ieee.std_logic_1164.all;

entity tb_sim_mpu6050 is
end entity tb_sim_mpu6050;

architecture tb of tb_sim_mpu6050 is
    constant TbPeriod : time := 37.037 ns; -- 27 MHz clock period
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

    signal clk : std_logic;
    signal rst : std_logic;
    signal sda : std_logic;
    signal scl : std_logic;
    signal update : boolean := true;

begin
    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';
    clk <= TbClock;
    
    sda <= 'H';
    scl <= 'H';

    -- Instantiate the I2C_brute entity
    dut : entity work.brute_6050
    generic map (
        frequency_mhz => 27.0,
        i2c_frequency_mhz => 0.4,
        start_on_reset => true,
        reset_on_reset => true,
        simulation => false
    )
    port map (
        clk => clk,
        rst => rst,
        sda => sda,
        scl => scl,
        update_mpu => update
    );
    
    dut2 : entity work.sim_mpu6050
    port map (
        rst => rst,
        sda => sda,
        scl => scl
    );

    -- Stimulus process
    stim_proc : process
    begin
        -- Initialize inputs
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 100 ns;

        wait for 2000 us;
        TbSimEnded <= '1';
        wait;
    end process;

end architecture tb;