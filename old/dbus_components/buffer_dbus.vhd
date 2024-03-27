library ieee;
use ieee.std_logic_1164.all;

use work.common_pkg.all;

entity buffer_dbus is

    port(
        
        clk         : in std_logic;
        rst         : in STD_LOGIC;
        
        dbus_in : in dbus;
        dbus_out : out dbus

    );
end buffer_dbus;

architecture rtl of buffer_dbus is
    
begin

    process(clk)
    begin
        if rising_edge(clk) then
            dbus_out <= dbus_in;
            if rst = '1' then
                dbus_out <= c_dbus;
            end if;
        end if;
    end process;

end architecture rtl;