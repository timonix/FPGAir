library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.common_pkg.all;

entity uart_multi_rx is
    generic (
        frequency_mhz : real := 27.0;
        baud_rate_mhz : real := 115200.0/1000000.0;
        num_bytes : POSITIVE := 2

    );
    port (
        
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        enable : in boolean;
        rx : in STD_LOGIC;
        
        data : out STD_LOGIC_VECTOR(num_bytes*8-1 downto 0);
        data_valid : out boolean
        
    );
end entity uart_multi_rx;

architecture rtl of uart_multi_rx is

    signal state : natural range 0 to num_bytes-1;
   
    signal s_byte_data : STD_LOGIC_VECTOR(7 downto 0);
    signal byte_valid : boolean;
    
    signal rx_q : std_logic;
    signal rx_qq: std_logic;
    
    constant timeout : natural := 10*natural(frequency_mhz/baud_rate_mhz);
    signal timeout_counter : natural range 0 to timeout + 1;
    
begin
    
    process(clk)
    begin
        if rising_edge(clk) then
            data_valid <= FALSE;
            rx_q <= rx;
            rx_qq <= rx_q;
            
            if timeout_counter /= 0 then
                timeout_counter <= timeout_counter - 1;
            end if;
            
            if timeout_counter = 0 then
                state <= 0;
            end if;
            
            if rx_q /= rx_qq then
                timeout_counter <= timeout;
            end if;
            
            if byte_valid then
                
                data(state*8+7 downto state*8) <= s_byte_data;
                
                if state = num_bytes-1 then
                    state <= 0;
                    data_valid <= true;
                else
                    state <= state + 1;
                end if;
            end if;

            if rst = '1' or not enable then
                data_valid <= FALSE;
                timeout_counter <= timeout;
                state <= 0;
                rx_q <= '1';
                rx_qq <= '1';
            end if;
        end if;
    end process;
   
    rx_inst: entity work.uart_rx(rtl)
    generic map (
        frequency_mhz => frequency_mhz,
        baud_rate_mhz => baud_rate_mhz
    )
    port map (clk  => clk,
        rst        => rst,
        enable     => enable,
        rx         => rx_qq,
        data       => s_byte_data,
        data_valid => byte_valid);
    
end architecture rtl;