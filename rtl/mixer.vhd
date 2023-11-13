
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.fixed_pkg.all;


use work.common_pkg.ALL;

entity mixer is
    port(
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        enable : in BOOLEAN;
        throttle_i : in sfixed(11 downto -11);
        roll_pid_i : in sfixed(11 downto -11);
        pitch_pid_i : in sfixed(11 downto -11);
        yaw_pid_i : in sfixed(11 downto -11);
        motor1_signal_o : out UNSIGNED(10 downto 0);
        motor2_signal_o : out UNSIGNED(10 downto 0);
        motor3_signal_o : out UNSIGNED(10 downto 0);
        motor4_signal_o : out UNSIGNED(10 downto 0)
    );
end entity mixer;

architecture rtl of mixer is
    
    --signals
    signal tmp1 : sfixed(14 downto -11);
    signal tmp2 : sfixed(14 downto -11);
    signal tmp3 : sfixed(14 downto -11);
    signal tmp4 : sfixed(14 downto -11);
    
    function clamp(value: sfixed; min_val: integer; max_val: integer) return sfixed is
begin
    if to_integer(value) < min_val then
        return to_sfixed(min_val, value'left, value'right);
    elsif to_integer(value) > max_val then
        return to_sfixed(max_val, value'left, value'right);
    else
        return value;
    end if;
end function;

begin

    process (clk)
    begin
        if rising_edge(clk) then
            
            -- Mix the throttle and PID values
            --report "throttle_i value: " & to_string(throttle_i);
            --report "roll_pid_i value: " & to_string(roll_pid_i);
            ----report "pitch_pid_i value: " & to_string(pitch_pid_i);
            --report "yaw_pid_i value: " & to_string(yaw_pid_i);
            
        --    tmp1 <= throttle_i - roll_pid_i - pitch_pid_i + yaw_pid_i;
        --    tmp2 <= throttle_i + roll_pid_i - pitch_pid_i - yaw_pid_i;
        --    tmp3 <= throttle_i - roll_pid_i + pitch_pid_i - yaw_pid_i;
        --    tmp4 <= throttle_i + roll_pid_i + pitch_pid_i + yaw_pid_i;
        --
        --    -- Limit the signals max value
        --    if tmp1 > 1000 then
        --        tmp1 <= to_sfixed(1000, tmp1'length);
        --    end if;
        --    if tmp2 > 1000 then
        --        tmp2 <= to_sfixed(1000, tmp2'length);
        --    end if;
        --    if tmp3 > 1000 then
        --        tmp3 <= to_sfixed(1000, tmp3'length);
        --    end if;
        --    if tmp4 > 1000 then
        --        tmp4 <= to_sfixed(1000, tmp4'length);
        --    end if;
        --
        --    -- Limit the signals min value
        --    if tmp1 < 0 then
        --        tmp1 <= (others => '0');
        --    end if;
        --    if tmp2 < 0 then
        --        tmp2 <= (others => '0');
        --    end if;
        --    if tmp3 < 0 then
        --        tmp3 <= (others => '0');
        --    end if;
        --    if tmp4 < 0 then
        --        tmp4 <= (others => '0');
        --    end if;
        --
        --    -- Cut all decimal bits
        --    motor1_signal_o <= UNSIGNED(tmp1(10 downto 0));
        --    motor2_signal_o <= UNSIGNED(tmp2(10 downto 0));
        --    motor3_signal_o <= UNSIGNED(tmp3(10 downto 0));
        --    motor4_signal_o <= UNSIGNED(tmp4(10 downto 0));
            
            tmp1 <= clamp(throttle_i + roll_pid_i + pitch_pid_i - yaw_pid_i, 0, 1000);
            tmp2 <= clamp(throttle_i - roll_pid_i + pitch_pid_i + yaw_pid_i, 0, 1000);
            tmp3 <= clamp(throttle_i + roll_pid_i - pitch_pid_i + yaw_pid_i, 0, 1000);
            tmp4 <= clamp(throttle_i - roll_pid_i - pitch_pid_i - yaw_pid_i, 0, 1000);
            
            motor1_signal_o <= UNSIGNED(tmp1(10 downto 0));
            motor2_signal_o <= UNSIGNED(tmp2(10 downto 0));
            motor3_signal_o <= UNSIGNED(tmp3(10 downto 0));
            motor4_signal_o <= UNSIGNED(tmp4(10 downto 0));
            
            -- Reset if not enabled or rst
            if not enable or rst = '1' then
                motor1_signal_o <= (others => '0');
                motor2_signal_o <= (others => '0');
                motor3_signal_o <= (others => '0');
                motor4_signal_o <= (others => '0');
            end if;
            
        end if;
    end process;

end architecture rtl;

