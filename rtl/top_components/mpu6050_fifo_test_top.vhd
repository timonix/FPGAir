library ieee;
use ieee.std_logic_1164.all;

use work.common_pkg.all;

entity mpu6050_fifo_test_top is
    generic(
        frequency_mhz : real := 27.0;
        i2c_frequency_mhz : real := 1.1;
        baud_rate_mhz : real := 1000000.0/1000000.0
    );
    port(
        clk         : in std_logic;
        rst         : in STD_LOGIC;
        
        sda   : inout std_logic;
        scl   : inout std_logic;
        
        tx         : out std_logic;
        mpu_interrupt : in std_logic;
        debug : out std_logic
    );
end mpu6050_fifo_test_top;

architecture rtl of mpu6050_fifo_test_top is
    
    signal gyro_x, gyro_y, gyro_z : std_logic_vector(15 downto 0);
    signal acc_x, acc_y, acc_z : std_logic_vector(15 downto 0);
    signal temperature : std_logic_vector(15 downto 0);
    
    signal mpu_working : boolean;
    signal update_mpu : boolean;
    
    constant mpu_timer_max: natural := integer(150.0*frequency_mhz);
    constant mpu_timer_cutoff : natural := integer(100.0*frequency_mhz);
    signal mpu_timer : natural range 0 to mpu_timer_max+1;
    
    signal fifo_queue : natural range 0 to 16;
    signal data_ready : boolean;
    
    signal accelerometer_data_available : boolean;
    signal gyro_data_available : boolean;
    signal mpu_interrupt_Q : STD_LOGIC;
    signal mpu_interrupt_QQ : STD_LOGIC;

begin
    
    --debug <= '1' when fifo_queue > 1  else '0';
    --debug <= mpu_timer < mpu_timer_max);
    
    process(clk)
    begin
        if rising_edge(clk) then
            mpu_interrupt_Q <= mpu_interrupt;
            mpu_interrupt_QQ <= mpu_interrupt_Q;
            
            if gyro_data_available and fifo_queue > 0 then
                fifo_queue <= fifo_queue - 1;
                gyro_data_available <= false;
            end if;
            --rising edge for interrupt
            if mpu_interrupt_Q = '1' and mpu_interrupt_QQ = '0' then
                debug <= '1';
                if fifo_queue < 8 then
                    fifo_queue <= fifo_queue + 1;
                end if;
            end if;
            
            if fifo_queue > 0 then
                gyro_data_available <= true;
            end if;
            
            if mpu_interrupt_Q then
                if mpu_timer > mpu_timer_cutoff then
                    accelerometer_data_available <= true;
                    fifo_queue <= fifo_queue + 2;
                    gyro_data_available <= false;
                end if;
                mpu_timer <= 0;
            end if;
            
            if mpu_interrupt_Q = '0' and (mpu_timer < 10) then
                debug <= '0';
            end if;
            
            if mpu_interrupt_Q = '0' and (mpu_timer < mpu_timer_max) then
                mpu_timer <= mpu_timer + 1;
            end if;
            
            if gyro_data_available then
                gyro_data_available <= false;
            end if;
            
            if mpu_working then
                gyro_data_available <= false;
                accelerometer_data_available <= false;
            end if;
            
            if rst = '1' then
                fifo_queue <= 0;
                gyro_data_available <= false;
                accelerometer_data_available <= false;
            end if;
        end if;
    end process;
    
    

    mpu6050 : entity work.mpu_using_fifo(rtl)
    generic map (frequency_mhz, i2c_frequency_mhz, true, false)
    port map (clk, rst, sda, scl, gyro_x, gyro_y, gyro_z, acc_x, acc_y, acc_z, temperature, mpu_working, open ,accelerometer_data_available,gyro_data_available);
    
    data_unloader: entity work.data_unloader(rtl)
    generic map (
        frequency_mhz => frequency_mhz,
        baud_rate_mhz => baud_rate_mhz,
        boot_message  => "unload.",
        delimiter     => 'D',
        num_bytes     => 2*6
    )
    port map (
        clk     => clk,
        rst     => rst,
        o_ready => open,
        i_valid => accelerometer_data_available,
        i_data  => acc_x&acc_y&acc_z&gyro_x&gyro_y&gyro_z,
        o_tx    => tx
    );

    
end rtl;