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
    
    signal throttle_i_value : sfixed(11 downto -11);
    signal roll_pid_i_value : sfixed(11 downto -11);
    signal pitch_pid_i_value : sfixed(11 downto -11);
    signal yaw_pid_i_value : sfixed(11 downto -11);

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
    
    procedure set_values_and_wait (
        throttle_i_input : in sfixed (11 downto -11);
        roll_pid_i_input : in sfixed (11 downto -11);
        pitch_pid_i_input : in sfixed (11 downto -11);
        yaw_pid_i_input : in sfixed (11 downto -11)
    ) is
    begin

        throttle_i <= (others => '0');
        roll_pid_i <= (others => '0');
        pitch_pid_i <= (others => '0');
        yaw_pid_i <= (others => '0');
        
        wait for 1 * TbPeriod;
        
        report "throttle = " & to_string(throttle_i_input);
        
        throttle_i <= throttle_i_input;
        roll_pid_i <= roll_pid_i_input;
        pitch_pid_i <= pitch_pid_i_input;
        yaw_pid_i <= yaw_pid_i_input;
        
        
        
        wait for 5 * TbPeriod;
        report "throttle = " & to_string(motor1_signal_o);
    end procedure;
    
    procedure set_to_0_and_wait is
    begin

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
        wait for 2 * TbPeriod;
        report "this is a message"; -- severity note
        
        -- Throttle ------------------------------------------------------
        --throttle_i_value <= to_sfixed(100, 11,-11);
        --roll_pid_i_value <= to_sfixed(0, 11,-11);
        --pitch_pid_i_value <= to_sfixed(0, 11,-11);
        --yaw_pid_i_value <= to_sfixed(0, 11,-11);
        --
        --set_values_and_wait(to_sfixed(100, 11,-11), roll_pid_i_value, pitch_pid_i_value, yaw_pid_i_value);
        --
        --assert motor1_signal_o = 100 report "unexpected value. i = " & to_string(motor1_signal_o);
        --assert motor2_signal_o = 100 report "unexpected value. i = " & to_string(motor2_signal_o);
        --assert motor3_signal_o = 100 report "unexpected value. i = " & to_string(motor3_signal_o);
        --assert motor4_signal_o = 100 report "unexpected value. i = " & to_string(motor4_signal_o);
        ----------------------------------------------------------------
        
        -- Throttle -----------------------------------------------
        set_to_0_and_wait;

        throttle_i <= to_sfixed(100, 11,-11);
        roll_pid_i <=  (others => '0');
        pitch_pid_i <= (others => '0');
        yaw_pid_i <= (others => '0');
        
        wait for 2 * TbPeriod;
        
        assert motor1_signal_o = 100 report "unexpected value. i = " & to_string(motor1_signal_o);
        assert motor2_signal_o = 100 report "unexpected value. i = " & to_string(motor2_signal_o);
        assert motor3_signal_o = 100 report "unexpected value. i = " & to_string(motor3_signal_o);
        assert motor4_signal_o = 100 report "unexpected value. i = " & to_string(motor4_signal_o);
        
        -- Roll right ---------------------------------------------------------
        set_to_0_and_wait;

        throttle_i <= (others => '0');
        roll_pid_i <=  to_sfixed(200, 11,-11);
        pitch_pid_i <= (others => '0');
        yaw_pid_i <= (others => '0');
        
        wait for 2 * TbPeriod;
        
        assert motor1_signal_o = 200 report "unexpected value. i = " & to_string(motor1_signal_o);
        assert motor2_signal_o = 0 report "unexpected value. i = " & to_string(motor2_signal_o);
        assert motor3_signal_o = 200 report "unexpected value. i = " & to_string(motor3_signal_o);
        assert motor4_signal_o = 0 report "unexpected value. i = " & to_string(motor4_signal_o);
        
        -- Roll left ---------------------------------------------------------
        set_to_0_and_wait;

        throttle_i <= (others => '0');
        roll_pid_i <=  to_sfixed(-200, 11,-11);
        pitch_pid_i <= (others => '0');
        yaw_pid_i <= (others => '0');
        
        wait for 2 * TbPeriod;
        
        assert motor1_signal_o = 0 report "unexpected value. i = " & to_string(motor1_signal_o);
        assert motor2_signal_o = 200 report "unexpected value. i = " & to_string(motor2_signal_o);
        assert motor3_signal_o = 0 report "unexpected value. i = " & to_string(motor3_signal_o);
        assert motor4_signal_o = 200 report "unexpected value. i = " & to_string(motor4_signal_o);
        
        -- Pitch up ---------------------------------------------------------
        set_to_0_and_wait;

        throttle_i <= (others => '0');
        roll_pid_i <=  (others => '0');
        pitch_pid_i <= to_sfixed(300, 11,-11);
        yaw_pid_i <= (others => '0');
        
        wait for 2 * TbPeriod;
        
        assert motor1_signal_o = 300 report "unexpected value. i = " & to_string(motor1_signal_o);
        assert motor2_signal_o = 300 report "unexpected value. i = " & to_string(motor2_signal_o);
        assert motor3_signal_o = 0 report "unexpected value. i = " & to_string(motor3_signal_o);
        assert motor4_signal_o = 0 report "unexpected value. i = " & to_string(motor4_signal_o);
        
        -----------------------------------------------------------
        
        
        --set_to_0_and_wait;
        --
        --throttle_i <= (others => '0');
        --roll_pid_i <= (others => '0');
        --pitch_pid_i <=  to_sfixed(300, 11,-11);
        --yaw_pid_i <= (others => '0');
        --
        --wait for 2 * TbPeriod;
        --
        --assert motor1_signal_o > 0 report "unexpected value. i = " & to_string(motor1_signal_o);
        --
        --set_to_0_and_wait;
        --
        --throttle_i <= (others => '0');
        --roll_pid_i <= (others => '0');
        --pitch_pid_i <= (others => '0');
        --yaw_pid_i <=  to_sfixed(400, 11,-11);
        --
        --
        ---- Full throttle and roll
        --set_to_0_and_wait;
        --
        --throttle_i <= to_sfixed(1000, 11,-11);
        --roll_pid_i <= to_sfixed(400, 11,-11);
        --pitch_pid_i <= (others => '0');
        --yaw_pid_i <=  (others => '0');
