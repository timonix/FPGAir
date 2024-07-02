library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.fixed_pkg.all;

entity top_aurora is
    generic (
        frequency_mhz : real := 27.0
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        sda : inout std_logic;
        scl : inout std_logic;
        radio_channels : in std_logic_vector(6 downto 1);
        
        pulse_out : out std_logic;
        led_out : out std_logic;
        start_btn : in std_logic
    );
end entity top_aurora;

architecture rtl of top_aurora is

    signal acc_x : STD_LOGIC_VECTOR(15 downto 0);
    signal acc_y : STD_LOGIC_VECTOR(15 downto 0);
    signal acc_z : STD_LOGIC_VECTOR(15 downto 0);
    
    signal filtered_acc_x : SIGNED(15 downto 0);
    signal filtered_acc_y : SIGNED(15 downto 0);
    signal filtered_acc_z : SIGNED(15 downto 0);
    
    signal roll : UNSIGNED(15 downto 0);
    signal pid_roll : sfixed(10 downto -11);
    signal pid_setpoint : sfixed(10 downto -11);
    signal pid_output : sfixed(10 downto -11);

    
    type channel_data_array is array (1 to 6) of unsigned(10 downto 0);
    signal channel_data : channel_data_array;

    signal mpu_data_valid : boolean;
    
    
    signal read_mpu : boolean;
    signal calculate_attitude : boolean;
    signal update_pid : boolean;
    signal send_pulse : boolean;
    
    signal system_armed : boolean;
    
begin

    mpu6050_inst : entity work.brute_6050
    generic map (
        frequency_mhz => 27.0,
        i2c_frequency_mhz => 0.4,
        reset_on_reset => false,
        start_on_reset => true,
        simulation => false
    )
    port map (
        clk => clk,
        rst => rst,
        sda => sda,
        scl => scl,
        acc_x => acc_x,
        acc_y => acc_y,
        acc_z => acc_z,
        mpu_data_valid => mpu_data_valid,
        update_mpu => read_mpu
    );
    
    filter_x : entity work.rolling_average_filter
    generic map (
        taps => 4,
        data_width => 16
    )
    port map (
        clk => clk,
        reset => rst,
        update => mpu_data_valid,
        i_data => signed(acc_x),
        o_data => filtered_acc_x
    );
    
    filter_y : entity work.rolling_average_filter
    generic map (
        taps => 4,
        data_width => 16
    )
    port map (
        clk => clk,
        reset => rst,
        update => mpu_data_valid,
        i_data => signed(acc_y),
        o_data => filtered_acc_y
    );
    
    filter_z : entity work.rolling_average_filter
    generic map (
        taps => 4,
        data_width => 16
    )
    port map (
        clk => clk,
        reset => rst,
        update => mpu_data_valid,
        i_data => signed(acc_z),
        o_data => filtered_acc_z
    );
    
    roll_module : entity work.attitude_module_roll
    generic map (
        data_width => 16
    )
    port map (
        clk => clk,
        rst => rst,
        data_in_valid => calculate_attitude,
        gravity_x => filtered_acc_x,
        gravity_y => filtered_acc_y,
        gravity_z => filtered_acc_z,
        roll => roll
    );
    
        -- Instantiate 6 radio channels
    gen_channels: for i in 1 to 6 generate
        channel_inst: entity work.radio_channel
        generic map (
            frequency_mhz => frequency_mhz
        )
        port map (
            clk => clk,
            rst => rst,
            enable => true,
            channel_pwm => radio_channels(i),
            channel_data => channel_data(i)
        );
    end generate;
    
    arming_inst : entity work.arming
    port map (
        clk => clk,        -- Connect to your clock signal
        rst => rst,      -- Connect to your reset signal
        channel_1 => channel_data(1),  -- Connect to your channel 1 signal
        channel_2 => channel_data(2),  -- Connect to your channel 2 signal
        channel_3 => channel_data(3),  -- Connect to your channel 3 signal
        channel_4 => channel_data(4),  -- Connect to your channel 4 signal
        channel_5 => channel_data(5),  -- Connect to your channel 5 signal
        armed => system_armed     -- Connect to your armed signal
    );
    pidassignment: for i in 10 downto -4 generate
        pid_roll(i) <= roll(i+5);
    end generate;
    
    pid_roll(-5 downto -11) <= (others => '0');

    pid_inst : entity work.pid(rtl)
    generic map (
        integer_bits => 11,
        fractional_bits => 11,
        Kp => 0.005,
        Ki => 0.001,
        Kd => 0.002
    )
    port map (
        clk  => clk,
        rst => rst,
        enable => true,
        update => update_pid,
        
        A_setpoint => (others => '0'),
        A_measured => (others => '0'),
        A_output =>open,
        
        B_setpoint =>pid_setpoint,
        B_measured =>pid_roll,
        B_output   =>pid_output
    );

end architecture rtl;