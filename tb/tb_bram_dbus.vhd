library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common_pkg.all;

entity bram_dbus_tb is
end bram_dbus_tb;

architecture sim of bram_dbus_tb is

    constant CLK_PERIOD : time := 37 ns;
    
    -- Define the generics
    constant REGISTER_START : natural := 25;
    constant REGISTER_STOP  : natural := 55;

    -- Define the signals
    signal clk        : std_logic := '0';
    signal rst        : std_logic := '0';
    signal dbus_in    : dbus;
    signal dbus_out   : dbus;
    
    signal TbSimEnded : boolean := false;


    
begin

    -- Generate the clock
    clk <= not clk after clk_period / 2 when not TbSimEnded else '0';

    -- Instantiate the DUT
    DUT: entity work.bram_dbus(rtl)
    generic map (
        register_start => REGISTER_START,
        register_stop  => REGISTER_STOP
    )
    port map (
        clk       => clk,
        rst       => rst,
        dbus_in   => dbus_in,
        dbus_out  => dbus_out
    );

    -- Create the test process
    stim_proc: process
    begin
        -- Initialize the inputs
        dbus_in <= c_dbus;
        rst <= '1';
        wait for CLK_PERIOD;
        rst <= '0';
        
        
        -- Test writing to the bram_dbus
        dbus_in.source_address <= 35;
        dbus_in.target_address <= REGISTER_START;
        dbus_in.command <= WR;
        dbus_in.data <= "00000001";
        wait for CLK_PERIOD;
        dbus_in <= c_dbus;
        wait for CLK_PERIOD*4;
        
        -- Test reading from the bram_dbus
        dbus_in.source_address <= 45;
        dbus_in.target_address <= REGISTER_START;
        dbus_in.command <= RD;
        dbus_in.data <= (others => '0');
        wait for CLK_PERIOD;
        
        wait for CLK_PERIOD*50;

        TbSimEnded <= true;
        -- Insert more tests as needed
        -- ...

        -- Finish the test
        wait;
    end process;

end architecture sim;