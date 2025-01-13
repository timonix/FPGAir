library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.fixed_pkg.all;

entity tb_neo_gyro_estimator_full is
end tb_neo_gyro_estimator_full ;

architecture behavior of tb_neo_gyro_estimator_full  is

    -- Signals to drive the DUT (Device Under Test)
    signal clk   : std_logic := '0';
    signal rst   : std_logic := '0';
    
    signal gyro_x : std_logic_vector(15 downto 0) := (others => '0');
    signal gyro_y : std_logic_vector(15 downto 0) := (others => '0');
    signal gyro_z : std_logic_vector(15 downto 0) := (others => '0');
    
    signal gravity_x : sfixed(5 downto -18) := to_sfixed(0.0, 5, -18);
    signal gravity_y : sfixed(5 downto -18) := to_sfixed(0.0, 5, -18);
    signal gravity_z : sfixed(5 downto -18) := to_sfixed(0.0, 5, -18);
    
    signal acc_estimate_x : sfixed(5 downto -18) := to_sfixed(0.0, 5, -18);
    signal acc_estimate_y : sfixed(5 downto -18) := to_sfixed(0.0, 5, -18);
    signal acc_estimate_z : sfixed(5 downto -18) := to_sfixed(0.0, 5, -18);
    
    signal new_estimate_x : sfixed(5 downto -18);
    signal new_estimate_y : sfixed(5 downto -18);
    signal new_estimate_z : sfixed(5 downto -18);
    
    signal start_processing : boolean := false;

    -- Clock generation signals
    signal TbClock       : std_logic := '0';
    signal TbPeriod      : time := 10 ns;  -- Clock period
    signal TbSimRunning  : boolean := true;
    
begin

    -- DUT instantiation
    DUT: entity work.neo_gyro_estimator
    generic map (
        gyro_scale   => 0.007,
        gyro_bias_x  => 0.0,
        gyro_bias_y  => 0.0,
        gyro_bias_z  => 0.0,
        alpha        => 0.95,
        integer_bits => 6,
        fractional_bits => 18
    )
    port map (
        clk => clk,
        rst => rst,
        gyro_x => gyro_x,
        gyro_y => gyro_y,
        gyro_z => gyro_z,
        gravity_x => gravity_x,
        gravity_y => gravity_y,
        gravity_z => gravity_z,
        new_estimate_x => new_estimate_x,
        new_estimate_y => new_estimate_y,
        new_estimate_z => new_estimate_z,
        acc_estimate_x => acc_estimate_x,
        acc_estimate_y => acc_estimate_y,
        acc_estimate_z => acc_estimate_z,
        start_processing => start_processing
    );

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimRunning else '0';
    clk <= TbClock;

    -- Test process
    process
    begin
        -- Initialize reset
        rst <= '1';
        wait for TbPeriod*10;  -- Hold reset active for 20 ns
        rst <= '0';

        -- Set gyroscope inputs
        gyro_x <= x"0000";  -- Example gyroscope data (hexadecimal representation)
        gyro_y <= x"0000";
        gyro_z <= x"0000";
        
        -- Set gravity vectors and accelerometer estimates
        gravity_x <= to_sfixed(0.25, gravity_x);
        gravity_y <= to_sfixed(0.5, gravity_y);
        gravity_z <= to_sfixed(1.0, gravity_z);
        
        acc_estimate_x <= to_sfixed(0.6, acc_estimate_x);
        acc_estimate_y <= to_sfixed(0.3, acc_estimate_y);
        acc_estimate_z <= to_sfixed(0.7, acc_estimate_z);

        -- Start the estimator processing
        start_processing <= true;
        wait for TbPeriod;  -- Allow some time for processing
        start_processing <= false;

        -- Check the results (insert your own checks or monitoring here)
        wait for 500 ns;  -- Let simulation run for a while to observe behavior
        

        -- Set gyroscope inputs
        gyro_x <= x"0010";  -- Example gyroscope data (hexadecimal representation)
        gyro_y <= x"0000";
        gyro_z <= x"0000";
        
        -- Set gravity vectors and accelerometer estimates
        gravity_x <= to_sfixed(0.0, gravity_x);
        gravity_y <= to_sfixed(0.0, gravity_y);
        gravity_z <= to_sfixed(-1.0, gravity_z);
        
        acc_estimate_x <= to_sfixed(0.0, acc_estimate_x);
        acc_estimate_y <= to_sfixed(0.0, acc_estimate_y);
        acc_estimate_z <= to_sfixed(-1.0, acc_estimate_z);

        -- Start the estimator processing
        start_processing <= true;
        wait for TbPeriod;  -- Allow some time for processing
        start_processing <= false;

        -- Check the results (insert your own checks or monitoring here)
        wait for 500 ns;  -- Let simulation run for a while to observe behavior

        -- End simulation
        TbSimRunning <= false;  -- Stops the clock generation
        wait;
    end process;

end behavior;
