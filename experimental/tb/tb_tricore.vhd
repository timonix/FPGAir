library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use IEEE.fixed_pkg.all;

entity tb_tricore is
end tb_tricore;

architecture tb of tb_tricore is
    constant integer_bits : integer := 12;
    constant fractional_bits : integer := 12;
    
    component tricore
    port (clk                 : in std_logic;
        rst                 : in std_logic;
        gravity_X           : in sfixed (integer_bits-1 downto -fractional_bits);
        gravity_Y           : in sfixed (integer_bits-1 downto -fractional_bits);
        gravity_Z           : in sfixed (integer_bits-1 downto -fractional_bits);
        acc_X               : in sfixed (integer_bits-1 downto -fractional_bits);
        acc_Y               : in sfixed (integer_bits-1 downto -fractional_bits);
        acc_Z               : in sfixed (integer_bits-1 downto -fractional_bits);
        gyro_X              : in sfixed (integer_bits-1 downto -fractional_bits);
        gyro_Y              : in sfixed (integer_bits-1 downto -fractional_bits);
        gyro_Z              : in sfixed (integer_bits-1 downto -fractional_bits);
        output_X            : out sfixed (integer_bits-1 downto -fractional_bits);
        output_Y            : out sfixed (integer_bits-1 downto -fractional_bits);
        output_Z            : out sfixed (integer_bits-1 downto -fractional_bits);
        instruction_pointer : in integer range 0 to 31);
end component;

signal clk                 : std_logic;
signal rst                 : std_logic;
signal gravity_X           : sfixed (integer_bits-1 downto -fractional_bits);
signal gravity_Y           : sfixed (integer_bits-1 downto -fractional_bits);
signal gravity_Z           : sfixed (integer_bits-1 downto -fractional_bits);
signal acc_X               : sfixed (integer_bits-1 downto -fractional_bits);
signal acc_Y               : sfixed (integer_bits-1 downto -fractional_bits);
signal acc_Z               : sfixed (integer_bits-1 downto -fractional_bits);
signal gyro_X              : sfixed (integer_bits-1 downto -fractional_bits);
signal gyro_Y              : sfixed (integer_bits-1 downto -fractional_bits);
signal gyro_Z              : sfixed (integer_bits-1 downto -fractional_bits);
signal output_X            : sfixed (integer_bits-1 downto -fractional_bits);
signal output_Y            : sfixed (integer_bits-1 downto -fractional_bits);
signal output_Z            : sfixed (integer_bits-1 downto -fractional_bits);
signal instruction_pointer : integer range 0 to 31;

constant TbPeriod : time := 1000 ns; -- EDIT Put right period here
signal TbClock : std_logic := '0';
signal TbSimEnded : std_logic := '0';

signal target_value_x : sfixed (integer_bits-1 downto -fractional_bits);
signal target_value_y : sfixed (integer_bits-1 downto -fractional_bits);
signal target_value_z : sfixed (integer_bits-1 downto -fractional_bits);

begin

    dut : tricore
    port map (clk                 => clk,
        rst                 => rst,
        gravity_X           => gravity_X,
        gravity_Y           => gravity_Y,
        gravity_Z           => gravity_Z,
        acc_X               => acc_X,
        acc_Y               => acc_Y,
        acc_Z               => acc_Z,
        gyro_X              => gyro_X,
        gyro_Y              => gyro_Y,
        gyro_Z              => gyro_Z,
        output_X            => output_X,
        output_Y            => output_Y,
        output_Z            => output_Z,
        instruction_pointer => instruction_pointer);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    
    begin
        -- EDIT Adapt initialization as needed
        gravity_X <= (others => '0');
        gravity_Y <= (others => '0');
        gravity_Z <= (others => '0');
        acc_X <= (others => '0');
        acc_Y <= (others => '0');
        acc_Z <= (others => '0');
        gyro_X <= (others => '0');
        gyro_Y <= (others => '0');
        gyro_Z <= (others => '0');
        instruction_pointer <= 0;

        -- Reset generation
        -- EDIT: Check that rst is really your reset signal
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 100 ns;
        
        -- out_x = vec_x - vec_y*gyro_z + vec_z*gyro_y
        -- out_y = vec_y - vec_z*gyro_x + vec_x*gyro_z
        -- out_z = vec_z - vec_x*gyro_y + vec_y*gyro_x
        gravity_X <= to_sfixed(0.5,acc_X);
        gravity_Y <= to_sfixed(0.25,acc_X);
        gravity_Z <= to_sfixed(0.125,acc_X);
        
        gyro_X <= to_sfixed(0.05,acc_X);
        gyro_Y <= to_sfixed(0.012,acc_X);
        gyro_Z <= to_sfixed(0.067,acc_X);
        
        

        wait until TbClock = '1';
        for i in 1 to 13 loop
            instruction_pointer <= i;
            wait for 1 * TbPeriod;
        end loop;

        target_value_x <= resize ( arg => gravity_X - gravity_Y*gyro_Z + gravity_Z*gyro_Y, size_res => target_value_x);
        target_value_y <= resize ( arg => gravity_Y - gravity_Z*gyro_X + gravity_X*gyro_Z, size_res => target_value_y);
        target_value_z <= resize ( arg => gravity_Z - gravity_X*gyro_Y + gravity_Y*gyro_X, size_res => target_value_z);

        -- EDIT Add stimuli here
        wait for 100 * TbPeriod;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;