library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity uart_rx is
    generic (
        frequency_mhz : real := 27.0;
        buffer_size : natural := 2
    );
    port(
        
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        enable : in BOOLEAN;
        rx : in STD_LOGIC;
        
        data : out STD_LOGIC_VECTOR(buffer_size * 8-1 downto 0);
        data_valid : out BOOLEAN;
        ready : in BOOLEAN
        
    );
end entity uart_rx;

architecture rtl of uart_rx is
    
    type my_type_T is (Init_E, asd_E);
    
    constant micro_second : real := 1.0;
    constant clock_divisor : positive := positive(frequency_mhz / micro_second) - 1;
    constant period_time : INTEGER := 2500 * 8 - 1; -- 2500 for 400Hz

    signal clock_divider_counter : natural range 0 to clock_divisor + 1 := 0;
    signal micro_clock : STD_LOGIC := '0'; -- 1 DFF
    
    signal period_counter : NATURAL range 0 to period_time + 1 := 0;  --
    signal pulse_time : unsigned(10 downto 0); -- Time of pulse
    
    
begin
    
    radio_clock_proc : process (clk)
    begin
        if rising_edge(clk) then
            clock_divider_counter <= clock_divider_counter + 1;
            micro_clock <= '0';
            if clock_divider_counter = clock_divisor then
                clock_divider_counter <= 0;
                micro_clock <= '1';
            end if;
            
        end if;
    end process;
    
    process(clk)
    begin
        
        if rising_edge(clk) then
            
            sync <= '0';
            
            -- Add to period counter each micro second
            if micro_clock = '1' then
                period_counter <= period_counter + 1;
            end if;
            
            -- While signal is active
            if period_counter < pulse_time then
                output <= '1';
            end if;
            
            -- End of period, reset and fetch new speed time value
            if period_counter > period_time then
                sync <= '1';
                period_counter <= 0;
                pulse_time <= speed + 1000;
            end if;
            
            if not enable or rst then
                pulse_time <= 0;
                output <= '0';
                period_counter <= 0;
            end if;
            
        end if;
        
    end process;

end architecture rtl;
