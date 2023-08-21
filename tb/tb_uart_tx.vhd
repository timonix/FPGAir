-- Testbench automatically generated online
-- at https://vhdl.lapinoo.net
-- Generation date : 15.5.2023 20:32:37 UTC

library ieee;
use ieee.std_logic_1164.all;

entity tb_uart_tx is
end tb_uart_tx;

architecture tb of tb_uart_tx is

    component uart_tx
    port (clk        : in std_logic;
        rst        : in std_logic;
        enable     : in boolean;
        tx         : out std_logic;
        data       : in std_logic_vector (7 downto 0);
        data_valid : in boolean;
        ready      : out boolean);
end component;

signal clk        : std_logic;
signal rst        : std_logic;
signal enable     : boolean;
signal tx         : std_logic;
signal data       : std_logic_vector (7 downto 0);
signal data_valid : boolean;
signal ready      : boolean;

constant TbPeriod : time := 37 ns; -- EDIT Put right period here
signal TbClock : std_logic := '0';
signal TbSimEnded : std_logic := '0';

begin

    dut : uart_tx
    port map (clk        => clk,
        rst        => rst,
        enable     => enable,
        tx         => tx,
        data       => data,
        data_valid => data_valid,
        ready      => ready);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        enable <= True;
        data <= (others => '0');
        data_valid <=False;

        -- Reset generation
        -- EDIT: Check that rst is really your reset signal
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 1000 ns;
        wait for 8681 ns;
        assert ready = True;
        
        data <= "01010110";
        data_valid <= True;
        
        wait for TbPeriod;
        assert ready = False;
        
        wait for 8681*10 ns;
        wait for 8681*10 ns;
        wait for 8681*10 ns;

        -- EDIT Add stimuli here
        wait for 100 * TbPeriod;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_uart_tx of tb_uart_tx is
    for tb
end for;
end cfg_tb_uart_tx;