library ieee;
use ieee.std_logic_1164.all;

use work.common_pkg.all;

entity tb_mpu6050_test_top is
    generic(
        frequency_mhz : real := 27.0;
        i2c_frequency_mhz : real := 0.05;
        baud_rate_mhz : real := 115200.0/1000000.0
    );

end tb_mpu6050_test_top;

architecture sim of tb_mpu6050_test_top is
    
    signal clk, rst : std_logic := '0';
    
    signal sda,scl :std_logic;
    signal rx,tx : std_logic;
    
    signal TbSimEnded : boolean := false;
    
    constant clk_period : time := 37 ns;

    signal dbus0, dbus1, dbus2, dbus3, dbus4 : dbus;
    signal dbus5, dbus6, dbus7, dbus8, dbus9 : dbus;
    signal dbus10, dbus11, dbus12, dbus13, dbus14 : dbus;
    
    signal gyro_x, gyro_y, gyro_z : std_logic_vector(15 downto 0);
    signal acc_x, acc_y, acc_z : std_logic_vector(15 downto 0);
    signal temperature : std_logic_vector(15 downto 0);
    
    signal mpu_working : boolean;
    signal update_mpu : boolean;

begin
    
    clk <= not clk after clk_period / 2 when not TbSimEnded else '0';
    

    mpu6050 : entity work.mpu6050(rtl) generic map (frequency_mhz, i2c_frequency_mhz,true, false) port map (clk, rst, sda, scl, gyro_x, gyro_y, gyro_z, acc_x, acc_y, acc_z, temperature, mpu_working, update_mpu);
    
    cleaner : entity work.bus_cleaner_dbus(rtl) port map (clk, rst, dbus14, dbus0);
    gx0 : entity work.debug_module_dbus generic map (15,false) port map (clk, rst, gyro_x(7 downto 0),open,dbus0,dbus1);
    gx1 : entity work.debug_module_dbus generic map (16,false) port map (clk, rst, gyro_x(15 downto 8),open,dbus1,dbus2);
    gy0 : entity work.debug_module_dbus generic map (17,false) port map (clk, rst, gyro_y(7 downto 0),open,dbus2,dbus3);
    gy1 : entity work.debug_module_dbus generic map (18,false) port map (clk, rst, gyro_y(15 downto 8),open,dbus3,dbus4);
    gz0 : entity work.debug_module_dbus generic map (19,false) port map (clk, rst, gyro_z(7 downto 0),open,dbus4,dbus5);
    gz1 : entity work.debug_module_dbus generic map (20,false) port map (clk, rst, gyro_z(15 downto 8),open,dbus5,dbus6);

    ax0 : entity work.debug_module_dbus generic map (21,false) port map (clk, rst, acc_x(7 downto 0),open,dbus6,dbus7);
    ax1 : entity work.debug_module_dbus generic map (22,false) port map (clk, rst, acc_x(15 downto 8),open,dbus7,dbus8);
    ay0 : entity work.debug_module_dbus generic map (23,false) port map (clk, rst, acc_y(7 downto 0),open,dbus8,dbus9);
    ay1 : entity work.debug_module_dbus generic map (24,false) port map (clk, rst, acc_y(15 downto 8),open,dbus9,dbus10);
    az0 : entity work.debug_module_dbus generic map (25,false) port map (clk, rst, acc_z(7 downto 0),open,dbus10,dbus11);
    az1 : entity work.debug_module_dbus generic map (26,false) port map (clk, rst, acc_z(15 downto 8),open,dbus11,dbus12);
    
    uart_tx : entity work.uart_tx_dbus(rtl) generic map (1, frequency_mhz, baud_rate_mhz,"FPGAir" & LF,8) port map (clk, rst, dbus12, dbus13, tx);
    uart_rx : entity work.uart_rx_dbus(rtl) generic map (1, frequency_mhz, baud_rate_mhz) port map (clk, rst, dbus13, dbus14, rx);
    
    
    stim_proc: process

    
    begin
        
        -- reset
        rst <= '1';
        wait for clk_period*10;
        rst <= '0';
        

        wait for 8.68055556*10 us;
        
        wait until not mpu_working;
        
        
        wait for clk_period*10;
        
        TbSimEnded <= true;

        wait;
    end process;
    
end sim;