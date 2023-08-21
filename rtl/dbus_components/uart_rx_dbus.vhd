library ieee;
use ieee.std_logic_1164.all;

use work.common_pkg.all;

entity uart_rx_dbus is
    generic(
        source_address : natural range 1 to dbus_range := 1;
        frequency_mhz : real := 27.0;
        baud_rate_mhz : real := 115200.0/1000000.0
    );
    port(
        clk         : in std_logic;
        rst         : in STD_LOGIC;
        
        dbus_in : in dbus;
        dbus_out : out dbus;
        
        rx         : in STD_LOGIC
    );
end uart_rx_dbus;

architecture rtl of uart_rx_dbus is
    
    
    signal s_rx_data : STD_LOGIC_VECTOR(7 downto 0);

    signal rx_buffer : dbus;
    
    
    type t_rx_state is (WAITING_FOR_DATA, WAITING_FOR_ADDRESS_HIGH, WAITING_FOR_ADDRESS_LOW);
    signal s_rx_state : t_rx_state := WAITING_FOR_DATA;
    signal s_rx_valid : boolean;

    
begin
    

    rx_module : entity work.uart_rx(rtl)
    generic map(
        frequency_mhz => frequency_mhz,
        baud_rate_mhz => baud_rate_mhz
    )
    port map (
        clk           => clk,
        rst           => rst,
        enable        => TRUE,
        rx            => rx,
        data          => s_rx_data,
        data_valid    => s_rx_valid
    );
    


    process(clk)
    variable pop_buffer : boolean;
    begin
        if rising_edge(clk) then
            
            dbus_out <= dbus_in;
            
            if s_rx_state = WAITING_FOR_ADDRESS_HIGH and s_rx_valid then
                rx_buffer.target_address <= to_natural(s_rx_data(5 downto 0));
                rx_buffer.command <= to_dbus_command(s_rx_data(7 downto 6));
                s_rx_state <= WAITING_FOR_ADDRESS_LOW;
            elsif s_rx_state = WAITING_FOR_ADDRESS_LOW and s_rx_valid then
                rx_buffer.target_address <= rx_buffer.target_address * 256 + to_natural(s_rx_data);
                s_rx_state <= WAITING_FOR_DATA;
            elsif s_rx_state = WAITING_FOR_DATA and s_rx_valid then
                rx_buffer.data <= s_rx_data;
                rx_buffer.source_address <= source_address;
                s_rx_state <= WAITING_FOR_ADDRESS_HIGH;
            end if;
            
            if rx_buffer.target_address /= 0 and s_rx_state = WAITING_FOR_DATA then
                dbus_out <= rx_buffer;
                rx_buffer <= c_dbus;
            end if;
            
            if rst = '1' then
                s_rx_state <= WAITING_FOR_DATA;
                dbus_out <= c_dbus;
                rx_buffer <=  c_dbus;

            end if;
        end if;
    end process;

end rtl;