library ieee;
use ieee.std_logic_1164.all;

use work.common_pkg.all;

entity mpu_seperated_test_top is
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
end mpu_seperated_test_top;

architecture rtl of mpu_seperated_test_top is
    
    signal data_x, data_y, data_z : std_logic_vector(15 downto 0);
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
    
    signal command_valid : boolean;
    signal update_accelerometer: boolean;
    signal update_gyroscope : boolean;
    
    signal mpu_interrupt_Q : STD_LOGIC;
    signal mpu_interrupt_QQ : STD_LOGIC;
    
    signal mpu_data_valid : boolean;
    signal mpu_ready : boolean;
    
    signal ready : boolean;
    

begin
    
    
    process(clk)
    begin
        if rising_edge(clk) then
            command_valid <= false;
            update_accelerometer <= false;
            
            mpu_interrupt_Q <= mpu_interrupt;
            mpu_interrupt_QQ <= mpu_interrupt_Q;
            
            if mpu_interrupt_Q then
                if mpu_timer > mpu_timer_cutoff then
                    command_valid <= true;
                    update_accelerometer <= true;
                end if;
                mpu_timer <= 0;
            end if;
            
            if mpu_interrupt_Q = '0' and (mpu_timer < mpu_timer_max) then
                mpu_timer <= mpu_timer + 1;
            end if;
            
            if rst = '1' then
                mpu_timer <= 0;
            end if;
        end if;
    end process;
    
    mpu6050 : entity work.mpu_seperated(rtl)
    generic map (
        frequency_mhz => frequency_mhz,
        i2c_frequency_mhz => i2c_frequency_mhz,
        start_on_reset => true,
        simulation => false
    )
    port map(
        
        clk         => clk,
        rst         => rst,
        
        sda         => sda,
        scl         => scl,
        
        --output stream
        x           => data_x,
        y           => data_y,
        z           => data_z,
        
        temperature => temperature,
        
        data_valid     => mpu_data_valid,
        reciever_ready => ready,
        
        -- input stream
        mpu_ready => mpu_ready,
        command_valid => command_valid,
        i_update_accelerometer  => update_accelerometer,
        i_update_gyroscope => update_gyroscope,
        i_reset_mpu => false
        
    );

    data_unloader: entity work.data_unloader(rtl)
    generic map (
        frequency_mhz => frequency_mhz,
        baud_rate_mhz => baud_rate_mhz,
        boot_message  => "unload.",
        delimiter     => 'D',
        num_bytes     => 2*3
    )
    port map (
        clk     => clk,
        rst     => rst,
        o_ready => open,
        i_valid => accelerometer_data_available,
        i_data  => data_x&data_y&data_z,
        o_tx    => tx
    );


end rtl;