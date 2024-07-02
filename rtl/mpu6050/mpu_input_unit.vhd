library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.fixed_pkg.all;

use work.common_pkg.all;

entity mpu_input_unit is
    generic(
        data_out_integer_bits : INTEGER := 16;
        data_out_fractional_bits : INTEGER := -16;
        
        scale_integer_bits : INTEGER := 16;
        scale_fractional_bits : INTEGER := -16;
        
        bias_integer_bits : INTEGER := 16;
        bias_fractional_bits : INTEGER := -16;
        
        frequency_mhz : real := 27.0;
        i2c_frequency_mhz : real := 0.4;
        start_on_reset : boolean := true;
        simulation : boolean := true
    );
    port(
        clk             : in std_logic;
        rst             : in STD_LOGIC;
        
        sda             : inout STD_LOGIC;
        scl             : inout STD_LOGIC;
        
        acc_x_bias          : in sfixed(bias_integer_bits-1 downto bias_fractional_bits) := to_sfixed(0.0,bias_integer_bits-1,bias_fractional_bits);
        acc_y_bias          : in sfixed(bias_integer_bits-1 downto bias_fractional_bits) := to_sfixed(0.0,bias_integer_bits-1,bias_fractional_bits);
        acc_z_bias          : in sfixed(bias_integer_bits-1 downto bias_fractional_bits) := to_sfixed(0.0,bias_integer_bits-1,bias_fractional_bits);
        acc_x_scale         : in sfixed(scale_integer_bits-1 downto scale_fractional_bits):= to_sfixed(0.0,bias_integer_bits-1,bias_fractional_bits);
        acc_y_scale         : in sfixed(scale_integer_bits-1 downto scale_fractional_bits):= to_sfixed(0.0,bias_integer_bits-1,bias_fractional_bits);
        acc_z_scale         : in sfixed(scale_integer_bits-1 downto scale_fractional_bits):= to_sfixed(0.0,bias_integer_bits-1,bias_fractional_bits);
        
        gyro_x_bias          : in sfixed(bias_integer_bits-1 downto bias_fractional_bits):= to_sfixed(1.0,scale_integer_bits-1,scale_fractional_bits);
        gyro_y_bias          : in sfixed(bias_integer_bits-1 downto bias_fractional_bits):= to_sfixed(1.0,scale_integer_bits-1,scale_fractional_bits);
        gyro_z_bias          : in sfixed(bias_integer_bits-1 downto bias_fractional_bits):= to_sfixed(1.0,scale_integer_bits-1,scale_fractional_bits);
        gyro_x_scale         : in sfixed(scale_integer_bits-1 downto scale_fractional_bits):= to_sfixed(1.0,scale_integer_bits-1,scale_fractional_bits);
        gyro_y_scale         : in sfixed(scale_integer_bits-1 downto scale_fractional_bits):= to_sfixed(1.0,scale_integer_bits-1,scale_fractional_bits);
        gyro_z_scale         : in sfixed(scale_integer_bits-1 downto scale_fractional_bits):= to_sfixed(1.0,scale_integer_bits-1,scale_fractional_bits);
        
        data_out_valid  : out BOOLEAN;
        acc_x_out           : out sfixed(data_out_integer_bits-1 downto data_out_fractional_bits);
        acc_y_out           : out sfixed(data_out_integer_bits-1 downto data_out_fractional_bits);
        acc_z_out           : out sfixed(data_out_integer_bits-1 downto data_out_fractional_bits);
        
        gyro_x_out          : out sfixed(data_out_integer_bits-1 downto data_out_fractional_bits);
        gyro_y_out          : out sfixed(data_out_integer_bits-1 downto data_out_fractional_bits);
        gyro_z_out          : out sfixed(data_out_integer_bits-1 downto data_out_fractional_bits);
        
        o_working       : out boolean;
        i_reset_mpu     : in boolean := false;
        i_update        : in boolean
    );
end entity mpu_input_unit;

architecture rtl of mpu_input_unit is
    signal gyro_x      : std_logic_vector(15 downto 0);
    signal gyro_y      : std_logic_vector(15 downto 0);
    signal gyro_z      : std_logic_vector(15 downto 0);
    
    signal acc_x       : std_logic_vector(15 downto 0);
    signal acc_y       : std_logic_vector(15 downto 0);
    signal acc_z       : std_logic_vector(15 downto 0);
    
    signal temperature : std_logic_vector(15 downto 0);
    
    signal data_valid  : boolean;
    
begin

    mpu_inst : entity work.mpu(rtl)
    generic map(
        frequency_mhz => frequency_mhz,
        i2c_frequency_mhz => i2c_frequency_mhz,
        start_on_reset => start_on_reset,
        simulation => simulation
    )
    port map(
        clk         => clk,
        rst         => rst,
        sda         => sda,
        scl         => scl,
        gyro_x      => gyro_x,
        gyro_y      => gyro_y,
        gyro_z      => gyro_z,
        acc_x       => acc_x,
        acc_y       => acc_y,
        acc_z       => acc_z,
        temperature => temperature,
        data_valid  => data_valid,
        o_working   => o_working,
        i_reset_mpu => i_reset_mpu,
        i_update    => i_update
    );
    
    acc_scale_bias_correction_inst : entity work.scale_bias_correction(rtl)
    generic map(
        data_in_integer_bits => 16,
        data_in_fractional_bits => 0,
        data_out_integer_bits => data_out_integer_bits,
        data_out_fractional_bits => data_out_fractional_bits,
        scale_integer_bits => scale_integer_bits,
        scale_fractional_bits => scale_fractional_bits,
        bias_integer_bits => bias_integer_bits,
        bias_fractional_bits => bias_fractional_bits
    )
    port map(
        clk             => clk,
        rst             => rst,
        data_in_valid   => data_valid,
        x_in            => to_sfixed(acc_x, 16-1, 0),
        y_in            => to_sfixed(acc_y, 16-1, 0),
        z_in            => to_sfixed(acc_z, 16-1, 0),
        x_bias          => acc_x_bias,
        y_bias          => acc_y_bias,
        z_bias          => acc_z_bias,
        x_scale         => acc_x_scale,
        y_scale         => acc_y_scale,
        z_scale         => acc_z_scale,
        data_out_valid  => data_out_valid,
        x_out           => acc_x_out,
        y_out           => acc_y_out,
        z_out           => acc_z_out);

end architecture rtl;