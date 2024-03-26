library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity scale_bias_correction is
    generic(
        width_scale     : POSITIVE := 16;
        width_data_in   : POSITIVE := 16;
        width_data_out  : POSITIVE := 16;
        width_bias      : POSITIVE := 16
        
    );
    port(
        clk             :  in std_logic;
        rst             : in STD_LOGIC;
        
        data_in_valid   : in BOOLEAN;
        x_in            : in std_logic_vector(width_data_in-1 downto 0);
        y_in            : in std_logic_vector(width_data_in-1 downto 0);
        z_in            : in std_logic_vector(width_data_in-1 downto 0);
        x_bias          : in std_logic_vector(width_bias-1 downto 0);
        y_bias          : in std_logic_vector(width_bias-1 downto 0);
        z_bias          : in std_logic_vector(width_bias-1 downto 0);
        x_scale         : in std_logic_vector(width_scale-1 downto 0);
        y_scale         : in std_logic_vector(width_scale-1 downto 0);
        z_scale         : in std_logic_vector(width_scale-1 downto 0);
        
        data_out_valid  : out BOOLEAN;
        x_out           : out std_logic_vector(width_data_out-1 downto 0);
        y_out           : out std_logic_vector(width_data_out-1 downto 0);
        z_out           : out std_logic_vector(width_data_out-1 downto 0)
    );
end entity scale_bias_correction;

architecture rtl of scale_bias_correction is
    type selector_t is (x, y, z, idle);
    signal selector         : selector_t := x;
    
begin

    process(clk)
    
    variable selected_data    : SIGNED(width_bias-1 downto 0);
    variable selected_bias    : SIGNED(width_bias-1 downto 0);
    variable selected_scale   : SIGNED(width_scale-1 downto 0);
    
    begin
        if rising_edge(clk) then
            
            data_out_valid <= false;
            
            if data_in_valid = true then
                selector <= x;
            end if;
            
            case selector is
                when x =>
                    selected_data := SIGNED(x_in);
                    selected_bias := SIGNED(x_bias);
                    selected_scale := SIGNED(x_scale);
                    
                    x_out <= std_logic_vector(selected_data * selected_scale + selected_bias);
                    selector <= y;
                
                when y =>
                    selected_data := SIGNED(y_in);
                    selected_bias := SIGNED(y_bias);
                    selected_scale := SIGNED(y_scale);
                    
                    y_out <= std_logic_vector(selected_data * selected_scale + selected_bias);
                    selector <= z;
                    
                when z =>
                    selected_data := SIGNED(z_in);
                    selected_bias := SIGNED(z_bias);
                    selected_scale := SIGNED(z_scale);
                    
                    z_out <= std_logic_vector(selected_data * selected_scale + selected_bias);
                    selector <= idle;
                    data_out_valid <= true;
                    
                when others =>
            end case;

            if rst = '1' then
                selector <= idle;
                data_out_valid <= false;
            end if;
        end if;
    end process;

end architecture rtl;