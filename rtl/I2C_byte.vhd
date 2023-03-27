library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity I2C_byte is
    generic(
        frequency_mhz : real := 27.0;
        i2c_frequency_mhz : real := 0.4
    );
    port(
        clk  : in std_logic;
        rst : in STD_LOGIC;
        i_send_byte : in STD_LOGIC;
        i_data : in std_logic_vector(7 downto 0)
    );
end entity I2C_byte;

architecture rtl of I2C_byte is
    
    signal clock_divisor : positive := positive(frequency_mhz / (4.0 * i2c_frequency_mhz));
    signal clock_divider_counter : natural range 0 to clock_divisor + 1 := 0;
    signal i2c_clock : STD_LOGIC := '0';
    
begin
    
    i2c_clock_proc: process(clk)
    begin
        if rising_edge(clk) then
            clock_divider_counter <= clock_divider_counter+1;
            i2c_clock <= '0';
            if clock_divider_counter = clock_divisor then
                clock_divider_counter <= 0;
                i2c_clock <= '1';
            end if;
        end if;
    end process;
    
    
    process(clk)
    
    begin
        if rising_edge(clk) then
            if i_send_byte = '1' then
                
            end if;
            
            if rst = '1' then
                
            end if;
        end if;
    end process;


end architecture rtl;