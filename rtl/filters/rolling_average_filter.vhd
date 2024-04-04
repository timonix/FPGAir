library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;


entity rolling_average_filter is
    generic(
        taps : integer := 8;
        data_width : POSITIVE := 16
    );
    
    port (
        clk   : in  std_logic;
        reset : in  std_logic;
        update: in  boolean;
        i_data: in  signed(data_width-1 downto 0);
        o_data: out signed(data_width-1 downto 0)
    );
end entity rolling_average_filter;

architecture rtl of rolling_average_filter is
    type data_array is array (0 to taps-1) of signed(data_width-1 downto 0);
    signal data_buffer : data_array;
    
    constant extra_bits : integer := integer(log2(real(taps)));

begin
    
    assert (taps = 2**integer(log2(real(taps))))
    report "number of taps must be a power of 2"
    severity failure;
    
    process(clk)
    variable sum : signed(data_width+extra_bits-1 downto 0);
    begin
        if rising_edge(clk) then
            if update then
                data_buffer <= i_data & data_buffer(0 to taps-2);
            end if;
            
            sum := (others => '0');
            for i in 0 to taps-1 loop
                sum := sum + data_buffer(i);
            end loop;
            
            if reset = '1' then
                data_buffer <= (others => (others => '0'));
                sum := (others => '0');
            end if;

            o_data <= sum(data_width+extra_bits-1 downto extra_bits);
            
        end if;
    end process;
    
    
end architecture rtl;