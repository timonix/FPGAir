library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.common_pkg.ALL;

entity tb_I2C_byte_2 is
end tb_I2C_byte_2;

architecture tb of tb_I2C_byte_2 is
    signal clk, rst: std_logic := '0';
    signal sda, scl: std_logic;
    signal o_working: boolean;
    signal i_ctrl: t_i2c_ctrl;
    signal i_ack: std_logic;
    signal i_data: std_logic_vector(7 downto 0);
    signal o_ack: std_logic;
    signal o_data: std_logic_vector(7 downto 0);
    
    signal TbSimEnded : boolean := false;

    constant clk_period : time := 37 ns;
    
begin
    -- DUT (Device Under Test)
    dut: entity work.I2C_byte(rtl)
    generic map (frequency_mhz => 27.0, i2c_frequency_mhz => 0.4, simulation => true)
    port map (
        clk => clk,
        rst => rst,
        sda => sda,
        scl => scl,
        o_working => o_working,
        i_ctrl => i_ctrl,
        i_ack => i_ack,
        i_data => i_data,
        o_ack => o_ack,
        o_data => o_data
    );

    clk <= not clk after clk_period / 2 when not TbSimEnded else '0';

    tb: process
    begin
        -- reset
        rst <= '1';
        i_ctrl <= NOP_E;
        i_ack <= '0';
        i_data <= (others => '0');
        wait for clk_period * 2;
        rst <= '0';

        -- Send start condition
        i_ctrl <= START;
        i_ack <= '0';
        i_data <= "00000000";
        wait until o_working = false;

        --Read/Write
        i_ctrl <= RW;
        i_ack <= '0';
        i_data <= "10101010"; -- Sample data
        wait until o_working = false;

        -- Send stop condition
        i_ctrl <= STOP; -- STOP
        i_ack <= '0';
        i_data <= "00000000";
        wait until o_working = false;
        
        wait for clk_period * 500;
        
        TbSimEnded <= true;
        -- Finish test
        wait;
    end process tb;
end architecture tb;

