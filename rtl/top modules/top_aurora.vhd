library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_aurora is
    generic (
        frequency_mhz : real := 27.0
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        sda : inout std_logic;
        scl : inout std_logic;
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
    
        type channel_data_array is array (1 to 6) of unsigned(10 downto 0);
    signal channel_data : channel_data_array;
    signal channel : unsigned (10 downto 0);
    
    signal read_mpu : boolean;
    signal mpu_data_valid : boolean;
    
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

end architecture rtl;