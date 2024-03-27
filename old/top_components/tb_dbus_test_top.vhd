library ieee;
use ieee.std_logic_1164.all;

use work.common_pkg.all;

entity tb_dbus_test_top is

end tb_dbus_test_top;

architecture sim of tb_dbus_test_top is
    
    constant frequency_mhz : real := 27.0;
    constant baud_rate_mhz : real := 115200.0/1000000.0;
    constant buffer_size : positive := 2;

    signal clk : std_logic := '0';
    signal rst : std_logic := '1';

    signal tx, rx : std_logic := '1';
    
    constant clk_period : time := 37 ns;  -- Clock period, you may change this as required
    signal TbSimEnded : boolean := false;
    signal dbus0, dbus1, dbus2, dbus3, dbus4 : dbus;

begin
    
    clk <= not clk after clk_period / 2 when not TbSimEnded else '0';
    
    cleaner : entity work.bus_cleaner_dbus(rtl) port map (clk, rst, dbus3, dbus0);
    bram : entity work.bram_dbus(rtl) generic map (2, 10) port map (clk, rst, dbus0, dbus1);
    uart_tx : entity work.uart_tx_dbus(rtl) generic map (1, frequency_mhz, baud_rate_mhz,"FPGAir" & LF,8) port map (clk, rst, dbus1, dbus2, tx);
    uart_rx : entity work.uart_rx_dbus(rtl) generic map (1, frequency_mhz, baud_rate_mhz) port map (clk, rst, dbus2, dbus3, rx);
    
    stim_proc: process
    variable test_address_high : std_logic_vector(7 downto 0) := x"40";
    variable test_address_low : std_logic_vector(7 downto 0) := x"01";
    variable test_data : std_logic_vector(7 downto 0) := x"65";
    
    begin
        
        -- reset
        rst <= '1';
        wait for clk_period*10;
        rst <= '0';
        
        wait for 10*8*8.68055556 us;

        -- scenario 1
        wait for clk_period*5;
        
        
        rx <= '0'; --start bit
        wait for 8.68055556 us;
        for bit in 0 to 7 loop
            rx <= test_data(bit);
            wait for 8.68055556 us;
        end loop;
        rx <= '1'; --stop bit
        
        
        wait for 8.68055556 us;
        
        rx <= '0'; --start bit
        wait for 8.68055556 us;
        for bit in 0 to 7 loop
            rx <= test_address_high(bit);
            wait for 8.68055556 us;
        end loop;
        rx <= '1'; --stop bit
        wait for 8.68055556 us;
        
        rx <= '0'; --start bit
        wait for 8.68055556 us;
        for bit in 0 to 7 loop
            rx <= test_address_low(bit);
            wait for 8.68055556 us;
        end loop;
        rx <= '1'; --stop bit
        wait for 8.68055556 us;
        
        wait for 20*8.68055556 us;
        
        wait for clk_period*10;
        
        TbSimEnded <= true;

        wait;
    end process;

end sim;