library ieee;
use ieee.std_logic_1164.all;

use work.common_pkg.all;

entity debug_module_dbus is
    generic(
        register_address : natural range 1 to dbus_range := 8;
        enable_force : boolean := false
    );
    port(
        
        clk         : in std_logic;
        rst         : in STD_LOGIC;
        
        data_in  : in std_logic_vector(7 downto 0);
        data_out : out std_logic_vector(7 downto 0);
        
        dbus_in : in dbus;
        dbus_out : out dbus

    );
end debug_module_dbus;

architecture rtl of debug_module_dbus is
    
    signal force_data : std_logic_vector(7 downto 0);
    signal s_force : boolean;
    signal s_is_injected : boolean;
    
begin
    
    data_out <= force_data when s_force and enable_force else data_in;

    process(clk)
    begin
        if rising_edge(clk) then
            dbus_out <= dbus_in;
            if s_is_injected then
                s_force <= false;
                s_is_injected <= false;
            end if;
            
            if dbus_in.target_address = register_address and dbus_in.command = RD then
                dbus_out.command <= WR;
                dbus_out.source_address <= register_address;
                dbus_out.target_address <= dbus_in.source_address;
                dbus_out.data <= data_in;
            elsif dbus_in.target_address = register_address and dbus_in.command = WR and enable_force then
                dbus_out.source_address <= 0;
                dbus_out.target_address <= 0;
                dbus_out.data <= (others => '0');
                force_data <= dbus_in.data;
                s_force <= true;
                s_is_injected <= true;
            elsif dbus_in.target_address = register_address and dbus_in.command = INJECT and enable_force then
                dbus_out.source_address <= 0;
                dbus_out.target_address <= 0;
                dbus_out.data <= (others => '0');
                force_data <= dbus_in.data;
                s_force <= true;
            elsif dbus_in.target_address = register_address and dbus_in.command = CLR and enable_force then
                dbus_out.source_address <= 0;
                dbus_out.target_address <= 0;
                dbus_out.data <= (others => '0');
                force_data <= dbus_in.data;
                s_force <= false;
            end if;
            
            if rst = '1' then
                s_force <= false;
            end if;
        end if;
    end process;

end rtl;