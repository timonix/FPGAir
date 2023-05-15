-- Testbench automatically generated online
-- at https://vhdl.lapinoo.net
-- Generation date : 15.5.2023 19:33:00 UTC

library ieee;
use ieee.std_logic_1164.all;

entity tb_uart_rx is
end tb_uart_rx;

architecture tb of tb_uart_rx is

    component uart_rx
    port (clk        : in std_logic;
        rst        : in std_logic;
        enable     : in boolean;
        rx         : in std_logic;
        data       : out std_logic_vector (7 downto 0);
        data_valid : out boolean);
end component;

signal clk        : std_logic;
signal rst        : std_logic;
signal enable     : boolean;
signal rx         : std_logic;
signal data       : std_logic_vector (7 downto 0);
signal data_valid : boolean;
signal ready      : boolean;

constant TbPeriod : time := 37 ns; -- EDIT Put right period here
signal TbClock : std_logic := '0';
signal TbSimEnded : std_logic := '0';

begin

    dut : uart_rx
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
        
        wait for 100 * TbPeriod;

        TbSimEnded <= '1';
        wait;
    end process;

end tb;


configuration cfg_tb_uart_rx of tb_uart_rx is
    for tb
end for;
end cfg_tb_uart_rx;