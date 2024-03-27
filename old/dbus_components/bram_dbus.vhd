library ieee;
use ieee.std_logic_1164.all;

use work.common_pkg.all;

entity bram_dbus is
    generic(
        register_start : natural range 1 to dbus_range := 1024;
        register_stop : natural range 1 to dbus_range := 2047
    );
    port(
        
        clk         : in std_logic;
        rst         : in STD_LOGIC;
        
        dbus_in : in dbus;
        dbus_out : out dbus

    );
end bram_dbus;

architecture rtl of bram_dbus is
    
    type t_ram is array (register_start to register_stop) of std_logic_vector(7 downto 0);
    signal s_ram : t_ram;
    
    signal dbus_Q : dbus := c_dbus;
    signal dbus_QQ : dbus := c_dbus;
    signal s_ram_addr : natural range register_start to register_stop;
    signal s_wr : boolean;
    signal s_rd : boolean;
    
    
begin
    
    assert register_stop > register_start report "invalid address range:" severity failure;
    
    process(clk)
    begin
        if rising_edge(clk) then
            dbus_Q <= dbus_in;
            dbus_QQ <= dbus_Q;
            dbus_out <= dbus_QQ;
            
            s_wr <= false;
            s_rd <= false;
            if dbus_in.target_address >= register_start and dbus_in.target_address <= register_stop then
                s_ram_addr <= dbus_in.target_address;
                s_wr <= dbus_in.command = WR OR dbus_in.command = INJECT;
                s_rd <= dbus_in.command = RD OR dbus_in.command = CLR;
            end if;
            
            if s_wr then
                dbus_QQ <= c_dbus;
                s_ram(s_ram_addr) <= dbus_Q.data;
            end if;
            
            if s_rd then
                dbus_QQ <= c_dbus;
                dbus_QQ.target_address <= dbus_Q.source_address;
                dbus_QQ.data <= s_ram(s_ram_addr);
                dbus_QQ.source_address <= s_ram_addr;
                dbus_QQ.command <= WR;
            end if;
            
        end if;
    end process;
    

end architecture rtl;