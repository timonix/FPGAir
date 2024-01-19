library ieee;
use ieee.std_logic_1164.all;

use work.common_pkg.all;

entity uart_tx_buffered_stream is
    generic(
        frequency_mhz : real := 27.0;
        baud_rate_mhz : real := 115200.0/1000000.0;
        boot_message : String := "FPGAir";
        buffer_size : positive range boot_message'length to integer'high := boot_message'length
    );
    port(
        
        clk         : in std_logic;
        rst         : in STD_LOGIC;
        
        o_ready       : out boolean;
        i_valid       : in boolean;
        i_data        : in std_logic_vector(7 downto 0);
        
        o_tx         : out STD_LOGIC

    );
end uart_tx_buffered_stream;

architecture rtl of uart_tx_buffered_stream is
    
    signal s_tx_data : STD_LOGIC_VECTOR(7 downto 0);
    
    type uart_element is record
        data : STD_LOGIC_VECTOR(7 downto 0);
        valid : boolean;
    end record uart_element;
    
    type t_uart_buffer is array (natural range <>) of uart_element;
    signal tx_buffer : t_uart_buffer(0 to buffer_size-1);
    
    signal s_tx_valid : boolean;
    signal s_tx_ready : boolean;
    
begin
    
    tx_module : entity work.uart_tx(rtl)
    generic map(
        frequency_mhz => frequency_mhz,
        baud_rate_mhz => baud_rate_mhz
    )
    port map (
        clk           => clk,
        rst           => rst,
        enable        => TRUE,
        tx            => o_tx,
        data          => s_tx_data,
        data_valid    => s_tx_valid,
        ready         => s_tx_ready
    );
    
    o_ready <= not tx_buffer(tx_buffer'high).valid;
    
    process(clk)
    begin
        if rising_edge(clk) then
            
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
            
            if i_valid then
                tx_buffer(tx_buffer'high).valid <= true;
                tx_buffer(tx_buffer'high).data <= i_data;
            end if;
            
            if rst = '1' then
                tx_buffer <= (others => (
                        data => (others => '0'),
                        valid => false)
                );
                
                for char in boot_message'range loop
                    tx_buffer(char-1) <= (data => TO_STDLOGICVECTOR(boot_message(char)), valid => true);
                end loop;
                
            end if;
        end if;
    end process;

end rtl;