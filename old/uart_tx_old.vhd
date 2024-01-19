library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity uart_tx_old is
    generic (
        frequency_mhz : real := 27.0;
        baud_rate_mhz : real := 115200.0/1000000.0
    );
    port (
        
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        enable : in boolean;
        tx : out STD_LOGIC;
        
        data : in STD_LOGIC_VECTOR(7 downto 0);
        data_valid : in boolean;
        ready : out boolean
        
    );
end entity uart_tx_old;

architecture rtl of uart_tx_old is
    
    type state_t is (idle_E, working_E);
    signal state : state_t;
    
    constant period_time : natural := integer(frequency_mhz/baud_rate_mhz);
    constant half_period : natural := period_time/2;
    
    signal period_counter : natural range 0 to period_time + 1;
    
    signal s_data : STD_LOGIC_VECTOR(9 downto 0);
    
    signal bit_counter : NATURAL range 0 to 10;
    
begin
    --s_data(7 downto 0) <= data;
    
    ready <= state = idle_E;
    
    process (clk)
    begin
        if rising_edge(clk) then
            
            if not (period_counter = 0) then
                period_counter <= period_counter - 1;
            end if;
            
            if state = idle_E and data_valid then
                bit_counter <= 0;
                s_data(9) <= '1';
                s_data(0) <= '0';
                s_data(8 downto 1) <= data;
                state <= working_E;
            end if;
            
            if state = working_E and period_counter = 0 and not (bit_counter = 10) then
                tx <= s_data(0);
                s_data(8 downto 0) <= s_data(9 downto 1);
                period_counter <= period_time;
                bit_counter <= bit_counter + 1;
            end if;
            
            if state = working_E and period_counter = 0 and bit_counter = 10 then
                state <= idle_E;
            end if;
            
            if rst = '1' then
                state <= idle_E;
                period_counter <= 0;
                tx <= '1';
            end if;
            
        end if;

    end process;

end architecture rtl;