library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity radio is
    generic(
        frequency_mhz : real := 27.0
    );
    port(
        clk  : in std_logic;
        rst : in STD_LOGIC;
        channel_1 : in STD_LOGIC;
        signal_1 : out STD_LOGIC_VECTOR(9 downto 0);
        multiplier : in unsigned(9 downto 0)
        
    );
end entity radio;

architecture rtl of radio is
    
    constant micro_second : real := 1.0;
    constant clock_divisor : positive := positive(frequency_mhz / micro_second);
    signal clock_divider_counter : natural range 0 to clock_divisor + 1 := 0;
    signal radio_clock : STD_LOGIC := '0';
    
    signal channel_1_counter : integer := 0;
    signal channel_1_last_val : STD_LOGIC;
    
begin

    radio_clock_proc: process(clk)
    begin
        if rising_edge(clk) then
            clock_divider_counter <= clock_divider_counter+1;
            radio_clock <= '0';
            if clock_divider_counter = clock_divisor then
                clock_divider_counter <= 0;
                radio_clock <= '1';
            end if;
        end if;
    end process;
    
    process(clk, radio_clock, rst)
        variable tmp : unsigned (19 downto 0);
    begin
        
        
        if rising_edge(clk) then            
            
            if radio_clock = '1' AND channel_1 = '1' then                
                channel_1_counter <= channel_1_counter + 1;
            end if;
            
            if channel_1_last_val = '1' AND channel_1 = '0' then
                tmp := to_unsigned(channel_1_counter - 1000, signal_1'length)*multiplier;
                signal_1 <= std_logic_vector(tmp(19 downto 10));
                channel_1_counter <= 0;
            end if;
            
            channel_1_last_val <= channel_1;

            
            
            if rst = '1' then
                signal_1 <= (others => '0');
            end if;
            
        end if;
    end process;

end architecture rtl;



