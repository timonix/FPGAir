library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity uart_tx is
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
end entity uart_tx;

architecture rtl of uart_tx is
    
    constant period_time : natural := integer(frequency_mhz/baud_rate_mhz);
    signal period_counter : natural range 0 to period_time + 1;
    
    signal s_data : STD_LOGIC_VECTOR(8 downto 0) := (others => '1');
    
    signal s_ready : boolean;
    
begin
    
    
    ready <= s_ready;
    tx <= s_data(0);
    
    process (clk)
    begin
        if rising_edge(clk) then
            
            if not (period_counter = 0) then
                period_counter <= period_counter - 1;
            end if;
            
            if s_ready and data_valid then
                s_data(0) <= '0';
                s_data(8 downto 1) <= data;
                s_ready <= false;
            end if;
            
            if period_counter = 0 then
                s_ready <= (and s_data) = '1';
                s_data(8 downto 0) <= '1' & s_data(8 downto 1);
                period_counter <= period_time;
            end if;
            
            if rst = '1' then
                s_data <= (others => '1');
            end if;
            
        end if;

    end process;

end architecture rtl;