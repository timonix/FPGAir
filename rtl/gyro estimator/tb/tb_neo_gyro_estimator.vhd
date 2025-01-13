library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.fixed_pkg.all;

entity tb_neo_gyro_estimator is
end entity;

architecture tb of tb_neo_gyro_estimator is

    -- Constants
    constant integer_bits    : integer := 6;
    constant fractional_bits : integer := 18;

    -- Signals
    signal clk   : std_logic := '0';
    signal rst   : std_logic := '0';

    signal gyro_x : std_logic_vector(15 downto 0);
    signal gyro_y : std_logic_vector(15 downto 0);
    signal gyro_z : std_logic_vector(15 downto 0);

    signal gravity_x : sfixed(integer_bits-1 downto -fractional_bits);
    signal gravity_y : sfixed(integer_bits-1 downto -fractional_bits);
    signal gravity_z : sfixed(integer_bits-1 downto -fractional_bits);

    signal new_estimate_x : sfixed(integer_bits-1 downto -fractional_bits);
    signal new_estimate_y : sfixed(integer_bits-1 downto -fractional_bits);
    signal new_estimate_z : sfixed(integer_bits-1 downto -fractional_bits);

    signal acc_estimate_x : sfixed(integer_bits-1 downto -fractional_bits);
    signal acc_estimate_y : sfixed(integer_bits-1 downto -fractional_bits);
    signal acc_estimate_z : sfixed(integer_bits-1 downto -fractional_bits);

    signal start_processing : boolean := false;
    constant TbPeriod : time := 37 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';
begin

    -- Instantiate the Unit Under Test (UUT)
    uut: entity work.neo_gyro_estimator
    generic map (
        gyro_scale      => 1.0 / 131.0,
        integer_bits    => integer_bits,
        fractional_bits => fractional_bits
    )
    port map (
        clk               => clk,
        rst               => rst,
        gyro_x            => gyro_x,
        gyro_y            => gyro_y,
        gyro_z            => gyro_z,
        gravity_x         => gravity_x,
        gravity_y         => gravity_y,
        gravity_z         => gravity_z,
        new_estimate_x    => new_estimate_x,
        new_estimate_y    => new_estimate_y,
        new_estimate_z    => new_estimate_z,
        acc_estimate_x    => acc_estimate_x,
        acc_estimate_y    => acc_estimate_y,
        acc_estimate_z    => acc_estimate_z,
        start_processing  => start_processing
    );

    -- Clock generation process
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';
    clk <= TbClock;

    -- Stimulus process
    stimulus_process : process
    begin
        -- Initial reset
        rst <= '1';
        wait for 50 ns;
        rst <= '0';
        wait for 50 ns;

        -- Test case 1: Provide gyro inputs and start processing
        gyro_x <= std_logic_vector(to_signed(-245, 16));  -- Example gyro data
        gyro_y <= std_logic_vector(to_signed(0, 16));
        gyro_z <= std_logic_vector(to_signed(0, 16));

        gravity_x <= to_sfixed(0.0, gravity_x);
        gravity_y <= to_sfixed(0.0, gravity_y);
        gravity_z <= to_sfixed(0.0, gravity_z);  -- Assume gravity in Z direction

        acc_estimate_x <= to_sfixed(0.0, acc_estimate_x);
        acc_estimate_y <= to_sfixed(0.0, acc_estimate_y);
        acc_estimate_z <= to_sfixed(0.0, acc_estimate_z);

        start_processing <= true;
        wait for TbPeriod;
        start_processing <= false;
        wait for TbPeriod;

        -- Wait for the processing to complete
        wait for TbPeriod*30;

        -- Test case 2: Change gyro inputs
        gyro_x <= std_logic_vector(to_signed(0, 16));
        gyro_y <= std_logic_vector(to_signed(1000, 16));
        gyro_z <= std_logic_vector(to_signed(0, 16));

        start_processing <= true;
        wait for TbPeriod;
        start_processing <= false;
        wait for TbPeriod;

        -- Wait for the processing to complete
        wait for 200 ns;
        TbSimEnded <= '1';

        -- End simulation
        wait;
    end process;

end architecture;
