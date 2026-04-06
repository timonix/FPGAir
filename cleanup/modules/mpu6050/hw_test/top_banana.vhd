library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.fixed_pkg.all;

entity top_banana is
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
end entity top_banana;

architecture rtl of top_banana is

    signal rst : std_logic;

    signal acc_x : STD_LOGIC_VECTOR(15 downto 0);
    signal acc_y : STD_LOGIC_VECTOR(15 downto 0);
    signal acc_z : STD_LOGIC_VECTOR(15 downto 0);
    
    signal gyro_x : STD_LOGIC_VECTOR(15 downto 0);
    signal gyro_y : STD_LOGIC_VECTOR(15 downto 0);
    signal gyro_z : STD_LOGIC_VECTOR(15 downto 0);

    signal mpu_data_valid : boolean;
    
    signal read_mpu : boolean;
    
    signal mpu_failure : boolean;
    
    
begin

    rst <= not a_rst;
    mpu_enable <= not rst;
    
    led(0) <= '0';
    led(1) <= '0';
    
    motor_channel_ext <= (others => '0');
    
    sequencer_inst : entity work.sequencer
    generic map (
        frequency_mhz => frequency_mhz
    )
    port map (
        clk => clk,
        rst => rst,
        enable => true,
        update_pid => open,
        update_mpu => read_mpu,
        send_pulse => open,
        calculate_attitude => open
    );

    mpu6050_inst : entity work.brute_6050
    generic map (
        frequency_mhz => frequency_mhz,
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



    unloader_inst: entity work.data_unloader
    generic map(
        num_bytes => 2*3,
        baud_rate_mhz => 115200.0/1000000
    )

    port map (
        clk => clk,
        rst => rst,
        o_ready => open,
        i_valid => true,
        i_data => STD_LOGIC_VECTOR(gyro_x) & STD_LOGIC_VECTOR(gyro_y)& STD_LOGIC_VECTOR(gyro_z),
        o_tx => tx_ext
    );

end architecture rtl;