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
        
        tx         : out std_logic;
        rx         : in STD_LOGIC
    );
end dbus_test_top;

architecture rtl of dbus_test_top is

    signal dbus0, dbus1, dbus2, dbus3, dbus4 : dbus;

begin
    cleaner : entity work.bus_cleaner_dbus(rtl) port map (clk, rst, dbus4, dbus0);
    bram : entity work.bram_dbus(rtl) generic map (1024, 2047) port map (clk, rst, dbus0, dbus1);
    buf  : entity work.buffer_dbus(rtl) port map (clk, rst, dbus1, dbus2);
    uart_tx : entity work.uart_tx_dbus(rtl) generic map (1, frequency_mhz, baud_rate_mhz, 2) port map (clk, rst, dbus2, dbus3, tx);
    uart_rx : entity work.uart_rx_dbus(rtl) generic map (frequency_mhz, baud_rate_mhz) port map (clk, rst, dbus3, dbus4, rx);

end rtl;