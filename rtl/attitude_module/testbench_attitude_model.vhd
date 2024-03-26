library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.fixed_pkg.all;

entity testbench_attitude_module is
    generic (
        gyro_scale : sfixed := to_sfixed(0.00763358778,0,-15);
        data_width : positive := 16
    );
    port (
        clk              : in  std_logic;
        rst              : in  std_logic;
        gyro_x           : in  signed(data_width-1 downto 0);
        gyro_y           : in  signed(data_width-1 downto 0);
        gyro_z           : in  signed(data_width-1 downto 0);
        accelerometer_x  : in  signed(data_width-1 downto 0);
        accelerometer_y  : in  signed(data_width-1 downto 0);
        accelerometer_z  : in  signed(data_width-1 downto 0);
        roll             : out unsigned(data_width-1 downto 0)
    );
end entity testbench_attitude_module;