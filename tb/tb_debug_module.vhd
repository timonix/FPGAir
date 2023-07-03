library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common_pkg.all;

entity debug_module_tb is
end debug_module_tb;

architecture tb of debug_module_tb is
    constant clk_period : time := 37 ns;
    signal TbSimEnded : boolean := false;
    
    signal current_test : integer := 0;
    
    signal clk       : std_logic := '0';
    signal rst       : std_logic := '0';
    signal data_in   : std_logic_vector(7 downto 0) := (others => '0');
    signal data_out  : std_logic_vector(7 downto 0);
    signal dbus_in   : dbus;
    signal dbus_out  : dbus;
    
begin
    -- Instantiate the debug_module
    uut: entity work.debug_module generic map(
        register_address => 10,
        enable_force => true
    ) port map(
        clk => clk,
        rst => rst,
        data_in => data_in,
        data_out => data_out,
        dbus_in => dbus_in,
        dbus_out => dbus_out
    );

    -- Clock process definitions
    clk <= not clk after clk_period / 2 when not TbSimEnded else '0';
    
    -- Stimulus process
    stim_proc: process
    begin
        -- Reset pulse
        rst <= '1';
        wait for clk_period*10;
        rst <= '0';
        wait for clk_period;
        
            -- Sample test 1
        current_test <= 1;
        dbus_in.target_address <= 10;  -- Must be the same as the generic map register_address
        dbus_in.command <= RD;
        dbus_in.data <= "01010101";
        data_in <= "11111111";
        wait for clk_period;
        assert dbus_out.command = WR and dbus_out.data = data_in
        report "Test 1 Failed" severity ERROR;
        
    -- Sample test 2
        current_test <= 2;
        dbus_in.target_address <= 10;  -- Must be the same as the generic map register_address
        dbus_in.command <= WR;
        dbus_in.data <= "10101010";
        data_in <= "00000000";
        wait for clk_period;
        assert dbus_out.source_address = 0 and dbus_out.target_address = 0 and dbus_out.data = x"00" and data_out = dbus_in.data
        report "Test 2 Failed" severity ERROR;
        
    -- Sample test 3
        current_test <= 3;
        dbus_in.target_address <= 10;  -- Must be the same as the generic map register_address
        dbus_in.command <= CLR;
        dbus_in.data <= "11110000";
        data_in <= "11110000";
        wait for clk_period;
        assert dbus_out.source_address = 0 and dbus_out.target_address = 0 and dbus_out.data = x"00" and data_out = data_in
        report "Test 3 Failed" severity ERROR;
        
        
        TbSimEnded <= true;
        
        wait;
    end process;
    
end tb;