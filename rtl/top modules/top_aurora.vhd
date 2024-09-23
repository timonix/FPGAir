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
        led_out : out std_logic
    );
end entity top_aurora;

architecture rtl of top_aurora is

    signal rst : std_logic;

    signal acc_x : STD_LOGIC_VECTOR(15 downto 0);
    signal acc_y : STD_LOGIC_VECTOR(15 downto 0);
    signal acc_z : STD_LOGIC_VECTOR(15 downto 0);
    
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
    
    
    
begin

    rst <= not a_rst;
    
    led_out <= '0' when system_armed else '1';
    
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
        simulation => simulation
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
        channel_pwm => radio_channel_ext(i),
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
pidassignment: for i in 11 downto -3 generate
    pid_roll(i) <= roll(i+4);
end generate;

pid_roll(-4 downto -12) <= (others => '0');

neo_pid_inst: entity work.neo_pid
generic map(
    integer_bits => 12,
    fractional_bits => 12,
    Kp => 0.01,
    Ki => 0.001,
    Kd => 0.001
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
    max_value => 300
)
port map(
    clk => clk,
    rst => rst,
    enable => system_armed,
    throttle_i => to_sfixed(150.0,pid_output),
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
    num_bytes => 2*4,
    baud_rate_mhz => 115200.0/1000000
)

port map (
    clk => clk,
    rst => rst,
    o_ready => open,
    i_valid => true,
    i_data => "00000"&std_logic_vector(motor_signal_3)&"00000"&std_logic_vector(motor_signal_2)&"00000"&std_logic_vector(motor_signal_1)&"00000"&std_logic_vector(motor_signal_0),
    o_tx => tx_ext
);

end architecture rtl;