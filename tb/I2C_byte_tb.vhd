library ieee;
use ieee.std_logic_1164.all;

entity tb_I2C_byte is
end tb_I2C_byte;

architecture tb of tb_I2C_byte is

    component I2C_byte
    generic(
        frequency_mhz : real := 27.0;
        i2c_frequency_mhz : real := 0.4
    );
    port (clk    : in std_logic;
        rst    : in std_logic;
        i_send_byte : in STD_LOGIC;
        i_data : in std_logic_vector (7 downto 0));
end component;

signal clk    : std_logic;
signal rst    : std_logic;
signal s_send_byte : std_logic;
signal i_data : std_logic_vector (7 downto 0);

constant TbPeriod : time := (100 ns)/27; -- EDIT Put right period here
signal TbClock : std_logic := '0';
signal TbSimEnded : std_logic := '0';



begin

    dut : I2C_byte
    port map (clk    => clk,
        rst    => rst,
        i_send_byte => s_send_byte,
        i_data => i_data);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        i_data <= (others => '0');

        -- Reset generation
        -- EDIT: Check that rst is really your reset signal
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 100 ns;

        -- EDIT Add stimuli here
        wait for 4000 * TbPeriod;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_I2C_byte of tb_I2C_byte is
    for tb
end for;
end cfg_tb_I2C_byte;