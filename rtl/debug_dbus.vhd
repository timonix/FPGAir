library ieee;
use ieee.std_logic_1164.all;

use work.common_pkg.all;

entity debug_dbus is
    generic(
        register_map : natural range 0 to dbus_range := 1;
        frequuency_mhz : real := 27.0;
        baud_rate_mhz : real := 115200.0/1000000.0;
        rx_buffer_size : positive := 2;
        tx_buffer_size : positive := 2
    );
    port(
        
        clk         : in std_logic;
        rst         : in STD_LOGIC;
        
        dbus_in : in dbus;
        dbus_out : out dbus;
        
        rx         : in STD_LOGIC;
        tx         : out STD_LOGIC

    );
end debug_dbus;

architecture rtl of debug_dbus is
    
    
    signal s_rx_data : STD_LOGIC_VECTOR(7 downto 0);
    signal s_tx_data : STD_LOGIC_VECTOR(7 downto 0);
    
    type uart_element is record
        data : STD_LOGIC_VECTOR(7 downto 0);
        valid : boolean;
    end record uart_element;
    
    type t_uart_buffer is array (positive range <>) of uart_element;
    signal rx_buffer : t_uart_buffer(0 to rx_buffer_size-1);
    signal tx_buffer : t_uart_buffer(0 to tx_buffer_size-1);
   
    
    signal s_rx_valid : boolean;
    signal s_tx_valid : boolean;
    signal s_tx_ready : boolean;
    
    type t_rx_state is (IDLE,STAGE_0,STAGE_1);
    signal s_rx_state : t_rx_state;
    
begin
    assert rx_buffer_size >= 2 report "rx_buffer_size is too small" severity failure;
    assert tx_buffer_size >= 1 report "tx_buffer_size is too small" severity failure;
    

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
    
    
    TX_PROC: process(clk)
    begin
        if rising_edge(clk) then
            for element in tx_buffer'low to tx_buffer'high-1 loop --shift buffer
                if not tx_buffer(element).valid then
                    tx_buffer(element) <= tx_buffer(element+1);
                    tx_buffer(element+1).valid <= false;
                end if;
            end loop;
            
            if dbus_in.target_address = register_map then
                tx_buffer(tx_buffer'high).valid <= true;
                tx_buffer(tx_buffer'high).data <= dbus_in.data;
            end if;
            
            if tx_buffer(tx_buffer'low).valid and s_tx_ready then
                s_tx_valid <= true;
                s_tx_data <= tx_buffer(tx_buffer'low).data;
                tx_buffer(tx_buffer'low).valid <= false;
            end if;
            
            if rst = '1' then
                tx_buffer <= (others => (
                        data => (others => '0'),
                        valid => false)
                );
                
            end if;
        end if;
    end process;
    
    


    RX_proc: process(clk)
    begin
        if rising_edge(clk) then
            
            dbus_out <= dbus_in;
            
            for element in rx_buffer'low to rx_buffer'high-1 loop --shift buffer
                if not rx_buffer(element).valid then
                    rx_buffer(element) <= rx_buffer(element+1);
                    rx_buffer(element+1).valid <= false;
                end if;
            end loop;
            
            if s_rx_valid then -- Add to recieve buffer
                rx_buffer(rx_buffer'high).valid <= true;
                rx_buffer(rx_buffer'high).data <= s_rx_data;
            end if;
            
            
            if rx_buffer(rx_buffer'low).valid and rx_buffer(rx_buffer'low+1).valid and dbus_in.target_address = 0 then -- add to bus when there is room
                rx_buffer(rx_buffer'low+1).valid <= false;
                rx_buffer(rx_buffer'low).valid <= false;
                dbus_out.source_address <= register_map;
                dbus_out.data <= rx_buffer(rx_buffer'low+1).data;
                dbus_out.target_address <= to_natural(rx_buffer(rx_buffer'low).data(5 downto 0)); --lower bits are device address
                dbus_out.command <=
                RD when rx_buffer(rx_buffer'low).data(7 downto 6) = "00" else
                WR when rx_buffer(rx_buffer'low).data(7 downto 6) = "01" else
                CLR;
            end if;
            
            if rst = '1' then
                rx_buffer <= (others => (
                        data => (others => '0'),
                        valid => false)
                );

            end if;
        end if;
    end process;

end rtl;