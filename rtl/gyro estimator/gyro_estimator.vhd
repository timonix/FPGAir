LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
use IEEE.fixed_pkg.all;

use work.common_pkg.fixed_mul;
use work.common_pkg.fixed_add;
use work.common_pkg.fixed_sub;

ENTITY gyro_estimator IS
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
        
        data_in_valid   : in BOOLEAN;
        vec_x : IN sfixed(vector_integer_bits - 1 DOWNTO vector_fractional_bits);
        vec_y : IN sfixed(vector_integer_bits - 1 DOWNTO vector_fractional_bits);
        vec_z : IN sfixed(vector_integer_bits - 1 DOWNTO vector_fractional_bits);
        
        gyro_x : IN sfixed(gyro_integer_bits - 1 DOWNTO gyro_fractional_bits);
        gyro_y : IN sfixed(gyro_integer_bits - 1 DOWNTO gyro_fractional_bits);
        gyro_z : IN sfixed(gyro_integer_bits - 1 DOWNTO gyro_fractional_bits);
        
        data_out_valid  : out BOOLEAN;
        out_x  : OUT sfixed(output_integer_bits - 1 DOWNTO output_fractional_bits);
        out_y  : OUT sfixed(output_integer_bits - 1 DOWNTO output_fractional_bits);
        out_z  : OUT sfixed(output_integer_bits - 1 DOWNTO output_fractional_bits)
        
    );
END ENTITY gyro_estimator;

-- out_x = vec_x - vec_y*gyro_z + vec_z*gyro_y
-- out_y = vec_y - vec_z*gyro_x + vec_x*gyro_z
-- out_z = vec_z - vec_x*gyro_y + vec_y*gyro_x

architecture rtl of gyro_estimator is
    signal line_out : sfixed(output_integer_bits - 1 DOWNTO output_fractional_bits);
    signal A : sfixed(vector_integer_bits - 1 DOWNTO vector_fractional_bits);
    signal B : sfixed(vector_integer_bits - 1 DOWNTO vector_fractional_bits);
    signal C : sfixed(vector_integer_bits - 1 DOWNTO vector_fractional_bits);
    
    constant Ar : sfixed(gyro_integer_bits - 1 DOWNTO gyro_fractional_bits) := to_sfixed(1.0,gyro_integer_bits - 1,gyro_fractional_bits);
    signal Br : sfixed(gyro_integer_bits - 1 DOWNTO gyro_fractional_bits);
    signal Cr : sfixed(gyro_integer_bits - 1 DOWNTO gyro_fractional_bits);
    
    type selector_t is (x0, y0, z0,unload_0, unload_1, idle);
    signal selector         : selector_t := idle;
    
begin
    
    process (clk)

    begin
        if rising_edge(clk) then
            data_out_valid <= false;
            case selector is
                when x0 => -- out_x = vec_x - vec_y*gyro_z + vec_z*gyro_y
                    A <= vec_x;
                    B <= vec_y;
                    C <= vec_z;
                    Br <= gyro_z;
                    Cr <= gyro_y;
                    selector <= y0;
                when y0 => -- out_y = vec_y - vec_z*gyro_x + vec_x*gyro_z
                    A <= vec_y;
                    B <= vec_z;
                    C <= vec_x;
                    Br <= gyro_x;
                    Cr <= gyro_z;
                    selector <= z0;
                when z0 => -- out_z = vec_z - vec_x*gyro_y + vec_y*gyro_x
                    A <= vec_z;
                    B <= vec_x;
                    C <= vec_y;
                    Br <= gyro_y;
                    Cr <= gyro_x;
                    out_x <= line_out;
                    selector <= unload_0;
                when unload_0 =>
                    out_y <= line_out;
                    selector <= unload_1;
                when unload_1 =>
                    out_z <= line_out;
                    selector <= idle;
                    data_out_valid <= true;
                when idle =>
                    if data_in_valid then
                        selector <= x0;
                    end if;
                when others =>
                    
            end case;
            if rst then
                selector <= idle;
            end if;
        end if;
    end process;
    
    process (clk)
    variable t0 : sfixed(output_integer_bits - 1 DOWNTO output_fractional_bits);
    variable t1 : sfixed(output_integer_bits - 1 DOWNTO output_fractional_bits);
    variable t2 : sfixed(output_integer_bits - 1 DOWNTO output_fractional_bits);
    begin
        if rising_edge(clk) then
            t0 := fixed_mul(A,Ar,line_out);
            t1 := fixed_mul(B,Br,line_out);
            t2 := fixed_mul(C,Cr,line_out);
            line_out <= fixed_add(fixed_sub(t0,t1),t2);
        end if;
    end process;

end architecture rtl;
