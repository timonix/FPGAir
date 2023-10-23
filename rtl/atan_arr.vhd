library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.fixed_pkg.all;

use IEEE.MATH_REAL.all;

entity atan_arr is
    generic (
        
    );
    port(
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        i_update : in BOOLEAN;
        i_iteration : in POSITIVE;
        i_d : in BOOLEAN;
        o_z : out sfixed
    );
end entity atan_arr;

architecture rtl of atan_arr is
    type arr_type is array (i_iteration'range) of sfixed(o_z'range);
    signal atan_array : arr_type;
begin
    
    arctan_generator: for i in atan_array'range generate
        atan_array(i) <= to_sfixed((ARCTAN(2.0**(-i))/(2.0*MATH_PI)), atan_array(i)'left, atan_array(i)'right);
    end generate arctan_generator;
    
    process(clk)
    begin
        
        if rising_edge(clk) then
            
            
            
        end if;
        
    end process;
end architecture rtl;

