library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.fixed_pkg.all;

entity top_aurora is
    generic (
        frequency_mhz : real := 27.0;
        simulation : boolean := false
    );
    port (
        clk : in std_logic;
        a_rst : in std_logic;
        sda : inout std_logic;
        scl : inout std_logic;
        radio_channel_ext : in std_logic_vector(6 downto 1);
        motor_channel_ext : out std_logic_vector(4 downto 1);
        
        tx_ext : out std_logic;
        mpu_enable : out std_logic;
        led : out std_logic_vector(1 downto 0)
    );
end entity top_aurora;

architecture rtl of top_aurora is

    signal rst : std_logic;

    signal acc_x : STD_LOGIC_VECTOR(15 downto 0);
    signal acc_y : STD_LOGIC_VECTOR(15 downto 0);
    signal acc_z : STD_LOGIC_VECTOR(15 downto 0);
    
    signal gyro_x : STD_LOGIC_VECTOR(15 downto 0);
    signal gyro_y : STD_LOGIC_VECTOR(15 downto 0);
    signal gyro_z : STD_LOGIC_VECTOR(15 downto 0);
    
    signal filtered_acc_x : SIGNED(15 downto 0);
    signal filtered_acc_y : SIGNED(15 downto 0);
    signal filtered_acc_z : SIGNED(15 downto 0);
    
    signal roll : UNSIGNED(15 downto 0);
    signal pid_roll : sfixed(11 downto -12);
    signal pid_setpoint : sfixed(11 downto -12) := (others => '0');
    signal pid_output : sfixed(11 downto -12);

    
    type channel_data_array is array (1 to 6) of unsigned(10 downto 0);
    signal channel_data : channel_data_array;

    signal mpu_data_valid : boolean;
    
    
    signal read_mpu : boolean;
    signal calculate_attitude : boolean;
    signal update_pid : boolean;
    signal send_pulse : boolean;
    
    signal system_armed : boolean;
    
    signal motor_signal_0 : unsigned(10 downto 0);
    signal motor_signal_1 : unsigned(10 downto 0);
    signal motor_signal_2 : unsigned(10 downto 0);
    signal motor_signal_3 : unsigned(10 downto 0);
    
    signal acc_estimate_x : sfixed(5 downto -18);
    signal acc_estimate_y : sfixed(5 downto -18);
    signal acc_estimate_z : sfixed(5 downto -18);
    
    signal gravity_x : sfixed(5 downto -18);
    signal gravity_y : sfixed(5 downto -18);
    signal gravity_z : sfixed(5 downto -18);
    
    signal mpu_failure : boolean;
    
    
