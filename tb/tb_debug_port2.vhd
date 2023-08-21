library ieee;
use ieee.std_logic_1164.all;

use work.common_pkg.all;

entity testbench is
end testbench;

architecture tb of testbench is
    constant dbus_range : integer := 255;
    constant frequency_mhz : real := 27.0;
    constant baud_rate_mhz : real := 115200.0/1000000.0;
    constant buffer_size : positive := 2;

    signal clk : std_logic := '0';
    signal rst : std_logic := '1';

    signal dbus_Q : dbus;
    
    signal dbus_out_tx : dbus;
    signal dbus_in_tx : dbus;
    
    signal dbus_out_rx : dbus;
    signal dbus_in_rx : dbus;
    
    signal tx, rx : std_logic := '1';
    
    constant clk_period : time := 37 ns;  -- Clock period, you may change this as required
    signal TbSimEnded : boolean := false;
    
begin
    
    dbus_in_rx <= dbus_out_tx;
    
    process(clk)
    begin
        if rising_edge(clk) then
            dbus_Q <= dbus_out_rx;
            dbus_in_tx <= dbus_Q;
            
            if rst = '1' then
                dbus_in_tx <= C_dbus;
                dbus_Q <= C_dbus;
            end if;
        end if;
    end process;

    
    clk <= not clk after clk_period / 2 when not TbSimEnded else '0';
    
    tx_inst : entity work.uart_tx_dbus(rtl)
    generic map(
        register_map => 1,
        frequency_mhz => frequency_mhz,
        baud_rate_mhz => baud_rate_mhz,
        buffer_size => buffer_size
    )
    port map(
        clk => clk,
        rst => rst,
        dbus_in => dbus_in_tx,
        dbus_out => dbus_out_tx,
        tx => tx
    );
    
    rx_inst : entity work.uart_rx_dbus(rtl)
    generic map(

        frequency_mhz => frequency_mhz,
        baud_rate_mhz => baud_rate_mhz
    )
    port map(
        clk => clk,
        rst => rst,
        dbus_in => dbus_in_rx,
        dbus_out => dbus_out_rx,
        rx => rx
    );
    
        -- Stimulus process
    stim_proc: process
    variable test_address : std_logic_vector(7 downto 0) := "01000001";
    variable test_data : std_logic_vector(7 downto 0) := "01100101";
    
    begin
        
        -- reset
        rst <= '1';
        wait for clk_period*10;
        rst <= '0';

        -- scenario 1
        wait for clk_period*5;
        
        
        rx <= '0'; --start bit
        wait for 8.68055556 us;
        for bit in test_data'range loop
            rx <= test_data(bit);
            wait for 8.68055556 us;
        end loop;
        rx <= '1'; --stop bit
        
        
        wait for 8.68055556 us;
        
        rx <= '0'; --start bit
        wait for 8.68055556 us;
        for bit in test_address'range loop
            rx <= test_address(bit);
            wait for 8.68055556 us;
        end loop;
        rx <= '1'; --stop bit
        wait for 8.68055556 us;
        
        wait for 20*8.68055556 us;
        
        wait for clk_period*10;
        
        TbSimEnded <= true;

        wait;
    end process;

end tb;