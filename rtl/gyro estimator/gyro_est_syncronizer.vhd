LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
use IEEE.fixed_pkg.all;

use work.common_pkg.fixed_mul;
use work.common_pkg.fixed_add;
use work.common_pkg.fixed_sub;

ENTITY gyro_est_syncronizer IS
    generic(
        vector_integer_bits : INTEGER := 16;
        vector_fractional_bits : INTEGER := -16;
        
        gyro_integer_bits : INTEGER := 16;
        gyro_fractional_bits : INTEGER := -16;
        
        output_integer_bits : INTEGER := 16;
        output_fractional_bits : INTEGER := -16
    );
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        
        vector_data_valid   : in BOOLEAN;
        vec_x : IN sfixed(vector_integer_bits - 1 DOWNTO vector_fractional_bits);
        vec_y : IN sfixed(vector_integer_bits - 1 DOWNTO vector_fractional_bits);
        vec_z : IN sfixed(vector_integer_bits - 1 DOWNTO vector_fractional_bits);
        
        gyro_data_valid   : in BOOLEAN;
        gyro_x : IN sfixed(gyro_integer_bits - 1 DOWNTO gyro_fractional_bits);
        gyro_y : IN sfixed(gyro_integer_bits - 1 DOWNTO gyro_fractional_bits);
        gyro_z : IN sfixed(gyro_integer_bits - 1 DOWNTO gyro_fractional_bits);
        
        sync_data_valid   : OUT BOOLEAN;
        sync_vec_x : OUT sfixed(vector_integer_bits - 1 DOWNTO vector_fractional_bits);
        sync_vec_y : OUT sfixed(vector_integer_bits - 1 DOWNTO vector_fractional_bits);
        sync_vec_z : OUT sfixed(vector_integer_bits - 1 DOWNTO vector_fractional_bits);
        sync_gyro_x : OUT sfixed(gyro_integer_bits - 1 DOWNTO gyro_fractional_bits);
        sync_gyro_y : OUT sfixed(gyro_integer_bits - 1 DOWNTO gyro_fractional_bits);
        sync_gyro_z : OUT sfixed(gyro_integer_bits - 1 DOWNTO gyro_fractional_bits)
    );
END ENTITY gyro_est_syncronizer;


architecture rtl of gyro_est_syncronizer is
    signal gyro_valid : boolean := false;
    signal vec_valid : boolean := false;
begin
    
    process (clk)

    begin
        if rising_edge(clk) then
            
            sync_data_valid <= false;
            
            if vector_data_valid then
                vec_valid <= true;
                sync_vec_x <= vec_x;
                sync_vec_y <= vec_y;
                sync_vec_z <= vec_z;
            end if;
            
            if gyro_data_valid then
                gyro_valid <= true;
                sync_gyro_x <= gyro_x;
                sync_gyro_y <= gyro_y;
                sync_gyro_z <= gyro_z;
            end if;
            
            if gyro_valid and vec_valid then
                gyro_valid <= false;
                vec_valid <= false;
                sync_data_valid <= true;
            end if;
            
            if rst then
                gyro_valid <= false;
                vec_valid <= false;
            end if;
        end if;
    end process;
    
end architecture rtl;
