library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity I2C_byte_tb_2 is
end I2C_byte_tb_2;

architecture tb of I2C_byte_tb_2 is
    signal clk, rst: std_logic := '0';
    signal sda, scl: std_logic;
    signal o_working: std_logic;
    signal i_ctrl: std_logic_vector(1 downto 0);
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
        i_ctrl <= "00";
        i_ack <= '0';
        i_data <= (others => '0');
        wait for clk_period * 2;
        rst <= '0';

        -- Send start condition
        i_ctrl <= "01"; -- START
        i_ack <= '0';
        i_data <= "00000000";
        wait until o_working = '0';

        -- Read/Write
        i_ctrl <= "11"; -- READ/WRITE
        i_ack <= '0';
        i_data <= "10101010"; -- Sample data
        wait until o_working = '0';

        -- Send stop condition
        i_ctrl <= "10"; -- STOP
        i_ack <= '0';
        i_data <= "00000000";
        wait until o_working = '0';
        
        TbSimEnded <= true;
        -- Finish test
        wait;
    end process tb;
end architecture tb;

