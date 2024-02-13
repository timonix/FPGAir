library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;

use work.common_pkg.ALL;

entity mpu6050_to_pid_meta_to_tx is
    generic(
        frequency_mhz : real := 27.0;
        i2c_frequency_mhz : real := 1.0;
        baud_rate_mhz : real := 230400.0/1000000.0;
        sample_rate_mhz : real := 4000.0/1000000.0
    );
        port (
        -- Define the external ports for the uart_system
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        
        sda   : inout std_logic;
        scl   : inout std_logic;
        
        tx : out STD_LOGIC;
        rx : in STD_LOGIC
        -- other ports as required
    );
end mpu6050_to_pid_meta_to_tx;

architecture rtl of mpu6050_to_pid_meta_to_tx is

    signal update_pid   : boolean;

    signal pid_valid: BOOLEAN;
    signal setpoint : sfixed(10 downto -11) := to_sfixed(50.0, 10,-11);
    signal pid_output : sfixed(10 downto -11);
    signal pid_input : sfixed(10 downto -11):= to_sfixed(0.0, 10,-11);
    
    signal gyro_x, gyro_y, gyro_z : std_logic_vector(15 downto 0);
    signal acc_x, acc_y, acc_z : std_logic_vector(15 downto 0);
    signal temperature : std_logic_vector(15 downto 0);
    
    constant period_time : natural := integer(frequency_mhz/sample_rate_mhz);
    signal period_counter : natural range 0 to period_time + 1;
    signal update_mpu : boolean;
    signal data_ready : boolean;
    signal mpu_working : boolean;

begin
    pid_input(-6 downto -11) <= (others => '0');
    pid_input(10 downto -5) <= sfixed(gyro_y(15 downto 0));
    
    update_pid <= data_ready;
    
    process(clk)
    begin
        if rising_edge(clk) then
            data_ready <= false;
            update_mpu <= false;
            
            if not (period_counter = 0) then
                period_counter <= period_counter - 1;
            end if;
            
            if period_counter = 0 and not mpu_working then
                data_ready <= true;
                period_counter <= period_time;
                update_mpu <= true;
            end if;
            
            if rst = '1' then
                period_counter <= period_time;
            end if;
        end if;
    end process;
    
    mpu6050 : entity work.mpu_using_comp(rtl)
    generic map (frequency_mhz, i2c_frequency_mhz, true, false)
    port map (clk, rst, sda, scl, gyro_x, gyro_y, gyro_z, acc_x, acc_y, acc_z, temperature, mpu_working, open ,update_mpu);
    

    pid_inst : entity work.pid_meta(rtl)
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
        
        data_valid => pid_valid,
        
        A_setpoint => (others => '0'),
        A_measured => (others => '0'),
        A_output =>open,--output_value,
        
        B_setpoint =>setpoint,
        B_measured =>pid_input,
        B_output   =>pid_output
    );
    
    DUT: entity work.data_unloader(rtl)
    generic map (
        frequency_mhz => frequency_mhz,
        baud_rate_mhz => baud_rate_mhz,
        boot_message  => "FPGAir data unload test:",
        delimiter     => 'D',
        num_bytes     => 2
    )
    port map (
        clk     => clk,
        rst     => rst,
        o_ready => open,
        i_valid => pid_valid,
        i_data  => std_logic_vector(pid_output(10 downto -5)),
        o_tx    => tx
    );



    end rtl;



