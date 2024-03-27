library ieee;
use ieee.std_logic_1164.all;

use work.common_pkg.all;

entity bus_cleaner_dbus is

    port(
        
        clk         : in std_logic;
        rst         : in STD_LOGIC;
        
        dbus_in : in dbus;
        dbus_out : out dbus

    );
end bus_cleaner_dbus;

architecture rtl of bus_cleaner_dbus is
    
begin

    process(clk)
    begin
        if rising_edge(clk) then
            dbus_out <= dbus_in;
            dbus_out.marked_for_deletion <= true;
            
            if dbus_in.marked_for_deletion or
            dbus_in.target_address = 0 or
            rst = '1' then
                dbus_out <= c_dbus;
            end if;
            
        end if;
    end process;

end architecture rtl;