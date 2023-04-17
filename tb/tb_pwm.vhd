-- Testbench automatically generated online
-- at https://vhdl.lapinoo.net
-- Generation date : 17.4.2023 20:23:12 UTC

library ieee;
use ieee.std_logic_1164.all;

entity tb_pwm is
end tb_pwm;

architecture tb of tb_pwm is

    component pwm
    port (clk    : in std_logic;
        rst    : in std_logic;
        speed  : in std_logic_vector (10 downto 0);
        output : out std_logic);
end component;

signal clk    : std_logic;
signal rst    : std_logic;
signal speed  : std_logic_vector (10 downto 0);
signal output : std_logic;

constant TbPeriod : time := 37 ns; -- EDIT Put right period here
signal TbClock : std_logic := '0';
signal TbSimEnded : std_logic := '0';

begin

    dut : pwm
    port map (clk    => clk,
        rst    => rst,
        speed  => speed,
        output => output);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        speed <= (others => '0');

        -- Reset generation
        -- EDIT: Check that rst is really your reset signal
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 100 ns;
        
        speed <= "01111101000";
        
        wait for 5 ms;
        
        --speed <= "00111110100";
        
        wait for 5 ms;
        
        -- EDIT Add stimuli here
        wait for 100 * TbPeriod;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_pwm of tb_pwm is
    for tb
end for;
end cfg_tb_pwm;