library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;
use IEEE.numeric_std.all;

use ieee.fixed_pkg.all;

use work.common_pkg.ALL;

entity tb_mixer is
end tb_mixer;




architecture tb of tb_mixer is


    signal clk             : std_logic;
    signal rst             : std_logic;
    signal enable          : boolean;
    signal throttle_i      : sfixed (11 downto -11);
    signal roll_pid_i      : sfixed (11 downto -11);
    signal pitch_pid_i     : sfixed (11 downto -11);
    signal yaw_pid_i       : sfixed (11 downto -11);
    signal motor1_signal_o : UNSIGNED (10 downto 0);
    signal motor2_signal_o : UNSIGNED (10 downto 0);
    signal motor3_signal_o : UNSIGNED (10 downto 0);
    signal motor4_signal_o : UNSIGNED (10 downto 0);
    
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
        motor3_signal_o => motor3_signal_o,
        motor4_signal_o => motor4_signal_o);
    
    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    
    procedure wait_and_set_to_0 is
    begin
        wait for 5 * TbPeriod;
        throttle_i <= (others => '0');
        roll_pid_i <= (others => '0');
        pitch_pid_i <= (others => '0');
        yaw_pid_i <= (others => '0');
        wait for 1 * TbPeriod;
    end procedure;
    
    begin
        -- EDIT Adapt initialization as needed
        enable <= True;
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
        report "this is a message"; -- severity note
        throttle_i <= to_sfixed(100, 11,-11);
        roll_pid_i <= (others => '0');
        pitch_pid_i <= (others => '0');
        yaw_pid_i <= (others => '0');
        
        wait_and_set_to_0;
        
        throttle_i <= (others => '0');
        roll_pid_i <=  to_sfixed(200, 11,-11);
        pitch_pid_i <= (others => '0');
        yaw_pid_i <= (others => '0');
        
        wait for 2 * TbPeriod;
        
        assert motor1_signal_o > 0 report "unexpected value. i = " & to_string(motor1_signal_o);
        
        wait_and_set_to_0;
        
        throttle_i <= (others => '0');
        roll_pid_i <= (others => '0');
        pitch_pid_i <=  to_sfixed(300, 11,-11);
        yaw_pid_i <= (others => '0');
        
        wait for 2 * TbPeriod;
        
        assert motor1_signal_o > 0 report "unexpected value. i = " & to_string(motor1_signal_o);
        
        wait_and_set_to_0;
        
        throttle_i <= (others => '0');
        roll_pid_i <= (others => '0');
        pitch_pid_i <= (others => '0');
        yaw_pid_i <=  to_sfixed(400, 11,-11);
        
        
        -- Full throttle and roll
        wait_and_set_to_0;
        
        throttle_i <= to_sfixed(1000, 11,-11);
        roll_pid_i <= to_sfixed(400, 11,-11);
        pitch_pid_i <= (others => '0');
        yaw_pid_i <=  (others => '0');

        wait for 2 * TbPeriod;
        
        assert motor1_signal_o = 1000 report "unexpected value. i = " & to_string(motor1_signal_o);
        assert motor2_signal_o < 1000 report "unexpected value. i = " & to_string(motor2_signal_o);
        assert motor3_signal_o = 1000 report "unexpected value. i = " & to_string(motor3_signal_o);
        assert motor4_signal_o < 1000 report "unexpected value. i = " & to_string(motor4_signal_o);
        
        
        -- Full throttle and putch
        wait_and_set_to_0;
        
        throttle_i <= to_sfixed(1000, 11,-11);
        roll_pid_i <= (others => '0');
        pitch_pid_i <= to_sfixed(400, 11,-11);
        yaw_pid_i <= (others => '0');

        wait for 2 * TbPeriod;
        
        assert motor1_signal_o = 1000 report "unexpected value. i = " & to_string(motor1_signal_o);
        assert motor2_signal_o = 1000 report "unexpected value. i = " & to_string(motor2_signal_o);
        assert motor3_signal_o < 1000 report "unexpected value. i = " & to_string(motor3_signal_o);
        assert motor4_signal_o < 1000 report "unexpected value. i = " & to_string(motor4_signal_o);
        

        -- Full throttle and yaw
        wait_and_set_to_0;
        
        throttle_i <= to_sfixed(1000, 11,-11);
        roll_pid_i <= (others => '0');
        pitch_pid_i <= (others => '0');
        yaw_pid_i <=  to_sfixed(400, 11,-11);

        wait for 2 * TbPeriod;
        
        assert motor1_signal_o < 1000 report "unexpected value. i = " & to_string(motor1_signal_o);
        assert motor2_signal_o = 1000 report "unexpected value. i = " & to_string(motor2_signal_o);
        assert motor3_signal_o = 1000 report "unexpected value. i = " & to_string(motor3_signal_o);
        assert motor4_signal_o < 1000 report "unexpected value. i = " & to_string(motor4_signal_o);
        
        wait for 2 * TbPeriod;
        
        
        
        
        
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