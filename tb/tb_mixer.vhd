library ieee;
use ieee.std_logic_1164.all;

entity tb_mixer is
end tb_mixer;
use work.common_pkg.ALL;

architecture tb of tb_mixer is


signal clk             : std_logic;
signal rst             : std_logic;
signal enable          : boolean;
signal throttle_i      : sfixed (11 downto -11);
signal roll_pid_i      : sfixed (11 downto -11);
signal pitch_pid_i     : sfixed (11 downto -11);
signal yaw_pid_i       : sfixed (11 downto -11);
signal motor1_signal_o : sfixed (11 downto -11);
signal motor2_signal_o : sfixed (11 downto -11);
signal motor3_signal_o : sfixed (11 downto -11);

constant TbPeriod : time := 1000 ns; -- EDIT Put right period here
signal TbClock : std_logic := '0';
signal TbSimEnded : std_logic := '0';

begin

    dut : entity work.mixer(rtl)
    port map (clk             => clk,
        rst             => rst,
        enable          => enable,
        throttle_i      => throttle_i,
        roll_pid_i      => roll_pid_i,
        pitch_pid_i     => pitch_pid_i,
        yaw_pid_i       => yaw_pid_i,
        motor1_signal_o => motor1_signal_o,
        motor2_signal_o => motor2_signal_o,
        motor3_signal_o => motor3_signal_o);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        enable <= '0';
        throttle_i <= (others => '0');
        roll_pid_i <= (others => '0');
        pitch_pid_i <= (others => '0');
        yaw_pid_i <= (others => '0');

        -- Reset generation
        -- EDIT: Check that rst is really your reset signal
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 100 ns;

        -- EDIT Add stimuli here
        wait for 5 * TbPeriod;
        
        throttle_i <= to_sfixed(500, throttle_i'length);
        roll_pid_i <= (others => '0');
        pitch_pid_i <= (others => '0');
        yaw_pid_i <= (others => '0');
        
        wait for 5 * TbPeriod;
        
        throttle_i <= (others => '0');
        roll_pid_i <= to_sfixed(500, throttle_i'length);
        pitch_pid_i <= (others => '0');
        yaw_pid_i <= (others => '0');
        

        wait for 5 * TbPeriod;
        
        throttle_i <= (others => '0');
        roll_pid_i <= (others => '0');
        pitch_pid_i <= to_sfixed(500, throttle_i'length);
        yaw_pid_i <= (others => '0');

        
        wait for 5 * TbPeriod;
        
        throttle_i <= (others => '0');
        roll_pid_i <= (others => '0');
        pitch_pid_i <= (others => '0');
        yaw_pid_i <= to_sfixed(500, throttle_i'length);

        wait for 5 * TbPeriod;
        

        
        

        
        
        
        
        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_mixer of tb_mixer is
    for tb
end for;
end cfg_tb_mixer;