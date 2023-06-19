library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;

use work.common_pkg.all;

entity mpu6050 is
    generic(
        frequency_mhz : real := 27.0;
        i2c_frequency_mhz : real := 0.4;
        accelerometer_range : ufixed(13 downto 0) := to_ufixed(16384,13,0);
        gyroscope_range : ufixed(7 downto -6) := to_ufixed(131,7,-6);
        simulation : boolean := false
    );
    port(
        
        clk         : in std_logic;
        rst         : in STD_LOGIC;
        
        sda         : inout STD_LOGIC;
        scl         : inout STD_LOGIC;
        
        
        
        
        o_working : out boolean;
        i_update : in boolean;
        
        
        
        i_ack  : in  std_logic;
        i_data : in  std_logic_vector(7 downto 0);
        
        o_ack  : out std_logic;
        o_data : out std_logic_vector(7 downto 0)
    );
end entity mpu6050;

architecture rtl of mpu6050 is