begin

    rst <= not a_rst;
    mpu_enable <= not rst;
    
    led(0) <= '0' when system_armed else '1';
    led(1) <= '0' when mpu_failure else '1';
    
    sequencer_inst : entity work.sequencer
    generic map (
        frequency_mhz => 27.0
    )
    port map (
        clk => clk,
        rst => rst,
        enable => true,
        update_pid => update_pid,
        update_mpu => read_mpu,
        send_pulse => send_pulse,
        calculate_attitude => calculate_attitude
    );

    mpu6050_inst : entity work.brute_6050
    generic map (
        frequency_mhz => 27.0,
        i2c_frequency_mhz => 0.4,
        reset_on_reset => true,
        start_on_reset => true,
        simulation => simulation,
        error_detection => true
    )
    port map (
        clk => clk,
        rst => rst,
        sda => sda,
        scl => scl,
        acc_x => acc_x,
        acc_y => acc_y,
        acc_z => acc_z,
        gyro_x => gyro_x,
        gyro_y => gyro_y,
        gyro_z => gyro_z,
        mpu_data_valid => mpu_data_valid,
        update_mpu => read_mpu,
        mpu_failure => mpu_failure
    );
    
    neo_gyro_estimator_inst: entity work.neo_gyro_estimator
    generic map(
        gyro_scale => 0.00174358392, --1.0 GAV 20 för 33.3rpm vill ha rad/500us
        integer_bits => 6,
        fractional_bits => 18
    )
    port map(
        clk => clk,
        rst => rst,
        gyro_x => gyro_x,
        gyro_y => gyro_y,
        gyro_z => gyro_z,
        gravity_x => gravity_x,
        gravity_y => gravity_y,
        gravity_z => gravity_z,
        new_estimate_x => gravity_x,
        new_estimate_y => gravity_y,
        new_estimate_z => gravity_z,
        acc_estimate_x => acc_estimate_x,
        acc_estimate_y => acc_estimate_y,
        acc_estimate_z => acc_estimate_z,
        start_processing => calculate_attitude
    );
    
    acc_estimate_x(5 downto 1) <= (others => filtered_acc_x(filtered_acc_x'high));
    acc_estimate_x(-15 downto -18) <= (others => '0');
    
    acc_estimate_y(5 downto 1) <= (others => filtered_acc_y(filtered_acc_y'high));
    acc_estimate_y(-15 downto -18) <= (others => '0');
    
    acc_estimate_z(5 downto 1) <= (others => filtered_acc_z(filtered_acc_z'high));
    acc_estimate_z(-15 downto -18) <= (others => '0');

    acc_est_assignment: for i in 1 downto -14 generate
    acc_estimate_x(i) <= filtered_acc_x(i+14);
    acc_estimate_y(i) <= filtered_acc_y(i+14);
    acc_estimate_z(i) <= filtered_acc_z(i+14);
end generate;




filter_x : entity work.rolling_average_filter
generic map (
    taps => 8,
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
    taps => 8,
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
    taps => 8,
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
    gravity_x => signed(std_logic_vector(gravity_x(5 downto -10))),
    gravity_y => signed(std_logic_vector(gravity_y(5 downto -10))),
    gravity_z => signed(std_logic_vector(gravity_z(5 downto -10))),
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
        channel_pwm => radio_channel_ext(i),
        channel_data => channel_data(i)
    );
end generate;

arming_inst : entity work.arming
port map (
    clk => clk,        -- Connect to your clock signal
    rst => rst,      -- Connect to your reset signal
    force_disarm => mpu_failure,
    channel_1 => channel_data(1),  -- Connect to your channel 1 signal
    channel_2 => channel_data(2),  -- Connect to your channel 2 signal
    channel_3 => channel_data(3),  -- Connect to your channel 3 signal
    channel_4 => channel_data(4),  -- Connect to your channel 4 signal
    channel_5 => channel_data(5),  -- Connect to your channel 5 signal
    armed => system_armed     -- Connect to your armed signal
);
pidassignment: for i in 11 downto -3 generate
    pid_roll(i) <= roll(i+4);
end generate;

pid_roll(-4 downto -12) <= (others => '0');

neo_pid_inst: entity work.neo_pid
generic map(
    integer_bits => 12,
    fractional_bits => 12,
    Kp => 0.6,
    Ki => 0.01,
    Kd => 0.0
)
port map(
    clk => clk,
    rst => rst,
    enable => system_armed,
    update => update_pid,
    output_valid => open,
    A_setpoint => pid_setpoint,
    A_measured => pid_roll,
    A_output => pid_output
);

mixer_inst: entity work.mixer
generic map (
    max_value => 350
)
port map(
    clk => clk,
    rst => rst,
    enable => system_armed,
    throttle_i => to_sfixed(125.0,pid_output),
    roll_pid_i => pid_output,
    pitch_pid_i => to_sfixed(0.0,pid_output),
    yaw_pid_i => to_sfixed(0.0,pid_output),
    motor1_signal_o => motor_signal_0,
    motor2_signal_o => motor_signal_1,
    motor3_signal_o => motor_signal_2,
    motor4_signal_o => motor_signal_3
);

motor0_inst: entity work.pulser
generic map(
    frequency_mhz => frequency_mhz
)
port map(
    clk => clk,
    input_valid => send_pulse,
    pulse_len_us => motor_signal_0+1000,
    pulser_ready => open,
    output => motor_channel_ext(2)
);

motor1_inst: entity work.pulser
generic map(
    frequency_mhz => frequency_mhz
)
port map(
    clk => clk,
    input_valid => send_pulse,
    pulse_len_us => motor_signal_1+1000,
    pulser_ready => open,
    output => motor_channel_ext(1)
);



unloader_inst: entity work.data_unloader(rtl)
generic map(
    num_bytes => 3*3+3*2-2,
    baud_rate_mhz => 115200.0/1000000
)

port map (
    clk => clk,
    rst => rst,
    o_ready => open,
    i_valid => true,
    i_data => STD_LOGIC_VECTOR(gyro_x) & STD_LOGIC_VECTOR(gyro_y) & STD_LOGIC_VECTOR(gyro_z) & "00000" &STD_LOGIC_VECTOR(motor_signal_2) & "00000" &STD_LOGIC_VECTOR(motor_signal_1) & STD_LOGIC_VECTOR(pid_output),
    o_tx => tx_ext
);

end architecture rtl;