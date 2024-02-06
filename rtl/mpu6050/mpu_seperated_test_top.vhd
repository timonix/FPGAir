library ieee;
use ieee.std_logic_1164.all;

use work.common_pkg.all;

entity mpu_seperated_test_top is
    generic(
        frequency_mhz : real := 27.0;
        i2c_frequency_mhz : real := 1.1;
        baud_rate_mhz : real := 2000000.0/1000000.0
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
    constant mpu_timer_cutoff : natural := integer(100.0*frequency_mhz); -- 100 us

    signal mpu_timer : natural range 0 to mpu_timer_max+1;
    
    signal fifo_queue : natural range 0 to 16;
    signal data_ready : boolean;
    
    signal accelerometer_data_available : boolean;
    signal gyro_data_available : boolean;
    
    signal command_valid : boolean := false;
    signal update_accelerometer: boolean := false;
    signal update_gyroscope : boolean := false;
    
    signal mpu_interrupt_Q : STD_LOGIC;
    signal mpu_interrupt_QQ : STD_LOGIC;

    signal accelerometer_data_valid : boolean;
    signal gyroscope_data_valid : boolean;
    
    signal mpu_ready : boolean;
    
    signal ready : boolean;
    
    constant last_state : integer := 30000;
    signal state : integer range 0 to 30000;
    signal debug_buffer : std_logic;
    
    constant delay_Test : INTEGER := integer(92.0*frequency_mhz);
    constant late_offset : INTEGER := integer(55.0*frequency_mhz);
    
    constant gyro_serial_header : std_logic_vector(7 downto 0) := TO_STDLOGICVECTOR('G');
    constant acc_serial_header : std_logic_vector(7 downto 0) := TO_STDLOGICVECTOR('A');
    signal data_type : std_logic_vector(7 downto 0);
    signal transmit : boolean;

begin
    
    
    sync: process(clk)
    begin
        if rising_edge(clk) then
            debug <= debug_buffer;
            debug_buffer <= tx;
            
            mpu_interrupt_Q <= mpu_interrupt;
            
            state <= state +1;
            
            command_valid <= false;
            update_gyroscope <= false;
            update_accelerometer <= false;
            
            case state is
                when 0 => 
                when 1 => -- sample gyro
                    command_valid <= true;
                    update_gyroscope <= true;
                when 1*delay_Test=> -- sample accelerometer
                    command_valid <= true;
                    update_accelerometer <= true;
                when 2*delay_Test=> -- sample gyro
                    command_valid <= true;
                    update_gyroscope <= true;
                when 3*delay_Test => -- sample gyro
                    command_valid <= true;
                    update_gyroscope <= true;
                when 4*delay_Test => -- sample gyro
                    command_valid <= true;
                    update_gyroscope <= true;
                when 5*delay_Test => -- sample gyro
                    command_valid <= true;
                    update_gyroscope <= true;
                when 6.3*delay_Test => -- sample gyro
                    command_valid <= true;
                    update_gyroscope <= true;
                when 7.8*delay_Test => -- sample gyro
                    command_valid <= true;
                    update_gyroscope <= true;
                when 9.2*delay_Test => -- sample gyro
                    command_valid <= true;
                    update_gyroscope <= true;
                when last_state => state <= last_state;

                when others => 
            end case;
            
            
            if mpu_interrupt_Q = '1' then
                mpu_timer <= 0;
            end if;
            
            if mpu_interrupt_Q = '0' and (mpu_timer < mpu_timer_max) then
                mpu_timer <= mpu_timer + 1;
            end if;
            
            if mpu_timer > mpu_timer_cutoff then
                state <= 0;
                mpu_timer <= 0;
            end if;
            
            if rst = '1' then
                mpu_timer <= 0;
                state <= last_state;
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

        accelerometer_data_valid => accelerometer_data_valid,
        gyroscope_data_valid     => gyroscope_data_valid,
        reciever_ready => true,
        
        -- input stream
        mpu_ready => mpu_ready,
        command_valid => command_valid,
        i_update_accelerometer  => update_accelerometer,
        i_update_gyroscope => update_gyroscope,
        i_reset_mpu => false
        
    );
    
    process(clk)
    begin
        if rising_edge(clk) then

            if accelerometer_data_valid then
                data_type <= acc_serial_header;
            end if;
            
            if gyroscope_data_valid then
                data_type <= gyro_serial_header;
            end if;
            
            transmit <= gyroscope_data_valid or accelerometer_data_valid;
            
            if rst = '1' then
                data_type <= (others => '0');
            end if;
        end if;
    end process;

    data_unloader: entity work.data_unloader(rtl)
    generic map (
        frequency_mhz => frequency_mhz,
        baud_rate_mhz => baud_rate_mhz,
        boot_message  => "unload$",
        delimiter     => 'D',
        num_bytes     => 2*3+1
    )
    port map (
        clk     => clk,
        rst     => rst,
        o_ready => open,
        i_valid => transmit,
        i_data  => data_x&data_y&data_z&data_type,
        o_tx    => tx
    );


end rtl;