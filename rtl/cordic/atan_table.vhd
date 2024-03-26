library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity atan_table is
    generic (
       max_index : natural := 15;
       value_size : natural := 16
    );
    port (
        index: in natural range 0 to max_index;
        value: out signed(value_size-1 downto 0)
    );
end entity atan_table;

architecture Behavioral of atan_table is
    type lookup_table_type is array (0 to max_index) of signed(value_size-1 downto 0);

    function generate_lookup_table return lookup_table_type is
        variable table: lookup_table_type;
        constant scale_factor: real := 2.0 ** value_size / (2.0 * MATH_PI);
    begin
        for i in 0 to max_index loop
            table(i) := to_signed(integer(round(arctan(1.0 / (2.0 ** i)) * scale_factor)), value_size);
        end loop;
        return table;
    end function generate_lookup_table;
    
    constant lookup_table: lookup_table_type := generate_lookup_table;

begin
    value <= lookup_table(index);
end architecture Behavioral;