--
        --wait for 2 * TbPeriod;
        --
        --assert motor1_signal_o = 1000 report "unexpected value. i = " & to_string(motor1_signal_o);
        --assert motor2_signal_o < 1000 report "unexpected value. i = " & to_string(motor2_signal_o);
        --assert motor3_signal_o = 1000 report "unexpected value. i = " & to_string(motor3_signal_o);
        --assert motor4_signal_o < 1000 report "unexpected value. i = " & to_string(motor4_signal_o);
        --
        --
        ---- Full throttle and putch
        --set_to_0_and_wait;
        --
        --throttle_i <= to_sfixed(1000, 11,-11);
        --roll_pid_i <= (others => '0');
        --pitch_pid_i <= to_sfixed(400, 11,-11);
        --yaw_pid_i <= (others => '0');
--
        --wait for 2 * TbPeriod;
        --
        --assert motor1_signal_o = 1000 report "unexpected value. i = " & to_string(motor1_signal_o);
        --assert motor2_signal_o = 1000 report "unexpected value. i = " & to_string(motor2_signal_o);
        --assert motor3_signal_o < 1000 report "unexpected value. i = " & to_string(motor3_signal_o);
        --assert motor4_signal_o < 1000 report "unexpected value. i = " & to_string(motor4_signal_o);
        --
--
        ---- Full throttle and yaw
        --set_to_0_and_wait;
        --
        --throttle_i <= to_sfixed(1000, 11,-11);
        --roll_pid_i <= (others => '0');
        --pitch_pid_i <= (others => '0');
        --yaw_pid_i <=  to_sfixed(400, 11,-11);
--
        --wait for 2 * TbPeriod;
        --
        --assert motor1_signal_o < 1000 report "unexpected value. i = " & to_string(motor1_signal_o);
        --assert motor2_signal_o = 1000 report "unexpected value. i = " & to_string(motor2_signal_o);
        --assert motor3_signal_o = 1000 report "unexpected value. i = " & to_string(motor3_signal_o);
        --assert motor4_signal_o < 1000 report "unexpected value. i = " & to_string(motor4_signal_o);
        --
        --wait for 2 * TbPeriod;
        
        
        
        
        
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