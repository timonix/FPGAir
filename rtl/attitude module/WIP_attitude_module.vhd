LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE ieee.fixed_pkg.ALL;

ENTITY attitude_module IS
   GENERIC (
      data_width : POSITIVE := 16
   );
   PORT (
      clk : IN STD_LOGIC;
      rst : IN STD_LOGIC;
      gyro_x : IN signed(data_width - 1 DOWNTO 0);
      gyro_y : IN signed(data_width - 1 DOWNTO 0);
      gyro_z : IN signed(data_width - 1 DOWNTO 0);
      accelerometer_x : IN signed(data_width - 1 DOWNTO 0);
      accelerometer_y : IN signed(data_width - 1 DOWNTO 0);
      accelerometer_z : IN signed(data_width - 1 DOWNTO 0);
      roll : OUT unsigned(data_width - 1 DOWNTO 0)
   );
END ENTITY attitude_module;
