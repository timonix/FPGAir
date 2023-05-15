library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity uart_rx is
    generic (
        frequency_mhz : real := 27.0;
        baud_rate_mhz : real := 9600.0/1000000
    );
    port (
        
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        enable : in boolean;
        rx : in STD_LOGIC;
        
        data : out STD_LOGIC_VECTOR(7 downto 0);
        data_valid : out boolean;
        ready : in boolean
        
    );
end entity uart_rx;

architecture rtl of uart_rx is
    
    type state_t is (idle_E, working_E);
    signal state : state_t;
    
    constant period_time : natural := integer(frequency_mhz/baud_rate_mhz);
    constant half_period : natural := period_time/2;
    
    signal period_counter : natural range 0 to period_time + 1;
    
    signal s_data : STD_LOGIC_VECTOR(8 downto 0);
    
    
begin
    data <= s_data(7 downto 0);
    
    process (clk)
    begin
        if rising_edge(clk) then
            
            if not (period_counter = 0) then
                period_counter <= period_counter - 1;
            end if;
            
            if state = idle_E and rx = '0' then
                period_counter <= period_time/2;
                state <= working_E;
                s_data <= (others => '1');
            end if;
            
            if state = working_E and period_counter = 0 and s_data(8) = '1' then
                s_data<= s_data(7 downto 0) & rx;
                period_counter <= period_time;
            end if;
            
            if state = working_E and period_counter = 0 and s_data(8) = '0' then
                state <= idle_E;
            end if;
            
            if rst = '1' then
                period_counter <= 0;
                s_data <= (others => '0');
            end if;
            
        end if;

    end process;

end architecture rtl;