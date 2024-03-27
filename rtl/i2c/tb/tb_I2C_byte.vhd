library ieee;
use ieee.std_logic_1164.all;

use work.common_pkg.t_i2c_ctrl;

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
        o_working : out boolean;
        i_ctrl    : t_i2c_ctrl;
        i_ack     : in std_logic;
        i_data    : in std_logic_vector (7 downto 0);
        o_ack     : out std_logic;
        o_data    : out std_logic_vector (7 downto 0));
end component;

signal clk       : std_logic;
signal rst       : std_logic;
signal sda       : std_logic;
signal scl       : std_logic;
signal o_working : boolean;
signal i_ctrl    : t_i2c_ctrl;
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
        i_ctrl <= NOP_E;
        i_ack <= '0';
        i_data <= (others => '0');

        -- Reset generation
        -- EDIT: Check that rst is really your reset signal
        rst <= '1';
        wait for 10 * TbPeriod;
        rst <= '0';
        wait for 10 * TbPeriod;
        
        
        

        -- EDIT Add stimuli here
        
        i_ctrl <= START;
        wait for 1 * TbPeriod;
        i_ctrl <= NOP_E;
        
        
        wait until o_working = false;
        wait for 1 * TbPeriod;
        i_ctrl <= RW;
        i_data <= "01010110";
        wait for 1 * TbPeriod;
        i_ctrl <= NOP_E;
        i_data <= (others => '0');
        --wait for 10000 * TbPeriod;
        wait until o_working = false;
        wait for 1 * TbPeriod;
        i_ctrl <= STOP;
        wait for 1 * TbPeriod;
        i_ctrl <= NOP_E;
        wait until o_working = false;
        wait for 100 * TbPeriod;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;
