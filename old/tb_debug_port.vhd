library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.common_pkg.all;

entity tb_debug_port is
end tb_debug_port;

architecture tb of tb_debug_port is
    signal clk        : std_logic := '0';
    signal rst        : std_logic := '1';

    signal dbus_in    : dbus;
    signal dbus_out   : dbus;
    
    signal dbus_Q     : dbus;

    signal rx         : std_logic := '1';
    signal tx         : std_logic;

    constant clk_period : time := 37 ns;  -- Clock period, you may change this as required
    signal TbSimEnded : boolean := false;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: entity work.debug_dbus
    generic map(
        register_map => 1,
        frequency_mhz => 27.0,
        baud_rate_mhz => 115200.0/1000000.0,
        rx_buffer_size => 2,
        tx_buffer_size => 2
    )
    port map(
        clk => clk,
        rst => rst,
        dbus_in => dbus_in,
        dbus_out => dbus_out,
        rx => rx,
        tx => tx
    );

    -- Clock process definitions
    clk <= not clk after clk_period / 2 when not TbSimEnded else '0';
    
    process(clk)
    begin
        if rising_edge(clk) then
            dbus_Q <= dbus_out;
            dbus_in <= dbus_Q;
            
            if rst = '1' then
                dbus_in <= C_dbus;
                dbus_Q <= C_dbus;
            end if;
        end if;
    end process;


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
        for bit in test_address'range loop
            rx <= test_address(bit);
            wait for 8.68055556 us;
        end loop;
        rx <= '1'; --stop bit
        
        
        wait for 8.68055556 us;
        
        rx <= '0'; --start bit
        wait for 8.68055556 us;
        for bit in test_data'range loop
            rx <= '0';
            wait for 8.68055556 us;
        end loop;
        rx <= '1'; --stop bit
        wait for 8.68055556 us;
        
        wait for 12*8.68055556 us;
        
        wait for clk_period*10;
        
        TbSimEnded <= true;

        wait;
    end process;

end tb;
