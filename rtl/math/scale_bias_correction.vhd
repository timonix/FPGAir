library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.fixed_pkg.all;

use work.common_pkg.addmul;

entity scale_bias_correction is
    generic(
        data_in_integer_bits : INTEGER := 16;
        data_in_fractional_bits : INTEGER := -16;
        data_out_integer_bits : INTEGER := 16;
        data_out_fractional_bits : INTEGER := -16;
        
        scale_integer_bits : INTEGER := 16;
        scale_fractional_bits : INTEGER := -16;
        
        bias_integer_bits : INTEGER := 16;
        bias_fractional_bits : INTEGER := -16
        
    );
    port(
        clk             :  in std_logic;
        rst             : in STD_LOGIC;
        
        data_in_valid   : in BOOLEAN;
        x_in            : in sfixed(data_in_integer_bits-1 downto data_in_fractional_bits);
        y_in            : in sfixed(data_in_integer_bits-1 downto data_in_fractional_bits);
        z_in            : in sfixed(data_in_integer_bits-1 downto data_in_fractional_bits);
        x_bias          : in sfixed(bias_integer_bits-1 downto bias_fractional_bits);
        y_bias          : in sfixed(bias_integer_bits-1 downto bias_fractional_bits);
        z_bias          : in sfixed(bias_integer_bits-1 downto bias_fractional_bits);
        x_scale         : in sfixed(scale_integer_bits-1 downto scale_fractional_bits);
        y_scale         : in sfixed(scale_integer_bits-1 downto scale_fractional_bits);
        z_scale         : in sfixed(scale_integer_bits-1 downto scale_fractional_bits);
        
        data_out_valid  : out BOOLEAN;
        x_out           : out sfixed(data_out_integer_bits-1 downto data_out_fractional_bits);
        y_out           : out sfixed(data_out_integer_bits-1 downto data_out_fractional_bits);
        z_out           : out sfixed(data_out_integer_bits-1 downto data_out_fractional_bits)
    );
end entity scale_bias_correction;

architecture rtl of scale_bias_correction is
    type selector_t is (x, y, z, idle);
    signal selector         : selector_t := x;
    
begin

    process(clk)
    
    variable selected_data    : sfixed(data_in_integer_bits-1 downto data_in_fractional_bits);
    variable selected_bias    : sfixed(bias_integer_bits-1 downto bias_fractional_bits);
    variable selected_scale   : sfixed(scale_integer_bits-1 downto scale_fractional_bits);
    
    begin
        if rising_edge(clk) then
            
            data_out_valid <= false;
            
            if data_in_valid = true then
                selector <= x;
            end if;
            
            case selector is
                when x =>
                    selected_data := x_in;
                    selected_bias := x_bias;
                    selected_scale := x_scale;
                    x_out <= addmul(selected_data,selected_bias,selected_scale,x_out);
                    selector <= y;
                    
                when y =>
                    selected_data := y_in;
                    selected_bias := y_bias;
                    selected_scale := y_scale;
                    
                    y_out <= addmul(selected_data,selected_bias,selected_scale,x_out);
                    selector <= z;
                    
                when z =>
                    selected_data := z_in;
                    selected_bias := z_bias;
                    selected_scale := z_scale;
                    
                    z_out <= addmul(selected_data,selected_bias,selected_scale,x_out);
                    selector <= idle;
                    data_out_valid <= true;
                    
                when others =>
                    
            end case;

            if rst = '1' then
                selector <= idle;
            end if;
        end if;
    end process;

end architecture rtl;