library ieee;
use ieee.std_logic_1164.all;

use work.common_pkg.all;

entity uart_tx_dbus is
    generic(
        register_map : natural range 0 to dbus_range := 1;
        frequency_mhz : real := 27.0;
        baud_rate_mhz : real := 115200.0/1000000.0;
        buffer_size : positive := 2
    );
    port(
        
        clk         : in std_logic;
        rst         : in STD_LOGIC;
        
        dbus_in : in dbus;
        dbus_out : out dbus;
        
        tx         : out STD_LOGIC

    );
end uart_tx_dbus;

architecture rtl of uart_tx_dbus is
    
    signal s_tx_data : STD_LOGIC_VECTOR(7 downto 0);
    
    type uart_element is record
        data : STD_LOGIC_VECTOR(7 downto 0);
        valid : boolean;
    end record uart_element;
    
    type t_uart_buffer is array (positive range <>) of uart_element;
    signal tx_buffer : t_uart_buffer(0 to buffer_size-1);
    
    signal s_tx_valid : boolean;
    signal s_tx_ready : boolean;
    
begin
    
    assert buffer_size >= 1 report "tx_buffer_size is too small" severity failure;
    
    tx_module : entity work.uart_tx(rtl)
    generic map(
        frequency_mhz => frequency_mhz,
        baud_rate_mhz => baud_rate_mhz
    )
    port map (
        clk           => clk,
        rst           => rst,
        enable        => TRUE,
        tx            => tx,
        data          => s_tx_data,
        data_valid    => s_tx_valid,
        ready         => s_tx_ready
    );
    
    
    process(clk)
    variable pop_buffer : boolean;
    begin
        if rising_edge(clk) then
            
            dbus_out <= dbus_in;
            
            s_tx_valid <= false;
            if tx_buffer(tx_buffer'low).valid and s_tx_ready then
                s_tx_valid <= true;
                s_tx_data <= tx_buffer(tx_buffer'low).data;
                tx_buffer(tx_buffer'low).valid <= false;
            end if;
            
            if not tx_buffer(tx_buffer'low).valid then
                tx_buffer(0 to tx_buffer'high-1) <= tx_buffer(1 to tx_buffer'high);
                tx_buffer(tx_buffer'high).valid <= false;
            end if;
            
            if dbus_in.target_address = register_map then
                tx_buffer(tx_buffer'high).valid <= true;
                tx_buffer(tx_buffer'high).data <= dbus_in.data;
                dbus_out <= c_dbus;
            end if;
            
            if rst = '1' then
                dbus_out <= c_dbus;
                tx_buffer <= (others => (
                        data => (others => '0'),
                        valid => false)
                );
                
            end if;
        end if;
    end process;

end rtl;