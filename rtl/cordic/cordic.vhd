library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.MATH_REAL.ALL;

use work.common_pkg.all;

entity cordic is
    generic(
        mode : string := "vector";
        iterations : positive := 15;
        data_width_vector : POSITIVE := 16;
        data_width_angle : POSITIVE := 16
    );
    port(
        clk         : in std_logic;
        rst         : in STD_LOGIC;
        
        i_x         : in signed(data_width_vector-1 downto 0); -- coordinate
        i_y         : in signed(data_width_vector-1 downto 0); -- coordinate
        i_angle     : in unsigned(data_width_angle-1 downto 0);
        
        update_data : in boolean;
        ready_to_recieve : out boolean;
        computation_done : out boolean;
        
        o_x          : out signed(data_width_vector-1 downto 0);
        o_y          : out signed(data_width_vector-1 downto 0);
        o_angle      : out unsigned(data_width_angle-1 downto 0)
        
    );
end cordic;

architecture rtl of cordic is
    
    type direction_t is (UP, DOWN);
    type t_cordic_data is record
        x     : signed(i_x'high+iterations+1 downto 0);
        y     : signed(i_y'high+iterations+1 downto 0);
        angle : unsigned(i_angle'range);
    end record;
    
    signal s_cordic_data : t_cordic_data;
    
    type lookup_table_type is array (0 to iterations-1) of unsigned(o_angle'range);

    function generate_lookup_table return lookup_table_type is
        variable table: lookup_table_type;
        constant scale_factor: real := 2.0 ** (data_width_angle) / (2.0 * MATH_PI);
    begin
        for i in 0 to iterations-1 loop
            table(i) := to_unsigned(integer(round(arctan(1.0 / (2.0 ** i)) * scale_factor)), data_width_angle);
        end loop;
        return table;
    end function generate_lookup_table;
    
    constant lookup_table: lookup_table_type := generate_lookup_table;

    constant one : unsigned(data_width_angle-1 downto 0) := (1 => '1', others => '0');
    signal deg_180 : unsigned(data_width_angle-1 downto 0) := shift_left(one,data_width_angle-2);

    constant zero_extend : signed(iterations-1 downto 0) := (others => '0');
    

    function rotate(input: t_cordic_data; index: natural; direction: direction_t) return t_cordic_data is
    variable data_out: t_cordic_data;
begin
    if direction = UP then
        data_out.angle := input.angle - lookup_table(index);
        data_out.x := input.x - shift_right(input.y, index);
        data_out.y := input.y + shift_right(input.x, index);
    else -- DOWN
        data_out.angle := input.angle + lookup_table(index);
        data_out.x := input.x + shift_right(input.y, index);
        data_out.y := input.y - shift_right(input.x, index);
    end if;
    
    return data_out;
end function rotate;

signal index : integer range 0 to iterations;

signal s_ready_to_recieve : boolean;

signal s_quadrant : std_logic_vector(0 to 1);

begin
    
    assert (mode = "vector" or mode = "rotation")
    report "Invalid mode selected. Mode must be either 'vector' or 'rotation'."
    severity failure;
    
    ready_to_recieve <= s_ready_to_recieve;

    o_x <= s_cordic_data.x(i_x'high+iterations downto iterations);
    o_y <= s_cordic_data.y(i_y'high+iterations downto iterations);
    o_angle <= s_cordic_data.angle;
    
    process(clk)
    begin
        if rising_edge(clk) then
            computation_done <= false;
            
            if (index < iterations) and (mode = "vector") then
                index <= index + 1;
                if s_cordic_data.y(s_cordic_data.y'high) = '1' then
                    s_cordic_data <= rotate(s_cordic_data, index, UP);
                else
                    s_cordic_data <= rotate(s_cordic_data, index, DOWN);
                end if;
            end if;
            
            if (index < iterations) and (mode = "rotation") then
                index <= index + 1;
                if s_cordic_data.angle(s_cordic_data.angle'high) = '0' then
                    s_cordic_data <= rotate(s_cordic_data, index, UP);
                else
                    s_cordic_data <= rotate(s_cordic_data, index, DOWN);
                end if;
            end if;
            
            if index = iterations and s_quadrant(0)='1' then
                s_cordic_data.x <= -s_cordic_data.x;
            end if;
            
            if index = iterations and s_quadrant(1)='1' then
                s_cordic_data.y <= -s_cordic_data.y;
            end if;
            
            if index = iterations then
                if s_quadrant(0) and (not s_quadrant(1)) then --WRONG
                    s_cordic_data.angle <= deg_180 - s_cordic_data.angle;
                elsif s_quadrant(0) and s_quadrant(1) then
                    s_cordic_data.angle <= s_cordic_data.angle - deg_180;
                    
                elsif not s_quadrant(0) and s_quadrant(1) then --correct
                    s_cordic_data.angle <= not s_cordic_data.angle;
                end if;
                s_quadrant <= (others => '0');
                s_ready_to_recieve <= true;
                if not s_ready_to_recieve then
                    computation_done <= true;
                end if;
            end if;
            
            if update_data and s_ready_to_recieve then
                --s_cordic_data.x <= i_x(i_x'high) & abs(i_x) & zero_extend;
                --s_cordic_data.y <= i_y(i_y'high) & abs(i_y) & zero_extend;

                s_cordic_data.x <= abs(i_x(i_x'high) & i_x & zero_extend);
                s_cordic_data.y <= abs(i_y(i_y'high) & i_y & zero_extend);
                s_cordic_data.angle <= i_angle;
                
                --s_quadrant <= (i_x < 0) & (i_y < 0);
                s_quadrant <= i_x(i_x'high) & i_y(i_y'high);
                
                index <= 0;
                s_ready_to_recieve <= false;
            end if;
            
            if rst = '1' then
                s_cordic_data.x <= (others => '0');
                s_cordic_data.y <= (others => '0');
                s_cordic_data.angle <= (others => '0');
                s_quadrant <= (others => '0');
                s_ready_to_recieve <= true;
                index <= iterations;
            end if;
            
        end if;
    end process;
    

    
end rtl;