-- Testbench automatically generated online
-- at https://vhdl.lapinoo.net
-- Generation date : 15.5.2023 19:33:00 UTC

library ieee;
use ieee.std_logic_1164.all;

entity tb_uart_multi_rx is
end tb_uart_multi_rx;

architecture tb of tb_uart_multi_rx is

signal clk        : std_logic;
signal rst        : std_logic;
signal enable     : boolean;
signal rx         : std_logic;
signal data       : std_logic_vector (15 downto 0);
signal data_valid : boolean;
signal ready      : boolean;

constant TbPeriod : time := 37 ns; -- EDIT Put right period here
signal TbClock : std_logic := '0';
signal TbSimEnded : std_logic := '0';

begin

    DUT: entity work.uart_multi_rx(rtl)
    generic map (
        frequency_mhz => 27.0,
        baud_rate_mhz => 115200.0/1000000.0
    )
    port map (clk        => clk,
        rst        => rst,
        enable     => enable,
        rx         => rx,
        data       => data,
        data_valid => data_valid);

    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    clk <= TbClock;

    stimuli : process
    begin
        enable <= true;
        rx <= '1';

        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 100 ns;
        
        wait for 1000 ns;
        rx <= '0';
        wait for 8681 ns;
        rx <= '1';
        wait for 8681 ns;
        rx <= '1';
        wait for 8681 ns;
        rx <= '0';
        wait for 8681 ns;
        rx <= '1';
        wait for 8681 ns;
        rx <= '1';
        wait for 8681 ns;
        rx <= '0';
        wait for 8681 ns;
        rx <= '1';
        wait for 8681 ns;
        rx <= '0';
        wait for 8681 ns;
        wait for 8681 ns;
        
        wait for 1000 ns;
        rx <= '0';
        wait for 8681 ns;
        rx <= '1';
        wait for 8681 ns;
        rx <= '1';
        wait for 8681 ns;
        rx <= '0';
        wait for 8681 ns;
        rx <= '1';
        wait for 8681 ns;
        rx <= '1';
        wait for 8681 ns;
        rx <= '0';
        wait for 8681 ns;
        rx <= '1';
        wait for 8681 ns;
        rx <= '0';
        wait for 8681 ns;
        wait for 8681 ns;
        
        
        
        wait for 100 * TbPeriod;

        TbSimEnded <= '1';
        wait;
    end process;

end tb;