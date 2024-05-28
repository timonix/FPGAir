library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;
use IEEE.fixed_pkg.all;
use work.common_pkg.all;


entity rolling_average_filter_sfixed is
    generic(
        taps : integer := 8;
        data_in_integer_bits : INTEGER := 16;
        data_in_fractional_bits : INTEGER := -16
    );
    
    port (
        clk   : in  std_logic;
        reset : in  std_logic;
        update: in  boolean;
        i_data: in  sfixed(data_in_integer_bits-1 downto data_in_fractional_bits);
        o_data: out sfixed(data_in_integer_bits-1 downto data_in_fractional_bits-integer(log2(real(taps))))
    );
end entity rolling_average_filter_sfixed;

architecture rtl of rolling_average_filter_sfixed is
    type data_array is array (0 to taps-1) of sfixed(data_in_integer_bits-1 downto data_in_fractional_bits);
    signal data_buffer : data_array;

begin
    
    assert (taps = 2**integer(log2(real(taps))))
    report "number of taps must be a power of 2"
    severity failure;
    
    process(clk)
    variable sum : sfixed(data_in_integer_bits-1 downto data_in_fractional_bits-integer(log2(real(taps))));
    begin
        if rising_edge(clk) then
            report "input -- " & to_string(i_data);
            
            if update then
                data_buffer <= i_data & data_buffer(0 to taps-2);
            end if;
            
            sum := (others => '0');
            
            for i in 0 to taps-1 loop
                sum := fixed_add(sum,data_buffer(i) srl (3));
            end loop;
            
            if reset = '1' then
                data_buffer <= (others => (others => '0'));
                sum := (others => '0');
            end if;

            o_data <= sum;
            
        end if;
    end process;
    
    
end architecture rtl;