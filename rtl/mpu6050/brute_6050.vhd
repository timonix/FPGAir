library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity brute_6050 is
    generic(
        frequency_mhz : real := 27.0;
        i2c_frequency_mhz : real := 0.4;
        reset_on_reset : boolean := false;
        start_on_reset : boolean := true;
        simulation : boolean := false
    );
    port(
        
        clk         : in std_logic;
        rst         : in STD_LOGIC;
        
        sda         : inout STD_LOGIC;
        scl         : inout STD_LOGIC;
        
        gyro_x      : out std_logic_vector(15 downto 0);
        gyro_y      : out std_logic_vector(15 downto 0);
        gyro_z      : out std_logic_vector(15 downto 0);
        
        acc_x      : out std_logic_vector(15 downto 0);
        acc_y      : out std_logic_vector(15 downto 0);
        acc_z      : out std_logic_vector(15 downto 0);
        
        temperature : out std_logic_vector(15 downto 0);
        
        mpu_data_valid : out boolean;
        
        reset_mpu : in boolean := false;
        mpu_ready  : out boolean;
        update_mpu : in boolean
    );
end entity brute_6050;

architecture rtl of brute_6050 is
    
    procedure OPEN_DRAIN_SET(constant value : in STD_LOGIC;
        signal   sig : out STD_LOGIC) is
    begin
        if value = '1' then
            sig <= 'Z';
        else
            sig <= '0';
        end if;
        
        if simulation then
            sig <= value;
        end if;
    end procedure OPEN_DRAIN_SET;
    
    constant mpu_addr_W : std_logic_vector (7 downto 0) := "11010000";
    constant mpu_addr_R : std_logic_vector (7 downto 0) := "11010001";
    constant pwr_mgt_0 : std_logic_vector (7 downto 0) := x"6b";
    constant data_addr : std_logic_vector (7 downto 0) := x"3b";
    
    constant clock_divisor : positive := positive(frequency_mhz / (4.0 * i2c_frequency_mhz));
    signal clock_divider_counter : natural range 0 to clock_divisor + 1 := 0;
    signal i2c_clock : STD_LOGIC := '0';
    
    constant last_stage : natural := 1023;
    signal s_stage : natural range 0 to last_stage;
    
    constant C_ENABLE_POWER_0 : natural := 120;
    constant C_ENABLE_POWER_1 : natural := 140;
    constant C_ENABLE_POWER_2 : natural := 180;
    constant C_ENABLE_POWER_3 : natural := 220;
    constant C_ENABLE_POWER_4 : natural := 260;
    
    constant C_SET_ADDRESS_0 : natural := 280;
    constant C_SET_ADDRESS_1 : natural := 300;
    constant C_SET_ADDRESS_2 : natural := 340;
    constant C_SET_ADDRESS_3 : natural := 380;
    
    CONSTANT C_READ_SENSORS_START : natural := 400;
    CONSTANT C_READ_SENSORS_DEVICE_ADDR : natural := 420;
    CONSTANT C_READ_SENSORS_acc_x_H : natural := 460;
    CONSTANT C_READ_SENSORS_acc_x_L : natural := 500;
    CONSTANT C_READ_SENSORS_acc_y_H : natural := 540;
    CONSTANT C_READ_SENSORS_acc_y_L : natural := 580;
    CONSTANT C_READ_SENSORS_acc_z_H : natural := 620;
    CONSTANT C_READ_SENSORS_acc_z_L : natural := 660;
    
    CONSTANT C_READ_SENSORS_temp_H : natural := 700;
    CONSTANT C_READ_SENSORS_temp_L : natural := 740;
    
    CONSTANT C_READ_SENSORS_gyro_x_H : natural := 780;
    CONSTANT C_READ_SENSORS_gyro_x_L : natural := 820;
    CONSTANT C_READ_SENSORS_gyro_y_H : natural := 860;
    CONSTANT C_READ_SENSORS_gyro_y_L : natural := 900;
    CONSTANT C_READ_SENSORS_gyro_z_H : natural := 940;
    CONSTANT C_READ_SENSORS_gyro_z_L : natural := 980;
    
    CONSTANT C_READ_SENSORS_STOP : natural := 1020;
    
    signal s_gyro_x      :  std_logic_vector(15 downto 0);
    signal s_gyro_y      :  std_logic_vector(15 downto 0);
    signal s_gyro_z      :  std_logic_vector(15 downto 0);
    
    signal s_acc_x       :  std_logic_vector(15 downto 0);
    signal s_acc_y       :  std_logic_vector(15 downto 0);
    signal s_acc_z       :  std_logic_vector(15 downto 0);
    
    signal s_temperature :  std_logic_vector(15 downto 0);
    
