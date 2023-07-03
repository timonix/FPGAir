library ieee;
use ieee.std_logic_1164.all;

use work.common_pkg.all;

entity mpu6050_dbus is
    generic(
        register_map : natural range 0 to dbus_range := 2**5;
        frequency_mhz : real := 27.0;
        i2c_frequency_mhz : real := 0.4;
        simulation : boolean := true
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

        o_working : out boolean;
        i_update : in boolean;
        
        dbus_in : in dbus;
        dbus_out : out dbus

    );
end mpu6050_dbus;

architecture rtl of mpu6050_dbus is
    
    constant acc_x_reg : natural := 0;
    constant acc_y_reg : natural := 2;
    constant acc_z_reg : natural := 4;
    constant temperature_reg : natural := 6;
    constant gyro_x_reg : natural := 8;
    constant gyro_y_reg : natural := 10;
    constant gyro_z_reg : natural := 12;
    constant command_reg : natural := 14;

    signal s_working : boolean;
    signal s_update  : boolean;
    
    signal s_acc_x : std_logic_vector(15 downto 0);
    signal s_acc_y : std_logic_vector(15 downto 0);
    signal s_acc_z : std_logic_vector(15 downto 0);
    
    signal s_temperature : std_logic_vector(15 downto 0);
    
    signal s_gyro_x : std_logic_vector(15 downto 0);
    signal s_gyro_y : std_logic_vector(15 downto 0);
    signal s_gyro_z : std_logic_vector(15 downto 0);
    
    signal s_command : std_logic_vector(7 downto 0);
    
begin
    
    gyro_x      <= s_gyro_x     ;
    gyro_y      <= s_gyro_y     ;
    gyro_z      <= s_gyro_z     ;
    
    acc_x       <= s_acc_x      ;
    acc_y       <= s_acc_y      ;
    acc_z       <= s_acc_z      ;
    
    temperature <= s_temperature;

    dut : entity work.mpu6050(rtl)
    port map (clk       => clk,
        rst       => rst,
        sda       => sda,
        scl       => scl,
        acc_x    => s_acc_x,
        acc_y    => s_acc_y,
        acc_z    => s_acc_z,
        temperature    => s_temperature,
        gyro_x    => s_gyro_x,
        gyro_y    => s_gyro_y,
        gyro_z    => s_gyro_z,
        o_working => s_working,
        i_update  => s_update);
    
    s_update <= true when s_command(0) = '1' or i_update else false;


    process(clk)
    begin
        if rising_edge(clk) then
            
            s_command <= (others => '0');
            dbus_out <= dbus_in;
            
            
            if dbus_in.target_address >= register_map and dbus_in.target_address <= register_map+14 then
                dbus_out.target_address <= dbus_in.responce_address;
                dbus_out.command <= WR;
                dbus_out.responce_address <= 0;
            end if;
            
            if dbus_in.target_address = register_map + acc_x_reg then
                dbus_out.data <= s_acc_x(7 downto 0);
            elsif dbus_in.target_address = register_map + acc_x_reg +1 then
                dbus_out.data <= s_acc_x(15 downto 8);
            elsif dbus_in.target_address = register_map + acc_y_reg + 0 then
                dbus_out.data <= s_acc_y(7 downto 0);
            elsif dbus_in.target_address = register_map + acc_y_reg +1 then
                dbus_out.data <= s_acc_y(15 downto 8);
            elsif dbus_in.target_address = register_map + acc_z_reg + 0 then
                dbus_out.data <= s_acc_z(7 downto 0);
            elsif dbus_in.target_address = register_map + acc_z_reg +1 then
                dbus_out.data <= s_acc_z(15 downto 8);
                
            elsif dbus_in.target_address = register_map + gyro_x_reg then
                dbus_out.data <= s_gyro_x(7 downto 0);
            elsif dbus_in.target_address = register_map + gyro_x_reg +1 then
                dbus_out.data <= s_gyro_x(15 downto 8);
            elsif dbus_in.target_address = register_map + gyro_y_reg + 0 then
                dbus_out.data <= s_gyro_y(7 downto 0);
            elsif dbus_in.target_address = register_map + gyro_y_reg +1 then
                dbus_out.data <= s_gyro_y(15 downto 8);
            elsif dbus_in.target_address = register_map + gyro_z_reg + 0 then
                dbus_out.data <= s_gyro_z(7 downto 0);
            elsif dbus_in.target_address = register_map + gyro_z_reg +1 then
                dbus_out.data <= s_gyro_z(15 downto 8);
                
            elsif dbus_in.target_address = register_map + temperature_reg then
                dbus_out.data <= s_temperature(7 downto 0);
            elsif dbus_in.target_address = register_map + temperature_reg +1 then
                dbus_out.data <= s_temperature(15 downto 8);
                
            elsif dbus_in.target_address = register_map + command_reg then
                dbus_out.data <= s_command;
                s_command <= dbus_in.data;
            end if;
            
            
            if rst = '1'then
            
        end if;
        
    end if;
end process;

end rtl;