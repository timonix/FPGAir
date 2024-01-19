library ieee;
use ieee.std_logic_1164.all;

use work.common_pkg.all;

entity mpu6050_redout_top is
    generic(
        frequency_mhz : real := 27.0;
        i2c_frequency_mhz : real := 0.6;
        baud_rate_mhz : real := 500000.0/1000000.0;
        sample_rate_mhz : real := 2.0/1000000.0
    );
    port(
        clk         : in std_logic;
        rst         : in STD_LOGIC;
        
        sda   : inout std_logic;
        scl   : inout std_logic;
        
        tx         : out std_logic
    );
end mpu6050_redout_top;

architecture rtl of mpu6050_redout_top is
    
    signal gyro_x, gyro_y, gyro_z : std_logic_vector(15 downto 0);
    signal acc_x, acc_y, acc_z : std_logic_vector(15 downto 0);
    signal temperature : std_logic_vector(15 downto 0);
    
    signal mpu_working : boolean;
    signal update_mpu : boolean;
    
    constant period_time : natural := integer(frequency_mhz/baud_rate_mhz);
    signal period_counter : natural range 0 to period_time + 1;
    
    signal data_ready : boolean;

begin
    
    
    
    process(clk)
    begin
        if rising_edge(clk) then
            data_ready <= false;
            
            if not (period_counter = 0) then
                period_counter <= period_counter - 1;
            end if;
            
            if period_counter = 0 and not mpu_working then
                data_ready <= true;
                period_counter <= period_time;
            end if;
            
            if rst = '1' then
                period_counter <= period_time;
            end if;
        end if;
    end process;
    

    mpu6050 : entity work.mpu6050(rtl)
    generic map (frequency_mhz, i2c_frequency_mhz, true, false)
    port map (clk, rst, sda, scl, gyro_x, gyro_y, gyro_z, acc_x, acc_y, acc_z, temperature, mpu_working, open ,update_mpu);
    
    data_unloader: entity work.data_unloader(rtl)
    generic map (
        frequency_mhz => frequency_mhz,
        baud_rate_mhz => baud_rate_mhz,
        boot_message  => "unload.",
        delimiter     => 'D',
        num_bytes     => 2
    )
    port map (
        clk     => clk,
        rst     => rst,
        o_ready => open,
        i_valid => data_ready,
        i_data  => gyro_x,
        o_tx    => tx
    );

    
end rtl;