begin
    
    gyro_x <= s_gyro_x;
    gyro_y <= s_gyro_y;
    gyro_z <= s_gyro_z;
    
    acc_x <= s_acc_x;
    acc_y <= s_acc_y;
    acc_z <= s_acc_z;
    
    temperature <= s_temperature;

    i2c_clock_proc: process(clk)
    begin
        if rising_edge(clk) then
            i2c_clock <= '0';

            if clock_divider_counter = 0 then
                i2c_clock <= '1';
                clock_divider_counter <= clock_divisor;
            else
                clock_divider_counter <= clock_divider_counter - 1;
            end if;
        end if;
    end process;


    process(clk)
    procedure send_data(start_state : natural;
        data : std_logic_vector) is
    begin

        for i in data'RANGE loop
            if s_stage = start_state + 0 + i*4 and data'ASCENDING then OPEN_DRAIN_SET(data(data'LEFT+i), sda); end if;
            if s_stage = start_state + 0 + i*4 and not data'ASCENDING then OPEN_DRAIN_SET(data(data'LEFT-i), sda); end if;
            if s_stage = start_state + 1 + i*4 then OPEN_DRAIN_SET('1', scl); end if;
            if s_stage = start_state + 3 + i*4 then OPEN_DRAIN_SET('0', scl); end if;
        end loop;
    end procedure;

    procedure shift_in_responce(start_state : natural;
        signal target : inout std_logic_vector) is
    begin

        for i in 0 to 7 loop
            if s_stage = start_state + 2 + i*4 then target(0) <= sda; target(15 downto 1) <= target(14 downto 0); end if;
        end loop;
    end procedure;

    procedure send_start(start_state : natural) is
    begin

        if s_stage = start_state + 1 then OPEN_DRAIN_SET('0', sda); end if;
        if s_stage = start_state + 2 then OPEN_DRAIN_SET('0', scl); end if;

    end procedure;

    procedure send_stop(start_state : natural) is
    begin
        if s_stage = start_state + 1 then OPEN_DRAIN_SET('0', sda); end if;
        if s_stage = start_state + 2 then OPEN_DRAIN_SET('0', scl); end if;
        if s_stage = start_state + 3 then OPEN_DRAIN_SET('1', scl); end if;
        if s_stage = start_state + 4 then OPEN_DRAIN_SET('1', sda); end if;
    end procedure;
    begin
        if rising_edge(clk) then
            mpu_ready <= false;
            if update_mpu and mpu_ready then
                s_stage <= C_SET_ADDRESS_0;
            end if;
            
            if reset_mpu then
                s_stage <= 0;
            end if;
            
            if i2c_clock = '1'then
            
            if s_stage = 1023 then
                mpu_ready <= true;
                s_stage <= 1023;
            else
                s_stage <= s_stage + 1;
            end if;
            
            mpu_data_valid <= false;
            if s_stage = C_READ_SENSORS_STOP then
                mpu_data_valid <= true;
            end if;
            
            send_start(C_ENABLE_POWER_0);
            send_data(C_ENABLE_POWER_1,mpu_addr_W & '1');
            send_data(C_ENABLE_POWER_2,pwr_mgt_0 & '1');
            send_data(C_ENABLE_POWER_3,"00000000" & '1');
            send_stop(C_ENABLE_POWER_4);
            
            send_start(C_SET_ADDRESS_0);
            send_data(C_SET_ADDRESS_1,mpu_addr_W & '1');
            send_data(C_SET_ADDRESS_2,data_addr & '1');
            send_stop(C_SET_ADDRESS_3);
            
            send_start(C_READ_SENSORS_START);
            send_data(C_READ_SENSORS_DEVICE_ADDR,mpu_addr_R & '0');
            
            send_data(C_READ_SENSORS_acc_x_H,"11111111" & '0'); shift_in_responce(C_READ_SENSORS_acc_x_H,s_acc_x);
            send_data(C_READ_SENSORS_acc_x_L,"11111111" & '0'); shift_in_responce(C_READ_SENSORS_acc_x_L,s_acc_x);
            send_data(C_READ_SENSORS_acc_y_H,"11111111" & '0'); shift_in_responce(C_READ_SENSORS_acc_y_H,s_acc_y);
            send_data(C_READ_SENSORS_acc_y_L,"11111111" & '0'); shift_in_responce(C_READ_SENSORS_acc_y_L,s_acc_y);
            send_data(C_READ_SENSORS_acc_z_H,"11111111" & '0'); shift_in_responce(C_READ_SENSORS_acc_z_H,s_acc_z);
            send_data(C_READ_SENSORS_acc_z_L,"11111111" & '0'); shift_in_responce(C_READ_SENSORS_acc_z_L,s_acc_z);
            
            send_data(C_READ_SENSORS_temp_H,"11111111" & '0'); shift_in_responce(C_READ_SENSORS_temp_H,s_temperature);
            send_data(C_READ_SENSORS_temp_L,"11111111" & '0'); shift_in_responce(C_READ_SENSORS_temp_L,s_temperature);
            
            send_data(C_READ_SENSORS_gyro_x_H,"11111111" & '0'); shift_in_responce(C_READ_SENSORS_gyro_x_H,s_gyro_x);
            send_data(C_READ_SENSORS_gyro_x_L,"11111111" & '0'); shift_in_responce(C_READ_SENSORS_gyro_x_L,s_gyro_x);
            send_data(C_READ_SENSORS_gyro_y_H,"11111111" & '0'); shift_in_responce(C_READ_SENSORS_gyro_y_H,s_gyro_y);
            send_data(C_READ_SENSORS_gyro_y_L,"11111111" & '0'); shift_in_responce(C_READ_SENSORS_gyro_y_L,s_gyro_y);
            send_data(C_READ_SENSORS_gyro_z_H,"11111111" & '0'); shift_in_responce(C_READ_SENSORS_gyro_z_H,s_gyro_z);
            send_data(C_READ_SENSORS_gyro_z_L,"11111111" & '1'); shift_in_responce(C_READ_SENSORS_gyro_z_L,s_gyro_z);
            send_stop(C_READ_SENSORS_STOP);
            
        end if;
        
        if rst = '1' then
            s_stage <= last_stage;
            if start_on_reset then
                s_stage <= C_SET_ADDRESS_0;
            end if;
            
            if reset_on_reset then
                s_stage <= 0;
            end if;
            
            OPEN_DRAIN_SET('1', sda);
            OPEN_DRAIN_SET('1', scl);
        end if;
        
    end if;
end process;


end architecture rtl;