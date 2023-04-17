library ieee;
use ieee.std_logic_1164.all;

entity tb_I2C_byte is
end tb_I2C_byte;

architecture tb of tb_I2C_byte is

    component I2C_byte
    generic(
        frequency_mhz : real := 27.0;
        i2c_frequency_mhz : real := 0.4;
        simulation : boolean := true
    );
    port (clk       : in std_logic;
        rst       : in std_logic;
        sda       : inout std_logic;
        scl       : inout std_logic;
        o_working : out std_logic;
        i_ctrl    : in std_logic_vector (1 downto 0);
        i_ack     : in std_logic;
        i_data    : in std_logic_vector (7 downto 0);
        o_ack     : out std_logic;
        o_data    : out std_logic_vector (7 downto 0));
end component;

signal clk       : std_logic;
signal rst       : std_logic;
signal sda       : std_logic;
signal scl       : std_logic;
signal o_working : std_logic;
signal i_ctrl    : std_logic_vector (1 downto 0);
signal i_ack     : std_logic;
signal i_data    : std_logic_vector (7 downto 0);
signal o_ack     : std_logic;
signal o_data    : std_logic_vector (7 downto 0);

constant TbPeriod : time := 37 ns; -- EDIT Put right period here
signal TbClock : std_logic := '0';
signal TbSimEnded : std_logic := '0';

begin

    dut : I2C_byte
    port map (clk       => clk,
        rst       => rst,
        sda       => sda,
        scl       => scl,
        o_working => o_working,
        i_ctrl    => i_ctrl,
        i_ack     => i_ack,
        i_data    => i_data,
        o_ack     => o_ack,
        o_data    => o_data);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        i_ctrl <= (others => '0');
        i_ack <= '0';
        i_data <= (others => '0');

        -- Reset generation
        -- EDIT: Check that rst is really your reset signal
        rst <= '1';
        wait for 10 * TbPeriod;
        rst <= '0';
        wait for 10 * TbPeriod;
        
        
        

        -- EDIT Add stimuli here
        
        i_ctrl <= "01";
        wait for 1 * TbPeriod;
        i_ctrl <= "00";
        wait until o_working = '0';
        wait for 1 * TbPeriod;
        i_ctrl <= "11";
        i_data <= "01010110";
        wait for 1 * TbPeriod;
        i_ctrl <= "00";
        i_data <= (others => '0');
        wait until o_working = '0';
        wait for 1 * TbPeriod;
        i_ctrl <= "10";
        wait for 1 * TbPeriod;
        i_ctrl <= "00";
        wait until o_working = '0';
        wait for 100 * TbPeriod;

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