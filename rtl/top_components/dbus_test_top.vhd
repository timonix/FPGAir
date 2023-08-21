library ieee;
use ieee.std_logic_1164.all;

use work.common_pkg.all;

entity dbus_test_top is
    generic(
        frequency_mhz : real := 27.0;
        baud_rate_mhz : real := 115200.0/1000000.0
    );
    port(
        clk         : in std_logic;
        rst         : in STD_LOGIC;
        
        debug_rx   : out std_logic;
        debug_tx   : out std_logic;
        
        
        tx         : out std_logic;
        rx         : in STD_LOGIC
    );
end dbus_test_top;

architecture rtl of dbus_test_top is

    signal dbus0, dbus1, dbus2, dbus3, dbus4 : dbus;
    signal tx_tmp :STD_LOGIC;

begin
    debug_rx <= rx;
    debug_tx <= tx_tmp;
    tx <= tx_tmp;
    
    cleaner : entity work.bus_cleaner_dbus(rtl) port map (clk, rst, dbus3, dbus0);
    bram : entity work.bram_dbus(rtl) generic map (2, 10) port map (clk, rst, dbus0, dbus1);
    uart_tx : entity work.uart_tx_dbus(rtl) generic map (1, frequency_mhz, baud_rate_mhz,"FPGAir" & LF,8) port map (clk, rst, dbus1, dbus2, tx_tmp);
    uart_rx : entity work.uart_rx_dbus(rtl) generic map (1, frequency_mhz, baud_rate_mhz) port map (clk, rst, dbus2, dbus3, rx);

end rtl;